# Proje 4: Veritabanı Yük Dengeleme ve Dağıtık Yapılar

> BLM4522, Final dönemi projesi, DBMS: **PostgreSQL 16**, Mimari: **gerçek 3-node dağıtık küme**

## Hızlı Başlangıç

Bu proje tek makinede simülasyon değil; coğrafi olarak ayrı **üç gerçek sunucu** üzerinde, WireGuard private mesh üzerinden çalışır. Kurulum bölümler hâlinde ilerler (her node'da ilgili komutlar):

```bash
# 1) WireGuard mesh (10.10.0.0/24) - her node'da /etc/wireguard/wg0.conf
#    Şablon: wireguard/wg0.conf.example  |  Doğrula: wg show + mesh ping
sudo wg-quick up wg0

# 2) etcd 3-node quorum - tek-node "new" → diğerlerini learner ekle → promote
#    Şablon: etcd/run-etcd.sh.example
bash etcd/run-etcd.sh.example contabo 10.10.0.1     # her node kendi adı/IP'siyle

# 3) Patroni + PostgreSQL 16 (yalnızca DB node'larda: Contabo + AWS)
docker build -t patroni-pg16:local patroni/
# /etc/patroni/patroni.yml yerleştir (gerçek DOSYA), sonra:
bash patroni/run-patroni.sh.example

# 4) HAProxy read/write split (Contabo'da)
#    Şablon: haproxy/haproxy.cfg  → :5000 write, :5001 read, :7000 stats

# 5) Doğrulama / testler
bash scripts/04_replication_status.sh   # cluster durumu + lag
bash scripts/03_failover_test.sh        # otomatik failover senaryosu
```

### Küme Bilgileri

| Node | Mesh IP | Sağlayıcı / Donanım | Rol |
|------|---------|---------------------|-----|
| `contabo` | `10.10.0.1` | Contabo, x86, 8GB, Debian 13 | PostgreSQL + Patroni + etcd + **HAProxy** |
| `aws` | `10.10.0.2` | AWS t4g.small, ARM, 2GB, Debian 13 | PostgreSQL + Patroni + etcd + **HAProxy** |
| `witness-node` | `10.10.0.3` | mevcut prod sunucu, x86 | **etcd witness** (yalnızca quorum) |

> **Yüksek erişilebilirlik her iki katmanda:** Hem veritabanı (Patroni failover) hem de yük dengeleyici (iki bağımsız HAProxy) yedeklidir — tek nokta arıza (SPOF) yoktur. Uygulama çoklu-host bağlantı string'i ile iki HAProxy'yi de bilir; biri çökerse diğerine kendiliğinden geçer.

| Erişim Noktası | Adres | Açıklama |
|----------------|-------|----------|
| Yazma (write) | `10.10.0.1:5000` **+** `10.10.0.2:5000` | İki HAProxy → her zaman **primary**'ye |
| Okuma (read) | `10.10.0.1:5001` **+** `10.10.0.2:5001` | İki HAProxy → **replica**'ya |
| HAProxy Stats | `10.10.0.1:7000` / `10.10.0.2:7000` | İki izleme paneli |

**Uygulama bağlantı string'i (LB switch'li, yazma için):**
```
postgresql://<user>:<pass>@10.10.0.1:5000,10.10.0.2:5000/postgres?target_session_attrs=read-write
```
Bir HAProxy çökerse libpq otomatik diğerini dener; `target_session_attrs=read-write` her zaman primary'ye düşmeyi garantiler.

> Gerçek IP, WireGuard anahtarları ve veritabanı şifreleri sunucularda + `.secrets/` altında tutulur (git'e girmez). Repo'da yalnızca sırsız `.example` şablonları bulunur.

> **Not:** Tablodaki AWS, Contabo ve witness-node ibareleri; bizim bu projeyi laboratuvar ortamında ayağa kaldırırken kullandığımız özel test sunucularımızdır. Bu projeyi klonlayıp kendi ortamınızda denemek isterseniz, repo içindeki `.example` şablonlarını kullanarak **kendi belirleyeceğiniz herhangi 3 sunucu (veya sanal makine)** üzerinde birebir aynı mimariyi kurabilirsiniz. *(Şablon dosyalarındaki `node1`, `node2` ve `node3` isimleri sırasıyla tablodaki Contabo, AWS ve witness-node sunucularına karşılık gelmektedir.)*

🎥 **Video:** _(eklenecek)_

---

## Mimari Genel Bakış

```mermaid
flowchart TD
    subgraph WG [WireGuard Şifreli Mesh - 10.10.0.0/24]
        direction LR
        subgraph Node1 [Contabo Node - 10.10.0.1]
            H1[HAProxy]
            P1[(PostgreSQL 16 Primary)]
            E1(etcd)
            H1 -->|:5000 Write| P1
        end
        
        subgraph Node2 [AWS Node - 10.10.0.2]
            H2[HAProxy]
            P2[(PostgreSQL 16 Replica)]
            E2(etcd)
        end
        
        subgraph Node3 [Witness Node - 10.10.0.3]
            E3(etcd)
        end
        
        H1 -.->|:5001 Read| P2
        H2 -->|:5000 Write| P1
        H2 -.->|:5001 Read| P2
        P1 ====>|Streaming Replication| P2
        E1 <--> E2 <--> E3 <--> E1
    end
    APP[Uygulama<br/>multi-host conn] --> H1
    APP --> H2
    
    U(Uygulama) -->|Read/Write Trafiği| H
```

> [!NOTE]
> **Failover Mekanizması:** Primary (Node 1) çökerse, etcd quorum sayesinde kalan düğümler (Node 2 + Witness = 2/3 çoğunluk) saniyeler içinde yeni lideri belirler ve Patroni, Node 2'yi **OTOMATİK** olarak yeni Primary yapar. HAProxy trafiği kesintisiz olarak yeni lidere yönlendirir.

## 1. Projenin Amacı
Bu projenin temel amacı, tek bir veritabanı sunucusuna bağımlılığın (Single Point of Failure) yarattığı riski ortadan kaldıran, coğrafi olarak dağıtık ve **yüksek erişilebilir (HA)** bir PostgreSQL kümesi kurmaktır. Üç farklı sağlayıcıdaki (Contabo, AWS, mevcut prod sunucu) üç gerçek makine, şifreli bir özel ağ (WireGuard mesh) üzerinden birbirine bağlanır. Bu küme üzerinde **(1)** verinin gerçek zamanlı çoğaltılması (streaming replication), **(2)** primary sunucu çöktüğünde insan müdahalesi olmadan yeni bir liderin otomatik seçilmesi (Patroni + etcd failover) ve **(3)** okuma/yazma yükünün uygun düğümlere dağıtılması (HAProxy) somut önce-sonra kanıtlarıyla gösterilmiştir.

## 2. Kullanılan Platform ve Araçlar
- **DBMS:** PostgreSQL 16.14 (Docker container, her DB node'da).
- **HA Orkestrasyonu:** **Patroni 4.1.3** - PostgreSQL'i cluster durumuna göre yöneten, lider seçimi ve failover'ı otomatikleştiren şablon.
- **Dağıtık Konsensüs:** **etcd 3.5.21** - 3 düğümlü quorum; hangi node'un primary olduğuna çoğunluk kararıyla karar verir.
- **Yük Dengeleyici:** **HAProxy 2.9** - Patroni REST sağlık ucunu (`:8008`) sorgulayarak read/write trafiğini doğru düğüme yönlendirir.
- **Özel Ağ:** **WireGuard** - üç sunucu arasında şifreli mesh (`10.10.0.0/24`); hiçbir veritabanı portu public internete açılmaz.
- **Mimari Not:** Düğümler farklı mimaridedir (Contabo x86_64, AWS ARM64). Tüm Docker imajları çok-mimarili (multi-arch) olduğundan her node kendi mimarisinde native çalışır.

## 3. Kullanılan Veri Seti / Veritabanı
Replication ve failover sırasında veri bütünlüğünü kanıtlamak için basit bir `accounts` (banka hesabı) tablosu sentetik olarak üretilmiştir (`sql/00_init_schema.sql`). Bu projede kritik olan veri hacmi değil, **bir düğümde yazılan verinin diğerine anında çoğalması** ve **failover sonrası kaybolmamasıdır.**

## 4. Başlangıç Durumu
HA kurulmadan önceki sorun: **tek sunucu bağımlılığı.** Tek bir PostgreSQL düğümüne bağlı bir uygulamada, o düğüm çökerse hizmet tamamen kesilir; otomatik bir yedek devreye girmez ve veri kaybı riski doğar. Bu projenin tüm kurulumu, bu tek arıza noktasını (SPOF) ortadan kaldırmak için yapılmıştır.

## 5. Yapılan İşlemler
- **WireGuard Mesh:** Üç sunucu arasında `10.10.0.0/24` özel ağı kuruldu (full mesh); tüm küme trafiği (replication, etcd, Patroni) bu şifreli tünelden geçirildi. Mevcut OpenVPN'e dokunulmadı.
- **etcd 3-node Quorum:** Üç düğümde etcd kümesi kuruldu. witness-node yalnızca **witness** (etcd) olarak görev yapar; üzerinde PostgreSQL çalışmaz. Bu sayede bir DB düğümü çökse bile 2/3 çoğunluk korunur.
- **Streaming Replication:** Patroni + PostgreSQL 16 ile Contabo primary, AWS replica olarak yapılandırıldı; veri gerçek zamanlı çoğaltıldı.
- **Otomatik Failover:** Primary durdurulduğunda Patroni'nin etcd quorum'u üzerinden yeni lideri **otomatik** seçtiği doğrulandı.
- **Yük Dengeleme:** HAProxy ile `:5000` yazma trafiğini primary'ye, `:5001` okuma trafiğini replica'ya yönlendiren read/write split kuruldu.
- **Yük Dengeleyici Yedekliliği (LB-HA):** İki bağımsız HAProxy (Contabo + AWS) kuruldu. Uygulama çoklu-host bağlantı string'i ile ikisini de bilir; bir HAProxy çökerse libpq otomatik diğerine geçer (`target_session_attrs=read-write` ile her zaman primary'ye). Böylece yük dengeleyici katmanı da tek nokta arıza olmaktan çıkarıldı.

## 6. Kullanılan Komutlar ve Yapılandırma Dosyaları
Tüm yapılandırma ve betikler katman katman repo'da yer alır (gerçek sırlar hariç, `.example` olarak):
- `wireguard/wg0.conf.example` - mesh düğüm yapılandırması (PersistentKeepalive=25, AWS NAT için).
- `etcd/run-etcd.sh.example` - etcd düğüm başlatıcı; mesh IP'lerine bind, port public'e açılmaz.
- `patroni/Dockerfile` - `postgres:16` üzerine Patroni (`USER postgres` ile çalışır).
- `patroni/patroni.yml.example` - düğüm yapılandırması (etcd hosts, REST 8008, `shared_buffers 256MB`, `pg_hba 10.10.0.0/24`).
- `patroni/run-patroni.sh.example` - Patroni container başlatıcı.
- `haproxy/haproxy.cfg` - read/write split (Patroni REST `OPTIONS /primary` ve `/replica` health-check'leri).
- `sql/00_init_schema.sql`, `sql/01_replication_check.sql` - şema + replication doğrulama.
- `scripts/03_failover_test.sh`, `scripts/04_replication_status.sh` - failover ve durum betikleri.

## 7. Ekran Görüntüleri
Aşağıdaki yedi görüntü, projeyi alttan üste - şifreli ağdan başlayıp otomatik failover'a kadar - adım adım kanıtlar. Tüm görseller `screenshots/` dizinindedir.

---

### 7.1, Mimari / Node Diyagramı
Üç gerçek makinenin WireGuard mesh üzerinden nasıl bağlandığını ve hangi servisi çalıştırdığını özetler.

![Node diyagramı](screenshots/11_node_diagram.png)

---

### 7.2, WireGuard Mesh - Şifreli Özel Ağ (`wg show`)
Üç düğüm arasında karşılıklı **handshake** ve veri transferi. Tüm küme trafiği bu şifreli tünelden geçer; hiçbir veritabanı portu public internete açık değildir.

![WireGuard handshake](screenshots/01_wireguard_handshake.png)

---

### 7.3, etcd 3-Node Quorum - Sağlık Durumu
Üç düğümün de `is healthy` döndüğü konsensüs katmanı. Bu quorum sayesinde bir DB düğümü çökse bile **2/3 çoğunluk** korunur ve failover mümkün olur.

![etcd health](screenshots/03_etcd_health.png)

---

### 7.4, Streaming Replication - `patronictl list`
Kümenin canlı topolojisi: bir düğüm **Leader**, diğeri **Replica**, replikasyon gecikmesi (**Lag**) sıfır. Patroni tüm bu durumu etcd üzerinden yönetir.

![patronictl list](screenshots/04_patroni_list_initial.png)

---

### 7.5, Replication Kanıtı - Yazma Çoğalıyor, Replica Korumalı
Tek karede üç kanıt: **(1)** primary'ye yazılan kayıt başarıyla eklenir, **(2)** aynı veri replica'da anında görünür, **(3)** replica'ya yazma denemesi `cannot execute INSERT in a read-only transaction` ile reddedilir.

![Replication kanıtı](screenshots/05_replication_proof.png)

---

### 7.6, Otomatik Failover ⭐
**Önce / Sonra** karşılaştırması: mevcut primary durdurulduğunda, Patroni + etcd quorum **insan müdahalesi olmadan** kalan düğümü yeni Leader seçer. Timeline değerinin arttığına (ör. `2 → 3`) ve Leader'ın el değiştirdiğine dikkat edin.

![Failover öncesi/sonrası](screenshots/08_failover_after.png)

---

### 7.7, HAProxy - Read/Write Split ve Stats Paneli
Yük dengeleyici paneli: `postgres_write` backend'inde yalnızca **primary** düğümü UP (yeşil), `postgres_read` backend'inde yalnızca **replica** UP. Uygulama tek bir adrese bağlanır; doğru yönlendirmeyi HAProxy yapar.

![HAProxy stats](screenshots/09_haproxy_stats.png)

## 8. Elde Edilen Sonuçlar
Tüm bileşenler **üç gerçek makine üzerinde** uçtan uca doğrulanmıştır.

| Senaryo | Başlangıç (HA Yok) | Sonuç (HA Var) | Kanıt |
|---------|--------------------|----------------|-------|
| **Replication** | Tek kopya, yedek yok | Primary'de yazılan kayıt replica'da **anında** görünür | `accounts` tablosu replica'da Lag 0 |
| **Replica Koruması** | - | Replica'da yazma reddedilir | `cannot execute INSERT in a read-only transaction` |
| **Otomatik Failover** | Primary ölünce hizmet biter | AWS, quorum ile **otomatik** yeni Leader oldu (insan yok) | Timeline 1→2, `updated leader lock during promote` |
| **Yük Dengeleme** | Tek adres, tek node | `:5000` write→primary, `:5001` read→replica | `inet_server_addr()` farkı |
| **HAProxy Adaptasyonu** | - | Failover sonrası `:5000` yeni primary'ye **kendiliğinden** yöneldi | write `→10.10.0.2` (eski: `10.10.0.1`) |
| **Failback** | - | Eski primary geri gelince **replica** olarak katıldı | Timeline 2, Lag 0, veri senkron |
| **LB Switch** | Tek HAProxy = SPOF | Bir HAProxy durdurulunca uygulama diğerine **kendiliğinden** geçti, yazma kesilmedi | multi-host conn: Contabo LB down → AWS LB üzerinden primary'ye yazma OK |

**Failover anının özeti (gerçek test çıktısı):**

```text
ÖNCE:                                    SONRA (primary durduruldu):
+---------+-----------+---------+        +--------+-----------+--------+
| Member  | Host      | Role    |        | Member | Host      | Role   |
+---------+-----------+---------+        +--------+-----------+--------+
| contabo | 10.10.0.1 | Leader  |   -->  | aws    | 10.10.0.2 | Leader |  (TL 1→2, otomatik)
| aws     | 10.10.0.2 | Replica |        +--------+-----------+--------+
+---------+-----------+---------+
```

## 9. Karşılaşılan Problemler ve Çözümleri
1. **UFW, mesh trafiğini engelliyordu:** Contabo'da güvenlik duvarı (varsayılan `deny incoming`) WireGuard tüneli içindeki TCP trafiğini (etcd 2379/2380) düşürüyordu - ICMP ping geçiyor ama TCP filtreleniyordu. Bu, hem etcd peer hatalarının hem de Patroni'nin yanıltıcı hata mesajlarının asıl köküydü. **Çözüm:** `ufw allow in on wg0 from 10.10.0.0/24`.
2. **etcd cluster-version 3.0.0'da takılması:** Üç düğümün eşzamanlı `state=new` bootstrap'ında etcd küme sürümü 3.0'da kalıyor ve Patroni eski API'ye düşüyordu. **Çözüm:** Tek düğümle bootstrap → diğerlerini `learner` olarak ekle → `promote`.
3. **Patroni `initdb` root reddi:** PostgreSQL initdb root kullanıcısıyla çalışmaz. **Çözüm:** Dockerfile'a `USER postgres` + veri volume'üne uygun sahiplik (uid 999).
4. **WireGuard MTU uyumsuzluğu:** AWS düğümünün varsayılan jumbo MTU'su (8921) tünelde TCP paketlerini düşürüyordu. **Çözüm:** `wg0.conf`'a `MTU=1420` (kalıcı).
5. **Bayat etcd anahtarları:** Başarısız bootstrap denemelerinden kalan `/service/pg-cluster/initialize` anahtarı "waiting for leader" döngüsüne sokuyordu. **Çözüm:** `etcdctl del --prefix` + Patroni restart.

## 10. Sonuç ve Değerlendirme
Bu projede, tek sunucu bağımlılığının ortadan kaldırıldığı, gerçek anlamda **dağıtık ve kendi kendini iyileştiren** bir veritabanı mimarisi kuruldu. Primary sunucu çöktüğünde sistemin, üç düğümlü bir konsensüs (etcd quorum) sayesinde insan müdahalesi olmadan saniyeler içinde yeni bir lider seçtiği ve uygulamanın - bağlantı adresini hiç değiştirmeden - kesintisiz çalışmaya devam ettiği kanıtlandı. Özellikle "witness düğümü" yaklaşımının (üçüncü hafif bir düğümün yalnızca oy çokluğu için bulunması), iki düğümlü kurulumların failover yapamama sorununu nasıl çözdüğü pratikte gösterildi. Bu yapı, dersin **"Ağ Tabanlı Paralel Dağıtım Sistemleri"** başlığının çekirdeğini - gerçek makineler arası, gerçek ağ üzerinden dayanıklılık - birebir yansıtmaktadır.

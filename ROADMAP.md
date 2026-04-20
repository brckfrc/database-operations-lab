# BLM4522 — Ağ Tabanlı Paralel Dağıtım Sistemleri · Yol Haritası

> Bu doküman, ders kapsamındaki 5 projeyi iş bazında takip etmek için kullanılır.
> Her proje kendi bölümünde tanım, checklist ve teslim çıktılarıyla yer alır.
> Teknik detaylar ve geliştirme günlüğü için → [`docs/PROGRESS.md`](PROGRESS.md) 

---

## Genel Bakış

| # | Proje | DBMS | Dönem | Durum |
|---|-------|------|-------|-------|
| 1 | Performans Optimizasyonu ve İzleme | MSSQL | Vize | `[ ]` |
| 2 | Yedekleme ve Felaketten Kurtarma | PostgreSQL | Final | `[ ]` |
| 3 | Güvenlik ve Erişim Kontrolü | Oracle | Final | `[ ]` |
| 4 | Yük Dengeleme ve Dağıtık Yapılar | PostgreSQL | Final | `[ ]` |
| 5 | Veri Temizleme ve ETL Süreçleri | PostgreSQL | Vize | Kısmi *(ETL + rapor tamam; video ve `screenshots/` bekleniyor)* |

### Debian Sunucu İhtiyacı

| Proje | İhtiyaç | Sebep | Karar |
|-------|---------|-------|-------|
| 1. Performans | Düşük | Tek makinede rahat gösterilir | Lokal yeterli |
| 2. Backup/Recovery | Orta | Farklı restore senaryoları için faydalı olabilir | Önce lokal, gerekirse server |
| 3. Security | Düşük | Kullanıcı, rol, audit lokalde gösterilebilir | Lokal |
| 4. Load Balancing | **Yüksek** | Primary-standby, replication, failover ve ağ testleri | Server |
| 5. ETL | Düşük | Tek ortamda veri temizleme ve yükleme rahat yapılır | Lokal |

---

## Çalışma Sırası (Önerilen 5 Aşama)

| Aşama | Odak | Çıktı | Not |
|-------|------|-------|-----|
| 1 | Ortamı kur | Docker, repo, veri seti, klasör yapısı | Önce iskeleti kur |
| 2 | Vize projelerini başlat | Proje 5 (ETL) ve Proje 1 (Performans) | Hızlı sonuç ve çeşitlilik |
| 3 | Raporları eş zamanlı yaz | Her proje için taslak rapor | Raporu sona bırakma |
| 4 | Kanıtları topla | Ekran görüntüsü, ölçüm, log, SQL script | Önce-sonra kanıtları kritik |
| 5 | Videoları çek | En az 10 dk anlatım | Rapor tamamlanınca çek |

---

## Ortak Uygulama İskeleti (Her Proje İçin A→G Akışı)

Her projede aşağıdaki omurga takip edilir. Bu yapı rapor, video ve Git düzenini birebir eşleştirir.

| Adım | Açıklama |
|------|----------|
| **A. Problem Tanımı** | Bu projede neyi göstereceğin net yazılacak |
| **B. Ortam Kurulumu** | DBMS kurulumu, veritabanı, tablo yapısı, örnek veri seti, varsa kullanıcı rolleri |
| **C. Başlangıç Durumu** | Sistemi sorunlu / ham haliyle göster (yavaş sorgu, bozuk veri, yanlış yetki vb.) |
| **D. Uygulama** | İndeks ekleme, sorgu rewrite, backup, restore, rol tanımlama, veri temizleme vb. |
| **E. Sonuç / Kanıt** | Önce-sonra mantığıyla somut fark göster |
| **F. Raporlama** | Ekran görüntüleri, SQL kodları, açıklamalar ve sonuç bölümleriyle teknik rapor |
| **G. Video** | Proje amacı → Ortam → Ne test edildi → Ne düzeltildi → Sonuç |

---

## Ortak Altyapı

- `[ ]` Repo klasör yapısını oluştur (`project-1-performance/` … `project-5-etl/`)
- `[ ]` Her proje klasöründe `sql/`, `report/`, `screenshots/`, `README.md` iskeletini kur
- `[ ]` Docker ortamını hazırla (PostgreSQL, MSSQL, Oracle container'ları)
- `[ ]` Ortak rapor şablonunu oluştur (aşağıdaki 10 başlıklı format)
- `[ ]` `.gitignore` düzenle

---

## Vize Projeleri

### Proje 5 — Veri Temizleme ve ETL Süreçleri (PostgreSQL)

**Amaç:** Kirli veriyi temizlemek, standartlaştırmak ve hedef tabloya/şemaya yüklemek.

**Gösterilecek Problemler:** Eksik değer · yanlış format · mükerrer kayıt · tutarsız isimlendirme · bozuk tarih ve telefon alanları.

**Kanıt:** Ham veri ve temiz veri karşılaştırması, ETL adımları, quality report, dönüşüm kuralları, çakışan kayıtların `crm_contacts_duplicates` üzerinden izlenebilirliği.

#### Checklist

**A. Problem Tanımı**
- `[x]` İki farklı dış kaynaktan (`data/source/customers_seed.csv`, `data/source/leads_seed.csv` — Datablist kaynaklı ~100'er satır örnek) gelen verilerin, `etl_db` içinde ortak hedef tablolarda birleştirilmesi ve standartlaştırılması hedefini netleştir. *(Kanıt: `project-5-etl/README.md` §1, §3.)*

**B. Ortam Kurulumu**
- `[x]` PostgreSQL 16 `docker-compose.yml` hazırla ve başlat (`POSTGRES_DB=etl_db`). *(Kanıt: `project-5-etl/docker-compose.yml`.)*
- `[x]` `customers_seed.csv` ve `leads_seed.csv` dosyalarını `project-5-etl/data/source/` altında tut. *(Kanıt: repo dosyaları.)*
- `[x]` Veritabanında raw (`stg_customers`, `stg_leads`) ve hedef (`crm_contacts_clean`, `crm_contacts_rejected`, **`crm_contacts_duplicates`**) tablolarını yarat. *(Kanıt: `sql/00_init_schema.sql`.)*

**C. Başlangıç Durumu**
- `[x]` Her iki seed verisini de kendi staging tablolarına import et (`sql/01a_import_seed.sql`, `COPY`). *(Kanıt: script.)*
- `[x]` Kontrollü veri bozma katmanını çalıştır (`sql/01b_make_dirty.sql` — duplicate, null, cross-duplicate). *(Kanıt: script.)*
- `[x]` Verideki dağınıklığı ve uyumsuzluğu gözlemle. *(Kanıt: `README.md` §4.)*

**D. Uygulama**
- `[x]` `sql/02_etl_process.sql` ile iki tabloyu (`UNION ALL` + `TEMP TABLE` / `BEGIN…COMMIT`) birleştirip standartlaştıran ETL adımını yaz. *(Kanıt: script + `README.md` §5–§6, §9.)*
- `[x]` İki kaynak arasında çakışan (aynı e-posta) verileri tekilleştir (**Customer > Lead**); ezilen Lead kayıtlarını `crm_contacts_duplicates` tablosuna yaz. *(Kanıt: `README.md` §5, §8; `02_etl_process.sql`.)*
- `[x]` Kurtarılamayanları `crm_contacts_rejected` tablosuna aktar. *(Kanıt: `README.md` §5, §8.)*

**E. Sonuç / Kanıt**
- `[ ]` Ekran görüntüleri ile kaynak ayrımını ve temizleme farklarını topla (`project-5-etl/screenshots/` — henüz boş; README §7 planına göre video sonrası).
- `[x]` `sql/03_quality_report.sql` ile entegrasyon/kalite raporu çıkart (ör. 185 clean, 8 suppressed duplicate, 12 rejected — `README.md` §8 tablosu).

**F. Raporlama**
- `[x]` `project-5-etl/README.md` altında 10 başlıklı proje raporunu yaz.

**G. Video**
- `[ ]` ETL workflow'unu adım adım anlatan ≥ 10 dk video çek.

---

### Proje 1 — Veritabanı Performans Optimizasyonu ve İzleme (MSSQL)

**Amaç:** Bir e-ticaret sipariş veritabanı üzerinde yavaş sorguları tespit etmek, indeks ve sorgu iyileştirmesi uygulamak, DMV izleme araçlarıyla önce-sonra farkını somut metriklerle göstermek.

**Senaryo:** E-ticaret sipariş sistemi — `customers`, `products`, `orders`, `order_items` tabloları. Veri tamamen T-SQL ile sentetik üretilir (tekrar üretilebilir, repo'yu klonlayan herkes aynı ortamı kurabilir).

**Hedef Veri Hacmi:** customers ~100K · products ~20K · orders ~500K–1M · order_items ~1–2M.

**Gösterilecek Problemler:** Non-sargable filtre (`YEAR(order_date)`) · gereksiz `SELECT *` · indekssiz JOIN · gereksiz indeksin yazma maliyeti · yüksek logical reads / CPU time.

**Kanıt:** `SET STATISTICS IO, TIME ON` çıktıları · execution plan ekran görüntüleri (önce-sonra) · logical reads / elapsed time karşılaştırma tablosu · DMV sorgu çıktıları.

#### Checklist

**A. Problem Tanımı**
- `[ ]` E-ticaret sipariş senaryosunu tanımla: müşteriler sipariş verir, siparişler kalem bazında ürün içerir.
- `[ ]` Gösterilecek 4 kötü sorgu patternini belirle: (1) non-sargable date filter, (2) SELECT * + eksik covering index, (3) indekssiz JOIN, (4) gereksiz indeksin INSERT maliyeti.

**B. Ortam Kurulumu**
- `[x]` MSSQL container'ı kur — `docker-compose.yml` ile `azure-sql-edge` (Apple Silicon uyumlu). (Not: `2022-latest` x86 emulator kullanıldı)
- `[x]` `sql/00_schema.sql` ile veritabanı ve tablo yapısını oluştur (`customers`, `products`, `orders`, `order_items`).
- `[x]` `sql/01_seed_lookup.sql` ile küçük lookup tablosunu (`products` — ~20K) doldur.
- `[x]` `sql/02_seed_large_data.sql` ile büyük tabloları T-SQL loop / `INSERT … SELECT` ile sentetik üret (`customers` ~100K, `orders` ~500K–1M, `order_items` ~1–2M). Tarihler 5 yıla yayılacak, status/region/category alanları kontrollü dağılımda.

**C. Başlangıç Durumu**
- `[ ]` `sql/03_baseline_bad_queries.sql` ile 4 kötü sorguyu `SET STATISTICS IO, TIME ON` açık şekilde çalıştır ve çıktıları kaydet.
- `[ ]` Her kötü sorgu için execution plan ekran görüntüsü al (`screenshots/before_*.png`).

**D. Uygulama**
- `[ ]` `sql/04_indexes_and_tuning.sql` ile iyileştirmeleri uygula:
  - Sorgu 1: `WHERE YEAR(order_date) = 2024` → sargable range filtre + `order_date` indeksi.
  - Sorgu 2: `SELECT *` → dar kolon seçimi + covering index.
  - Sorgu 3: `orders ⟕ customers` indekssiz → JOIN kolonlarına uygun indeks.
  - Sorgu 4: Gereksiz indeks ekle → INSERT benchmark ile yazma maliyetini göster, sonra indeksi kaldır.
- `[ ]` `sql/05_after_measurement.sql` ile aynı sorguları optimizasyon sonrası tekrar çalıştır.
- `[ ]` `sql/06_monitoring_dmv.sql` ile DMV sorguları yaz: `sys.dm_exec_query_stats`, `sys.dm_db_index_usage_stats`, `sys.dm_db_missing_index_details`.

**E. Sonuç / Kanıt**
- `[ ]` Her sorgu için önce-sonra logical reads / CPU time / elapsed time karşılaştırma tablosu oluştur.
- `[ ]` Optimizasyon sonrası execution plan ekran görüntülerini al (`screenshots/after_*.png`).
- `[ ]` Kullanılan / kaldırılan indeks listesi ve kısa performans özeti.

**F. Raporlama**
- `[ ]` `project-1-performance/README.md` altında 10 başlıklı proje raporunu yaz.

**G. Video**
- `[ ]` Tüm akışı (ortam → baseline → optimizasyon → sonuç) adım adım anlatan ≥ 10 dk video çek.

#### Ekstra

- `[ ]` **Parameter sniffing senaryosu:** Aynı stored procedure'ü farklı parametrelerle çalıştırıp cached plan'ın kötü performansa neden olduğunu göster. `OPTION (RECOMPILE)` veya `OPTIMIZE FOR` ile düzelt. MSSQL'e özgü bir konu olduğu için projeyi diğerlerinden ayırır.

---

## Final Projeleri

### Proje 2 — Veritabanı Yedekleme ve Felaketten Kurtarma (PostgreSQL)

**Amaç:** Yedek alma, veri kaybı senaryosu oluşturma ve geri dönüş sürecini göstermek.

**Gösterilecek Problemler:** Yanlışlıkla veri silinmesi · bozulmuş tablo senaryosu · manuel backup sürecinin yetersizliği.

**Kanıt:** Backup dosyaları, restore sonrası veri bütünlüğü, senaryo bazlı kurtarma açıklaması, ekran görüntüleri.

#### Checklist

**A. Problem Tanımı**
- `[ ]` Proje amacını ve gösterilecek sorunları netleştir

**B. Ortam Kurulumu**
- `[ ]` PostgreSQL container kur
- `[ ]` Veritabanı oluştur ve örnek veri yükle

**C. Başlangıç Durumu**
- `[ ]` Manuel backup yetersizliğini göster

**D. Uygulama**
- `[ ]` Tam yedek (full backup) al — `pg_dump --format=custom`
- `[ ]` Zamanlanmış yedek mantığı kur
- `[ ]` Veri silme senaryosu oluştur
- `[ ]` Silinen veriyi geri getir (restore)
- `[ ]` Farklı restore denemeleri
- `[ ]` Point-in-time recovery mantığını açıkla / uygula

**E. Sonuç / Kanıt**
- `[ ]` Backup dosyaları ve restore sonrası bütünlük kanıtı
- `[ ]` Senaryo bazlı kurtarma ekran görüntüleri

**F. Raporlama**
- `[ ]` 10 başlıklı teknik rapor yaz

**G. Video**
- `[ ]` ≥ 10 dk video çek

---

### Proje 3 — Veritabanı Güvenliği ve Erişim Kontrolü (Oracle)

**Amaç:** Kullanıcı yetkileri, roller, hassas veri koruması ve aktivite izlemesini göstermek.

**Gösterilecek Problemler:** Aşırı yetkili kullanıcı · korumasız hassas veri alanları · audit kapalı ortam · rol ayrımının olmaması.

**Kanıt:** Yetki verilen ve engellenen kullanıcı örnekleri, audit çıktıları, güvenlik farkı gösteren önce-sonra tablosu.

#### Checklist

**A. Problem Tanımı**
- `[ ]` Proje amacını ve gösterilecek sorunları netleştir

**B. Ortam Kurulumu**
- `[ ]` Oracle container kur (`gvenzl/oracle-xe` — ~8GB+, erken pull)
- `[ ]` Veritabanı ve tablo yapısını oluştur
- `[ ]` Örnek veri yükle

**C. Başlangıç Durumu**
- `[ ]` Aşırı yetkili kullanıcı / korumasız veri / audit kapalı durumu göster

**D. Uygulama**
- `[ ]` Kullanıcı ve rol tanımları oluştur
- `[ ]` Tablo bazlı yetki verme / kısıtlama
- `[ ]` Hassas alanlarda koruma yaklaşımı (masking / encryption)
- `[ ]` Audit / aktivite izleme aç
- `[ ]` Güvenlik test senaryosu çalıştır

**E. Sonuç / Kanıt**
- `[ ]` Yetki verilen ve engellenen kullanıcı örnekleri
- `[ ]` Audit çıktıları
- `[ ]` Önce-sonra güvenlik farkı tablosu

**F. Raporlama**
- `[ ]` 10 başlıklı teknik rapor yaz

**G. Video**
- `[ ]` ≥ 10 dk video çek

---

### Proje 4 — Veritabanı Yük Dengeleme ve Dağıtık Yapılar (PostgreSQL)

**Amaç:** Replication, standby, failover ve temel yük dağıtımı mantığını gerçek bir senaryo halinde göstermek.

**Gösterilecek Problemler:** Tek sunucu bağımlılığı · failover eksikliği · okuma yükünün tek node üzerinde kalması.

**Kanıt:** Node diyagramı, replication çalıştığını gösteren veri kanıtı, failover testi, kısa uptime / davranış özeti.

> ⚠️ Bu proje diğerlerinden daha fazla ortam ve test gerektirir. Erken prototip çıkarmak önemlidir.

#### Checklist

**A. Problem Tanımı**
- `[ ]` Proje amacını ve gösterilecek sorunları netleştir

**B. Ortam Kurulumu**
- `[ ]` Debian sunucuyu hazırla (veya multi-container Docker Compose)
- `[ ]` En az 2 PostgreSQL node kur (primary + standby)

**C. Başlangıç Durumu**
- `[ ]` Tek sunucu bağımlılığını ve failover eksikliğini göster

**D. Uygulama**
- `[ ]` Streaming replication yapılandır
- `[ ]` Veri çoğaltmayı doğrula
- `[ ]` Failover testi (primary'yi kapat, standby promote)
- `[ ]` Read replica / temel load balancing mantığı

**E. Sonuç / Kanıt**
- `[ ]` Replication çalıştığını gösteren veri kanıtı
- `[ ]` Failover test sonuçları
- `[ ]` Node diyagramı
- `[ ]` Uptime / davranış özeti

**F. Raporlama**
- `[ ]` 10 başlıklı teknik rapor yaz

**G. Video**
- `[ ]` ≥ 10 dk video çek

---

## Rapor Şablonu (10 Başlık — Her Proje İçin)

Her proje raporunda aynı başlıkları kullanmak profesyonel görünüm sağlar ve video ile birebir eşleşir.

1. Projenin amacı
2. Kullanılan platform ve araçlar
3. Kullanılan veri seti / veritabanı
4. Başlangıç durumu
5. Yapılan işlemler
6. Kullanılan SQL komutları ve açıklamaları
7. Ekran görüntüleri
8. Elde edilen sonuçlar
9. Karşılaşılan problemler ve çözümleri
10. Sonuç ve değerlendirme

---

## Video Anlatım Şablonu (Her Proje İçin)

1. **Açılış:** Proje başlığı, amaç ve hangi veritabanının kullanıldığı
2. **Kurulum özeti:** Container, tablo, veri seti, kullanıcılar
3. **Başlangıç sorunu:** Ne bozuktu veya ne eksikti?
4. **Uygulanan çözüm adımları**
5. **Sonuç:** Önce-sonra karşılaştırması
6. **Kapanış:** Kısa değerlendirme ve öğrenilen teknik noktalar

> Video süresi: **en az 10 dakika**.

---

## Teslim Çıktıları (Her Proje İçin)

| Çıktı | Açıklama |
|-------|----------|
| **Rapor** | 10 başlıklı teknik rapor (yukarıdaki şablon) |
| **Video** | ≥ 10 dk anlatım (yukarıdaki şablon) |
| **SQL Scriptleri** | Numaralı, açıklamalı dosyalar halinde `sql/` altında |
| **Ekran Görüntüleri** | Başlıklarla isimlendirilmiş, `screenshots/` altında |
| **README** | Proje özeti + video linki |
| **Git Geçmişi** | Her anlamlı adım için küçük commit |

---

## Riskler ve Hatırlatmalar

- Proje 4 erken prototip ister — ortam kurulumunu sona bırakma.
- Oracle container imageları büyük (~8GB+). Erken pull et.
- MSSQL Apple Silicon'da `azure-sql-edge` image gerektirir.
- Rapor ve Git işini sona bırakmak en büyük hata — süreç boyunca küçük commitlerle ilerle.
- **Her projede önce-sonra farkını somut kanıtla göstermek en kritik unsur.**

---

## Son Karar Özeti

- **Seçilen projeler:** 1, 2, 3, 4, 5
- **DBMS dağılımı:** P1 → MSSQL, P2 → PostgreSQL, P3 → Oracle, P4 → PostgreSQL, P5 → PostgreSQL
- **Vize:** Proje 5 (ETL) + Proje 1 (Performans)
- **Final:** Proje 2 (Backup) + Proje 3 (Güvenlik) + Proje 4 (Load Balancing)
- **Debian sunucu:** Özellikle Proje 4 için hazır tutulacak; diğerleri lokal

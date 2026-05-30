# Proje 3: Oracle Veritabanı Güvenliği ve Erişim Kontrolü Planı

Bu plan, **Database Operations Lab** kapsamındaki `project-3-security` projesinin adım adım nasıl uygulanacağını tanımlar.

## Hedef

Oracle üzerinde **kullanıcı/rol bazlı erişim kontrolü**, **hassas veri şifreleme (DBMS_CRYPTO)**, **veri maskeleme**, **SQL injection savunması** ve **denetim (audit) loglaması** uygulayarak; güvensiz bir başlangıç durumundan güvenli bir hedef duruma geçişi önce-sonra kanıtlarıyla göstermek.

## Senaryo Seçimi

Projede **"Hastane / Sağlık Kayıtları" (Hospital Records)** veritabanı kullanılacak. Sağlık verisi doğal olarak hassastır (TC kimlik no, tanı, kan grubu, telefon); bu da şifreleme, maskeleme ve erişim kısıtlama demolarını gerçekçi ve kritik kılar. P2 (banka) ve P5 (ETL müşteri) ile tema çakışması olmaması da bilinçli bir tercihtir.

### Veritabanı Şeması

| Tablo | Açıklama | Hassas Alanlar | Hedef Satır |
|-------|----------|----------------|-------------|
| `patients` | Hastalar | `national_id` (TC), `phone`, `address` | ~1.000 |
| `doctors` | Doktorlar | — | ~50 |
| `medical_records` | Tıbbi kayıtlar | `diagnosis`, `treatment` | ~5.000 |
| `appointments` | Randevular | `notes` | ~5.000 |

Veri tamamen SQL ile sentetik üretilecek (tekrar üretilebilir). Güvenlik projesi olduğu için veri hacmi küçük tutulur; önemli olan satır sayısı değil, hassas alanların korunmasıdır.

---

## ROADMAP A→G ile Eşleme

| ROADMAP Adımı | Bu Plandaki Karşılığı |
|---------------|-----------------------|
| A. Problem Tanımı | "Hedef" + "Senaryo Seçimi" bölümleri |
| B. Ortam Kurulumu | Docker (Oracle 23ai Free) + şema + örnek veri |
| C. Başlangıç Durumu | "Güvensiz Başlangıç" bölümü (aşırı yetkili kullanıcı, açık veri, audit kapalı, zafiyetli kod) |
| D. Uygulama | Bölüm 1 (erişim) + Bölüm 2 (şifreleme + maskeleme) + Bölüm 3 (SQL injection) + Bölüm 4 (audit) |
| E. Sonuç / Kanıt | Önce-sonra güvenlik tablosu + yetkili/engellenen kullanıcı örnekleri + audit çıktıları + ekran görüntüleri |
| F. Raporlama | `README.md` — 10 başlıklı teknik rapor (P1/P5 ile aynı konvansiyon) |
| G. Video | ≥ 10 dk video akışı (en alt bölümde planlandı) |

---

## Mimari Genel Bakış

```
┌──────────────────────────────────────────────────────────┐
│                  Docker Compose Stack                     │
├──────────────────────────────────────────────────────────┤
│  Oracle Database 23ai Free  (gvenzl/oracle-free:23-slim)  │
│   └── PDB: FREEPDB1                                       │
│         ├── Şema: hospital_app (tablolar + veri)         │
│         │                                                │
│         ├── Roller:  doctor_role / nurse_role /          │
│         │            receptionist_role / auditor_role    │
│         ├── Kullanıcılar: dr_house, nurse_joy,          │
│         │                 reception1, auditor1           │
│         │                                                │
│         ├── DBMS_CRYPTO ──► national_id şifreli kolon    │
│         ├── Masked VIEW ──► düşük yetkiliye XXX-XX-1234  │
│         └── Unified Audit ─► hassas tablo erişim logu    │
│                                                          │
│  injection_demo.py (host) ──► zafiyetli vs güvenli sorgu │
└──────────────────────────────────────────────────────────┘
```

> **Oracle notu:** Oracle 23ai, *pluggable database* (PDB) mimarisi kullanır. Uygulama şeması ve yerel kullanıcılar `FREEPDB1` PDB'si içinde oluşturulur (CDB seviyesindeki `C##` ortak kullanıcıları değil). Tüm bağlantılar `localhost:1521/FREEPDB1` servis adıyla yapılır.
>
> **Image kararı:** Makine Apple Silicon (arm64) olduğu için repo dokümanlarında yazan `gvenzl/oracle-xe` (21c, yalnızca x86) yerine **`gvenzl/oracle-free:23-slim`** (Oracle Database 23ai Free) kullanılır — daha güncel ve arm64'te native çalışır. Planda kullanılan tüm özellikler (DBMS_CRYPTO, Unified Auditing, roller) bu sürümde desteklidir.

---

## Ortam Kurulumu (B)

### Image Seçimi

`gvenzl/oracle-free:23-slim` (Oracle Database 23ai Free) kullanılacak — arm64'te native, ücretsiz, init-script desteği var.

```yaml
# docker-compose.yml (özet)
services:
  oracle:
    image: gvenzl/oracle-free:23-slim
    environment:
      ORACLE_PASSWORD: <admin_sifre>      # SYS / SYSTEM şifresi
      APP_USER: hospital_app
      APP_USER_PASSWORD: <app_sifre>
    ports:
      - "1521:1521"
    volumes:
      - oracle-data:/opt/oracle/oradata
```

> **Init script yerine manuel çalıştırma:** Güvenlik projesi olduğu için scriptler **farklı kullanıcılarla** (admin, hospital_app, dr_house, reception1 …) çalıştırılmak zorunda — tek bağlantılı otomatik init dizini bunu karşılayamaz. Bu yüzden scriptler `docker exec` + `sqlplus` ile sırayla, doğru kullanıcıyla elle çalıştırılır. Her SQL dosyasının başında hangi kullanıcıyla çalışacağı belirtilir. Bu yaklaşım video akışıyla da (adım adım gösterim) birebir uyumludur.

### DBMS_CRYPTO Erişimi

Şifreleme için `hospital_app` şemasına `EXECUTE ON SYS.DBMS_CRYPTO` yetkisi verilmesi gerekir (admin kullanıcı tarafından). Bu, `00_admin_setup.sql` içinde yapılacak.

---

## Güvensiz Başlangıç Durumu (C)

Projenin "önce" hali bilinçli olarak güvensiz kurulur; her zafiyet sonradan kapatılarak önce-sonra farkı gösterilir.

| # | Güvensiz Durum | Sonradan Çözülecek Bölüm |
|---|----------------|--------------------------|
| 1 | Tek, aşırı yetkili kullanıcı herkes tarafından kullanılıyor (rol ayrımı yok) | Bölüm 1 |
| 2 | `national_id` (TC) ve `diagnosis` düz metin — herkes okuyabiliyor | Bölüm 2 |
| 3 | Düşük yetkili kullanıcı bile tüm hassas alanları görebiliyor | Bölüm 2 (maskeleme) |
| 4 | Uygulama sorgusu string birleştirmeyle yazılmış (SQL injection'a açık) | Bölüm 3 |
| 5 | Audit kapalı — kim neye erişti hiç bilinmiyor | Bölüm 4 |

`sql/02_insecure_baseline.sql` bu durumu gösterir; ekran görüntüleriyle "before" kanıtı alınır.

---

## Bölüm 1: Erişim Yönetimi — Kullanıcı, Rol, Yetki (D)

### Roller ve En Az Yetki Prensibi

| Rol | Yetki Kapsamı |
|-----|---------------|
| `doctor_role` | Hasta + tıbbi kayıt okuma/yazma (tedavi için tam erişim) |
| `nurse_role` | Hasta okuma + randevu yönetimi; tanıya sınırlı erişim |
| `receptionist_role` | Sadece randevu + iletişim; hassas tıbbi alan **yok**, TC maskeli |
| `auditor_role` | Sadece audit loglarını okuma; hasta verisine erişim **yok** |

### Kullanıcılar

| Kullanıcı | Rol |
|-----------|-----|
| `dr_house` | doctor_role |
| `nurse_joy` | nurse_role |
| `reception1` | receptionist_role |
| `auditor1` | auditor_role |

### Yapılacaklar (`sql/03_users_and_roles.sql`)

1. Rolleri oluştur (`CREATE ROLE ...`).
2. Her role **tablo bazında** yetki ver (`GRANT SELECT ON ...`, `GRANT INSERT/UPDATE ON ...`).
3. Kullanıcıları oluştur, rolleri ata.
4. Resepsiyonist'in tıbbi kayda erişiminin reddedildiğini test et (`ORA-00942 / yetki hatası`).

> **Oracle önemli notu:** Oracle, **kolon bazlı SELECT grant'i desteklemez** (kolon bazlı yetki yalnızca INSERT/UPDATE/REFERENCES için geçerlidir). Belirli kolonları (TC, tanı) bir rolden gizlemek için **VIEW** kullanılır — düşük yetkili rol yalnızca gerekli kolonları içeren view'e erişir, ana tabloya erişimi yoktur. Bu, Bölüm 2'deki maskeleme view'i ile birleşir.

---

## Bölüm 2: Veri Şifreleme + Maskeleme (D)

### 2.1 Şifreleme — DBMS_CRYPTO (Kolon Bazlı)

Hocanın PDF'te belirttiği TDE, Oracle Enterprise Edition gerektirdiği ve XE'de çalışmadığı için; aynı amaca hizmet eden ve XE'de kesin çalışan **DBMS_CRYPTO ile kolon bazlı şifreleme** kullanılacak. Raporda bu tercih ve TDE farkı açıkça belirtilecek.

**Yapılacaklar (`sql/04_encryption_dbms_crypto.sql`):**
1. `national_id` için şifreli bir kolon (`national_id_enc RAW`) ekle.
2. `DBMS_CRYPTO.ENCRYPT` ile mevcut TC'leri şifrele (AES-256, CBC, PKCS5 padding).
3. Şifre çözmeyi yalnızca yetkili rolün çağırabildiği bir fonksiyon (`fn_decrypt_nid`) yaz.
4. Şifreli kolona doğrudan `SELECT` atıldığında **anlamsız RAW veri** göründüğünü kanıtla.
5. Düz metin kolonu kaldır (artık sadece şifreli sürüm tutulur).

> **Not (anahtar yönetimi):** Demo amacıyla şifreleme anahtarı fonksiyon içinde sabit tutulur. Gerçek sistemlerde anahtar **Oracle Wallet / keystore** içinde saklanır — bu fark raporda belirtilecek.
> **Not (DBMS_CRYPTO erişimi):** `EXECUTE ON SYS.DBMS_CRYPTO` yetkisi admin tarafından `hospital_app`'e verilir (`00_admin_setup.sql`).

### 2.2 Maskeleme — Düşük Yetkili Kullanıcı İçin

Şifreleme verinin diskte korunmasını sağlar; maskeleme ise **yetkiye göre farklı görünüm** sağlar. Aynı zamanda Oracle'da kolon-bazlı okuma kısıtlamasının da yolu budur (bkz. Bölüm 1 notu).

**Yapılacaklar (`sql/05_masking_views.sql`):**
1. `v_patients_masked` view'i oluştur: TC `XXX-XX-1234` formatında, telefon kısmen gizli, hassas tıbbi alanlar hariç.
2. Resepsiyonist role yalnızca bu maskeli view'e erişim ver; ana tabloya erişimi kapat.
3. Aynı sorgunun:
   - `dr_house` (doctor_role) → tam TC,
   - `reception1` (receptionist_role) → maskeli TC
   gösterdiğini yan yana kanıtla.

> **Şifreleme vs Maskeleme farkı** raporda net açıklanacak: şifreleme = diskte/yedekte korunan veri; maskeleme = ekranda yetkiye göre kısıtlı görünüm.

---

## Bölüm 3: SQL Injection Testleri (D)

### Yöntem: Küçük Python Scripti

Gerçek dünyaya en yakın gösterim için küçük bir Python scripti (`python-oracledb` kütüphanesi) kullanılacak: önce zafiyetli sürüm, sonra güvenli sürüm.

**Yapılacaklar (`app/injection_demo.py`):**

1. **Zafiyetli sorgu** — kullanıcı girdisi doğrudan string'e gömülür:
   ```python
   # KÖTÜ — string birleştirme
   query = f"SELECT * FROM patients WHERE national_id = '{user_input}'"
   ```
   Girdi olarak `' OR '1'='1` verilince **tüm hastaların** sızdığı gösterilir.

2. **Güvenli sürüm** — bind variable (parametreli sorgu):
   ```python
   # İYİ — bind variable
   cur.execute("SELECT * FROM patients WHERE national_id = :nid", nid=user_input)
   ```
   Aynı kötü girdinin artık **hiçbir kayıt döndürmediği** gösterilir.

3. Önce-sonra çıktısı terminal ekran görüntüsüyle kanıtlanır.

> **Ek savunma:** Uygulamanın bağlandığı DB kullanıcısının en az yetkiyle (sadece gerekli tablo/kolon) çalıştığı, böylece injection başarılı olsa bile hasarın sınırlı kaldığı vurgulanacak (Bölüm 1 ile bağ).

---

## Bölüm 4: Denetim / Audit Logları (D)

### Yöntem: Unified Auditing (Oracle 12c+ Modern Yaklaşım)

Eski `AUDIT` ifadeleri yerine modern **Unified Auditing** kullanılacak.

**Yapılacaklar (`sql/06_unified_audit.sql`, SYSTEM olarak):**
1. Hassas tablolara erişimi izleyen audit politikası oluştur:
   ```sql
   CREATE AUDIT POLICY pol_patient_access
     ACTIONS SELECT, UPDATE, DELETE ON hospital_app.patients;
   AUDIT POLICY pol_patient_access;
   ```
2. Başarısız giriş / yetkisiz erişim denemelerini de izle.
3. Farklı kullanıcılarla erişim üret (dr_house okur, reception1 reddedilir).
4. **Audit trail'i flush et** (`DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL`) — Unified Audit kayıtları varsayılan olarak kuyruğa yazılır; flush etmeden hemen sorgulanınca görünmeyebilir.
5. `UNIFIED_AUDIT_TRAIL` görünümünden "kim, ne zaman, neye, hangi sonuçla eriştiğini" sorgula ve göster.

> **Not:** Audit politikası oluşturma/etkinleştirme `AUDIT_ADMIN` rolü veya `SYSTEM` gerektirir; bu yüzden bu script admin kullanıcısıyla çalıştırılır.

> `auditor1` kullanıcısı yalnızca audit trail'i okuyabilir; hasta verisine erişemez — görevler ayrılığı (separation of duties) prensibi gösterilir.

---

## Güvenlik Test Senaryoları (E)

`sql/07_security_tests.sql` (çeşitli kullanıcılarla) — önce-sonra kanıt üretir:

| Test | Beklenen Sonuç |
|------|----------------|
| `reception1` → `medical_records` SELECT | **Reddedilir** (yetki yok) |
| `reception1` → `v_patients_masked` SELECT | TC **maskeli** görünür |
| `dr_house` → `patients` SELECT | TC **şifresi çözülmüş** görünür |
| Şifreli kolona ham SELECT | **Anlamsız RAW** veri |
| `auditor1` → `patients` SELECT | **Reddedilir** |
| `auditor1` → `UNIFIED_AUDIT_TRAIL` | Tüm erişim logu görünür |
| SQL injection (zafiyetli) | Tüm kayıtlar sızar |
| SQL injection (güvenli) | 0 kayıt |

---

## Dosya ve Klasör Yapısı

> Her dosyanın başında **hangi kullanıcıyla** çalıştırılacağı belirtilir (admin = SYSTEM, app = hospital_app, ya da ilgili son kullanıcı).

```
project-3-security/
├── docker-compose.yml
├── sql/
│   ├── 00_admin_setup.sql          # [admin]  hospital_app'e EXECUTE ON DBMS_CRYPTO + CREATE VIEW vb. grant
│   ├── 01_init_schema.sql          # [app]    Şema (patients, doctors, medical_records, appointments) + sentetik veri
│   ├── 02_insecure_baseline.sql    # [app]    Güvensiz başlangıç: düz metin TC, kısıtsız erişim (before kanıtı)
│   ├── 03_users_and_roles.sql      # [admin]  Roller + kullanıcılar + tablo bazlı yetkilendirme
│   ├── 04_encryption_dbms_crypto.sql  # [app] national_id AES-256 şifreleme + decrypt fonksiyonu
│   ├── 05_masking_views.sql        # [app]    Maskeli view + resepsiyonist erişimi (kolon kısıtlama)
│   ├── 06_unified_audit.sql        # [admin]      Unified Auditing politikası
│   ├── 07_test_reception.sql       # [reception1] RED + maskeli view erişimi
│   ├── 08_test_doctor.sql          # [dr_house]   tam erişim + TC şifre çözme
│   ├── 09_test_auditor.sql         # [auditor1]   hasta verisine RED + audit trail okuma
│   └── 10_audit_review.sql         # [admin]      audit trail incelemesi
├── scripts/
│   ├── run_sql.sh                  # docker exec + sqlplus yardımcı çalıştırıcı (kullanıcı parametreli)
│   └── run_security_tests.sh       # 07-10 testlerini kullanıcı başına AYRI bağlantıyla sırayla çalıştırır
├── app/
│   ├── injection_demo.py           # Zafiyetli vs güvenli (bind variable) sorgu demosu
│   └── requirements.txt            # python-oracledb
├── screenshots/
└── README.md                       # 10 başlıklı teknik rapor + proje özeti + video linki
```

> Not: 10 başlıklı teknik rapor doğrudan `README.md` içindedir (P1/P5 ile aynı konvansiyon, AGENTS.md'ye uygun). Ayrı `report/` klasörü kullanılmaz.

> Not: Kolon bazlı okuma kısıtlaması Oracle'da VIEW ile yapıldığından ayrı bir `column_privileges.sql` dosyası yoktur; bu iş `05_masking_views.sql` içindedir.

---

## Çektirilecek Ekran Görüntüleri (`screenshots/`)

| Dosya | İçerik |
|-------|--------|
| `01_baseline_plaintext_nid.png` | Başlangıçta TC'nin düz metin, herkesçe okunur olması |
| `02_roles_created.png` | Roller ve kullanıcıların oluşturulması |
| `03_reception_denied_medical.png` | Resepsiyonistin tıbbi kayda erişiminin reddi (yetki hatası) |
| `04_encrypted_column_raw.png` | Şifreli `national_id_enc` kolonunun anlamsız RAW görünümü |
| `05_doctor_decrypted_nid.png` | Doktorun şifresi çözülmüş tam TC görmesi |
| `06_reception_masked_nid.png` | Resepsiyonistin maskeli TC (XXX-XX-1234) görmesi |
| `07_injection_vulnerable.png` | Zafiyetli sorguda `' OR '1'='1` ile tüm kayıtların sızması |
| `08_injection_safe.png` | Bind variable ile aynı girdinin 0 kayıt döndürmesi |
| `09_audit_policy_enabled.png` | Unified Audit politikasının aktif edilmesi |
| `10_audit_trail_output.png` | `UNIFIED_AUDIT_TRAIL` — kim/ne zaman/neye eriştiği |
| `11_before_after_security.png` | Önce-sonra güvenlik karşılaştırma tablosu |

---

## Doğrulama ve Video Akışı Planı

Video en az 10 dk olacak. Önerilen akış:

### Giriş (~1 dk)
- Projenin amacını, senaryoyu (hastane DB) ve güvenlik konularını tanıt.

### Başlangıç: Güvensiz Durum (~1.5 dk)
- Aşırı yetkili tek kullanıcı, düz metin TC, audit kapalı, zafiyetli sorgu gösterilir (before kanıtı).

### Bölüm 1: Erişim Yönetimi (~2 dk)
1. Roller ve kullanıcılar oluşturulur.
2. Kolon bazlı yetkiler verilir.
3. Resepsiyonistin tıbbi kayda erişiminin reddedildiği gösterilir.

### Bölüm 2: Şifreleme + Maskeleme (~2.5 dk)
4. `national_id` DBMS_CRYPTO ile şifrelenir; ham SELECT'te anlamsız veri gösterilir.
5. Doktor şifre çözülmüş TC'yi, resepsiyonist maskeli TC'yi görür (yan yana).
6. Şifreleme vs maskeleme farkı kısaca açıklanır.

### Bölüm 3: SQL Injection (~1.5 dk)
7. Python scripti — zafiyetli sorguya `' OR '1'='1` → tüm kayıtlar sızar.
8. Bind variable sürümü → aynı girdi 0 kayıt döndürür.

### Bölüm 4: Audit (~1.5 dk)
9. Unified Audit politikası aktif edilir.
10. Farklı kullanıcılarla erişim üretilir.
11. `UNIFIED_AUDIT_TRAIL`'den erişim logu gösterilir; auditor'ın görev ayrılığı vurgulanır.

### Kapanış (~1 dk)
- Önce-sonra güvenlik tablosu; her zafiyetin nasıl kapatıldığının özeti.

---

## Tamamlama Kontrolü

Proje "tamamlandı" denmeden önce:

- [ ] Tüm SQL scriptleri Oracle XE'de hatasız çalışıyor (PDB `XEPDB1` üzerinde).
- [ ] `app/injection_demo.py` hem zafiyetli hem güvenli çıktıyı üretiyor.
- [ ] `docs/REVIEW_GUIDE.md` audit'ini tüm SQL scriptleri ve config için çalıştır.
- [ ] Bulguları `project-3-security/OPTIMIZATIONS.md` dosyasına yaz (otomatik düzeltme yok, yalnızca işaret et).
- [ ] `ROADMAP.md` checklist'ini `[x]` ile işaretle — yalnızca karşılık gelen kanıt (screenshot / script çıktısı) mevcutsa.
- [ ] `docs/PROGRESS.md`'e A→G adımları için log gir.

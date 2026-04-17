# Project 5 — Veri Temizleme ve ETL Süreçleri Tasarımı

## 1. Projenin Amacı
Bu projede, aynı "Müşteri (CRM)" eksenindeki iki farklı dış veri kaynağından (`Customers` ve `Leads`) gelen verilerin, ortak bir veri merkezinde başarıyla entegre edilmesi hedeflenmiştir. ETL pipeline kullanılarak, farklı kaynakların şemaları ortak bir hedefe birleştirilmiş (`UNION ALL`), veri standardizasyonu sağlanmış ve özellikle **aynı kaydın her iki platformda bulunması durumunda (Lead to Customer conflict)** kurumsal önceliklere (Customer > Lead) göre tekilleştirme yapılmıştır. Hatalı ve eksik veriler reddedilmiş ve karantinaya alınmıştır.

## 2. Kullanılan Platform ve Araçlar
- Veritabanı Motoru: PostgreSQL 16 (Docker)
- Geliştirme Ortamı: Docker Compose, SQL pg_catalog, pg_isready

## 3. Kullanılan Veri Seti / Veritabanı
Daha önceden tanımlanmış bir dış kaynak olan *Datablist* platformundan alınan:
- Toplam 100 satırlık `customers-100.csv`
- Toplam 100 satırlık `leads-100.csv` 
örnek veri seti temel alınarak kullanılmıştır. Senaryoyu canlandırmak adına bu veriler bir "kirletme ve çakışma (dirty)" katmanından geçirilerek veri kalitesi bozulmuş, kasıtlı olarak kaynaklar arası çakışma (Duplicate Mail) üretilmiştir. ETL pipeline'ı `etl_db` veritabanında koşturulmuştur.

## 4. Başlangıç Durumu
Başlangıç durumunda `stg_customers` ve `stg_leads` tablolarında toplam `104+101=205` civarı raw (kirli) veri ve bazı tamamen anlamsız test değerleri ("Test", "Invalid") bulunuyordu. Verilerde e-posta standardı yoktu (`@` eksiklikleri), yazım standartları karışıktı ve iki tabloda da tamamen aynı e-postaya (`email`) sahip kişiler yer almaktaydı.

## 5. Yapılan İşlemler
- `stg_customers` ve `stg_leads` tablolarından veriler `TEMP TABLE` üzerine `UNION ALL` ile standart bir formata (`first_name`, `email`, vs.) oturtularak aktarıldı.
- Ekstra `source_priority` adlı öncelik kolonu sisteme tanıtıldı (`Customer`=1, `Lead`=2).
- Veri Doğrulama (Validation) aşamasında sorunlu mail formatı ve test hesapları elenerek `crm_contacts_rejected` karantina tablosuna aktarıldı.
- Temiz veriler üzerinden `ROW_NUMBER() OVER (PARTITION BY email ORDER BY source_priority ASC)` uygulanarak Tekilleştirme (Deduplication) ve Önceliklendirme başarı ile işletildi.
- Temiz hedefe ulaşan benzersiz müşteriler `crm_contacts_clean` tablosuna aktarılırken, "Lead" kaynağından gelen ancak "Customer" statüsü yüzünden sisteme tekrar girmesi engellenen **ezilen kayıtlar** (suppressed data), sonradan incelenebilmesi için `crm_contacts_duplicates` tablosuna gönderildi.

## 6. Kullanılan SQL Komutları ve Açıklamaları
Projede modüler olarak tasarlanmış SQL scriptleri yer almaktadır:
- `00_init_schema.sql`: İki raw tablo (`stg_customers`, `stg_leads`) ve üç operasyonel tablo (`clean`, `duplicates`, `rejected`) oluşturuldu.
- `01a_import_seed.sql`: `COPY` komutlarıyla dış kaynak (CSV) verisi `stg` tablolarına aktarıldı.
- `01b_make_dirty.sql`: Sahte ve kirli verileri oluşturma katmanı.
- `02_etl_process.sql`: Yukarıda tanımlanan, tüm CTE ve TEMP işlemleri ile veri temizleme ve yükleme döngüsü scripti. Regex araması için `~` operatörü, büyük/küçük harf için `INITCAP` kullanıldı.
- `03_quality_report.sql`: Sistemin sonuç çıktısını getiren ve Data Quality tablosu çizen rapor scripti.

## 7. Ekran Görüntüleri
*(Proje dizinindeki `/screenshots/` klasörüne video anlatımı sonrasında yerleştirilecektir.)*
- Temizlik sonrası `crm_contacts_clean` tablosu.
- `crm_contacts_duplicates` çakışma log paneli.
- Kalite Raporu Konsol Çıktısı.
- `crm_contacts_rejected` hata sebepleri paneli.

## 8. Elde Edilen Sonuçlar
Aşağıdaki terminal raporunda da görüleceği üzere; Toplamda gelen **205 satır** üzerinden, ETL motoru **185** tertemiz ve tekil kişiyi asıl hedefine iletti. Toplam **8** çakışan ve duplicate eden kayıt karantinadan farklı olarak "Duplicate Log" tablosuna ayrıştırıldı (`Lead lost to Customer`). Formatı yanlış olan veya tamamen sahte veriler (**12 kayıt**) "Quarantine" yani Reddilenler noktasına düşerek başarılı bir şekilde yalıtılmış oldu.

```text
                        metric                        | count 
------------------------------------------------------+-------
 1. [Staging] Total Raw Customers                     |   104
 1. [Staging] Total Raw Leads                         |   101
 2. [Target] Successfully Loaded (Clean & Unique)     |   185
 3. [Suppressed] Deduplicated (Lead lost to Customer) |     8
 4. [Quarantine] Rejected for Bad Data Quality        |    12
```

## 9. Karşılaşılan Problemler ve Çözümleri
**Problem**: PostgreSQL `WITH` kullanarak birden fazla hedef (Clean, Rejected, Duplicate gibi) tabloya tek sorgu yapısı içinden veri eklenmesine izin vermiyordu (CTE limitleri).
**Çözüm**: Raw ve Temiz birleştirilmiş veriyi barındıran yapılar RAM üzerinde çalışan `CREATE TEMP TABLE` mantığı ile geçici tablolara alınarak bu kuralın etrafından dolaşıldı. Tek bir `BEGIN ... COMMIT` bloğunda çalıştıktan sonra geçici tablolar silindi (`DROP TABLE`).

## 10. Sonuç ve Değerlendirme
Veritabanı optimizasyonu ve yönetimi sürecinde, özellikle ETL gibi dağınık verilerin entegrasyonu aşamalarında sadece "hatalı olanı silme" refleksinin yeterli olmadığı net olarak test edilmiş oldu. Farklı veri hedeflerindeki veri mantığında "Veri Güvenilirliği"ni (Customer vs Lead) referans almak, gerçek dünyadaki veri iş gücünün (data engineering) çekirdeğini göstermektedir.

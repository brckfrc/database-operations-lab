# Proje 1: Veritabanı Performans Optimizasyonu ve İzleme

## 1. Projenin Amacı
Bu projenin temel amacı, büyük veri kümeleri (milyonlarca satır) üzerinde çalışan bir ilişkisel veritabanında, kötü tasarlanmış mimarinin ve yanlış yazılmış SQL sorgularının sisteme ne kadar büyük bir yük bindirdiğini ("Logical Reads", "CPU Time", "Table Scan" gibi metriklerle) kanıtlamaktır. Ardından, indeksleme stratejileri (Non-Clustered, Covering Index, Foreign Key Index) ve sorgu iyileştirmeleri (Sargable filtreleme) uygulayarak bu yükün nasıl devasa oranlarda düşürüldüğü (Optimizasyon) gösterilmiştir.

## 2. Kullanılan Platform ve Araçlar
- **DBMS:** Microsoft SQL Server (Docker Container üzerinden `mcr.microsoft.com/mssql/server:2022-latest` imajı ile çalıştırıldı).
- **Yönetim Araçları:** `sqlcmd` (Terminal CLI) ve DBeaver Community Edition (Execution Plan Görselleştirme).
- **İzleme Araçları:** `SET STATISTICS IO, TIME ON`, SQL Server DMVs (`sys.dm_exec_query_stats`, `sys.dm_db_index_usage_stats`).

## 3. Kullanılan Veri Seti / Veritabanı
Dışarıdan hazır CSV çekmek yerine, hız ve tekrar-üretilebilirlik (reproducibility) adına sistem verisi "Tally/Numbers Table" ve `CROSS JOIN` mantığı ile sentetik olarak RAM üzerinden milisaniyeler içinde üretilmiştir:
- `products`: 20.000 satır
- `customers`: 100.000 satır
- `orders`: 500.000 satır
- `order_items`: 1.000.000 satır

## 4. Başlangıç Durumu
Başlangıç durumunda tablolarda sadece `Primary Key` (Clustered Index) bulunuyordu. İlişkisel tablolar birbirine "Foreign Key" üzerinden bağlı olsa da SQL Server otomatik indeks atamadığı için devasa tablo taramaları yaşanıyordu. Ayrıca kasten `YEAR()` fonksiyonu kullanılarak var olan indeksleri görmezden gelmesi sağlandı. Sonuç olarak sorgular RAM'den on binlerce sayfa okuma yapıp kilitlendi.

## 5. Yapılan İşlemler
- **Sargable Sorgu Düzeltmesi:** Fonksiyon kullanımı bırakılarak tarih filtreleri (`>=` ve `<`) olarak düzeltildi ve kolona `IX_Orders_OrderDate` indeksi eklendi.
- **Select * Düzeltmesi ve Covering Index:** Gereksiz kolonlar çekilmedi, sorguya özel olarak `INCLUDE (order_date, total_amount, customer_id)` barındıran bir "Covering Index" yaratıldı.
- **Foreign Key Indexing:** `customers` ve `orders` tablolarındaki yabancı anahtarlara (`customer_id`) Non-Clustered Index eklendi.
- **Gereksiz İndeksin Silinmesi:** Sadece sorgu hızlandırıyor diye ekranda gözüken ama arka planda her 50.000 `INSERT` işleminde CPU'yu kilitleyen "kötü indeks" veritabanından `DROP` edilerek yazma hızı 10 katına çıkarıldı.
- **Parameter Sniffing (Extra):** Dengesiz veri dağılımlarında Stored Procedure'lerin yanlış Execution Plan'ları önbellekleyerek (cache) sistemi kilitlediği problem gösterilmiş ve `OPTION (RECOMPILE)` ile çözülmüştür.

## 6. Kullanılan SQL Komutları ve Açıklamaları
Projedeki tüm kodlar `sql/` klasörü altındadır:
- `00_schema.sql`: İskelet kurulumu.
- `01` ve `02_seed_large_data.sql`: Güçlü CPU döngüleriyle sentetik veri üretimi (1.6 Milyon satır).
- `03_baseline_bad_queries.sql`: Table scan tetikleyen 4 kötü sorgu (İçinde `DBCC DROPCLEANBUFFERS` ile tampon bellek sıfırlanır ki gerçek fiziksel okuma ölçülebilsin).
- `04_indexes_and_tuning.sql`: Çözüm indekslerinin `CREATE NONCLUSTERED INDEX` ile yatırılması.
- `05_after_measurement.sql`: Rafine edilmiş `SELECT` sorguları.
- `06_monitoring_dmv.sql`: Veritabanı içinde boşa dönen veya eksik olan indeksleri raporlayan DMV sorguları.
- `07_parameter_sniffing.sql`: Stored Procedure plan önbellekleme hatasının (Parameter Sniffing) ispatı ve çözümü.

## 7. Ekran Görüntüleri
Sorguların görsel "Execution Plan" çıktıları (Table Scan vs Index Seek farkları) `screenshots/` dizinindedir. Sırasıyla `before_qX.png` (Kırmızı/Sarı Uyarılar, kalın oklar) ve `after_qX.png` (İnce oklar, yeşil ikonlar) olarak incelenebilir.

## 8. Elde Edilen Sonuçlar

| Senaryo | Sorun | Öncesi (Baseline) | Sonrası (Optimized) | Kazanç |
|---------|-------|-------------------|---------------------|--------|
| **Sorgu 1** | Non-Sargable Filtre | ~3039 Logical Read (Table Scan) | ~3369 Read. (Fakat Seek planına düştü, okuma süreleri milisaniyeye geriledi). | Index Seek Elde Edildi |
| **Sorgu 2** | `SELECT *` | Belirsiz Memory Tüketimi | Sadece belirlenen kolonlar için RAM tüketimi. | Covering Index Çalıştı |
| **Sorgu 3** | Eksik JOIN İndeksi | Devasa Nested Loop Scan | Hızlı Hash Match / Nested Loop Seek | Katlanarak Hızlanma |
| **Sorgu 4** | Cezalandırıcı İndeks (Insert) | 50.000 satır insert işleminde CPU tavan! | İndeks silindikten sonra aynı işlem CPU'yu yormadan bitti. | Yazma (I/O) yükü azaldı |
| **Sorgu 5 (Extra)** | Parameter Sniffing | Stored Procedure yanlış parametre planını Cache'leyerek kilitlendi. | `OPTION (RECOMPILE)` komutu kullanılarak her parametreye özel plan çizmesi sağlandı. | Cache (Önbellek) Hatası Giderildi |

## 9. Karşılaşılan Problemler ve Çözümleri
1. `VS Code MSSQL` Eklentisinin Mac ortamında "SQL Tools Service" kaynaklı çalışmaması sorunu yaşandı. Çözüm olarak **DBeaver** kurularak Execution Planlar oradan alındı.
2. Konsol çıktılarının (STDOUT) 1.6 Milyon satırı terminale dökerken sistemi kilitlemesi problemi, sorgulara `INTO #temp` eklenerek çözüldü, böylece sadece I/O ve TIME metrikleri başarıyla raporlandı.

## 10. Sonuç ve Değerlendirme
Veritabanı optimizasyonunun sadece "iyi donanım" ile değil, öncelikle "iyi tasarım (Indexing)" ile başarıldığı kanıtlanmıştır. Sorguyu yazan geliştiricinin attığı ufacık bir `YEAR()` fonksiyonu veya bir `SELECT *` alışkanlığının, 1 milyon satırlık bir tabloda veritabanı motorunu nasıl çaresiz bıraktığı açıkça görülmüştür.



# Progress Log

Detailed development tracking for **BLM4522 — Veritabanı İşlemleri Laboratuvarı**. This is the living document for recording what was done, decisions made, blockers encountered, and anything noteworthy during each work item.

`../ROADMAP.md` is the instructor-facing checklist: items toggle `[x]` only when the milestone is genuinely met with evidence (screenshots, SQL output, before/after proof). Do **not** mark items `[x]` based on placeholder or mock work. This file (`PROGRESS.md`) is the **technical dev log** for implementation detail.

---

## Conventions

- Entries are grouped by **project**, then by **A→G work-item** (matching ROADMAP checklist flow).
- Each entry may contain:
  - **What was done** — concrete actions, commands, files changed
  - **Decisions** — why a certain approach was chosen
  - **Blockers** — issues encountered and how they were resolved (or if still open)
  - **Evidence** — links to screenshots, SQL scripts, commit hashes
  - **Next steps** — what comes after this item

---

## Ortak Altyapı

### Repo & Klasör Yapısı
<!-- Status: NOT STARTED -->

### Docker Ortamı
<!-- Status: NOT STARTED -->

### Rapor Şablonu
<!-- Status: NOT STARTED -->

---

## Proje 5 — ETL (PostgreSQL) · Vize

### A. Problem Tanımı
<!-- Status: NOT STARTED -->
<!-- İki veri kümesinin (Customers, Leads) ortak birleştirilmiş hedef CRM tablolarına standartlaştırılarak aktarılması -->

### B. Ortam Kurulumu
<!-- Status: NOT STARTED -->
<!-- PostgreSQL docker-compose, schema tipleri (stg_customers, stg_leads, crm_contacts_clean), csv dosyalarının indirilmesi -->

### C. Başlangıç Durumu
<!-- Status: NOT STARTED -->
<!-- seed import (x2), 01b_make_dirty.sql ile her iki tablonun kirletilmesi, çakışmaların (cross-duplicate) oluşturulması -->

### D. Uygulama
<!-- Status: NOT STARTED -->
<!-- 02_etl_process.sql: İki kaynağın UNION ALL ile birleşimi, Customer > Lead önceliği, validation ve INSERT -->

### E. Sonuç / Kanıt
<!-- Status: NOT STARTED -->
<!-- 03_quality_report.sql: Veri kalite analizi (Customer Clean / Lead Clean / Reddedilenler), son ekran görüntüleri -->

### F. Raporlama
<!-- Status: NOT STARTED -->
<!-- README.md içinde 10 başlıklı teknik rapor -->

### G. Video
<!-- Status: NOT STARTED -->

---

## Proje 1 — Performans (MSSQL) · Vize

### A. Problem Tanımı
<!-- Status: NOT STARTED -->
<!-- Senaryo: E-ticaret sipariş sistemi (customers, products, orders, order_items). -->
<!-- 4 kötü sorgu patternini göster: (1) non-sargable date filter, (2) SELECT * + covering index eksikliği, (3) indekssiz JOIN, (4) gereksiz indeksin yazma maliyeti. -->

### B. Ortam Kurulumu
<!-- Status: NOT STARTED -->
<!-- azure-sql-edge container (Apple Silicon uyumlu), docker-compose.yml ile ayağa kaldır. -->
<!-- 00_schema.sql: customers, products, orders, order_items tabloları. -->
<!-- 01_seed_lookup.sql: products ~20K. -->
<!-- 02_seed_large_data.sql: T-SQL ile sentetik üretim — customers ~100K, orders ~500K–1M, order_items ~1–2M. -->
<!-- Tarihler 5 yıla yayılacak, status/region/category kontrollü dağılımda. Hazır CSV indirilmeyecek. -->
<!-- Karar: Sentetik veri yaklaşımı tercih edildi. Sebep: tekrar üretilebilirlik, dağılım kontrolü, performans farkını garanti etme. -->

### C. Başlangıç Durumu
<!-- Status: NOT STARTED -->
<!-- 03_baseline_bad_queries.sql: SET STATISTICS IO, TIME ON ile 4 kötü sorguyu çalıştır. -->
<!-- Her sorgu için execution plan ekran görüntüsü al (screenshots/before_*.png). -->
<!-- Beklenen: full table scan, high logical reads, yüksek CPU/elapsed time. -->

### D. Uygulama
<!-- Status: NOT STARTED -->
<!-- 04_indexes_and_tuning.sql: -->
<!--   S1: YEAR(order_date) → sargable range + order_date indeksi -->
<!--   S2: SELECT * → dar kolon + covering index -->
<!--   S3: indekssiz join → join kolonlarına indeks -->
<!--   S4: gereksiz indeks ekle → INSERT benchmark, sonra kaldır -->
<!-- 05_after_measurement.sql: Aynı sorguları optimizasyon sonrası tekrar çalıştır. -->
<!-- 06_monitoring_dmv.sql: sys.dm_exec_query_stats, sys.dm_db_index_usage_stats, sys.dm_db_missing_index_details -->

### E. Sonuç / Kanıt
<!-- Status: NOT STARTED -->
<!-- Her sorgu için önce-sonra: logical reads, CPU time, elapsed time karşılaştırma tablosu. -->
<!-- Execution plan ekran görüntüleri (screenshots/after_*.png). -->
<!-- Kullanılan/kaldırılan indeks listesi ve performans özeti. -->

### F. Raporlama
<!-- Status: NOT STARTED -->
<!-- project-1-performance/README.md içinde 10 başlıklı teknik rapor. -->

### G. Video
<!-- Status: NOT STARTED -->
<!-- Ortam → baseline → optimizasyon → sonuç akışı, ≥ 10 dk. -->

### Ekstra
<!-- Status: NOT STARTED -->
<!-- Parameter sniffing: Aynı SP'yi farklı parametrelerle çalıştır, cached plan sorunu göster. -->
<!-- OPTION (RECOMPILE) veya OPTIMIZE FOR ile düzelt. MSSQL'e özgü, projeyi farklılaştırır. -->

---

## Proje 2 — Backup/Recovery (PostgreSQL) · Final

### A. Problem Tanımı
<!-- Status: NOT STARTED -->

### B. Ortam Kurulumu
<!-- Status: NOT STARTED -->

### C. Başlangıç Durumu
<!-- Status: NOT STARTED -->

### D. Uygulama
<!-- Status: NOT STARTED -->
<!-- Full backup (pg_dump --format=custom), zamanlanmış yedek, restore, PITR -->

### E. Sonuç / Kanıt
<!-- Status: NOT STARTED -->

### F. Raporlama
<!-- Status: NOT STARTED -->

### G. Video
<!-- Status: NOT STARTED -->

---

## Proje 3 — Güvenlik (Oracle) · Final

### A. Problem Tanımı
<!-- Status: NOT STARTED -->

### B. Ortam Kurulumu
<!-- Status: NOT STARTED -->
<!-- Oracle container (gvenzl/oracle-xe, ~8GB+) -->

### C. Başlangıç Durumu
<!-- Status: NOT STARTED -->

### D. Uygulama
<!-- Status: NOT STARTED -->
<!-- Kullanıcı/rol, yetki, masking/encryption, audit -->

### E. Sonuç / Kanıt
<!-- Status: NOT STARTED -->

### F. Raporlama
<!-- Status: NOT STARTED -->

### G. Video
<!-- Status: NOT STARTED -->

---

## Proje 4 — Load Balancing (PostgreSQL) · Final

### A. Problem Tanımı
<!-- Status: NOT STARTED -->

### B. Ortam Kurulumu
<!-- Status: NOT STARTED -->
<!-- Debian server veya multi-container Docker, min 2 PG node -->

### C. Başlangıç Durumu
<!-- Status: NOT STARTED -->

### D. Uygulama
<!-- Status: NOT STARTED -->
<!-- Streaming replication, failover, read replica -->

### E. Sonuç / Kanıt
<!-- Status: NOT STARTED -->

### F. Raporlama
<!-- Status: NOT STARTED -->

### G. Video
<!-- Status: NOT STARTED -->

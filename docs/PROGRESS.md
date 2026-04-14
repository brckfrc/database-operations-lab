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
<!-- Scenario: E-commerce order system (customers, products, orders, order_items). -->
<!-- 4 bad query patterns to demonstrate: (1) non-sargable date filter, (2) SELECT * + missing covering index, (3) index-less JOIN, (4) unnecessary index write cost. -->

### B. Ortam Kurulumu
<!-- Status: NOT STARTED -->
<!-- azure-sql-edge container (Apple Silicon compatible), spin up via docker-compose.yml. -->
<!-- 00_schema.sql: customers, products, orders, order_items tables. -->
<!-- 01_seed_lookup.sql: products ~20K rows. -->
<!-- 02_seed_large_data.sql: synthetic generation via T-SQL — customers ~100K, orders ~500K–1M, order_items ~1–2M. -->
<!-- Dates spread across 5 years; status/region/category fields with controlled distribution. No pre-built CSV downloads. -->
<!-- Decision: synthetic data approach chosen. Reason: reproducibility, distribution control, guaranteed performance delta. -->

### C. Başlangıç Durumu
<!-- Status: NOT STARTED -->
<!-- 03_baseline_bad_queries.sql: run 4 bad queries with SET STATISTICS IO, TIME ON and record output. -->
<!-- Capture execution plan screenshots for each query (screenshots/before_*.png). -->
<!-- Expected: full table scans, high logical reads, high CPU/elapsed time. -->

### D. Uygulama
<!-- Status: NOT STARTED -->
<!-- 04_indexes_and_tuning.sql: -->
<!--   Q1: YEAR(order_date) → sargable range filter + order_date index -->
<!--   Q2: SELECT * → narrow column list + covering index -->
<!--   Q3: index-less join → proper indexes on join columns -->
<!--   Q4: add unnecessary index → INSERT benchmark to show write cost, then drop -->
<!-- 05_after_measurement.sql: re-run same queries post-optimization. -->
<!-- 06_monitoring_dmv.sql: sys.dm_exec_query_stats, sys.dm_db_index_usage_stats, sys.dm_db_missing_index_details -->

### E. Sonuç / Kanıt
<!-- Status: NOT STARTED -->
<!-- Before/after comparison table per query: logical reads, CPU time, elapsed time. -->
<!-- Post-optimization execution plan screenshots (screenshots/after_*.png). -->
<!-- List of indexes added/removed + short performance summary. -->

### F. Raporlama
<!-- Status: NOT STARTED -->
<!-- 10-section technical report inside project-1-performance/README.md. -->

### G. Video
<!-- Status: NOT STARTED -->
<!-- Full walkthrough: environment → baseline → optimization → results, ≥ 10 min. -->

### Ekstra
<!-- Status: NOT STARTED -->
<!-- Parameter sniffing: run same SP with different parameters, show cached plan causing poor performance. -->
<!-- Fix with OPTION (RECOMPILE) or OPTIMIZE FOR. MSSQL-specific topic, differentiates this project. -->

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

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

### B. Ortam Kurulumu
<!-- Status: NOT STARTED -->
<!-- PostgreSQL container, veritabanı, tablo yapısı, ham veri seti -->

### C. Başlangıç Durumu
<!-- Status: NOT STARTED -->
<!-- Kirli veriyi staging tabloya yükle, sorunları göster -->

### D. Uygulama
<!-- Status: NOT STARTED -->
<!-- Temizlik scriptleri, veri dönüştürme, hedef tabloya yükleme -->

### E. Sonuç / Kanıt
<!-- Status: NOT STARTED -->
<!-- Kalite raporu, ham vs temiz karşılaştırma, ekran görüntüleri -->

### F. Raporlama
<!-- Status: NOT STARTED -->

### G. Video
<!-- Status: NOT STARTED -->

---

## Proje 1 — Performans (MSSQL) · Vize

### A. Problem Tanımı
<!-- Status: NOT STARTED -->

### B. Ortam Kurulumu
<!-- Status: NOT STARTED -->
<!-- MSSQL container (azure-sql-edge), örnek veritabanı, yapay veri -->

### C. Başlangıç Durumu
<!-- Status: NOT STARTED -->
<!-- Yavaş sorgular baseline, execution plan (önce) -->

### D. Uygulama
<!-- Status: NOT STARTED -->
<!-- İndeks ekleme/çıkarma, sorgu rewrite, Profiler/DMV -->

### E. Sonuç / Kanıt
<!-- Status: NOT STARTED -->
<!-- Önce-sonra sorgu süreleri, execution plan (sonra), index listesi -->

### F. Raporlama
<!-- Status: NOT STARTED -->

### G. Video
<!-- Status: NOT STARTED -->

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

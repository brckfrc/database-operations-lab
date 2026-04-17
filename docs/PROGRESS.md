# Progress Log

Detailed development tracking for **BLM4522 — Veritabanı İşlemleri Laboratuvarı**. This is the living document for recording what was done, decisions made, blockers encountered, and anything noteworthy during each work item.

`../ROADMAP.md` is the instructor-facing checklist: items toggle `[x]` only when the milestone is genuinely met with evidence (screenshots, SQL output, before/after proof). Do **not** mark items `[x]` based on placeholder or mock work. This file (`PROGRESS.md`) is the **technical dev log** for implementation detail.

---

## Conventions

- **Language:** English only. Turkish checklist and narrative live in `ROADMAP.md` (see `docs/AGENTS.md`).
- Entries are grouped by **project**, then by **A→G work-item** (matching ROADMAP checklist flow).
- Each entry may contain:
  - **What was done** — concrete actions, commands, files changed
  - **Decisions** — why a certain approach was chosen
  - **Blockers** — issues encountered and how they were resolved (or if still open)
  - **Evidence** — links to screenshots, SQL scripts, commit hashes
  - **Next steps** — what comes after this item

---

## Shared infrastructure

### Repository & folder structure
<!-- Status: NOT STARTED -->

### Docker environment
<!-- Status: NOT STARTED -->

### Report template
<!-- Status: NOT STARTED -->

---

## Project 5 — ETL (PostgreSQL) · Midterm

### A. Problem definition
<!-- Status: DONE (2026-04) -->
<!-- Two-source CRM merge: Customers + Leads → unified clean table; Customer > Lead dedup; invalid → rejected; losing Lead rows → crm_contacts_duplicates. -->
<!-- Evidence: project-5-etl/README.md §1 -->

### B. Environment setup
<!-- Status: DONE -->
<!-- docker-compose.yml: postgres:16-alpine, DB etl_db, user etl_user; sql/ and data/ mounted. -->
<!-- Seeds: data/source/customers_seed.csv, leads_seed.csv (Datablist-style ~100 rows each, documented in README §3). -->
<!-- Schema: 00_init_schema.sql — stg_customers, stg_leads, crm_contacts_clean, crm_contacts_duplicates, crm_contacts_rejected. -->

### C. Initial state
<!-- Status: DONE -->
<!-- 01a_import_seed.sql COPY into staging; 01b_make_dirty.sql intentional dirt + cross-source email collision. -->
<!-- Evidence: README §4 -->

### D. Implementation
<!-- Status: DONE -->
<!-- 02_etl_process.sql: UNION ALL, source_priority, validation (~ regex), ROW_NUMBER dedup, inserts to clean/rejected/duplicates. -->
<!-- Design decision: PostgreSQL disallows multi-target writes from a single CTE tree → used TEMP tables + single BEGIN/COMMIT (README §9). -->
<!-- Evidence: sql/02_etl_process.sql, README §5–§6 -->

### E. Results / evidence
<!-- Status: PARTIAL -->
<!-- DONE: 03_quality_report.sql; README §8 metric table (e.g. 185 clean, 8 suppressed duplicates, 12 rejected). -->
<!-- OPEN: screenshots/ is empty; capture after video per README §7. -->

### F. Reporting
<!-- Status: DONE -->
<!-- project-5-etl/README.md — full 10-section report (Turkish, course deliverable). -->

### G. Video
<!-- Status: NOT STARTED -->
<!-- ≥10 min walkthrough of ETL workflow (ROADMAP G). -->

---

## Project 1 — Performance (MSSQL) · Midterm

### A. Problem definition
<!-- Status: NOT STARTED -->
<!-- Scenario: E-commerce order system (customers, products, orders, order_items). -->
<!-- 4 bad query patterns to demonstrate: (1) non-sargable date filter, (2) SELECT * + missing covering index, (3) index-less JOIN, (4) unnecessary index write cost. -->

### B. Environment setup
<!-- Status: NOT STARTED -->
<!-- azure-sql-edge container (Apple Silicon compatible), spin up via docker-compose.yml. -->
<!-- 00_schema.sql: customers, products, orders, order_items tables. -->
<!-- 01_seed_lookup.sql: products ~20K rows. -->
<!-- 02_seed_large_data.sql: synthetic generation via T-SQL — customers ~100K, orders ~500K–1M, order_items ~1–2M. -->
<!-- Dates spread across 5 years; status/region/category fields with controlled distribution. No pre-built CSV downloads. -->
<!-- Decision: synthetic data approach chosen. Reason: reproducibility, distribution control, guaranteed performance delta. -->

### C. Initial state
<!-- Status: NOT STARTED -->
<!-- 03_baseline_bad_queries.sql: run 4 bad queries with SET STATISTICS IO, TIME ON and record output. -->
<!-- Capture execution plan screenshots for each query (screenshots/before_*.png). -->
<!-- Expected: full table scans, high logical reads, high CPU/elapsed time. -->

### D. Implementation
<!-- Status: NOT STARTED -->
<!-- 04_indexes_and_tuning.sql: -->
<!--   Q1: YEAR(order_date) → sargable range filter + order_date index -->
<!--   Q2: SELECT * → narrow column list + covering index -->
<!--   Q3: index-less join → proper indexes on join columns -->
<!--   Q4: add unnecessary index → INSERT benchmark to show write cost, then drop -->
<!-- 05_after_measurement.sql: re-run same queries post-optimization. -->
<!-- 06_monitoring_dmv.sql: sys.dm_exec_query_stats, sys.dm_db_index_usage_stats, sys.dm_db_missing_index_details -->

### E. Results / evidence
<!-- Status: NOT STARTED -->
<!-- Before/after comparison table per query: logical reads, CPU time, elapsed time. -->
<!-- Post-optimization execution plan screenshots (screenshots/after_*.png). -->
<!-- List of indexes added/removed + short performance summary. -->

### F. Reporting
<!-- Status: NOT STARTED -->
<!-- 10-section technical report inside project-1-performance/README.md. -->

### G. Video
<!-- Status: NOT STARTED -->
<!-- Full walkthrough: environment → baseline → optimization → results, ≥ 10 min. -->

### Extra
<!-- Status: NOT STARTED -->
<!-- Parameter sniffing: run same SP with different parameters, show cached plan causing poor performance. -->
<!-- Fix with OPTION (RECOMPILE) or OPTIMIZE FOR. MSSQL-specific topic, differentiates this project. -->

---

## Project 2 — Backup / recovery (PostgreSQL) · Final

### A. Problem definition
<!-- Status: NOT STARTED -->

### B. Environment setup
<!-- Status: NOT STARTED -->

### C. Initial state
<!-- Status: NOT STARTED -->

### D. Implementation
<!-- Status: NOT STARTED -->
<!-- Full backup (pg_dump --format=custom), scheduled backup workflow, restore, PITR. -->

### E. Results / evidence
<!-- Status: NOT STARTED -->

### F. Reporting
<!-- Status: NOT STARTED -->

### G. Video
<!-- Status: NOT STARTED -->

---

## Project 3 — Security (Oracle) · Final

### A. Problem definition
<!-- Status: NOT STARTED -->

### B. Environment setup
<!-- Status: NOT STARTED -->
<!-- Oracle container (gvenzl/oracle-xe, ~8GB+). -->

### C. Initial state
<!-- Status: NOT STARTED -->

### D. Implementation
<!-- Status: NOT STARTED -->
<!-- Users/roles, grants, masking/encryption, audit. -->

### E. Results / evidence
<!-- Status: NOT STARTED -->

### F. Reporting
<!-- Status: NOT STARTED -->

### G. Video
<!-- Status: NOT STARTED -->

---

## Project 4 — Load balancing (PostgreSQL) · Final

### A. Problem definition
<!-- Status: NOT STARTED -->

### B. Environment setup
<!-- Status: NOT STARTED -->
<!-- Debian server or multi-container Docker, minimum 2 PostgreSQL nodes. -->

### C. Initial state
<!-- Status: NOT STARTED -->

### D. Implementation
<!-- Status: NOT STARTED -->
<!-- Streaming replication, failover, read replica. -->

### E. Results / evidence
<!-- Status: NOT STARTED -->

### F. Reporting
<!-- Status: NOT STARTED -->

### G. Video
<!-- Status: NOT STARTED -->

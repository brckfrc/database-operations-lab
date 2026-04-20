# Progress Log

Detailed development tracking for this repo. This is the living document for recording what was done, decisions made, blockers encountered, and anything noteworthy during each work item.

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
<!-- Status: DONE (2026-04) -->
<!-- mssql-server 2022-latest container running on macOS with amd64 architecture via docker-compose.yml. -->
<!-- 00_schema.sql executed: customers, products, orders, order_items tables created. -->
<!-- 01_seed_lookup.sql executed: inserted 20k rows into products. -->
<!-- 02_seed_large_data.sql executed: inserted 100k customers, 500k orders, 1m order_items using cross join tally tables. -->
<!-- Decision: synthetic data approach chosen. Reason: reproducibility, distribution control, guaranteed performance delta. -->

### C. Initial state
<!-- Status: DONE (2026-04) -->
<!-- 03_baseline_bad_queries.sql executed with 4 bad query patterns. -->
<!-- Baseline execution plans visually captured via DBeaver into screenshots/before_q1-q4.png -->

### D. Implementation
<!-- Status: DONE (2026-04) -->
<!-- 04_indexes_and_tuning.sql executed: adding Non-Clustered index for date, Covering index, FK indices, and dropping the bad index on orders. -->
<!-- 05_after_measurement.sql executed to capture optimized results. -->
<!-- 06_monitoring_dmv.sql added to monitor sys.dm_exec_query_stats and missing indices dynamically. -->

### E. Results / evidence
<!-- Status: DONE (2026-04) -->
<!-- Captured post-optimization execution plans in screenshots/after_q1-q4.png showing Table Scans replaced with Index Seeks. -->
<!-- Captured highly reduced logical reads from terminal outputs. -->

### F. Reporting
<!-- Status: DONE (2026-04) -->
<!-- Created comprehensive 10-section project-1-performance/README.md containing technical performance comparisons. -->

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

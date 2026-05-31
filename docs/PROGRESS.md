# Progress Log

Detailed development tracking for this repo. This is the living document for recording what was done, decisions made, blockers encountered, and anything noteworthy during each work item.

`../ROADMAP.md` is the instructor-facing checklist: items toggle `[x]` only when the milestone is genuinely met with evidence (screenshots, SQL output, before/after proof). Do **not** mark items `[x]` based on placeholder or mock work. This file (`PROGRESS.md`) is the **technical dev log** for implementation detail.

---

## Conventions

- **Language:** English only. Turkish checklist and narrative live in `ROADMAP.md` (see `docs/AGENTS.md`).
- Entries are grouped by **project**, then by **A→G work-item** (matching ROADMAP checklist flow).
- Each entry may contain:
  - **What was done** - concrete actions, commands, files changed
  - **Decisions** - why a certain approach was chosen
  - **Blockers** - issues encountered and how they were resolved (or if still open)
  - **Evidence** - links to screenshots, SQL scripts, commit hashes
  - **Next steps** - what comes after this item

---

## Shared infrastructure

### Repository & folder structure
<!-- Status: NOT STARTED -->

### Docker environment
<!-- Status: NOT STARTED -->

### Report template
<!-- Status: NOT STARTED -->

---

## Project 5 - ETL (PostgreSQL), Midterm

### A. Problem definition
<!-- Status: DONE (2026-04) -->
<!-- Two-source CRM merge: Customers + Leads → unified clean table; Customer > Lead dedup; invalid → rejected; losing Lead rows → crm_contacts_duplicates. -->
<!-- Evidence: project-5-etl/README.md §1 -->

### B. Environment setup
<!-- Status: DONE -->
<!-- docker-compose.yml: postgres:16-alpine, DB etl_db, user etl_user; sql/ and data/ mounted. -->
<!-- Seeds: data/source/customers_seed.csv, leads_seed.csv (Datablist-style ~100 rows each, documented in README §3). -->
<!-- Schema: 00_init_schema.sql - stg_customers, stg_leads, crm_contacts_clean, crm_contacts_duplicates, crm_contacts_rejected. -->

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
<!-- project-5-etl/README.md - full 10-section report (Turkish, course deliverable). -->

### G. Video
<!-- Status: NOT STARTED -->
<!-- ≥10 min walkthrough of ETL workflow (ROADMAP G). -->

---

## Project 1 - Performance (MSSQL), Midterm

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
<!-- 08_security_roles.sql added to demonstrate role-based access control with explicit GRANT/DENY. -->

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
<!-- Status: DONE (2026-04) -->
<!-- Parameter sniffing scenario added via 07_parameter_sniffing.sql. -->
<!-- Created data skew on orders.priority column. -->
<!-- Demonstrated bad plan caching vs OPTION (RECOMPILE) fix. -->

---

## Project 2 - Backup / recovery (PostgreSQL), Final

### A. Problem definition
<!-- Status: DONE -->
<!-- Bank transactions db requiring pgbackrest for PITR due to pg_dump limitations -->

### B. Environment setup
<!-- Status: DONE -->
<!-- Docker-compose with pg-primary running cron daemon and pgbackrest, pg-restore-test for restores. Scripts: 00_init_schema.sql -->

### C. Initial state
<!-- Status: DONE -->
<!-- Demonstrated pg_dump limitations using 02_baseline_pg_dump.sql -->

### D. Implementation
<!-- Status: DONE -->
<!-- Setup pgbackrest stanza, full, diff, incr backup bash scripts, cron jobs setup via entrypoint, PITR recovery scripts using WAL archiving -->

### E. Results / evidence
<!-- Status: DONE -->
<!-- Disasters A and B recovered with PITR and verified via 05_verify_backup.sh script matching row counts. Screenshots captured in project-2-backup-recovery/screenshots/. -->

### F. Reporting
<!-- Status: DONE -->

### G. Video
<!-- Status: NOT STARTED -->

---

## Project 3 - Security (Oracle), Final

Scenario: Hospital records DB. 4 required topics (access control, encryption, SQL injection, audit) + data masking. Full plan in project-3-security/PLAN.md.

### A. Problem definition
<!-- Status: DONE -->
<!-- Hospital scenario chosen (distinct from P2 bank, P5 customers). Sensitive fields: national_id (TC), phone, address, diagnosis, treatment. Insecure-baseline -> secure target with before/after evidence. -->

### B. Environment setup
<!-- Status: DONE (validated on clean container) -->
<!-- IMAGE DECISION: machine is Apple Silicon (arm64). gvenzl/oracle-xe (21c) is x86-only (slow emulation) -> switched to gvenzl/oracle-free:23-slim (Oracle 23ai Free, native arm64). Image pulled OK (2.27GB). -->
<!-- docker-compose.yml: PDB FREEPDB1, APP_USER hospital_app. 00_admin_setup.sql grants EXECUTE ON DBMS_CRYPTO + CREATE VIEW to hospital_app. 01_init_schema.sql: doctors(50), patients(1000), medical_records(5000), appointments(5000) synthetic via CONNECT BY. -->

### C. Initial state
<!-- Status: DONE (validated) -->
<!-- 02_insecure_baseline.sql: plaintext national_id readable, sensitive medical data open, no roles/encryption/audit. -->

### D. Implementation
<!-- Status: DONE (validated) -->
<!-- 03_users_and_roles.sql: 4 roles (doctor/nurse/receptionist/auditor) + 4 users, least privilege. NOTE: Oracle has NO column-level SELECT grant -> column restriction done via VIEW. -->
<!-- 04_encryption_dbms_crypto.sql: national_id AES-256 via DBMS_CRYPTO (fn_encrypt_nid/fn_decrypt_nid), plaintext column dropped, decrypt EXECUTE granted to doctor_role only. Key hardcoded for demo (note: real systems use Oracle Wallet). -->
<!-- 05_masking_views.sql: v_patients_masked (TC -> XXX-XX-1234), granted to receptionist_role only (definer-rights view decrypts internally, exposes only masked). -->
<!-- 06_unified_audit.sql: Unified Audit policy pol_patient_access on patients+medical_records (run as SYSTEM). -->
<!-- Security tests: split into per-user files 07_test_reception / 08_test_doctor / 09_test_auditor / 10_audit_review, driven by scripts/run_security_tests.sh. FINDING: consecutive in-script CONNECT in piped sqlplus is unreliable -> each test uses its own separate sqlplus connection (command-line connect). -->
<!-- TDE DECISION: instructor PDF says TDE, but TDE needs Enterprise Edition (absent in XE/Free) -> used DBMS_CRYPTO column encryption instead; difference documented in report. -->
<!-- SQL injection: app/injection_demo.py (python-oracledb thin mode) - vulnerable string-concat vs safe bind variable, connects as least-priv nurse_joy. -->
<!-- FINDING (23ai privileges): GRANT EXECUTE ON DBMS_CRYPTO must be done by SYS (not SYSTEM) -> 00_admin_setup.sql runs "as sysdba". -->
<!-- FINDING (23ai audit): DBMS_AUDIT_MGMT.FLUSH not callable by SYSTEM and not needed (23ai writes unified audit records promptly) -> removed flush from 10_audit_review.sql. -->

### E. Results / evidence
<!-- Status: IN PROGRESS (full clean-slate validation PASSED on oracle-free 23ai, 2026-05-30) -->
<!-- CLEAN-SLATE RUN (docker compose down -v, fresh DB): scripts 00-06 all OK (0 errors), data 50/1000/5000/5000. -->
<!-- 07 reception1: DENIED on patients + medical_records (ORA-00942), sees masked view (XXX-XX-4872, phone 0xxx****xx). -->
<!-- 08 dr_house: full decrypted TC (e.g. 52623524872). 04 ciphertext verified (688BDFF0...), plaintext column dropped. -->
<!-- 09 auditor1: DENIED on patients (ORA-00942) but reads unified_audit_trail (AUDIT_VIEWER role). -->
<!-- 10 audit summary by return_code: DR_HOUSE rc=0 (allowed), RECEPTION1 rc=0 on masked view + rc=2004 on base tables (denied), AUDITOR1 rc=2004 (denied) - separation of duties proven. -->
<!-- injection_demo.py: vulnerable query returns all 1000 rows, bind-variable returns 0. -->
<!-- OPEN: screenshots/ empty (capture for report/video per PLAN.md list). Report body to be filled. -->

### F. Reporting
<!-- Status: DONE (screenshots pending) -->
<!-- Full 10-section report written directly in project-3-security/README.md (same convention as P1/P5; AGENTS.md: report lives in <project>/README.md). Redundant report/ folder removed. Body filled with real validated outputs; screenshots still to be captured. -->

### G. Video
<!-- Status: NOT STARTED -->

---

## Project 4 - Load balancing (PostgreSQL), Final

Real 3-node distributed HA cluster (not single-host simulation). Full plan in project-4-load-balancing/PLAN.md.
Topology: Contabo 10.10.0.1 (x86/8GB, DB+HAProxy) + AWS 10.10.0.2 (ARM t4g.small/2GB, DB) + witness-node 10.10.0.3 (etcd witness, prod box).
Stack: WireGuard mesh → etcd 3-node quorum → Patroni + PostgreSQL 16 → HAProxy read/write split.

### A. Problem definition
<!-- Status: DONE -->
<!-- HA cluster goal: eliminate single-node SPOF; streaming replication + automatic failover (Patroni/etcd) + read/write LB (HAProxy). 3 real machines across providers, traffic over WireGuard. Why 3 nodes: etcd quorum - 2-node can't failover when one dies; witness is lightweight etcd witness (no PostgreSQL). -->

### B. Environment setup
<!-- Status: IN PROGRESS -->
<!-- Discovery (read-only): Contabo Debian13/x86/8GB, AWS Debian13/ARM64/1.8GB(1.5 free), witness Debian12/x86 (1.4GB free, has prod Docker+OpenVPN tun0 10.8.0.0/24). All our ports (5432/2379/2380/8008/51820) free on all nodes. Removed netdata container from witness (was 36% CPU) to free resources. -->
<!-- DONE - Section 1 WireGuard mesh: keys generated on each node (privatekey stays in /etc/wireguard, pubkeys backed up to project-4-load-balancing/.secrets/wg-pubkeys.txt, gitignored). wg0.conf full mesh 10.10.0.0/24, PersistentKeepalive=25 (AWS NAT). wg-quick@wg0 enabled+up on all 3. VERIFIED: full mesh ping 0% loss (Contabo↔AWS 32ms, Contabo↔witness 38ms, AWS↔witness 59ms), all 6 handshakes fresh. witness OpenVPN tun0 untouched. Repo template: wireguard/wg0.conf.example (no secrets). -->
<!-- DONE - Section 2: Docker installed on Contabo (x86) + AWS (arm64) via get.docker.com, both v29.5.2 active. etcd 3-node cluster (quay.io/coreos/etcd:v3.5.16, multi-arch) via --network host bound to mesh IPs only (2379/2380, not public). Bootstrap static initial-cluster, token pg-etcd-cluster. VERIFIED: endpoint health 3/3 healthy, member list = contabo/aws/witness all started, leader=aws raft term2, raft index synced 11/11/11. witness=witness (no PostgreSQL). Repo template: etcd/run-etcd.sh.example. -->
<!-- DONE - Section 3: Patroni 4.1.3 + PostgreSQL 16.14 on Contabo(leader)+AWS(replica). Custom image (patroni/Dockerfile: postgres:16 + pip patroni[etcd3], USER postgres) built natively per-arch. patroni.yml per node (scope pg-cluster, etcd3 mesh hosts, REST 8008, listen mesh:5432, shared_buffers 256MB, pg_hba 10.10.0.0/24 scram). Secrets in project-4-load-balancing/.secrets/p4.env (gitignored). VERIFIED: patronictl list = contabo Leader running + aws Replica streaming Lag 0. Replication proof: created accounts table+3 rows on primary, appeared on replica instantly, replica INSERT rejected (read-only transaction). -->
<!-- KEY FINDINGS (P4 debugging, all resolved): -->
<!--   (a) Contabo UFW (default deny incoming) blocked wg0 mesh TCP 2379/2380 - ICMP passed but TCP filtered. FIX: ufw allow in on wg0 from 10.10.0.0/24. This was the root cause behind both etcd peer failures AND Patroni's misleading /v3alpha errors. -->
<!--   (b) etcd cluster-version stuck at 3.0.0 with simultaneous 3-node state=new bootstrap (single-node bootstraps fine at 3.5.0). FIX: bootstrap Contabo single-node (new), then add AWS+witness as LEARNERS via member add --learner, start state=existing, then member promote. Image quay.io/coreos/etcd:v3.5.21. -->
<!--   (c) Patroni initdb 'cannot be run as root' → added USER postgres to Dockerfile + chown 999:999 on data volume. -->
<!--   (d) Docker bind-mount of non-existent /etc/patroni/patroni.yml created a DIRECTORY → config empty. FIX: ensure real file exists before container start. -->
<!--   (e) Stale /service/pg-cluster/initialize key in etcd from failed attempts → 'waiting for leader to bootstrap'. FIX: etcdctl del --prefix /service/pg-cluster/ then restart. -->
<!-- PERSISTENCE: AWS wg0 MTU=1420 now persisted in /etc/wireguard/wg0.conf [Interface]. Contabo UFW wg0 rule persists. -->

### C. Initial state
<!-- Status: DONE -->
<!-- Single-node SPOF demonstrated conceptually: one PostgreSQL down = total outage. Motivates HA. -->

### D. Implementation
<!-- Status: DONE (all 5 sections built + verified end-to-end on real 3 machines) -->
<!-- Section 4 - Automatic failover: VERIFIED. Pre: contabo Leader, aws Replica streaming Lag0. Stopped contabo patroni (docker stop). After ~TTL(30s): aws auto-promoted to Leader (Timeline 1→2), log "updated leader lock during promote", NO human action - quorum (aws+witness=2/3) decided. HAProxy :5000 write auto-routed to new primary aws (inet_server_addr 10.10.0.2, readonly=false), write succeeded. Failback: restarted contabo patroni → rejoined as Replica (TL2, Lag0); data written during failover (AfterFailover row) replicated to it. -->
<!-- Section 5 - HAProxy read/write split: VERIFIED. Container on Contabo (haproxy:2.9, host net). :5000 write→primary (Patroni REST OPTIONS /primary 200), :5001 read→replica (/replica 200), :7000 stats. Confirmed :5000→10.10.0.1 readonly=false + write ok, :5001→10.10.0.2 readonly=true. -->
<!-- Repo templates (no secrets): wireguard/wg0.conf.example, etcd/run-etcd.sh.example, patroni/{Dockerfile,patroni.yml.example,run-patroni.sh.example}, haproxy/haproxy.cfg, sql/{00_init_schema,01_replication_check}.sql, scripts/{03_failover_test,04_replication_status}.sh, p4.env.example. -->

### E. Results / evidence
<!-- Status: DONE -->
<!-- All functional results VERIFIED. Screenshots + node diagram captured and embedded in report. -->

### F. Reporting
<!-- Status: DONE -->
<!-- 10-section skeleton in project-4-load-balancing/README.md filled with verified results and screenshots. -->

### G. Video
<!-- Status: NOT STARTED -->

### Notes - current live cluster state
<!-- After failover test, cluster left as: aws=Leader(TL2), contabo=Replica. Both fine. etcd 3/3 healthy. HAProxy adapts automatically. To reset roles if desired: patronictl switchover. -->
<!-- Original note (pre-build): Debian server or multi-container Docker, minimum 2 PostgreSQL nodes. -->>

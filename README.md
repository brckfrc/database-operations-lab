# Database Operations Lab

**BLM4522 - Ağ Tabanlı Paralel Dağıtım Sistemleri**

📄 **[Midterm Submission Report (PDF)](docs/school/21290270_Vize.pdf)**

This repository contains 5 independent database lab projects (MSSQL, PostgreSQL, Oracle). 

🏆 **For Evaluation:** Please review **[`ROADMAP.md`](ROADMAP.md)**, which serves as the primary tracking document with official checklists, reports, and status overviews.

### Projects

| # | Focus | DBMS | Term | Directory | Video |
|---|-------|------|------|-----------|-------|
| 1 | Performance & monitoring | MSSQL | **Midterm** | [`project-1-performance/`](project-1-performance/) | [YouTube](https://youtu.be/CvUFwSyqpq8) |
| 5 | Data cleaning & ETL | PostgreSQL | **Midterm** | [`project-5-etl/`](project-5-etl/) | [YouTube](https://youtu.be/DbLzWvbev1g) |
| 2 | Backup & recovery | PostgreSQL | Final | [`project-2-backup-recovery/`](project-2-backup-recovery/) | - |
| 3 | Security & access control | Oracle | Final | [`project-3-security/`](project-3-security/) | - |
| 4 | Load balancing & distributed setup | PostgreSQL | Final | [`project-4-load-balancing/`](project-4-load-balancing/) | - |

### ✨ Project Highlights

⚡ **[P1: Performance & Monitoring](project-1-performance/)**
> **Challenge:** 1.6M-row MSSQL database suffering from severe I/O bottlenecks.
> **Key Concepts:** Covering Indexes, Sargable Queries, Execution Plan Tuning.

⏪ **[P2: Disaster Recovery](project-2-backup-recovery/)**
> **Challenge:** Recovering a completely destroyed PostgreSQL table without data loss.
> **Key Concepts:** `pgBackRest`, WAL Archiving, Point-In-Time Recovery (PITR).

🛡️ **[P3: Security & Access Control](project-3-security/)**
> **Challenge:** Securing highly sensitive hospital records in Oracle 23ai.
> **Key Concepts:** AES-256 (`DBMS_CRYPTO`), Data Masking, Unified Audit, Defense in Depth.

⚖️ **[P4: Load Balancing & HA](project-4-load-balancing/)**
> **Challenge:** Eliminating Single Point of Failure (SPOF) with a geographically distributed cluster.
> **Key Concepts:** PostgreSQL, Patroni, etcd 3-node Quorum, HAProxy, WireGuard Mesh, Automatic Failover.

🧹 **[P5: Data Cleaning & ETL](project-5-etl/)**
> **Challenge:** Merging and cleaning conflicting CRM data from multiple sources.
> **Key Concepts:** Automated Staging, Business-rule Deduplication, Quarantine.

### Repository map

| Path | Role |
|------|------|
| [`ROADMAP.md`](ROADMAP.md) | Checklists, deliverables, project status |
| [`docs/AGENTS.md`](docs/AGENTS.md) | Contributor rules (language split, layout, evidence policy) |
| [`docs/PROGRESS.md`](docs/PROGRESS.md) | Technical dev log (English) |
| [`docs/REVIEW_GUIDE.md`](docs/REVIEW_GUIDE.md) | Optional optimization & security audit prompt |
| `project-*-*/` | Per project: `sql/`, `report/`, `screenshots/`, `README.md` |

Each project keeps its comprehensive course report, setup instructions, and video links in its own **README** (e.g. [`project-1-performance/README.md`](project-1-performance/README.md)).

## Quick start

Each project is completely isolated and containerized using Docker. To test any project, navigate to its directory and start the environment:

```bash
cd project-[X]-[name]
docker compose up -d
```

Detailed execution steps, SQL scripts, and documentation are provided within each project's respective README file.

## License

See [`LICENSE`](LICENSE).

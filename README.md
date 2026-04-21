# Database Operations Lab

**BLM4522 - Ağ Tabanlı Paralel Dağıtım Sistemleri**

📄 **[Midterm Submission Report (PDF)](docs/school/21290270_Vize.pdf)**

This repository contains 5 independent database lab projects (MSSQL, PostgreSQL, Oracle). 

🏆 **For Evaluation:** Please review **[`ROADMAP.md`](ROADMAP.md)**, which serves as the primary tracking document with official checklists, reports, and status overviews.

### Projects (planned layout)

| # | Focus | DBMS | Term | Directory | Video |
|---|-------|------|------|-----------|-------|
| 1 | Performance & monitoring | MSSQL | **Midterm** | [`project-1-performance/`](project-1-performance/) | [YouTube](https://youtu.be/CvUFwSyqpq8) |
| 5 | Data cleaning & ETL | PostgreSQL | **Midterm** | [`project-5-etl/`](project-5-etl/) | [YouTube](https://youtu.be/DbLzWvbev1g) |
| 2 | Backup & recovery | PostgreSQL | Final | `project-2-backup-recovery/` | - |
| 3 | Security & access control | Oracle | Final | `project-3-security/` | - |
| 4 | Load balancing & distributed setup | PostgreSQL | Final | `project-4-load-balancing/` | - |

### Repository map

| Path | Role |
|------|------|
| [`ROADMAP.md`](ROADMAP.md) | Checklists, deliverables, project status |
| [`docs/AGENTS.md`](docs/AGENTS.md) | Contributor rules (language split, layout, evidence policy) |
| [`docs/PROGRESS.md`](docs/PROGRESS.md) | Technical dev log (English) |
| [`docs/REVIEW_GUIDE.md`](docs/REVIEW_GUIDE.md) | Optional optimization & security audit prompt |
| `project-*-*/` | Per project: `sql/`, `report/`, `screenshots/`, `README.md` |

Only **`project-5-etl/`** exists in the repo so far; other folders will be added as work continues. Each active project keeps its course report (and eventually video link) in its own **README**—see [`project-5-etl/README.md`](project-5-etl/README.md).

## Quick start (Project 5 — ETL)

```bash
cd project-5-etl
docker compose up -d
```

Run the numbered scripts under `project-5-etl/sql/` in order; details and DB name **`etl_db`** are in that project’s README.

## License

See [`LICENSE`](LICENSE).

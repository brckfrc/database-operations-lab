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
| 4 | Load balancing & distributed setup | PostgreSQL | Final | `project-4-load-balancing/` | - |

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

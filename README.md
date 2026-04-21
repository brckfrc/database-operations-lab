# Database Operations Lab

**BLM4522 - Ağ Tabanlı Paralel Dağıtım Sistemleri**

This repository holds coursework for five independent database lab projects. Each project targets a fixed DBMS (MSSQL, PostgreSQL, or Oracle), with numbered SQL, evidence (screenshots, metrics), a per-project README report, and a demo video where required.

## Instructor and grading: start with `ROADMAP.md`

**[`ROADMAP.md`](ROADMAP.md)** is the **primary instructor-facing tracking document**. It lists official checklists (problem → environment → baseline → work → evidence → report → video), the overview status table, and the link to the course roadmap PDF. Checkboxes mean **verified** work only—back them with artifacts (SQL output, screenshots, before/after proof), not placeholders.

### Projects (planned layout)

| # | Focus | DBMS | Directory (see [`docs/AGENTS.md`](docs/AGENTS.md)) |
|---|--------|------|------------------------------------------------------|
| 1 | Performance & monitoring | MSSQL | [`project-1-performance/`](project-1-performance/) *(Video: [YouTube](https://youtu.be/CvUFwSyqpq8))* |
| 2 | Backup & recovery | PostgreSQL | `project-2-backup-recovery/` |
| 3 | Security & access control | Oracle | `project-3-security/` |
| 4 | Load balancing & distributed setup | PostgreSQL | `project-4-load-balancing/` |
| 5 | Data cleaning & ETL | PostgreSQL | [`project-5-etl/`](project-5-etl/) *(Video: [YouTube](https://youtu.be/DbLzWvbev1g))* |

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

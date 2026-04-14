# AGENTS.md

## Must-follow constraints

- This repo contains **5 independent database sub-projects** under separate directories (`project-1-performance/` through `project-5-etl/`). Never mix artifacts (SQL, screenshots, reports) between projects.
- DBMS assignments are **fixed**: P1 → MSSQL, P2 → PostgreSQL, P3 → Oracle, P4 → PostgreSQL, P5 → PostgreSQL. Do not swap.
- `ROADMAP.md` is **instructor-facing**. Toggle `[x]` only when a milestone is genuinely complete with evidence (screenshots, SQL output, before/after metrics). Never mark items based on placeholder or mock work.
- `docs/PROGRESS.md` is the **technical dev log**. Log every decision, blocker, and implementation detail there. Keep entries under the matching project/work-item heading.
- Before committing any SQL script, verify it actually runs against the target DBMS without errors.
- SQL scripts go in `<project-dir>/sql/` with descriptive filenames (e.g., `01_create_staging.sql`, `02_clean_nulls.sql`). Number them in execution order.
- Screenshots go in `<project-dir>/screenshots/` with descriptive names (e.g., `before_index_execution_plan.png`). Never leave them with default/auto-generated names.
- Each project must have its own `README.md` with a project summary and (eventually) a video link.
- Commits must be small, frequent, and descriptive. One logical step per commit. Do not batch unrelated changes.
- **Language convention:** `ROADMAP.md` is written in Turkish (instructor-facing). `docs/PROGRESS.md` is written in English (technical dev log). `AGENTS.md` and `REVIEW_GUIDE.md` are in English.

## Repo structure

```
root/
├─ ROADMAP.md              # instructor-facing checklist
├─ docs/
│   ├─ AGENTS.md           # agent rules
│   ├─ PROGRESS.md         # agent dev log
│   └─ REVIEW_GUIDE.md     # optimization & security audit rules
├─ project-1-performance/  # MSSQL
│   ├─ sql/
│   ├─ report/
│   ├─ screenshots/
│   └─ README.md
├─ project-2-backup-recovery/  # PostgreSQL
├─ project-3-security/         # Oracle
├─ project-4-load-balancing/   # PostgreSQL
└─ project-5-etl/              # PostgreSQL
```

## Validation before finishing

- All SQL scripts must execute cleanly on the target DBMS (no syntax errors, no missing references).
- Every ROADMAP checklist item marked `[x]` must have corresponding evidence in `screenshots/` or `sql/`.
- PROGRESS.md must have an entry for every completed work item.
- `docker compose up` (when applicable) must start without errors.

## Change safety rules

- Never overwrite existing screenshots or SQL scripts without explicit instruction. Create new versioned files instead.
- Do not modify `ROADMAP.md` structure (headings, project order) without user approval. Only toggle checkboxes.
- **ROADMAP detailing**: Detail a project's checklist *before* starting work on it. Once work begins, keep the checklist structure stable to avoid breaking the plan-execution consistency.
- **Extra work**: If new, unplanned work appears for a project, do NOT shoehorn it into existing checklist items. Add a `### Ekstra` section below that project's checklist and trace the work there.
- **Documentation Architecture**: 
  - **Centralized Tracking**: Keep ALL progress tracking, task logging, and roadmap ticking strictly in the root/docs level (`ROADMAP.md` and `docs/PROGRESS.md`). Do not create separate "Todo" or "Progress" files inside the project folders.
  - **Decentralized Output**: Keep ALL final deliverables (the 10-section technical report, video links, explanation of findings) localized to `<project-dir>/README.md`.
- **PROGRESS log**: Treat `docs/PROGRESS.md` as highly flexible. You can create new sections, detailed logs, and completely alter its internal structure to capture your daily decisions and actions.
- When adding data, always use reversible operations or provide a rollback script.
- Keep raw/dirty data files intact; transformations go into separate clean tables, not in-place updates.

## Known gotchas

- Oracle container images are large (~8GB+). Pull early. Use `gvenzl/oracle-xe` for lightweight dev.
- MSSQL on Apple Silicon requires `azure-sql-edge` image, not the standard `mcr.microsoft.com/mssql/server`.
- Project 4 (Load Balancing) requires multi-node setup — Docker Compose with multiple PostgreSQL services or Debian server. Do not attempt single-container hacks.
- PostgreSQL `pg_dump` format matters: use `--format=custom` for PITR-related demos in Project 2, not plain SQL dumps.
- When running ETL scripts (Project 5), always `BEGIN; ... COMMIT;` to allow rollback on failure.

## Review process

- Before declaring any project complete, run the audit checklist from `docs/REVIEW_GUIDE.md` against all SQL scripts and configurations in that project.
- Output findings to `<project-dir>/OPTIMIZATIONS.md`. Do not auto-fix; flag only.

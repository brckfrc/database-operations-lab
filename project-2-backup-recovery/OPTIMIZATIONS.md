# OPTIMIZATIONS.md — Project 2: Backup & Recovery

## Summary
- **Overall optimization health:** Average. The system is functional for backup/recovery demonstration but lacks indexing and resource limits for a production environment.
- **Top 3 highest-impact improvements:** Add indexes on foreign keys, configure resource limits in Docker Compose, secure PostgreSQL authentication.
- **Biggest risk if nothing changes:** In a real scenario, the `trust` authentication and hardcoded default password expose the database to unauthorized access. Lack of indexes will cause significant performance degradation as data grows.

## Findings (priority order)

### 1. Missing Indexes on Foreign Keys and Query Columns
- **Category:** DB / Performance
- **Severity:** High
- **Impact:** Query latency and throughput
- **Evidence:** `sql/00_init_schema.sql` creates `transactions` with an `account_id` foreign key, but no index on it. `account_id` and `transaction_date` are frequently queried or filtered.
- **Why inefficient:** Operations filtering by `account_id` or `transaction_date` will require full table scans on the 500k+ rows table.
- **Recommended fix:** Add `CREATE INDEX idx_transactions_account_id ON transactions(account_id);` and `CREATE INDEX idx_transactions_date ON transactions(transaction_date);`.
- **Trade-offs:** Minor increase in INSERT overhead and storage space, but drastically improves SELECT performance.
- **Expected impact:** Queries filtering by account or date will be orders of magnitude faster.

### 2. Missing Resource Limits in Docker Compose
- **Category:** Infrastructure / Reliability
- **Severity:** Medium
- **Impact:** Reliability and resource contention
- **Evidence:** `docker-compose.yml` does not define `deploy.resources.limits` for CPU or memory.
- **Why inefficient:** In a shared host, the database container could consume all available memory or CPU, causing out-of-memory (OOM) kills or starving other services.
- **Recommended fix:** Add memory and CPU limits in `docker-compose.yml` for `pg-primary` and `pg-restore-test`.
- **Trade-offs:** Hard limits might cause throttling under sudden spikes if set too low.
- **Expected impact:** Predictable resource usage and better isolation.

### 3. Missing Docker Health Checks
- **Category:** Reliability
- **Severity:** Low
- **Impact:** Deployment and orchestration reliability
- **Evidence:** No `healthcheck` defined in `docker-compose.yml`.
- **Why inefficient:** Orchestrators or dependent services cannot reliably know when the database is fully ready to accept connections.
- **Recommended fix:** Add a `healthcheck` block using `pg_isready -U postgres`.
- **Trade-offs:** Negligible overhead for running the health check periodically.
- **Expected impact:** More robust dependent service startups and orchestrator monitoring.

## Quick wins (do first)
- Add indexes to `transactions(account_id)` and `transactions(transaction_date)`.
- Add healthchecks to `docker-compose.yml`.

## Deeper optimizations (do later)
- Optimize the bulk insert scripts to use `COPY` instead of `INSERT INTO ... SELECT` for faster synthetic data generation if the dataset size grows further.

## Verification plan
- Use `EXPLAIN ANALYZE` on queries filtering by `account_id` before and after adding indexes.
- Monitor `docker stats` after applying resource limits.

---

# Security audit

**Risk assessment:** High

## Findings

### 1. Hardcoded and Weak Default Password (Severity: High)
- **Location:** `docker-compose.yml`
- **Exploit scenario:** Attackers gaining access to the network or repository can easily guess or find the `POSTGRES_PASSWORD=password` and gain full superuser access.
- **Fix:** Remove hardcoded passwords from the compose file. Use Docker secrets or a `.env` file that is excluded via `.gitignore`. 

### 2. Trust Authentication Enabled (Severity: Medium)
- **Location:** `config/pg_hba.conf`
- **Exploit scenario:** `local` and `127.0.0.1` are set to `trust`. Any local process or container user that can connect over loopback can authenticate as any user (including `postgres`) without a password.
- **Fix:** Change `trust` to `scram-sha-256` for all connections, or limit `trust` strictly to essential internal sockets if absolutely necessary.

### 3. Broad Network Exposure (Severity: Low)
- **Location:** `docker-compose.yml`
- **Exploit scenario:** Port `5432:5432` binds to all interfaces by default. If the host is exposed to the internet or an untrusted network, the database is exposed.
- **Fix:** Bind to localhost only: `127.0.0.1:5432:5432`, or use a VPN/firewall to restrict access.

## Observations
- Ensure that the `.env` file containing the actual secrets is never committed to version control.
- Consider dropping the `postgres` superuser privileges from the application if a dedicated application user can be created for standard CRUD operations.

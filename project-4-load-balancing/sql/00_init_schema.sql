-- Executed on Primary (HAProxy :5000 or directly on leader).
-- Simple bank account schema (used in replication and failover demo).
CREATE TABLE IF NOT EXISTS accounts (
  id      serial PRIMARY KEY,
  owner   text NOT NULL,
  balance numeric NOT NULL DEFAULT 0
);
INSERT INTO accounts(owner, balance) VALUES
  ('Ali', 1000), ('Veli', 2500), ('Ayse', 3700);
SELECT count(*) AS primary_rows FROM accounts;

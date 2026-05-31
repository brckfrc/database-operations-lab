-- Executed on Replica (HAProxy :5001 or directly on replica).
-- 1) Is the same data visible, 2) is the replica truly read-only.
SELECT count(*) AS replica_rows FROM accounts;
SELECT pg_is_in_recovery() AS is_replica;   -- true expected
-- The following line should FAIL on the replica (read-only transaction):
-- INSERT INTO accounts(owner,balance) VALUES('ShouldFail',0);

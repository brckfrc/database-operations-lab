-- Disaster B: Drop Critical Table (DDL)
-- Note current state
-- We'll create a restore point first so we can restore back to this exact moment.

SELECT pg_create_restore_point('before_disaster_b');

-- DROP table transactions
DROP TABLE transactions;

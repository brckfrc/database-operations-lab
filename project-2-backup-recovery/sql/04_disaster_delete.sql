-- Disaster A: Accidental Mass Deletion (DML)
-- Note current count
-- We'll create a restore point first so we can restore back to this exact moment.

SELECT pg_create_restore_point('before_disaster_a');

-- DELETE ALL transactions
DELETE FROM transactions;

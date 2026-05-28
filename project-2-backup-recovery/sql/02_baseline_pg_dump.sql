-- Baseline pg_dump demo - To be used to demonstrate pg_dump insufficiency
-- This script just inserts a specific record to show it gets lost if we restore an old dump.

INSERT INTO transactions (account_id, transaction_type, amount, transaction_date)
VALUES (1, 'deposit', 999999.99, CURRENT_TIMESTAMP);

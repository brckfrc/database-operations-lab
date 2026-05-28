-- Simulate workload (e.g. 5000 transactions for diff, 2000 for incr)
-- To be called with an argument or just random amount. Let's do a fixed insert block.
-- When called, it inserts 5000 records. You can run it multiple times.

INSERT INTO transactions (account_id, transaction_type, amount, transaction_date)
SELECT
    (random() * 14999 + 1)::integer,
    'deposit',
    random() * 100,
    CURRENT_TIMESTAMP
FROM generate_series(1, 5000);

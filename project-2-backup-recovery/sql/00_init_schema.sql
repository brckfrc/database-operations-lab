-- Initialize tables for bankdb
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    account_type VARCHAR(20) CHECK (account_type IN ('checking', 'savings')),
    balance DECIMAL(15,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES accounts(account_id),
    transaction_type VARCHAR(20) CHECK (transaction_type IN ('deposit', 'withdrawal', 'transfer')),
    amount DECIMAL(15,2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Generate synthetic data
-- Insert 10,000 customers
INSERT INTO customers (name)
SELECT 'Customer ' || generate_series(1, 10000);

-- Insert 15,000 accounts
INSERT INTO accounts (customer_id, account_type, balance)
SELECT
    (random() * 9999 + 1)::integer,
    CASE WHEN random() < 0.5 THEN 'checking' ELSE 'savings' END,
    random() * 10000
FROM generate_series(1, 15000);

-- Insert 500,000 transactions
INSERT INTO transactions (account_id, transaction_type, amount, transaction_date)
SELECT
    (random() * 14999 + 1)::integer,
    CASE
        WHEN random() < 0.4 THEN 'deposit'
        WHEN random() < 0.8 THEN 'withdrawal'
        ELSE 'transfer'
    END,
    random() * 500,
    CURRENT_TIMESTAMP - (random() * 365 || ' days')::interval
FROM generate_series(1, 500000);

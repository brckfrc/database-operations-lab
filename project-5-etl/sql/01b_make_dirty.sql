-- 01b_make_dirty.sql
-- Introduce intentional data issues and cross-source duplicates.

-- 1. Create Internal Duplicates in Customers
INSERT INTO stg_customers (index_val, customer_id, first_name, last_name, company, email, phone_1)
SELECT index_val, customer_id, first_name, last_name, company, email, phone_1
FROM stg_customers
LIMIT 3;

-- 2. Create Cross-Source Duplicates (Let's make some Leads have the same email as Customers)
-- We'll take the first 5 records in Customers and copy their emails over to some Leads.
WITH target_leads AS (
    SELECT account_id FROM stg_leads LIMIT 5
),
target_customers AS (
    SELECT email FROM stg_customers LIMIT 5
)
UPDATE stg_leads
SET email_1 = c.email
FROM (
    SELECT l.account_id, c.email
    FROM (SELECT account_id, row_number() over() as rn FROM target_leads) l
    JOIN (SELECT email, row_number() over() as rn FROM target_customers) c
    ON l.rn = c.rn
) c
WHERE stg_leads.account_id = c.account_id;

-- 3. Corrupt Emails (Invalid formats)
-- Customers without @
UPDATE stg_customers 
SET email = REPLACE(email, '@', '') 
WHERE MOD(CAST(index_val AS INTEGER), 15) = 0;

-- Leads with null emails
UPDATE stg_leads 
SET email_1 = NULL 
WHERE MOD(CAST(index_val AS INTEGER), 22) = 0;

-- 4. Formatting Issues (Casing)
UPDATE stg_customers SET first_name = UPPER(first_name) WHERE MOD(CAST(index_val AS INTEGER), 8) = 0;
UPDATE stg_leads SET last_name = LOWER(last_name) WHERE MOD(CAST(index_val AS INTEGER), 9) = 0;

-- 5. Add completely fake rows (Validation rejection candidates)
INSERT INTO stg_customers (index_val, customer_id, first_name, last_name, email)
VALUES ('998', 'FAKE001', 'Test', 'User', 'testuser@example.com');

INSERT INTO stg_leads (index_val, account_id, first_name, last_name, email_1)
VALUES ('999', 'FAKE002', 'Invalid', 'Data', 'invaliddata@example.com');

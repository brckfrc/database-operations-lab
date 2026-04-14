-- 01b_make_dirty.sql
-- Script to introduce intentional data quality issues to test the ETL pipeline.

-- 1. Create exact duplicates (5 records)
INSERT INTO customers_raw (index_val, customer_id, first_name, last_name, company, city, country, phone_1, phone_2, email, subscription_date, website)
SELECT index_val, customer_id, first_name, last_name, company, city, country, phone_1, phone_2, email, subscription_date, website
FROM customers_raw
LIMIT 5;

-- 2. Corrupt some emails (Remove @ symbol)
UPDATE customers_raw 
SET email = REPLACE(email, '@', '') 
WHERE MOD(CAST(index_val AS INTEGER), 15) = 0;

-- 3. Nullify some emails completely
UPDATE customers_raw 
SET email = NULL 
WHERE MOD(CAST(index_val AS INTEGER), 22) = 0;

-- 4. Inconsistent casing in names
-- Uppercase first names
UPDATE customers_raw 
SET first_name = UPPER(first_name) 
WHERE MOD(CAST(index_val AS INTEGER), 8) = 0;

-- Lowercase last names
UPDATE customers_raw 
SET last_name = LOWER(last_name) 
WHERE MOD(CAST(index_val AS INTEGER), 9) = 0;

-- 5. Bad phone extensions / formatting
-- Replace with completely fake or incomplete phone format
UPDATE customers_raw 
SET phone_1 = '0555-123' 
WHERE MOD(CAST(index_val AS INTEGER), 18) = 0;

UPDATE customers_raw 
SET phone_1 = '+90 (555) ' || FLOOR(RANDOM() * 900 + 100)::VARCHAR || ' 12 34' 
WHERE MOD(CAST(index_val AS INTEGER), 12) = 0;

-- 6. Add some completely blank / invalid rows (To be rejected later)
INSERT INTO customers_raw (index_val, customer_id, first_name, last_name)
VALUES 
('998', 'FAKE001', 'Test', 'User'),
('999', 'FAKE002', 'Invalid', 'Data');

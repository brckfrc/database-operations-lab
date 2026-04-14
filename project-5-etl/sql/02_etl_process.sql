-- 02_etl_process.sql
-- Performs the Extract, Transform, Load (ETL) operation from customers_raw

BEGIN;

-- 1. Insert Valid Records into customers_clean
-- Transformation Rules:
-- a. Deduplication: DISTINCT ON (customer_id)
-- b. Casing: INITCAP first_name, INITCAP last_name
-- c. Validations: Email must contain '@'
INSERT INTO customers_clean (customer_id, first_name, last_name, company, city, country, phone, email, subscription_date, website)
SELECT DISTINCT ON (customer_id) 
    customer_id,
    INITCAP(TRIM(first_name)) AS first_name,
    INITCAP(TRIM(last_name)) AS last_name,
    company,
    city,
    country,
    -- Simple phone normalization: if it has strange letters, we nullify it, else keep it
    CASE 
        WHEN phone_1 ~ '[a-zA-Z]' THEN NULL
        ELSE TRIM(phone_1)
    END AS phone,
    LOWER(TRIM(email)) AS email,
    CASE 
        -- If date is in wrong format (we created an error with dd-mm-yyyy instead of yyyy-mm-dd)
        WHEN subscription_date ~ '^\d{2}-\d{2}-\d{4}$' THEN TO_DATE(subscription_date, 'DD-MM-YYYY')
        ELSE CAST(subscription_date AS DATE)
    END AS subscription_date,
    website
FROM customers_raw
WHERE email LIKE '%@%'
  AND first_name NOT IN ('Test', 'Invalid')
  AND last_name NOT IN ('User', 'Data')
  AND customer_id IS NOT NULL;


-- 2. Insert Invalid Records into customers_rejected
INSERT INTO customers_rejected (customer_id, raw_data, rejection_reason)
SELECT 
    customer_id,
    row_to_json(customers_raw)::jsonb AS raw_data,
    CASE
        WHEN email NOT LIKE '%@%' OR email IS NULL THEN 'Missing or invalid email format'
        WHEN first_name IN ('Test', 'Invalid') OR last_name IN ('User', 'Data') THEN 'Fake/Test data detected'
        WHEN customer_id IS NULL THEN 'Missing Primary Identifier'
        ELSE 'Other data quality issue'
    END AS rejection_reason
FROM customers_raw
WHERE email NOT LIKE '%@%' 
   OR email IS NULL 
   OR first_name IN ('Test', 'Invalid')
   OR last_name IN ('User', 'Data')
   OR customer_id IS NULL;

COMMIT;

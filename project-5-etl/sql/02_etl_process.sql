-- 02_etl_process.sql
-- Multi-Source Extract, Transform, and Load script

BEGIN;

-- 1. Unify and standardize into a temporary table
CREATE TEMP TABLE temp_standardized AS
WITH unified_raw AS (
    -- Source A: Customers
    SELECT 
        'Customer' AS source_system,
        1 AS source_priority, -- Highest priority
        customer_id AS source_id,
        first_name,
        last_name,
        company,
        phone_1 AS phone,
        email,
        website,
        row_to_json(stg_customers)::jsonb AS raw_data
    FROM stg_customers
    WHERE customer_id IS NOT NULL
    
    UNION ALL

    -- Source B: Leads
    SELECT 
        'Lead' AS source_system,
        2 AS source_priority, -- Lower priority
        account_id AS source_id,
        first_name,
        last_name,
        company,
        phone_1 AS phone,
        email_1 AS email,
        website,
        row_to_json(stg_leads)::jsonb AS raw_data
    FROM stg_leads
    WHERE account_id IS NOT NULL
)
SELECT 
    source_system,
    source_priority,
    source_id,
    INITCAP(TRIM(first_name)) AS first_name,
    INITCAP(TRIM(last_name)) AS last_name,
    company,
    CASE WHEN phone ~ '[a-zA-Z]' THEN NULL ELSE TRIM(phone) END AS phone,
    LOWER(TRIM(email)) AS email,
    website,
    raw_data,
    CASE 
        WHEN LOWER(TRIM(email)) NOT LIKE '%@%' OR email IS NULL THEN FALSE
        WHEN first_name IN ('Test', 'Invalid') OR last_name IN ('User', 'Data') THEN FALSE
        ELSE TRUE
    END AS is_valid_record
FROM unified_raw;


-- 2. Create another temporary table for valid ranked data
CREATE TEMP TABLE temp_ranked_valid AS
SELECT 
    *,
    ROW_NUMBER() OVER (
        PARTITION BY email 
        ORDER BY source_priority ASC, source_id DESC
    ) AS rn
FROM temp_standardized
WHERE is_valid_record = TRUE;


-- 3. INSERT INTO TARGET TABLES

-- A. Load Clean Targets (rn = 1)
INSERT INTO crm_contacts_clean (source_system, source_id, first_name, last_name, company, phone, email, website)
SELECT source_system, source_id, first_name, last_name, company, phone, email, website
FROM temp_ranked_valid
WHERE rn = 1;

-- B. Load Suppressed Target (rn > 1) (e.g. Leads that had to yield to Customers)
INSERT INTO crm_contacts_duplicates (suppressed_source_system, suppressed_source_id, winning_source_system, normalized_email, raw_data)
SELECT 
    d.source_system, 
    d.source_id, 
    w.source_system, 
    d.email, 
    d.raw_data
FROM temp_ranked_valid d
JOIN temp_ranked_valid w ON d.email = w.email AND w.rn = 1
WHERE d.rn > 1;

-- C. Load Rejected Targets (is_valid_record = FALSE)
INSERT INTO crm_contacts_rejected (source_system, source_id, raw_data, rejection_reason)
SELECT 
    source_system, 
    source_id, 
    raw_data,
    CASE
        WHEN email NOT LIKE '%@%' OR email IS NULL THEN 'Missing or invalid email format'
        WHEN first_name IN ('Test', 'Invalid') OR last_name IN ('User', 'Data') THEN 'Fake/Test data detected'
        ELSE 'Other issue'
    END
FROM temp_standardized
WHERE is_valid_record = FALSE;

-- Cleanup temp tables
DROP TABLE temp_standardized;
DROP TABLE temp_ranked_valid;

COMMIT;

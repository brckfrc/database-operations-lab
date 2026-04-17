-- 00_init_schema.sql
-- Create necessary tables for the multi-source ETL process

-- 1. STAGING TABLE (RAW CUSTOMERS)
CREATE TABLE stg_customers (
    index_val VARCHAR,
    customer_id VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    company VARCHAR,
    city VARCHAR,
    country VARCHAR,
    phone_1 VARCHAR,
    phone_2 VARCHAR,
    email VARCHAR,
    subscription_date VARCHAR,
    website VARCHAR
);

-- 2. STAGING TABLE (RAW LEADS)
CREATE TABLE stg_leads (
    index_val VARCHAR,
    account_id VARCHAR,
    lead_owner VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    company VARCHAR,
    phone_1 VARCHAR,
    phone_2 VARCHAR,
    email_1 VARCHAR,
    email_2 VARCHAR,
    website VARCHAR,
    source VARCHAR,
    deal_stage VARCHAR,
    notes VARCHAR
);

-- 3. CLEAN TABLE (UNIFIED TARGET)
CREATE TABLE crm_contacts_clean (
    id SERIAL PRIMARY KEY,
    source_system VARCHAR(20) NOT NULL, -- 'Customer' or 'Lead'
    source_id VARCHAR(50) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    company VARCHAR(150),
    phone VARCHAR(50), 
    email VARCHAR(150) UNIQUE NOT NULL, -- Logical deduplication key
    website VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. DUPLICATES TABLE (SUPPRESSED LEADS)
CREATE TABLE crm_contacts_duplicates (
    id SERIAL PRIMARY KEY,
    suppressed_source_system VARCHAR(20),
    suppressed_source_id VARCHAR(50),
    winning_source_system VARCHAR(20),
    normalized_email VARCHAR(150),
    raw_data JSONB,
    suppressed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. REJECTED TABLE (QUARANTINE FOR INVALID DATA)
CREATE TABLE crm_contacts_rejected (
    id SERIAL PRIMARY KEY,
    source_system VARCHAR(20),
    source_id VARCHAR(50),
    raw_data JSONB,
    rejection_reason VARCHAR(255),
    rejected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

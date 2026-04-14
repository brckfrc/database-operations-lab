-- 00_init_schema.sql
-- Create necessary tables for the ETL process

-- 1. STAGING TABLE (RAW)
CREATE TABLE customers_raw (
    index_val VARCHAR, -- Using varchar for raw imports to catch any formatting issues
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

-- 2. CLEAN TABLE (TARGET)
CREATE TABLE customers_clean (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    company VARCHAR(150),
    city VARCHAR(100),
    country VARCHAR(100),
    phone VARCHAR(50), 
    email VARCHAR(150),
    subscription_date DATE,
    website VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. REJECTED TABLE (QUARANTINE)
CREATE TABLE customers_rejected (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR,
    raw_data JSONB, -- store the entire raw row for debugging
    rejection_reason VARCHAR(255),
    rejected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

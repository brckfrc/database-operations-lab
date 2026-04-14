-- 01a_import_seed.sql
-- Import data from the mounted CSV file into the staging table (customers_raw).

-- Using absolute path inside the container
COPY customers_raw (
    index_val, 
    customer_id, 
    first_name, 
    last_name, 
    company, 
    city, 
    country, 
    phone_1, 
    phone_2, 
    email, 
    subscription_date, 
    website
)
FROM '/data/source/customers_seed.csv'
DELIMITER ','
CSV HEADER;

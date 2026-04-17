-- 01a_import_seed.sql
-- Import data from the mounted CSV files into the staging tables

COPY stg_customers (
    index_val, customer_id, first_name, last_name, company, city, country, phone_1, phone_2, email, subscription_date, website
)
FROM '/data/source/customers_seed.csv'
DELIMITER ','
CSV HEADER;

COPY stg_leads (
    index_val, account_id, lead_owner, first_name, last_name, company, phone_1, phone_2, email_1, email_2, website, source, deal_stage, notes
)
FROM '/data/source/leads_seed.csv'
DELIMITER ','
CSV HEADER;

-- 03_quality_report.sql
-- Provides a data quality and integration report summarizing the multi-source ETL outcome

SELECT '1. [Staging] Total Raw Customers' AS metric, COUNT(*) AS count FROM stg_customers
UNION ALL
SELECT '1. [Staging] Total Raw Leads', COUNT(*) FROM stg_leads
UNION ALL
SELECT '2. [Target] Successfully Loaded (Clean & Unique)', COUNT(*) FROM crm_contacts_clean
UNION ALL
SELECT '3. [Suppressed] Deduplicated (Lead lost to Customer)', COUNT(*) FROM crm_contacts_duplicates
UNION ALL
SELECT '4. [Quarantine] Rejected for Bad Data Quality', COUNT(*) FROM crm_contacts_rejected
ORDER BY metric;

-- Show Duplicate Details
SELECT 'Duplicate details ->' as category, suppressed_source_system, winning_source_system, count(*) 
FROM crm_contacts_duplicates 
GROUP BY suppressed_source_system, winning_source_system;

-- Show Rejection Reasons
SELECT 'Rejection details ->' as category, source_system, rejection_reason, COUNT(*) as occurrence
FROM crm_contacts_rejected
GROUP BY source_system, rejection_reason
ORDER BY occurrence DESC;

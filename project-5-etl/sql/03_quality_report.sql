-- 03_quality_report.sql
-- Provides a summary of the data quality and the outcome of the ETL pipeline

SELECT 'Total Records in Staging (Raw)' AS metric, COUNT(*) AS count FROM customers_raw
UNION ALL
SELECT 'Successfully Cleaned & Loaded', COUNT(*) FROM customers_clean
UNION ALL
SELECT 'Rejected (Quarantined)', COUNT(*) FROM customers_rejected;

-- Show sample of rejected reasons
SELECT rejection_reason, COUNT(*) as occurrence
FROM customers_rejected
GROUP BY rejection_reason
ORDER BY occurrence DESC;

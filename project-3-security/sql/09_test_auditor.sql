-- =====================================================================
-- 09_test_auditor.sql
-- Execution user: auditor1 @ FREEPDB1 (auditor_role / AUDIT_VIEWER)
-- Expected: DENIED for patient data (segregation of duties) but audit trail READABLE.
-- =====================================================================
SET LINESIZE 160
SET PAGESIZE 50

PROMPT === [EXPECTED: DENIED] auditor1 -> patient data ===
SELECT * FROM hospital_app.patients WHERE ROWNUM <= 1;

PROMPT === [EXPECTED: SUCCESS] auditor1 -> audit trail access ===
SELECT COUNT(*) AS audit_kayit_sayisi
FROM   unified_audit_trail
WHERE  object_schema = 'HOSPITAL_APP';

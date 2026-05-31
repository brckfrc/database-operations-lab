-- =====================================================================
-- 07_test_reception.sql
-- Execution user: reception1 @ FREEPDB1 (most restricted role)
-- Expected: DENIED to medical/sensitive tables, access only to masked view.
-- NOTE: Expected DENIALS (ORA-00942) are NOT ERRORS, they serve as proof.
-- =====================================================================
SET LINESIZE 160
SET PAGESIZE 50

PROMPT === [EXPECTED: DENIED] reception1 -> medical_records ===
SELECT * FROM hospital_app.medical_records WHERE ROWNUM <= 1;

PROMPT === [EXPECTED: DENIED] reception1 -> patients (main table) ===
SELECT * FROM hospital_app.patients WHERE ROWNUM <= 1;

PROMPT === [EXPECTED: MASKED] reception1 -> v_patients_masked ===
SELECT * FROM hospital_app.v_patients_masked WHERE ROWNUM <= 5;

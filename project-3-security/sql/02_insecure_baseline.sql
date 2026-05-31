-- =====================================================================
-- 02_insecure_baseline.sql
-- Execution user: hospital_app @ FREEPDB1
-- Purpose: show INSECURE baseline state (before proof).
--   1) National ID PLAIN TEXT -> readable by anyone
--   2) Sensitive medical data is exposed
--   3) No role separation, no encryption, audit disabled
-- =====================================================================

SET LINESIZE 160
SET PAGESIZE 50

PROMPT === [INSECURE] National ID readable as PLAIN TEXT ===
SELECT patient_id, full_name, national_id, phone
FROM   patients
WHERE  ROWNUM <= 5;

PROMPT === [INSECURE] Sensitive medical data (diagnosis/treatment) exposed ===
SELECT r.record_id, p.full_name, r.diagnosis, r.treatment
FROM   medical_records r
JOIN   patients p ON p.patient_id = r.patient_id
WHERE  ROWNUM <= 5;

PROMPT === [INSECURE] national_id is a plain text column (not encrypted) ===
SELECT column_name, data_type, data_length
FROM   user_tab_columns
WHERE  table_name = 'PATIENTS' AND column_name = 'NATIONAL_ID';

PROMPT >>> Status: no roles, no encryption, audit disabled. (Will be fixed in Parts 1-4)

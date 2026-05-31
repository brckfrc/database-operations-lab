-- =====================================================================
-- 08_test_doctor.sql
-- Execution user: dr_house @ FREEPDB1 (doctor_role)
-- Expected: access to patient table + decryption of national ID.
-- =====================================================================
SET LINESIZE 160
SET PAGESIZE 50

PROMPT === [EXPECTED: FULL ID] dr_house -> decrypted national ID ===
SELECT patient_id, hospital_app.fn_decrypt_nid(national_id_enc) AS tc
FROM   hospital_app.patients
WHERE  ROWNUM <= 5;

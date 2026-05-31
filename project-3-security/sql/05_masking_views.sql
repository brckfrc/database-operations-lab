-- =====================================================================
-- 05_masking_views.sql
-- Execution user: hospital_app @ FREEPDB1
-- Purpose: MASKED view + column restriction for low-privileged user.
--   - v_patients_masked: ID -> XXX-XX-1234, phone partially hidden,
--     excluding sensitive medical fields.
--   - Receptionist ONLY sees this view (no access to main table).
--   NOTE: View operates with definer-rights; owner of fn_decrypt_nid
--        is hospital_app, the receptionist does not need EXECUTE privilege
--        -> only the masked result is returned.
-- =====================================================================

CREATE OR REPLACE VIEW v_patients_masked AS
SELECT patient_id,
       full_name,
       'XXX-XX-' || SUBSTR(fn_decrypt_nid(national_id_enc), -4)        AS national_id_masked,
       SUBSTR(phone,1,4) || '****' || SUBSTR(phone,-2)                 AS phone_masked,
       blood_type
FROM   patients;

-- Receptionist only sees the masked view
GRANT SELECT ON v_patients_masked TO receptionist_role;

SET LINESIZE 160
PROMPT === Masked view (what the receptionist sees) ===
SELECT * FROM v_patients_masked WHERE ROWNUM <= 5;

PROMPT >>> Masking view ready; receptionist cannot see main table.

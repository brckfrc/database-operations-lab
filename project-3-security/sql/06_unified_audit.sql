-- =====================================================================
-- 06_unified_audit.sql
-- Execution user: SYSTEM (admin) @ FREEPDB1
-- Purpose: Audit access to sensitive tables using Unified Auditing.
--   - pol_patient_access: monitors SELECT/UPDATE/DELETE
--     actions on patients + medical_records.
--   NOTE: Audit records are written to a queue; before querying
--        Flushed with DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL (in 07).
-- =====================================================================

-- Cleanup (re-runnability)
BEGIN EXECUTE IMMEDIATE 'NOAUDIT POLICY pol_patient_access';     EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP AUDIT POLICY pol_patient_access';  EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE AUDIT POLICY pol_patient_access
  ACTIONS
    SELECT ON hospital_app.patients,
    UPDATE ON hospital_app.patients,
    DELETE ON hospital_app.patients,
    SELECT ON hospital_app.medical_records,
    UPDATE ON hospital_app.medical_records,
    DELETE ON hospital_app.medical_records;

AUDIT POLICY pol_patient_access;

PROMPT === Active audit policies ===
SELECT policy_name, enabled_option
FROM   audit_unified_enabled_policies
WHERE  policy_name = 'POL_PATIENT_ACCESS';

PROMPT >>> Unified Audit policy active.

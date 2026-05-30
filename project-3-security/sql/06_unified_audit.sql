-- =====================================================================
-- 06_unified_audit.sql
-- Calistirma kullanicisi: SYSTEM (admin)  @ FREEPDB1
-- Amac: Unified Auditing ile hassas tablolara erisimi denetlemek.
--   - pol_patient_access: patients + medical_records uzerinde
--     SELECT/UPDATE/DELETE eylemlerini izler.
--   NOT: Audit kayitlari kuyruga yazilir; sorgulamadan once
--        DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL ile bosaltilir (07'de).
-- =====================================================================

-- Temizlik (tekrar calistirilabilirlik)
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

PROMPT === Aktif audit politikalari ===
SELECT policy_name, enabled_option
FROM   audit_unified_enabled_policies
WHERE  policy_name = 'POL_PATIENT_ACCESS';

PROMPT >>> Unified Audit politikasi aktif.

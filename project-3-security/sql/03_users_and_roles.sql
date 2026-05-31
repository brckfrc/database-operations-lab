-- =====================================================================
-- 03_users_and_roles.sql
-- Execution user: SYSTEM (admin) @ FREEPDB1
-- Purpose: Roles + users + least privilege.
--   Roles: doctor_role / nurse_role / receptionist_role / auditor_role
--   NOTE: Oracle DOES NOT SUPPORT column-based SELECT grants -> column restriction
--        Done via VIEW (see 05_masking_views.sql).
-- =====================================================================

-- ---- Temizlik (tekrar calistirilabilirlik) ----
BEGIN
  FOR u IN (SELECT username FROM dba_users
            WHERE username IN ('DR_HOUSE','NURSE_JOY','RECEPTION1','AUDITOR1')) LOOP
    EXECUTE IMMEDIATE 'DROP USER '||u.username||' CASCADE';
  END LOOP;
END;
/
BEGIN
  FOR r IN (SELECT role FROM dba_roles
            WHERE role IN ('DOCTOR_ROLE','NURSE_ROLE','RECEPTIONIST_ROLE','AUDITOR_ROLE')) LOOP
    EXECUTE IMMEDIATE 'DROP ROLE '||r.role;
  END LOOP;
END;
/

-- ---- Roles ----
CREATE ROLE doctor_role;
CREATE ROLE nurse_role;
CREATE ROLE receptionist_role;
CREATE ROLE auditor_role;

-- ---- Table-based privileges (SYSTEM, with DBA privilege, can grant to another schema) ----
-- Doctor: full access to patients + medical records, read access to appointments
GRANT SELECT, INSERT, UPDATE ON hospital_app.patients        TO doctor_role;
GRANT SELECT, INSERT, UPDATE ON hospital_app.medical_records TO doctor_role;
GRANT SELECT                 ON hospital_app.appointments     TO doctor_role;

-- Nurse: read access to patients, manage appointments, read medical records
GRANT SELECT                 ON hospital_app.patients         TO nurse_role;
GRANT SELECT, INSERT, UPDATE ON hospital_app.appointments     TO nurse_role;
GRANT SELECT                 ON hospital_app.medical_records  TO nurse_role;

-- Receptionist: ONLY appointments; NO access to patient table (masked view given in 05)
GRANT SELECT, INSERT, UPDATE ON hospital_app.appointments     TO receptionist_role;

-- Auditor: NO access to patient data; only audit trail (segregation of duties)
GRANT AUDIT_VIEWER TO auditor_role;

-- ---- Users ----
CREATE USER dr_house   IDENTIFIED BY "DrHouse#2026";
CREATE USER nurse_joy  IDENTIFIED BY "NurseJoy#2026";
CREATE USER reception1 IDENTIFIED BY "Recept1#2026";
CREATE USER auditor1   IDENTIFIED BY "Auditor1#2026";

GRANT CREATE SESSION TO dr_house, nurse_joy, reception1, auditor1;

GRANT doctor_role       TO dr_house;
GRANT nurse_role        TO nurse_joy;
GRANT receptionist_role TO reception1;
GRANT auditor_role      TO auditor1;

PROMPT >>> Roles and users created (least privilege principle).

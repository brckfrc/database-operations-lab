-- =====================================================================
-- 00_admin_setup.sql
-- Execution user: SYS as SYSDBA @ FREEPDB1
--   (NOTE: SYS packages -> DBMS_CRYPTO / DBMS_AUDIT_MGMT privileges
--    cannot be granted by SYSTEM in Oracle 23ai; SYS is required.)
-- Purpose: grant required system/package privileges to hospital_app schema.
--   - DBMS_CRYPTO : column encryption (Part 2)
--   - CREATE VIEW : masking view (does not grant RESOURCE role)
-- Execution:
--   ./scripts/run_sql.sh 'sys/"Admin#2026pass"@localhost:1521/FREEPDB1 as sysdba' sql/00_admin_setup.sql
-- =====================================================================

GRANT EXECUTE ON DBMS_CRYPTO      TO hospital_app;
GRANT CREATE VIEW                 TO hospital_app;
GRANT UNLIMITED TABLESPACE        TO hospital_app;

PROMPT >>> Admin setup complete: DBMS_CRYPTO + CREATE VIEW privileges granted (hospital_app).

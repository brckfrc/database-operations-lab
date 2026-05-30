-- =====================================================================
-- 00_admin_setup.sql
-- Calistirma kullanicisi: SYS as SYSDBA  @ FREEPDB1
--   (NOT: SYS paketleri -> DBMS_CRYPTO / DBMS_AUDIT_MGMT yetkileri
--    Oracle 23ai'de SYSTEM tarafindan verilemez; SYS gerekir.)
-- Amac: hospital_app semasina gerekli sistem/paket yetkilerini ver.
--   - DBMS_CRYPTO : kolon sifreleme (Bolum 2)
--   - CREATE VIEW : maskeleme view'i (RESOURCE rolu vermez)
-- Calistirma:
--   ./scripts/run_sql.sh 'sys/"Admin#2026pass"@localhost:1521/FREEPDB1 as sysdba' sql/00_admin_setup.sql
-- =====================================================================

GRANT EXECUTE ON DBMS_CRYPTO      TO hospital_app;
GRANT CREATE VIEW                 TO hospital_app;
GRANT UNLIMITED TABLESPACE        TO hospital_app;

PROMPT >>> Admin setup tamam: DBMS_CRYPTO + CREATE VIEW yetkileri verildi (hospital_app).

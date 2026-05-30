-- =====================================================================
-- 09_test_auditor.sql
-- Calistirma kullanicisi: auditor1  @ FREEPDB1  (auditor_role / AUDIT_VIEWER)
-- Beklenen: hasta verisine RED (gorevler ayriligi) ama audit trail OKUNUR.
-- =====================================================================
SET LINESIZE 160
SET PAGESIZE 50

PROMPT === [BEKLENEN: RED] auditor1 -> hasta verisi ===
SELECT * FROM hospital_app.patients WHERE ROWNUM <= 1;

PROMPT === [BEKLENEN: BASARILI] auditor1 -> audit trail erisimi ===
SELECT COUNT(*) AS audit_kayit_sayisi
FROM   unified_audit_trail
WHERE  object_schema = 'HOSPITAL_APP';

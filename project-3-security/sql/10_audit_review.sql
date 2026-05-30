-- =====================================================================
-- 10_audit_review.sql
-- Calistirma kullanicisi: SYSTEM (admin)  @ FREEPDB1
-- Amac: 07-09 testlerindeki erisimleri unified audit trail'den gostermek.
-- NOT: Oracle 23ai unified audit kayitlari pratikte aninda gorunur,
--      manuel flush gerekmez (eski surumlerde DBMS_AUDIT_MGMT.FLUSH...
--      cagrilirdi; 23ai'de gerek yok).
-- =====================================================================
SET LINESIZE 160
SET PAGESIZE 50

PROMPT === Audit trail: kim / ne zaman / neye / sonuc ===
PROMPT     (return_code: 0 = basarili erisim, <>0 = engellendi/hata)
SELECT TO_CHAR(event_timestamp,'HH24:MI:SS') AS zaman,
       dbusername, action_name, object_name, return_code
FROM   unified_audit_trail
WHERE  object_schema = 'HOSPITAL_APP'
ORDER  BY event_timestamp DESC
FETCH FIRST 20 ROWS ONLY;

PROMPT >>> Audit incelemesi tamam. (rc=0 dr_house basarili; rc<>0 reception1/auditor1 engellendi)

-- =====================================================================
-- 10_audit_review.sql
-- Execution user: SYSTEM (admin) @ FREEPDB1
-- Purpose: show accesses from tests 07-09 in the unified audit trail.
-- NOTE: Oracle 23ai unified audit records appear practically instantly,
--      manual flush is not needed (in older versions DBMS_AUDIT_MGMT.FLUSH...
--      would be called; not needed in 23ai).
-- =====================================================================
SET LINESIZE 160
SET PAGESIZE 50

PROMPT === Audit trail: who / when / what / result ===
PROMPT     (return_code: 0 = successful access, <>0 = denied/error)
SELECT TO_CHAR(event_timestamp,'HH24:MI:SS') AS zaman,
       dbusername, action_name, object_name, return_code
FROM   unified_audit_trail
WHERE  object_schema = 'HOSPITAL_APP'
ORDER  BY event_timestamp DESC
FETCH FIRST 20 ROWS ONLY;

PROMPT >>> Audit review complete. (rc=0 dr_house successful; rc<>0 reception1/auditor1 denied)

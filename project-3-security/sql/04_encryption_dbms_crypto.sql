-- =====================================================================
-- 04_encryption_dbms_crypto.sql
-- Execution user: hospital_app @ FREEPDB1
-- Purpose: Column-based AES-256 encryption for national_id.
--   - fn_encrypt_nid / fn_decrypt_nid functions (DBMS_CRYPTO)
--   - plain text column dropped, national_id_enc RAW remains
--   NOTE: Key is hardcoded in function for demo; in a real system
--        Oracle Wallet/keystore is used.
-- =====================================================================

-- Add encrypted column (drop first if exists -> re-runnability)
DECLARE
  l_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_tab_columns
  WHERE table_name='PATIENTS' AND column_name='NATIONAL_ID_ENC';
  IF l_cnt = 0 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE patients ADD (national_id_enc RAW(2000))';
  END IF;
END;
/

CREATE OR REPLACE FUNCTION fn_encrypt_nid(p_text VARCHAR2) RETURN RAW IS
  l_key RAW(32)      := UTL_RAW.CAST_TO_RAW('0123456789abcdef0123456789abcdef'); -- 32 byte (demo)
  l_typ PLS_INTEGER  := DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;
BEGIN
  IF p_text IS NULL THEN RETURN NULL; END IF;
  RETURN DBMS_CRYPTO.ENCRYPT(UTL_RAW.CAST_TO_RAW(p_text), l_typ, l_key);
END;
/

CREATE OR REPLACE FUNCTION fn_decrypt_nid(p_raw RAW) RETURN VARCHAR2 IS
  l_key RAW(32)      := UTL_RAW.CAST_TO_RAW('0123456789abcdef0123456789abcdef');
  l_typ PLS_INTEGER  := DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;
BEGIN
  IF p_raw IS NULL THEN RETURN NULL; END IF;
  RETURN UTL_RAW.CAST_TO_VARCHAR2(DBMS_CRYPTO.DECRYPT(p_raw, l_typ, l_key));
END;
/

-- Encrypt existing national IDs, clear plain text
UPDATE patients SET national_id_enc = fn_encrypt_nid(national_id);
COMMIT;

-- Drop plain text column (only encrypted version is stored now)
DECLARE
  l_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_cnt FROM user_tab_columns
  WHERE table_name='PATIENTS' AND column_name='NATIONAL_ID';
  IF l_cnt > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE patients DROP COLUMN national_id';
  END IF;
END;
/

-- Grant decrypt privilege only to doctor role
GRANT EXECUTE ON fn_decrypt_nid TO doctor_role;

SET LINESIZE 160
PROMPT === Encrypted column raw state (meaningless RAW) ===
SELECT patient_id, national_id_enc FROM patients WHERE ROWNUM <= 3;

PROMPT === Authorized decryption (fn_decrypt_nid) ===
SELECT patient_id, fn_decrypt_nid(national_id_enc) AS tc FROM patients WHERE ROWNUM <= 3;

PROMPT >>> national_id is now encrypted with AES-256.

-- =====================================================================
-- 04_encryption_dbms_crypto.sql
-- Calistirma kullanicisi: hospital_app  @ FREEPDB1
-- Amac: TC kimligi (national_id) AES-256 ile kolon bazli sifrelemek.
--   - fn_encrypt_nid / fn_decrypt_nid fonksiyonlari (DBMS_CRYPTO)
--   - duz metin kolon dusurulur, yerine national_id_enc RAW kalir
--   NOT: Anahtar demo amacli fonksiyon icinde sabittir; gercek sistemde
--        Oracle Wallet/keystore kullanilir.
-- =====================================================================

-- Sifreli kolonu ekle (varsa once dusur -> tekrar calistirilabilirlik)
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

-- Mevcut TC'leri sifrele, duz metni temizle
UPDATE patients SET national_id_enc = fn_encrypt_nid(national_id);
COMMIT;

-- Duz metin kolonu dusur (artik sadece sifreli sürum saklanir)
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

-- Cozme yetkisini sadece doktor roluna ver
GRANT EXECUTE ON fn_decrypt_nid TO doctor_role;

SET LINESIZE 160
PROMPT === Sifreli kolon ham hali (anlamsiz RAW) ===
SELECT patient_id, national_id_enc FROM patients WHERE ROWNUM <= 3;

PROMPT === Yetkili cozum (fn_decrypt_nid) ===
SELECT patient_id, fn_decrypt_nid(national_id_enc) AS tc FROM patients WHERE ROWNUM <= 3;

PROMPT >>> national_id artik AES-256 ile sifreli.

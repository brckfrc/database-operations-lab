-- =====================================================================
-- 05_masking_views.sql
-- Calistirma kullanicisi: hospital_app  @ FREEPDB1
-- Amac: Dusuk yetkili kullaniciya MASKELI gorunum + kolon kisitlamasi.
--   - v_patients_masked: TC -> XXX-XX-1234, telefon kismen gizli,
--     hassas tibbi alanlar haric.
--   - Resepsiyonist SADECE bu view'i gorur (ana tabloya erisimi yok).
--   NOT: View definer-rights ile calisir; fn_decrypt_nid sahibi
--        hospital_app oldugundan resepsiyonistin EXECUTE yetkisine
--        gerek yoktur -> sadece maskeli sonuc disari cikar.
-- =====================================================================

CREATE OR REPLACE VIEW v_patients_masked AS
SELECT patient_id,
       full_name,
       'XXX-XX-' || SUBSTR(fn_decrypt_nid(national_id_enc), -4)        AS national_id_masked,
       SUBSTR(phone,1,4) || '****' || SUBSTR(phone,-2)                 AS phone_masked,
       blood_type
FROM   patients;

-- Resepsiyonist sadece maskeli view'i gorur
GRANT SELECT ON v_patients_masked TO receptionist_role;

SET LINESIZE 160
PROMPT === Maskeli gorunum (resepsiyonistin gorecegi) ===
SELECT * FROM v_patients_masked WHERE ROWNUM <= 5;

PROMPT >>> Maskeleme view'i hazir; resepsiyonist ana tabloyu goremez.

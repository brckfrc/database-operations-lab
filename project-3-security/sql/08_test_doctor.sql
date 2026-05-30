-- =====================================================================
-- 08_test_doctor.sql
-- Calistirma kullanicisi: dr_house  @ FREEPDB1  (doctor_role)
-- Beklenen: hasta tablosuna erisim + TC'nin sifresinin cozulmesi.
-- =====================================================================
SET LINESIZE 160
SET PAGESIZE 50

PROMPT === [BEKLENEN: TAM TC] dr_house -> sifre cozulmus TC ===
SELECT patient_id, hospital_app.fn_decrypt_nid(national_id_enc) AS tc
FROM   hospital_app.patients
WHERE  ROWNUM <= 5;

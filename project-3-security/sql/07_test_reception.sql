-- =====================================================================
-- 07_test_reception.sql
-- Calistirma kullanicisi: reception1  @ FREEPDB1  (en kisitli rol)
-- Beklenen: tibbi/hassas tablolara RED, sadece maskeli view'e erisim.
-- NOT: Beklenen RED'ler (ORA-00942) HATA DEGIL, kanit niteligindedir.
-- =====================================================================
SET LINESIZE 160
SET PAGESIZE 50

PROMPT === [BEKLENEN: RED] reception1 -> medical_records ===
SELECT * FROM hospital_app.medical_records WHERE ROWNUM <= 1;

PROMPT === [BEKLENEN: RED] reception1 -> patients (ana tablo) ===
SELECT * FROM hospital_app.patients WHERE ROWNUM <= 1;

PROMPT === [BEKLENEN: MASKELI] reception1 -> v_patients_masked ===
SELECT * FROM hospital_app.v_patients_masked WHERE ROWNUM <= 5;

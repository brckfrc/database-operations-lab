-- =====================================================================
-- 02_insecure_baseline.sql
-- Calistirma kullanicisi: hospital_app  @ FREEPDB1
-- Amac: GUVENSIZ baslangic durumunu gostermek (before kaniti).
--   1) TC kimlik DUZ METIN -> okuyan herkes gorur
--   2) Hassas tibbi veri acik
--   3) Rol ayrimi yok, sifreleme yok, audit kapali
-- =====================================================================

SET LINESIZE 160
SET PAGESIZE 50

PROMPT === [GUVENSIZ] TC kimlik DUZ METIN olarak okunabiliyor ===
SELECT patient_id, full_name, national_id, phone
FROM   patients
WHERE  ROWNUM <= 5;

PROMPT === [GUVENSIZ] Hassas tibbi veri (tani/tedavi) acik ===
SELECT r.record_id, p.full_name, r.diagnosis, r.treatment
FROM   medical_records r
JOIN   patients p ON p.patient_id = r.patient_id
WHERE  ROWNUM <= 5;

PROMPT === [GUVENSIZ] national_id duz metin bir kolon (sifreli degil) ===
SELECT column_name, data_type, data_length
FROM   user_tab_columns
WHERE  table_name = 'PATIENTS' AND column_name = 'NATIONAL_ID';

PROMPT >>> Durum: rol yok, sifreleme yok, audit kapali. (Bolum 1-4'te kapatilacak)

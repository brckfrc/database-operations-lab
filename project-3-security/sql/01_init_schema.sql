-- =====================================================================
-- 01_init_schema.sql
-- Execution user: hospital_app @ FREEPDB1
-- Purpose: Hospital schema + synthetic data (reproducible).
--   Tables: doctors, patients, medical_records, appointments
--   Sensitive fields: patients.national_id (ID), phone, address;
--                   medical_records.diagnosis, treatment
-- =====================================================================

-- Drop previous tables for re-runnability
BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN ('APPOINTMENTS','MEDICAL_RECORDS','PATIENTS','DOCTORS')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE '||t.table_name||' CASCADE CONSTRAINTS';
  END LOOP;
END;
/

CREATE TABLE doctors (
  doctor_id   NUMBER         PRIMARY KEY,
  full_name   VARCHAR2(100)  NOT NULL,
  specialty   VARCHAR2(50)
);

CREATE TABLE patients (
  patient_id   NUMBER        PRIMARY KEY,
  full_name    VARCHAR2(120) NOT NULL,
  national_id  VARCHAR2(11)  NOT NULL,   -- National ID (PLAIN TEXT initially)
  birth_date   DATE,
  blood_type   VARCHAR2(3),
  phone        VARCHAR2(15),
  address      VARCHAR2(200),
  created_at   DATE DEFAULT SYSDATE
);

CREATE TABLE medical_records (
  record_id   NUMBER        PRIMARY KEY,
  patient_id  NUMBER        NOT NULL REFERENCES patients(patient_id),
  doctor_id   NUMBER        NOT NULL REFERENCES doctors(doctor_id),
  visit_date  DATE,
  diagnosis   VARCHAR2(100),
  treatment   VARCHAR2(200)
);

CREATE TABLE appointments (
  appointment_id  NUMBER       PRIMARY KEY,
  patient_id      NUMBER       NOT NULL REFERENCES patients(patient_id),
  doctor_id       NUMBER       NOT NULL REFERENCES doctors(doctor_id),
  appt_date       DATE,
  status          VARCHAR2(20),
  notes           VARCHAR2(200)
);

-- ---- Doktorlar (50) ----
INSERT INTO doctors (doctor_id, full_name, specialty)
SELECT level,
       'Dr. ' || INITCAP(DBMS_RANDOM.STRING('L',5)) || ' ' || INITCAP(DBMS_RANDOM.STRING('L',7)),
       CASE MOD(level,6)
         WHEN 0 THEN 'Kardiyoloji' WHEN 1 THEN 'Noroloji'  WHEN 2 THEN 'Dahiliye'
         WHEN 3 THEN 'Ortopedi'    WHEN 4 THEN 'Pediatri'  ELSE 'Genel Cerrahi'
       END
FROM dual CONNECT BY level <= 50;

-- ---- Patients (1000) ----
INSERT INTO patients (patient_id, full_name, national_id, birth_date, blood_type, phone, address)
SELECT level,
       INITCAP(DBMS_RANDOM.STRING('L',6)) || ' ' || INITCAP(DBMS_RANDOM.STRING('L',8)),
       TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(10000000000, 99999999999)), 'FM99999999999'),
       DATE '1950-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 27000)),
       CASE MOD(level,8)
         WHEN 0 THEN 'A+' WHEN 1 THEN 'A-' WHEN 2 THEN 'B+' WHEN 3 THEN 'B-'
         WHEN 4 THEN '0+' WHEN 5 THEN '0-' WHEN 6 THEN 'AB+' ELSE 'AB-'
       END,
       '05' || TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(100000000, 999999999)), 'FM999999999'),
       'Mahalle ' || TRUNC(DBMS_RANDOM.VALUE(1,99)) || ' Sokak No:' || TRUNC(DBMS_RANDOM.VALUE(1,200))
FROM dual CONNECT BY level <= 1000;

-- ---- Tibbi kayitlar (5000) ----
INSERT INTO medical_records (record_id, patient_id, doctor_id, visit_date, diagnosis, treatment)
SELECT level,
       TRUNC(DBMS_RANDOM.VALUE(1, 1001)),
       TRUNC(DBMS_RANDOM.VALUE(1, 51)),
       DATE '2023-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 900)),
       CASE MOD(level,8)
         WHEN 0 THEN 'Hipertansiyon' WHEN 1 THEN 'Diyabet' WHEN 2 THEN 'Migren' WHEN 3 THEN 'Bronsit'
         WHEN 4 THEN 'Anemi'         WHEN 5 THEN 'Gastrit' WHEN 6 THEN 'Astim'  ELSE 'Grip'
       END,
       CASE MOD(level,8)
         WHEN 0 THEN 'Beta bloker' WHEN 1 THEN 'Insulin' WHEN 2 THEN 'Analjezik' WHEN 3 THEN 'Antibiyotik'
         WHEN 4 THEN 'Demir takviyesi' WHEN 5 THEN 'Antasit' WHEN 6 THEN 'Inhaler' ELSE 'Istirahat'
       END
FROM dual CONNECT BY level <= 5000;

-- ---- Appointments (5000) ----
INSERT INTO appointments (appointment_id, patient_id, doctor_id, appt_date, status, notes)
SELECT level,
       TRUNC(DBMS_RANDOM.VALUE(1, 1001)),
       TRUNC(DBMS_RANDOM.VALUE(1, 51)),
       DATE '2026-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 180)),
       CASE MOD(level,3) WHEN 0 THEN 'Planlandi' WHEN 1 THEN 'Tamamlandi' ELSE 'Iptal' END,
       'Kontrol randevusu #' || level
FROM dual CONNECT BY level <= 5000;

COMMIT;

PROMPT >>> Schema + data loaded:
SELECT 'doctors'        AS tablo, COUNT(*) AS adet FROM doctors
UNION ALL SELECT 'patients',        COUNT(*) FROM patients
UNION ALL SELECT 'medical_records', COUNT(*) FROM medical_records
UNION ALL SELECT 'appointments',    COUNT(*) FROM appointments;

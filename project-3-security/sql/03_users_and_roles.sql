-- =====================================================================
-- 03_users_and_roles.sql
-- Calistirma kullanicisi: SYSTEM (admin)  @ FREEPDB1
-- Amac: Roller + kullanicilar + en az yetki (least privilege).
--   Roller: doctor_role / nurse_role / receptionist_role / auditor_role
--   NOT: Oracle kolon-bazli SELECT grant DESTEKLEMEZ -> kolon kisitlamasi
--        VIEW ile yapilir (bkz. 05_masking_views.sql).
-- =====================================================================

-- ---- Temizlik (tekrar calistirilabilirlik) ----
BEGIN
  FOR u IN (SELECT username FROM dba_users
            WHERE username IN ('DR_HOUSE','NURSE_JOY','RECEPTION1','AUDITOR1')) LOOP
    EXECUTE IMMEDIATE 'DROP USER '||u.username||' CASCADE';
  END LOOP;
END;
/
BEGIN
  FOR r IN (SELECT role FROM dba_roles
            WHERE role IN ('DOCTOR_ROLE','NURSE_ROLE','RECEPTIONIST_ROLE','AUDITOR_ROLE')) LOOP
    EXECUTE IMMEDIATE 'DROP ROLE '||r.role;
  END LOOP;
END;
/

-- ---- Roller ----
CREATE ROLE doctor_role;
CREATE ROLE nurse_role;
CREATE ROLE receptionist_role;
CREATE ROLE auditor_role;

-- ---- Tablo bazli yetkiler (SYSTEM, DBA yetkisiyle baska semaya grant verebilir) ----
-- Doktor: hasta + tibbi kayit tam erisim, randevu okuma
GRANT SELECT, INSERT, UPDATE ON hospital_app.patients        TO doctor_role;
GRANT SELECT, INSERT, UPDATE ON hospital_app.medical_records TO doctor_role;
GRANT SELECT                 ON hospital_app.appointments     TO doctor_role;

-- Hemsire: hasta okuma, randevu yonetimi, tibbi kayit okuma
GRANT SELECT                 ON hospital_app.patients         TO nurse_role;
GRANT SELECT, INSERT, UPDATE ON hospital_app.appointments     TO nurse_role;
GRANT SELECT                 ON hospital_app.medical_records  TO nurse_role;

-- Resepsiyonist: SADECE randevu; hasta tablosuna erisim YOK (maskeli view 05'te verilir)
GRANT SELECT, INSERT, UPDATE ON hospital_app.appointments     TO receptionist_role;

-- Denetci: hasta verisine erisim YOK; sadece audit trail (gorevler ayriligi)
GRANT AUDIT_VIEWER TO auditor_role;

-- ---- Kullanicilar ----
CREATE USER dr_house   IDENTIFIED BY "DrHouse#2026";
CREATE USER nurse_joy  IDENTIFIED BY "NurseJoy#2026";
CREATE USER reception1 IDENTIFIED BY "Recept1#2026";
CREATE USER auditor1   IDENTIFIED BY "Auditor1#2026";

GRANT CREATE SESSION TO dr_house, nurse_joy, reception1, auditor1;

GRANT doctor_role       TO dr_house;
GRANT nurse_role        TO nurse_joy;
GRANT receptionist_role TO reception1;
GRANT auditor_role      TO auditor1;

PROMPT >>> Roller ve kullanicilar olusturuldu (en az yetki prensibi).

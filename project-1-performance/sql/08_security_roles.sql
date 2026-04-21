-- =========================================================================
-- 8) ROLE AND PRIVILEGE MANAGEMENT (GÜVENLİK VE YETKİLENDİRME)
-- =========================================================================

-- 1. Yalnızca Okuma (Raporlama) Yapabilecek Özel Bir Rol Oluşturulması
-- (Pazarlama ve Raporlama ekiplerinin yanlışlıkla veri bozmasını engellemek için)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'report_reader' AND type = 'R')
BEGIN
    CREATE ROLE report_reader;
    PRINT 'Rol başarıyla oluşturuldu: report_reader';
END
GO

-- 2. İlgili Yetkilerin Tanımlanması (Grant)
-- Sadece okunması gereken tablolara SELECT yetkisi veriyoruz
GRANT SELECT ON customers TO report_reader;
GRANT SELECT ON orders TO report_reader;
GRANT SELECT ON products TO report_reader;

-- 3. Tehlikeli Yetkilerin Açıkça Reddedilmesi (Deny)
-- Bu rol kesinlikle sisteme veri ekleyemez, silemez veya güncelleyemez
DENY INSERT, UPDATE, DELETE ON orders TO report_reader;
DENY INSERT, UPDATE, DELETE ON customers TO report_reader;
DENY INSERT, UPDATE, DELETE ON products TO report_reader;

PRINT 'Rol yetkilendirmesi (Grant/Deny) tamamlandı.';
GO

-- =========================================================================
-- TEST SENARYOSU
-- (Not: Bu testlerin yapılabilmesi için sisteme gerçekten o rolde bir 
-- login eklenmiş olması gerekir. Aşağıda bunun sanal bir simülasyonu vardır)
-- =========================================================================

/*
-- Test Kullanıcısı Yaratma ve Role Ekleme
CREATE USER test_user WITHOUT LOGIN;
ALTER ROLE report_reader ADD MEMBER test_user;

-- Sisteme test_user kimliği ile bürün (Impersonate)
EXECUTE AS USER = 'test_user';

-- SELECT: Başarılı Olacaktır
SELECT TOP 5 * FROM orders;

-- INSERT: HATA VERECEKTİR (The INSERT permission was denied on the object 'orders')
INSERT INTO orders (customer_id, order_date, total_amount, status)
VALUES (1, GETDATE(), 100, 'Pending');

-- Kimlikten çık ve DBA (Admin) yetkilerine geri dön
REVERT;
*/

-- =========================================================================
-- 8) ROLE AND PRIVILEGE MANAGEMENT
-- =========================================================================

-- 1. Create a Custom Read-Only (Reporting) Role
-- (To prevent Marketing and Reporting teams from accidentally corrupting data)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'report_reader' AND type = 'R')
BEGIN
    CREATE ROLE report_reader;
    PRINT 'Rol başarıyla oluşturuldu: report_reader';
END
GO

-- 2. Define Relevant Privileges (Grant)
-- Granting SELECT privilege only to tables that need to be read
GRANT SELECT ON customers TO report_reader;
GRANT SELECT ON orders TO report_reader;
GRANT SELECT ON products TO report_reader;

-- 3. Explicitly Deny Dangerous Privileges (Deny)
-- This role absolutely cannot insert, delete, or update data in the system
DENY INSERT, UPDATE, DELETE ON orders TO report_reader;
DENY INSERT, UPDATE, DELETE ON customers TO report_reader;
DENY INSERT, UPDATE, DELETE ON products TO report_reader;

PRINT 'Rol yetkilendirmesi (Grant/Deny) tamamlandı.';
GO

-- =========================================================================
-- TEST SCENARIO
-- (Note: For these tests to run, an actual login for that role 
-- login must be added. A virtual simulation of this is below)
-- =========================================================================

/*
-- Create Test User and Add to Role
CREATE USER test_user WITHOUT LOGIN;
ALTER ROLE report_reader ADD MEMBER test_user;

-- Impersonate test_user in the system
EXECUTE AS USER = 'test_user';

-- SELECT: Will Succeed
SELECT TOP 5 * FROM orders;

-- INSERT: WILL THROW ERROR (The INSERT permission was denied on the object 'orders')
INSERT INTO orders (customer_id, order_date, total_amount, status)
VALUES (1, GETDATE(), 100, 'Pending');

-- Revert identity and return to DBA (Admin) privileges
REVERT;
*/

USE PerformanceLab;
GO

PRINT '=== PARAMETER SNIFFING SETUP ===';

-- 1. Veri Dengesizliği (Data Skew) Yaratalım
-- Parameter Sniffing hatasının oluşabilmesi için dengesiz veriye ihtiyacımız var.
-- Siparişlere "prioriy" (öncelik) kolonu ekliyoruz. %99'u Normal, sadece 100 tanesi Critical olacak.
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'priority' AND Object_ID = Object_ID(N'orders'))
BEGIN
    ALTER TABLE orders ADD priority VARCHAR(10) DEFAULT 'Normal';
    EXEC('UPDATE orders SET priority = ''Normal''');
    -- Sadece 100 kaydı Critical yapıyoruz
    EXEC('UPDATE TOP (100) orders SET priority = ''Critical''');
END
GO

-- Öncelik kolonu için non-clustered index ekliyoruz (Covering değil ki Key Lookup yapsın)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_Priority' AND object_id = OBJECT_ID('orders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_Priority ON orders(priority);
END
GO


-- 2. Stored Procedure OLUŞTURALIM
-- Bu prosedür "priority" bilgisini parametre olarak alıp Sipariş detaylarını dönecek.
CREATE OR ALTER PROCEDURE GetOrdersByPriority
    @p_priority VARCHAR(10)
AS
BEGIN
    SELECT order_id, customer_id, total_amount, order_date, priority
    FROM orders
    WHERE priority = @p_priority;
END
GO


PRINT '=== BEFORE (SNIFFING PROBLEM) ===';
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO

-- 3. TUZAĞIN KURULMASI:
-- Sistemi kandırıyoruz. Önce sadece 100 kayıt dönen 'Critical' parametresiyle SP'yi çalıştırıyoruz.
-- SQL Server bu "Küçük" veri için süper hızlı olan "Index Seek + Key Lookup" planını çizip Cache (hafıza) atıyor.
EXEC GetOrdersByPriority @p_priority = 'Critical';
GO

-- 4. HATANIN GÖRÜLMESİ (BUNUN EKRAN GÖRÜNTÜSÜ ALINACAK - before_sniffing.png):
-- Şimdi aynı SP'yi 499.000 kayıt dönen 'Normal' parametresiyle çağırıyoruz.
-- SQL Server tembellik yapıp yukarıdaki Cache planını(Key Lookup) kullanacak ve felç geçirecek!
-- Execution Plan'a bakarsanız devasa kalın oklar ve uyarılar göreceksiniz.
EXEC GetOrdersByPriority @p_priority = 'Normal';
GO


PRINT '=== AFTER (SOLUTION WITH RECOMPILE) ===';
-- 5. ÇÖZÜM: OPTION (RECOMPILE)
-- SP'mizin sonuna sihirli kodu ekliyoruz. "Cache tutma, her parametreye özel anlık plan çiz" diyoruz.
CREATE OR ALTER PROCEDURE GetOrdersByPriority
    @p_priority VARCHAR(10)
AS
BEGIN
    SELECT order_id, customer_id, total_amount, order_date, priority
    FROM orders
    WHERE priority = @p_priority
    OPTION (RECOMPILE); -- SİHİRLİ DOKUNUŞ
END
GO

-- 6. ÇÖZÜMÜN GÖRÜLMESİ (BUNUN EKRAN GÖRÜNTÜSÜ ALINACAK - after_sniffing.png):
-- Şimdi büyük veri getiren Normal'i tekrar sorguluyoruz.
-- SQL Server bu sefer Key Lookup gibi amelelik yapmak yerine, doğrudan mantıklı olan "Clustered Index Scan" planını seçecek! 
-- Execution plan tertemiz olacak.
EXEC GetOrdersByPriority @p_priority = 'Normal';
GO

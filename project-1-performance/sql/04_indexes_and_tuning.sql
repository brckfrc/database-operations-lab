USE PerformanceLab;
GO

PRINT '=== OPTIMIZATION & TUNING START ===';

-- FIX 4: Kötü İndeksi Kaldır (Yazma Hızını Düzelt)
-- orders(status, total_amount, order_date) şeklindeki aşırı geniş indeks okumada işe yarasa da INSERT/UPDATE'leri boğuyordu.
-- Bunu kaldırıyoruz.
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_BadIndex' AND object_id = OBJECT_ID('orders'))
BEGIN
    PRINT 'Dropping Bad Index: IX_Orders_BadIndex';
    DROP INDEX IX_Orders_BadIndex ON orders;
END
GO

-- FIX 1: Sargable Sorgu için Tarih İndeksi Ekle
-- YEAR() fonksiyonundan kurtaracağımız sorgu için order_date kolonuna düz indeks atıyoruz.
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_OrderDate' AND object_id = OBJECT_ID('orders'))
BEGIN
    PRINT 'Creating Index: IX_Orders_OrderDate';
    CREATE NONCLUSTERED INDEX IX_Orders_OrderDate ON orders(order_date);
END
GO

-- FIX 3: Eksik Foreign Key İndekslerini Ekle (Nested Loop Faciasını Engelle)
-- SQL Server FK'lara otomatik indeks atmaz. Milyonlarca satırlık devasa JOIN'leri hızlandırmalıyız.
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_CustomerID' AND object_id = OBJECT_ID('orders'))
BEGIN
    PRINT 'Creating FK Index: IX_Orders_CustomerID';
    CREATE NONCLUSTERED INDEX IX_Orders_CustomerID ON orders(customer_id);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderItems_OrderID' AND object_id = OBJECT_ID('order_items'))
BEGIN
    PRINT 'Creating FK Index: IX_OrderItems_OrderID';
    CREATE NONCLUSTERED INDEX IX_OrderItems_OrderID ON order_items(order_id);
END
GO

-- FIX 2: SELECT * Yerine Spesifik (Covering) Index
-- Sadece order_date, total_amount, status gibi 3 kolon kullanıldığı için "Covering Index" yaratarak doğrudan indeks ağacından okunmasını sağlıyoruz.
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_Status_Include' AND object_id = OBJECT_ID('orders'))
BEGIN
    PRINT 'Creating Covering Index: IX_Orders_Status_Include';
    CREATE NONCLUSTERED INDEX IX_Orders_Status_Include 
    ON orders(status) INCLUDE (order_date, total_amount, customer_id);
END
GO

PRINT '=== OPTIMIZATION & TUNING COMPLETE ===';
GO

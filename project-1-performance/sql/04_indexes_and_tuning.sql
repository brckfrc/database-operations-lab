USE PerformanceLab;
GO

PRINT '=== OPTIMIZATION & TUNING START ===';

-- FIX 4: Remove Bad Index (Fix Write Speed)
-- The excessively wide index on orders(status, total_amount, order_date) was useful for reading but choked INSERT/UPDATEs.
-- We are removing this.
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_BadIndex' AND object_id = OBJECT_ID('orders'))
BEGIN
    PRINT 'Dropping Bad Index: IX_Orders_BadIndex';
    DROP INDEX IX_Orders_BadIndex ON orders;
END
GO

-- FIX 1: Add Date Index for Sargable Query
-- Adding a standard index to the order_date column for the query we'll save from the YEAR() function.
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_OrderDate' AND object_id = OBJECT_ID('orders'))
BEGIN
    PRINT 'Creating Index: IX_Orders_OrderDate';
    CREATE NONCLUSTERED INDEX IX_Orders_OrderDate ON orders(order_date);
END
GO

-- FIX 3: Add Missing Foreign Key Indexes (Prevent Nested Loop Disaster)
-- SQL Server does not auto-index FKs. We must accelerate massive JOINs on millions of rows.
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

-- FIX 2: Specific (Covering) Index Instead of SELECT *
-- By creating a "Covering Index" for the 3 used columns (order_date, total_amount, status), we enable direct reads from the index tree.
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_Status_Include' AND object_id = OBJECT_ID('orders'))
BEGIN
    PRINT 'Creating Covering Index: IX_Orders_Status_Include';
    CREATE NONCLUSTERED INDEX IX_Orders_Status_Include 
    ON orders(status) INCLUDE (order_date, total_amount, customer_id);
END
GO

PRINT '=== OPTIMIZATION & TUNING COMPLETE ===';
GO

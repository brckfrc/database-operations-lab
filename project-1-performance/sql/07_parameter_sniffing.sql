USE PerformanceLab;
GO

PRINT '=== PARAMETER SNIFFING SETUP ===';

-- 1. Create Data Skew
-- Data skew is required to trigger the Parameter Sniffing error.
-- Adding a "priority" column to orders. 99% will be Normal, only 100 will be Critical.
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'priority' AND Object_ID = Object_ID(N'orders'))
BEGIN
    ALTER TABLE orders ADD priority VARCHAR(10) DEFAULT 'Normal';
    EXEC('UPDATE orders SET priority = ''Normal''');
    -- Making only 100 records Critical
    EXEC('UPDATE TOP (100) orders SET priority = ''Critical''');
END
GO

-- Adding a non-clustered index for the priority column (Not Covering, so it forces a Key Lookup)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_Priority' AND object_id = OBJECT_ID('orders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_Priority ON orders(priority);
END
GO


-- 2. CREATE Stored Procedure
-- This procedure takes "priority" as a parameter and returns Order details.
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

-- 3. SETTING THE TRAP:
-- Tricking the system. First, we run the SP with the 'Critical' parameter that returns only 100 records.
-- SQL Server draws a super-fast "Index Seek + Key Lookup" plan for this "Small" data and caches it.
EXEC GetOrdersByPriority @p_priority = 'Critical';
GO

-- 4. OBSERVING THE ERROR (TAKE SCREENSHOT - before_sniffing.png):
-- Now calling the same SP with the 'Normal' parameter returning 499,000 records.
-- SQL Server will act lazy, use the cached plan (Key Lookup) from above, and paralyze itself!
-- Check the Execution Plan to see massive thick arrows and warnings.
EXEC GetOrdersByPriority @p_priority = 'Normal';
GO


PRINT '=== AFTER (SOLUTION WITH RECOMPILE) ===';
-- 5. SOLUTION: OPTION (RECOMPILE)
-- Adding the magic code to our SP: "Do not cache, draw an ad-hoc plan for each parameter."
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

-- 6. OBSERVING THE SOLUTION (TAKE SCREENSHOT - after_sniffing.png):
-- Now querying the large-data returning Normal again.
-- Instead of doing grunt work like Key Lookup, SQL Server will directly choose the logical "Clustered Index Scan" plan this time! 
-- Execution plan will be crystal clear.
EXEC GetOrdersByPriority @p_priority = 'Normal';
GO

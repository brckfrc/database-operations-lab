USE PerformanceLab;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

PRINT '=== BASELINE QUERIES START ===';

-- 1. Non-Sargable Date Filter
PRINT '--- QUERY 1: Non-Sargable Date Filter ---';
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO
SELECT order_id, customer_id, total_amount, order_date 
INTO #temp1
FROM orders 
WHERE YEAR(order_date) = 2024;
GO

-- 2. SELECT * Laziness
PRINT '--- QUERY 2: SELECT * Overkill ---';
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO
SELECT o.order_id as o_id, o.customer_id, o.order_date, o.total_amount, o.status, 
       oi.order_item_id, oi.order_id as oi_order_id, oi.product_id, oi.quantity, oi.unit_price
INTO #temp2
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Pending';
GO

-- 3. Missing Index (Missing Index on Foreign Key)
PRINT '--- QUERY 3: Missing Index on JOIN ---';
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO
SELECT c.first_name, c.last_name, count(o.order_id) as total_orders
INTO #temp3
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.region = 'North'
GROUP BY c.first_name, c.last_name;
GO

-- 4. Punishing Index (Write Load - Baseline "Bad" Scenario)
PRINT '--- QUERY 4: Over-Indexing Write Penalty ---';
-- First, we intentionally add an index that will exhaust the database; useful for reads but heavy for writes.
CREATE NONCLUSTERED INDEX IX_Orders_BadIndex ON orders (status, total_amount, order_date);
GO

DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO
-- Add 50,000 new orders to measure the index update cost (latency).
INSERT INTO orders (customer_id, order_date, total_amount, status)
SELECT TOP 50000 
    customer_id, GETDATE(), 150.00, 'Pending'
FROM customers;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

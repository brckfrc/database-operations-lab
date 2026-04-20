USE PerformanceLab;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

PRINT '=== AFTER OPTIMIZATION QUERIES ===';

-- 1. Sargable Hale Getirilmiş Filtre
PRINT '--- OPTIMIZED QUERY 1: Sargable Date Range Filter ---';
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO
SELECT order_id, customer_id, total_amount, order_date 
INTO #temp1
FROM orders 
WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01';
GO

-- 2. Spesifik Kolonlarla Sorgu (Select * Düzeltmesi)
PRINT '--- OPTIMIZED QUERY 2: Specific Columns (No SELECT *) ---';
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO
SELECT o.order_id as o_id, o.customer_id, o.order_date, o.total_amount, o.status, 
       oi.order_item_id, oi.product_id, oi.quantity, oi.unit_price
INTO #temp2
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Pending';
GO

-- 3. İndekslenmiş JOIN
PRINT '--- OPTIMIZED QUERY 3: Indexed JOIN ---';
-- Sorgu kodu değişmedi, SADECE arkada yatan indeksler sayesinde bu sorgu "Index Seek" yetenekleri kazandı.
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

-- 4. Temizlenmiş İndeks İle Hızlı Yazma
PRINT '--- OPTIMIZED QUERY 4: Fast Insert Without Penalty ---';
-- Gereksiz IX_Orders_BadIndex kaldırıldıktan sonra yazma hızını test ediyoruz.
DBCC DROPCLEANBUFFERS;
DBCC FREEPROCCACHE;
GO
INSERT INTO orders (customer_id, order_date, total_amount, status)
SELECT TOP 50000 
    customer_id, GETDATE(), 150.00, 'Pending'
FROM customers;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

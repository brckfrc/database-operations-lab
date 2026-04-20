USE PerformanceLab;
GO

SET NOCOUNT ON;

-- 1. Customers (100,000)
IF (SELECT COUNT(*) FROM customers) = 0
BEGIN
    WITH L0 AS (SELECT c FROM (VALUES(1),(1)) AS D(c)),
         L1 AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
         L2 AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
         L3 AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
         L4 AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
         L5 AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
         Tally AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L5)
         
    INSERT INTO customers (first_name, last_name, email, region, registration_date, status)
    SELECT TOP (100000)
        'First_' + CAST(n AS VARCHAR(20)),
        'Last_' + CAST(n AS VARCHAR(20)),
        'user' + CAST(n AS VARCHAR(20)) + '@example.com',
        CHOOSE((ABS(CHECKSUM(NEWID())) % 5) + 1, 'North', 'South', 'East', 'West', 'Central'),
        DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 1825), '2025-01-01'), -- Past 5 years from early 2025
        CHOOSE((ABS(CHECKSUM(NEWID())) % 4) + 1, 'Active', 'Active', 'Inactive', 'Banned') -- 50% Active
    FROM Tally;
    PRINT 'Inserted 100,000 rows into customers table.';
END
ELSE
BEGIN
    PRINT 'customers table already contains data.';
END

-- 2. Orders (500,000)
IF (SELECT COUNT(*) FROM orders) = 0
BEGIN
    WITH L0 AS (SELECT c FROM (VALUES(1),(1)) AS D(c)),
         L1 AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
         L2 AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
         L3 AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
         L4 AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
         L5 AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B), 
         Tally AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L5)

    INSERT INTO orders (customer_id, order_date, total_amount, status)
    SELECT TOP (500000)
        (ABS(CHECKSUM(NEWID())) % 100000) + 1, -- random customer 1-100k
        DATEADD(MINUTE, -(ABS(CHECKSUM(NEWID())) % 2628000), '2025-01-01'), -- Past 5 years random time
        (ABS(CHECKSUM(NEWID())) % 5000) + 10.50,
        CHOOSE((ABS(CHECKSUM(NEWID())) % 4) + 1, 'Pending', 'Shipped', 'Delivered', 'Cancelled')
    FROM Tally;
    PRINT 'Inserted 500,000 rows into orders table.';
END
ELSE
BEGIN
    PRINT 'orders table already contains data.';
END

-- 3. Order Items (1,000,000)
IF (SELECT COUNT(*) FROM order_items) = 0
BEGIN
    WITH L0 AS (SELECT c FROM (VALUES(1),(1)) AS D(c)),
         L1 AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
         L2 AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
         L3 AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
         L4 AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
         L5 AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
         Tally AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L5)

    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    SELECT TOP (1000000)
        (ABS(CHECKSUM(NEWID())) % 500000) + 1, -- random order 1-500k
        (ABS(CHECKSUM(NEWID())) % 20000) + 1,  -- random product 1-20k
        (ABS(CHECKSUM(NEWID())) % 10) + 1,     -- quantity 1-10
        (ABS(CHECKSUM(NEWID())) % 500) + 5.99  -- random unit price
    FROM Tally;
    PRINT 'Inserted 1,000,000 rows into order_items table.';
END
ELSE
BEGIN
    PRINT 'order_items table already contains data.';
END
GO

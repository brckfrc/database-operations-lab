USE PerformanceLab;
GO

SET NOCOUNT ON;

IF (SELECT COUNT(*) FROM products) = 0
BEGIN
    -- Using a Tally/Numbers table technique for fast bulk insertion
    WITH L0 AS (SELECT c FROM (VALUES(1),(1)) AS D(c)),
         L1 AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
         L2 AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
         L3 AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
         L4 AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
         Tally AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L4)
         
    INSERT INTO products (product_name, category, price, stock_quantity)
    SELECT TOP (20000)
        'Product_' + CAST(n AS VARCHAR(10)),
        CHOOSE((ABS(CHECKSUM(NEWID())) % 5) + 1, 'Electronics', 'Clothing', 'Home', 'Sports', 'Books'),
        (ABS(CHECKSUM(NEWID())) % 2000) + 5.99,
        (ABS(CHECKSUM(NEWID())) % 1000) + 5
    FROM Tally;

    PRINT 'Inserted 20,000 rows into products table.';
END
ELSE
BEGIN
    PRINT 'products table already contains data.';
END
GO

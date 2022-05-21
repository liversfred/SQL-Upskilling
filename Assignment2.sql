USE SQL4DEVSDb;

-- 1 --
SELECT p.ProductName, SUM(oi.Quantity) AS TotalQuantity 
FROM [Order] o
INNER JOIN OrderItem oi ON oi.OrderId = o.OrderId 
INNER JOIN Product p ON p.ProductId = oi.ProductId
WHERE o.ShippedDate IS NOT Null
GROUP BY p.ProductName
HAVING SUM(oi.Quantity) > 10
ORDER BY TotalQuantity ASC;
-- 1 --

--2--
SELECT REPLACE(c.CategoryName, 'Bikes', 'Bicycle') CategoryName, SUM(oi.Quantity) AS TotalQuantity 
FROM [Order] o
INNER JOIN OrderItem oi ON oi.OrderId = o.OrderId 
INNER JOIN Product p ON p.ProductId = oi.ProductId
INNER JOIN Category c ON c.CategoryId = p.CategoryId
GROUP BY c.CategoryName
ORDER BY TotalQuantity DESC;
--2--

--3--
-- Create a new Table with the result on Item no 1 --
SELECT p.ProductName, SUM(oi.Quantity) AS TotalQuantity 
INTO ProductOutput
FROM [Order] o
INNER JOIN OrderItem oi ON oi.OrderId = o.OrderId 
INNER JOIN Product p ON p.ProductId = oi.ProductId
WHERE o.ShippedDate IS NOT Null
GROUP BY p.ProductName
HAVING SUM(oi.Quantity) > 10
ORDER BY TotalQuantity ASC;
-- Create a new Table with the result on Item no 2 --
SELECT REPLACE(c.CategoryName, 'Bikes', 'Bicycle') CategoryName, SUM(oi.Quantity) AS TotalQuantity 
INTO CategoryOutput
FROM [Order] o
INNER JOIN OrderItem oi ON oi.OrderId = o.OrderId 
INNER JOIN Product p ON p.ProductId = oi.ProductId
INNER JOIN Category c ON c.CategoryId = p.CategoryId
GROUP BY c.CategoryName
ORDER BY TotalQuantity DESC;

-- Do The Merge --
MERGE [dbo].[CategoryOutput] AS tgt
USING [dbo].[ProductOutput] AS src
	ON (tgt.CategoryName = src.ProductName)
WHEN MATCHED
	THEN UPDATE
		SET tgt.CategoryName = src.ProductName
	      , tgt.TotalQuantity = src.TotalQuantity
WHEN NOT MATCHED
	THEN INSERT
	VALUES(src.ProductName, src.TotalQuantity)
WHEN NOT MATCHED BY SOURCE
	THEN DELETE
OUTPUT DELETED.*, $action, INSERTED.*;
--3--

--4--
WITH cteTable1 AS (
	SELECT 
		YEAR(o.OrderDate) AS OrderYear,
		MONTH(o.OrderDate) AS OrderMonth,
		p.ProductName,
		SUM(oi.Quantity) AS TotalQuantity
	FROM [Order] o
	INNER JOIN OrderItem oi ON oi.OrderId = o.OrderId 
	INNER JOIN Product p ON p.ProductId = oi.ProductId
	GROUP BY o.OrderDate, p.ProductName
), cteTable2 AS (
	SELECT RANK() OVER(PARTITION BY OrderYear, OrderMonth ORDER BY TotalQuantity DESC) AS RankId , * 
	FROM cteTable1
)

Select OrderYear, OrderMonth, ProductName, TotalQuantity
From cteTable2
WHERE RankId=1;
--4--

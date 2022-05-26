USE SQL4DevsDb
GO

--7--
WITH cteTable AS (
	SELECT LEFT(DATENAME(MONTH, o.OrderDate), 3) as MonthNames, YEAR(o.OrderDate) AS SalesYear, SUM(oi.ListPrice) AS Total
	FROM [Order] o
	INNER JOIN OrderItem oi ON oi.OrderId = o.OrderId
	GROUP BY o.OrderDate
)

SELECT 
	SalesYear, 
	COALESCE(Jan, 0) Jan, COALESCE(Feb, 0) Feb, COALESCE(Mar, 0) Mar, COALESCE(Apr, 0) Apr, COALESCE(May, 0) May, COALESCE(Jun, 0) Jun, 
	COALESCE(Jul, 0) Jul, COALESCE(Aug, 0) Aug, COALESCE(Sep, 0) Sep, COALESCE(Oct, 0) Oct, COALESCE(Nov, 0) Nov, COALESCE(Dec, 0) Dec 
FROM cteTable
PIVOT(
	 SUM(Total)
	 FOR MonthNames IN (
		Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec
	 )
) AS PivotTable
--7--

--6--
DECLARE @var1 INT
	  , @var2 INT;
SET @var1 = 1;

WHILE @var1 <= 10
BEGIN
	SET @var2 = 1;

	WHILE @var2 <= 10
	BEGIN
		PRINT CAST(@var1 AS VARCHAR) + '*' + CAST(@var2 AS VARCHAR) + ' = ' + CAST((@var1 * @var2) AS VARCHAR);
		SET @var2 = @var2 + 1;
	END

	SET @var1 = @var1 + 1;
END
--6--

--5--
DECLARE @StoreName VARCHAR(MAX)
	  , @OrderYear VARCHAR(MAX)
	  , @OrderCount INT

DECLARE cursor_store_order CURSOR FOR
SELECT s.StoreName, YEAR(o.OrderDate) AS OrderYear, COUNT(DISTINCT oi.OrderId) AS OrderCount
FROM [Order] o
LEFT JOIN OrderItem oi ON oi.OrderId = o.OrderId
LEFT JOIN Store s ON s.StoreId = o.StoreId
GROUP BY s.StoreName, YEAR(o.OrderDate)
ORDER BY s.StoreName, OrderYear DESC

OPEN cursor_store_order;
FETCH NEXT FROM cursor_store_order INTO @StoreName, @OrderYear, @OrderCount;

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @StoreName + ' ' + @OrderYear + ' ' + CAST(@OrderCount AS VARCHAR);
	FETCH NEXT FROM cursor_store_order INTO @StoreName, @OrderYear, @OrderCount;
END;

CLOSE cursor_store_order;
DEALLOCATE cursor_store_order;
--5--

--4--
WITH cteTable1 AS (
	SELECT RANK() OVER(PARTITION BY b.BrandName ORDER BY b.BrandName, ListPrice DESC) AS RankId , b.BrandName, p.ProductId, p.ProductName, p.ListPrice 
	FROM Product p
	LEFT JOIN Brand b ON b.BrandId = p.BrandId
)

Select BrandName, ProductId, ProductName, ListPrice
From cteTable1
WHERE RankId BETWEEN 1 AND 5
ORDER BY BrandName, ListPrice DESC, ProductName;
--4--

--3--
SELECT s.StoreName, YEAR(o.OrderDate) AS OrderYear, COUNT(DISTINCT oi.OrderId) AS OrderCount
FROM [Order] o
LEFT JOIN OrderItem oi ON oi.OrderId = o.OrderId
LEFT JOIN Store s ON s.StoreId = o.StoreId
GROUP BY s.StoreName, YEAR(o.OrderDate)
ORDER BY s.StoreName, OrderYear DESC;
--3--

--2--
SELECT p.ProductId, p.ProductName, b.BrandName, c.CategoryName, stck.Quantity
FROM Product p
LEFT JOIN Brand b ON b.BrandId = p.BrandId
LEFT JOIN Category c ON c.CategoryId = p.CategoryId
LEFT JOIN Stock stck ON stck.ProductId = p.ProductId
LEFT JOIN Store sr ON sr.StoreId = stck.StoreId
WHERE (ModelYear BETWEEN 2017 AND 2018) AND stck.StoreId = 2 --Baldwin Bikes store with StoreId 2
ORDER BY stck.Quantity DESC, p.ProductName, b.BrandName, c.CategoryName ASC;
--2--

--1--
SELECT s.StoreId, s.StoreName 
FROM STORE s
LEFT JOIN [Order] o ON s.StoreId = o.StoreId 
WHERE o.StoreId IS NULL;
--1--
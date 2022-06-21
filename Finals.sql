USE SQL4DevsDb
GO

-- 1 ---------------------------------------------------------------------------------------------------------
CREATE PROCEDURE CreateNewBrandAndMoveProducts
@NewBrandName VARCHAR(100) = null,
@OldBrandId INT = null
AS
BEGIN TRY

	BEGIN TRAN InsertAndUpdateProcess

		-- INSERT THE NEW BRAND
		INSERT INTO Brand 
		VALUES (@NewBrandName);

		-- UPDATE PRODUCTS
		UPDATE Product
		SET BrandId = (SELECT TOP 1 BrandId FROM Brand  ORDER BY BrandId DESC)
		WHERE BrandID = @OldBrandId;

		-- DELETE OLD BRAND
		DELETE FROM Brand WHERE BrandId = @OldBrandId;

		COMMIT TRAN InsertAndUpdateProcess
END TRY
BEGIN CATCH
	
	ROLLBACK TRAN InsertAndUpdateProcess
	SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_STATE() AS ErrorState,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage;
END CATCH

--EXEC CreateNewBrandAndMoveProducts @NewBrandName = 'NewBrand', @OldBrandId = 9;
-- END OF 1 ---------------------------------------------------------------------------------------------------------




-- 2 ---------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetProductList
@ProductName NVARCHAR(100) = NULL,
@BrandId INT = NULL,
@CatergoryId INT = NULL,
@ModelYear INT= NULL,
@PageNumber INT = 1
AS
SELECT * FROM Product
WHERE (ProductName = @ProductName OR @ProductName IS NULL)
	AND (BrandId = @BrandId OR @BrandId IS NULL) 
	AND (CategoryId = @CatergoryId OR @CatergoryId IS NULL)
	AND (ModelYear = @ModelYear OR @ModelYear IS NULL)
ORDER BY ModelYear DESC, ListPrice DESC, ProductName
OFFSET (10 * (@PageNumber - 1)) ROWS
FETCH NEXT 10 ROWS ONLY;

--EXEC GetProductList 
--@PageNumber = 1
--, @ProductName = 'Trek Slash 8 27.5 - 2016'
--, @BrandId = 11
--, @CatergoryId = 6
--, @ModelYear = 2016
-- END OF 2 ---------------------------------------------------------------------------------------------------------




-- 3 ---------------------------------------------------------------------------------------------------------
-- BACKUP Product TABLE
SELECT * INTO Product_backup FROM Product;

-- CREATE SP
CREATE PROCEDURE UpdateListPrice
@CategoryName VARCHAR(255),
@CategoryId INT
ASUPDATE Product_backupSET ListPrice = 	CASE 		WHEN (@CategoryName = 'Children Bicycles' OR @CategoryName = 'Cyclocross Bicycles' OR @CategoryName = 'Road Bikes')  			THEN (ListPrice * 1.2)		WHEN (@CategoryName = 'Comfort Bicycles' OR @CategoryName = 'Cruisers Bicycles' OR @CategoryName = 'Electric Bikes')  			THEN (ListPrice * 1.7)		WHEN (@CategoryName = 'Mountain Bikes')			THEN (ListPrice * 1.4)	ENDFROM Product_backup pINNER JOIN Category c ON c.CategoryId = p.CategoryId AND p.CategoryId = @CategoryIdEXEC UpdateListPrice @CategoryName = 'Mountain Bikes', @CategoryId = 1;
-- END OF 3 ---------------------------------------------------------------------------------------------------------





-- 4 ---------------------------------------------------------------------------------------------------------
-- CREATE RANKING TABLE
CREATE TABLE Ranking (
    Id INT IDENTITY(1,1) PRIMARY KEY (Id),
    Description varchar(255) NOT NULL
);

-- POPUlATE RANKING TABLE
INSERT INTO Ranking (Description)
VALUES ('Inactive')
	   , ('Bronze')
	   , ('Silver')
	   , ('Gold')
	   , ('Platinum')

-- ADD FOREIGN KEY TO THE CUSTOMER TABLE
ALTER TABLE Customer
ADD RankingId INT FOREIGN KEY (RankingId) REFERENCES Ranking(Id);

-- SP FOR UPDATING Customer.RankingId
CREATE PROCEDURE uspRankCustomers
AS 
BEGIN
	;WITH cteTable AS (
		SELECT o.CustomerId, SUM((oI.Quantity * oI.ListPrice) / (1 + oI.Discount)) AS TotalAmount
		FROM [Order] o
		INNER JOIN OrderItem oi ON oi.OrderId = o.OrderId
		GROUP BY o.CustomerId
	)

	UPDATE Customer	SET RankingId = 		CASE 			WHEN (TotalAmount = 0 )				THEN 1			WHEN (TotalAmount < 1000)				THEN 2			WHEN (TotalAmount < 2000)				THEN 3			WHEN (TotalAmount < 3000)				THEN 4			WHEN (TotalAmount >= 3000)				THEN 5		END	FROM Customer p	INNER JOIN cteTable cte ON cte.CustomerId = p.CustomerId
END

-- EXECUTE SP
EXEC uspRankCustomers;

-- CREATE VIEW
CREATE VIEW vwCustomerOrders AS
SELECT c.CustomerId, c.FirstName, c.LastName, CAST(SUM((oI.Quantity * oI.ListPrice) / (1 + oI.Discount)) AS DECIMAL(10,2)) AS TotalAmount, r.Description
FROM Customer c
INNER JOIN [Order] o ON o.CustomerId = c.CustomerId
INNER JOIN OrderItem oi ON oi.OrderId = o.OrderId
INNER JOIN Ranking r ON r.Id = c.RankingId
GROUP BY c.CustomerId, c.FirstName, c.LastName, r.Description

-- QUERY FROM VIEW
SELECT * FROM vwCustomerOrders ORDER BY CustomerId
-- END OF 4 ---------------------------------------------------------------------------------------------------------





-- 5 ---------------------------------------------------------------------------------------------------------
;WITH cteStaff AS (
	SELECT 
		StaffId
		, (FirstName + ' ' + LastName) AS FullName
		, CAST((FirstName + ' ' + LastName) as varchar(100)) AS EmployeeHierarchy
	FROM Staff
	WHERE ManagerId IS NULL

	UNION ALL

	SELECT
		s.StaffId
		, (FirstName + ' ' + LastName) AS FullName
		, CAST(EmployeeHierarchy + ', ' + CAST((s.FirstName + ' ' + s.LastName) as varchar(100)) AS VARCHAR(100))
	FROM cteStaff cs
	INNER JOIN Staff s ON cs.StaffId = s.ManagerId
)

SELECT * 
FROM cteStaff
ORDER BY StaffId;
-- END OF 5 ---------------------------------------------------------------------------------------------------------
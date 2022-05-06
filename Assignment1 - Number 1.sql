SELECT CustomerId, COUNT(OrderId) AS OrderCount 
FROM [dbo].[Order] 
WHERE year(OrderDate) BETWEEN 2017 AND 2018 AND ShippedDate IS NULL 
GROUP BY CustomerId
HAVING COUNT(OrderId) !< 2;
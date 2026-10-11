CREATE DATABASE RetailAnalytix;
USE RetailAnalytix;
-- Renaming the TableName

ALTER TABLE Customer_Profiles
RENAME TO Customers;

ALTER TABLE Product_Inventory
RENAME TO Products;

ALTER TABLE Sales_Transaction
RENAME TO Sales;

-- Understanding the Data ..

DESCRIBE Customers;

DESCRIBE Products;

DESCRIBE Sales;

SELECT * FROM Customers;

SELECT * FROM Products;

SELECT * FROM Sales;

-- RENAMING COLUMNS 
ALTER TABLE Customers
RENAME COLUMN ï»¿CustomerID TO CustomerID;

DESC Customers;

-- RENAMING COLUMNS 
ALTER TABLE Products
RENAME COLUMN ï»¿ProductID TO ProductID;

DESC Products;


-- RENAMING COLUMNS 
ALTER TABLE Sales
RENAME COLUMN ï»¿TransactionID TO TransactionID;

DESC Sales;

-- Challenge 1 : Remove Duplicates .....

SELECT * FROM Sales; -- 5002 row(s) returned

SELECT
	TransactionID,
    COUNT(*)
FROM Sales
GROUP BY 1
HAVING COUNT(*) > 1;

SELECT DISTINCT * FROM Sales; -- 5000 row(s) returned

CREATE TABLE Sales_Unique AS 
SELECT DISTINCT * FROM Sales;

DROP TABLE Sales;

ALTER TABLE Sales_Unique
RENAME TO Sales;

-- Challenge 2 : Fix Incorrect Price

USE retailAnalytix;

SELECT * FROM Sales;

SELECT * FROM Products;

SELECT
	p.ProductID,
    TransactionID,
    s.Price AS TransactionPrice,
    p.Price AS InventoryPrice
FROM sales s
JOIN products p
ON p.ProductID = s.ProductID
WHERE s.Price <> p.Price;

-- Static Update [Where ProductId = 51]
SET SQL_SAFE_UPDATES = 0;

UPDATE Sales
SET Price = 93.12
WHERE ProductID = 51;

-- Challenge3 : Fix NULL Values 

SELECT * FROM Customers;

SELECT DISTINCT Location FROM Customers;

SELECT COUNT(*) FROM Customers
WHERE Location = "";

-- For Platform 
SELECT COUNT(*) FROM Customers
WHERE Location IS NULL;

UPDATE Customers
SET Location = "Unknown"
WHERE Location = "";
-- 13 row(s) affected Rows matched: 13  Changed: 13  Warnings: 0

-- For Platform 
UPDATE Customers
SET Location = "Unknown"
WHERE Location IS NULL;

-- Challenge 4: Cleaning Date

SELECT * FROM Sales;

DESC Sales;

CREATE TABLE Sales_Updates AS (
	SELECT 
		*,
		STR_TO_DATE(TransactionDate , "%d/%m/%y") AS TransactionDate_updated
	FROM Sales
);

SELECT * FROM Sales_Updates;

DESC Sales_Updates;

UPDATE Sales_Updates 
SET TransactionDate = STR_TO_DATE(TransactionDate , "%d/%m/%y");
-- 5000 row(s) affected Rows matched: 5000  Changed: 5000  Warnings: 0

ALTER TABLE Sales_Updates
MODIFY COLUMN TransactionDate DATE;

DROP TABLE Sales;

ALTER TABLE Sales_Updates
RENAME TO Sales;

SELECT * FROM Sales;

-- Total Sales Summary 

SELECT * FROM Sales;

SELECT
	ProductID,
    SUM(QuantityPurchased) AS TotalUnitsSold,
    ROUND(SUM(QuantityPurchased * Price),2) AS TotalSales
FROM Sales
GROUP BY ProductID
ORDER BY TotalSales DESC;

-- Challenge 6 : Customer Purchase Frequency :

SELECT 
    CustomerID,
    COUNT(*) AS NumberOfTransactions
FROM Sales
GROUP BY CustomerID
ORDER BY NumberOfTransactions DESC;

-- Challenge 7: Product Categories Performance 

SELECT
	p.Category,
	SUM(s.QuantityPurchased) AS TotalUnitsSold,
	ROUND(SUM(s.Price * s.QuantityPurchased),2) AS TotalSales
FROM Sales s
JOIN Products p
ON s.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY TotalSales DESC;

-- Challenge 8 - High Sales Products...

SELECT * FROM Sales;

SELECT
	ProductId,
    ROUND(SUM(QuantityPurchased * Price),2) AS TotalRevenue
FROM Sales
GROUP BY ProductID
ORDER BY TotalRevenue DESC
LIMIT 10;

-- CHALLENGE 9: Low Sales Products 

SELECT
	ProductId,
    SUM(QuantityPurchased) AS TotalUnitsSold
FROM Sales
GROUP BY ProductID
HAVING TotalUnitsSold > 0
ORDER BY TotalUnitsSold
LIMIT 10;

-- Challenge 10 : Sales Trend 

SELECT * FROM Sales;

SELECT
	TransactionDate AS DATETRANS,
    COUNT(*) AS Transaction_count,
    SUM(QuantityPurchased) AS TotalUnitsSold,
    ROUND(SUM(QuantityPurchased * Price),2) AS TotalSales
FROM Sales
GROUP BY DATETRANS
ORDER BY DATETRANS DESC;


-- Challenge 11 - Growth Rate of Sales..... 

SELECT * FROM sales;

WITH MonthlySales AS(
	SELECT 
		EXTRACT(MONTH FROM TransactionDate) AS month,
        ROUND(SUM(QuantityPurchased * Price),2) AS total_sales
	FROM Sales
    GROUP BY month
),
PreviousMonthSales AS (
	SELECT 
		month,
        total_sales,
		LAG(total_sales) OVER(ORDER BY month) AS previous_month_sales
	FROM MonthlySales
)
SELECT 
	*,
    ROUND(((total_sales - previous_month_sales) / previous_month_sales) * 100,2) AS mom_growth_percentage
FROM PreviousMonthSales;

-- Challenge 12 : High Purchase Frequency ..........

SELECT * FROM Sales;

SELECT
	CustomerID,
	COUNT(TransactionID) AS NumberOfTransactions,
	SUM(QuantityPurchased * Price) AS TotalSpent
FROM Sales
GROUP BY CustomerID; -- 989 row(s) returned


SELECT
	CustomerID,
	COUNT(TransactionID) AS NumberOfTransactions,
	ROUND(SUM(QuantityPurchased * Price),2) AS TotalSpent
FROM Sales
GROUP BY CustomerID
HAVING NumberOfTransactions > 10 AND TotalSpent > 1000
ORDER BY TotalSpent DESC; -- 18 row(s) returned



SELECT
	CustomerID,
	COUNT(TransactionID) AS NumberOfTransactions,
	ROUND(SUM(QuantityPurchased * Price),2) AS TotalSpent
FROM Sales
GROUP BY CustomerID
HAVING NumberOfTransactions > 10 AND TotalSpent > 1000
ORDER BY TotalSpent DESC; -- 18 row(s) returned

-- Challenge 13 : Occassional Customers 

SELECT
	CustomerID,
	COUNT(TransactionID) AS NumberOfTransactions,
	ROUND(SUM(QuantityPurchased * Price),2) AS TotalSpent
FROM Sales
GROUP BY CustomerID
HAVING NumberOfTransactions <= 2
ORDER BY NumberOfTransactions ASC , TotalSpent DESC; -- 130 row(s) returned

-- Challenge 14 : Repeat Purchases 

SELECT * FROM Sales;

SELECT
	CustomerID,
    ProductID,
    COUNT(*) AS TimesPurchased
FROM Sales
GROUP BY CustomerID , ProductID
HAVING TimesPurchased > 1 
ORDER BY TimesPurchased DESC; -- 70 row(s) returned

-- Challenge 15 : Loyalty Indicators

SELECT * FROM Sales;

WITH TransactionsDate AS (
	SELECT 
		CustomerID,
        STR_TO_DATE(TransactionDate , "%Y-%m-%d") AS TransactionDate
	FROM Sales
)
SELECT
	CustomerID,
    MIN(TransactionDate) AS FirstPurchase,
    MAX(TransactionDate) AS LastPurchase,
    DATEDIFF(MAX(TransactionDate) , MIN(TransactionDate)) AS DaysBetweenPurchases
FROM TransactionsDate
GROUP BY CustomerID
HAVING DaysBetweenPurchases > 0
ORDER BY DaysBetweenPurchases DESC; -- 950 row(s) returned

-- Challenge 16 : Customers Segmentation ......

SELECT * FROM Sales;

SELECT
	c.CustomerID,
	SUM(s.QuantityPurchased) AS TotalQuantity
FROM Customers c 
JOIN Sales s
ON c.CustomerID = s.CustomerID
GROUP BY c.CustomerID;

CREATE TABLE customer_segments AS (
	WITH customers_totals AS (
		SELECT
			c.CustomerID,
			SUM(s.QuantityPurchased) AS TotalQuantity
		FROM Customers c 
        JOIN Sales s
        ON c.CustomerID = s.CustomerID
        GROUP BY c.CustomerID
    )
    SELECT 
		CustomerID,
        TotalQuantity,
        CASE
			WHEN TotalQuantity BETWEEN 1 AND 10 THEN 'Low'
			WHEN TotalQuantity BETWEEN 11 AND 30 THEN 'Med'
            WHEN TotalQuantity > 30 THEN 'High'
			ELSE 'None'
        END AS CustomerSegment
	FROM customers_totals
); -- 989 row(s) affected Records: 989  Duplicates: 0  Warnings: 0

SELECT * FROM Customer_Segments;
    
SELECT
	CustomerSegment,
    COUNT(*)
FROM Customer_Segments
GROUP BY CustomerSegment;
    
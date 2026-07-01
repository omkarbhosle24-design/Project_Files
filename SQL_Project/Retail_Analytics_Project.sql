CREATE DATABASE retailanalytic;

USE retailanalytic;

-- Renaming the Tables 
ALTER TABLE customer_profiles
RENAME TO customers;

ALTER TABLE product_inventory
RENAME TO products;

ALTER TABLE sales_transaction
RENAME TO sales;

DESC customers;
DESC products;
DESC sales;

-- ï»¿CustomerID -> CustomerID
-- ï»¿ProductID  -> ProductID
-- ï»¿TransactionID -> TransactionID

ALTER TABLE Customers
RENAME COLUMN ï»¿CustomerID TO CustomerID;

ALTER TABLE Products
RENAME COLUMN ï»¿ProductID TO ProductID;

ALTER TABLE sales
RENAME COLUMN ï»¿TransactionID TO TransactionID;

-- Reading out all the dataset ....
SELECT * FROM Customers;

SELECT * FROM Products;

SELECT * FROM Sales;

-- Challenge 1: Remove Duplicates

SELECT
    TransactionID,
    COUNT(*)
FROM Sales
GROUP BY TransactionID
HAVING COUNT(*) > 1;

CREATE TABLE sales_unique AS 
SELECT DISTINCT * FROM sales; -- 5000 row(s) affected Records: 5000

DROP TABLE sales;
ALTER TABLE sales_unique RENAME TO sales;

-- Challenge 2: Fix Incorrect Price

SELECT 
	p.ProductID,
    TransactionID,
    s.Price AS TransactionPrice,
    p.Price AS InventoryPrice
FROM sales s
JOIN products p
ON p.ProductID = s.ProductID
WHERE s.Price <> p.Price;

/*
UPDATE Sales 
SET Price = 93.12 -- Dynamic Value 
WHERE ProductID = 51; IN (51,27,33,55,44)
*/

-- Generalized Solution .......

SET SQL_SAFE_UPDATES = 0;

UPDATE sales s
SET Price = (
	SELECT p.price FROM Products p 
    WHERE s.ProductID = p.ProductID
)
WHERE ProductID IN (
	SELECT ProductID FROM Products p
    WHERE p.Price <> s.Price
);

SELECT * FROM Sales WHERE ProductID = 51;

-- Challenge 3 - Fixing Null Values :

SELECT * FROM Customers;
SELECT * FROM Customers WHERE Location LIKE "";
SELECT COUNT(*) FROM Customers WHERE Location IS NULL;
SELECT COUNT(*) FROM Customers WHERE Location LIKE "";

-- Update the Location Column with Unknown
UPDATE Customers
SET Location = "Unknown"
WHERE Location LIKE "";
-- 13 row(s) affected Rows matched: 13  Changed: 13  Warnings: 0

-- Challenge 4 : Cleaning Date
SELECT * FROM Sales;
DESC Sales;

CREATE TABLE sales_updates AS 
SELECT 
    TransactionID,
    CustomerID,
    ProductID,
    QuantityPurchased,
    Price,
    STR_TO_DATE(TransactionDate,'%d/%m/%y') AS TransactionDate_updated
FROM Sales;

SELECT * FROM sales_updates;

DROP TABLE Sales;

ALTER TABLE sales_updates RENAME TO Sales;

-- Challenge 5 : Total Sales Summary

SELECT * FROM Sales; 

SELECT
    ProductID,
    SUM(QuantityPurchased) AS TotalUnitsSold,
    ROUND(SUM(QuantityPurchased * Price),2) AS TotalSales
FROM Sales
GROUP BY 1
Order BY 3 DESC;

-- Challenge 6 : Customer Purchase Frequency ....

SELECT * FROM Sales; 

SELECT 
    CustomerID,
    COUNT(*) AS NumberOfTrasactions
FROM Sales
GROUP BY 1
ORDER BY 2 DESC;

-- Challenge 7 : Product Categories Performance 

SELECT * FROM Sales;
SELECT * FROM Products;

SELECT 
    p.Category,
    SUM(s.QuantityPurchased) AS TotalUnitsSold,
    ROUND(SUM(s.QuantityPurchased * s.Price),2) AS TotalSales
FROM Products p
JOIN Sales s 
ON p.ProductID = s.ProductID
GROUP BY 1
ORDER BY 3 DESC;

-- Challenge 8 : High Sales Products

SELECT * FROM Sales;

SELECT 
    ProductID,
    ROUND(SUM(QuantityPurchased * Price),2) AS TotalRevenue
FROM Sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Challenge 9 : Low Sales Products

SELECT * FROM Sales;

SELECT
	ProductID,
    SUM(QuantityPurchased) AS TotalUnitsSold
FROM Sales
GROUP BY ProductID
HAVING TotalUnitsSold > 0
ORDER BY TotalUnitsSold
LIMIT 10;

-- Challenge 10 : Sales Trend

SELECT * FROM Sales;

SELECT
    TransactionDate_updated AS DATETRANS,
    COUNT(*) AS Transaction_count,
    SUM(QuantityPurchased) AS TotalSoldUnits,
    ROUND(SUM(QuantityPurchased * Price),2) AS Totalsales
FROM Sales
GROUP BY 1
ORDER BY 1 DESC;

-- Challenge 11 : Growth Rate of Sales

SELECT * FROM Sales;

WITH MonthlySales AS (
	SELECT
		EXTRACT(MONTH FROM TransactionDate_updated) AS month,
        ROUND(SUM(QuantityPurchased * Price) , 2) AS total_sales
	FROM Sales
    GROUP BY 1
)
SELECT 
	month,
    total_sales,
    LAG(total_sales) OVER(ORDER BY month) AS previous_month_sales,
    ROUND(((total_sales - LAG(total_sales) OVER(ORDER BY month)) / 
    LAG(total_sales) OVER(ORDER BY month)) * 100 , 2) AS mom_growth_percentage
FROM MonthlySales
ORDER BY month;

-- Challenge 12 : High Purchase Frequency
SELECT * FROM Sales;

SELECT
	CustomerID,
    COUNT(TransactionID) AS NumberOfTransactions,
    ROUND(SUM(QuantityPurchased * Price) , 2) As TotalSpent
FROM Sales
GROUP BY CustomerID
HAVING NumberOfTransactions > 10 AND TotalSpent > 1000
ORDER BY TotalSpent DESC;











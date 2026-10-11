--Cleaning of Inventory_data
--1. DROP EXISTING TABLES
DROP TABLE IF EXISTS My_Inventory;

--2. CREATE RAW TABLE
CREATE TABLE  My_Inventory(
--Stock Keeping Unit Every product has UNIQUE ID
    SKU VARCHAR(20),
	Category VARCHAR(50),
	Size_Of_Product VARCHAR(10),
	Unit_In_Stock INT,
	Unit_Sold_7d INT,
	Unit_Sold_30d INT,
    Unit_Sold_60d INT,
	Days_of_inventory_left NUMERIC(10,1),
    Dead_stock_flag CHAR(1),
    inventory_date DATE
);

-- 3. LOAD RAW DATA
COPY  My_Inventory(
    SKU,
    Category, 
	Size_Of_Product, 
	Unit_In_Stock, 
	Unit_Sold_7d, 
	Unit_Sold_30d, 
    Unit_Sold_60d,
	Days_of_inventory_left, 
    Dead_stock_flag,
    inventory_date 
)
FROM 'D:\E-Commerce_Analysis\inventory_snapshots.csv'
DELIMITER ','
CSV HEADER;

---- 4. INITIAL DATA CHECK
SELECT * FROM My_Inventory;

SELECT COUNT(*) FROM My_Inventory;

-- 5. CREATE CLEANING TABLE
DROP TABLE IF EXISTS MyInventroy_clean;

CREATE TABLE MyInventroy_clean AS
SELECT *
FROM My_Inventory;

-- 6. VIEW CLEANING TABLE
SELECT * FROM  MyInventroy_clean;

-- 10. find Null value in each column
SELECT 
COUNT(*) - COUNT(SKU) AS SKU_null,
COUNT(*) - COUNT(cATEGORY) AS Customer_name_null,
COUNT(*) - COUNT(size_Of_Product) AS Size_Of_Product_Null,
COUNT(*) - COUNT(Unit_In_Stock) AS Unit_In_Stock_null,
COUNT(*) - COUNT(Unit_Sold_7d ) AS  Unit_Sold_7d_null,
COUNT(*) - COUNT(Unit_Sold_30d) AS  Unit_Sold_7d_null,
COUNT(*) - COUNT(Unit_Sold_60d) AS  Unit_Sold_7d_null,
COUNT(*) - COUNT(days_of_inventory_left) AS  days_of_inventory_left_null,
COUNT(*) - COUNT(dead_stock_flag) AS dead_stock_flag_null,
COUNT(*) - COUNT(inventory_date) AS inventory_date_null
From MyInventroy_clean;

--7. Blank / empty values check
SELECT *
FROM  MyInventroy_clean
WHERE TRIM(sku) = ''
OR TRIM(category) = ''
OR TRIM(Size_Of_Product) = ''
OR TRIM(Dead_stock_flag) = '';

-- 8. CHECK DUPLICATE RECORDS
SELECT SKU, COUNT(*)
FROM MyInventroy_clean
GROUP BY SKU
HAVING COUNT(*) > 1;

--9 SKU + Date should identify one inventory snapshot
SELECT
    SKU,inventory_date,
    COUNT(*) AS occurrence_count
FROM MyInventroy_clean
GROUP BY SKU,inventory_date
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

-- 10. NUMERIC VALUES VALIDATION
-- Negative values should not exist
SELECT * FROM MyInventroy_clean
WHERE Unit_In_Stock < 0
OR Unit_Sold_7d < 0
OR Unit_Sold_30d < 0
OR Unit_Sold_60d < 0
OR Days_of_inventory_left < 0;

-- 11. LOGICAL CONSISTENCY CHECK
-- 60-day sales >= 30-day sales >= 7-day sales
SELECT *
FROM MyInventroy_clean
WHERE Unit_Sold_30d < Unit_Sold_7d
   OR Unit_Sold_60d < Unit_Sold_30d;

-- 12. DEAD STOCK FLAG VALIDATION
-- Expected values: Y / N
SELECT DISTINCT Dead_stock_flag
FROM MyInventroy_clean
ORDER BY Dead_stock_flag;

-- 13. CATEGORY VALIDATION
-- Check unique category values
SELECT DISTINCT Category
FROM MyInventroy_clean
ORDER BY Category;

-- 14. SIZE VALIDATION
-- Check unique size values
SELECT DISTINCT  Size_Of_Product
FROM MyInventroy_clean
GROUP BY Size_Of_Product;


-- 16. DATE RANGE CHECK
SELECT
    MIN(inventory_date) AS earliest_date,
    MAX(inventory_date) AS latest_date
FROM MyInventroy_clean;

-- 17. FUTURE DATE CHECK
SELECT *
FROM  MyInventroy_clean
WHERE inventory_date > CURRENT_DATE;

-- 18. FINAL ROW COUNT
SELECT COUNT(*) AS total_clean_rows
FROM MyInventroy_clean;
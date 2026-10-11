-- CREATE AND LOAD THE RAW SKU Catalogs TABLE

DROP TABLE IF EXISTS SKU_Catalogs;
--Cleaning on SKU Catalogs dataset
 CREATE TABLE SKU_Catalogs (
 SKU VARCHAR(50),
 Category VARCHAR(50),
 Vendor VARCHAR(100),
 MRP INTEGER,
 Cost_Per_Unit NUMERIC(10,2)
);
-- Load data from the CSV file 
COPY SKU_Catalogs(
 SKU,
 Category,
 Vendor ,
 MRP ,
 Cost_Per_Unit 
)
FROM 'D:\E-Commerce_Analysis\sku_catalog.csv'
DELIMITER ','
CSV HEADER;

--check the loaded dataset
SELECT * FROM SKU_Catalogs;

--Check the total number of rows loaded
SELECT COUNT(*) AS Total_Row
FROM SKU_Catalogs;

--Create table for cleaning process
DROP TABLE IF EXISTS Clean_SKU_Catalogs;

CREATE TABLE Clean_SKU_Catalogs AS
SELECT * FROM SKU_Catalogs ;

--check the cleaning dataset
SELECT * FROM Clean_SKU_Catalogs;

--Check the total number of rows in cleaning daataset
SELECT COUNT(*) AS Total_Row
FROM Clean_SKU_Catalogs;

--Check null value 
SELECT 
COUNT(*) FILTER (WHERE SKU IS NULL) AS NULL_SKU,
COUNT(*) FILTER (WHERE Category IS NULL) AS NULL_Category,
COUNT(*) FILTER (WHERE Vendor  IS NULL) AS NULL_Vendor ,
COUNT(*) FILTER (WHERE MRP IS NULL) AS NULL_MRP,
COUNT(*) FILTER (WHERE Cost_Per_Unit IS NULL) AS NULL_Cost_Per_Unit
FROM Clean_SKU_Catalogs;

--Check Blank Value
SELECT * FROM Clean_SKU_Catalogs
WHERE TRIM(SKU) = ''
OR TRIM(Category) = ''
OR TRIM(Vendor) = '';


--CHECK duplicate row
SELECT
 SKU,
 Category,
 Vendor ,
 MRP ,
 Cost_Per_Unit ,
 COUNT(*) AS Duplicate_Count
 FROM Clean_SKU_Catalogs
 GROUP BY SKU,Category,Vendor ,MRP ,Cost_Per_Unit 
 HAVING COUNT(*)> 1;
 
 --CHECK FOR INVALID NUMERIC VALUES
SELECT * FROM Clean_SKU_Catalogs
WHERE MRP <=0
OR Cost_Per_Unit <= 0;

--Check distinct category
SELECT  
Category AS Category,
COUNT(*) AS Total_Category
FROM Clean_SKU_Catalogs
GROUP BY Category
ORDER BY Total_Category DESC;

SELECT
DISTINCT Vendor
FROM Clean_SKU_Catalogs;

-- Check for duplicate SKUs
SELECT
    SKU,
    COUNT(*) AS SKU_Count
FROM Clean_SKU_Catalogs
GROUP BY SKU
HAVING COUNT(*) > 1;

-- Check products where cost is greater than or equal to MRP
SELECT * FROM Clean_SKU_Catalogs
WHERE Cost_Per_Unit >= MRP;

-- Review MRP and cost ranges
SELECT
    MIN(MRP) AS Minimum_MRP,
    MAX(MRP) AS Maximum_MRP,
    ROUND(AVG(MRP),2) AS Average_MRP,

    MIN(Cost_Per_Unit) AS Minimum_Cost_per_unit,
    MAX(Cost_Per_Unit) AS Maximum_Cost_per_unit,
    ROUND(AVG(Cost_Per_Unit),2) AS Average_Cost_per_unit
FROM Clean_SKU_Catalogs;
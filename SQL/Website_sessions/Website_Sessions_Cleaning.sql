-- WEBSITE SESSIONS DATASET

-- Drop existing table
DROP TABLE IF EXISTS Website_Sessions;

-- Create raw table
CREATE TABLE Website_Sessions (
    Session_ID VARCHAR(50),
    MyDate DATE,
    Traffic_Source VARCHAR(50),
    Campaign_Name VARCHAR(100),
    Device_Category VARCHAR(50),
    City VARCHAR(100),
    Sessions INTEGER,
    Product_Views INTEGER,
    Add_To_Cart INTEGER,
    Begin_Checkout INTEGER,
    Purchased INTEGER,
    Order_ID VARCHAR(50),
    Customer_ID VARCHAR(50),
    Revenue NUMERIC(12,2)
);

-- Load data from CSV
COPY Website_Sessions (
    Session_ID,
    MyDate,
    Traffic_Source,
    Campaign_Name,
    Device_Category,
    City,
    Sessions,
    Product_Views,
    Add_To_Cart,
    Begin_Checkout,
    Purchased,
    Order_ID,
    Customer_ID,
    Revenue
)
FROM 'D:\E-Commerce_Analysis\website_sessions.csv'
DELIMITER ','
CSV HEADER;

-- Preview raw data

SELECT *
FROM Website_Sessions
LIMIT 10;

-- Check total number of columns

SELECT COUNT(*) AS Total_Columns
FROM information_schema.columns
WHERE table_name = 'website_sessions';

-- Check total number of rows
SELECT COUNT(*) AS Total_Rows
FROM Website_Sessions;

--CREATE CLEAN TABLE
DROP TABLE IF EXISTS Clean_WebsiteSessions

-- Create clean table
CREATE TABLE Clean_WebsiteSessions AS
SELECT * FROM Website_Sessions;

-- Preview clean data
SELECT*FROM Clean_WebsiteSessions
LIMIT 10;

-- Check total rows
SELECT COUNT(*) AS Total_Rows
FROM Clean_WebsiteSessions;


-- Check NULL values in all columns
SELECT
    COUNT(*) FILTER (WHERE Session_ID IS NULL) AS Session_ID_NULL,
    COUNT(*) FILTER (WHERE MyDate IS NULL) AS MyDate_NULL,
    COUNT(*) FILTER (WHERE Traffic_Source IS NULL) AS Traffic_Source_NULL,
    COUNT(*) FILTER (WHERE Campaign_Name IS NULL) AS Campaign_Name_NULL,
    COUNT(*) FILTER (WHERE Device_Category IS NULL) AS Device_Category_NULL,
    COUNT(*) FILTER (WHERE City IS NULL) AS City_NULL,
    COUNT(*) FILTER (WHERE Sessions IS NULL) AS Sessions_NULL,
    COUNT(*) FILTER (WHERE Product_Views IS NULL) AS Product_Views_NULL,
    COUNT(*) FILTER (WHERE Add_To_Cart IS NULL) AS Add_To_Cart_NULL,
    COUNT(*) FILTER (WHERE Begin_Checkout IS NULL) AS Begin_Checkout_NULL,
    COUNT(*) FILTER (WHERE Purchased IS NULL) AS Purchased_NULL,
    COUNT(*) FILTER (WHERE Order_ID IS NULL) AS Order_ID_NULL,
    COUNT(*) FILTER (WHERE Customer_ID IS NULL) AS Customer_ID_NULL,
    COUNT(*) FILTER (WHERE Revenue IS NULL) AS Revenue_NULL
FROM Clean_WebsiteSessions;


-- Check Order_ID and Customer_ID NULLs by purchase status
SELECT 
Purchased,
COUNT(*) AS Total_Rows,
COUNT(*) FILTER(WHERE Order_ID IS NULL) AS NULL_Order_ID,
COUNT(*) FILTER(WHERE Customer_ID IS NULL) AS NULL_Customer_ID
FROM Clean_WebsiteSessions
GROUP BY Purchased
ORDER BY Purchased;

-- Check NULL campaign names by traffic source
SELECT
Traffic_Source,
COUNT(*) AS Null_Campaign_Count
FROM Clean_WebsiteSessions
WHERE Campaign_Name IS NULL
GROUP BY Traffic_Source
ORDER BY Null_Campaign_Count DESC;

--Replace NULL campaign names
UPDATE Clean_WebsiteSessions
SET Campaign_Name = 'No Campaign'
WHERE Campaign_Name IS NULL;

-- Verify remaining NULL campaign names
SELECT
    COUNT(*) FILTER (
        WHERE Campaign_Name IS NULL
    ) AS Remaining_Null_Campaigns
FROM Clean_WebsiteSessions;

--Check duplicate
SELECT 
    Session_ID,
    MyDate,
    Traffic_Source,
    Campaign_Name,
    Device_Category,
    City,
    Sessions,
    Product_Views,
    Add_To_Cart,
    Begin_Checkout,
    Purchased,
    Order_ID,
    Customer_ID,
    Revenue,
COUNT(*) AS Duplicate_Count
FROM  Clean_WebsiteSessions
GROUP BY 
    Session_ID,
    MyDate,
    Traffic_Source,
    Campaign_Name,
    Device_Category,
    City,
    Sessions,
    Product_Views,
    Add_To_Cart,
    Begin_Checkout,
    Purchased,
    Order_ID,
    Customer_ID,
    Revenue
HAVING COUNT(*)>1;

--check blank value 
SELECT * FROM  Clean_WebsiteSessions
WHERE TRIM(Session_ID) = ''
OR TRIM(Traffic_Source) = ''
OR TRIM(Campaign_name)= ''
OR TRIM(Device_Category) = ''
OR TRIM( City) = ''
OR TRIM(Order_ID)= ''
OR TRIM(Customer_ID) = '';

--Check distinc device
SELECT Device_Category,
COUNT(*) AS Total_NoOf_Device
FROM Clean_WebsiteSessions
GROUP BY Device_Category
ORDER BY Total_NoOf_Device;

--Check distinc City
SELECT City,
COUNT(*) AS Total_NoOf_City
FROM Clean_WebsiteSessions
GROUP BY City
ORDER BY Total_NoOf_City DESC;

-- Check traffic sources
SELECT
    Traffic_Source,
    COUNT(*) AS Total_Sessions
FROM Clean_WebsiteSessions
GROUP BY Traffic_Source
ORDER BY Total_Sessions DESC;

-- Check duplicate session IDs
SELECT
    Session_ID,
    COUNT(*) AS Duplicate_Count
FROM Clean_WebsiteSessions
GROUP BY Session_ID
HAVING COUNT(*) > 1;

-- Check dataset date range
SELECT
    MIN(MyDate) AS Start_Date,
    MAX(MyDate) AS End_Date
FROM Clean_WebsiteSessions;

-- Check negative values
SELECT *
FROM Clean_WebsiteSessions
WHERE Sessions < 0
   OR Product_Views < 0
   OR Add_To_Cart < 0
   OR Begin_Checkout < 0
   OR Revenue < 0;

-- Check purchase and revenue consistency
SELECT *
FROM Clean_WebsiteSessions
WHERE
    (Purchased = 1 AND Revenue <= 0)
    OR
    (Purchased = 0 AND Revenue <> 0);

--Review Incomplete Purchase Records
SELECT 
    Traffic_Source,
    Campaign_Name,
    Device_Category,
    COUNT(*) AS Incomplete_Purchase_Records
FROM Clean_WebsiteSessions
WHERE Purchased = 1
  AND Revenue = 0
  AND Order_ID IS NULL
  AND Customer_ID IS NULL
  Group BY
    Traffic_Source,
    Campaign_Name,
    Device_Category
	ORDER BY Incomplete_Purchase_Records;
  
-- Check incomplete purchase records across traffic sources
SELECT
    Traffic_Source,
    COUNT(*) AS Incomplete_Purchase_Records
FROM Clean_WebsiteSessions
WHERE Purchased = 1
  AND Revenue = 0
  AND Order_ID IS NULL
  AND Customer_ID IS NULL
GROUP BY Traffic_Source
ORDER BY Incomplete_Purchase_Records DESC;

-- Check funnel activity in incomplete purchase records
SELECT
    Device_Category,
    MIN(Product_Views) AS Min_Product_Views,
    MAX(Product_Views) AS Max_Product_Views,
    MIN(Add_To_Cart) AS Min_Add_To_Cart,
    MAX(Add_To_Cart) AS Max_Add_To_Cart,
    MIN(Begin_Checkout) AS Min_Begin_Checkout,
    MAX(Begin_Checkout) AS Max_Begin_Checkout,
    COUNT(*) AS Total_Records
FROM Clean_WebsiteSessions
WHERE Purchased = 1
  AND Revenue = 0
  AND Order_ID IS NULL
  AND Customer_ID IS NULL
GROUP BY Device_Category
ORDER BY Total_Records DESC;

-- Check funnel combinations
SELECT
    Product_Views,
    Add_To_Cart,
    Begin_Checkout,
	Purchased,
    COUNT(*) AS Total_Records
FROM Clean_WebsiteSessions
WHERE Purchased = 1
  AND Revenue = 0
  AND Order_ID IS NULL
  AND Customer_ID IS NULL
GROUP BY Product_Views, Add_To_Cart, Begin_Checkout,Purchased
ORDER BY Total_Records DESC;

-- Add purchase data quality status
ALTER TABLE Clean_WebsiteSessions
ADD COLUMN Purchase_Data_Status VARCHAR(30);

-- Classify purchase records
UPDATE Clean_WebsiteSessions
SET Purchase_Data_Status =
    CASE
        WHEN Purchased = 1
             AND Revenue > 0
             AND Order_ID IS NOT NULL
             AND Customer_ID IS NOT NULL
        THEN 'Valid Purchase'

        WHEN Purchased = 1
             AND Revenue = 0
             AND Order_ID IS NULL
             AND Customer_ID IS NULL
        THEN 'Incomplete Purchase'

        WHEN Purchased = 0
        THEN 'No Purchase'

        ELSE 'Review Required'
    END;

--check the Purchase_Data_Status
SELECT
    Purchase_Data_Status,
    COUNT(*) AS Total_Records
FROM Clean_WebsiteSessions
GROUP BY Purchase_Data_Status
ORDER BY Total_Records DESC;


-- WEBSITE Daily DATASET
DROP TABLE IF EXISTS Website_Daily;

CREATE TABLE Website_Daily (
    MyDate DATE,
    Traffic_Source VARCHAR(50),
    Campaign_Name VARCHAR(100),
    Device_Category VARCHAR(50),
    Sessions INTEGER,
    Product_Views INTEGER,
    Add_To_Cart INTEGER,
    Begin_Checkout INTEGER,
    Purchases INTEGER,
    Revenue NUMERIC(12,2),
    Conversion_Rate NUMERIC(10,4),
    AOV NUMERIC(12,2),
    Country VARCHAR(50),
    City VARCHAR(100),
    Purchased INTEGER
);
COPY Website_Daily(
    MyDate ,
    Traffic_Source ,
    Campaign_Name ,
    Device_Category ,
    Sessions ,
    Product_Views ,
    Add_To_Cart ,
    Begin_Checkout ,
    Purchases ,
    Revenue ,
    Conversion_Rate ,
    AOV ,
    Country ,
    City ,
    Purchased 
)
FROM 'D:\E-Commerce_Analysis\website_daily.csv'
DELIMITER ','
CSV HEADER;

--Preview the raw data
SELECT * FROM  Website_Daily
--Check the total number of rows loaded
SELECT COUNT(*) AS Total_Row
FROM Website_Daily;

--Create cleanin table 
DROP TABLE IF EXISTS Clean_Website_Daily

CREATE TABLE Clean_Website_Daily AS
SELECT * FROM Website_Daily;

--CHECK Dataset
SELECT*FROM Clean_Website_Daily;

--Check total no of data
SELECT COUNT(*) 
FROM Clean_Website_Daily;
--check null
SELECT
COUNT(*)FILTER(WHERE  MyDate IS NULL) AS MyDate_NULL,
COUNT(*)FILTER(WHERE  Traffic_Source  IS NULL) AS  Traffic_Source_NULL,
COUNT(*)FILTER(WHERE  Campaign_Name IS NULL) AS  Campaign_Name_NULL,
COUNT(*)FILTER(WHERE  Device_Category IS NULL) AS Device_Category_NULL,
COUNT(*)FILTER(WHERE  Sessions  IS NULL) AS Sessions_NULL,
COUNT(*)FILTER(WHERE  Product_Views IS NULL) AS Product_Views_NULL,
COUNT(*)FILTER(WHERE  Add_To_Cart  IS NULL) AS  Add_To_Cart_NULL,
COUNT(*)FILTER(WHERE  Begin_Checkout IS NULL) AS  Begin_Checkout_NULL,
COUNT(*)FILTER(WHERE  Purchases IS NULL) AS Purchases_NULL,
COUNT(*)FILTER(WHERE  Revenue IS NULL) AS Revenue_NULL,
COUNT(*)FILTER(WHERE Conversion_Rate  IS NULL) AS Conversion_Rate_NULL,
COUNT(*)FILTER(WHERE  AOV IS NULL) AS AOV_NULL,
COUNT(*)FILTER(WHERE  Country  IS NULL) AS  Country_NULL,
COUNT(*)FILTER(WHERE   City IS NULL) AS   City_NULL,
COUNT(*)FILTER(WHERE  Purchased  IS NULL) AS Purchased_NULL
FROM Clean_Website_Daily;

SELECT
    Traffic_Source,
    Campaign_Name,
    COUNT(*) AS Total_Records
FROM Clean_Website_Daily
GROUP BY Traffic_Source, Campaign_Name
ORDER BY Traffic_Source, Campaign_Name;

-- Replace missing campaign names with 'No Campaign'
UPDATE Clean_Website_Daily
SET Campaign_Name = 'No Campaign'
WHERE Campaign_Name IS NULL;

-- Verify that no NULL campaign names remain
SELECT
    COUNT(*) FILTER (
        WHERE Campaign_Name IS NULL
    ) AS Remaining_Null_Campaigns
FROM Clean_Website_Daily;

--check blank value 
SELECT * FROM Clean_Website_Daily
WHERE TRIM(Traffic_Source ) = ''
OR TRIM(Campaign_Name) = ''
OR TRIM(Device_Category) = ''
OR TRIM(Country) = ''
OR TRIM(City) = '';

--check duplicate
--CHECK FOR EXACT DUPLICATE ROWS
SELECT 
Traffic_Source,
MyDate,
Campaign_Name,
Device_Category,
Sessions ,
Product_Views ,
Add_To_Cart,
Begin_Checkout ,
Purchases ,
Revenue ,
Conversion_Rate ,
AOV ,
Country ,
City ,
Purchased,
COUNT(*) AS Duplicate_Count
FROM Clean_Website_Daily
GROUP BY 
Traffic_Source,
MyDate,
Campaign_Name,
Device_Category,
Sessions ,
Product_Views ,
Add_To_Cart,
Begin_Checkout ,
Purchases ,
Revenue ,
Conversion_Rate ,
AOV ,
Country ,
City ,
Purchased 
HAVING COUNT(*)>1;

--check distinct exists city
SELECT 
DISTINCT City,
COUNT(City) AS Total_City
FROM Clean_Website_Daily
GROUP BY City
ORDER BY Total_City DESC;

--Check distinct country
SELECT 
DISTINCT Country,
COUNT(Country) AS Total_Country
FROM Clean_Website_Daily
GROUP BY Country
ORDER BY Total_Country DESC;

--check date range
SELECT
    MIN(MyDate) AS Start_Date,
    MAX(MyDate) AS End_Date
FROM Clean_Website_Daily;

---- Check for negative values
SELECT *
FROM Clean_Website_Daily
WHERE Sessions < 0
   OR Product_Views < 0
   OR Add_To_Cart < 0
   OR Begin_Checkout < 0
   OR Purchases < 0
   OR Revenue < 0
   OR Conversion_Rate < 0
   OR AOV < 0;


 -- Review unusual funnel relationships
SELECT *
FROM Clean_Website_Daily
WHERE Purchases > Begin_Checkout
   OR Begin_Checkout > Add_To_Cart;

-- Check purchase and revenue consistency
SELECT *
FROM Clean_Website_Daily
WHERE
    (Purchases > 0 AND Revenue <= 0)
    OR
    (Purchases = 0 AND Revenue > 0);


-- Check activity when sessions are zero
SELECT *
FROM Clean_Website_Daily
WHERE Sessions = 0
  AND (
        Product_Views > 0
        OR Add_To_Cart > 0
        OR Begin_Checkout > 0
        OR Purchases > 0
        OR Revenue > 0
      );
---- Review city and country combinations
SELECT
    Country,
    City,
    COUNT(*) AS Total_Records
FROM Clean_Website_Daily
GROUP BY Country, City
ORDER BY Country, City;

-- Check invalid conversion rates
SELECT *
FROM Clean_Website_Daily
WHERE Conversion_Rate < 0
   OR Conversion_Rate > 1;

-- Validate purchased flag
--Purchases happened, but the Purchased flag is not 1.
--No purchases happened, but the Purchased flag is not 0.
SELECT *
FROM Clean_Website_Daily
WHERE
    (Purchases > 0 AND Purchased <> 1)
    OR
    (Purchases = 0 AND Purchased <> 0);
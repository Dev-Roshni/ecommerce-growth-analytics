/*Maine ads par paisa lagaya.Kitne logon ne ad dekha? 
Kitne click kiye? Kitne product cart mein dale?
Kitne ne purchase kiya? Kitna revenue aaya?
Aur mera advertising paisa worth it tha ya nahi?"
*/
--DATA CLEANING
DROP TABLE IF EXISTS Campaign_Info;

--create table 
CREATE TABLE Campaign_Info(
   Campaign_Date DATE,
    Campaign_Name VARCHAR(100),
    Adset_Name VARCHAR(100),
    Results INT,
    Amount_Spent_INR NUMERIC(15,2),
    Spend NUMERIC(15,2),
    Reach INT,
    Impressions INT,
    Frequency NUMERIC(10,2),
    Link_Clicks INT,
    CTR_Link NUMERIC(10,4),
    Add_To_Cart INT,
    Initiate_Checkout INT,
    Purchases INT,
    Purchase_Conversion_Value NUMERIC(15,2),
    CAC NUMERIC(15,2),
    ROAS NUMERIC(10,2),
    Creative_Type VARCHAR(50),
    Launch_Date DATE,
    Hook_Rate NUMERIC(10,4)
);
-- 3. LOAD RAW DATA
copy Campaign_Info(
    Campaign_Date,
    Campaign_Name,
    Adset_Name,
    Results,
    Amount_Spent_INR,
    Spend,
    Reach,
    Impressions,
    Frequency,
    Link_Clicks,
    CTR_Link,
    Add_To_Cart,
    Initiate_Checkout,
    Purchases,
    Purchase_Conversion_Value,
    CAC,
    ROAS,
    Creative_Type,
    Launch_Date,
    Hook_Rate
)

FROM 'D:/E-Commerce_Analysis/meta_ads_campaigns.csv'
DELIMITER ','
CSV HEADER ;


---- 4. INITIAL DATA CHECK
-- View all records
SELECT * FROM Campaign_Info;

-- Check total number of rows
SELECT COUNT(*) AS Total_Rows
FROM Campaign_Info;

-- Check total number of columns
SELECT COUNT(*) AS Total_Columns
FROM information_schema.columns
WHERE table_name = 'campaign_info';

-- 5. CREATE CLEANING TABLE
DROP TABLE IF EXISTS CampaignInfo_Clean;

CREATE TABLE CampaignInfo_Clean AS
SELECT *
FROM Campaign_Info;

-- VIEW CLEANING TABLE
SELECT * FROM  CampaignInfo_Clean;

-- 6. CHECK NULL VALUES
--    Find missing values in every column
SELECT
    COUNT(*) FILTER (WHERE Campaign_Date IS NULL) AS Campaign_Date_Null,
    COUNT(*) FILTER (WHERE Campaign_Name IS NULL) AS Campaign_Name_Null,
    COUNT(*) FILTER (WHERE Adset_Name IS NULL) AS Adset_Name_Null,
    COUNT(*) FILTER (WHERE Results IS NULL) AS Results_Null,
    COUNT(*) FILTER (WHERE Amount_Spent_INR IS NULL) AS Amount_Spent_INR_Null,
    COUNT(*) FILTER (WHERE Spend IS NULL) AS Spend_Null,
    COUNT(*) FILTER (WHERE Reach IS NULL) AS Reach_Null,
    COUNT(*) FILTER (WHERE Impressions IS NULL) AS Impressions_Null,
    COUNT(*) FILTER (WHERE Frequency IS NULL) AS Frequency_Null,
    COUNT(*) FILTER (WHERE Link_Clicks IS NULL) AS Link_Clicks_Null,
    COUNT(*) FILTER (WHERE CTR_Link IS NULL) AS CTR_Link_Null,
    COUNT(*) FILTER (WHERE Add_To_Cart IS NULL) AS Add_To_Cart_Null,
    COUNT(*) FILTER (WHERE Initiate_Checkout IS NULL) AS Initiate_Checkout_Null,
    COUNT(*) FILTER (WHERE Purchases IS NULL) AS Purchases_Null,
    COUNT(*) FILTER (WHERE Purchase_Conversion_Value IS NULL) AS Purchase_Conversion_Value_Null,
    COUNT(*) FILTER (WHERE CAC IS NULL) AS CAC_Null,
    COUNT(*) FILTER (WHERE ROAS IS NULL) AS ROAS_Null,
    COUNT(*) FILTER (WHERE Creative_Type IS NULL) AS Creative_Type_Null,
    COUNT(*) FILTER (WHERE Launch_Date IS NULL) AS Launch_Date_Null,
    COUNT(*) FILTER (WHERE Hook_Rate IS NULL) AS Hook_Rate_Null
FROM  CampaignInfo_Clean;;

-- 7. CHECK BLANK / EMPTY VALUES
--    Check empty text values
SELECT *
FROM  CampaignInfo_Clean
WHERE TRIM(Campaign_Name) = ''
   OR TRIM(Adset_Name) = ''
   OR TRIM(Creative_Type) = '';

-- 8. CHECK DUPLICATE COLUMN
--    Check whether Amount_Spent_INR and Spend contain the same information
SELECT
    COUNT(*) AS Total_Rows,
   COUNT(*) FILTER(WHERE Amount_Spent_INR = Spend) AS Same_Value,
   COUNT(*) FILTER(WHERE Amount_Spent_INR <> Spend) AS Different_Values
   FROM  CampaignInfo_Clean;

-- Check Results = Link Clicks
SELECT
    COUNT(*) AS Total_Rows,
   COUNT(*) FILTER(WHERE Results = Link_Clicks) AS Same_Value,
   COUNT(*) FILTER(WHERE Results <> Link_Clicks) AS Different_Values
   FROM  CampaignInfo_Clean;
   

-- 9. REMOVE REDUNDANT COLUMN
--    Remove Spend because it duplicates Amount_Spent_INR
ALTER TABLE  CampaignInfo_Clean
DROP COLUMN Spend ;

-- REMOVE REDUNDANT COLUMN
ALTER TABLE  CampaignInfo_Clean
DROP COLUMN Results;

-- 10. CHECK FINAL COLUMN COUNT
--Confirm that one duplicate column was removed

SELECT COUNT(*) AS Total_Columns
FROM information_schema.columns
WHERE table_name = 'campaigninfo_clean';

-- 11. CHECK COLUMN NAMES AND DATA TYPES
--Make sure all remaining columns have correct data types
SELECT 
Ordinal_Position,
Column_Name,
Data_Type
FROM Information_Schema.Columns
WHERE Table_Name =  'campaigninfo_clean'
ORDER BY Ordinal_Position;

-- 12. CHECK DATE RANGE
--Understand the time period covered by the dataset
SELECT
    MIN(Campaign_Date) AS Min_Campaign_Date,
    MAX(Campaign_Date) AS Max_Campaign_Date,
    MIN(Launch_Date) AS Min_Launch_Date,
    MAX(Launch_Date) AS Max_Launch_Date
FROM campaigninfo_clean;

-- 13. CHECK CREATIVE TYPES
--Find different types of advertisements
SELECT 
Creative_Type,
COUNT(*) AS Total_ADS
FROM campaigninfo_clean
GROUP BY Creative_Type
ORDER BY Total_ADS DESC;

-- 14. CHECK DUPLICATE ROWS
--Find completely duplicate records
SELECT
    Campaign_Date,
    Campaign_Name,
    Adset_Name,
    Amount_Spent_INR,
    Reach,
    Impressions,
    Frequency,
    Link_Clicks,
    CTR_Link,
    Add_To_Cart,
    Initiate_Checkout,
    Purchases,
    Purchase_Conversion_Value,
    CAC,
    ROAS,
    Creative_Type,
    Launch_Date,
    Hook_Rate,
    COUNT(*) AS Duplicate_Count
FROM CampaignInfo_Clean
GROUP BY 
 Campaign_Date,
    Campaign_Name,
    Adset_Name,
    Amount_Spent_INR,
    Reach,
    Impressions,
    Frequency,
    Link_Clicks,
    CTR_Link,
    Add_To_Cart,
    Initiate_Checkout,
    Purchases,
    Purchase_Conversion_Value,
    CAC,
    ROAS,
    Creative_Type,
    Launch_Date,
    Hook_Rate
HAVING COUNT(*) > 1;

-- 15. CHECK NEGATIVE VALUES
--These marketing metrics should normally not be negative
SELECT *
FROM CampaignInfo_Clean
WHERE Amount_Spent_INR < 0
   OR Reach < 0
   OR Impressions < 0
   OR Frequency < 0
   OR Link_Clicks < 0
   OR CTR_Link < 0
   OR Add_To_Cart < 0
   OR Initiate_Checkout < 0
   OR Purchases < 0
   OR Purchase_Conversion_Value < 0
   OR CAC < 0
   OR ROAS < 0
   OR Hook_Rate < 0;
   
--Link_Clicks -> Add_To_Cart -> Initiate_Checkout -> Purchases
-- 16. FUNNEL CONSISTENCY CHECK
---This identifies unusual/inconsistent rows.

SELECT COUNT(*) AS Inconsistent_Row
FROM CampaignInfo_Clean
WHERE Link_Clicks < Add_To_Cart
OR Add_To_Cart < Initiate_Checkout
OR Initiate_Checkout < Purchases;

-- View the problematic funnel rows

SELECT
    Campaign_Name,
    Link_Clicks,
    Add_To_Cart,
    Initiate_Checkout,
    Purchases
FROM CampaignInfo_Clean
WHERE Link_Clicks < Add_To_Cart
OR Add_To_Cart < Initiate_Checkout
OR Initiate_Checkout < Purchases;

-- 17. VALIDATE FREQUENCY
--Frequency = Impressions / Reach

SELECT
    Campaign_Name,
    Frequency,
	 ROUND(
        Impressions::NUMERIC / NULLIF(Reach, 0),2)
		AS Calculated_Frequency
FROM CampaignInfo_Clean;

-- 18. VALIDATE CTR
--     CTR = Link Clicks / Impressions
SELECT
    Campaign_Name,
    CTR_Link,
    ROUND(
        Link_Clicks::NUMERIC / NULLIF(Impressions, 0),
        4
    ) AS Calculated_CTR
FROM CampaignInfo_Clean;

-- 19. VALIDATE CAC
-- CAC = Advertising Spend / Purchases
SELECT
    Campaign_Name,
    CAC,
    ROUND(
        Amount_Spent_INR / NULLIF(Purchases, 0),
        2
    ) AS Calculated_CAC
FROM CampaignInfo_Clean;

-- 20. VALIDATE ROAS
--     ROAS = Purchase Conversion Value / Ad Spend
SELECT
    Campaign_Name,
    ROAS,
    ROUND(
        Purchase_Conversion_Value /
        NULLIF(Amount_Spent_INR, 0),
        2
    ) AS Calculated_ROAS
FROM CampaignInfo_Clean;



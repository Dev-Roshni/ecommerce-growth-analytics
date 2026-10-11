--EDA 
--1 Overall Performance
SELECT
    SUM(Sessions) AS Total_Sessions,
    SUM(Product_Views) AS Total_Product_Views,
    SUM(Add_To_Cart) AS Total_Add_To_Cart,
    SUM(Begin_Checkout) AS Total_Checkouts,
    SUM(Revenue) AS Total_Revenue,
    SUM(Purchased) AS Total_Purchases
FROM Clean_WebsiteSessions;

--2 Traffic source performance

SELECT
    Traffic_Source,
    COUNT(*) AS Total_Sessions,
    SUM(Revenue) AS Total_Revenue,
	 SUM(Purchased) AS Total_Purchases,
    ROUND(
        SUM(Purchased) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Conversion_Rate_Percent,
	ROUND(
        SUM(Revenue) / NULLIF(SUM(Purchased), 0),
        2
    ) AS AOV
FROM Clean_WebsiteSessions
GROUP BY Traffic_Source
ORDER BY Total_Revenue DESC;

--3 Device-wise website performance
SELECT 
    Device_Category,
    SUM(Sessions) AS Total_Sessions,
    SUM(Product_Views) AS Total_Product_Views,
    SUM(Add_To_Cart) AS Total_Add_To_Cart,
    SUM(Begin_Checkout) AS Total_Checkouts,
    SUM(Purchased) AS Total_Purchases,
    SUM(Revenue) AS Total_Revenue,
	 ROUND(
        SUM(Purchased) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Conversion_Rate_Percent
FROM Clean_WebsiteSessions
GROUP BY Device_Category
ORDER BY Total_Revenue DESC;

--4 Overall conversion funnel
SELECT
    SUM(Sessions) AS Total_Sessions,
    SUM(Product_Views) AS Total_Product_Views,
    SUM(Add_To_Cart) AS Total_Add_To_Cart,
    SUM(Begin_Checkout) AS Total_Checkouts,
    SUM(Purchased) AS Total_Purchases,

    ROUND(
        SUM(Product_Views) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Session_To_View_Percent,

    ROUND(
        SUM(Add_To_Cart) * 100.0
        / NULLIF(SUM(Product_Views), 0),
        2
    ) AS View_To_Cart_Percent,

    ROUND(
        SUM(Begin_Checkout) * 100.0
        / NULLIF(SUM(Add_To_Cart), 0),
        2
    ) AS Cart_To_Checkout_Percent,

    ROUND(
        SUM(Purchased) * 100.0
        / NULLIF(SUM(Begin_Checkout), 0),
        2
    ) AS Checkout_To_Purchase_Percent,

    ROUND(
        SUM(Purchased) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Overall_Conversion_Rate_Percent

FROM Clean_WebsiteSessions;

--5 Traffic source funnel performance
SELECT
    Traffic_Source,
    SUM(Sessions) AS Total_Sessions,
    SUM(Product_Views) AS Total_Product_Views,
    SUM(Add_To_Cart) AS Total_Add_To_Cart,
    SUM(Begin_Checkout) AS Total_Checkouts,
    SUM(Purchased) AS Total_Purchases,

    ROUND(
        SUM(Purchased) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Conversion_Rate_Percent

FROM Clean_WebsiteSessions
GROUP BY Traffic_Source
ORDER BY Conversion_Rate_Percent DESC;


--6 Campaign vs no campaign performance
SELECT
    CASE
        WHEN Campaign_Name = 'No Campaign'
        THEN 'No Campaign'
        ELSE 'Campaign'
    END AS Campaign_Type,

    SUM(Sessions) AS Total_Sessions,
    SUM(Purchased) AS Total_Purchases,
    SUM(Revenue) AS Total_Revenue,

    ROUND(
        SUM(Purchased) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Conversion_Rate_Percent
FROM  Clean_WebsiteSessions
GROUP BY Campaign_Type
ORDER BY Total_Revenue DESC;

--9 Campaign performance
SELECT
    Campaign_Name,
    SUM(Sessions) AS Total_Sessions,
    SUM(Purchased) AS Total_Purchases,
    SUM(Revenue) AS Total_Revenue,

    ROUND(
        SUM(Purchased) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Conversion_Rate_Percent

FROM  Clean_WebsiteSessions
GROUP BY Campaign_Name
ORDER BY Total_Revenue DESC;

-- 10. Product View and Add-to-Cart Performance

SELECT
    SUM(Product_Views) AS Total_Product_Views,
    SUM(Add_To_Cart) AS Total_Add_To_Cart,

    ROUND(
        SUM(Product_Views) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Session_To_View_Rate,

    ROUND(
        SUM(Add_To_Cart) * 100.0
        / NULLIF(SUM(Product_Views), 0),
        2
    ) AS View_To_Cart_Rate

FROM Clean_WebsiteSessions;

--11 Monthly website performance trend
SELECT
    DATE_TRUNC('month', MyDate)::DATE AS Months,

    SUM(Sessions) AS Total_Sessions,
    SUM(Purchased) AS Total_Purchased,
    SUM(Revenue) AS Total_Revenue,

    ROUND(
        SUM(Purchased) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Conversion_Rate_Percent

FROM  Clean_WebsiteSessions
GROUP BY Months
ORDER BY Months;


--12 City-wise website performance
SELECT 
    City,
    SUM(Sessions) AS Total_Sessions,
    SUM(Purchased) AS Total_Purchases,
    SUM(Revenue) AS Total_Revenue,

    ROUND(
        SUM(Purchased) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Conversion_Rate_Percent

FROM  Clean_WebsiteSessions
GROUP BY City
ORDER BY Total_Revenue DESC;

--13 Traffic source and device performance
SELECT
    Traffic_Source,
    Device_Category,
    SUM(Sessions) AS Total_Sessions,
    SUM(Purchased) AS Total_Purchases,
    SUM(Revenue) AS Total_Revenue,

    ROUND(
        SUM(Purchased) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Conversion_Rate_Percent

FROM Clean_WebsiteSessions
GROUP BY
    Traffic_Source,
    Device_Category
ORDER BY Total_Revenue DESC;

-- 14. Purchase Data Quality Analysis
SELECT
    Purchase_Data_Status,
    COUNT(*) AS Total_Records
FROM Clean_WebsiteSessions
GROUP BY Purchase_Data_Status
ORDER BY Total_Records DESC;
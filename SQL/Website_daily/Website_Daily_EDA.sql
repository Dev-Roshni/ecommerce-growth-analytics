--EDA
---- Overall website performance
SELECT 
SUM(Sessions) AS Total_sessions,
SUM(Purchases) AS Total_Purchase,
SUM(Revenue) AS Total_Revenue,
ROUND(
        SUM(Purchases) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Overall_Conversion_Rate_Percent,

    ROUND(
        SUM(Revenue)
        / NULLIF(SUM(Purchases), 0),
        2
    ) AS Overall_AOV
FROM clean_Website_Daily;

-- Overall website funnel performance
SELECT
    SUM(Sessions) AS Total_Sessions,
    SUM(Product_Views) AS Total_Product_Views,
    SUM(Add_To_Cart) AS Total_Add_To_Cart,
    SUM(Begin_Checkout) AS Total_Begin_Checkout,
    SUM(Purchases) AS Total_Purchases,

    ROUND(
        SUM(Product_Views) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Product_View_Rate_Percent,

    ROUND(
        SUM(Add_To_Cart) * 100.0
        / NULLIF(SUM(Product_Views), 0),
        2
    ) AS Add_To_Cart_Rate_Percent,

    ROUND(
        SUM(Begin_Checkout) * 100.0
        / NULLIF(SUM(Add_To_Cart), 0),
        2
    ) AS Cart_To_Checkout_Rate_Percent,

    ROUND(
        SUM(Purchases) * 100.0
        / NULLIF(SUM(Begin_Checkout), 0),
        2
    ) AS Checkout_To_Purchase_Rate_Percent

FROM Clean_Website_Daily;

-- Traffic source performance
SELECT
    Traffic_Source,
    SUM(Sessions) AS Total_Sessions,
    SUM(Purchases) AS Total_Purchases,
    SUM(Revenue) AS Total_Revenue,

    ROUND(
        SUM(Purchases) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Conversion_Rate_Percent

FROM Clean_Website_Daily
GROUP BY Traffic_Source
ORDER BY Total_Revenue DESC;

-- Campaign performance
SELECT
    Campaign_Name,
    SUM(Sessions) AS Total_Sessions,
    SUM(Purchases) AS Total_Purchases,
    SUM(Revenue) AS Total_Revenue,

    ROUND(
        SUM(Purchases) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Conversion_Rate_Percent

FROM Clean_Website_Daily
GROUP BY Campaign_Name
ORDER BY Total_Revenue DESC;

-- Campaign vs no campaign performance
SELECT
    CASE
        WHEN Campaign_Name = 'No Campaign'
        THEN 'No Campaign'
        ELSE 'Campaign'
    END AS Campaign_Type,

    SUM(Sessions) AS Total_Sessions,
    SUM(Purchases) AS Total_Purchases,
    SUM(Revenue) AS Total_Revenue,

    ROUND(
        SUM(Purchases) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Conversion_Rate_Percent
FROM Clean_Website_Daily
GROUP BY Campaign_Type
ORDER BY Total_Revenue DESC;

-- Device-wise website performance
SELECT
    Device_Category,
    SUM(Sessions) AS Total_Sessions,
    SUM(Purchases) AS Total_Purchases,
    SUM(Revenue) AS Total_Revenue,

    ROUND(
        SUM(Purchases) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Conversion_Rate_Percent

FROM Clean_Website_Daily
GROUP BY Device_Category
ORDER BY Total_Revenue DESC;

--Part 5: Website Funnel Analysis — 3 queries

SELECT
 SUM(Product_Views) AS Total_Product_Views,
 SUM(Add_To_Cart) AS Total_Add_to_Cart,
  ROUND(
        SUM(Product_Views) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Product_View_Rate,

	 ROUND(
        SUM(Add_To_Cart) * 100.0
        / NULLIF(SUM(Product_Views), 0),
        2
    ) AS Product_View_Rate	 
FROM clean_Website_Daily;

-- Checkout to purchase conversion rate
SELECT
    SUM(Begin_Checkout) AS Total_Checkouts,
    SUM(Purchases) AS Total_Purchases,

    ROUND(
        SUM(Purchases) * 100.0
        / NULLIF(SUM(Begin_Checkout), 0),
        2
    ) AS Checkout_To_Purchase_Rate

FROM Clean_Website_Daily;

-- Monthly website performance trend
SELECT
    DATE_TRUNC('month', MyDate)::DATE AS Month,

    SUM(Sessions) AS Total_Sessions,
    SUM(Purchases) AS Total_Purchases,
    SUM(Revenue) AS Total_Revenue,

    ROUND(
        SUM(Purchases) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Conversion_Rate_Percent

FROM Clean_Website_Daily
GROUP BY Month
ORDER BY Month;


-- City-wise website performance
SELECT 
    City,
    SUM(Sessions) AS Total_Sessions,
    SUM(Purchases) AS Total_Purchases,
    SUM(Revenue) AS Total_Revenue,

    ROUND(
        SUM(Purchases) * 100.0
        / NULLIF(SUM(Sessions), 0),
        2
    ) AS Conversion_Rate_Percent

FROM Clean_Website_Daily
GROUP BY City
ORDER BY Total_Revenue DESC;
--EDA Steps

--PART 1 — DATASET OVERVIEW
--1. Total number of records in the dataset 
 
SELECT 
    COUNT(*) AS Total_Records
FROM MyInventroy_Clean;

-- 2. Total number of unique SKUs 
SELECT COUNT(DISTINCT SKU )
FROM MyInventroy_clean;

--3. Total number of unique product categories 
SELECT COUNT(DISTINCT Category) AS Unique_Categories
FROM MyInventroy_clean;

--4. Available product sizes
SELECT DISTINCT 
    Size_Of_Product
FROM MyInventroy_Clean
ORDER BY Size_Of_Product;

--5.Dataset date range
SELECT 
    MIN(inventory_date) AS Start_Date,
    MAX(inventory_date) AS End_Date
FROM MyInventroy_Clean;

--PART 2 — OVERALL INVENTORY OVERVIEW

-- 6. Total units currently available in stock

SELECT SUM(Unit_In_Stock) AS Total_Units_In_Stock
FROM MyInventroy_clean;


/* 7. Average days of inventory remaining */
SELECT 
    ROUND(AVG(Days_of_inventory_left), 2) 
        AS Average_Inventory_Days
FROM MyInventroy_Clean;

/* 8. Inventory days statistical summary */
SELECT 
    MIN(Days_of_inventory_left) AS Min_Inventory_Days,

    ROUND(AVG(Days_of_inventory_left), 2) 
        AS Avg_Inventory_Days,

    PERCENTILE_CONT(0.25)
        WITHIN GROUP (
            ORDER BY Days_of_inventory_left
        ) AS P25,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY Days_of_inventory_left
        ) AS Median_Inventory_Days,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY Days_of_inventory_left
        ) AS P75,

    MAX(Days_of_inventory_left) AS Max_Inventory_Days

FROM MyInventroy_Clean;

--PART 3 — INVENTORY ANALYSIS BY SKU

--9. Average inventory per SKU 

SELECT 
    SKU,
    ROUND(AVG(Unit_In_Stock), 2) AS Avg_Unit_In_Stock
FROM MyInventroy_Clean
GROUP BY SKU
ORDER BY Avg_Unit_In_Stock DESC;

/* 10. Top 10 SKUs with the highest total inventory */
SELECT 
    SKU,
    SUM(Unit_In_Stock) AS Total_Unit_Stock
FROM MyInventroy_Clean
GROUP BY SKU
ORDER BY Total_Unit_Stock DESC
LIMIT 10;

/* 11. Bottom 10 SKUs with the lowest total inventory */
SELECT 
    SKU,
    SUM(Unit_In_Stock) AS Total_Unit_Stock
FROM MyInventroy_Clean
GROUP BY SKU
ORDER BY Total_Unit_Stock ASC
LIMIT 10;

/* 12. SKUs having 90+ days of inventory remaining */
SELECT 
    SKU,
    Days_of_inventory_left
FROM MyInventroy_Clean
WHERE Days_of_inventory_left >= 90
ORDER BY Days_of_inventory_left DESC;

--13. SKUs having less than 30 days of inventory */
SELECT 
    SKU,
    Days_of_inventory_left
FROM MyInventroy_Clean
WHERE Days_of_inventory_left < 30
ORDER BY Days_of_inventory_left ASC;

--PART 4 — SALES PERFORMANCE
/* 14. Total units sold in the last 7 days */

SELECT 
    SUM(Unit_Sold_7d) AS Total_Units_Sold_7d
FROM MyInventroy_Clean;


/* 15. Total units sold in the last 30 days */
SELECT 
    SUM(Unit_Sold_30d) AS Total_Units_Sold_30d
FROM MyInventroy_Clean;

/* 16. Total units sold in the last 60 days */
SELECT 
    SUM(Unit_Sold_60d) AS Total_Units_Sold_60d
FROM MyInventroy_Clean;


/* 17. Average 7-day sales per SKU */
SELECT 
    SKU,
    ROUND(AVG(Unit_Sold_7d), 2) AS Avg_Unit_Sold_7d
FROM MyInventroy_Clean
GROUP BY SKU
ORDER BY Avg_Unit_Sold_7d DESC;


/* 18. Top 10 best-selling SKUs based on 7-day sales */
SELECT 
    SKU,
    SUM(Unit_Sold_7d) AS Total_Units_Sold_7d
FROM MyInventroy_Clean
GROUP BY SKU
ORDER BY Total_Units_Sold_7d DESC
LIMIT 10;

/* 19. Bottom 10 slow-selling SKUs based on 7-day sales */
SELECT 
    SKU,
    SUM(Unit_Sold_7d) AS Total_Units_Sold_7d
FROM MyInventroy_Clean
GROUP BY SKU
ORDER BY Total_Units_Sold_7d ASC
LIMIT 10;

--PART 5 — SALES DISTRIBUTION & CLASSIFICATION
/* 20. Statistical summary of 7-day sales */
SELECT 
    MIN(Unit_Sold_7d) AS Min_7D_Sales,

    ROUND(AVG(Unit_Sold_7d), 2) AS Avg_7D_Sales,

    PERCENTILE_CONT(0.25)
        WITHIN GROUP (
            ORDER BY Unit_Sold_7d
        ) AS P25,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY Unit_Sold_7d
        ) AS Median_7D_Sales,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY Unit_Sold_7d
        ) AS P75,

    MAX(Unit_Sold_7d) AS Max_7D_Sales

FROM MyInventroy_Clean;

/* 21. Classify SKUs based on recent 7-day sales */
SELECT 
    SKU,
    Unit_Sold_7d,
    CASE
        WHEN Unit_Sold_7d <= 1 THEN 'Low Sale'
        WHEN Unit_Sold_7d <= 3 THEN 'Normal Sale'
        WHEN Unit_Sold_7d <= 10 THEN 'High Sale'
        ELSE 'Very High Sale'
    END AS Sales_Status
FROM MyInventroy_Clean;
 
/* 22. Statistical summary of 30-day sales */
SELECT 
    MIN(Unit_Sold_30d) AS Min_30D_Sales,

    ROUND(AVG(Unit_Sold_30d), 2) AS Avg_30D_Sales,

    PERCENTILE_CONT(0.25)
        WITHIN GROUP (
            ORDER BY Unit_Sold_30d
        ) AS P25,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY Unit_Sold_30d
        ) AS Median_30D_Sales,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY Unit_Sold_30d
        ) AS P75,

    MAX(Unit_Sold_30d) AS Max_30D_Sales
	FROM MyInventroy_Clean;

/* 23. Classify SKUs based on 30-day sales */
SELECT 
    SKU,
    Unit_Sold_30d,

    CASE
        WHEN Unit_Sold_30d <= 3 
            THEN 'Low Sale'

        WHEN Unit_Sold_30d <= 6 
            THEN 'Normal Sale'

        WHEN Unit_Sold_30d <= 12 
            THEN 'High Sale'

        ELSE 'Very High Sale'
    END AS Sales_Status

FROM MyInventroy_Clean;


/* 24. Statistical summary of 60-day sales */
SELECT 
    MIN(Unit_Sold_60d) AS Min_60D_Sales,

    ROUND(AVG(Unit_Sold_60d), 2) AS Avg_60D_Sales,

    PERCENTILE_CONT(0.25)
        WITHIN GROUP (
            ORDER BY Unit_Sold_60d
        ) AS P25,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY Unit_Sold_60d
        ) AS Median_60D_Sales,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY Unit_Sold_60d
        ) AS P75,
		
    MAX(Unit_Sold_60d) AS Max_60D_Sales

FROM MyInventroy_Clean;

/* 25. Classify SKUs based on 60-day sales */
SELECT 
    SKU,
    Unit_Sold_60d,

    CASE
        WHEN Unit_Sold_60d <= 7 
            THEN 'Low Sale'

        WHEN Unit_Sold_60d <= 12 
            THEN 'Normal Sale'

        WHEN Unit_Sold_60d <= 24 
            THEN 'High Sale'

        ELSE 'Very High Sale'
    END AS Sales_Status

FROM MyInventroy_Clean;

--PART 6 — INVENTORY RISK & DEAD STOCK

/* 26. Total number of dead-stock SKUs */
SELECT 
    COUNT(
        DISTINCT CASE 
            WHEN Dead_stock_flag = 'Y' 
            THEN SKU 
        END
    ) AS Dead_Stock_SKUs
FROM MyInventroy_Clean;

/* 27. Dead-stock percentage */
SELECT 
    ROUND(
        COUNT(
            DISTINCT CASE 
                WHEN Dead_stock_flag = 'Y' 
                THEN SKU 
            END
        ) * 100.0
        / COUNT(DISTINCT SKU),
        2
    ) AS Dead_Stock_Percentage
FROM MyInventroy_Clean;

/* 28. Categories with the highest number of dead-stock SKUs */
SELECT 
    Category,

    COUNT(
        DISTINCT CASE 
            WHEN Dead_stock_flag = 'Y' 
            THEN SKU 
        END
    ) AS Dead_Stock_SKUs

FROM MyInventroy_Clean
GROUP BY Category
ORDER BY Dead_Stock_SKUs DESC;


/* 29. Inventory status classification */
SELECT 
    SKU,
    Days_of_inventory_left,

    CASE
        WHEN Days_of_inventory_left = 0
            THEN 'Critical / Out of Stock'

        WHEN Days_of_inventory_left <= 30
            THEN 'Low Inventory'

        WHEN Days_of_inventory_left <= 90
            THEN 'Normal Inventory'

        WHEN Days_of_inventory_left <= 180
            THEN 'High Inventory'

        ELSE 'Very High / Overstock'
    END AS Inventory_Status
	
FROM MyInventroy_Clean;


/* 30. Category with the highest average inventory days */
SELECT 
    Category,
    ROUND(
        AVG(Days_of_inventory_left), 
        2
    ) AS Avg_Inventory_Days

FROM MyInventroy_Clean
GROUP BY Category
ORDER BY Avg_Inventory_Days DESC;

--PART 7 — SKU-LEVEL BUSINESS ANALYSIS
/* 31. SKUs with high inventory but very low sales */
SELECT 
    SKU,
    Category,
    Unit_In_Stock,
    Unit_Sold_7d,
    Days_of_inventory_left

FROM MyInventroy_Clean

WHERE Days_of_inventory_left > 90
  AND Unit_Sold_7d <= 1
ORDER BY Days_of_inventory_left DESC;

/* 32. SKUs with low inventory days but high sales */
SELECT 
    SKU,
    Category,
    Unit_In_Stock,
    Unit_Sold_7d,
    Days_of_inventory_left

FROM MyInventroy_Clean

WHERE Days_of_inventory_left <= 30
  AND Unit_Sold_7d >= 10

ORDER BY Days_of_inventory_left ASC,
         Unit_Sold_7d DESC;


/* 33. Overstocked SKUs */
SELECT 
    SKU,
    Category,
    Unit_In_Stock,
    Unit_Sold_7d,
    Days_of_inventory_left,
    'Overstocked' AS Stock_Status

FROM MyInventroy_Clean
WHERE Days_of_inventory_left >= 180
ORDER BY Days_of_inventory_left DESC;


/* 34. SKUs requiring high restocking priority */
SELECT 
    SKU,
    Category,
    Unit_In_Stock,
    Unit_Sold_7d,
    Days_of_inventory_left,
    'High Restocking Priority' AS Stock_Status

FROM MyInventroy_Clean

WHERE Days_of_inventory_left <= 30
  AND Unit_Sold_7d >= 10
  
ORDER BY Days_of_inventory_left ASC,
         Unit_Sold_7d DESC;


--PART 8 — CATEGORY ANALYSIS
/* 35. Average 7-day sales by category */
SELECT 
    Category,
    ROUND(
        AVG(Unit_Sold_7d), 
        2
    ) AS Avg_Units_Sold_7d

FROM MyInventroy_Clean
GROUP BY Category
ORDER BY Avg_Units_Sold_7d DESC;

/* 36. Total 7-day sales by category */
SELECT 
    Category,
    SUM(Unit_Sold_7d) AS Total_Units_Sold_7d

FROM MyInventroy_Clean
GROUP BY Category
ORDER BY Total_Units_Sold_7d DESC;


/* 37. Total inventory by category */
SELECT 
    Category,
    SUM(Unit_In_Stock) AS Total_Inventory_In_Stock

FROM MyInventroy_Clean
GROUP BY Category
ORDER BY Total_Inventory_In_Stock DESC;


/* 38. Categories with high inventory but relatively low sales */
SELECT 
    Category,
    SUM(Unit_In_Stock) AS Total_Inventory,
    SUM(Unit_Sold_7d) AS Total_Sales

FROM MyInventroy_Clean
GROUP BY Category

ORDER BY Total_Inventory DESC,
         Total_Sales ASC;

-- PART 9 — SIZE ANALYSIS


/* 39. Total inventory by product size */
SELECT 
    Size_Of_Product,
    SUM(Unit_In_Stock) AS Total_Units_In_Stock

FROM MyInventroy_Clean
GROUP BY Size_Of_Product
ORDER BY Total_Units_In_Stock DESC;


/* 40. Total 7-day sales by product size */
SELECT 
    Size_Of_Product,
    SUM(Unit_Sold_7d) AS Total_Units_Sold_7d

FROM MyInventroy_Clean
GROUP BY Size_Of_Product
ORDER BY Total_Units_Sold_7d DESC;


--PART 10 — DATE & TIME ANALYSIS

/* 42. Number of records per year */
SELECT 
    EXTRACT(YEAR FROM inventory_date) AS Year,
    COUNT(*) AS Total_Records

FROM MyInventroy_Clean
GROUP BY EXTRACT(YEAR FROM inventory_date)
ORDER BY Year;

/* 43. Year-wise total inventory */
SELECT 
    EXTRACT(YEAR FROM inventory_date) AS Year,
    SUM(Unit_In_Stock) AS Total_Stock

FROM MyInventroy_Clean
GROUP BY EXTRACT(YEAR FROM inventory_date)
ORDER BY Year;


/* 44. Year-wise average daily inventory */
SELECT 
    EXTRACT(YEAR FROM inventory_date) AS Year,
    ROUND(
        AVG(Unit_In_Stock), 
        2
    ) AS Avg_Daily_Inventory

FROM MyInventroy_Clean
GROUP BY EXTRACT(YEAR FROM inventory_date)
ORDER BY Year;


/* 45. Year-wise average inventory days */
SELECT 
    EXTRACT(YEAR FROM inventory_date) AS Year,
    ROUND(
        AVG(Days_of_inventory_left), 
        2
    ) AS Avg_Inventory_Days

FROM MyInventroy_Clean
GROUP BY EXTRACT(YEAR FROM inventory_date)
ORDER BY Year;

/* 46. Year-wise zero-stock percentage */
SELECT 
    EXTRACT(YEAR FROM inventory_date) AS Year,
    COUNT(*) AS Total_Records,
    SUM(
        CASE 
            WHEN Unit_In_Stock = 0 
            THEN 1
            ELSE 0
        END
    ) AS Zero_Stock_Records,
	ROUND(
        SUM(
            CASE 
                WHEN Unit_In_Stock = 0 
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Zero_Stock_Percentage

FROM MyInventroy_Clean
GROUP BY EXTRACT(YEAR FROM inventory_date)
ORDER BY Year;


/* 47. Daily inventory trend */
SELECT 
    inventory_date,

    ROUND(
        AVG(Unit_In_Stock), 
        2
    ) AS Avg_Inventory,

    ROUND(
        AVG(Days_of_inventory_left), 
        2
    ) AS Avg_Inventory_Days

FROM MyInventroy_Clean

GROUP BY inventory_date
ORDER BY inventory_date;

/* 48. Dates where all SKUs had zero inventory */
SELECT 
    inventory_date,

    COUNT(*) AS Total_SKUs,

    SUM(
        CASE 
            WHEN Unit_In_Stock = 0 
            THEN 1
            ELSE 0
        END
    ) AS Zero_Stock_SKUs
	
FROM MyInventroy_Clean

GROUP BY inventory_date

HAVING SUM(
    CASE 
        WHEN Unit_In_Stock = 0 
        THEN 1
        ELSE 0
    END
) = COUNT(*)

ORDER BY inventory_date;

/* 49. Last date when inventory was non-zero */
SELECT 
    MAX(inventory_date) AS Last_Non_Zero_Inventory_Date
FROM MyInventroy_Clean
WHERE Unit_In_Stock > 0;

--PART 11 — YEAR + MONTH SALES ANALYSIS
 /* 50. Monthly sales trend across all years
      Includes 7d, 30d and 60d sales */
SELECT 
    EXTRACT(YEAR FROM inventory_date) AS Year,
    EXTRACT(MONTH FROM inventory_date) AS Month,

    SUM(Unit_Sold_7d) AS Total_7D_Sales,
    SUM(Unit_Sold_30d) AS Total_30D_Sales,
    SUM(Unit_Sold_60d) AS Total_60D_Sales

FROM MyInventroy_Clean

GROUP BY 
    EXTRACT(YEAR FROM inventory_date),
    EXTRACT(MONTH FROM inventory_date)

ORDER BY 
    Year,
    Month;

	/* 51. Overall highest-sales month */
SELECT 
    EXTRACT(YEAR FROM inventory_date) AS Year,
    EXTRACT(MONTH FROM inventory_date) AS Month,
    SUM(Unit_Sold_7d) AS Total_Sales

FROM MyInventroy_Clean

GROUP BY 
    EXTRACT(YEAR FROM inventory_date),
    EXTRACT(MONTH FROM inventory_date)

ORDER BY Total_Sales DESC

LIMIT 1;

/* 52. Highest-sales month for every year */
WITH Monthly_Sales AS (

    SELECT 
        EXTRACT(YEAR FROM inventory_date) AS Year,
        EXTRACT(MONTH FROM inventory_date) AS Month,
        SUM(Unit_Sold_7d) AS Total_Sales

    FROM MyInventroy_Clean

    GROUP BY 
        EXTRACT(YEAR FROM inventory_date),
        EXTRACT(MONTH FROM inventory_date)
),

Ranked_Sales AS (

    SELECT 
        Year,
        Month,
        Total_Sales,

        RANK() OVER (
            PARTITION BY Year
            ORDER BY Total_Sales DESC
        ) AS Sales_Rank

    FROM Monthly_Sales
)

SELECT 
    Year,
    Month,
    Total_Sales

FROM Ranked_Sales
WHERE Sales_Rank = 1
ORDER BY Year;

/* 53. Month-wise seasonal sales pattern
      Combines the same month across all years */
SELECT 
    EXTRACT(MONTH FROM inventory_date) AS Month,
    SUM(Unit_Sold_7d) AS Total_Sales

FROM MyInventroy_Clean
GROUP BY EXTRACT(MONTH FROM inventory_date)
ORDER BY Total_Sales DESC;

--PART 12 — FINAL BUSINESS ACTION ANALYSIS
/* 54. SKUs with high sales and sufficient inventory */
SELECT 
    SKU,
    Category,
    Unit_In_Stock,
    Unit_Sold_7d,
    Days_of_inventory_left

FROM MyInventroy_Clean

WHERE Unit_Sold_7d >= 10
  AND Days_of_inventory_left >= 30

ORDER BY Unit_Sold_7d DESC,
         Days_of_inventory_left DESC;


/* 55. Final inventory action classification */
SELECT 
    SKU,
    Category,
    Unit_In_Stock,
    Unit_Sold_7d,
    Days_of_inventory_left,

    CASE

        WHEN Days_of_inventory_left = 0
            THEN 'Critical / Out of Stock'

        WHEN Days_of_inventory_left <= 30
             AND Unit_Sold_7d >= 10
            THEN 'Urgent Restocking'

        WHEN Days_of_inventory_left <= 30
            THEN 'Low Inventory - Monitor'

        WHEN Days_of_inventory_left <= 90
             AND Unit_Sold_7d >= 10
            THEN 'High Sales - Monitor Stock'

        WHEN Days_of_inventory_left <= 180
		THEN 'Normal / High Inventory'

        ELSE 'Very High / Overstock'

    END AS Inventory_Action

FROM MyInventroy_Clean

ORDER BY 
    Days_of_inventory_left ASC,
    Unit_Sold_7d DESC;
	
/* 56. Year-wise sales growth */

WITH Yearly_Sales AS (

    /* Step 1: Calculate total sales for each year */
    SELECT
        EXTRACT(YEAR FROM inventory_date) AS Year,
        SUM(Unit_Sold_7d) AS Total_Sales

    FROM MyInventroy_Clean

    GROUP BY EXTRACT(YEAR FROM inventory_date)
),

Sales_With_Previous_Year AS (

    /* Step 2: Get previous year's sales */
    SELECT
        Year,
        Total_Sales,

        LAG(Total_Sales) OVER ( ORDER BY Year) 
		AS Previous_Year_Sales

    FROM Yearly_Sales
)

SELECT
    Year,
    Total_Sales,
    Previous_Year_Sales,

    /* Step 3: Calculate YoY growth percentage */
    ROUND((Total_Sales - Previous_Year_Sales) * 100.0
        / NULLIF(Previous_Year_Sales, 0),2) 
		AS Year_over_Year_Growth_Percentage

FROM Sales_With_Previous_Year
ORDER BY Year;

--SKU Sales Momentum — 7d vs 30d with 60d context 
SELECT
    SKU,
	Category,
    Unit_Sold_7d,
    Unit_Sold_30d,
    Unit_Sold_60d,
	ROUND(Unit_SOld_7d/7.0,2) AS Sales_Pace_7D,
	ROUND(Unit_Sold_30d/30.0,2)AS Sales_Pace_30D,
	ROUND(Unit_Sold_60d/60.0,2)AS Sales_Pace_60D
	FROM MyInventroy_Clean;
/* 57. SKU sales momentum based on 7d vs 30d */

WITH Sales_Pace AS (

    SELECT
        SKU,
        Category,
        Unit_Sold_7d,
        Unit_Sold_30d,
	ROUND(Unit_Sold_7d / 7.0, 2) AS Actual_7D_Pace,
	ROUND(Unit_Sold_30d / 30.0, 2) AS Average_30D_Pace,

        ROUND((Unit_Sold_30d / 30.0) * 7,2)
            AS Expected_7D_Sales

    FROM MyInventroy_Clean
)

SELECT
    SKU,
    Category,
    Unit_Sold_7d,
    Unit_Sold_30d,
	Actual_7D_Pace,
	Average_30D_Pace,
    Expected_7D_Sales,

    ROUND(( Unit_Sold_7d - Expected_7D_Sales) * 100.0
	/ NULLIF(Expected_7D_Sales, 0), 2)
	AS Sales_Momentum_Percentage

FROM Sales_Pace;

/* 58. SKUs with zero sales in the last 7 days */
SELECT
    COUNT(DISTINCT SKU) AS Zero_Sales_SKUs
FROM MyInventroy_Clean
WHERE Unit_Sold_7d = 0;

/* 59. Percentage of SKUs with zero sales */
SELECT
    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN Unit_Sold_7d = 0
                THEN SKU
            END
        ) * 100.0
        / COUNT(DISTINCT SKU),
        2
    ) AS Zero_Sales_Percentage

FROM MyInventroy_Clean;
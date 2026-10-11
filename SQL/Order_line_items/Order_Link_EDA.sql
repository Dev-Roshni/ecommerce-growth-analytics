/*
PART 01 — CREATE FINAL ANALYTICAL TABLE
    Purpose:
    Create derived analytical fields for pricing and discount quality.

*/
DROP TABLE IF EXISTS Final_FashionOrder;

CREATE TABLE Final_FashionOrder AS
SELECT
    Order_ID,
    SKU_ID,
    Category,
    Size_List,
    Color,
    MRP,
    Selling_Price,
    Discount_Percent,
    Returned,
    Return_Reason,

/* Calculated Discount
 Formula: (MRP - Selling Price) / MRP × 100 */
 
 ROUND(
        (MRP - Selling_Price) * 100.0
        / NULLIF(MRP, 0),
        2
    ) AS Calculated_Discount,

 -- Classify pricing relationship
 CASE
        WHEN MRP IS NULL
          OR Selling_Price IS NULL
            THEN 'MISSING_PRICE'

        WHEN MRP <= 0
            THEN 'INVALID_MRP'

        WHEN Selling_Price < 0
            THEN 'INVALID_SELLING_PRICE'

        WHEN Selling_Price > MRP
            THEN 'PRICE_ANOMALY'

        WHEN Selling_Price = MRP
            THEN 'NO_DISCOUNT'

        ELSE 'NORMAL_DISCOUNT'
    END AS Pricing_Status,
	
/*  Discount Quality Flag
        Checks whether reported Discount_Percent matches
        the calculated discount.*/
CASE
        WHEN MRP IS NULL
          OR Selling_Price IS NULL
            THEN 'MISSING_PRICE'

        WHEN MRP <= 0
            THEN 'INVALID_MRP'

        WHEN Selling_Price > MRP
            THEN 'NOT_APPLICABLE_PRICE_ANOMALY'

        WHEN ABS(
            Discount_Percent -
            (
                (MRP - Selling_Price) * 100.0
                / NULLIF(MRP, 0)
            )
        ) <= 1
            THEN 'DISCOUNT_MATCH'

        ELSE 'DISCOUNT_MISMATCH'
    END AS Discount_Quality_Flag
FROM Clean_FashionOrder;

--PART 02 — ORDER & SALES OVERVIEW
SELECT
    COUNT(*) AS Total_Order_Items
FROM Final_FashionOrder;
--02. Total Orders
SELECT
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM Final_FashionOrder;

/* 03. Total MRP vs Actual Selling Value
    Total Discount Value:
    MRP Value - Actual Selling Value
*/	
SELECT
    SUM(MRP) AS Total_MRP,
    SUM(Selling_Price) AS Total_Selling_Value,
    SUM(MRP - Selling_Price) AS Total_Discount_Value
FROM Final_FashionOrder;

-- 04. Average Order Value
SELECT
    ROUND(
        SUM(Selling_Price) * 1.0
        / NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS Average_Order_Value
FROM Final_FashionOrder;

--05. Average Selling Price per Order Item
SELECT
    ROUND(AVG(Selling_Price), 2) AS Average_Selling_Price
FROM Final_FashionOrder;

-- 06. Average Items per Order
SELECT
    ROUND(
        COUNT(*) * 1.0
        / NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS Average_Items_Per_Order
FROM Final_FashionOrder;

-- 07. Order Basket Size Distribution
WITH Order_Basket AS (

    SELECT
        Order_ID,
        COUNT(*) AS Item_Count
    FROM Final_FashionOrder
    GROUP BY Order_ID

)

SELECT
    Item_Count,
    COUNT(*) AS Orders
FROM Order_Basket
GROUP BY Item_Count
ORDER BY Item_Count;

-- PART 03 — PRICING & DISCOUNT ANALYSIS
--08. Overall Effective Discount %
--Formula:  (Total MRP - Total Selling Value) / Total MRP × 100
SELECT
    ROUND(
        (SUM(MRP) - SUM(Selling_Price)) * 100.0
        / NULLIF(SUM(MRP), 0),
        2
    ) AS Overall_Effective_Discount_Percent
FROM Final_FashionOrder
WHERE Pricing_Status <> 'PRICE_ANOMALY';

-- 09. Selling Price Distribution
SELECT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY Selling_Price) AS P25_Price,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY Selling_Price) AS Median_Price,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY Selling_Price) AS P75_Price

FROM Final_FashionOrder;

-- 10. Discount Distribution
SELECT
    CASE
        WHEN Discount_Percent < 10 THEN '0-10%'
        WHEN Discount_Percent < 20 THEN '10-20%'
        WHEN Discount_Percent < 30 THEN '20-30%'
        WHEN Discount_Percent < 40 THEN '30-40%'
        WHEN Discount_Percent < 50 THEN '40-50%'
        ELSE '50%+'
    END AS Discount_Range,

    COUNT(*) AS Item_Count,

    ROUND(
        COUNT(*) * 100.0
        / NULLIF(
            (SELECT COUNT(*) FROM Final_FashionOrder),
            0
        ),
        2
    ) AS Item_Share_Percent,

    SUM(Selling_Price) AS Revenue,

    SUM(
        CASE
            WHEN Returned = 'Y'
			 THEN 1 ELSE 0
        END
    ) AS Returned_Items,

    ROUND(
        SUM(
            CASE
                WHEN Returned = 'Y'
                THEN 1 ELSE 0
            END
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS Return_Rate

FROM Final_FashionOrder

WHERE Pricing_Status <> 'PRICE_ANOMALY'

GROUP BY Discount_Range
ORDER BY Discount_Range;

--11. Discount vs Revenue
 SELECT
 CASE
        WHEN Discount_Percent < 10 THEN '0-10%'
        WHEN Discount_Percent < 20 THEN '10-20%'
        WHEN Discount_Percent < 30 THEN '20-30%'
        WHEN Discount_Percent < 40 THEN '30-40%'
        WHEN Discount_Percent < 50 THEN '40-50%'
        ELSE '50%+'
    END AS Discount_Range,

    COUNT(*) AS Order_Items,

    SUM(Selling_Price) AS Revenue

FROM Final_FashionOrder

WHERE Pricing_Status <> 'PRICE_ANOMALY'

GROUP BY Discount_Range
ORDER BY Revenue DESC;

-- 12. Discount vs Return Rate
SELECT
    CASE
        WHEN Discount_Percent < 10 THEN '0-10%'
        WHEN Discount_Percent < 20 THEN '10-20%'
        WHEN Discount_Percent < 30 THEN '20-30%'
        WHEN Discount_Percent < 40 THEN '30-40%'
        WHEN Discount_Percent < 50 THEN '40-50%'
        ELSE '50%+'
    END AS Discount_Range,

    COUNT(*) AS Order_Items,

    SUM(
        CASE
            WHEN Returned = 'Y'
            THEN 1 ELSE 0
        END
    ) AS Returned_Items,
 ROUND(
        SUM(
            CASE
                WHEN Returned = 'Y'
                THEN 1 ELSE 0
            END
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS Return_Rate

FROM Final_FashionOrder

WHERE Pricing_Status <> 'PRICE_ANOMALY'

GROUP BY Discount_Range
ORDER BY Return_Rate DESC;

-- PART 04 — PRICING DATA QUALITY & ANOMALY ANALYSIS
--13. Selling Price > MRP — Overall Anomaly Impact
SELECT
    COUNT(*) AS Anomaly_Items,

    ROUND(
        COUNT(*) * 100.0
        / NULLIF(
            (SELECT COUNT(*) FROM Final_FashionOrder),
            0
        ),
        2
    ) AS Anomaly_Percentage,

    ROUND(
        SUM(Selling_Price - MRP),
        2
    ) AS Excess_Price_Value

FROM Final_FashionOrder

WHERE Pricing_Status = 'PRICE_ANOMALY';

-- 14. Pricing Anomalies by Category
SELECT
    Category,

    COUNT(*) AS Anomaly_Items,

    ROUND(
        COUNT(*) * 100.0
        / NULLIF(
            SUM(COUNT(*)) OVER (),
            0
        ),
        2
    ) AS Anomaly_Share_Percent,

    ROUND(
        SUM(Selling_Price - MRP),
        2
    ) AS Excess_Price_Value

FROM Final_FashionOrder

WHERE Pricing_Status = 'PRICE_ANOMALY'

GROUP BY Category

ORDER BY Anomaly_Items DESC;

-- 15. Pricing Anomaly Severity
SELECT
    Order_ID,
    SKU_ID,
    Category,
    MRP,
    Selling_Price,

    ROUND(
        Selling_Price - MRP,
        2
    ) AS Excess_Price,

    ROUND(
        (Selling_Price - MRP) * 100.0
        / NULLIF(MRP, 0),
        2
    ) AS Excess_Price_Percentage

FROM Final_FashionOrder

WHERE Pricing_Status = 'PRICE_ANOMALY'

ORDER BY Excess_Price_Percentage DESC;

-- 16. Discount Mismatch Analysis
SELECT
    Order_ID,
    SKU_ID,
    MRP,
    Selling_Price,
    Discount_Percent,
    Calculated_Discount,

    ROUND(
        Discount_Percent - Calculated_Discount,
        2
    ) AS Discount_Difference

FROM Final_FashionOrder

WHERE Discount_Quality_Flag = 'DISCOUNT_MISMATCH';

-- 17. Discount Quality Summary
SELECT
    Discount_Quality_Flag,
    COUNT(*) AS Row_Count,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS Percentage

FROM Final_FashionOrder
GROUP BY Discount_Quality_Flag
ORDER BY Row_Count DESC;

-- PART 05 — CATEGORY PERFORMANCE
--   18. Category-Level Sales Performance
SELECT
    Category,

    COUNT(*) AS Order_Items,

    SUM(Selling_Price) AS Total_Revenue,

    ROUND(
        AVG(Selling_Price),
        2
    ) AS Average_Selling_Price,

    ROUND(
        AVG(Discount_Percent),
        2
    ) AS Average_Discount_Percent,

    SUM(
        CASE
            WHEN Returned = 'Y'
            THEN 1 ELSE 0
        END
    ) AS Returned_Items,
	
    ROUND(
        SUM(
            CASE
                WHEN Returned = 'Y'
                THEN 1 ELSE 0
            END
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS Return_Rate

FROM Final_FashionOrder

GROUP BY Category

ORDER BY Total_Revenue DESC;

--  19. Category Revenue Share
SELECT
    Category,

    COUNT(*) AS Order_Items,

    SUM(Selling_Price) AS Revenue,

    ROUND(
        SUM(Selling_Price) * 100.0
        / NULLIF(
            SUM(SUM(Selling_Price)) OVER (),
            0
        ),
        2
    ) AS Revenue_Share_Percent

FROM Final_FashionOrder

GROUP BY Category

ORDER BY Revenue DESC;

-- PART 06 — SIZE & COLOR PERFORMANCE
-- 20. Size Performance
SELECT
    Size_List,

    COUNT(*) AS Total_Items,

    SUM(Selling_Price) AS Revenue,

    ROUND(
        AVG(Discount_Percent),
        2
    ) AS Average_Discount,

    SUM(
        CASE
            WHEN Returned = 'Y'
            THEN 1 ELSE 0
        END
    ) AS Returned_Items,

    ROUND(
        SUM(
            CASE
                WHEN Returned = 'Y'
                THEN 1 ELSE 0
            END
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS Return_Rate

FROM Final_FashionOrder

GROUP BY Size_List

ORDER BY Return_Rate DESC;

--  21. Color Performance
SELECT
    Color,

    COUNT(*) AS Total_Items,

    SUM(Selling_Price) AS Revenue,

    ROUND(
        AVG(Selling_Price),
        2
    ) AS Average_Selling_Price,

    ROUND(
        AVG(Discount_Percent),
        2
    ) AS Average_Discount,

    SUM(
        CASE
            WHEN Returned = 'Y'
            THEN 1 ELSE 0
        END
    ) AS Returned_Items,
	  ROUND(
        SUM(
            CASE
                WHEN Returned = 'Y'
                THEN 1 ELSE 0
            END
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS Return_Rate

FROM Final_FashionOrder

GROUP BY Color

ORDER BY Return_Rate DESC;

-- 22. Category × Size Return Analysis
SELECT
    Category,
    Size_List,

    COUNT(*) AS Total_Items,

    SUM(
        CASE
            WHEN Returned = 'Y'
            THEN 1 ELSE 0
        END
    ) AS Returned_Items,

    ROUND(
        SUM(
            CASE
                WHEN Returned = 'Y'
                THEN 1 ELSE 0
            END
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS Return_Rate

FROM Final_FashionOrder
GROUP BY Category, Size_List
ORDER BY Return_Rate DESC;

--PART 07 — RETURN INTELLIGENCE
--    23. Overall Return Performance
SELECT
    COUNT(*) AS Total_Items,

    SUM(
        CASE
            WHEN Returned = 'Y'
            THEN 1 ELSE 0
        END
    ) AS Returned_Items,

    ROUND(
        SUM(
            CASE
                WHEN Returned = 'Y'
                THEN 1 ELSE 0
            END
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS Overall_Return_Rate

FROM Final_FashionOrder;

--24. Return Reason Analysis
SELECT
    Return_Reason,

    COUNT(*) AS Returned_Items,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS Return_Share

FROM Final_FashionOrder
WHERE Returned = 'Y'
GROUP BY Return_Reason
ORDER BY Returned_Items DESC;

--  25. Category × Return Reason
SELECT
    Category,
    Return_Reason,

    COUNT(*) AS Returned_Items,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY Category
        ),
        2
    ) AS Return_Reason_Share

FROM Final_FashionOrder
WHERE Returned = 'Y'
GROUP BY Category, Return_Reason
ORDER BY Category, Returned_Items DESC;

-- 26. Returned Revenue / Value Impact
SELECT
    COUNT(*) AS Total_Items,
    SUM(Selling_Price) AS Total_Selling_Value,
    SUM(
        CASE
            WHEN Returned = 'Y'
            THEN Selling_Price
            ELSE 0
        END
    ) AS Returned_Selling_Value,

    ROUND(
        SUM(
            CASE
                WHEN Returned = 'Y'
                THEN Selling_Price
                ELSE 0
            END
        ) * 100.0
        / NULLIF(SUM(Selling_Price), 0),
        2
    ) AS Returned_Value_Percentage
FROM Final_FashionOrder;

--27  Returned Value by Category
SELECT
    Category,
    COUNT(*) AS Returned_Items,
    SUM(Selling_Price) AS Returned_Value,
    ROUND(
        SUM(Selling_Price) * 100.0
        / NULLIF(
            SUM(SUM(Selling_Price)) OVER (),
            0
        ),
        2
    ) AS Returned_Value_Share
FROM Final_FashionOrder
WHERE Returned = 'Y'
GROUP BY Category

ORDER BY Returned_Value DESC;

--  PART 08 — SKU PERFORMANCE
--  28. SKU Sales Performance

SELECT
    SKU_ID,
    Category,
    COUNT(*) AS Items_Sold,
    SUM(Selling_Price) AS Revenue,
    ROUND(
        AVG(Selling_Price),
        2
    ) AS Average_Selling_Price,
    ROUND(
        AVG(Discount_Percent),
        2
    ) AS Average_Discount,

    SUM(
        CASE
            WHEN Returned = 'Y'
            THEN 1 ELSE 0
        END
    ) AS Returned_Items,
    ROUND(
        SUM(
            CASE
                WHEN Returned = 'Y'
                THEN 1 ELSE 0
            END
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS Return_Rate
FROM Final_FashionOrder
GROUP BY SKU_ID, Category
ORDER BY Revenue DESC;


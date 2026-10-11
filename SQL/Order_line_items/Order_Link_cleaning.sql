--Cleaning steps on order line items

--1 DROP TABLE IF EXIST
DROP TABLE IF EXISTS Fashion_Order;

--2 CREATE TABLE
CREATE TABLE Fashion_Order(
    Order_ID VARCHAR(30),
    SKU_ID VARCHAR(30),
    Category VARCHAR(50),
    Size_List VARCHAR(10),
    Color VARCHAR(30),
    MRP DECIMAL(10,2),
    Selling_Price DECIMAL(10,2),
    Discount_Percent DECIMAL(5,2),
    Returned CHAR(1),
    Return_Reason VARCHAR(50)
);
-- 3. LOAD RAW DATA
COPY Fashion_Order(
    Order_ID,
    SKU_ID ,
    Category ,
    Size_List,
    Color,
	MRP,
	Selling_Price,
	Discount_Percent,
	Returned,
	Return_Reason
	)
FROM 'D:\E-Commerce_Analysis\order_line_items.csv'
DELIMITER ','
CSV HEADER;

---- 4. INITIAL DATA CHECK
-- View all records
SELECT * FROM Fashion_Order;

-- Check total number of rows
SELECT COUNT(*) AS Total_Rows
FROM Fashion_Order;

-- 5. CREATE CLEANING TABLE
DROP TABLE IF EXISTS Clean_FashionOrder;

CREATE TABLE Clean_FashionOrder AS
SELECT * FROM Fashion_Order

-- Verify cleaning table
SELECT * FROM Clean_FashionOrder

-- Verify row count
SELECT COUNT(*) AS Total_Rows
FROM Clean_FashionOrder;

--6.Check Duplicate Order IDS
SELECT
    Order_ID,
    SKU_ID,
    Size_List,
    Color,
	MRP,
    Category ,
	Selling_Price,
	Discount_Percent,
	Returned,
	Return_Reason,
    COUNT(*) AS Duplicate_Count
FROM Clean_FashionOrder
GROUP BY Order_ID, SKU_ID, Size_List, Color,MRP,Order_ID,Category,
Selling_Price,Discount_Percent ,Returned,Return_Reason
HAVING COUNT(*) > 1;

--Delete same to same rows
BEGIN;

WITH Duplicate AS (
    SELECT
        ctid,
        ROW_NUMBER() OVER (
            PARTITION BY
                Order_ID,
                SKU_ID,
                Size_List,
                Color,
                MRP,
                Category,
                Selling_Price,
                Discount_Percent,
                Returned,
                Return_Reason
            ORDER BY ctid
        ) AS row_numbers
    FROM Clean_FashionOrder
)
DELETE FROM Clean_FashionOrder
WHERE ctid IN (
    SELECT ctid
    FROM Duplicate
    WHERE row_numbers > 1
);
--Now check duplicate row again.
SELECT
    Order_ID,
    SKU_ID,
    Size_List,
    Color,
    MRP,
    Category,
    Selling_Price,
    Discount_Percent,
    Returned,
    Return_Reason,
    COUNT(*) AS Duplicate_Count
FROM Clean_FashionOrder
GROUP BY
    Order_ID,
    SKU_ID,
    Size_List,
    Color,
    MRP,
    Category,
    Selling_Price,
    Discount_Percent,
    Returned,
    Return_Reason
HAVING COUNT(*) > 1;

--Now COMMIT
COMMIT;


--7. Check NULL / blank values
SELECT 
COUNT(*) FILTER (WHERE Order_ID  IS NULL) OrderID_NULL,
COUNT(*) FILTER (WHERE Category IS NULL) Category_NULL,
COUNT(*) FILTER (WHERE  SKU_ID IS NULL)  SKU_ID_NULL,
COUNT(*) FILTER (WHERE Size_List IS NULL) Size_List_NULL,
COUNT(*) FILTER (WHERE Returned IS NULL) Returned_NULL,
COUNT(*) FILTER (WHERE Return_Reason IS NULL) Return_Reason_NULL,
COUNT(*) FILTER (WHERE MRP IS NULL) AS MRP_NULL,
COUNT(*) FILTER (WHERE Selling_Price IS NULL) AS SellingPrice_NULL,
COUNT(*) FILTER (WHERE Discount_Percent IS NULL) AS Discount_NULL
FROM Clean_FashionOrder;

--8. CHECK BLANK / WHITESPACE VALUES
SELECT *
FROM Clean_FashionOrder
WHERE TRIM(Order_ID) = ''
   OR TRIM(SKU_ID) = ''
   OR TRIM(Category) = ''
   OR TRIM(Size_List) = ''
   OR TRIM(Color) = ''
   OR TRIM(Returned) = ''
   OR TRIM(Return_Reason) = '';

--9. CHECK DISTINCT CATEGORY VALUES   

SELECT DISTINCT
    Category
FROM Clean_FashionOrder
ORDER BY Category;

--10. CHECK DISTINCT SIZE VALUES
SELECT DISTINCT
    Size_List
FROM Clean_FashionOrder
ORDER BY Size_List;

--11. Standardize Color values
SELECT DISTINCT 
Color
FROM Clean_FashionOrder
ORDER BY Color;

--12. VALIDATE RETURNED VALUES
SELECT DISTINCT
    Returned
FROM Clean_FashionOrder
ORDER BY Returned;

--13. VALIDATE RETURN REASONS
SELECT DISTINCT
    Return_Reason
FROM Clean_FashionOrder
ORDER BY Return_Reason;

--14. CHECK INVALID NUMERIC VALUES
SELECT * FROM Clean_FashionOrder
WHERE MRP < 0
OR Selling_Price <0
OR Discount_Percent < 0
OR Discount_Percent > 100;

--15. CHECK MRP = 0 and selling price=0
SELECT *
FROM Clean_FashionOrder
WHERE MRP = 0
OR  Selling_Price = 0 ;

--16 MRP DISTRIBUTION / OUTLIER CHECK
SELECT
PERCENTILE_CONT(0.25)
WITHIN GROUP (ORDER BY MRP) AS Q1,

PERCENTILE_CONT(0.50)
WITHIN GROUP (ORDER BY MRP) AS Median,

PERCENTILE_CONT(0.75)
WITHIN GROUP (ORDER BY MRP) AS Q3

FROM Clean_FashionOrder;



--17. CHECK SELLING PRICE > MRP
/* -- Expected relationship:
-- Selling Price < MRP  → Discount
-- Selling Price = MRP  → No Discount
-- Selling Price > MRP  → Potential anomaly
 */
SELECT
    Order_ID,
    SKU_ID,
    Category,
    MRP,
    Selling_Price,
    Discount_Percent,
   (Selling_Price - MRP) AS Difference
FROM Clean_FashionOrder
WHERE Selling_Price > MRP
ORDER BY Difference DESC;

--18. COUNT PRICE AND percentage ANOMALIES
SELECT 
 COUNT(*) AS Total_Rows,

    COUNT(*) FILTER (
        WHERE Selling_Price > MRP
    ) AS Anomaly_Rows,

ROUND(
COUNT(*) FILTER(WHERE Selling_Price > MRP)*100.0/NULLIF(COUNT(*),0),2)
AS Percentage
FROM Clean_FashionOrder;
--19.Find where anomalies are concentrated
SELECT
    Category,
    COUNT(*) AS Total_Rows,
    COUNT(*) FILTER (
        WHERE Selling_Price > MRP
    ) AS Anomaly_Rows,
	
     ROUND(
        COUNT(*) FILTER (
            WHERE Selling_Price > MRP
        ) * 100.0 / COUNT(*),
        2
    ) AS Anomaly_Percentage

FROM Clean_FashionOrder
GROUP BY Category

--20 ANOMALIES BY SKU
SELECT 
SKU_ID,
Category,
COUNT(*) AS Total_rowa,
COUNT(*) FILTER(WHERE Selling_Price > MRP) AS Anomaly_Rows,
ROUND(
COUNT(*)FILTER(WHERE Selling_Price > MRP)*100.0/NULLIF(COUNT(*),0),2
)AS Anomaly_Percentage
FROM Clean_FashionOrder
GROUP By SKU_ID,Category
ORDER BY Anomaly_Rows DESC;

--21 VALIDATE DISCOUNT CALCULATION
SELECT
    Order_ID,
    SKU_ID,
    MRP,
    Selling_Price,
    Discount_Percent,
	ROUND((MRP-Selling_Price)*100.0/NULLIF(MRP,0),2)
	AS Calculated_Discount,
	ROUND(Discount_Percent-(MRP-Selling_Price)*100.0/NULLIF(MRP,0),2)
	AS Discount_Difference
FROM Clean_FashionOrder;

-- 22. QUANTIFY DISCOUNT MISMATCHES
WITH Calculate_Discount AS (
SELECT *,
ROUND((MRP-Selling_Price)*100/NULLIF(MRP,0),2) AS Calculated_Discount
FROM Clean_FashionOrder
),
Calculate_Mismatch AS (
SELECT 
COUNT(*) Total_Count,
COUNT(*) FILTER(WHERE ABS(Discount_Percent-Calculated_Discount)>1) AS Mismatch_Rows
FROM Calculate_Discount
)
SELECT 
Total_Count,
Mismatch_Rows,
ROUND(Mismatch_Rows*100.0/NULLIF(Total_Count,0),2) AS Mismatch_Percentage
FROM Calculate_Mismatch;

--23. CREATE DISCOUNT QUALITY FLAG

SELECT
    Order_ID,
    SKU_ID,
    Category,
    MRP,
    Selling_Price,
    Discount_Percent,

    ROUND(
        (MRP - Selling_Price) * 100.0
        / NULLIF(MRP, 0),
        2
    ) AS Calculated_Discount,

    ROUND(
        Discount_Percent -
        (
            (MRP - Selling_Price) * 100.0
            / NULLIF(MRP, 0)
        ),
        2
    ) AS Discount_Difference,

    CASE

        WHEN MRP IS NULL
          OR Selling_Price IS NULL
            THEN 'MISSING_PRICE'

        WHEN MRP <= 0
            THEN 'INVALID_MRP'

        WHEN Selling_Price > MRP
            THEN 'PRICE_ANOMALY'

        WHEN ABS(
            Discount_Percent -
            (
                (MRP - Selling_Price) * 100.0
                / NULLIF(MRP, 0)
            )
        ) <= 0.1
            THEN 'DISCOUNT_MATCH'

        ELSE 'DISCOUNT_MISMATCH'

    END AS Discount_Quality_Flag

FROM Clean_FashionOrder;

--24. DISCOUNT QUALITY SUMMARY

WITH Discount_Check AS (
    SELECT
        CASE

            WHEN MRP IS NULL
              OR Selling_Price IS NULL
                THEN 'MISSING_PRICE'

            WHEN MRP <= 0
                THEN 'INVALID_MRP'

            WHEN Selling_Price > MRP
                THEN 'PRICE_ANOMALY'

            WHEN ABS(
                Discount_Percent -
                (
                    (MRP - Selling_Price) * 100.0
                    / NULLIF(MRP, 0)
                )
            ) <= 0.1
                THEN 'DISCOUNT_MATCH'

            ELSE 'DISCOUNT_MISMATCH'
        END AS Discount_Quality_Flag
    FROM Clean_FashionOrder
)

SELECT
    Discount_Quality_Flag,
    COUNT(*) AS Row_Count,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS Percentage

FROM Discount_Check
GROUP BY Discount_Quality_Flag
ORDER BY Row_Count DESC;

--check Check outliers in MRP
SELECT
 PERCENTILE_CONT(0.25) 
 WITHIN GROUP (ORDER BY MRP) AS Q1,
 PERCENTILE_CONT(0.50) 
 WITHIN GROUP (ORDER BY MRP) AS Q2,
 PERCENTILE_CONT(0.75) 
 WITHIN GROUP (ORDER BY MRP) AS Q3
 FROM Clean_FashionOrder;

---- CHECK SKU-CATEGORY MISMATCH: Find SKUs associated with more than one category

SELECT
    SKU_ID,
    COUNT(DISTINCT Category) AS Category_Count
FROM Clean_FashionOrder
GROUP BY SKU_ID
HAVING COUNT(DISTINCT Category) > 1;

--SKU-level MRP consistency
SELECT
    SKU_ID,
    COUNT(DISTINCT MRP) AS MRP_Variations
FROM Clean_FashionOrder
GROUP BY SKU_ID
HAVING COUNT(DISTINCT MRP) > 1;


DROP TABLE IF EXISTS Raw_Orders;
--Cleaning on order dataset
 CREATE TABLE Raw_Orders (
    Order_ID VARCHAR(30),
    Customer_ID VARCHAR(30),
    Order_Date_Time TIMESTAMP,
    Product VARCHAR(50),
    Order_Value_Gross_Net VARCHAR(50),
    Order_Value_Gross NUMERIC(12,2),
    Order_Value_Net NUMERIC(12,2),
    Discount_Applied_Rs_Percent VARCHAR(50),
    Discount_Applied_Rs NUMERIC(12,2),
    Discount_Applied_Percent VARCHAR(20),
    Payment_Mode VARCHAR(30),
    Shipping_City VARCHAR(100),
    Pincode VARCHAR(20),
    First_Order_vs_Repeat VARCHAR(20),
    Channel_Source_Last_Touch VARCHAR(100),
    Delivered_Returned_RTO VARCHAR(30)
);
COPY Raw_Orders(
 Order_ID ,
    Customer_ID ,
    Order_Date_Time ,
    Product ,
    Order_Value_Gross_Net,
    Order_Value_Gross ,
    Order_Value_Net ,
    Discount_Applied_Rs_Percent ,
    Discount_Applied_Rs,
    Discount_Applied_Percent ,
    Payment_Mode ,
    Shipping_City ,
    Pincode ,
    First_Order_vs_Repeat ,
    Channel_Source_Last_Touch ,
    Delivered_Returned_RTO
)
FROM 'D:\E-Commerce_Analysis\orders.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM  Raw_Orders;

SELECT COUNT(*) AS Total_Count
FROM Raw_Orders;

-- CREATE Order_Clean TABLE

DROP TABLE IF EXISTS Order_Clean ;

CREATE TABLE Order_Clean AS
SELECT * FROM Raw_Orders;

SELECT COUNT(*) AS Total_Count
FROM Order_Clean;

--Check duplicate rows
SELECT 
    Order_ID,
	customer_id,
    COUNT(*)  AS duplicate_count
FROM Order_Clean
GROUP BY  Order_ID,  customer_id
HAVING COUNT(*) > 1;

--Check Order value (gross, net)
SELECT
    COUNT(*) AS Total_Rows,

    COUNT(*) FILTER (
        WHERE Order_Value_Gross_Net =
        CONCAT(
            Order_Value_Gross::INT,
            ',',
            Order_Value_Net::INT
        )
    ) AS Matching_Rows,

    COUNT(*) FILTER (
        WHERE Order_Value_Gross_Net <>
        CONCAT(
            Order_Value_Gross::INT,
            ',',
            Order_Value_Net::INT
        )
    ) AS Mismatching_Rows
FROM Order_Clean;

--Check Discount applied (₹ + %)
SELECT 
    COUNT(*) AS Total_Row,

    COUNT(*) FILTER (
        WHERE Discount_Applied_Rs_Percent =
        CONCAT(
            Discount_Applied_Rs::INT,
            ',',
            Discount_Applied_Percent
        )
    ) AS Matching_Rows,
	COUNT(*) FILTER (
        WHERE Discount_Applied_Rs_Percent <>
        CONCAT(
            Discount_Applied_Rs::INT,
            ',',
            Discount_Applied_Percent
        )
    ) AS Mismatching_Rows

FROM Order_Clean;

--Delte maching duplicate row
ALTER TABLE Order_Clean
DROP COLUMN Order_Value_Gross_Net,
DROP COLUMN Discount_Applied_Rs_Percent;

--NOW check it
SELECT * FROM Order_Clean;

--Test the split before updating

SELECT
    Order_Date_Time,
    Order_Date_Time::DATE AS Order_Date,
    Order_Date_Time::TIME AS Order_Time
FROM Order_Clean;

ALTER TABLE Order_Clean
ADD COLUMN Dates DATE,
ADD COLUMN Times TIME;

--Update coulm
 UPDATE Order_Clean
 SET 
 Dates = Order_Date_Time::Date,
 Times = Order_Date_Time::Time;

--check it 
 SELECT 
 Order_Date_Time,
 Dates,
 Times 
 FROM Order_Clean;

 --Check Datatype 
 SELECT 
     Discount_Applied_Percent,
    pg_typeof(Discount_Applied_Percent) AS Data_Type
FROM Order_Clean
LIMIT 5;

--first remove % 
UPDATE Order_Clean
SET Discount_Applied_Percent = REPLACE(Discount_Applied_Percent, '%','');

--Check 
SELECT Discount_Applied_Percent
FROM Order_Clean
LIMIT 10;
--Convert varchar to numeric
ALTER TABLE Order_Clean
ALTER COLUMN Discount_Applied_Percent
TYPE NUMERIC(5,2)
USING Discount_Applied_Percent::NUMERIC;
--now check it again their datatype
SELECT Discount_Applied_Percent,
Pg_typeof(Discount_Applied_Percent) AS Datatypes
FROM Order_Clean
LIMIT 5;

--Check Invalid Numeric Values
SELECT * FROM Order_Clean
WHERE order_value_gross <= 0
OR order_value_net <= 0
OR discount_applied_rs < 0
OR Discount_Applied_Percent < 0
OR Discount_Applied_Percent > 100;


 --check null column 
 SELECT 
    COUNT(*) FILTER (WHERE Order_ID IS NULL) AS Order_ID_Nulls,
    COUNT(*) FILTER (WHERE Customer_ID IS NULL) AS Customer_ID_Nulls,
    COUNT(*) FILTER (WHERE Order_Date_Time IS NULL) AS Order_Date_Time_Nulls,
    COUNT(*) FILTER (WHERE Product IS NULL) AS Product_Nulls,
    COUNT(*) FILTER (WHERE Order_Value_Gross IS NULL) AS Gross_Nulls,
    COUNT(*) FILTER (WHERE Order_Value_Net IS NULL) AS Net_Nulls,
    COUNT(*) FILTER (WHERE Dates IS NULL) AS Date_Nulls,
    COUNT(*) FILTER (WHERE Times IS NULL) AS Time_Nulls
FROM Order_Clean;
--Check Blank text value
SELECT * FROM Order_Clean
WHERE TRIM(Order_ID) = ''
  OR  TRIM(Customer_ID) = ''
   OR TRIM(Product) = ''
   OR TRIM(Payment_Mode) = ''
   OR TRIM(Shipping_City) = ''
   OR TRIM(First_Order_vs_Repeat) = ''
   OR TRIM(Channel_Source_Last_Touch) = ''
   OR TRIM(Delivered_Returned_RTO) = '';

-- CHeck Net Order value
SELECT
COUNT(*) AS TOtal_Row,
COUNT(*) FILTER(WHERE Order_Value_Net = Order_Value_Gross - Discount_Applied_Rs )
AS Matching_Row,
 COUNT(*) FILTER (
        WHERE Order_Value_Net <>
              Order_Value_Gross - Discount_Applied_Rs
    ) AS Mismatching_Rows
FROM Order_Clean;



--Validate Discount Percentage
SELECT
    Discount_Applied_Rs,
    Discount_Applied_Percent,

    Order_Value_Gross - Order_Value_Net
        AS Discount_Applied_Rs_Calculated,

    ROUND(
        (Order_Value_Gross - Order_Value_Net) * 100.0
        / Order_Value_Gross,
        2
    ) AS Discount_Percentage

FROM Order_Clean;
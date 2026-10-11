-- CREATE AND LOAD THE RAW PURCHASE ORDERS TABLE

DROP TABLE IF EXISTS Purchases_Orders;
--Cleaning on order dataset
 CREATE TABLE Purchases_Orders (
 SKU VARCHAR(50),
 Vendor VARCHAR(100),
 Order_Quantity INTEGER,
 Cost_Per_Unit NUMERIC(10,2),
 Order_Date DATE,
 Expected_Delivery DATE,
 Actual_Delivery DATE,
 Lead_Time INTEGER  
);
-- Load data from the CSV file 
COPY Purchases_Orders(
 SKU ,
 Vendor ,
 Order_Quantity ,
 Cost_Per_Unit,
 Order_Date ,
 Expected_Delivery ,
 Actual_Delivery,
 Lead_Time  
)
FROM 'D:\E-Commerce_Analysis\purchase_orders.csv'
DELIMITER ','
CSV HEADER;

--Preview the raw data
SELECT * FROM  Purchases_Orders;

--Check the total number of rows loaded
SELECT COUNT(*) AS Total_Row
FROM Purchases_Orders;

--CREATE A WORKING CLEAN TABLE

DROP TABLE IF EXISTS Purchases_Orders_Clean;

CREATE TABLE Purchases_Orders_Clean AS
SELECT * FROM Purchases_Orders;

--Verify the row count in the clean table
SELECT COUNT(*) AS Total_Count
FROM Purchases_Orders_Clean;

--CHECK FOR EXACT DUPLICATE ROWS
SELECT 
SKU,
Vendor,
Order_Quantity,
Cost_Per_Unit,
Order_Date ,
Expected_Delivery ,
Actual_Delivery,
Lead_Time,
COUNT(*) AS DUplicate_COunt
FROM Purchases_Orders_Clean
GROUP BY 
SKU,
Vendor,
Order_Quantity,
Cost_Per_Unit,
Order_Date ,
Expected_Delivery ,
Actual_Delivery,
Lead_Time
HAVING COUNT(*)>1;

--CHECK FOR NULL VALUES
SELECT
COUNT(*) FILTER(WHERE SKU IS NULL) AS SKU_NULL,
COUNT(*) FILTER (WHERE Vendor IS NULL) AS Vendor_NULL,
COUNT(*) FILTER(WHERE Order_Quantity IS NULL ) AS Order_Quantity_NULL,
COUNT(*) FILTER(WHERE Cost_Per_Unit IS NULL) AS Cost_Per_Unit_NULL, 
COUNT(*) FILTER (WHERE Order_Date IS NULL) AS Order_Date_NULL,
COUNT(*) FILTER(WHERE Expected_Delivery IS NULL ) AS Expected_Delivery_NULL,
COUNT(*) FILTER(WHERE Actual_Delivery IS NULL) AS Actual_Delivery_NULL, 
COUNT(*) FILTER(WHERE Lead_Time IS NULL) AS Lead_Time_NULL
FROM Purchases_Orders_Clean;

-- CHECK FOR BLANK OR EMPTY TEXT VALUES
SELECT * FROM Purchases_Orders_Clean
WHERE TRIM(SKU) = ''
OR TRIM(Vendor) = '';

-- CHECK DATE RANGE
SELECT
    MIN(Order_Date) AS First_Order_Date,
    MAX(Order_Date) AS Last_Order_Date,

    MIN(Expected_Delivery) AS First_Expected_Delivery,
    MAX(Expected_Delivery) AS Last_Expected_Delivery,

    MIN(Actual_Delivery) AS First_Actual_Delivery,
    MAX(Actual_Delivery) AS Last_Actual_Delivery

FROM Purchases_Orders_Clean;

--CHECK FOR INVALID NUMERIC VALUES
SELECT * FROM Purchases_Orders_Clean
WHERE Order_Quantity <=0
OR Cost_Per_Unit <= 0;

--VALIDATE DELIVERY DATE LOGIC
SELECT *
FROM Purchases_Orders_Clean
WHERE Expected_Delivery < Order_Date
   OR Actual_Delivery < Order_Date;

--VALIDATE DELIVERY DELAY

SELECT
    SKU,
    Vendor,
    Order_Date,
    Expected_Delivery,
    Actual_Delivery,
    Actual_Delivery - Expected_Delivery AS Delivery_Delay_Days
	FROM Purchases_Orders_Clean
ORDER BY Delivery_Delay_Days DESC;

--Check the standardized SKU values 
SELECT
    SKU,
    COUNT(*) AS Total_Purchase_Orders
FROM Purchases_Orders_Clean
GROUP BY SKU
ORDER BY SKU;

-- Review standardized Vendor values 
SELECT DISTINCT Vendor
FROM Purchases_Orders_Clean
ORDER BY Vendor;

--Validate Lead Time 
SELECT
    SKU,
    Order_Date,
    Actual_Delivery,
    Lead_Time,
	(Actual_Delivery-Order_Date) AS Calculated_Lead_Time
	FROM Purchases_Orders_Clean
	WHERE Lead_Time <>
      Actual_Delivery - Order_Date;

--Check Vendor Consistency
SELECT
    Vendor,
    COUNT(*) AS Total_Orders
FROM Purchases_Orders_Clean
GROUP BY Vendor
ORDER BY Total_Orders DESC;

--CHECK COST VARIATION BY SKU
SELECT
    SKU,
    MIN(Cost_Per_Unit) AS Minimum_Cost,
    MAX(Cost_Per_Unit) AS Maximum_Cost,
    ROUND(AVG(Cost_Per_Unit), 2) AS Average_Cost
FROM Purchases_Orders_Clean
GROUP BY SKU
ORDER BY Average_Cost DESC;






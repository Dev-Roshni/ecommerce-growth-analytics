--EDA Purchases_Order Cleaning
--Overall procurement

SELECT 
COUNT(*) AS Total_Purchase_Orders,
SUM(Order_Quantity) AS Total_Units_Ordered,
SUM(Order_Quantity * Cost_Per_Unit) AS Total_Procurement_Cost,
ROUND(AVG(Order_Quantity), 2) AS Average_Order_Quantity,
ROUND(AVG(Cost_Per_Unit), 2) AS Average_Cost_Per_Unit
FROM Purchases_Orders_Clean;

--Unique SKUs and vendor
SELECT
COUNT(DISTINCT SKU) AS Unique_SKU,
COUNT(DISTINCT Vendor) AS Unique_Vendor
FROM Purchases_Orders_Clean;

-- Monthly procurement trend
SELECT
DATE_TRUNC('MONTH',Order_Date)::DATE AS Months,
COUNT(*) AS Total_Purchase_Orders,
SUM(Order_Quantity) AS Total_Units_Ordered,
SUM(Order_Quantity * Cost_Per_Unit) AS Total_Procurement_Cost,
ROUND(AVG(Order_Quantity), 2) AS Avg_Order_Quantity
FROM Purchases_Orders_Clean
GROUP BY  Months
ORDER BY  Total_Purchase_Orders DESC;


-- Procurement performance by vendo
SELECT
    Vendor,
    COUNT(*) AS Total_Purchase_Orders,
	SUM(Order_Quantity) AS Total_Unit_Ordered,
	 SUM(Order_Quantity * Cost_Per_Unit) AS Total_Money_Spent,
	ROUND(AVG(lead_Time),2) AS AVG_Leading_Time,
	COUNT(DISTINCT SKU) AS unique_SKUs_supplied	
FROM Purchases_Orders_Clean
GROUP BY Vendor
ORDER BY Total_Purchase_Orders DESC;

---Calculate delivery delay for each purchase order

SELECT 
SKU,
Vendor,
Order_Date,
Expected_Delivery,
Actual_Delivery,
Actual_Delivery - Expected_Delivery AS  Delivery_Delay_Days
FROM Purchases_Orders_Clean
ORDER BY Delivery_Delay_Days DESC;

--Delivery Status Summary
SELECT
    CASE
        WHEN Actual_Delivery < Expected_Delivery THEN 'Early'
        WHEN Actual_Delivery = Expected_Delivery THEN 'On Time'
        WHEN Actual_Delivery > Expected_Delivery THEN 'Delayed'
    END AS Delivery_Status,
    COUNT(*) AS Total_Orders,
	ROUND(
        AVG(Actual_Delivery - Expected_Delivery),
        2
    ) AS Average_Delivery_Delay_Days
FROM Purchases_Orders_Clean
GROUP BY Delivery_Status
ORDER BY Total_Orders DESC;

---. Delayed Delivery Rate by Vendor
SELECT
Vendor,
COUNT(*) FILTER(WHERE Actual_Delivery > Expected_Delivery) AS Delayed_Order,
COUNT(*) AS Total_Delivered_Orders,
ROUND(COUNT(*)FILTER(WHERE Actual_Delivery > Expected_Delivery)*100.0/
NULLIF(COUNT(*),0),2) AS Delayed_Delivery_Percentage
FROM Purchases_Orders_Clean
WHERE Actual_Delivery IS NOT NULL
  AND Expected_Delivery IS NOT NULL
GROUP BY Vendor
ORDER BY Delayed_Delivery_Percentage DESC;

--On-Time Delivery Rate by Vendor
SELECT
Vendor,
COUNT(*) FILTER(WHERE Actual_Delivery = Expected_Delivery) 
AS OnTime_Order,
COUNT(*) AS Total_Delivered_Orders,
ROUND(COUNT(*)FILTER(WHERE Actual_Delivery = Expected_Delivery)*100.0/
NULLIF(COUNT(*),0),2) AS OnTime_Delivery_Percentage
FROM Purchases_Orders_Clean
WHERE Actual_Delivery IS NOT NULL
  AND Expected_Delivery IS NOT NULL
GROUP BY Vendor
ORDER BY OnTime_Delivery_Percentage DESC;

--Procurement performance by SKU

SELECT
    SKU,
    SUM(Order_Quantity) AS Total_Units_Ordered,
	SUM(Order_Quantity*Cost_Per_Unit) AS Total_Cost_spend,
	ROUND(AVG(Cost_Per_Unit),2) AS AVG_Cost_Per_Unit
FROM Purchases_Orders_Clean
GROUP BY SKU
ORDER BY Total_Units_Ordered DESC;

--Cost Variation by SKU
SELECT
    SKU,
    MIN(Cost_Per_Unit) AS Minimum_Cost,
    MAX(Cost_Per_Unit) AS Maximum_Cost,
    MAX(Cost_Per_Unit) - MIN(Cost_Per_Unit) AS Cost_Difference
FROM Purchases_Orders_Clean
GROUP BY SKU
ORDER BY Cost_Difference DESC;

--Most Frequently Purchased SKUs
SELECT
SKU,
COUNT(*) AS  Purchase_Order_Frequency
FROM Purchases_Orders_Clean
GROUP BY SKU
ORDER BY Purchase_Order_Frequency DESC;
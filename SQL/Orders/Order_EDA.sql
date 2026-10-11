--EDA
--PART A — Overall Business Performance

SELECT 
COUNT(DISTINCT Order_ID) AS Total_order,
SUM(Order_Value_Net) AS Total_Net_Revenue,
SUM(Order_Value_Gross) AS Total_Gross_Revenue,
ROUND(SUM(Order_Value_Net)/COUNT(DISTINCT Order_ID),2) AS AOV,
SUM(Discount_Applied_Rs) AS Total_Discount
FROM Order_Clean;

--2. Monthly Business Performance ⭐

SELECT 
DATE_TRUNC('month', Dates)::DATE AS Order_Month,
COUNT(DISTINCT Order_ID) AS Monthly_Order,
SUM(Order_Value_Gross) AS Monthly_Gross_Revenue,
SUM(Order_Value_Net) AS Mothly_Net_Revenue,
 ROUND(
        SUM(Order_Value_Net) 
        / NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS Monthly_AOV
FROM Order_Clean
GROUP BY Order_Month
ORDER BY Order_Month;

--3. Month-over-Month (MoM) Growth Analysis
--Formula MOM Growth % = (Current_Month_Revenue - Prevois_Month_revenue)*100/Prevois_Month_revenue
WITH Monthly_Data AS (
    SELECT
        DATE_TRUNC('month', Dates)::DATE AS Order_Month,
        SUM(Order_Value_Net) AS Net_Revenue,
        COUNT(DISTINCT Order_ID) AS Total_Orders
    FROM Order_Clean
    GROUP BY DATE_TRUNC('month', Dates)::DATE
)

SELECT
    Order_Month,
    Net_Revenue,
    Total_Orders,
	 ROUND(
        (
            Net_Revenue
            - LAG(Net_Revenue) OVER (ORDER BY Order_Month)
        ) * 100.0
        / NULLIF(
            LAG(Net_Revenue) OVER (ORDER BY Order_Month),
            0
        ),
        2
    ) AS MoM_Revenue_Growth_Percent,
	ROUND(
        (
            Total_Orders
            - LAG(Total_Orders) OVER (ORDER BY Order_Month)
        ) * 100.0
        / NULLIF(
            LAG(Total_Orders) OVER (ORDER BY Order_Month),
            0
        ),
        2
    ) AS MoM_Order_Growth_Percent	
FROM Monthly_Data
ORDER BY Order_Month;

--4.Monthly Return & RTO Trend

SELECT
DATE_TRUNC('Month',Dates):: DATE AS Order_Month,
COUNT(DISTINCT Order_ID) AS Total_Orders,
 ROUND(
        COUNT(DISTINCT Order_ID)
        FILTER (
            WHERE Delivered_Returned_RTO = 'Returned'
        ) * 100.0
        / NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS Return_Rate,
	  ROUND(
        COUNT(DISTINCT Order_ID)
        FILTER (
            WHERE Delivered_Returned_RTO = 'RTO'
        ) * 100.0
        / NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS RTO_Rate
FROM Order_Clean
GROUP BY Order_Month
ORDER BY Order_Month;

--PART C — Customer order Behavior
-- 5. First Order vs Repeat Order Performance

SELECT 
First_Order_vs_Repeat,
COUNT(DISTINCT Order_ID) AS Total_Orders,
SUM(Order_Value_Net) AS Total_Net_Order,
ROUND(SUM(Order_Value_Net)/NULLIF(COUNT(DISTINCT Order_ID),0),2) AS AOV,
ROUND(SUM(Order_Value_Net)*100.0/SUM(SUM(Order_Value_Net)) OVER(),2)
FROM Order_Clean
GROUP BY First_Order_vs_Repeat
ORDER BY First_Order_vs_Repeat;

--6. Channel Performance by First vs Repeat Orders
SELECT 
Channel_Source_Last_Touch,
First_Order_vs_Repeat,
COUNT(DISTINCT Order_ID) AS Total_Orders,
SUM(Order_Value_Net) AS Revenue
FROM Order_Clean
GROUP BY Channel_Source_Last_Touch,First_Order_vs_Repeat
ORDER BY Revenue DESC, Total_Orders DESC;

-- 7. CHANNEL PERFORMANCE
SELECT 
Channel_Source_Last_Touch,
COUNT(DISTINCT Order_ID) AS Total_Orders,
SUM(Order_Value_Net) AS Total_Net_Order,
ROUND(SUM(Order_Value_Net)/NULLIF(COUNT(DISTINCT Order_ID),0),2) AS AOV,
ROUND(SUM(Order_Value_Net)*100.0/SUM(SUM(Order_Value_Net)) OVER(),2)
AS Revenue_Contribution_Percent
FROM Order_Clean
GROUP BY Channel_Source_Last_Touch
ORDER BY Total_Orders DESC;


-- 8. Channel Performance and Order Status Analysis
SELECT
    Channel_Source_Last_Touch,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Order_Value_Net) AS Revenue,

    ROUND(
        COUNT(DISTINCT Order_ID)
        FILTER (WHERE Delivered_Returned_RTO = 'Returned')
        * 100.0
        / NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS Return_Rate,
    ROUND(
        COUNT(DISTINCT Order_ID)
        FILTER (WHERE Delivered_Returned_RTO = 'RTO')
        * 100.0
        / NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS RTO_Rate
FROM Order_Clean
GROUP BY Channel_Source_Last_Touch
ORDER BY Revenue DESC,RTO_Rate DESC;

--9. DISCOUNT ANALYSIS
SELECT 
Discount_Applied_Percent ,
COUNT(DISTINCT Order_ID) AS Total_Orders,
SUM(Discount_Applied_Rs) AS Total_Discount_Given,
ROUND(
COUNT(DISTINCT Order_ID)*100/SUM(COUNT(DISTINCT Order_ID))OVER(),2) 
AS Order_Percentage,
ROUND( SUM(Order_Value_Net) / NULLIF(COUNT(DISTINCT Order_ID), 0), 2 ) 
AS AOV,
COUNT(DISTINCT Order_ID)FILTER(WHERE First_Order_vs_Repeat = 'Repeat')
AS repeat_Order,
ROUND(
    COUNT(DISTINCT Order_ID) FILTER (
        WHERE First_Order_vs_Repeat = 'Repeat'
    ) * 100.0
    / NULLIF(COUNT(DISTINCT Order_ID), 0),
    2
) AS Repeat_Percentage

FROM Order_Clean
GROUP BY Discount_Applied_Percent
ORDER BY Discount_Applied_Percent;

--10. Discount Bucket Performance
SELECT
    CASE
        WHEN Discount_Applied_Percent = 0 THEN 'No Discount'
        WHEN Discount_Applied_Percent <= 10 THEN '1-10%'
        WHEN Discount_Applied_Percent <= 20 THEN '11-20%'
        WHEN Discount_Applied_Percent <= 30 THEN '21-30%'
        ELSE '30%+'
    END AS Discount_Distribution,
	COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Order_Value_Net) AS Revenue,
	ROUND(SUM(Order_Value_Net)/NULLIF(COUNT(DISTINCT Order_ID),0),2)AS AOV
FROM Order_Clean
GROUP BY Discount_Distribution
ORDER BY Discount_Distribution;

--11. Overall Order Status Performance ⭐
SELECT
    COUNT(DISTINCT Order_ID) AS Total_Orders,

    COUNT(DISTINCT Order_ID)
        FILTER (WHERE Delivered_Returned_RTO = 'Returned')
        AS Returned_Orders,

    ROUND(
        COUNT(DISTINCT Order_ID)
        FILTER (WHERE Delivered_Returned_RTO = 'Returned')
        * 100.0
        / NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS Return_Rate,

    COUNT(DISTINCT Order_ID)
        FILTER (WHERE Delivered_Returned_RTO = 'RTO')
        AS RTO_Orders,

    ROUND(
        COUNT(DISTINCT Order_ID)
        FILTER (WHERE Delivered_Returned_RTO = 'RTO')
        * 100.0
        / NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS RTO_Rate,

    COUNT(DISTINCT Order_ID)
        FILTER (WHERE Delivered_Returned_RTO = 'Delivered')
        AS Delivered_Orders,

    ROUND(
        COUNT(DISTINCT Order_ID)
        FILTER (WHERE Delivered_Returned_RTO = 'Delivered')
        * 100.0
        / NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS Delivered_Rate

FROM Order_Clean;

--12. Revenue Impact by Order Status
SELECT
    Delivered_Returned_RTO AS Order_Status,
	COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Order_Value_Net) AS Total_Order_Value,
	ROUND(
	SUM(Order_Value_Net)*100.0/
	SUM(SUM(Order_Value_Net))OVER(),2) AS Revenue_Percentage
FROM Order_Clean
GROUP BY Delivered_Returned_RTO
ORDER BY Total_Order_Value DESC;

--13. Payment Mode Performance

SELECT 
Payment_Mode,
COUNT(DISTINCT Order_ID) AS Total_Orders,
SUM(Order_Value_Gross) AS Total_Gross_Value,
SUM(Order_Value_Net) AS Total_Net_Value,
ROUND(
        SUM(Order_Value_Net) * 1.0 /
        NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS AOV,

COUNT(DISTINCT Order_ID) FILTER(WHERE Delivered_Returned_RTO = 'RTO')
AS RTO_Orders,
COUNT(DISTINCT Order_ID) FILTER(WHERE Delivered_Returned_RTO = 'Delivered')
AS Delivered_Orders,
COUNT(DISTINCT Order_ID) FILTER(WHERE Delivered_Returned_RTO = 'Returned')
AS Returned_Orders
FROM Order_Clean
GROUP BY Payment_Mode
ORDER BY Total_Orders DESC;

--14. Payment Mode × RTO Rate

SELECT
     Payment_Mode,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Order_Value_Net) AS Revenue,
	COUNT(DISTINCT Order_ID)
	FILTER(WHERE  Delivered_Returned_RTO = 'RTO'
    ) AS RTO_Orders,

   ROUND(COUNT(DISTINCT Order_ID)
	FILTER(WHERE  Delivered_Returned_RTO = 'RTO')*100.0/
	NULLIF(COUNT(DISTINCT Order_ID),0),2) AS RTO_Rate

FROM Order_Clean
GROUP BY  Payment_Mode
ORDER BY RTO_Rate DESC;

--15. City-wise Business & Order Status Performance
SELECT 
Shipping_City,
SUM(Order_Value_Net) AS Total_Net_Value,
COUNT(DISTINCT Order_ID) FILTER(WHERE Delivered_Returned_RTO = 'Returned')
AS  Returned_Orders,
COUNT(DISTINCT Order_ID) FILTER(WHERE Delivered_Returned_RTO = 'Delivered')
AS Delivered_order,
COUNT(DISTINCT Order_ID) FILTER(WHERE Delivered_Returned_RTO = 'RTO')
AS RTO_Order
FROM Order_Clean
GROUP BY Shipping_City
ORDER BY RTO_Returned DESC,Returened_rate DESC,Delivered_rate DESC;

--16. Which channel generate more revenue and return order
SELECT 
Channel_Source_Last_Touch,
SUM(Order_Value_Net) AS Total_Net_Value,
COUNT(DISTINCT Order_ID) FILTER(WHERE Delivered_Returned_RTO = 'Returned')
AS Returned_Orders
FROM Order_Clean
GROUP BY Channel_Source_Last_Touch
ORDER BY Returned_Orders DESC;



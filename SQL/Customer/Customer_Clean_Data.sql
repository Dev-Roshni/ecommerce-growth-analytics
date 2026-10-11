DROP TABLE IF EXISTS customers_raw;

-- 2. CREATE RAW TABLE

CREATE TABLE customers_raw (
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    first_order_date DATE,
    total_orders INTEGER,
    total_revenue NUMERIC(12,2),
    average_order_value NUMERIC(12,2),
    time_to_2nd_purchase NUMERIC(10,2),
    last_purchase_date DATE,
    city_tier_raw VARCHAR(100),
    acquisition_channel VARCHAR(50),
    repurchased VARCHAR(5)
);

-- 3. LOAD RAW DATA
COPY customers_raw (
    customer_id,
    customer_name,
    first_order_date,
    total_orders,
    total_revenue,
    average_order_value,
    time_to_2nd_purchase,
    last_purchase_date,
    city_tier_raw,
    acquisition_channel,
    repurchased
)
FROM 'D:/E-Commerce_Analysis/customers.csv'
DELIMITER ','
CSV HEADER;


-- 4. CREATE CLEANING TABLE
DROP TABLE IF EXISTS customers_clean;

CREATE TABLE customers_clean AS
SELECT *
FROM customers_raw;


-- 5. CHECK IMPORTED DATA

SELECT *
FROM customers_clean
LIMIT 20;


-- 6. CHECK TOTAL ROWS AND UNIQUE CUSTOMERS
-- Confirms that the data was imported correctly.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM customers_clean;

--7. CUSTOMER_ID NULL / BLANK CHECK
SELECT *
FROM customers_clean
WHERE customer_id IS NULL
   OR TRIM(customer_id) = '';

--8. CHECK DUPLICATE CUSTOMER_ID
SELECT
    customer_id,
    COUNT(*) AS occurrence_count
FROM customers_clean
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

--9 SPLIT CITY AND TIER
-- First check the raw format.

SELECT City_tier_raw
FROM customers_clean;

--Test the split before updating
SELECT city_tier_raw,
SPLIT_PART(city_tier_raw,'/',1) AS City,
SPLIT_PART(city_tier_raw,'/',2) AS Tier
FROM customers_clean;

--ADD new column
ALTER TABLE customers_clean
ADD COLUMN City TEXT,
ADD COLUMN Tier TEXT;

--Now Update new colum
UPDATE customers_clean
SET
    City = TRIM(SPLIT_PART(city_tier_raw, '/', 1)),
    Tier = TRIM(SPLIT_PART(city_tier_raw, '/', 2));

--Verify
SELECT
    city_tier_raw,
    City,
    Tier
FROM customers_clean;

--Now Drop City_tier_raw
ALTER TABLE Customers_Clean
DROP COLUMN city_tier_raw

-- 10. find Null value in each column
SELECT 
COUNT(*) - COUNT(Customer_name) AS Customer_name_null,
COUNT(*) - COUNT(time_to_2nd_purchase) AS time_to_2nd_purchase_Null,
COUNT(*) - COUNT(first_order_date) AS first_order_date_null,
COUNT(*) - COUNT(total_orders ) AS total_orders_null,
COUNT(*) - COUNT(total_revenue) AS total_revenue_null,
COUNT(*) - COUNT(average_order_value) AS average_order_value_null,
COUNT(*) - COUNT( last_purchase_date) AS  last_purchase_date_null,
COUNT(*) - COUNT(acquisition_channel) AS acquisition_channel_null,
COUNT(*) - COUNT(City) AS City_null,
COUNT(*) - COUNT(Tier) AS Tier_null,
COUNT(*) - COUNT(repurchased) AS repurchased_null
From Customers_Clean;


--11. CHECK LEADING / TRAILING SPACES

SELECT 
    Customer_name,
    City,
    Tier,
    acquisition_channel
FROM Customers_Clean
WHERE Customer_name <> TRIM(Customer_name)
   OR City <> TRIM(City)
   OR Tier <> TRIM(Tier)
   OR acquisition_channel <> TRIM(acquisition_channel);

--12. CHECK MULTIPLE SPACES INSIDE CUSTOMER NAMES
SELECT Customer_name
FROM Customers_Clean
WHERE Customer_name ~ '\s{2,}'
   OR Customer_name <> TRIM(Customer_name);

--13.Look for impossible negative values.

SELECT * FROM Customers_Clean
WHERE total_orders < 0
OR total_revenue < 0
OR average_order_value < 0
 OR time_to_2nd_purchase < 0;

--14. CHECK DATE CONSISTENCY
SELECT *
FROM customers_clean
WHERE last_purchase_date < first_order_date;


/*15
VALIDATE AVERAGE ORDER VALUE
  Business rule:
Average Order Value = Total Revenue / Total Orders
NULLIF(total_orders, 0) prevents division-by-zero errors.
IF value1 = value2
        ↓
      NULL
IF value1 ≠ value2
        ↓
    value1

This query compares the stored AOV with the calculated AOV.
   Any returned rows indicate a possible inconsistency.   */

	SELECT
    customer_id,
    total_orders,
    total_revenue,
    average_order_value,
    ROUND(total_revenue / NULLIF(total_orders, 0), 2) AS calculated_AOV
FROM customers_clean
WHERE average_order_value IS DISTINCT FROM
      ROUND(total_revenue / NULLIF(total_orders, 0), 2);

--16. CHECK ACQUISITION CHANNEL VALUES
/*This helps identify:
   - Inconsistent category names
   - Unexpected values
   - Spelling differences
   - Extra categories
   */
   
SELECT
    acquisition_channel,
    COUNT(*) AS customer_count
FROM customers_clean
GROUP BY acquisition_channel
ORDER BY customer_count DESC;

--17. CHECK REPURCHASED VALUES
SELECT
    repurchased,
    COUNT(*) AS customer_count
FROM customers_clean
GROUP BY repurchased
ORDER BY customer_count DESC;

--18. FINAL CLEAN TABLE PREVIEW

SELECT *
FROM customers_clean
LIMIT 20;


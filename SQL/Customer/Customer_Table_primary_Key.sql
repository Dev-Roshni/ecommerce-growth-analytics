SELECT *
FROM customers_clean
LIMIT 10;

--Duplicate check
SELECT
    customer_id,
    COUNT(*) AS count
FROM customers_clean
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Null Check

SELECT Count(*) AS Null_Customer_id
FROM Customers_Clean
WHERE Customer_id IS Null;

--Add Primary Key

ALTER TABLE customers_clean
ADD CONSTRAINT customers_Primary_key
PRIMARY KEY (customer_id);

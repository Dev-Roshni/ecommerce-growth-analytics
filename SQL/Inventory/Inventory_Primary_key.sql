SELECT *
FROM MyInventroy_clean
LIMIT 10;

--Duplicate check
SELECT SKU,
inventory_date,
COUNT(*)
FROM MyInventroy_clean
GROUP BY SKU,inventory_date
HAVING COUNT(*) > 1;


-- Null Check

SELECT 
COUNT(*) - COUNT(SKU) AS SKU_null,
COUNT(*) - COUNT(inventory_date) AS inventory_date_null
From MyInventroy_clean;

--Add Primary Key

ALTER TABLE  MyInventroy_clean
ADD CONSTRAINT MyInventroy_Primary_key
PRIMARY KEY (SKU,inventory_date);



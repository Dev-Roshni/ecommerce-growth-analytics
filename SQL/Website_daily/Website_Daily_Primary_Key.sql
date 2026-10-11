SELECT * FROM Clean_Website_Daily
LIMIT 10;

--Check SKU duplicate in sku_catalog
SELECT 
     MyDate,
	Traffic_Source,
	Device_Category,
    COUNT(*) AS count
FROM Clean_Website_Daily
GROUP BY MyDate, Traffic_Source,Device_Category
HAVING COUNT(*) > 1;

--Check null in sku catalog null
SELECT COUNT(*)
FROM Clean_Website_Daily
WHERE MyDate IS NULL
OR Traffic_Source IS NULL
OR Device_Category IS NULL;

--Add primary key
ALTER TABLE Clean_Website_Daily
ADD CONSTRAINT Website_Daily_PK
PRIMARY KEY (MyDate,Traffic_Source,Device_Category );


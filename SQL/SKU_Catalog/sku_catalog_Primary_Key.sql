SELECT * FROM Clean_SKU_Catalogs
LIMIT 10;

--Check SKU duplicate in sku_catalog
SELECT 
    SKU,
    COUNT(*) AS count
FROM Clean_SKU_Catalogs
GROUP BY SKU
HAVING COUNT(*) > 1;

--Check null in sku catalog null
SELECT COUNT(*)
FROM Clean_SKU_Catalogs
WHERE SKU IS NULL;

--Add primary key
ALTER TABLE Clean_SKU_Catalogs
ADD CONSTRAINT SKU_Primary_Key
PRIMARY kEY (SKU);

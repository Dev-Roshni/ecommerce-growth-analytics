SELECT * FROM  Purchases_Orders_Clean
LIMIT 10;

--Check SKU duplicate in sku_catalog
SELECT 
     SKU,
	 Vendor,
	 Order_Date,
    COUNT(*) AS count
FROM Purchases_Orders_Clean
GROUP BY SKU , Vendor,Order_Date
HAVING COUNT(*) > 1;

--Check null in sku catalog null
SELECT COUNT(*)
FROM Purchases_Orders_Clean
WHERE SKU IS NULL
OR Vendor IS NULL
OR Order_Date IS NULL;

--Add primary key
ALTER TABLE Purchases_Orders_Clean
ADD CONSTRAINT  Purchases_Orders_PK
PRIMARY KEY (SKU,Vendor,Order_Date);

--Add Foreign key
ALTER TABLE Purchases_Orders_Clean
ADD CONSTRAINT Purchases_Orders_FK
FOREIGN KEY (SKU)
REFERENCES Clean_SKU_Catalogs(SKU);



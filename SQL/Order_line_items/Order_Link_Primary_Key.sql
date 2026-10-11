
SELECT * FROM Clean_FashionOrder
LIMIT 10;

--Check SKU duplicate in sku_catalog
SELECT 
     Order_ID,
	 SKU_ID,
    COUNT(*) AS count
FROM Clean_FashionOrder
GROUP BY order_ID,SKU_ID
HAVING COUNT(*) > 1;

--Check null in sku catalog null
SELECT COUNT(*)
FROM Clean_FashionOrder
WHERE SKU_ID IS NULL
OR Order_ID IS NULL;

--Add primary key
--No Any Primary key defined

--Add Foreign key

ALTER TABLE Clean_FashionOrder
ADD CONSTRAINT Fashion_Order_SKU_FK
FOREIGN KEY (SKU_ID)
REFERENCES Clean_SKU_Catalogs(SKU);


/*
ALTER TABLE Clean_FashionOrder
DROP CONSTRAINT Fashion_Order_SKU_FK;
*/


ALTER TABLE Clean_FashionOrder
ADD CONSTRAINT Fashion_Order_OrderID_FK
FOREIGN KEY (Order_ID)
REFERENCES Order_Clean(Order_ID);



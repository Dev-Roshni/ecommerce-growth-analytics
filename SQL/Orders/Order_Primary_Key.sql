SELECT * FROM Order_Clean
LIMIT 10;

--Check SKU duplicate in sku_catalog
SELECT 
     Order_ID,
    COUNT(*) AS count
FROM Fashion_Order
GROUP BY order_ID,SKU_ID
HAVING COUNT(*) > 1;

--Check null in sku catalog null
SELECT COUNT(*)
FROM Order_Clean
WHERE Order_ID IS NULL;

--Add primary key

ALTER TABLE Order_Clean
ADD CONSTRAINT Order_ID_FK
PRIMARY KEY(Order_ID)

--ADD Foreign key
ALTER TABLE Order_Clean
ADD CONSTRAINT Order_CustomerID_FK
FOREIGN KEY (Customer_ID)
REFERENCES Customers_Clean(customer_id);




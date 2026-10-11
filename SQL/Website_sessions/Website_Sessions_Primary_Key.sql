SELECT * FROM Clean_WebsiteSessions
LIMIT 10;

--Check SKU duplicate in sku_catalog
SELECT 
    Session_ID,
    MyDate,
    Traffic_Source,
    Campaign_Name,
    Device_Category,
    City,
    Sessions,
    Product_Views,
    Add_To_Cart,
    Begin_Checkout,
    Purchased,
    Order_ID,
    Customer_ID,
    Revenue,
COUNT(*) AS Duplicate_Count
FROM  Clean_WebsiteSessions
GROUP BY 
    Session_ID,
    MyDate,
    Traffic_Source,
    Campaign_Name,
    Device_Category,
    City,
    Sessions,
    Product_Views,
    Add_To_Cart,
    Begin_Checkout,
    Purchased,
    Order_ID,
    Customer_ID,
    Revenue
HAVING COUNT(*)>1;

--Check null in sku catalog null
SELECT
    COUNT(*) FILTER (WHERE Session_ID IS NULL) AS Session_ID_NULL,
    COUNT(*) FILTER (WHERE MyDate IS NULL) AS MyDate_NULL,
    COUNT(*) FILTER (WHERE Traffic_Source IS NULL) AS Traffic_Source_NULL,
    COUNT(*) FILTER (WHERE Campaign_Name IS NULL) AS Campaign_Name_NULL,
    COUNT(*) FILTER (WHERE Device_Category IS NULL) AS Device_Category_NULL,
    COUNT(*) FILTER (WHERE City IS NULL) AS City_NULL,
    COUNT(*) FILTER (WHERE Sessions IS NULL) AS Sessions_NULL,
    COUNT(*) FILTER (WHERE Product_Views IS NULL) AS Product_Views_NULL,
    COUNT(*) FILTER (WHERE Add_To_Cart IS NULL) AS Add_To_Cart_NULL,
    COUNT(*) FILTER (WHERE Begin_Checkout IS NULL) AS Begin_Checkout_NULL,
    COUNT(*) FILTER (WHERE Purchased IS NULL) AS Purchased_NULL,
    COUNT(*) FILTER (WHERE Order_ID IS NULL) AS Order_ID_NULL,
    COUNT(*) FILTER (WHERE Customer_ID IS NULL) AS Customer_ID_NULL,
    COUNT(*) FILTER (WHERE Revenue IS NULL) AS Revenue_NULL
FROM Clean_WebsiteSessions;

--No primary key

--Foreign key Customer_ID
ALTER TABLE Clean_WebsiteSessions
ADD CONSTRAINT Website_Session_FK
FOREIGN KEY (Customer_ID)
REFERENCES customers_clean(Customer_ID);

--Foreign key Order ID
ALTER TABLE Clean_WebsiteSessions
ADD CONSTRAINT Website_Session_OrderID_FK
FOREIGN KEY (Order_ID )
REFERENCES Order_Clean(Order_ID);



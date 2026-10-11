-- FOREIGN KEY INTEGRITY CHECK
-- Expected Result:
-- 0 rows = No orphan foreign key found

---- 1. Orders → Customers
SELECT o.Customer_ID
FROM Order_Clean o
LEFT JOIN Customers_Clean c
    ON o.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;

-- 2. Order_Line_Item → Orders
SELECT f.Order_ID
FROM Clean_FashionOrder f
LEFT JOIN Order_Clean o
    ON f.Order_ID = o.Order_ID
WHERE o.Order_ID IS NULL;

-- 3. Order_Line_Item → SKU_Catalog
SELECT f.SKU_ID
FROM Clean_FashionOrder f
LEFT JOIN Clean_SKU_Catalogs s
ON f.SKU_ID = s.SKU
WHERE s.SKU IS NULL;


-- 4. Inventory_Snapshot → SKU_Catalog
SELECT i.SKU
FROM MyInventroy_clean i
LEFT JOIN Clean_SKU_Catalogs s
ON i.SKU = s.SKU
WHERE s.SKU IS NULL;


-- 5. Purchase_Order → SKU_Catalog
SELECT p.SKU
FROM Purchases_Orders_Clean p
LEFT JOIN Clean_SKU_Catalogs s
    ON p.SKU = s.SKU
WHERE s.SKU IS NULL;


-- 6. Website_Sessions → Customers
SELECT w.Customer_ID
FROM  Clean_WebsiteSessions w
LEFT JOIN Customers_Clean c
    ON w.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;

-- 7. Website_Sessions → Orders
SELECT w.Order_ID
FROM Clean_WebsiteSessions w
LEFT JOIN Order_Clean o
    ON w.Order_ID = o.Order_ID
WHERE o.Order_ID IS NULL;

-- 6. Website_Sessions → Customers: Check orphan Customer_IDs
SELECT DISTINCT w.Customer_ID
FROM Clean_WebsiteSessions w
LEFT JOIN Customers_Clean c
ON w.Customer_ID = c.Customer_ID
WHERE w.Customer_ID IS NOT NULL
AND c.Customer_ID IS NULL;


-- 7. Website_Sessions → Orders: Check orphan Order_IDs
SELECT DISTINCT w.Order_ID
FROM Clean_WebsiteSessions w
LEFT JOIN Order_Clean o
    ON w.Order_ID = o.Order_ID
WHERE w.Order_ID IS NOT NULL
  AND o.Order_ID IS NULL;

  
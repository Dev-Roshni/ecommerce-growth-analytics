--Product Catalog
--Total number of unique SKUs
SELECT
    COUNT(DISTINCT SKU) AS Total_SKU,
	COUNT(DISTINCT Category) AS Total_Categories,
    COUNT(DISTINCT Vendor) AS Total_Vendors	
FROM Clean_SKU_Catalogs;

--Number of SKUs in each category

SELECT 
Category,
COUNT(DISTINCT SKU) AS Total_SKU
FROM Clean_SKU_Catalogs
GROUP BY Category
ORDER BY Total_SKU DESC;

--Average MRP and cost by category
SELECT 
Category,
COUNT(DISTINCT SKU) AS Total_SKU,
ROUND(AVG(MRP), 2) AS Average_MRP,
ROUND(AVG(Cost_Per_Unit), 2) AS Average_Cost_Per_Unit
FROM Clean_SKU_Catalogs
GROUP BY Category
ORDER BY Total_SKU DESC;

--Sum of listed MRP and unit cost by category
SELECT
    Category,
    SUM(MRP) AS Sum_of_MRP,
    SUM(Cost_Per_Unit) AS Sum_of_Unit_Cost
FROM Clean_SKU_Catalogs
GROUP BY Category
ORDER BY Sum_of_MRP DESC;

--Category-wise potential gross margin
SELECT
    Category,
    ROUND(
        AVG(
            (MRP - Cost_Per_Unit) * 100.0
            / NULLIF(MRP, 0)
        ),
        2
    ) AS Average_Gross_Margin_Percent
FROM Clean_SKU_Catalogs
GROUP BY Category
ORDER BY Average_Gross_Margin_Percent DESC;

--Number of SKUs supplied by each vendor
SELECT
    Vendor,
    COUNT(DISTINCT SKU) AS Total_SKUs_Supplied,
	ROUND(AVG(MRP), 2) AS Average_MRP,
    ROUND(AVG(Cost_Per_Unit), 2) AS Average_Cost
FROM Clean_SKU_Catalogs
GROUP BY Vendor
ORDER BY Total_SKUs_Supplied DESC;

--SKU Profitability Analysis
SELECT
    SKU,
    Category,
    Vendor,
    MRP,
    Cost_Per_Unit,
    MRP - Cost_Per_Unit AS Potential_Gross_Profit_Per_Unit,
	 ROUND(
        (MRP - Cost_Per_Unit) * 100.0
        / NULLIF(MRP, 0),
        2
    ) AS Potential_Gross_Margin_Percent
	
FROM Clean_SKU_Catalogs
ORDER BY Potential_Gross_Profit_Per_Unit DESC;

--Highest cost products
SELECT
    SKU,
    Category,
    Vendor,
    Cost_Per_Unit
FROM Clean_SKU_Catalogs
ORDER BY Cost_Per_Unit DESC;

--MRP range by category
SELECT
    Category,
    MIN(MRP) AS Minimum_MRP,
    MAX(MRP) AS Maximum_MRP,
    ROUND(AVG(MRP), 2) AS Average_MRP
FROM Clean_SKU_Catalogs
GROUP BY Category
ORDER BY Average_MRP DESC;

--Cost range by category
SELECT
    Category,
    MIN(Cost_Per_Unit) AS Minimum_Cost_Per_Unit,
    MAX(Cost_Per_Unit) AS Maximum_Cost_Per_Unit,
    ROUND(AVG(Cost_Per_Unit), 2) AS Average_Cost_Per_Unit
FROM Clean_SKU_Catalogs
GROUP BY Category
ORDER BY Average_Cost_Per_Unit DESC;


--Category–Vendor relationship
SELECT
Category,
COUNT(DISTINCT Vendor) AS Total_Vendors
FROM Clean_SKU_Catalogs
GROUP BY Category
ORDER BY Total_Vendors DESC;
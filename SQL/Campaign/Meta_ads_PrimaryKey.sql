SELECT * FROM  CampaignInfo_Clean
LIMIT 10;

--Check SKU duplicate in sku_catalog
SELECT 
     Campaign_Name,
	 Campaign_Date,
    COUNT(*) AS count
FROM CampaignInfo_Clean
GROUP BY Campaign_Name , Campaign_Date
HAVING COUNT(*) > 1;

--Check null in sku catalog null
SELECT COUNT(*)
FROM CampaignInfo_Clean
WHERE Campaign_Name IS NULL
OR Campaign_Date IS NULL;

--Add primary key
ALTER TABLE CampaignInfo_Clean
ADD CONSTRAINT  CampaignInfo_PK
PRIMARY KEY (Campaign_Name,Campaign_Date);

/*
ALTER TABLE CampaignInfo_Clean
DROP CONSTRAINT CampaignInfo_PK;
*/

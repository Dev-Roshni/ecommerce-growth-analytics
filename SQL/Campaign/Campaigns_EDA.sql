/*Company ne ₹38,619 advertisement par spend kiya.
Ad 4.35 lakh unique people tak pahucha aur total 8.27 lakh times show hua.
Average person ne ad 1.9 times dekha. 10,759 clicks aaye. 
474 users ne product cart mein dala, 268 ne checkout start kiya aur 187 purchases hui. 
Total purchase value ₹5.15 lakh ke around rahi. 
Ek customer acquire karne ki advertising cost ₹206.52 rahi aur har ₹1 ad spend se ₹13.33 revenue generate hua. 
Advertisement Static format ka tha.
*/

--1. Total campaigns, total ad spend, total impressions,
--total reach aur total purchases kitne hain?
SELECT 
COUNT(DISTINCT Campaign_Name) AS Total_No_Of_Campaigns,
SUM( Amount_Spent_INR ) AS Amount_Spent_INR ,
SUM( Impressions) AS Total_Impressions,
SUM( Reach) AS Total_Reach,
SUM(Purchases ) AS Total_Purchases,
SUM(Purchase_Conversion_Value) AS Total_Revenue
FROM CampaignInfo_Clean;


--2. Campaign-wise Spend, Impressions, Reach, Clicks aur Purchases kya hain?
SELECT
    Campaign_Name,
    SUM(Amount_Spent_INR) AS Total_Spend,
    SUM(Impressions) AS Total_Impressions,
    SUM(Reach) AS Total_Reach,
    SUM(Link_Clicks) AS Total_Clicks,
    SUM(Add_to_Cart) AS Total_Add_to_Cart,
    SUM(Initiate_Checkout) AS Total_Checkout,
    SUM(Purchases) AS Total_Purchases
FROM CampaignInfo_Clean
GROUP BY Campaign_Name
ORDER BY Total_Spend DESC;
--3.Campaigns ko Spend ke basis par rank karne par top campaigns kaunse hain?
SELECT 
    Campaign_Name,
    SUM(Amount_Spent_INR) AS Total_Spend,
    RANK() OVER (
        ORDER BY SUM(Amount_Spent_INR) DESC
    ) AS Spend_Rank
FROM CampaignInfo_Clean
GROUP BY Campaign_Name
ORDER BY Spend_Rank;
--4.Campaigns ko Purchase Conversion Value ke basis par rank karne par top campaigns kaunse hain?
SELECT 
    Campaign_Name,
    SUM(Purchase_Conversion_Value) AS Total_Purchase_Value,
    RANK() OVER (
        ORDER BY SUM(Purchase_Conversion_Value) DESC
    ) AS Revenue_Rank
FROM CampaignInfo_Clean
GROUP BY Campaign_Name
ORDER BY Revenue_Rank;

--5. Campaign-level CTR calculate karo:
SELECT 
    Campaign_Name,
    SUM(Link_Clicks) AS Total_Clicks,
    SUM(Impressions) AS Total_Impressions,
    ROUND(
        SUM(Link_Clicks) * 100.0 /
        NULLIF(SUM(Impressions), 0),
        2
    ) AS CTR
FROM CampaignInfo_Clean
GROUP BY Campaign_Name
ORDER BY CTR DESC;

--6. Kya higher impressions wale campaigns necessarily higher clicks generate kar rahe hain?

SELECT 
Campaign_Name,
SUM(Impressions) AS Total_Impressions,
SUM(Link_Clicks) AS Total_Clicks,
ROUND(
        SUM(Link_Clicks) * 100.0 /
        NULLIF(SUM(Impressions),0),
        2
    ) AS CTR
FROM CampaignInfo_Clean
GROUP BY Campaign_Name
ORDER BY Total_Impressions DESC;
--7. Campaign-wise CPC (Cost per Click) kya hai aur kaunse campaigns traffic most efficiently generate kar rahe hain?
--CPC batata hai ki 1 ad click generate karne ke liye average kitna paisa spend hua. 

SELECT 
Campaign_Name,
SUM(Amount_Spent_INR) AS Total_Spend,
SUM(Link_Clicks) AS Total_Clicks,
ROUND(
 SUM(Amount_Spent_INR)/NULLIF(SUM(Link_Clicks),0),2
)AS Cost_per_Click
FROM CampaignInfo_Clean
GROUP BY Campaign_Name
ORDER BY Cost_per_Click ASC;

/*8.Reach vs Frequency ke basis par kaunse campaigns 
audience saturation ke signs dikha rahe hain?
*/

--Campaign-wise Reach & Impressions
SELECT Campaign_Name,
SUM(Reach) AS TOtal_Reach,
SUM(Impressions) AS Total_Impressions,
 ROUND( SUM(Impressions) * 1.0 / NULLIF(SUM(Reach), 0), 2)
 AS Frequency,

FROM CampaignInfo_Clean
GROUP BY Campaign_Name
ORDER BY Total_Reach DESC;

---CTR Finding 
SELECT 
    Campaign_Name,
    SUM(Impressions) AS Total_Impressions,
    SUM(Link_Clicks) AS Total_Clicks,
	ROUND(SUM(Link_Clicks)*100.0/NULLIF(SUM(Impressions),0),2)
	AS CTR
	
FROM CampaignInfo_Clean
GROUP BY Campaign_Name
ORDER BY CTR DESC;

-- Find frequency high,low,moderate
SELECT 
    Campaign_Name,
    SUM(Impressions) AS Total_Impressions,
    SUM(Link_Clicks) AS Total_Clicks,
	
    ROUND(SUM(Impressions) * 1.0 /NULLIF(SUM(Reach), 0),2)
	AS Avg_Frequency,
CASE
        WHEN SUM(Impressions) * 1.0 /
             NULLIF(SUM(Reach), 0) >= 2.2
            THEN 'High Saturation Signal'

        WHEN SUM(Impressions) * 1.0 /
             NULLIF(SUM(Reach), 0) >= 1.5
            THEN 'Moderate Saturation Signal'

        ELSE 'Low Saturation Signal'
    END AS Saturation_Level
	
FROM CampaignInfo_Clean
GROUP BY Campaign_Name
ORDER BY  Saturation_Level DESC;
--Part 2 ROAS & CAC
--Campaign-wise ROAS kya hai aur highest/lowest ROAS campaigns kaunse hain?
SELECT 
    Campaign_Name,
    ROAS
FROM CampaignInfo_Clean
ORDER BY ROAS DESC;

--Campaign-wise CAC kya hai aur kaunse campaigns customer acquisition 
--sabse efficiently kar rahe hain?

SELECT
    Campaign_Name,
	Amount_Spent_INR,
	Purchases,
    CAC
FROM CampaignInfo_Clean
ORDER BY CAC DESC;

--ROAS Range Width
SELECT
ROAS,
CASE 
WHEN ROAS < 4.88 THEN 'Low ROAS'
WHEN ROAS < 9.12 THEN 'Moderate ROAS'
ELSE 'High ROAS'
END AS ROAS_Range_Width
FROM CampaignInfo_Clean;

--CAC Range Width
SELECT 
CAC,
CASE 
WHEN CAC < 1337.31 THEN 'Low CAC'
WHEN CAC < 2468.11 THEN 'Moderate CAC'
ELSE 'High CAC'
END AS CAC_Range_Width
FROM CampaignInfo_Clean
ORDER BY CAC_Range_Width;

--Amount_Spent_INR Statictical operation
SELECT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY Amount_Spent_INR) AS Q1_25,

PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY Amount_Spent_INR) AS Q3_50,
		
    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY Amount_Spent_INR) AS Q3_75

FROM CampaignInfo_Clean;

--Amount_Spent_INR Distribution
WITH Spend_Threshold AS (

    SELECT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY Amount_Spent_INR) AS Q1_25,

        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY Amount_Spent_INR) AS Q3_75

    FROM CampaignInfo_Clean
)

SELECT
    c.Campaign_Name,
    c.Amount_Spent_INR,

    CASE
        WHEN c.Amount_Spent_INR < S.Q1_25
            THEN 'Low Spend'

        WHEN c.Amount_Spent_INR <= S.Q3_75
            THEN 'Moderate Spend'

        ELSE 'High Spend'
    END AS Spend_Level

FROM CampaignInfo_Clean c
CROSS JOIN Spend_Threshold S
ORDER BY c.Amount_Spent_INR DESC;

--High Spend + Low ROAS campaigns kaunse hain?
SELECT
    Campaign_Name,
    Amount_Spent_INR,
    ROAS
FROM CampaignInfo_Clean
WHERE Amount_Spent_INR >
      (
          SELECT PERCENTILE_CONT(0.75)
                 WITHIN GROUP (ORDER BY Amount_Spent_INR)
          FROM CampaignInfo_Clean
      )
AND ROAS < 4.88
ORDER BY Amount_Spent_INR DESC;

--Low CAC + High ROAS campaigns kaunse hain?
SELECT
    Campaign_Name,
    CAC,
    ROAS
FROM CampaignInfo_Clean
WHERE  CAC < 1337.31 
AND ROAS >= 9.12
ORDER BY ROAS ;

--High CAC + High ROAS campaigns kaunse hain?
SELECT
    Campaign_Name,
    CAC,
    ROAS
FROM CampaignInfo_Clean
WHERE  CAC >= 2468.11  
AND ROAS >= 9.12
ORDER BY ROAS ;

--PART 3 — Conversion Funnel

--14. Campaign-wise Click → Add-to-Cart Conversion Rate
/*simple meaaning - > Jo users ad par click karte hain, 
unmein se kitne % users Add to Cart karte hain?
Formula:
Click → ATC Rate = Add to Cart / Link Clicks × 100
*/

SELECT 
    Campaign_Name,
    SUM(Link_Clicks) AS Total_Clicks,
    SUM(Add_To_Cart) AS Total_Add_To_Cart,

    ROUND(
        SUM(Add_To_Cart) * 100.0 /
        NULLIF(SUM(Link_Clicks), 0),
        2
    ) AS Click_To_ATC_Rate

FROM CampaignInfo_Clean
GROUP BY Campaign_Name
ORDER BY Click_To_ATC_Rate DESC;

-- 15. Campaign-wise Add-to-Cart → Checkout conversion rate
/*
Business Meaning:
Jo users Add to Cart karte hain,
unmein se kitne % users Checkout initiate karte hain?

Formula:
ATC → Checkout Rate =
Initiate Checkout / Add to Cart × 100
*/
SELECT 
    Campaign_Name,
    SUM(Add_To_Cart) AS Total_Add_To_Cart,
    SUM(Initiate_Checkout) AS Total_Initiate_Checkout,

    ROUND(
        SUM(Initiate_Checkout) * 100.0 /
        NULLIF(SUM(Add_To_Cart), 0),
        2
    ) AS ATC_to_Checkout_Rate

FROM CampaignInfo_Clean
GROUP BY Campaign_Name
ORDER BY ATC_to_Checkout_Rate DESC;

-- 16. Campaign-wise Checkout → Purchase conversion rate
/*
Business Meaning:
Checkout initiate karne wale users mein se kitne % users
actually purchase complete karte hain?

Formula:
Checkout → Purchase Rate =
Purchases / Initiate Checkout × 100
*/
SELECT 
    Campaign_Name,
    SUM(Initiate_Checkout) AS Total_Initiate_Checkout,
    SUM(Purchases) AS Total_Purchases,
    ROUND(
        SUM(Purchases) * 100.0 /
        NULLIF(SUM(Initiate_Checkout), 0),
        2
    ) AS Checkout_To_Purchase_Rate
FROM CampaignInfo_Clean
GROUP BY Campaign_Name
ORDER BY Checkout_To_Purchase_Rate DESC;

-- 17. Identify campaigns with high clicks but low purchases
/*
Business Meaning:
Aise campaigns identify karna jo website par
kaafi traffic la rahe hain, lekin purchases comparatively low hain.

Interpretation:
High Clicks + Low Purchase Conversion Rate
→ Possible conversion/funnel problem.
*/
WITH Campaign_Performance AS (

    SELECT
        Campaign_Name,

        SUM(Link_Clicks) AS Total_Clicks,

        SUM(Purchases) AS Total_Purchases,

        ROUND(
            SUM(Purchases) * 100.0 /
            NULLIF(SUM(Link_Clicks), 0),
            2
        ) AS Click_To_Purchase_Rate

    FROM CampaignInfo_Clean

    GROUP BY Campaign_Name
),

Thresholds AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY Total_Clicks
        ) AS High_Click_Threshold,

        PERCENTILE_CONT(0.25)
        WITHIN GROUP (
            ORDER BY Click_To_Purchase_Rate
        ) AS Low_Conversion_Threshold

    FROM Campaign_Performance
)

SELECT
    cp.Campaign_Name,
    cp.Total_Clicks,
    cp.Total_Purchases,
    cp.Click_To_Purchase_Rate

FROM Campaign_Performance cp

CROSS JOIN Thresholds t
WHERE cp.Total_Clicks > t.High_Click_Threshold
  AND cp.Click_To_Purchase_Rate < t.Low_Conversion_Threshold
ORDER BY cp.Click_To_Purchase_Rate ASC;

-- 18. Identify campaigns with high Add-to-Cart
-- but low purchase performance
/*
Business Meaning:
Aise campaigns identify karna jahan users interested hain
(High Add-to-Cart), lekin purchase complete nahi kar rahe.

Possible issue:
Checkout friction, pricing, shipping cost, trust,
payment issue, etc.
*/


WITH Campaign_Performance AS (

    SELECT
        Campaign_Name,

        SUM(Add_To_Cart) AS Total_Add_To_Cart,

        SUM(Initiate_Checkout) AS Total_Checkout,

        SUM(Purchases) AS Total_Purchases,

        ROUND(
            SUM(Purchases) * 100.0 /
            NULLIF(SUM(Add_To_Cart), 0),
            2
        ) AS ATC_To_Purchase_Rate

    FROM CampaignInfo_Clean

    GROUP BY Campaign_Name
),

Thresholds AS (

    SELECT
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (
            ORDER BY Total_Add_To_Cart
        ) AS High_ATC_Threshold,

        PERCENTILE_CONT(0.25)
        WITHIN GROUP (
            ORDER BY ATC_To_Purchase_Rate
        ) AS Low_Conversion_Threshold

    FROM Campaign_Performance
)

SELECT
    cp.Campaign_Name,
    cp.Total_Add_To_Cart,
    cp.Total_Checkout,
    cp.Total_Purchases,
    cp.ATC_To_Purchase_Rate

FROM Campaign_Performance cp

CROSS JOIN Thresholds t

WHERE cp.Total_Add_To_Cart > t.High_ATC_Threshold
  AND cp.ATC_To_Purchase_Rate < t.Low_Conversion_Threshold

ORDER BY cp.ATC_To_Purchase_Rate ASC;

-- 19. Campaign-wise Click → Purchase conversion rate
/*
Business Meaning:
Ad par click karne wale users mein se kitne % users
ultimately purchase complete karte hain?

Formula:
Click → Purchase Rate =
Purchases / Link Clicks × 100

Higher rate = Better click-to-purchase efficiency
*/
      
SELECT
    Campaign_Name,

    SUM(Link_Clicks) AS Total_Clicks,

    SUM(Purchases) AS Total_Purchases,

    ROUND(
        SUM(Purchases) * 100.0 /
        NULLIF(SUM(Link_Clicks), 0),
        2
    ) AS Click_To_Purchase_Rate

FROM CampaignInfo_Clean
GROUP BY Campaign_Name
ORDER BY Click_To_Purchase_Rate DESC;

--PART 4 Creative Performance
--20 Creative type-wise CTR kya hai?

SELECT 
    Creative_Type,
    SUM(Link_Clicks) AS Total_Clicks,
    SUM(Impressions) AS Total_Impressions,
    ROUND(
        SUM(Link_Clicks) * 100.0 /
        NULLIF(SUM(Impressions), 0),
        2
    ) AS CTR
FROM CampaignInfo_Clean
GROUP BY Creative_Type
ORDER BY CTR DESC;

--21 Creative type-wise ROAS kya hai?
SELECT
Creative_Type,
SUM( Purchase_Conversion_Value)AS Total_Purchase_Conversion_Value,
SUM(Amount_Spent_INR) AS Amount_Spent,
ROUND(
SUM(Amount_Spent_INR)*100.0/
NULLIF(SUM( Purchase_Conversion_Value),0),2)
AS ROAS
FROM CampaignInfo_Clean
GROUP BY Creative_Type
ORDER BY ROAS DESC;

--22 Creative type-wise CAC kya hai?
SELECT
Creative_Type,
SUM(Amount_Spent_INR) AS Amount_Spent,
SUM( Purchases) AS Total_Purchases,
ROUND(
SUM(Purchases)*100.0/
NULLIF(SUM(Amount_Spent_INR),0),2)
AS CAC
FROM CampaignInfo_Clean
GROUP BY Creative_Type
ORDER BY CAC DESC;

--23 Creative type-wise Purchase volume kya hai?
SELECT
Creative_Type,
SUM(Purchases) AS Total_Purchases,
FROM CampaignInfo_Clean
GROUP BY Creative_Type
ORDER BY Total_Purchases DESC;

--Hook Rate aur CTR ke beech kya relationship hai?
SELECT
 Campaign_Name,
 Hook_Rate,
 Link_Clicks,
 Impressions,
 ROUND(
        Link_Clicks * 100.0 / NULLIF(Impressions, 0), 2 )
		AS CTR
FROM CampaignInfo_Clean
ORDER BY Hook_Rate DESC;

/*Hook Rate showed a very weak positive association with CTR (Pearson correlation = 0.088), 
indicating that higher hook rates alone were not strongly associated with higher click-through 
rates across the analyzed campaigns.*/

SELECT
    ROUND(
        CORR(
            Hook_Rate,
            Link_Clicks * 1.0 /
            NULLIF(Impressions,0)
        )::numeric,
        3
    ) AS Hook_Rate_CTR_Correlation
FROM CampaignInfo_Clean;

--PART 5 — Final Business Decision
--Kaunse campaigns overall best performers hain ROAS,CAC, Purchases,CTR
WITH Campaign_Metrics AS(
SELECT 
Campaign_Name,
ROAS AS Return_on_AD_spend,
CAC AS Customer_Aquisition_Cost,
Purchases,
ROUND(
Link_Clicks*100.0/NULLIF(Impressions,0),2) AS CTR
FROM CampaignInfo_Clean
),
Campaign_Ranks AS(
SELECT *,
RANK() OVER( ORDER BY  Return_on_AD_spend  DESC) AS ROAS_RANK,
RANK() OVER(ORDER BY Customer_Aquisition_Cost ASC) AS CAC_RANK,
RANK() OVER(ORDER BY Purchases DESC) AS Purchases_RANK,
RANK() OVER(ORDER BY CTR DESC) AS Click_Through_RANK
FROM Campaign_Metrics
),
Final_Score AS(
SELECT *,
ROAS_RANK+
CAC_RANK+
Purchases_RANK+
Click_Through_RANK
AS Overall_Rank_Score
FROM Campaign_Ranks
),
Final_Ranking AS(
SELECT *,
RANK() OVER (
    ORDER BY Overall_Rank_Score ASC
) AS Overall_Rank
FROM Final_Score
)

SELECT * FROM Final_Ranking
ORDER BY Overall_Rank;

--26. Kaunse campaigns ko scale karna chahiye?
--Strong ROAS + low CAC + sufficient purchase volume.
SELECT 
    Campaign_Name,
    ROAS AS Return_On_Ad_Spend,
    CAC AS Customer_Acquisition_Cost,
    Purchases
FROM CampaignInfo_Clean
WHERE ROAS >= (
        SELECT AVG(ROAS)
        FROM CampaignInfo_Clean
      )
  AND CAC <= (
        SELECT AVG(CAC)
        FROM CampaignInfo_Clean
      )
  AND Purchases >= (
        SELECT PERCENTILE_CONT(0.50)
               WITHIN GROUP (ORDER BY Purchases)
        FROM CampaignInfo_Clean
      )
ORDER BY ROAS DESC, CAC ASC, Purchases DESC;

--Kaunse campaigns ko optimize/review karna chahiye?
--High spend + weak ROAS / weak funnel.
SELECT 
    Campaign_Name,
	Amount_Spent_INR AS Amount_Spent_INR,
    ROAS AS Return_On_Ad_Spend
	
FROM CampaignInfo_Clean
WHERE  Amount_Spent_INR >= (
        SELECT AVG(Amount_Spent_INR)
        FROM CampaignInfo_Clean
      )
  AND ROAS <= (
        SELECT AVG(ROAS)
        FROM CampaignInfo_Clean
      )
ORDER BY Amount_Spent_INR DESC,ROAS ASC;


CREATE OR ALTER VIEW vw_CleanedRetail AS

SELECT
    InvoiceNo,
    StockCode,
    Description,
    TRY_CAST(Quantity AS FLOAT) AS Quantity,
    TRY_CONVERT(DATETIME, InvoiceDate, 105) AS InvoiceDate,
    TRY_CAST(UnitPrice AS FLOAT) AS UnitPrice,
    CustomerID,
    Country,
    TRY_CAST(Quantity AS FLOAT) * TRY_CAST(UnitPrice AS FLOAT) AS TotalPrice

FROM dbo.online_retail

WHERE
    CustomerID IS NOT NULL
    AND InvoiceNo NOT LIKE 'C%'
    AND ISNUMERIC(Quantity) = 1
    AND ISNUMERIC(UnitPrice) = 1;

SELECT *
FROM vw_CleanedRetail;

what is overall revenue in dataset
select sum(TotalPrice) as overall_revenue
from vw_CleanedRetail

which country genrates the most revenue
select Country,sum(TotalPrice) as Highest_revenue
from vw_CleanedRetail
group by Country
order by Highest_revenue DESC

WHO are your highestvalue customers? top10 customer by spending

select CustomerID,sum(TotalPrice) as highest_spending
from vw_CleanedRetail
group by CustomerID
order by highest_spending desc

montlhy revenue trend inssights: are there seasonal pattern or growth over time\


select FORMAT(InvoiceDate,'yyyy-MM') as month ,sum(TotalPrice) as Revenue
from vw_CleanedRetail
group by FORMAT(InvoiceDate,'yyyy-MM') 
order by month

SELECT
    FORMAT(TRY_CONVERT(DATETIME, InvoiceDate, 105),'yyyy-MM') AS Month,
    SUM(TotalPrice) AS Revenue
FROM vw_CleanedRetail
GROUP BY FORMAT(TRY_CONVERT(DATETIME, InvoiceDate, 105),'yyyy-MM')
ORDER BY Month;

most purchased products insight: which products are the best seller?

select Description, round(sum(TotalPrice),2) as revenue
from vw_CleanedRetail
group by Description
order by Revenue desc

order by time of day insights: when do customers shop most ( morining vs evening)?

select DATEPART(HOUR,InvoiceDate) AS TimeofDay  ,count(distinct InvoiceNo) as no_of_orders
from vw_CleanedRetail
group by DATEPART(HOUR,InvoiceDate) 
order by no_of_orders desc

select MAX(InvoiceDate)
from vw_CleanedRetail

create or alter view  vw_RFM AS
select CustomerID,
datediff(day,max(InvoiceDate),(select max(InvoiceDate) from vw_CleanedRetail)) as recency,
count(distinct InvoiceNO) as frequency,
sum(TotalPrice) as monetary
from vw_CleanedRetail
group by CustomerID

select *from vw_RFM

with RFM_ranked as(
select CustomerID,recency,frequency,monetary,
NTILE(5) OVER(ORDER BY recency desc) as R_SCORE,                      
NTILE(5) OVER(ORDER BY frequency asc) as F_SCORE, 
NTILE(5) OVER(ORDER BY  monetary asc) as M_SCORE     
 from vw_RFM)

 select CustomerID, recency, frequency,monetary,R_SCORE,F_SCORE,M_SCORE,
 CAST(R_SCORE AS varchar)+CAST(F_SCORE AS varchar)+CAST(M_SCORE AS varchar) as RFM_SCORE
 INTO RFM_Scored
 FROM RFM_ranked

 select*from RFM_Scored
 ORDER BY RFM_SCORE DESC


 SELECT *
FROM RFM_Scored
WHERE RFM_SCORE = '555'

SELECT *
FROM RFM_Scored

SELECT
COUNT(DISTINCT InvoiceNo) AS Orders
FROM vw_CleanedRetail;

SELECT
SUM(TotalPrice) * 1.0 /
COUNT(DISTINCT InvoiceNo) AS AOV
FROM vw_CleanedRetail;
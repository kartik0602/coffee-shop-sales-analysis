select * from [Coffeeshop ]
use [coffe shop]
EXEC sp_help [Coffeeshop ]
---------------------------------TOTAL SALES OF EVERY MONTH----------------------------
SELECT DATENAME(MONTH,TRANSACTION_DATE) AS MONTHS  ,CONCAT(ROUND(SUM(UNIT_PRICE * TRANSACTION_QTY)/1000,2),'K')
AS TOTAL_SALES FROM [Coffeeshop ] GROUP BY
DATENAME(MONTH,TRANSACTION_DATE) 

--------------------------FOR THE MONTH USER WANT TO------------------------------------
SELECT CONCAT(ROUND(SUM(UNIT_PRICE * TRANSACTION_QTY)/1000,2),'K') AS TOTAL_SALES FROM [Coffeeshop ]
WHERE MONTH(TRANSACTION_DATE)=5 -- MAY MONTH

--SELECTED MONTH / CM = MAY =5
--PREVIOUS MONTH / PM = APRIL = 4

WITH MonthlySales AS
(
    SELECT
        MONTH(transaction_date) AS [month],
        ROUND(SUM(unit_price * transaction_qty), 0) AS total_sales
    FROM [Coffeeshop ]
    WHERE MONTH(transaction_date) IN (4, 5)   -- April and May
    GROUP BY MONTH(transaction_date)
)
SELECT
    [month],
    total_sales,
    (
        (total_sales - LAG(total_sales, 1) OVER (ORDER BY [month]))
        * 100.0
        / LAG(total_sales, 1) OVER (ORDER BY [month])
    ) AS mom_increase_percentage
FROM MonthlySales
ORDER BY [month]

----------------------------------TOTAL ORDER ANALYSIS-----------------------------
SELECT COUNT(TRANSACTION_ID) AS TOTAL_ORDERS FROM [Coffeeshop ] WHERE MONTH(transaction_date)=5 -----  MAY
  

WITH MonthlyTransactions AS
(
    SELECT
        MONTH(transaction_date) AS [month],
        COUNT(transaction_id) AS total_transactions
    FROM [Coffeeshop ]
    GROUP BY MONTH(transaction_date)
)
SELECT
    [month],
    total_transactions,

    total_transactions -
    LAG(total_transactions) OVER (ORDER BY [month])
        AS mom_difference,

    ROUND(
        (
            (total_transactions -
             LAG(total_transactions) OVER (ORDER BY [month]))
            * 100.0
            / LAG(total_transactions) OVER (ORDER BY [month])
        ),
        2
    ) AS mom_growth_percentage

FROM MonthlyTransactions
WHERE [month] IN (4,5)
ORDER BY [month];

-----------------------------TOTAL QTY ANALYSIS-------------------------------
SELECT SUM(TRANSACTION_QTY) AS TOTAL_QTY
FROM [Coffeeshop ] WHERE MONTH(TRANSACTION_DATE)=5 -- MAY MONTH

WITH MonthlyQty AS
(
    SELECT
        MONTH(transaction_date) AS [month],
        SUM(transaction_qty) AS total_qty
    FROM [Coffeeshop ]
    GROUP BY MONTH(transaction_date)
)
SELECT
    [month],
    total_qty,

    total_qty -
    LAG(total_qty) OVER (ORDER BY [month])
        AS mom_difference,

    ROUND(
        (
            (total_qty -
             LAG(total_qty) OVER (ORDER BY [month]))
            * 100.0
            / LAG(total_qty) OVER (ORDER BY [month])
        ),
        2
    ) AS mom_growth_percentage

FROM MonthlyQty
WHERE [month] IN (4,5)
ORDER BY [month];

---------------------------------TOTAL'S FOR ANY DATE-------------------
SELECT
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS Total_sales,
    CONCAT(ROUND(SUM(transaction_qty)/1000,1), 'K') AS Total_Qty_Sold,
    CONCAT(ROUND(COUNT(transaction_id)/1000,1), 'K') AS Total_Orders
FROM [Coffeeshop ]
WHERE
    transaction_date = '2023-05-18'
-----------------------------------WEEKDAYS AND WEEKENDS-----------------------
SELECT CASE WHEN  
           DATEPART(WEEKDAY,transaction_date) IN (1,7) THEN 'WEEKENDS' ELSE 'WEEKDAYS' END AS 
           DAY_TYPE,
          CONCAT(ROUND(SUM(UNIT_PRICE*TRANSACTION_QTY)/1000,2),'K') AS TOTAL_SALES 
        FROM [Coffeeshop ] 
    WHERE MONTH(transaction_date)=2 -- MAY MONTH
GROUP BY CASE WHEN  
           DATEPART(WEEKDAY,transaction_date) IN (1,7) THEN 'WEEKENDS' ELSE 'WEEKDAYS' END 

----------------------------------STORE LOCATION---------------------------------
SELECT * FROM [Coffeeshop ]

SELECT STORE_LOCATION ,CONCAT(ROUND(SUM(UNIT_PRICE*TRANSACTION_QTY)/1000,2),'K') AS TOTAL_SALES 
FROM [Coffeeshop ] WHERE MONTH(TRANSACTION_DATE)=5 --- MAY MONTH
GROUP BY STORE_LOCATION ORDER BY SUM(UNIT_PRICE*TRANSACTION_QTY) DESC


----------------------------------AVG SALES---------------------------------------

SELECT CONCAT(ROUND(AVG(TOTAL_SALES)/1000,1),'K') AS AVG_SALES FROM 
(SELECT SUM(UNIT_PRICE*TRANSACTION_QTY) AS TOTAL_SALES FROM [Coffeeshop ] WHERE MONTH(TRANSACTION_DATE)=5 GROUP BY TRANSACTION_DATE)
AS INNER_QUERY


----------------------------------DAILY SALES-------------------------------------
SELECT DAY(TRANSACTION_DATE) AS DAY_OF_MONTH, SUM(UNIT_PRICE*TRANSACTION_QTY) AS TOTAL_SALES
FROM [Coffeeshop ] WHERE 
MONTH(TRANSACTION_DATE)=5 ----------- MAY 
GROUP BY  DAY(TRANSACTION_DATE)
ORDER BY  DAY(TRANSACTION_DATE)

--------------------------------SALES BY PRODUCT CATEGORY--------------------------
SELECT product_Category ,CONCAT(ROUND(SUM(UNIT_PRICE*TRANSACTION_QTY)/1000,2),'K') AS TOTAL_SALES from [Coffeeshop ] where month(transaction_date)=5 
group by product_category order by sum(UNIT_PRICE*TRANSACTION_QTY) DESC

--------------------------------SALES BY PRODUCT TYPE-------------------------

SELECT TOP 10 product_type,CONCAT(ROUND(SUM(UNIT_PRICE*TRANSACTION_QTY)/1000,2),'K') AS TOTAL_SALES from [Coffeeshop ] 
where month(transaction_date)=5
group by product_type order by sum(UNIT_PRICE*TRANSACTION_QTY) DESC

-------------------------------SALES ANALYSIS BY DAYS AND HOURS-------------------
SELECT
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS Total_qty_sold,
    COUNT(*) AS total_transactions
FROM [Coffeeshop ]
WHERE MONTH(transaction_date) = 5
  AND DATEPART(WEEKDAY, transaction_date) = 2   -- Monday
  AND DATEPART(HOUR, transaction_time) = 8 
  ------------------------------------hourls analysis-------------------------

  SELECT
    DATEPART(HOUR, transaction_time) AS sales_hour,
    SUM(unit_price * transaction_qty) AS total_sales
FROM [Coffeeshop ]
WHERE MONTH(transaction_date) = 5
GROUP BY DATEPART(HOUR, transaction_time)
ORDER BY DATEPART(HOUR, transaction_time);
----------------------------------WEEKLY ANALYSIS------------------
SELECT
    DATENAME(WEEKDAY, transaction_date) AS Day_of_Week,
    SUM(unit_price * transaction_qty) AS Total_Sales
FROM [Coffeeshop ]
WHERE MONTH(transaction_date) = 5
GROUP BY
    DATENAME(WEEKDAY, transaction_date),
    DATEPART(WEEKDAY, transaction_date)
ORDER BY DATEPART(WEEKDAY, transaction_date);
CREATE DATABASE PIZZA_SALES;
USE pizza_sales;
-----------------------------------------------------------------------------------------------------------------------------
-- KPI'
-----------------------------------------------------------------------------------------------------------------------------
-- 1) Total Revenue
SELECT sum(total_price) AS Total_Revenue FROM pizza_sales;

-- 2) Average Order value
SELECT (SUM(total_price)/count(distinct order_id)) AS Avg_Order_Value FROM pizza_sales;

-- 3) Total Pizza Sold
SELECT SUM(quantity) AS Total_Pizza_Sold from pizza_sales;

-- 4) Total Orders 
SELECT COUNT(DISTINCT order_id) AS Total_Orders FROM pizza_sales;

-- 5) Average pizzas per order
SELECT CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / 
CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS DECIMAL(10,2))
AS Avg_Pizzas_per_order
FROM pizza_sales;
---------------------------------------------------------------------------------------------------------------------------
ALTER TABLE pizza_sales
ADD COLUMN year INT,
ADD COLUMN quarter INT,
ADD COLUMN month INT,
ADD COLUMN day INT,
ADD COLUMN week INT;

UPDATE pizza_sales
SET 
    year = YEAR(order_date),
    quarter = QUARTER(order_date),
    month = MONTH(order_date),
    day = DAY(order_date),
    week = WEEK(order_date);
    
    SELECT 
    order_id,
    order_date,
    YEAR(order_date) AS year,
    QUARTER(order_date) AS quarter,
    MONTH(order_date) AS month,
    DAY(order_date) AS day,
    WEEK(order_date) AS week
FROM 
    pizza_sales;
SET SQL_SAFE_UPDATES = 0;

UPDATE pizza_sales
SET 
    year = YEAR(order_date),
    quarter = QUARTER(order_date),
    month = MONTH(order_date),
    day = DAY(order_date),
    week = WEEK(order_date);

SET SQL_SAFE_UPDATES = 1;


---------------------------------------------------------------------------------------------------------------------------
-- Daily Trend for Total Orders
---------------------------------------------------------------------------------------------------------------------------
SELECT DATENAME(DW, order_date) AS order_day, COUNT(DISTINCT order_id) AS total_orders 
FROM pizza_sales
GROUP BY DATENAME(DW, order_date);
SELECT DAYNAME(order_date) AS order_day, COUNT(DISTINCT order_id) AS total_orders 
FROM pizza_sales
GROUP BY DAYNAME(order_date);

SELECT 
    DAYNAME(order_date) AS weekday, 
    COUNT(DISTINCT order_id) AS total_orders
FROM 
    pizza_sales
GROUP BY 
    weekday
ORDER BY 
    FIELD(weekday, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');
    
    DESCRIBE pizza_sales;
UPDATE pizza_sales
SET order_date = STR_TO_DATE(order_date, '%Y-%m-%d')
WHERE STR_TO_DATE(order_date, '%Y-%m-%d') IS NOT NULL;
UPDATE pizza_sales
SET order_date = STR_TO_DATE(order_date, '%d-%m-%Y')
WHERE STR_TO_DATE(order_date, '%d-%m-%Y') IS NOT NULL;

UPDATE pizza_sales
SET 
    year = YEAR(order_date),
    quarter = QUARTER(order_date),
    month = MONTH(order_date),
    day = DAY(order_date),
    week = WEEK(order_date);

---------------------------------------------------------------------------------------------------------------------------
-- Monthly trend for Total Orders
---------------------------------------------------------------------------------------------------------------------------
select monthname(order_date) as Month_Name, COUNT(DISTINCT order_id) as Total_Orders
from pizza_sales
GROUP BY Month_Name;
------------------------------------------------------------------------------------------------------------------------------------------
-- % Sales by Pizza Category
SELECT pizza_category, CAST(SUM(total_price) AS DECIMAL(10,2)) as total_revenue,
CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS DECIMAL(10,2)) AS PCT
FROM pizza_sales
GROUP BY pizza_category;
------------------------------------------------------------------------------------------------------------------------------------------
--  % Sales by Pizza size
SELECT pizza_size, CAST(SUM(total_price) AS DECIMAL(10,2)) as total_revenue,
CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS DECIMAL(10,2)) AS PCT
FROM pizza_sales
GROUP BY pizza_size
ORDER BY pizza_size;
---------------------------------------------------------------------------------------------------------------------------------------
-- Total Pizza's sold by Pizza Category
SELECT pizza_category, SUM(quantity) as Total_Quantity_Sold
FROM pizza_sales
WHERE MONTH(order_date) = 2
GROUP BY pizza_category
ORDER BY Total_Quantity_Sold DESC;
-----------------------------------------------------------------------------------------------------------------------------------------
-- Top 5 Pizza's by Revenue
SELECT pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue DESC
LIMIT 5;
-------------------------------------------------------------------------------------------------------------------------------------------
-- Bottom 5 Pizza's by revenue
SELECT pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue Asc
LIMIT 5;
-------------------------------------------------------------------------------------------------------------------------------------------
-- Top 5 pizza's by quantity
SELECT pizza_name, SUM(quantity) AS Total_Pizza_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Pizza_Sold DESC
limit 5;
-----------------------------------------------------------------------------------------------------------------------------------------
-- Bottom 5 pizza's by quantity
SELECT pizza_name, SUM(quantity) AS Total_Pizza_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Pizza_Sold ASC
limit 5;
-------------------------------------------------------------------------------------------------------------------------------------------
-- Top 5 Pizza's by Total Order
SELECT pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders DESC
Limit 5;
-------------------------------------------------------------------------------------------------------------------------------------------
-- Bottom 5 Pizza's by Total Order
SELECT pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders ASC
Limit 5;





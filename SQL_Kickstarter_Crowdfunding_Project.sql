
create database projects;
USE projects;
select * from projects;
RENAME TABLE crowdfunding_category TO Category;
RENAME TABLE crowdfunding_location TO Location;
RENAME TABLE crowdfunding_category TO Category;
-------------------------------------------------------------------------------------------------------
-- Conversion of epcho to natural time
ALTER TABLE projects
ADD COLUMN created_date DATETIME;

SET SQL_SAFE_UPDATES = 0;

UPDATE projects
SET created_date = FROM_UNIXTIME(created_at);

SET SQL_SAFE_UPDATES = 1;  -- Re-enable safe mode after the update
---------------------------------------------------------------------------------------------------------
-- CALENDER_TABLE
SELECT 
    MIN(created_date) AS min_date,
    MAX(created_date) AS max_date
FROM projects;

create table calender_table as select created_date from projects;
select * from calender_table;
alter table calender_table
add column year int,
add column MonthNo int,
add column MonthFullName varchar(20),
add column Quarter varchar(2),
add column YearMonth varchar(20),
add column WeekdayNo int,
add column WeekdayName varchar(10),
add column FinancialMonth varchar(20),
add column FinancialQuarter varchar(20);

SET SQL_SAFE_UPDATES = 0;
UPDATE calender_table
set year = year(created_date),
	MonthNo = MONTH(created_date),
	MonthFullName = MONTHNAME(created_date),
    Quarter = concat('Q', QUARTER(created_date)),
    YearMonth = DATE_FORMAT(created_date,'%Y-%b'),
    WeekdayNo = dayofweek(created_date),
    WeekdayName = dayname(created_date),
    financialmonth = CASE
		WHEN MONTH(created_date) = 4 THEN 'FM1'
        WHEN MONTH(created_date) = 5 THEN 'FM2'
        WHEN MONTH(created_date) = 6 THEN 'FM3'
        WHEN MONTH(created_date) = 7 THEN 'FM4'
        WHEN MONTH(created_date) = 8 THEN 'FM5'
        WHEN MONTH(created_date) = 9 THEN 'FM6'
        WHEN MONTH(created_date) = 10 THEN 'FM7'
        WHEN MONTH(created_date) = 11 THEN 'FM8'
        WHEN MONTH(created_date) = 12 THEN 'FM9'
        WHEN MONTH(created_date) = 1 THEN 'FM10'
        WHEN MONTH(created_date) = 2 THEN 'FM11'
        WHEN MONTH(created_date) = 3 THEN 'FM12'
	END,
    financialQuarter = CASE
		WHEN MONTH(created_date) IN (4,5,6) THEN 'FQ-1'
        WHEN MONTH(created_date) IN (7,8,9) THEN 'FQ-2'
        WHEN MONTH(created_date) IN (10,11,12) THEN 'FQ-3'
        WHEN MONTH(created_date) IN (1,2,3) THEN 'FQ-4'
	END;
    select * from calender_table;

-------------------------------------------------------------------------------------------------------
-- Drop Column
ALTER TABLE projects
DROP COLUMN state_changed_at,
DROP COLUMN successful_at,
DROP COLUMN currency_symbol,
DROP COLUMN spotlight,
DROP COLUMN staff_pick,
DROP COLUMN blurb,
DROP COLUMN currency_trailing_code,
DROP COLUMN disable_communication;
-------------------------------------------------------------------------------------------------------
--- Projects Overview KPI :
-- 1) Total Number of Projects based on outcome :
SELECT state, COUNT(ProjectID) AS total_projects
FROM projects
GROUP BY state;
-------------------------------------------------------------------------------------------------------
-- 2) Total Number of Projects based on Locations:
SELECT country, COUNT(ProjectID) AS total_projects
FROM projects
GROUP BY country;

--------------------------------------------------------------------------------------------------------
-- 3)Total Number of Projects based on  Category:
SELECT category_id, COUNT(ProjectID) AS total_projects
FROM projects
GROUP BY category_id;

select c.name,count(ProjectID) as Total_Projects from projects p
join category c on c.id = p.category_id
group by c.name;
--------------------------------------------------------------------------------------------------------
-- 4) Total Number of Projects created by Year , Quarter , Month :

SELECT 
    YEAR(created_date) AS year,
    QUARTER(created_date) AS quarter,
    monthname(created_date) AS month,
    dayname(created_date) AS Day,
    COUNT(ProjectID) AS total_projects
FROM projects
GROUP BY year, quarter,month,Day;

------------------------------------------------------------------------------------------------------
---- Successful Projects:
--- 1) Successful Projects Amount Raised:
SELECT SUM(pledged) AS total_amount_raised
FROM projects
WHERE state = 'successful';

--- 2) Number of Backers for successful projects
SELECT SUM(backers_count) AS total_backers
FROM projects
where state = 'successful';

--- 3) Avg NUmber of Days for successful projects
SELECT AVG((deadline - created_at) / 86400) AS avg_days
FROM projects
WHERE state = 'successful';
---------------------------------------------------------------------------------------
--- Top Successful Projects :
---------------------------------------------------------------------------------------
--- 1) Based on Number of Backers :
SELECT ProjectID, name, backers_count
FROM projects
WHERE state = 'successful'
ORDER BY backers_count DESC
LIMIT 10;
----------------------------------------------------------------------------------------
--- 2) Based on Amount Raised.
SELECT ProjectID, name, pledged
FROM projects
WHERE state = 'successful'
ORDER BY pledged DESC
LIMIT 10;
----------------------------------------------------------------------------------------------------------
--- Percentage of Successful Projects overall:
----------------------------------------------------------------------------------------------------------
SELECT 
    (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS success_percentage
FROM projects;
----------------------------------------------------------------------------------------------------------
--- 1) Percentage of Successful Projects  by Category:
SELECT 
    category_id,
    (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS success_percentage
FROM projects
GROUP BY category_id;

select c.name, concat(SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS success_percentage
from projects p join category c
on p.category_id = c.id
group by c.name;
-----------------------------------------------------------------------------------------------------------
--- 2) Percentage of Successful Projects by Year , Month etc:
SELECT 
    YEAR(created_date) AS year,
    MONTH(created_date) AS month,
    monthname(created_date) AS Monthname,
    (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS success_percentage
FROM projects
GROUP BY year, month,Monthname;

-----------------------------------------------------------------------------------------------------------
--- 3) Percentage of Successful projects by Goal Range:
SELECT 
    CASE 
        WHEN goal < 1000 THEN 'Under 1000'
        WHEN goal BETWEEN 1000 AND 4999 THEN '1000-4999'
        WHEN goal BETWEEN 5000 AND 9999 THEN '5000-9999'
        ELSE '10000 and above'
    END AS goal_range,
    (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS success_percentage
FROM projects
GROUP BY goal_range;





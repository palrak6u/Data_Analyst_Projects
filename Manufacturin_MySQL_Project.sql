create database Manufacturing;
use manufacturing;

RENAME TABLE manufacturing_report TO Manufacturing;
ALTER TABLE Manufacturing
CHANGE `today Manufactured qty`  manufacture_qty int ;


-- Total Manufacturing Quantity
SELECT SUM(manufacture_qty) AS total_manufacture_qty
FROM manufacturing;
Select CONCAT(ROUND(SUM(manufacture_qty) / 1000, 2), 'K') AS total_manufacture_qty
FROM manufacturing;
select CONCAT(ROUND(SUM(manufacture_qty) / 1000000, 2), 'M') AS total_manufacture_qty
FROM manufacturing;

-- Total Rejected Quantity
SELECT SUM(`Rejected Qty`) AS total_rejected_qty
FROM manufacturing;
Select CONCAT(ROUND(SUM(`Rejected Qty`) / 1000, 2), 'K') AS total_manufacture_qty
FROM manufacturing;
select CONCAT(ROUND(SUM(`Rejected Qty`) / 1000000, 2), 'M') AS total_manufacture_qty
FROM manufacturing;

-- Total Proccessed Quantity
SELECT SUM(`Processed Qty`) AS total_processed_qty
FROM manufacturing;
Select CONCAT(ROUND(SUM(`Processed Qty`) / 1000, 2), 'K') AS total_manufacture_qty
FROM manufacturing;
select CONCAT(ROUND(SUM(`Processed Qty`) / 1000000, 2), 'M') AS total_manufacture_qty
FROM manufacturing;

-- Total Wastage Quantity
SELECT SUM(manufacture_qty - (`Processed Qty` + `Rejected Qty`)) AS total_wastage_qty
FROM manufacturing;
Select CONCAT(ROUND(SUM(manufacture_qty - (`Processed Qty` + `Rejected Qty`)) / 1000, 2), 'K') AS total_manufacture_qty
FROM manufacturing;
select CONCAT(ROUND(SUM(manufacture_qty - (`Processed Qty` + `Rejected Qty`)) / 1000000, 2), 'M') AS total_manufacture_qty
FROM manufacturing;

-- 5)EmployeeWise Rejected Quantity
SELECT `EMP Code`,`EMP Name`, SUM(`Rejected qty`) AS employee_wise_rejected_qty
FROM manufacturing
GROUP BY `EMP Code`,`EMP Name`
Order by employee_wise_rejected_qty DESC
Limit 10 ;

-- 6) MachineWwise Rejected Quantity
SELECT `Machine Code`, `Operation Name`, SUM(`rejected qty`) AS machine_wise_rejected_qty
FROM manufacturing
GROUP BY `Machine Code`, `Operation Name`
Order by machine_wise_rejected_qty Desc;

-- 7) Production Comarison Trend
SELECT DATE_FORMAT(`Doc Date`, '%Y-%m') AS month_year, 
       CONCAT(ROUND(SUM(manufacture_qty) / 1000, 2), 'K') AS total_manufacture, 
       CONCAT(ROUND(SUM(`Rejected Qty`) / 1000, 2), 'K') AS total_rejected
FROM manufacturing
GROUP BY month_year
ORDER BY month_year;

-- 8) Manufacture Vs Rejected Quantity
SELECT CONCAT(ROUND(SUM(manufacture_qty) / 1000, 2), 'K') AS total_manufacture_qty, CONCAT(ROUND(SUM(`Rejected Qty`) / 1000, 2), 'K') AS total_rejected_qty
FROM manufacturing;

-- 9) DepartmentWise Manufacture Vs Rejected Quantity
SELECT `Department Name`, CONCAT(ROUND(SUM(manufacture_qty) / 1000, 2), 'K') AS total_manufacture_qty, CONCAT(ROUND(SUM(`Rejected Qty`) / 1000, 2), 'K') AS total_rejected_qty
FROM manufacturing
GROUP BY `Department Name`
order by total_manufacture_qty, total_rejected_qty desc ;

-- 10) Operation Name wise Total Machine Cost
SELECT `Operation Name`, 
       `Machine Code`, 
       SUM(`Per Day Machine Cost`) AS total_machine_cost, 
       DATE_FORMAT(`Doc Date`, '%Y-%m') AS month_year
FROM manufacturing
GROUP BY `Operation Name`, `Machine Code`, month_year
ORDER BY total_machine_cost, month_year Desc;





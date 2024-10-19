create database hospitality;
Use hospitality;

-- 1) Total Revenue
SELECT SUM(revenue_realized) AS total_revenue
FROM fact_bookings;
SELECT SUM(revenue_realized) / 1000000 AS total_revenue_m
FROM fact_bookings;

-- 2) Occupancy
SELECT 
    SUM(successful_bookings) * 100.0 / SUM(capacity) AS occupancy_percentage
FROM fact_aggregated_bookings;

-- 3) Cancellation Rate
SELECT 
    SUM(booking_status = 'Cancelled') * 100.0 / count(booking_id) AS cancellation_percentage
FROM fact_bookings;

-- 4) Total Booking
SELECT SUM(successful_bookings) AS total_bookings_count
FROM fact_aggregated_bookings;

-- 5) Utilized Capacity
SELECT 
    SUM(successful_bookings) * 100.0 / SUM(capacity) AS utilized_capacity_percentage
FROM fact_aggregated_bookings;

-- 6) Trend Analysis 
SELECT
`week no`, format(sum(revenue_realized)/(select sum(revenue_realized)from fact_bookings)*100,'2')as `Revenue %`
from dim_date as d inner join fact_bookings as f
on str_to_date(d.date, '%d-%b-%y') = f.check_in_date
group by `week no`;

-- 7) Weekday  & Weekend  Revenue and Booking
select d.day_type, sum(f.revenue_realized) as `Toal_Revenue`
from dim_date as d inner join fact_bookings as f
on str_to_date(d.date, '%d-%b-%y') = f.check_in_date
group by d.day_type;

-- 8) Revenue by State & hotel
SELECT 
    city, 
    property_name, 
    concat(format(sum(f.revenue_realized)/1000000,'no'),' M') as `Total_Revenue`
from dim_hotels as d inner join fact_bookings as f
on d.property_id = f.property_id
group by city,property_name;

-- 9) Class Wise Revenue
select room_class as Class, format(sum(f.revenue_realized),'no') as `Total_Revenue`
from dim_rooms as r inner join fact_bookings as f
on r.room_id = f.room_category
group by Class;

-- 10) Checked out cancel No show
select booking_status,format(count(booking_status),'n')asTotal
from fact_bookings
group by booking_status;

-- 11) Weekly trend Key trend (Revenue, Total booking, Occupancy) 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
    WEEK(fb.booking_date, 1) AS booking_week,      -- Group by week (starting on Monday)
    YEAR(fb.booking_date) AS booking_year,         -- Also group by year to handle multiple years of data
    SUM(fb.revenue_realized) AS total_revenue,        -- Sum of revenue for the week
    COUNT(fb.booking_id) AS total_bookings,        -- Count total bookings for the week
    SUM(fba.successful_bookings) AS rooms_sold,              -- Sum of all rooms sold during the week
    SUM(fba.capacity) * COUNT(DISTINCT fb.booking_date) AS total_available_rooms_week,  -- Total available rooms per week
    (SUM(fba.successful_bookings) / SUM(fba.capacity) * 100) AS occupancy_rate -- Calculate occupancy rate
    
FROM
    fact_bookings fb
JOIN
    fact_aggregated_bookings fba ON fb.property_id = fba.property_id -- Join with dim_hotels to get total available rooms
GROUP BY
    booking_year, booking_week                      -- Group by both week and year
ORDER BY
    booking_year, booking_week;

SET GLOBAL net_read_timeout = 600;
SET GLOBAL net_write_timeout = 600;
SET GLOBAL wait_timeout = 600;

SET GLOBAL max_allowed_packet = 256M;
-- Query 1: Revenue and Booking Counts
SELECT
    WEEK(fb.booking_date, 1) AS booking_week,
    YEAR(fb.booking_date) AS booking_year,
    SUM(fb.revenue_realized) AS total_revenue,
    COUNT(fb.booking_id) AS total_bookings
FROM
    fact_bookings fb
GROUP BY
    booking_year, booking_week
ORDER BY
    booking_year, booking_week
LIMIT 100;

-- Query 2: Room Sales and Occupancy
SELECT
    WEEK(fb.booking_date, 1) AS booking_week,
    YEAR(fb.booking_date) AS booking_year,
    SUM(fba.successful_bookings) AS rooms_sold,
    SUM(fba.capacity) * COUNT(DISTINCT fb.booking_date) AS total_available_rooms_week,
    (SUM(fba.successful_bookings) / SUM(fba.capacity) * 100) AS occupancy_rate
FROM
    fact_bookings fb
JOIN
    fact_aggregated_bookings fba ON fb.property_id = fba.property_id
GROUP BY
    booking_year, booking_week
ORDER BY
    booking_year, booking_week
LIMIT 10;
-------------------------------------------------------------------------------------------------
 -- Total Capacity
 select sum(capacity) from fact_aggregated_bookings;
 
 -- Average Rating
 select avg(ratings_given) from fact_bookings;

-- No of days
SELECT
    DATEDIFF(STR_TO_DATE('01-May-22', '%d-%b-%y'), STR_TO_DATE('03-May-22', '%d-%b-%y')) AS days_between;
SELECT
    DATEDIFF('2023-12-31', '2023-01-01') AS days_between;  -- Replace with actual dates

-- Total Cancelled Booking
SELECT 
    COUNT(booking_id) AS total_canceled_bookings
FROM 
    fact_bookings
WHERE 
    booking_status = 'Cancelled';  -- Replace 'canceled' with the actual value indicating cancellation

-- Total Checked out
SELECT 
    COUNT(booking_id) AS total_Checked_Out
FROM 
    fact_bookings
WHERE 
    booking_status = 'Checked out';  -- Replace 'canceled' with the actual value indicating cancellation

--- Total No Show Booking
SELECT 
    COUNT(booking_id) AS total_No_Show_bookings
FROM 
    fact_bookings
WHERE 
    booking_status = 'No Show';  -- Replace 'canceled' with the actual value indicating cancellation

-- No Show rate %
SELECT 
    (SUM(CASE WHEN booking_status = 'No_Show' THEN 1 ELSE 0 END) / COUNT(booking_id)) * 100 AS no_show_rate
FROM 
    fact_bookings;
    
-- Booking % by Platform
SELECT 
    booking_platform,
    COUNT(booking_id) AS total_bookings,
    (COUNT(booking_id) / (SELECT COUNT(*) FROM fact_bookings)) * 100 AS booking_percentage
FROM 
    fact_bookings
GROUP BY 
    booking_platform
ORDER BY 
    booking_percentage DESC;
    
-- Booking % by room class
SELECT
    dr.room_class,
    COUNT(fb.booking_id) AS total_bookings,
    (COUNT(fb.booking_id) / (SELECT COUNT(*) FROM fact_bookings)) * 100 AS booking_percentage
FROM
    fact_bookings fb
JOIN
    dim_rooms dr ON fb.room_category = dr.room_id
GROUP BY
    dr.room_class
ORDER BY
    booking_percentage DESC;

-- Average Daily Rate(ADR)
SELECT 
    SUM(fb.revenue_realized) / SUM(fa.successful_bookings) AS ADR
FROM 
    fact_bookings fb
JOIN 
    fact_aggregated_bookings fa ON fb.property_id = fa.property_id;
    
--- Realization %
SELECT 
    (SUM(CASE WHEN booking_status = 'checked_out' THEN 1 ELSE 0 END) / COUNT(booking_id)) * 100 AS realisation_percentage
FROM 
    fact_bookings;
    
-- Revenue Generated Per available room
SELECT 
    SUM(fb.revenue_realized) / SUM(fa.capacity) AS revpar
FROM 
    fact_bookings fb
JOIN 
    fact_aggregated_bookings fa ON fb.property_id = fa.property_id;

--- Daily Booked Room Night
SELECT
    fb.booking_date,
    SUM(fa.successful_bookings) AS daily_booked_room_nights
FROM
    fact_bookings fb
JOIN
    fact_aggregated_bookings fa ON fb.property_id = fa.property_id
GROUP BY
    fb.booking_date
ORDER BY
    fb.booking_date;
    
-- Daily Sellable Rooms Night
SELECT
    fb.booking_date,
    SUM(fa.capacity) AS daily_sellable_room_nights
FROM
    fact_bookings fb
JOIN
    fact_aggregated_bookings fa ON fb.property_id = fa.property_id
GROUP BY
    fb.booking_date
ORDER BY
    fb.booking_date;

--- Daily Utilized Rooms Night
 SELECT
    fb.booking_date,
    SUM(fa.successful_bookings) AS daily_utilized_room_nights
FROM
    fact_bookings fb
JOIN
    fact_aggregated_bookings fa ON fb.property_id = fa.property_id
GROUP BY
    fb.booking_date
ORDER BY
    fb.booking_date;
    
-- Revenue Change percentage week over week
WITH weekly_revenue AS (
    SELECT
        YEAR(booking_date) AS booking_year,
        WEEK(booking_date, 1) AS booking_week,
        SUM(revenue_realized) AS total_weekly_revenue
    FROM
        fact_bookings
    GROUP BY
        YEAR(booking_date),
        WEEK(booking_date, 1)
)
SELECT
    current_week.booking_year,
    current_week.booking_week,
    current_week.total_weekly_revenue AS current_week_revenue,
    previous_week.total_weekly_revenue AS previous_week_revenue,
    ((current_week.total_weekly_revenue - previous_week.total_weekly_revenue) / previous_week.total_weekly_revenue) * 100 AS revenue_change_percentage
FROM
    weekly_revenue current_week
LEFT JOIN
    weekly_revenue previous_week 
    ON current_week.booking_year = previous_week.booking_year
    AND current_week.booking_week = previous_week.booking_week + 1
ORDER BY
    current_week.booking_year, current_week.booking_week;
    
-- Occupancy Change percentage week over week
WITH weekly_occupancy AS (
    SELECT
        YEAR(fb.booking_date) AS booking_year,
        WEEK(fb.booking_date, 1) AS booking_week,
        SUM(fa.successful_bookings) AS rooms_sold,
        SUM(fa.capacity) AS total_available_rooms,
        (SUM(fa.successful_bookings) / SUM(fa.capacity)) * 100 AS occupancy_rate
    FROM
        fact_bookings fb
    JOIN
        fact_aggregated_bookings fa ON fb.property_id = fa.property_id
    GROUP BY
        YEAR(fb.booking_date),
        WEEK(fb.booking_date, 1)
)
SELECT
    current_week.booking_year,
    current_week.booking_week,
    current_week.occupancy_rate AS current_week_occupancy,
    previous_week.occupancy_rate AS previous_week_occupancy,
    ((current_week.occupancy_rate - previous_week.occupancy_rate) / previous_week.occupancy_rate) * 100 AS occupancy_change_percentage
FROM
    weekly_occupancy current_week
LEFT JOIN
    weekly_occupancy previous_week 
    ON current_week.booking_year = previous_week.booking_year
    AND current_week.booking_week = previous_week.booking_week + 1
ORDER BY
    current_week.booking_year, current_week.booking_week;

-- Average Daily rate change percentage week over week
WITH weekly_adr AS (
    SELECT
        YEAR(fb.booking_date) AS booking_year,
        WEEK(fb.booking_date, 1) AS booking_week,
        SUM(fb.revenue_realized) AS total_weekly_revenue,
        SUM(fa.successful_bookings) AS rooms_sold,
        (SUM(fb.revenue_realized) / SUM(fa.successful_bookings)) AS adr
    FROM
        fact_bookings fb
    JOIN
        fact_aggregated_bookings fa ON fb.property_id = fa.property_id
    GROUP BY
        YEAR(fb.booking_date),
        WEEK(fb.booking_date, 1)
)
SELECT
    current_week.booking_year,
    current_week.booking_week,
    current_week.adr AS current_week_adr,
    previous_week.adr AS previous_week_adr,
    ((current_week.adr - previous_week.adr) / previous_week.adr) * 100 AS adr_change_percentage
FROM
    weekly_adr current_week
LEFT JOIN
    weekly_adr previous_week 
    ON current_week.booking_year = previous_week.booking_year
    AND current_week.booking_week = previous_week.booking_week + 1
ORDER BY
    current_week.booking_year, current_week.booking_week;

-- Revenue Per Available Room change percentage week over week
WITH weekly_revpar AS (
    SELECT
        YEAR(fb.booking_date) AS booking_year,
        WEEK(fb.booking_date, 1) AS booking_week,
        SUM(fb.revenue_realized) AS total_weekly_revenue,
        SUM(fa.capacity) AS total_available_rooms,
        (SUM(fb.revenue_realized) / SUM(fa.capacity)) AS revpar
    FROM
        fact_bookings fb
    JOIN
        fact_aggregated_bookings fa ON fb.property_id = fa.property_id
    GROUP BY
        YEAR(fb.booking_date),
        WEEK(fb.booking_date, 1)
)
SELECT
    current_week.booking_year,
    current_week.booking_week,
    current_week.revpar AS current_week_revpar,
    previous_week.revpar AS previous_week_revpar,
    ((current_week.revpar - previous_week.revpar) / previous_week.revpar) * 100 AS revpar_change_percentage
FROM
    weekly_revpar current_week
LEFT JOIN
    weekly_revpar previous_week 
    ON current_week.booking_year = previous_week.booking_year
    AND current_week.booking_week = previous_week.booking_week + 1
ORDER BY
    current_week.booking_year, current_week.booking_week
limit 17;

-- Realisation Change Percentage week over week
WITH weekly_realisation AS (
    SELECT
        YEAR(fb.booking_date) AS booking_year,
        WEEK(fb.booking_date, 1) AS booking_week,
        SUM(fb.revenue_realized) AS total_weekly_revenue,
        SUM(fa.capacity) AS total_available_rooms,
        SUM(CASE WHEN fb.booking_status != 'Cancelled' AND fb.booking_status != 'No Show' THEN 1 ELSE 0 END) / COUNT(fb.booking_id) AS Realisation
    FROM
        fact_bookings fb
    JOIN
        fact_aggregated_bookings fa ON fb.property_id = fa.property_id
    GROUP BY
        YEAR(fb.booking_date),
        WEEK(fb.booking_date, 1)
)
SELECT
    current_week.booking_year,
    current_week.booking_week,
    current_week.Realisation AS current_week_realisation,
    previous_week.Realisation AS previous_week_realisation,
    ((current_week.Realisation - previous_week.Realisation) / previous_week.Realisation) * 100 AS realisation_change_percentage
FROM
    weekly_realisation current_week
LEFT JOIN
    weekly_realisation previous_week 
    ON current_week.booking_year = previous_week.booking_year
    AND current_week.booking_week = previous_week.booking_week + 1
ORDER BY
    current_week.booking_year, current_week.booking_week
LIMIT 17;

------------------------------------------------------------------------------------------------------
-- Daily Sellable Rooms Night change Percentage week over week
WITH DailySellableRooms AS (
    SELECT 
        DATE(fb.booking_date) AS booking_date,
        YEAR(fb.booking_date) AS booking_year,
        WEEK(fb.booking_date, 1) AS booking_week,
        SUM(fa.capacity) AS total_sellable_rooms
    FROM 
        fact_bookings fb
    JOIN 
        fact_aggregated_bookings fa ON fb.property_id = fa.property_id
    GROUP BY 
        DATE(fb.booking_date),
        YEAR(fb.booking_date),
        WEEK(fb.booking_date, 1)
),
WeeklySellableRooms AS (
    SELECT
        booking_year,
        booking_week,
        SUM(total_sellable_rooms) AS total_weekly_sellable_rooms
    FROM 
        DailySellableRooms
    GROUP BY 
        booking_year,
        booking_week
)
SELECT 
    current_week.booking_year,
    current_week.booking_week,
    current_week.total_weekly_sellable_rooms AS current_week_sellable_rooms,
    previous_week.total_weekly_sellable_rooms AS previous_week_sellable_rooms,
    ((current_week.total_weekly_sellable_rooms - previous_week.total_weekly_sellable_rooms) / previous_week.total_weekly_sellable_rooms) * 100 AS sellable_rooms_change_percentage
FROM 
    WeeklySellableRooms current_week
LEFT JOIN 
    WeeklySellableRooms previous_week 
    ON current_week.booking_year = previous_week.booking_year
    AND current_week.booking_week = previous_week.booking_week + 1
WHERE 
    previous_week.total_weekly_sellable_rooms IS NOT NULL
ORDER BY 
    current_week.booking_year, current_week.booking_week;
    
SET GLOBAL net_read_timeout = 600;
SET GLOBAL net_write_timeout = 600;
SET GLOBAL wait_timeout = 600;
SET GLOBAL interactive_timeout = 600;

WITH DailySellableRooms AS (
    SELECT 
        DATE(fb.booking_date) AS booking_date,
        YEAR(fb.booking_date) AS booking_year,
        WEEK(fb.booking_date, 1) AS booking_week,
        SUM(fa.capacity) AS total_sellable_rooms
    FROM 
        fact_bookings fb
    JOIN 
        fact_aggregated_bookings fa ON fb.property_id = fa.property_id
    WHERE 
        fb.booking_date >= '2023-01-01' -- Only process data after a certain date
    GROUP BY 
        DATE(fb.booking_date),
        YEAR(fb.booking_date),
        WEEK(fb.booking_date, 1)
)

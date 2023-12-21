----------------------------------
-- CASE STUDY #5: Data Mart --
----------------------------------

-- Tool used: MySQL Workbench

-------------------------------------
-- CASE STUDY QUESTIONS AND ANSWERS--
-------------------------------------



-----------------------------------
-- 1. Data Cleansing Steps --
-----------------------------------

DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TEMPORARY TABLE clean_weekly_sales AS (
SELECT
	STR_TO_DATE(week_date, '%d/%m/%y') AS week_date,
	WEEK(STR_TO_DATE(week_date, '%d/%m/%y')) AS week_number,
	MONTH(STR_TO_DATE(week_date, '%d/%m/%y')) AS month_number,
	YEAR(STR_TO_DATE(week_date, '%d/%m/%y')) AS calendar_year,
	region, 
	platform, 
	segment,
	CASE 
		WHEN RIGHT(segment,1) = '1' THEN 'Young Adults'
		WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
		WHEN RIGHT(segment,1) in ('3','4') THEN 'Retirees'
		ELSE 'unknown' END AS age_band,
	CASE 
		WHEN LEFT(segment,1) = 'C' THEN 'Couples'
		WHEN LEFT(segment,1) = 'F' THEN 'Families'
		ELSE 'unknown' END AS demographic,
	transactions,
	ROUND((CAST(sales AS DECIMAL) / transactions), 2) AS avg_transaction,
	sales
FROM weekly_sales
);



-----------------------------------
-- 2. Data Exploration --
-----------------------------------

-- 1. What day of the week is used for each week_date value?

SELECT DISTINCT dayname(week_date) AS week_day
FROM clean_weekly_sales;


-- 2. What range of week numbers are missing from the dataset?

SELECT DISTINCT week(week_date) AS week_number
FROM clean_weekly_sales
ORDER BY week(week_date) ASC;


-- 3. How many total transactions were there for each year in the dataset?

SELECT calendar_year, 
	   SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;





















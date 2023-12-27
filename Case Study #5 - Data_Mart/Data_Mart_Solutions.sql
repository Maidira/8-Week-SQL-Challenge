----------------------------------
-- CASE STUDY #5: Data Mart --
----------------------------------

-- Tool used: MySQL Workbench

-------------------------------------
-- CASE STUDY QUESTIONS AND ANSWERS--
-------------------------------------



-----------------------------------
-- A. Data Cleansing Steps --
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
-- B. Data Exploration --
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


-- 4. What is the total sales for each region for each month?

SELECT month_number, region, 
	SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY month_number, region
ORDER BY month_number, region;


-- 5. What is the total count of transactions for each platform?

SELECT platform,
		SUM(transactions) AS total_transaction
FROM clean_weekly_sales
GROUP BY platform
ORDER BY total_transaction;


-- 6. What is the percentage of sales for Retail vs Shopify for each month?

WITH cte AS (
    SELECT calendar_year, month_number, platform,
        SUM(sales) AS monthly_sales
    FROM
        clean_weekly_sales
    GROUP BY
        calendar_year,
        month_number,
        platform
)

SELECT
    calendar_year,
    month_number,
    ROUND(
        100 * MAX(
            CASE WHEN platform = 'Retail' THEN monthly_sales ELSE 0 END
        ) / NULLIF(SUM(monthly_sales), 0), 2
    ) AS retail_percentage,
    ROUND(
        100 * MAX(
            CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE 0 END
        ) / NULLIF(SUM(monthly_sales), 0), 2
    ) AS shopify_percentage
FROM
    cte
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number;


-- 7. What is the percentage of sales by demographic for each year in the dataset?

WITH cte AS (
    SELECT calendar_year, demographic,
        SUM(sales) AS yearly_sales
    FROM
        clean_weekly_sales
    GROUP BY
        calendar_year,
        demographic
)

SELECT
    calendar_year,
    ROUND(
        100 * MAX(
            CASE WHEN demographic = 'Couples' THEN yearly_sales ELSE 0 END
        ) / NULLIF(SUM(yearly_sales), 0), 2
    ) AS couples_percentage,
    ROUND(
        100 * MAX(
            CASE WHEN demographic = 'Families' THEN yearly_sales ELSE 0 END
        ) / NULLIF(SUM(yearly_sales), 0), 2
    ) AS families_percentage,
    ROUND(
        100 * MAX(
            CASE WHEN demographic = 'unknown' THEN yearly_sales ELSE 0 END
        ) / NULLIF(SUM(yearly_sales), 0), 2
    ) AS unknown_percentage
FROM
    cte
GROUP BY calendar_year
ORDER BY calendar_year;


-- 8. Which age_band and demographic values contribute the most to Retail sales?

SELECT age_band, demographic,
  SUM(sales) AS retail_sales,
  ROUND(
    100 * CAST(SUM(sales) AS DECIMAL) / SUM(SUM(sales)) OVER (), 1
  ) AS sales_percentage
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY retail_sales DESC;


-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

SELECT calendar_year, platform, 
  ROUND(AVG(avg_transaction),0) AS avg_transaction_row, 
  ROUND(SUM(sales) / sum(transactions), 2) AS avg_sales_transaction
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;












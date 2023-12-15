----------------------------------
-- CASE STUDY #3: Foodie Fi --
----------------------------------

-- Tool used: MySQL Workbench

-------------------------------------
-- CASE STUDY QUESTIONS AND ANSWERS--
-------------------------------------


-- 1. How many customers has Foodie-Fi ever had?

SELECT 
	COUNT(DISTINCT customer_id) AS number_of_customers
FROM subscriptions;


-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value.

SELECT 
	MONTH(start_date) AS month_number,
    MONTHNAME(start_date) AS month_name,
    COUNT(s.customer_id) AS trial_plan_subscrpitions
FROM
	subscriptions s
JOIN 
	plans p 
ON 
	s.plan_id = p.plan_id
WHERE
	s.plan_id = 0
GROUP BY 
	MONTH(start_date)
ORDER BY 
	month_number;


-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.

SELECT
	p.plan_id,
    p.plan_name,
    COUNT(s.customer_id) AS number_of_events
FROM 
	subscriptions s
JOIN 
	plans p
ON 
	s.plan_id = p.plan_id
WHERE
	s.start_date >= "2021-01-01"
GROUP BY 
	p.plan_id, p.plan_name
ORDER BY
	p.plan_id;



-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT
  COUNT(DISTINCT s.customer_id) AS churned_customers,
  ROUND(100.0 * COUNT(s.customer_id)
    / (SELECT COUNT(DISTINCT s.customer_id) 
    	FROM subscriptions s)
  ,1) AS churn_percentage
FROM 
	subscriptions s
JOIN
	plans p
	ON s.plan_id = p.plan_id
WHERE
	p.plan_id = 4;


-- 6. What is the number and percentage of customer plans after their initial free trial ?

WITH cte AS (
  SELECT 
    s.customer_id,  
    p.plan_name, 
	  LEAD(p.plan_name) OVER ( 
      PARTITION BY s.customer_id
      ORDER BY s.start_date) AS next_plan
  FROM subscriptions s
  JOIN plans p
    ON s.plan_id = p.plan_id
)
  
SELECT 
  COUNT(customer_id) AS churned_customers,
  ROUND(100.0 * 
    COUNT(customer_id) 
    / (SELECT COUNT(DISTINCT customer_id) 
      FROM subscriptions)
  ) AS churn_percentage
FROM cte
WHERE plan_name = 'trial' 
  AND next_plan = 'churn';


-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31 ?

WITH cte AS (
  SELECT
    customer_id,
    plan_id,
  	start_date,
    LEAD(start_date) OVER (
      PARTITION BY customer_id
      ORDER BY start_date
    ) AS next_date
  FROM subscriptions
  WHERE start_date <= '2020-12-31'
)

SELECT
	plan_id, 
	COUNT(DISTINCT customer_id) AS customers,
  ROUND(100.0 * 
    COUNT(DISTINCT customer_id)
    / (SELECT COUNT(DISTINCT customer_id) 
      FROM subscriptions)
  ,1) AS percentage
FROM cte
WHERE next_date IS NULL
GROUP BY plan_id;


-- 8. How many customers have upgraded to an annual plan in 2020 ?

SELECT COUNT(DISTINCT customer_id) AS num_of_customers
FROM subscriptions
WHERE plan_id = 3
  AND start_date <= '2020-12-31';


-- 9. How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi ?

WITH trial_plan AS (
  SELECT 
    customer_id, 
    start_date AS trial_date
  FROM subscriptions
  WHERE plan_id = 0
), 
annual_plan AS (
  SELECT 
    customer_id, 
    start_date AS annual_date
  FROM subscriptions
  WHERE plan_id = 3
)

SELECT 
  ROUND(
    AVG(
      DATEDIFF(a.annual_date, t.trial_date)
    ), 0) AS avg_days_to_upgrade
FROM trial_plan t
JOIN annual_plan a
  ON t.customer_id = a.customer_id;


-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc) ?

WITH trial_plan AS (
  SELECT 
    customer_id, 
    start_date AS trial_date
  FROM subscriptions
  WHERE plan_id = 0
), 
annual_plan AS (
  SELECT 
    customer_id, 
    start_date AS annual_date
  FROM subscriptions
  WHERE plan_id = 3
),
bins AS (
  SELECT 
    t.customer_id,
    FLOOR(DATEDIFF(a.annual_date, t.trial_date) / 30) AS bucket_id
  FROM trial_plan t
  JOIN annual_plan a ON t.customer_id = a.customer_id
)
   
SELECT 
  CONCAT((bucket_id * 30), ' - ', (bucket_id + 1) * 30, ' days') AS bucket, 
  COUNT(DISTINCT customer_id) AS num_of_customers
FROM bins
GROUP BY bucket_id
ORDER BY bucket_id;


-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020 ?

WITH cte AS (
  SELECT 
    s.customer_id,  
    p.plan_id,
    p.plan_name, 
    LEAD(p.plan_id) OVER ( 
      PARTITION BY s.customer_id
      ORDER BY s.start_date) AS next_plan_id
  FROM subscriptions s
  JOIN plans p
    ON s.plan_id = p.plan_id
  WHERE YEAR(s.start_date) = 2020
)
   
SELECT 
  COUNT(customer_id) AS churned_customers
FROM cte
WHERE plan_id = 2
  AND next_plan_id = 1;







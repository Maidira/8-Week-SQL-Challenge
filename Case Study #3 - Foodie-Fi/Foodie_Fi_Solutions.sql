----------------------------------
-- CASE STUDY #1: Pizza Metrics --
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




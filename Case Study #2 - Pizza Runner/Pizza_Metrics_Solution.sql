----------------------------------
-- CASE STUDY #1: Pizza Metrics --
----------------------------------

-- Tool used: MySQL Server

-------------------------------------
-- CASE STUDY QUESTIONS AND ANSWERS--
-------------------------------------


-- 1. How many pizzas were ordered?

SELECT
  COUNT(pizza_id) AS number_of_pizza_ordered
FROM
  pizza_runner.customer_orders;


-- 2. How many unique customer orders were made?

SELECT
  customer_id,
  COUNT(DISTINCT order_id) AS unique_customer_orders
FROM
  pizza_runner.customer_orders;


-- 3. How many successful orders were delivered by each runner?

SELECT
  runner_id,
  COUNT(order_id) AS delivered_orders
FROM
  pizza_runner.runner_orders
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  1;


-- 4. How many of each type of pizza was delivered?

SELECT
  pizza_name,
  COUNT(pizza_name) AS number_of_pizzas_delivered
FROM
  pizza_runner.customer_orders AS c
  JOIN pizza_runner.pizza_names AS n ON c.pizza_id = n.pizza_id
  JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  1;


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
  customer_id,
  pizza_name,
  COUNT(pizza_name) AS number_of_pizzas_delivered
FROM
  pizza_runner.customer_orders AS c
  JOIN pizza_runner.pizza_names AS n ON c.pizza_id = n.pizza_id
GROUP BY
  customer_id,
  pizza_name
ORDER BY
  customer_id;



-- 6. What was the maximum number of pizzas delivered in a single order?

WITH pizza_count_cte AS
(
  SELECT 
    c.order_id, 
    COUNT(c.pizza_id) AS pizza_per_order
  FROM pizza_runner.customer_orders AS c
  JOIN pizza_runner.runner_orders  AS r
    ON c.order_id = r.order_id
  WHERE r.distance != 0
  GROUP BY c.order_id
)

SELECT 
  MAX(pizza_per_order) AS pizza_count
FROM pizza_count_cte;


-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
  c.customer_id,
  SUM(
    CASE WHEN c.exclusions <> ' ' OR c.extras <> ' ' THEN 1
    ELSE 0
    END) AS at_least_1_change,
  SUM(
    CASE WHEN c.exclusions = ' ' AND c.extras = ' ' THEN 1 
    ELSE 0
    END) AS no_change
FROM pizza_runner.customer_orders AS c
JOIN pizza_runner.runner_orders AS r
  ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id
ORDER BY c.customer_id;


-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT  
  SUM(
    CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
    ELSE 0
    END) AS pizza_count_w_exclusions_extras
FROM pizza_runner.customer_orders AS c
JOIN pizza_runner.runner_orders AS r
  ON c.order_id = r.order_id
WHERE r.distance >= 1 
  AND exclusions <> ' ' 
  AND extras <> ' ';


-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT 
  DATEPART(HOUR, [order_time]) AS hour_of_day, 
  COUNT(order_id) AS pizza_count
FROM pizza_runner.customer_orders
GROUP BY DATEPART(HOUR, [order_time]);


-- 10. What was the volume of orders for each day of the week?

SELECT 
  FORMAT(DATEADD(DAY, 2, order_time),'dddd') AS day_of_week, 
  COUNT(order_id) AS total_pizzas_ordered
FROM pizza_runner.customer_orders
GROUP BY FORMAT(DATEADD(DAY, 2, order_time),'dddd');

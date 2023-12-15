----------------------------------
-- CASE STUDY #2: Runner and Customer Experience --
----------------------------------

-- Tool used: MySQL Server

-------------------------------------
-- CASE STUDY QUESTIONS AND ANSWERS--
-------------------------------------


-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
  DATEPART(WEEK, registration_date) AS registration_week,
  COUNT(runner_id) AS runner_signup
FROM runners
GROUP BY DATEPART(WEEK, registration_date);


-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pick up the order?

WITH time_taken_cte AS
(
  SELECT 
    c.order_id, 
    c.order_time, 
    r.pickup_time, 
    DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS pickup_minutes
  FROM pizza_runner.customer_orders AS c
  JOIN pizza_runner.runner_orders AS r
    ON c.order_id = r.order_id
  WHERE r.distance != 0
  GROUP BY c.order_id, c.order_time, r.pickup_time
)

SELECT 
  AVG(pickup_minutes) AS avg_pickup_minutes
FROM time_taken_cte
WHERE pickup_minutes > 1;



-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH prep_time_cte AS
(
  SELECT 
    c.order_id, 
    COUNT(c.order_id) AS pizza_order, 
    c.order_time, 
    r.pickup_time, 
    DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS prep_time_minutes
  FROM pizza_runner.customer_orders AS c
  JOIN pizza_runner.runner_orders AS r
    ON c.order_id = r.order_id
  WHERE r.distance != 0
  GROUP BY c.order_id, c.order_time, r.pickup_time
)

SELECT 
  pizza_order, 
  AVG(prep_time_minutes) AS avg_prep_time_minutes
FROM prep_time_cte
WHERE prep_time_minutes > 1
GROUP BY pizza_order;


-- 4. What was the average distance travelled for each customer?

SELECT 
  c.customer_id, 
  AVG(r.distance) AS avg_distance
FROM pizza_runner.customer_orders AS c
JOIN pizza_runner.runner_orders AS r
  ON c.order_id = r.order_id
WHERE r.duration != 0
GROUP BY c.customer_id;


-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT
  MAX(TO_NUMBER(duration, '99')) - MIN(TO_NUMBER(duration, '99')) AS delivery_time_difference_in_minutes
FROM
  pizza_runner.runner_orders AS r
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null';


-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT
  order_id,
  runner_id,
  ROUND(
    AVG(
      TO_NUMBER(distance, '99D9') /(TO_NUMBER(duration, '99') / 60)
    )
  ) AS runner_average_speed
FROM
  pizza_runner.runner_orders AS r
WHERE
  pickup_time != 'null'
  AND distance != 'null'
  AND duration != 'null'
GROUP BY
  order_id,
  runner_id
ORDER BY
  order_id;


-- 7. What is the successful delivery percentage for each runner?

SELECT
  runner_id,
  ROUND(
    100 - (
      SUM(unsuccessful) / (SUM(unsuccessful) + SUM(successful))
    ) * 100
  ) AS successful_delivery_percent
FROM
  (
    SELECT
      runner_id,
      CASE
        WHEN pickup_time != 'null' THEN COUNT(*)
        ELSE 0
      END AS successful,
      CASE
        WHEN pickup_time = 'null' THEN COUNT(*)
        ELSE 0
      END AS unsuccessful
    FROM
      pizza_runner.runner_orders AS r
    GROUP BY
      runner_id,
      pickup_time
  ) AS count_rating
GROUP BY
  runner_id
ORDER BY
  runner_id;

























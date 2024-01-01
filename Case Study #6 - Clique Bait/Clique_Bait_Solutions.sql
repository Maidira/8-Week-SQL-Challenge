----------------------------------
-- CASE STUDY #5: Clique Bait --
----------------------------------

-- Tool used: MySQL Workbench

-------------------------------------
-- CASE STUDY QUESTIONS AND ANSWERS--
-------------------------------------


-------------------------------------
--       Digital Analysis         --
-------------------------------------

-- 1. How many users are there?

SELECT COUNT(DISTINCT user_id) AS total_users
FROM users;


-- 2. How many cookies does each user have on average?

SELECT
  ROUND(
    COUNT(cookie_id) / COUNT(distinct user_id),
    0
  ) AS avg_cookies_per_user
FROM users;


-- 3. What is the unique number of visits by all users per month?

SELECT 
  EXTRACT(MONTH FROM event_time) as month, 
  COUNT(DISTINCT visit_id) AS unique_visit_count
FROM events
GROUP BY month;


-- 4. What is the number of events for each event type?

SELECT event_type, 
	COUNT(*) AS event_count
FROM events
GROUP BY event_type
ORDER BY event_type;


-- 5. What is the percentage of visits which have a purchase event?

SELECT 
  100 * COUNT(DISTINCT e.visit_id)/
    (SELECT COUNT(DISTINCT visit_id) FROM events) AS percentage_purchase
FROM events e
JOIN event_identifier  ei
  ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase';


-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

WITH checkout_purchase AS (
SELECT 
  visit_id,
  MAX(CASE WHEN event_type = 1 AND page_id = 12 THEN 1 ELSE 0 END) AS checkout,
  MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase
FROM events
GROUP BY visit_id)

SELECT 
  ROUND(100 * (1-(SUM(purchase)/SUM(checkout))),2) AS pctge_checkout_with_no_purchase
FROM checkout_purchase;


-- 7. What are the top 3 pages by number of views?
























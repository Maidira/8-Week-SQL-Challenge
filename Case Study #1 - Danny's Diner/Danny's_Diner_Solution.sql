----------------------------------
-- CASE STUDY #1: DANNY'S DINER --
----------------------------------

-- Tool used: MySQL Server

-------------------------------------
-- CASE STUDY QUESTIONS AND ANSWERS--
-------------------------------------


-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
  s.customer_id, 
  SUM(m.price) AS total_sales
FROM sales s
INNER JOIN menu m
  ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id ASC;


-- 2. How many days has each customer visited the restaurant?

SELECT 
  customer_id, 
  COUNT(DISTINCT order_date) AS visit_count
FROM sales
GROUP BY customer_id;

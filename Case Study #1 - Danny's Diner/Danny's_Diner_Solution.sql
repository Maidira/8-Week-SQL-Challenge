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


-- 3. What was the first item from the menu purchased by each customer?
-- Since the timestamp is missing, all items bought on the first day are considered the first item

WITH ordered_sales AS (
  SELECT 
    s.customer_id, 
    s.order_date, 
    m.product_name,
    DENSE_RANK() OVER (
      PARTITION BY s.customer_id 
      ORDER BY s.order_date) AS rank
  FROM sales s
  INNER JOIN menu m
    ON s.product_id = m.product_id
)

SELECT 
  customer_id, 
  product_name
FROM ordered_sales
WHERE rank = 1
GROUP BY customer_id, product_name;








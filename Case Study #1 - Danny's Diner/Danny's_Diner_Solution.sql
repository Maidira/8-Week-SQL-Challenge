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


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT TOP 1
  m.product_name,
  COUNT(s.product_id) AS most_purchased_item
FROM sales s
INNER JOIN menu m
  ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY most_purchased_item DESC ;


-- 5. Which item was the most popular for each customer?

WITH most_popular AS (
  SELECT 
    s.customer_id, 
    m.product_name, 
    COUNT(m.product_id) AS order_count,
    DENSE_RANK() OVER (
      PARTITION BY s.customer_id 
      ORDER BY COUNT(s.customer_id) DESC) AS rank
  FROM menu m
  INNER JOIN sales s
    ON m.product_id = s.product_id
  GROUP BY s.customer_id, m.product_name
)

SELECT 
  customer_id, 
  product_name, 
  order_count
FROM most_popular 
WHERE rank = 1;


-- 6. Which item was purchased first by the customer after they became a member?

WITH as_member AS (
  SELECT
    m.customer_id, 
    s.product_id,
    ROW_NUMBER() OVER (
      PARTITION BY m.customer_id
      ORDER BY s.order_date) AS row_num
  FROM members m
  INNER JOIN sales s
    ON m.customer_id = s.customer_id
    AND s.order_date > m.join_date
)

SELECT 
  customer_id, 
  product_name 
FROM as_member am
INNER JOIN menu m
  ON am.product_id = m.product_id
WHERE row_num = 1
ORDER BY customer_id ASC;


-- 7. Which item was purchased just before the customer became a member?

WITH prior_member AS (
  SELECT 
    m.customer_id, 
    s.product_id,
    ROW_NUMBER() OVER (
      PARTITION BY m.customer_id
      ORDER BY s.order_date DESC) AS rank
  FROM members m
  INNER JOIN sales s
    ON m.customer_id = s.customer_id
    AND s.order_date < m.join_date
)

SELECT 
  pm.customer_id, 
  m.product_name 
FROM prior_member pm
INNER JOIN menu m
  ON pm.product_id = m.product_id
WHERE rank = 1
ORDER BY pm.customer_id ASC;


-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
  s.customer_id, 
  COUNT(s.product_id) AS total_items, 
  SUM(m.price) AS total_sales
FROM sales s
INNER JOIN members mem
  ON s.customer_id = mem.customer_id
  AND s.order_date < mem.join_date
INNER JOIN menu m
  ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH points_cte AS (
  SELECT 
    m.product_id, 
    CASE
      WHEN product_id = 1 THEN price * 20
      ELSE price * 10 END AS points
  FROM menu m
)

SELECT 
  s.customer_id, 
  SUM(points_cte.points) AS total_points
FROM sales s
INNER JOIN points_cte
  ON s.product_id = points_cte.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;


-- 10. In the first week after a customer joins the program (including their join date), they earn 2x points on all items, not just sushi 
-- - how many points do customer A and B have at the end of January?

WITH Dates AS (
  SELECT 
    customer_id, 
    join_date,
    DATEADD(d, 6, join_date) AS valid_date, 
    EOMONTH('2021-01-01') AS last_date
  FROM members
)

SELECT 
  d.customer_id,
  SUM(CASE 
      	WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN m.price*20
      	WHEN m.product_name = 'sushi' THEN m.price*20
      ELSE m.price*10 END) AS total_points
FROM sales s
JOIN Dates d 
  ON s.customer_id = d.customer_id
JOIN menu m 
  ON s.product_id = m.product_id
WHERE s.order_date <= last_date
GROUP BY d.customer_id;





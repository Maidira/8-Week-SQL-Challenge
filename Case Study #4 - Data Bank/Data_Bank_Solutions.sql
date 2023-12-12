----------------------------------
-- CASE STUDY #1: Pizza Metrics --
----------------------------------

-- Tool used: MySQL Workbench

-------------------------------------
-- CASE STUDY QUESTIONS AND ANSWERS--
-------------------------------------


------  A. Customer Nodes Exploration  ------   

-- 1. How many unique nodes are there on the Data Bank system ?

SELECT COUNT(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;


-- 2. What is the number of nodes per region?

SELECT 
	COUNT( DISTINCT c.node_id) AS num_of_node,
    r.region_name
FROM customer_nodes c
JOIN regions r
ON c.region_id = r.region_id
GROUP BY r.region_name;


-- 3. How many customers are allocated to each region?

SELECT
	COUNT(DISTINCT c.customer_id) AS num_of_customers,
    r.region_name
FROM customer_nodes c 
JOIN regions r
ON c.region_id = r.region_id
GROUP BY r.region_name
ORDER BY num_of_customers;


-- 4. How many days on average are customers reallocated to a different node?

WITH node_days AS (
  SELECT 
    customer_id, 
    node_id,
    end_date - start_date AS days_in_node
  FROM customer_nodes
  WHERE end_date != '9999-12-31'
  GROUP BY customer_id, node_id, start_date, end_date
) 
, allocated_node_days AS (
  SELECT 
    customer_id,
    node_id,
    SUM(days_in_node) AS total_days_in_node
  FROM node_days
  GROUP BY customer_id, node_id
)

SELECT ROUND(AVG(total_days_in_node)) AS avg_reallocation_days
FROM allocated_node_days;

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?




-- B. Customer Transactions

-- 1. What is the unique count and total amount for each transaction type?

SELECT
  txn_type, 
  COUNT(customer_id) AS transaction_count, 
  SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;


-- 2. What is the average total historical deposit counts and amounts for all customers?

WITH customerDeposit AS (
  SELECT 
    customer_id,
    txn_type,
    COUNT(*) AS dep_count,
    SUM(txn_amount) AS dep_amount
  FROM customer_transactions
  WHERE txn_type = 'deposit'
  GROUP BY customer_id, txn_type
)

SELECT
  AVG(dep_count) AS avg_dep_count,
  AVG(dep_amount) AS avg_dep_amount
FROM customerDeposit;


-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

WITH cte_transaction AS (
  SELECT 
    customer_id,
    MONTH(txn_date) AS months,
    SUM(CASE WHEN txn_type = 'deposit' THEN 0 ELSE 1 END) AS deposit_count,
    SUM(CASE WHEN txn_type = 'purchase' THEN 0 ELSE 1 END) AS purchase_count,
    SUM(CASE WHEN txn_type = 'withdrawal' THEN 0 ELSE 1 END) AS withdrawal_count
  FROM customer_transactions
  GROUP BY customer_id, MONTH(txn_date)
)

SELECT 
  months,
  COUNT(DISTINCT customer_id) AS customer_count
FROM cte_transaction
WHERE deposit_count > 1
  AND (purchase_count >= 1 OR withdrawal_count >= 1)
GROUP BY months;



-- 4. What is the closing balance for each customer at the end of the month? Also show the change in balance each month in the same table output?






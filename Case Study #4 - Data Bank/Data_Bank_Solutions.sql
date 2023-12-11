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
	COUNT(c.customer_id) AS num_of_customers,
    r.region_name
FROM customer_nodes c 
JOIN regions r
ON c.region_id = r.region_id
GROUP BY r.region_name
ORDER BY num_of_customers;


-- 4. How many days on average are customers reallocated to a different node?




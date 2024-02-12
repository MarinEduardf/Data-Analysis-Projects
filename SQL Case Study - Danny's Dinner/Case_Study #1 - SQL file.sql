CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),

  ('B', '2021-01-09');

-- Question no. 1:  What is the total amount each customer spent at the restaurant?
-- Query used:

SELECT customer_id AS customer
	   , SUM(price) AS total_spent
FROM sales s 
JOIN menu m
	ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY customer_id


-- Question no. 2: How many days has each customer visited the restaurant?
-- Query used:

SELECT customer_id AS customer
		, COUNT(DISTINCT(order_date)) AS total_visits
FROM sales
GROUP BY customer_id
ORDER BY customer_id


-- Question no. 3: What was the first item from the menu purchased by each customer?
-- Query used:

WITH rank_cte AS(
				SELECT s.customer_id
						, m.product_name
						, s.order_date
						, DENSE_RANK() OVER(PARTITION BY s.customer_id 
											ORDER BY s.order_date) AS purchase_rank
				FROM sales s 
				JOIN menu m
					ON s.product_id = m.product_id
				)

SELECT customer_id
		, product_name
FROM rank_cte
WHERE purchase_rank = 1


-- Question no. 4:  What is the most purchased item on the menu and how many times was it purchased by all customers?
-- Query used:

SELECT m.product_name
		, COUNT(s.product_id) AS number_of_purchases
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY number_of_purchases DESC
LIMIT 1


-- Question no. 5:  Which item was the most popular for each customer?
-- Query used:

WITH rank_cte AS (
				 SELECT s.customer_id AS customer_id
						, m.product_name AS product_name
						, COUNT(s.product_id) AS product_count
						, DENSE_RANK () OVER (PARTITION BY s.customer_id 
											  ORDER BY COUNT(s.product_id) DESC) AS product_rank
				 FROM sales s
				 JOIN menu m
					 ON s.product_id = m.product_id
				 GROUP BY s.customer_id
						, m.product_name
						, s.product_id
				 )


SELECT customer_id
		, product_name
		, product_count
FROM rank_cte
WHERE product_rank = 1


-- Question no. 6:  Which item was purchased first by the customer after they became a member?
-- Query used:

WITH rank_cte AS (
				  SELECT s.customer_id AS customer_id
						, m.product_name AS product_name
						, s.order_date AS order_date
						, mem.join_date AS join_date
						, DENSE_RANK () OVER (PARTITION BY s.customer_id 
											 ORDER BY s.order_date) AS rnk
				  FROM sales s
				  JOIN menu m 
					  ON s.product_id = m.product_id
				  JOIN members mem
					  ON s.customer_id = mem.customer_id
					  WHERE s.order_date >= mem.join_date
				 )


SELECT customer_id
		, product_name
		, order_date
		, join_date
FROM rank_cte
WHERE rnk = 1


-- Question no. 7:  Which item was purchased just before the customer became a member?
-- Query used:

WITH rank_cte AS (
				  SELECT s.customer_id AS customer_id
						, m.product_name AS product_name
						, s.order_date AS order_date
						, mem.join_date AS join_date
						, DENSE_RANK () OVER (PARTITION BY s.customer_id 
											 ORDER BY s.order_date DESC) AS rnk
				  FROM sales s
				  JOIN menu m 
					  ON s.product_id = m.product_id
				  JOIN members mem
					  ON s.customer_id = mem.customer_id
					  WHERE s.order_date < mem.join_date
				 )


SELECT customer_id
		, product_name
		, order_date
		, join_date
FROM rank_cte
WHERE rnk = 1


-- Question no. 8:  What is the total items and amount spent for each member before they became a member?
-- Query used:

SELECT s.customer_id
		, COUNT(s.product_id) AS items_purchased
		, SUM(m.price) AS total_spent
FROM sales s
JOIN menu m 
	ON s.product_id = m.product_id
JOIN members mem
	ON s.customer_id = mem.customer_id
	WHERE s.order_date < mem.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id


-- Question no. 9:  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- Query used:

SELECT s.customer_id
		, SUM(CASE
				  WHEN m.product_id = 1 THEN price * 20
				  ELSE price * 10
		  	  END) AS total_points		 	
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id


-- Question no. 10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-- Query used:

WITH date_cte AS (
				  SELECT *
						  , join_date + 6 AS date_interval
						  , TO_DATE('2021-01-31', 'YYYY-MM-DD') AS last_date
				  FROM members
				  )

SELECT s.customer_id
		, SUM(CASE
				  WHEN m.product_id = 1 THEN m.price * 20
			  	  WHEN s.order_date BETWEEN cte.join_date AND date_interval THEN m.price * 20
				  ELSE m.price * 10
		  	  END) AS total_points
FROM sales s
JOIN menu m 
	ON s.product_id = m.product_id
JOIN date_cte cte
	ON s.customer_id = cte.customer_id
	WHERE s.order_date < last_date
GROUP BY s.customer_id
ORDER BY s.customer_id
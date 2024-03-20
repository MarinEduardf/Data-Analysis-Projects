-- Check the number of entries in each table
SELECT COUNT(*) AS customer_count
FROM sales.customers;

SELECT COUNT(*) AS transaction_count
FROM sales.transactions;

SELECT COUNT(*) AS dates_count
FROM sales.date;

SELECT COUNT(*) AS market_count
FROM sales.markets;

SELECT COUNT(*) AS product_count
FROM sales.products;

-- 1. How many transactions have been made in Chennai?
SELECT COUNT(*) AS transaction_count
FROM sales.transactions t
JOIN sales.markets m
	ON t.market_code = m.markets_code
WHERE markets_name = 'Chennai';

-- 2. How many transactions were made in 2020?
SELECT COUNT(*) AS transaction_count
FROM sales.transactions t
JOIN sales.date d
	ON t.order_date = d.date
WHERE d.year = 2020;

-- 3. What was the total revenue in 2019?
SELECT SUM(t.sales_amount) AS revenue
FROM sales.transactions t
JOIN sales.date d
	ON t.order_date = d.date
WHERE d.year = 2019;

-- 4. What was the total revenue in Mumbai?
SELECT SUM(t.sales_amount) AS revenue
FROM sales.transactions t
JOIN sales.markets m
	ON t.market_code = m.markets_code
WHERE markets_name = 'Mumbai';
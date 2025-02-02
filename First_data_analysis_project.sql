-- CREATING THE DATABASE
CREATE DATABASE data_analysis_p1;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);

-- FIND NULL VALUES --
SELECT * FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR 
	age IS NULL
	OR 
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR 
	total_sale IS NULL

-- SUBSTITUTE NULL VALUES OF AGE USING COALESCE --

SELECT customer_id, gender, COALESCE (age, 18) 
FROM retail_sales

-- DELETE NULL VALUES -- 

DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR 
	total_sale IS NULL

-- DATA EXPLORATION -- 

-- How may sales do we have?
SELECT COUNT(*) AS total_sales FROM retail_sales;

-- How may unique customers do we have?
SELECT COUNT(DISTINCT (customer_id)) AS total_customer_count FROM retail_sales;
SELECT DISTINCT (customer_id) AS total_customers FROM retail_sales;

-- What are the unique categories we have?
SELECT DISTINCT category FROM retail_sales;


-- DATA ANALYSIS -- 
-- Data Analysis & Business Key Problems & Answers
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
	  AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	  AND quantity >= 4;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT category, SUM(total_sale) AS total_sale_per_category, COUNT(*) AS total_orders_per_category
FROM retail_sales
GROUP BY category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT category, ROUND(AVG(age), 2) AS average_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category;

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT category, gender, COUNT(transactions_id) AS total_transaction
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- USING TO_CHAR AND CORRELATED SUBQUERY
-- Calculates the average sale for each year and month
WITH monthly_sales AS ( 
  SELECT 
    TO_CHAR(sale_date, 'YYYY') AS year,
    TO_CHAR(sale_date, 'MM') AS month,
    AVG(total_sale) AS avg_sale
  FROM retail_sales
  GROUP BY TO_CHAR(sale_date, 'YYYY'), TO_CHAR(sale_date, 'MM')
),
-- Group the results by year and find the maximum average sale (MAX(avg_sale)) for each year.
max_sales AS (
  SELECT 
    year,
    MAX(avg_sale) AS max_avg_sale
  FROM monthly_sales
  GROUP BY year
)
-- Joins monthly_sales and max_sales; filtering the table to showing only the best sales in each year
SELECT m.year, m.month, m.avg_sale
FROM monthly_sales m
JOIN max_sales ms 
  ON m.year = ms.year AND m.avg_sale = ms.max_avg_sale
ORDER BY m.year;

-- USING EXTRACT
SELECT * FROM
(
	SELECT EXTRACT(YEAR FROM sale_date) as Year,
	       EXTRACT (MONTH FROM sale_date) as Month,
		   AVG(total_sale) as avg_sale,
		   RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC)
	FROM retail_sales
	GROUP BY Year, Month
) AS TABLE_1
WHERE rank = 1

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT category, COUNT(customer_id) AS customer_count
FROM retail_sales
GROUP BY category
ORDER BY category;

-- UNIQUE CUSTOMERS
SELECT category, COUNT(DISTINCT(customer_id)) AS unique_customers_count
FROM retail_sales
GROUP BY category
ORDER BY category;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
WITH hourly_sale
AS 
(
	SELECT *,
		CASE
			WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
	FROM retail_sales
)

SELECT hs.shift, COUNT(*) AS total_orders
FROM hourlY_sale hs
GROUP BY shift

-- END OF PROJECT


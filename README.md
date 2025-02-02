# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner  
**Database**: `data_analysis_p1`  
**Project Reference**: [Zero Analyst](https://www.youtube.com/watch?v=ChIQjGBI3AM&list=PLF2u7Zn-dIxbeais0AkBxUqdWM1hnSJDS&ab_channel=ZeroAnalyst)

This is my first data analysis project using SQL, based on Zero Analyst's tutorial (link above). It involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering business questions using SQL. Ideal for beginners looking to build a strong SQL foundation.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `data_analysis_p1`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
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
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**:
```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
	  AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	  AND quantity >= 4;
```

3. **Write a SQL query to calculate the total sales (total_sale) for each category.**:
```sql
SELECT category, SUM(total_sale) AS total_sale_per_category, COUNT(*) AS total_orders_per_category
FROM retail_sales
GROUP BY category;
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
SELECT category, ROUND(AVG(age), 2) AS average_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category;
```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT category, gender, COUNT(transactions_id) AS total_transaction
FROM retail_sales
GROUP BY category, gender
ORDER BY category;
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
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
```
```sql
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
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales**:
```sql
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT category, COUNT(DISTINCT(customer_id)) AS unique_customers_count
FROM retail_sales
GROUP BY category
ORDER BY category;
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
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
```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project introduced me to SQL for data analysis, covering database setup, data cleaning, EDA, and business-driven queries. Through this, I gained hands-on experience in analyzing sales patterns, customer behavior, and product performance to support business decisions.

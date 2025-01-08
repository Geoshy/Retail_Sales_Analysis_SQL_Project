-- Database Setup:

-- Create Retail "Sales Database":
CREATE DATABASE retail_sales;

-- Create Table "retail_sales_fact"':
DROP TABLE IF EXISTS retail_sales_fact;
CREATE TABLE retail_sales_fact (
	transactions_id INT NOT NULL PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(20) NOT NULL,	
	age INT,	
	category VARCHAR(25),	
	quantiy	INT,
	price_per_unit DECIMAL(10,2),
	cogs DECIMAL(10,2),
	total_sale DECIMAL(10,2)
);

-- Data Inspection:

-- Describe Structue Of A Table:
SELECT
	COLUMN_NAME,
	DATA_TYPE
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_NAME = 'retail_sales_fact';

-- Upload The Data Into the Database From the CSV File Using Import / Export Data To PostgreSQL:
SELECT * FROM retail_sales_fact;

-- Make Sure That The Database Number Of Rows Is Same CSV File:
SELECT COUNT(*) FROM retail_sales_fact; -- 2000

SELECT * FROM retail_sales_fact LIMIT 10;

-- Data Cleaning:
-- (1) Find Null Values In Each Column:
SELECT * 
FROM retail_sales_fact
WHERE transactions_id IS NULL;
-- 0 Rows Affected (No Null Values In "transactions_id")

SELECT * 
FROM retail_sales_fact
WHERE sale_date IS NULL;
-- 0 Rows Affected (No Null Values In "sale_date")

SELECT * 
FROM retail_sales_fact
WHERE sale_time IS NULL;
-- 0 Rows Affected (No Null Values In "sale_time")

SELECT * 
FROM retail_sales_fact
WHERE customer_id IS NULL;
-- 0 Rows Affected (No Null Values In "customer_id")

SELECT * 
FROM retail_sales_fact
WHERE gender IS NULL;
-- 0 Rows Affected (No Null Values In "gender")

SELECT * 
FROM retail_sales_fact
WHERE age IS NULL;
-- 10 Rows Affected (10 Null Rows In "gender")

SELECT * 
FROM retail_sales_fact
WHERE quantiy IS NULL;
-- 3 Rows Affected (10 Null Rows In "quantiy")

SELECT * 
FROM retail_sales_fact
WHERE price_per_unit IS NULL;
-- 3 Rows Affected (10 Null Rows In "price_per_unit")

SELECT * 
FROM retail_sales_fact
WHERE cogs IS NULL;
-- 3 Rows Affected (10 Null Rows In "cogs")

SELECT * 
FROM retail_sales_fact
WHERE total_sale IS NULL;
-- 3 Rows Affected (10 Null Rows In "total_sale")

-- OR
SELECT *
FROM
	retail_sales_fact
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
	quantiy IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

/*
Drop All Null Rows (age, quantiy, price_per_unit, cogs, total_sale) Of Columns, 
As This Columns Vales Can Not Replaced With Expected Values (Mean, Median, Mode)
*/

DELETE FROM retail_sales_fact
WHERE 
	quantiy IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;


-- (2) Treat With Null Values In Column "age":
SELECT * FROM retail_sales_fact WHERE age IS NULL; -- 10 Rows Affected ("10 Null Values In 'age' Column")

/*
- Choose The Suitable Value To Replace Null Values In Column "age" With It.
- We Will Compare Between The Values Of Mean, Median, Mode Of "age" Column And Find Suitable One To Replace Null Values With It.
*/

-- (1) Mean Of Column "age":

SELECT
	ROUND(AVG(age),0)
FROM
	retail_sales_fact
WHERE
	age IS NOT NULL; 
-- "41" Is The Average Age Value In The Whole Database.

-- (2) Median Of Column "age":
-- First, Check If Count(age) Is Odd Or Even Number:

SELECT
	COUNT(age),
	CASE
		WHEN (COUNT(age) % 2) = 0 THEN 'Even Number'
		WHEN (COUNT(age) % 2) != 0 THEN 'Odd Number'
	END AS count_type
FROM
	retail_sales_fact;
-- 1987	"Odd Number"

-- In This Case, When Count(age) Is Odd Number, Then Median Equal The Middle Value In An Ordered Dataset:

WITH ranked_cte AS (
	SELECT
		age,
		ROW_NUMBER() OVER(ORDER BY age ASC) AS age_rank,
		COUNT(age) OVER() age_count
	FROM
		retail_sales_fact
)
SELECT
	age AS median_age
FROM
	ranked_cte
WHERE
	age_rank = ((age_count + 1) / 2); -- AS Count(age) Is Odd Number
-- 
-- "42" Is The Median Age Value In The Whole Database.

-- (3) Mode Of Column "age":

WITH age_grouping AS (
	SELECT
		age,
		COUNT(age) age_count
	FROM
		retail_sales_fact
	GROUP BY
		age
	ORDER BY
		COUNT(age) DESC,
		age ASC
)
SELECT
	age
FROM
	age_grouping
WHERE
	age_count = (SELECT age_count FROM age_grouping LIMIT 1); -- 43 - 64
-- "43" & "64" Are The Mode Age Value In The Whole Database.

/*
- The Best Choice Is Replace NULL with the median (42), As:
 1. The median is robust to outliers and closely represents the central tendency of the data.
 2. It is a simple and effective method for most datasets.
*/

UPDATE retail_sales_fact
SET age = 42
WHERE age IS NULL;

SELECT * FROM retail_sales_fact WHERE age IS NULL; -- 0 Rows Affected

-- (2) Rename Column 'quantiy' To 'quantity':
ALTER TABLE retail_sales_fact
RENAME COLUMN quantiy to quantity;

-- Data Exploration:
SELECT COUNT(*) FROM retail_sales_fact; -- 1997

-- (1) How Many Invoices Data Have:
SELECT COUNT(*) FROM retail_sales_fact; -- 1997

-- (2) How Many Unique Customers Data Have:
SELECT COUNT(DISTINCT customer_id) FROM retail_sales_fact; -- 155

-- (3) How Many Unique Categories We Have:
SELECT COUNT(DISTINCT category) FROM retail_sales_fact; -- 3

-- (4) Highest Category Mentioned In The Invoices:
SELECT
	DISTINCT category,
	COUNT(category) OVER(PARTITION BY category) AS category_count
FROM
	retail_sales_fact
ORDER BY
	category_count DESC;
	
-- Clothing 701
-- Electronics 684
-- Beauty 612

-- OR
SELECT
	DISTINCT category,
	COUNT(category) AS category_count
FROM
	retail_sales_fact
GROUP BY
	category
ORDER BY 
	category_count DESC;

-- (5) Highest Gender Mentioned In The Invoices:
SELECT
	DISTINCT gender,
	COUNT(gender) AS gender_count
FROM
	retail_sales_fact
GROUP BY
	gender
ORDER BY 
	gender_count DESC;

-- Female 1017
-- Male 980

-- Data Analysis & Business Key Problems & Answers:

-- My Analysis & Findings:
-- (1) Write a SQL query to retrieve all columns for sales made on '2022-11-05':

SELECT * FROM retail_sales_fact WHERE sale_date = '2022-11-05'; -- 11 Rows Affected

/*
(2) Write a SQL query to retrieve all transactions where the category is 'Clothing' 
and the quantity sold is more than 4 in the month of Nov-2022
*/

SELECT 
	*
FROM
	retail_sales_fact
WHERE
	category = 'Clothing'
	AND
	quantity >= 4
	AND
	SUBSTRING((sale_date::VARCHAR(20)),1,7) = '2022-11'; -- 17 Rows Affected

-- OR:

SELECT 
	*
FROM
	retail_sales_fact
WHERE
	category = 'Clothing'
	AND
	quantity >= 4
	AND 
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'; -- 17 Rows Affected

-- OR
SELECT 
	*
FROM
	retail_sales_fact
WHERE
	category = 'Clothing'
	AND
	quantity >= 4
	AND
	EXTRACT(MONTH FROM sale_date) = 11
	AND
	EXTRACT(YEAR FROM sale_date) = 2022; -- 17 Rows Affected

-- (3) Write a SQL query to calculate the total sales (total_sale) for each category:
SELECT 
	category,
	ROUND(SUM(total_sale), 0) AS net_sale 
FROM
	retail_sales_fact
GROUP BY
	category
ORDER BY
	net_sale DESC;

-- (4) Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category:
SELECT
	ROUND(AVG(age), 2)
FROM 
	retail_sales_fact
WHERE
	category = 'Beauty'; -- 40.42

-- (5) Write a SQL query to find all transactions where the total_sale is greater than 1000:
SELECT * FROM retail_sales_fact WHERE total_sale > 1000; -- 306 Rows Affected
	
-- (6) Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category:
-- 1. Using Window Functions:

SELECT 
	DISTINCT category,
	gender,
	COUNT(transactions_id) OVER(PARTITION BY category, gender)
FROM
	retail_sales_fact
ORDER BY
	category ASC;

-- 2. Using Group By:

SELECT
	category,
	gender,
	COUNT(transactions_id)
FROM
	retail_sales_fact
GROUP BY
	category,
	gender
ORDER BY
	category ASC;

-- (7) Write a SQL query to show the distribution of time series with sales in the dataset:
SELECT
	EXTRACT(YEAR FROM sale_date) AS Year,
	EXTRACT(MONTH FROM sale_date) AS Month,
	ROUND(AVG(total_sale), 2) AS sales_average
FROM
	retail_sales_fact
GROUP BY
	Year,
	Month
ORDER BY
	Year ASC,
	Month ASC;
	
-- (8) Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:

WITH year_sales_avg AS (
	SELECT
		EXTRACT(YEAR FROM sale_date) AS Year,
		EXTRACT(MONTH FROM sale_date) AS Month,
		ROUND(AVG(total_sale), 2) AS sales_average,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY ROUND(AVG(total_sale), 2) DESC) AS rank_avg
	FROM
		retail_sales_fact
	GROUP BY
		Year,
		Month
)
SELECT *
FROM
	year_sales_avg
WHERE
	rank_avg = 1;

-- (9) Write a SQL query to find the top 5 customers based on the highest total sales:

SELECT
	customer_id,
	SUM(total_sale) AS total_sales
FROM
	retail_sales_fact
GROUP BY
	customer_id
ORDER BY
	total_sales DESC
LIMIT
	5;

-- (10) Write a SQL query to find the number of unique customers who purchased items from each category:

SELECT
	category,
	COUNT(DISTINCT customer_id) AS uni_customer_count
FROM
	retail_sales_fact
GROUP BY
	category
ORDER BY
	uni_customer_count DESC;

-- (11) Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17):

WITH shift_time AS (
	SELECT
		*,
		CASE
			WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift_type,
		EXTRACT(HOUR FROM sale_time)
	FROM
		retail_sales_fact
)
SELECT
	shift_type,
	COUNT(transactions_id) AS order_count
FROM
	shift_time
GROUP BY
	shift_type
ORDER BY
	order_count DESC;







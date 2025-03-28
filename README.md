# Retail-database-SQL-EDA
Sale analysis project showcasing advanced SQL skills

# 1: Retail Sales Analysis
## Overview
This project analyzes data from a retailer. I have analysed sales in regards to; change over time - cumulative - products performance - part to whole to identify winning products - segmenting customers for their buying behaviors.
I have used SQL, to analyze data to extract meaningful insights and monitor KPIs.

## Dataset Information
The dataset has been modeled to a sale(fact), customers and products tables. 

fact table:
  - order_number
  - product_key
  - customer_key
  - order_date
  - shipping date
  - due_date
  - sale_amount
  - quantity
  - price

    
customers table:
  - customer_key
  - customer_id
  - customer_number
  - first_name
  - last_name
  - country
  - marital_status
  - gender
  - birthday
  - create date

products table:
  - product_key
  - product_id
  - product_number
  - product_name
  - category_id
  - category
  - subcategory
  - maintenance
  - cost
  - product_line
  - start_date

## Data Analysis steps
Various SQL functionalities were utilized to extract valuable insights through the analysis stages. 

### 1. **Change Over time**
In calculating change over time, I hve used `DATETRUNK` function to extract month from date column. Then by utilizing `SUM` and `COUNT` I did some aggregation to  calculate `Total_sales`, `Total_customer` and `Total quantity` over each months of sale. 
Usage of `WHERE`, `GROUP BY` and `ORDER BY` statements has been shown.
```sql
select
	DATETRUNC(month, order_date) AS 'Order_date',
	sum(sales_amount) AS Total_sales,
	COUNT(distinct customer_key) AS Total_customer,
	SUM(quantity) as Total_quantity
from [gold.fact_sales]
where order_date is not null
group by DATETRUNC(month, order_date)
order by DATETRUNC(month, order_date);
```

### 2. **Cummulative Analysis**
Calculate total sales per month, running total (rolling total) and moving average over time. Used `SubQuery` fanctionality of SQL to achieve the results.
```sql
SELECT 
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS rolling_total,
	AVG(avg_price) OVER(ORDER BY order_date) AS moving_avg_price
FROM
(
SELECT 
	DATETRUNC(month, order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
FROM [gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
) t
```

- **Performance Analysis**:
I have calculated yearly performance of each product. By utilizing `CTE`s and `CASE` statements and `LAG` function.
```sql
WITH yearly_product_sales AS 
(
SELECT
	prod.product_name,
	SUM(fact.sales_amount) AS total_sales,
	YEAR(fact.order_date) AS order_year
FROM [gold.fact_sales] AS fact
JOIN [gold.dim_products] AS prod
	on fact.product_key = prod.product_key
WHERE fact.order_date IS NOT NULL
GROUP BY YEAR(fact.order_date), prod.product_name
)
SELECT 
	order_year,
	product_name,
	total_sales,
	AVG(total_sales) OVER(PARTITION BY product_name) AS average_sales,
	total_sales - AVG(total_sales) OVER(PARTITION BY product_name) AS diff_average,
	CASE 
		WHEN total_sales - AVG(total_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Average'
		WHEN total_sales - AVG(total_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Average'
		ELSE 'Average'
	END Average_Change,
	LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS p_y_sales,
	total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_p_y,
	CASE 
		WHEN total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		WHEN total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END y_over_y
FROM yearly_product_sales
```

- **Top 5 Months with the Highest Layoffs**:
I have calculated yearly performance of each product in this analysis.

- **Biggest Layoff Events**:
   - Used `ORDER BY total_layoffs DESC` to identify the largest single layoff events.

### 3. **SQL Techniques and Functionalities Used**
During the data cleaning and analysis process, multiple SQL functionalities were applied, including:
- `WHERE` clause to filter specific conditions (e.g., WHERE industry='Tech').
- `LIKE` statement for pattern matching (e.g., filtering company names containing 'Inc').
- `GROUP BY` and `ORDER BY` for summarizing and sorting data.
- `JOIN` and `UNION` to combine related datasets and enrich insights.
- **String Functions**:
   - `TRIM(column)`, `LOWER(column)`, `UPPER(column)` for text cleanup.
- **CASE Statements**:
   - Created new categorical insights (e.g., CASE WHEN total_layoffs > 1000 THEN 'High Impact' ELSE 'Low Impact' END).
- **Subqueries**:
   - Extracted specific insights using nested queries.
- **Window Functions**:
   - Used `RANK() OVER(PARTITION BY country ORDER BY total_layoffs DESC)` for ranking within groups.
- **Common Table Expressions (CTEs)**:
   - Simplified complex queries using `WITH cte_name AS (SELECT ...)`.
- **Temporary Tables**:
   - Created intermediate datasets using `CREATE TEMP TABLE`.

## Key Insights and Findings
After analyzing the dataset, several important trends were uncovered:

- **Layoffs peaked in 2020 and 2022**, aligning with major economic downturns and market corrections.
- **The tech industry was the most affected**, with large layoffs in major companies.
- **Countries like the USA, India, and the UK saw the highest number of layoffs**, primarily due to global market shifts and restructuring.
- **Certain months (e.g., January 2023) had exceptionally high layoffs**, possibly due to financial planning and restructuring.
- **The largest single layoff events were observed in major multinational companies**, particularly in the technology sector.

## Conclusion
This project demonstrates how SQL can be used for data cleaning, transformation, and analysis to derive valuable business insights. By leveraging SQL techniques, we have uncovered critical patterns in workforce layoffs over a three-year period.

The insights gained from this analysis can be used by businesses, policymakers, and researchers to understand employment trends and prepare for future workforce challenges.

## Files
[Download Layoffs Dataset](https://github.com/movahed-abdolahi/SQL-projects/Files/layoffs.csv)

[SQL Cleaning Script](https://github.com/movahed-abdolahi/SQL-projects/Files/SQL-Project-Data%20cleaning.sql)

[SQL Analysis Script](https://github.com/movahed-abdolahi/SQL-projects/Files/SQL-Project-Data%20analyzing.sql)


## License
This project is licensed under the MIT License - see the LICENSE file for details.

---
### Author
**Movahed Abdolahi**

For any questions or collaborations, feel free to reach out!


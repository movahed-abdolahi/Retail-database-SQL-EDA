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

### 3. **Performance Analysis**
I have calculated yearly performance of each product. By utilizing `CTE`'s and `CASE` statements and `LAG` function, I have categorized each producs performance in 3 categories of `Above Average`, `Below Average` and `Average` and Year-Over-Year performance of products in 3 categories of `Increase`, `Decrease` and `No Change`.
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

### 4. **Part to whole**
This was another interesting part of the analysis in which I calculated sale contribution of each product category compared to total sale. This Types of analysis usualy is good to identify dominant categories as well as underperforming categories.
```sql
WITH total_sales_category AS
(
SELECT
	category,
	SUM(sales_amount) AS total_sales_cat
FROM [gold.fact_sales] AS f
JOIN [gold.dim_products] AS p
	ON f.product_key = p.product_key
GROUP BY category
)
SELECT 
	category,
	total_sales_cat,
	SUM(total_sales_cat) OVER () AS overall_sales,
	CONCAT(ROUND((CAST (total_sales_cat AS FLOAT) / SUM(total_sales_cat) OVER ()) * 100, 2), '%') AS contribution_percentage
FROM total_sales_category
ORDER BY total_sales_cat DESC
```

### 5. **Segmentation**
In segmentation I have tried to categorize customers into 3 segment:
	- VIP: At least 12 months of history and spending more than 5000 
 	- Regular: At least 12 months of history and spending less than 5000 
  	- New: less than 12 month of history

```sql
WITH customer_spending AS
(
SELECT
	c.customer_key,
	SUM(f.sales_amount) total_spending,
	MIN(order_date) first_order,
	MAX(order_date) last_order,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) order_history
FROM [gold.fact_sales] f
JOIN [gold.dim_customers] c
	ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT
	customer_category,
	COUNT(customer_key) AS total_customers
FROM
(
SELECT 
	customer_key,
	CASE	
		WHEN order_history >= 12 AND total_spending > 5000 THEN 'VIP'
		WHEN order_history >= 12 AND total_spending <= 5000 THEN 'Regular'
		ELSE 'New'
	END customer_category
FROM customer_spending
) t
GROUP BY customer_category
ORDER BY total_customers DESC
```

And also products in 4 segment based on their COGS.
```sql
 WITH product_category AS
 (
 SELECT 
	product_key,
	product_name,
	cost,
	CASE
		WHEN cost < 100 THEN '0  to 100'
		WHEN cost BETWEEN 100 AND 500 THEN '100  to 500'
		WHEN cost BETWEEN 500 AND 1000 THEN '500  to 1000'
		ELSE 'Above 1000'
	END cost_category
 FROM [gold.dim_products] 
 )
SELECT 
	cost_category,
	COUNT(product_name) AS total_product
FROM product_category
GROUP BY cost_category
```

## Key Insights and Findings
After analyzing the dataset, several important trends were uncovered:

A

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


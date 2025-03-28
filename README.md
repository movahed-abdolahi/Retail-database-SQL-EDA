# Retail-database-SQL-EDA
Sale analysis project showcasing advanced SQL skills

#  Retail Sales Analysis
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

### 6. **Final query**
In final stage of the analysis, I have created 2 complex queries which one creating a complete repost for `Customer Analysis` and second one for `Products Analysis`. In this step I have utilzed `CREATE VIEW` statement to create a report table. Multiple agrregations, text anlyzing and `CTE`'s has been used.

`Customer Analysis`:
```sql
CREATE VIEW final_report_customers AS
WITH new_table AS
--First CTE to extract what we need
(
SELECT 
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM [gold.fact_sales] as f
JOIN [gold.dim_customers] as c
	ON f.customer_key = c.customer_key
WHERE order_date IS NOT NULL AND c.birthdate IS NOT NULL
)
, new_table2 AS
-- Second query to categorize customers
(
SELECT 
	customer_key,
	customer_name,
	customer_number,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	COUNT(quantity) AS total_quantity,
	COUNT(product_key) AS total_products,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan_months,
	MAX(order_date) AS last_order_date,
	age
FROM new_table
GROUP BY 	
	customer_key,
	customer_name,
	customer_number,
	age
)
SELECT 
	customer_key,
	customer_name,
	customer_number,
	age,
	CASE	
		WHEN age <= 30 THEN 'Under 30'
		WHEN age BETWEEN 30 AND 40 THEN '30 to 40'
		WHEN age BETWEEN 40 AND 50 THEN '40 to 50'
		ELSE 'Over 50'
	END age_group,
	CASE	
		WHEN lifespan_months >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan_months >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END customer_category,
	DATEDIFF(MONTH, last_order_date, GETDATE()) AS 'recency', 
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE (total_sales/total_orders)
	END 'avg_order',
	CASE
		WHEN lifespan_months = 0 THEN total_sales
		ELSE (total_sales/lifespan_months)
	END 'avg_monthly_spend'

FROM new_table2
```

`Products Analysis`:
```sql
CREATE VIEW final_report_products AS
WITH new_table AS
(
Select
	f.order_number,
	f.order_date,
	f.customer_key,
	f.sales_amount,
	f.quantity,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
FROM [gold.fact_sales] as f
JOIN [gold.dim_products] as p
	ON f.product_key = p.product_key
WHERE order_date IS NOT NULL 
), new_table2 AS
(
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS
	last_sale_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_sold,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM new_table
GROUP BY 
	product_key,
	product_name,
	category,
	subcategory,
	cost
)
SELECT 
	product_key,
	product_name,
	category,	
	subcategory,	
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE	
		WHEN total_sales > 50000 THEN 'High Performer'
		WHEN total_sales >= 20000 THEN 'Mid Performer'
		ELSE 'Low performer'
	END AS product_category,
	lifespan,
	total_orders,
	total_sales,
	total_sold,
	total_customers,
	avg_selling_price,
	-- Average order revenue
	CASE	
		WHEN total_orders = 0 THEN 0
		ELSE total_sales/total_orders
	END AS avg_revenue_order,
	-- Average monthly revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales/lifespan
	END AS avg_monthly_revenue
FROM new_table2
```

## Conclusion
SQL techniques such as CTEs, JOINs, CASE statements, window functions (OVER(), LAG()), and subqueries were extensively applied throughout the analysis to manipulate and aggregate the data effectively. The insights derived from these methods provide significant value in optimizing product offerings, refining marketing strategies, and enhancing customer engagement. This project demonstrates the power of SQL and data-driven decision-making in the retail industry, enabling more informed and strategic business actions.

## License
This project is licensed under MIT License - see the LICENSE file for details.

---
For any questions or collaborations, feel free to reach out!


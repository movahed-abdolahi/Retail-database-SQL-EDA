-- Building main report fr Stakeholders



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
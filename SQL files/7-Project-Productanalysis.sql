-- Create a report around key product metrics and behaviours
-- Gather essential columns such as, Product name, category, subcategory and cost
-- Segment by revenue to high-performer, mid-performer and low-performer
-- Aggregate product-level metrics: total orders - total sales - total unit sold - total unique customers - lifespan
-- Calculate important KPIs


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
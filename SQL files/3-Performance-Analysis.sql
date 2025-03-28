-- Yearly performance of the products




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
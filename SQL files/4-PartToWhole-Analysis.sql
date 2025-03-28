-- Which categories contribute the most to the overall sales?



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

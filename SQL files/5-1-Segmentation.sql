 -- Categorize product cost into 4 segment and count number of rows in each segment



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

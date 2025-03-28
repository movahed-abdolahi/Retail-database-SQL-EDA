-- Group customers in 3 segments based on their spending behavior:
--VIP: At least 12 months of history and spending more than 5000
--Regular: At least 12 months of history and spending less than 5000
--New: less than 12 month of history



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
-- SALES BY YEAR-MONTH

select
	DATETRUNC(month, order_date) AS 'Order_date',
	sum(sales_amount) AS Total_sales,
	COUNT(distinct customer_key) AS Total_customer,
	SUM(quantity) as Total_quantity
from [gold.fact_sales]
where order_date is not null
group by DATETRUNC(month, order_date)
order by DATETRUNC(month, order_date);





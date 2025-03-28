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



### 2. **Top Layoff Events and Patterns**
- **Top 5 Countries with the Highest Layoffs**:
   - Used `LIMIT 5` after `ORDER BY SUM(total_layoffs) DESC`.

- **Top 5 Industries with the Highest Layoffs**:
   - Similar to country analysis but grouped by `industry`.

- **Top 5 Months with the Highest Layoffs**:
   - Applied `ORDER BY` on aggregated monthly layoffs.

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


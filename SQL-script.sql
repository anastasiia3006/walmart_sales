SELECT * FROM walmart;
SELECT COUNT(*) FROM walmart;


SELECT COUNT(distinct branch) FROM walmart;

select max(quantity) FROM walmart;

-- Business Problems

-- 1 - Find different payment method and number of transactions, number of qty sold
SELECT payment_method,
 COUNT(*) as no_payments,
 SUM(quantity) as no_qty_sold
 FROM walmart GROUP BY payment_method;
 
 
 -- 2 - Indetify the highest-rated category in each branch, displaying the branch, category
 -- AVG RATING
 
 SELECT * 
 FROM 
 (	SELECT 
		branch,
		category, 
        AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as ranks
	FROM walmart 
	GROUP BY 1,2 
) subquery
 WHERE ranks = 1 ;
 
 
 -- 3 - Identify the busiest day for each branch based on the number of transactions
 
 SELECT * 
 FROM
	(SELECT 
		branch,
		TO_CHAR(TO_DATE(date, '%d/%m/%Y'), 'Day') as day_name,
		COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as ranks
	FROM walmart
	GROUP BY 1, 2
	)
WHERE ranks = 1;

-- 4 - Calculate the total quantity of items sold perpayment method. List payment_method and total_quantity

SELECT 
	payment_method,
    SUM(quantity) as no_qty_sold
FROM walmart GROUP BY payment_method;
 
 
 -- 5 - Determine the average, minimum and maximum rating of category for each city. 
 -- List the citym average_rating, min_rating and max_rating
 
 SELECT 
	city,
	category,
	MIN(rating) as min_rating,
    MAX(rating) as max_rating,
    AVG(rating) as avg_rating
FROM walmart
GROUP BY 1,2;


-- 6 - Calculate the total profit for each category by considering total_profit as 
-- (unit_price * quantity * profit_margin). List category and total_proifit, ordered from highest to lowerst profit

SELECT 
	category, 
    SUM(total) as total_revenue,
	SUM( total * profit_margin) as profit
FROM walmart 
GROUP BY 1;


-- 7 Determine the most common payment method for each Branch.
-- Display Branch and the preferred_payment_method

WITH cte
AS
(SELECT 
	branch,
    payment_method,
    COUNT(*) as total_trans,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as ranks
FROM walmart
GROUP BY 1, 2
)
SELECT *
FROM cte
WHERE ranks = 1 ;


-- 8 - Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- Find out which of the shift and number of invoices

SELECT
	branch,
CASE
		WHEN EXTRACT(HOUR FROM time ) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
	END day_time,
    COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC;


-- 9 - Identify 4 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
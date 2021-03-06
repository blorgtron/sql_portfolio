SQL Section


SQL Question 1

Captionless Image

*
 Option 1
 Option 1  
Option 2
 Option 2  
Option 3
 Option 3  
Option 4
 Option 4

For SQL Questions 2-4 consider the below "plan_history" table, and the output received from a limited select * query. This table contains subscription plan information for customers on a subscription service.

Captionless Image

Captionless Image

2. Please write a SQL query that would count the active customers on 1/1/2016 *
 SELECT count(distinct id) FROM plan_history WHERE plan_start::date =< '2016-01-01' AND (plan_end IS NULL OR plan_end::date > '2016-01-01') ... you could also coalesce(plan_end, <some arbitrary date far into the future>) >'2016-01-01 instead of having the "plan_end IS NULL OR"

3. Please write a SQL query that would output the number of active customers by day. You may use table "all_dates" that contains a single field "dte", which has all of the dates from 2010 to 2020 *
 SELECT all_dates.dte as date, count(distinct id) as active_users FROM all_dates LEFT JOIN plan_history ON (all_dates.dte BETWEEN plan_start::date AND plan_end::date)
GROUP BY 1
ORDER BY 1

4. [BONUS] Please write a SQL query that would show simple churn over time (# of canceled customers / total customers previous month)
 SELECT
prior_active.month AS month
, termed.term_count/ prior_active.active_users AS churn
FROM (SELECT to_char(all_dates.dte + INTERVAL '1 month', 'YYYY-DD') as month, count(distinct id) as active_users FROM all_dates LEFT JOIN plan_history ON (all_dates.dte BETWEEN plan_start::date AND plan_end::date)
GROUP BY 1
ORDER BY 1) AS prior_active
LEFT JOIN(SELECT to_char(plan_end, 'YYYY-MM') as term_month, count(distinct id) AS term_count FROM plan_history GROUP BY 1) AS termed on prior_active.month = termed.term_month

SQL Questions 5 - 8

Captionless Image

5. Write a SQL query to calculate "Total Sales" (using Invoice Amount) for each City. *
 SELECT customer.city, sum(invoice_totals.total) AS city_total FROM customer LEFT JOIN (SELECT customer_id, sum(coalesce(amount, 0)) as total FROM invoice GROUP BY 1) AS invoice_totals ON customer.id = invoice_totals.customer_id

6. Modify the above SQL query to show only cities over $100,000 in Total Sales. *
 SELECT city, city_total FROM(SELECT customer.city, sum(invoice_totals.total) AS city_total FROM customer LEFT JOIN (SELECT customer_id, sum(coalesce(amount, 0)) as total FROM invoice GROUP BY 1) AS invoice_totals ON customer.id = invoice_totals.customer_id) WHERE city_total >100000

7. Write a SQL query to show : name, credit_limit, and the amount of their first invoice *
 SELECT name, credit_limit, first_invoice.amount as first_invoice_amount FROM customer LEFT JOIN (SELECT DISTINCT customer_id, amount, min(created_at) AS first_invoice_date FROM invoice) AS first_invoice on customer.id = first_invoice.customer_id

8. [BONUS] Write a SQL query to show cumulative YTD (year to date) revenue per month
 SELECT rev_month, sum(revenue) OVER (PARTITON BY rev_year ORDER BY rev_month) (SELECT to_char(created_at, 'YYYY-MM') AS rev_month, tochar(created_at, 'YYYY') AS rev_year, sum(amount) AS revenue FROM invoice GROUP BY 1 ORDER BY 1) AS monthly_rev GROUP BY 1 ORDER BY 1

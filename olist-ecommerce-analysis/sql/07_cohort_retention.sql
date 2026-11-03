-- 07_cohort_retention.sql : monthly acquisition cohorts and the % who buy again in later months
WITH first_order AS (
    SELECT customer_unique_id, MIN(order_month) AS cohort_month
    FROM orders
    GROUP BY customer_unique_id
),
activity AS (
    SELECT DISTINCT o.customer_unique_id,
           f.cohort_month,
           DATE_DIFF('month', f.cohort_month, o.order_month) AS months_since_first
    FROM orders o
    JOIN first_order f USING (customer_unique_id)
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS customers FROM first_order GROUP BY cohort_month
)
SELECT a.cohort_month,
       s.customers                                              AS cohort_customers,
       a.months_since_first,
       COUNT(*)                                                 AS active_customers,
       ROUND(100.0 * COUNT(*) / s.customers, 2)                 AS retention_pct
FROM activity a
JOIN cohort_size s USING (cohort_month)
GROUP BY a.cohort_month, s.customers, a.months_since_first
ORDER BY a.cohort_month, a.months_since_first;

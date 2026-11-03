-- 06_repeat_customers.sql : how many customers come back?
WITH per_customer AS (
    SELECT customer_unique_id, COUNT(*) AS n_orders, SUM(order_value) AS spend
    FROM orders
    GROUP BY customer_unique_id
)
SELECT COUNT(*)                                          AS customers,
       SUM((n_orders > 1)::INT)                          AS repeat_customers,
       ROUND(100.0 * AVG((n_orders > 1)::INT), 2)        AS repeat_rate_pct,
       ROUND(100.0 * SUM(CASE WHEN n_orders > 1 THEN spend END) / SUM(spend), 1)
                                                         AS repeat_revenue_share_pct
FROM per_customer;

-- 02_monthly_trend.sql : orders, revenue and month-over-month growth
SELECT order_month,
       COUNT(*)                         AS orders,
       ROUND(SUM(order_value), 0)       AS revenue_brl,
       ROUND(AVG(order_value), 2)       AS avg_order_value_brl,
       ROUND(100.0 * (SUM(order_value) / LAG(SUM(order_value)) OVER (ORDER BY order_month) - 1), 1)
                                        AS revenue_mom_pct
FROM orders
GROUP BY order_month
ORDER BY order_month;

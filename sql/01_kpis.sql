-- 01_kpis.sql : headline numbers for the analysis period
SELECT COUNT(*)                                  AS orders,
       COUNT(DISTINCT customer_unique_id)        AS customers,
       ROUND(SUM(order_value), 0)                AS revenue_brl,
       ROUND(AVG(order_value), 2)                AS avg_order_value_brl,
       ROUND(AVG(review_score), 2)               AS avg_review_score,
       ROUND(100.0 * AVG(is_late::INT), 1)       AS late_delivery_pct,
       ROUND(MEDIAN(delivery_days), 0)           AS median_delivery_days
FROM orders;

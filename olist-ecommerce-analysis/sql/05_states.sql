-- 05_states.sql : demand, delivery time and freight by customer state
SELECT customer_state,
       COUNT(*)                                                     AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)          AS order_share_pct,
       ROUND(SUM(order_value), 0)                                   AS revenue_brl,
       ROUND(MEDIAN(delivery_days), 0)                              AS median_delivery_days,
       ROUND(100.0 * AVG(is_late::INT), 1)                          AS late_pct,
       ROUND(100.0 * SUM(freight_value) / SUM(product_value), 1)    AS freight_pct_of_product,
       ROUND(AVG(review_score), 2)                                  AS avg_review
FROM orders
GROUP BY customer_state
ORDER BY orders DESC;

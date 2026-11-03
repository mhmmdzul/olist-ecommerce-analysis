-- 09_payments.sql : how customers pay
WITH in_scope AS (
    SELECT p.* FROM payments p JOIN orders o USING (order_id)
)
SELECT payment_type,
       COUNT(DISTINCT order_id)                                       AS orders,
       ROUND(100.0 * SUM(payment_value) / SUM(SUM(payment_value)) OVER (), 1) AS value_share_pct,
       ROUND(AVG(CASE WHEN payment_type = 'credit_card' THEN payment_installments END), 1)
                                                                      AS avg_installments
FROM in_scope
GROUP BY payment_type
ORDER BY value_share_pct DESC;

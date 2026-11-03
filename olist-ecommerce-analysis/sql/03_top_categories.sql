-- 03_top_categories.sql : which product categories drive revenue
WITH item_level AS (
    SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
           oi.price
    FROM order_items oi
    JOIN orders o   USING (order_id)          -- keeps only in-scope delivered orders
    JOIN products p USING (product_id)
    LEFT JOIN category_translation t USING (product_category_name)
)
SELECT category,
       COUNT(*)                                              AS items_sold,
       ROUND(SUM(price), 0)                                  AS revenue_brl,
       ROUND(100.0 * SUM(price) / SUM(SUM(price)) OVER (), 1) AS revenue_share_pct,
       ROUND(AVG(price), 2)                                  AS avg_price_brl
FROM item_level
GROUP BY category
ORDER BY revenue_brl DESC;

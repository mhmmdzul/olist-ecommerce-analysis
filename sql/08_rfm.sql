-- 08_rfm.sql : RFM segmentation (Recency, Frequency, Monetary)
-- Reference date = the day after the last purchase in scope.
WITH ref AS (SELECT MAX(purchased_at)::DATE + 1 AS ref_date FROM orders),
rfm AS (
    SELECT customer_unique_id,
           DATE_DIFF('day', MAX(purchased_at)::DATE, (SELECT ref_date FROM ref)) AS recency_days,
           COUNT(*)                                                           AS frequency,
           SUM(order_value)                                                   AS monetary
    FROM orders
    GROUP BY customer_unique_id
),
scored AS (
    SELECT *,
           NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,   -- 5 = bought most recently
           NTILE(5) OVER (ORDER BY monetary)          AS m_score    -- 5 = spent the most
    FROM rfm
)
-- Most customers buy only once, so frequency is used directly (1 vs 2+)
-- instead of a quintile score, which would be meaningless here.
SELECT *,
       CASE
           WHEN frequency >= 2 AND r_score >= 4                 THEN 'Champions'
           WHEN frequency >= 2                                  THEN 'Loyal (lapsing)'
           WHEN r_score >= 4 AND m_score >= 4                   THEN 'New high-value'
           WHEN r_score >= 4                                    THEN 'New customers'
           WHEN r_score <= 2 AND m_score >= 4                   THEN 'At risk (high value)'
           WHEN r_score <= 2                                    THEN 'Lost / hibernating'
           ELSE                                                      'Needs attention'
       END AS segment
FROM scored;

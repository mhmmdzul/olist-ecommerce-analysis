-- 04_delivery_vs_review.sql : does a late delivery hurt the review score?
SELECT CASE WHEN is_late THEN 'Late' ELSE 'On time' END   AS delivery,
       COUNT(*)                                             AS orders,
       ROUND(AVG(review_score), 2)                          AS avg_review,
       ROUND(100.0 * AVG((review_score <= 2)::INT), 1)      AS pct_bad_reviews_1_2,
       ROUND(100.0 * AVG((review_score = 5)::INT), 1)       AS pct_5_star
FROM orders
WHERE review_score IS NOT NULL
GROUP BY 1
ORDER BY 1 DESC;

-- review score by how many days late (negative = arrived early)
-- SELECT DATE_DIFF('day', estimated_at::DATE, delivered_at::DATE) AS days_vs_estimate, ...

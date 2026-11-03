-- 00_setup.sql
-- Load the raw Olist CSVs as DuckDB views and build one clean, order-level table.
-- Scope: delivered orders purchased Jan 2017 - Aug 2018 (complete months only).

CREATE OR REPLACE VIEW customers   AS SELECT * FROM read_csv_auto('data/raw/olist_customers_dataset.csv');
CREATE OR REPLACE VIEW orders_raw  AS SELECT * FROM read_csv_auto('data/raw/olist_orders_dataset.csv');
CREATE OR REPLACE VIEW order_items AS SELECT * FROM read_csv_auto('data/raw/olist_order_items_dataset.csv');
CREATE OR REPLACE VIEW payments    AS SELECT * FROM read_csv_auto('data/raw/olist_order_payments_dataset.csv');
CREATE OR REPLACE VIEW reviews     AS SELECT * FROM read_csv_auto('data/raw/olist_order_reviews_dataset.csv');
CREATE OR REPLACE VIEW products    AS SELECT * FROM read_csv_auto('data/raw/olist_products_dataset.csv');
CREATE OR REPLACE VIEW sellers     AS SELECT * FROM read_csv_auto('data/raw/olist_sellers_dataset.csv');
CREATE OR REPLACE VIEW category_translation AS
  SELECT * FROM read_csv_auto('data/raw/product_category_name_translation.csv');

-- One row per delivered order, with value, timing and review score.
CREATE OR REPLACE TABLE orders AS
WITH items AS (
    SELECT order_id,
           COUNT(*)            AS n_items,
           SUM(price)          AS product_value,
           SUM(freight_value)  AS freight_value
    FROM order_items
    GROUP BY order_id
),
review AS (
    -- a few orders have more than one review: keep the latest one
    SELECT order_id, review_score
    FROM reviews
    QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_answer_timestamp DESC) = 1
)
SELECT o.order_id,
       c.customer_unique_id,
       c.customer_state,
       o.order_purchase_timestamp                                   AS purchased_at,
       DATE_TRUNC('month', o.order_purchase_timestamp)::DATE         AS order_month,
       o.order_delivered_customer_date                              AS delivered_at,
       o.order_estimated_delivery_date                              AS estimated_at,
       DATE_DIFF('day', o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_days,
       o.order_delivered_customer_date::DATE > o.order_estimated_delivery_date::DATE AS is_late,
       i.n_items,
       i.product_value,
       i.freight_value,
       i.product_value + i.freight_value                            AS order_value,
       r.review_score
FROM orders_raw o
JOIN customers c USING (customer_id)
JOIN items     i USING (order_id)
LEFT JOIN review r USING (order_id)
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp <  '2018-09-01';

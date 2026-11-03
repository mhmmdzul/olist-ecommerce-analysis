# Data

The CSV files in `raw/` are the public **Olist Brazilian E-Commerce** dataset, taken from
[olist/work-at-olist-data](https://github.com/olist/work-at-olist-data) (MIT licence, © 2019 Olist).
The same data is also published on [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

`olist_geolocation_dataset.csv` (61 MB) is not included because this analysis does not use it.

| File | Rows | What it holds |
|---|---:|---|
| `olist_orders_dataset.csv` | 99,441 | one row per order: status and timestamps |
| `olist_customers_dataset.csv` | 99,441 | customer id, unique id, city, state |
| `olist_order_items_dataset.csv` | 112,650 | products in each order: price and freight |
| `olist_order_payments_dataset.csv` | 103,886 | payment type, instalments, value |
| `olist_order_reviews_dataset.csv` | 99,224 | review score (1–5) and comment |
| `olist_products_dataset.csv` | 32,951 | product category and size |
| `olist_sellers_dataset.csv` | 3,095 | seller city and state |
| `product_category_name_translation.csv` | 71 | Portuguese → English category names |

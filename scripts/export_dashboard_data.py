"""Aggregate the cleaned order table into small JSON blocks for the dashboard (docs/).

Run from the repo root:  python scripts/export_dashboard_data.py
"""
import json
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[1]
con = duckdb.connect()
con.execute(f"SET file_search_path = '{ROOT.as_posix()}'")
con.execute((ROOT / "sql/00_setup.sql").read_text())

REGION_SQL = """
CASE
  WHEN customer_state IN ('AC','AP','AM','PA','RO','RR','TO') THEN 'North'
  WHEN customer_state IN ('AL','BA','CE','MA','PB','PE','PI','RN','SE') THEN 'Northeast'
  WHEN customer_state IN ('DF','GO','MT','MS') THEN 'Center-West'
  WHEN customer_state IN ('ES','MG','RJ','SP') THEN 'Southeast'
  ELSE 'South'
END
"""


def rows(sql):
    cur = con.execute(sql)
    cols = [d[0] for d in cur.description]
    return [dict(zip(cols, r)) for r in cur.fetchall()]


# Additive building blocks (per state), so the page can re-aggregate for any region/state filter.
monthly = rows(f"""
    SELECT {REGION_SQL} AS region, customer_state AS state, strftime(order_month, '%Y-%m') AS month,
           COUNT(*) AS orders, ROUND(SUM(order_value), 2) AS revenue,
           SUM(is_late::INT) AS late, SUM(delivery_days) AS delivery_days_sum,
           SUM(review_score) AS review_sum, COUNT(review_score) AS review_n,
           ROUND(SUM(freight_value), 2) AS freight, ROUND(SUM(product_value), 2) AS product
    FROM orders GROUP BY ALL ORDER BY month
""")

categories = rows(f"""
    SELECT {REGION_SQL} AS region, customer_state AS state,
           COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
           COUNT(*) AS items, ROUND(SUM(oi.price), 2) AS revenue
    FROM order_items oi
    JOIN orders o USING (order_id)
    JOIN products p USING (product_id)
    LEFT JOIN category_translation t USING (product_category_name)
    GROUP BY ALL
""")

delay = rows(f"""
    SELECT {REGION_SQL} AS region, customer_state AS state,
           LEAST(GREATEST(DATE_DIFF('day', estimated_at::DATE, delivered_at::DATE), -15), 15) AS days_vs_estimate,
           COUNT(*) AS orders, SUM(review_score) AS review_sum
    FROM orders WHERE review_score IS NOT NULL
    GROUP BY ALL
""")

# Customer-level views are shown for the whole business (not split by region).
rfm = rows("""
    WITH s AS (""" + (ROOT / "sql/08_rfm.sql").read_text().rstrip().rstrip(";") + """)
    SELECT segment, COUNT(*) AS customers, ROUND(SUM(monetary), 2) AS revenue,
           MEDIAN(recency_days) AS median_recency_days
    FROM s GROUP BY segment
""")

cohort = rows("""
    WITH c AS (""" + (ROOT / "sql/07_cohort_retention.sql").read_text().rstrip().rstrip(";") + """)
    SELECT strftime(cohort_month, '%Y-%m') AS cohort, cohort_customers, months_since_first, retention_pct
    FROM c WHERE months_since_first BETWEEN 1 AND 6 AND cohort_month <= DATE '2018-02-01'
""")

repeat = rows(open(ROOT / "sql/06_repeat_customers.sql").read())[0]
payments = rows(open(ROOT / "sql/09_payments.sql").read())

data = dict(monthly=monthly, categories=categories, delay=delay, rfm=rfm,
            cohort=cohort, repeat=repeat, payments=payments)
out = ROOT / "docs" / "data.js"
out.write_text("window.DASH_DATA = " + json.dumps(data, default=float, separators=(",", ":")) + ";\n")
print(f"wrote {out.relative_to(ROOT)} ({out.stat().st_size/1024:.0f} KB)")

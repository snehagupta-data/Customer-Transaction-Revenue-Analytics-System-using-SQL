-- ============================================================
-- FILE: 04_eda.sql
-- ============================================================

-- ============================================================
-- QUERY 5: Row Counts Per Table
-- Business Question: How many records exist in each table?
-- ============================================================

SELECT 'customers'   AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products',                  COUNT(*)              FROM products
UNION ALL
SELECT 'orders',                    COUNT(*)              FROM orders
UNION ALL
SELECT 'order_items',               COUNT(*)              FROM order_items
UNION ALL
SELECT 'payments',                  COUNT(*)              FROM payments;


-- ============================================================
-- QUERY 6: Date Range Analysis
-- Business Question: What time period does the data cover?
-- ============================================================

SELECT
    MIN(order_date)                                              AS earliest_order,
    MAX(order_date)                                              AS latest_order,
    MAX(order_date) - MIN(order_date)                            AS days_covered,
    COUNT(DISTINCT DATE_TRUNC('month', order_date))              AS months_covered
FROM orders;


-- ============================================================
-- QUERY 7: Basic Order Statistics
-- Business Question: What are the min, max, average, and median
--                    order values?
-- ============================================================

SELECT
    MIN(total_amount)                                            AS min_order_value,
    MAX(total_amount)                                            AS max_order_value,
    ROUND(AVG(total_amount), 2)                                  AS avg_order_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_amount)    AS median_order_value,
    ROUND(SUM(total_amount), 2)                                  AS total_revenue
FROM orders;


-- ============================================================
-- QUERY 8: Customer City Distribution
-- Business Question: Which cities have the most customers?
-- ============================================================

SELECT
    city,
    COUNT(*)                                                      AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
    2)                                                            AS pct_share
FROM customers
GROUP BY city
ORDER BY customer_count DESC
LIMIT 10;


-- ============================================================
-- QUERY 9: Product Category Distribution
-- Business Question: How many products exist per category,
--                    and what is the price range in each?
-- ============================================================

SELECT
    category,
    COUNT(*)                   AS total_products,
    ROUND(MIN(price), 2)       AS min_price,
    ROUND(MAX(price), 2)       AS max_price,
    ROUND(AVG(price), 2)       AS avg_price
FROM products
GROUP BY category
ORDER BY total_products DESC;

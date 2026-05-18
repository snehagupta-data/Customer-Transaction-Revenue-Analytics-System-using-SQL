-- ============================================================
-- FILE: 07_product_analysis.sql
-- ============================================================


-- ============================================================
-- QUERY 21: Best-Selling Products by Units Sold
-- Business Question: Which products have the highest
--                    sales volume?
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity)                         AS total_units_sold,
    COUNT(DISTINCT oi.order_id)              AS orders_containing_product,
    ROUND(SUM(oi.quantity * oi.price_at_purchase), 2)  AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_units_sold DESC
LIMIT 15;


-- ============================================================
-- QUERY 22: Pareto Analysis — 80/20 Rule
-- Business Question: Do 20% of products generate 80% of revenue?
-- Read: cumulative_pct tells you the revenue share up to and
--       including that product.
-- ============================================================

WITH product_rev AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        ROUND(SUM(oi.quantity * oi.price_at_purchase), 2)   AS revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
running AS (
    SELECT
        *,
        SUM(revenue) OVER (ORDER BY revenue DESC)   AS running_total,
        SUM(revenue) OVER ()                        AS grand_total
    FROM product_rev
)
SELECT
    product_id,
    product_name,
    category,
    revenue,
    ROUND(running_total * 100.0 / grand_total, 2)   AS cumulative_pct
FROM running
ORDER BY revenue DESC;


-- ============================================================
-- QUERY 23: Product Revenue Ranking Within Category
-- Business Question: Which product is top-ranked in each
--                    category by revenue?
-- ============================================================

WITH product_rev AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        ROUND(SUM(oi.quantity * oi.price_at_purchase), 2)   AS revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT
    category,
    product_name,
    revenue,
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC)   AS rank_in_category
FROM product_rev
ORDER BY category, rank_in_category;

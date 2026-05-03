-- ============================================================
-- FILE: 05_revenue_analysis.sql
-- ============================================================


-- ============================================================
-- QUERY 10: Total Revenue (Successful Transactions Only)
-- Business Question: What is the overall revenue generated?
-- ============================================================

SELECT
    COUNT(DISTINCT o.order_id)      AS total_orders,
    COUNT(DISTINCT o.customer_id)   AS unique_customers,
    ROUND(SUM(o.total_amount), 2)   AS total_revenue,
    ROUND(AVG(o.total_amount), 2)   AS avg_order_value
FROM orders o
WHERE o.order_id IN (
    SELECT order_id
    FROM payments
    WHERE payment_status = 'Success'
);


-- ============================================================
-- QUERY 11: Monthly Revenue Trend
-- Business Question: How has revenue changed month over month?
-- ============================================================

SELECT
    TO_CHAR(order_date, 'YYYY-MM')   AS month,
    COUNT(order_id)                  AS total_orders,
    ROUND(SUM(total_amount), 2)      AS monthly_revenue
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;


-- ============================================================
-- QUERY 12: Top 10 Customers by Revenue
-- Business Question: Who are our highest-value customers?
-- ============================================================

SELECT
    c.customer_id,
    c.name,
    c.city,
    COUNT(o.order_id)                AS total_orders,
    ROUND(SUM(o.total_amount), 2)    AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city
ORDER BY lifetime_value DESC
LIMIT 10;


-- ============================================================
-- QUERY 13: Top 10 Products by Revenue
-- Business Question: Which products drive the most revenue?
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity)                                            AS units_sold,
    ROUND(SUM(oi.quantity * oi.price_at_purchase), 2)           AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- QUERY 14: Revenue by Category
-- Business Question: Which product category contributes most
--                    to total revenue?
-- ============================================================

SELECT
    p.category,
    SUM(oi.quantity)                                            AS units_sold,
    ROUND(SUM(oi.quantity * oi.price_at_purchase), 2)           AS category_revenue,
    ROUND(
        SUM(oi.quantity * oi.price_at_purchase) * 100.0 /
        SUM(SUM(oi.quantity * oi.price_at_purchase)) OVER (),
    2)                                                          AS pct_of_total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

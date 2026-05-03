-- ============================================================
-- FILE: 06_customer_analysis.sql
-- ============================================================


-- ============================================================
-- QUERY 15: New vs Returning Customers
-- Business Question: How many customers placed more than
--                    one order?
-- ============================================================

WITH order_counts AS (
    SELECT
        customer_id,
        COUNT(order_id) AS num_orders
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN num_orders = 1 THEN 'New (1 Order)'
        ELSE 'Returning (2+ Orders)'
    END                                                     AS customer_type,
    COUNT(*)                                                AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)     AS percentage
FROM order_counts
GROUP BY
    CASE
        WHEN num_orders = 1 THEN 'New (1 Order)'
        ELSE 'Returning (2+ Orders)'
    END;


-- ============================================================
-- QUERY 16: Customer Lifetime Value (CLV)
-- Business Question: What is the revenue generated per
--                    customer over their lifetime?
-- ============================================================

SELECT
    c.customer_id,
    c.name,
    c.city,
    c.signup_date,
    CURRENT_DATE - c.signup_date          AS days_as_customer,
    COUNT(o.order_id)                     AS total_orders,
    ROUND(SUM(o.total_amount), 2)         AS lifetime_revenue,
    ROUND(AVG(o.total_amount), 2)         AS avg_order_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city, c.signup_date
ORDER BY lifetime_revenue DESC NULLS LAST;


-- ============================================================
-- QUERY 17: Customer Segmentation — High / Medium / Low Value
-- Business Question: How should we classify customers by
--                    total spending?
-- Thresholds: High ≥ ₹10,000 | Medium ≥ ₹3,000 | Low < ₹3,000
-- ============================================================

WITH clv AS (
    SELECT
        customer_id,
        ROUND(SUM(total_amount), 2) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN total_spent >= 10000  THEN 'High Value'
        WHEN total_spent >= 3000   THEN 'Medium Value'
        ELSE 'Low Value'
    END                                AS segment,
    COUNT(*)                           AS customers,
    ROUND(AVG(total_spent), 2)         AS avg_spend_per_customer,
    ROUND(SUM(total_spent), 2)         AS total_segment_revenue
FROM clv
GROUP BY 1
ORDER BY avg_spend_per_customer DESC;


-- ============================================================
-- QUERY 31: Customer Purchase Frequency Bucket
-- Business Question: How are customers distributed by number
--                    of orders placed?
-- ============================================================

WITH freq AS (
    SELECT
        customer_id,
        COUNT(order_id) AS num_orders
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN num_orders = 1  THEN '1 Order'
        WHEN num_orders <= 3 THEN '2–3 Orders'
        WHEN num_orders <= 6 THEN '4–6 Orders'
        ELSE '7+ Orders'
    END                    AS frequency_bucket,
    COUNT(*)               AS customers
FROM freq
GROUP BY 1
ORDER BY customers DESC;


-- ============================================================
-- QUERY 32: First vs Most Recent Order — Customer Tenure
-- Business Question: How long between a customer's first and
--                    most recent purchase?
-- ============================================================

SELECT
    c.customer_id,
    c.name,
    MIN(o.order_date)                          AS first_order_date,
    MAX(o.order_date)                          AS last_order_date,
    MAX(o.order_date) - MIN(o.order_date)      AS days_active,
    COUNT(o.order_id)                          AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY days_active DESC;


-- ============================================================
-- QUERY 34: Churned / Never-Ordered Customers
-- Business Question: Which customers signed up but never
--                    made a purchase?
-- ============================================================

SELECT
    c.customer_id,
    c.name,
    c.email,
    c.city,
    c.signup_date,
    CURRENT_DATE - c.signup_date   AS days_since_signup
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY days_since_signup DESC;

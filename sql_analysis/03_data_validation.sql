-- ============================================================
-- FILE: 03_data_validation.sql
-- ============================================================


-- ============================================================
-- QUERY 1: NULL Value Check — All Tables
-- Business Question: Are there any missing critical values?
-- ============================================================

-- NULL check on customers
SELECT
    'customers'                                                   AS table_name,
    COUNT(*) FILTER (WHERE name IS NULL)         AS null_name,
    COUNT(*) FILTER (WHERE email IS NULL)        AS null_email,
    COUNT(*) FILTER (WHERE signup_date IS NULL)  AS null_signup_date
FROM customers

UNION ALL

-- NULL check on orders
SELECT
    'orders',
    COUNT(*) FILTER (WHERE customer_id IS NULL)   AS null_customer_id,
    COUNT(*) FILTER (WHERE order_date IS NULL)    AS null_order_date,
    COUNT(*) FILTER (WHERE total_amount IS NULL)  AS null_total_amount
FROM orders

UNION ALL

-- NULL check on order_items
SELECT
    'order_items',
    COUNT(*) FILTER (WHERE order_id IS NULL)            AS null_order_id,
    COUNT(*) FILTER (WHERE product_id IS NULL)          AS null_product_id,
    COUNT(*) FILTER (WHERE price_at_purchase IS NULL)   AS null_price
FROM order_items;


-- ============================================================
-- QUERY 2: Duplicate Detection
-- Business Question: Are there duplicate customer emails or order IDs?
-- ============================================================

-- Duplicate emails in customers
SELECT
    email,
    COUNT(*) AS occurrence_count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- Duplicate order_ids in orders
SELECT
    order_id,
    COUNT(*) AS occurrence_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Duplicate payment records per order
SELECT
    order_id,
    COUNT(*) AS occurrence_count
FROM payments
GROUP BY order_id
HAVING COUNT(*) > 1;


-- ============================================================
-- QUERY 3: Foreign Key Integrity Validation
-- Business Question: Do all orders reference valid customers?
--                    Do all order_items reference valid orders/products?
-- ============================================================

-- Orders with no matching customer
SELECT
    o.order_id,
    o.customer_id AS orphan_customer_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- order_items with no matching order
SELECT
    oi.order_item_id,
    oi.order_id AS orphan_order_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- order_items with no matching product
SELECT
    oi.order_item_id,
    oi.product_id AS orphan_product_id
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Payments with no matching order
SELECT
    p.payment_id,
    p.order_id AS orphan_order_id
FROM payments p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


-- ============================================================
-- QUERY 4: Total Amount Accuracy Check
-- Business Question: Does orders.total_amount match the sum
--                    calculated from order_items?
-- ============================================================

SELECT
    o.order_id,
    o.total_amount                                        AS recorded_amount,
    ROUND(SUM(oi.quantity * oi.price_at_purchase), 2)     AS calculated_amount,
    ROUND(
        o.total_amount - SUM(oi.quantity * oi.price_at_purchase),
    2)                                                    AS discrepancy
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING ABS(
    o.total_amount - SUM(oi.quantity * oi.price_at_purchase)
) > 0.01;

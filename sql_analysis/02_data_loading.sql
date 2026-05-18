-- ============================================================
-- FILE: 02_data_loading.sql
-- ============================================================


-- ------------------------------------------------------------
-- LOADING ORDER (must follow this sequence):
--
--   Step 1: customers    → no dependencies
--   Step 2: products     → no dependencies
--   Step 3: orders       → depends on customers
--   Step 4: order_items  → depends on orders + products
--   Step 5: payments     → depends on orders
-- ------------------------------------------------------------


-- STEP 1: Load customers
COPY customers (customer_id, name, email, city, signup_date)
FROM 'E:\Data Analyst Projects\Sample Projects\sql-project\Data\customers.csv'
CSV HEADER;


-- STEP 2: Load products
COPY products (product_id, product_name, category, price)
FROM 'E:\Data Analyst Projects\Sample Projects\sql-project\Data\products.csv'
CSV HEADER;


-- STEP 3: Load orders
COPY orders (order_id, customer_id, order_date, total_amount, payment_method)
FROM 'E:\Data Analyst Projects\Sample Projects\sql-project\Data\orders.csv'
CSV HEADER;


-- STEP 4: Load order_items
COPY order_items (order_item_id, order_id, product_id, quantity, price_at_purchase)
FROM 'E:\Data Analyst Projects\Sample Projects\sql-project\Data\order_items.csv'
CSV HEADER;


-- STEP 5: Load payments
COPY payments (payment_id, order_id, payment_date, payment_method, payment_status)
FROM 'E:\Data Analyst Projects\Sample Projects\sql-project\Data\payments.csv'
CSV HEADER;


-- ------------------------------------------------------------
-- QUICK ROW COUNT CHECK AFTER LOADING
-- Run this to confirm all tables loaded successfully.
-- ------------------------------------------------------------
SELECT 'customers'   AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products',                  COUNT(*)              FROM products
UNION ALL
SELECT 'orders',                    COUNT(*)              FROM orders
UNION ALL
SELECT 'order_items',               COUNT(*)              FROM order_items
UNION ALL
SELECT 'payments',                  COUNT(*)              FROM payments;

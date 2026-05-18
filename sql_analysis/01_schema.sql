-- ============================================================
-- FILE: 01_schema.sql
-- PURPOSE: Create database schema for E-commerce SQL Project
-- ============================================================


-- ------------------------------------------------------------
-- CLEANUP (Optional)
-- Drops tables if they already exist.
-- This avoids duplicate table errors while re-running script.
-- ------------------------------------------------------------

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;


-- ============================================================
-- TABLE 1: customers
-- Stores customer information
-- ============================================================

CREATE TABLE customers (
    customer_id      INT PRIMARY KEY,
    name             VARCHAR(100) NOT NULL,
    email            VARCHAR(150) UNIQUE NOT NULL,
    city             VARCHAR(100),
    signup_date      DATE
);


-- ============================================================
-- TABLE 2: products
-- Stores product catalog information
-- ============================================================

CREATE TABLE products (
    product_id       INT PRIMARY KEY,
    product_name     VARCHAR(150) NOT NULL,
    category         VARCHAR(100),
    price            DECIMAL(10,2) NOT NULL
);


-- ============================================================
-- TABLE 3: orders
-- Stores customer order details
-- Depends on: customers
-- ============================================================

CREATE TABLE orders (
    order_id         INT PRIMARY KEY,
    customer_id      INT NOT NULL,
    order_date       DATE NOT NULL,
    total_amount     DECIMAL(10,2) NOT NULL,
    payment_method   VARCHAR(50),

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE
);


-- ============================================================
-- TABLE 4: order_items
-- Stores products inside each order
-- Depends on: orders, products
-- ============================================================

CREATE TABLE order_items (
    order_item_id        INT PRIMARY KEY,
    order_id             INT NOT NULL,
    product_id           INT NOT NULL,
    quantity             INT NOT NULL,
    price_at_purchase    DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_orderitems_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_orderitems_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
);


-- ============================================================
-- TABLE 5: payments
-- Stores payment transaction information
-- Depends on: orders
-- ============================================================

CREATE TABLE payments (
    payment_id        INT PRIMARY KEY,
    order_id          INT NOT NULL,
    payment_date      DATE NOT NULL,
    payment_method    VARCHAR(50),
    payment_status    VARCHAR(50),

    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE
);



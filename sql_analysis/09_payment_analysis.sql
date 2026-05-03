-- ============================================================
-- FILE: 09_payment_analysis.sql
-- ============================================================


-- ============================================================
-- QUERY 22: Payment Method Distribution
-- Business Question: Which payment methods are most popular,
--                    and how much revenue does each drive?
-- ============================================================

SELECT
    p.payment_method,
    COUNT(*)                                                    AS total_transactions,
    ROUND(SUM(o.total_amount), 2)                               AS total_revenue,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)         AS pct_of_transactions
FROM payments p
JOIN orders o ON p.order_id = o.order_id
GROUP BY p.payment_method
ORDER BY total_transactions DESC;


-- ============================================================
-- QUERY 23: Payment Success vs Failure Rate
-- Business Question: What percentage of transactions fail,
--                    are pending, or are refunded?
-- ============================================================

SELECT
    payment_status,
    COUNT(*)                                                    AS transaction_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)         AS pct_of_total
FROM payments
GROUP BY payment_status
ORDER BY transaction_count DESC;


-- ============================================================
-- QUERY 24: Failed Transactions — Revenue at Risk
-- Business Question: How much potential revenue was lost
--                    by payment method due to failures?
-- ============================================================

SELECT
    p.payment_method,
    COUNT(p.payment_id)                AS failed_transactions,
    ROUND(SUM(o.total_amount), 2)      AS revenue_at_risk
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE p.payment_status = 'Failed'
GROUP BY p.payment_method
ORDER BY revenue_at_risk DESC;

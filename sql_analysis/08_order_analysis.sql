-- ============================================================
-- FILE: 08_order_analysis.sql
-- ============================================================


-- ============================================================
-- QUERY 20: Average Order Value (AOV) by Month
-- Business Question: Is the average basket size growing over
--                    time? Are upselling efforts working?
-- ============================================================

SELECT
    TO_CHAR(order_date, 'YYYY-MM')   AS month,
    COUNT(order_id)                  AS total_orders,
    ROUND(SUM(total_amount), 2)      AS monthly_revenue,
    ROUND(AVG(total_amount), 2)      AS avg_order_value
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;


-- ============================================================
-- QUERY 21: Peak Order Periods — Day of Week
-- Business Question: On which days of the week do customers
--                    shop most?
-- ============================================================

SELECT
    TO_CHAR(order_date, 'Day')       AS day_of_week,
    EXTRACT(DOW FROM order_date)     AS dow_num,
    COUNT(order_id)                  AS total_orders,
    ROUND(SUM(total_amount), 2)      AS total_revenue,
    ROUND(AVG(total_amount), 2)      AS avg_order_value
FROM orders
GROUP BY TO_CHAR(order_date, 'Day'), EXTRACT(DOW FROM order_date)
ORDER BY dow_num;


-- ============================================================
-- QUERY 33: Year-over-Year Revenue Comparison
-- Business Question: How does annual revenue compare across
--                    years?
-- ============================================================

SELECT
    EXTRACT(YEAR FROM order_date)    AS year,
    COUNT(order_id)                  AS total_orders,
    ROUND(SUM(total_amount), 2)      AS annual_revenue,
    ROUND(AVG(total_amount), 2)      AS avg_order_value
FROM orders
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

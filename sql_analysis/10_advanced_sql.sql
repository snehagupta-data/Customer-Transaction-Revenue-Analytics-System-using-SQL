-- ============================================================
-- FILE: 10_advanced_sql.sql
-- ============================================================


-- ============================================================
-- QUERY 30: Customer Revenue Ranking
-- Business Question: Who are the top customers ranked by spend?
-- ============================================================

SELECT
    c.customer_id,
    c.name,
    c.city,
    ROUND(SUM(o.total_amount), 2)                               AS total_revenue,
    RANK()        OVER (ORDER BY SUM(o.total_amount) DESC)      AS revenue_rank,
    DENSE_RANK()  OVER (ORDER BY SUM(o.total_amount) DESC)      AS dense_rank,
    ROW_NUMBER()  OVER (ORDER BY SUM(o.total_amount) DESC)      AS row_num
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city
ORDER BY revenue_rank;


-- ============================================================
-- QUERY 31: Running Total Revenue
-- Business Question: What does the cumulative revenue look
--                    like over time?
-- ============================================================

SELECT
    TO_CHAR(order_date, 'YYYY-MM')                              AS month,
    ROUND(SUM(total_amount), 2)                                 AS monthly_revenue,
    ROUND(
        SUM(SUM(total_amount)) OVER (ORDER BY TO_CHAR(order_date, 'YYYY-MM')),
    2)                                                          AS running_total
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;


-- ============================================================
-- QUERY 32: 3-Month Moving Average Revenue
-- Business Question: What is the smoothed revenue trend,
--                    eliminating month-to-month noise?
-- ============================================================

WITH monthly AS (
    SELECT
        TO_CHAR(order_date, 'YYYY-MM')   AS month,
        ROUND(SUM(total_amount), 2)      AS monthly_revenue
    FROM orders
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT
    month,
    monthly_revenue,
    ROUND(
        AVG(monthly_revenue) OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
    2)                                   AS moving_avg_3m
FROM monthly
ORDER BY month;


-- ============================================================
-- QUERY 33: Month-over-Month Revenue Growth
-- Business Question: What is the percentage revenue change
--                    each month vs the prior month?
-- ============================================================

WITH monthly AS (
    SELECT
        TO_CHAR(order_date, 'YYYY-MM')   AS month,
        ROUND(SUM(total_amount), 2)      AS revenue
    FROM orders
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)                          AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0 /
        NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
    2)                                                          AS mom_growth_pct
FROM monthly
ORDER BY month;


-- ============================================================
-- QUERY 34: Cohort Analysis — Customer Retention by Signup Month
-- Business Question: What percentage of customers from each
--                    signup cohort return to purchase over time?
-- ============================================================

WITH cohort AS (
    SELECT
        c.customer_id,
        DATE_TRUNC('month', c.signup_date)   AS cohort_month,
        DATE_TRUNC('month', o.order_date)    AS order_month
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
),
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id)          AS cohort_customers
    FROM cohort
    GROUP BY cohort_month
),
retention AS (
    SELECT
        cohort_month,
        order_month,
        COUNT(DISTINCT customer_id)          AS active_customers,
        EXTRACT(MONTH FROM AGE(order_month, cohort_month))  AS months_since_signup
    FROM cohort
    GROUP BY cohort_month, order_month
)
SELECT
    r.cohort_month,
    r.months_since_signup,
    r.active_customers,
    cs.cohort_customers,
    ROUND(r.active_customers * 100.0 / cs.cohort_customers, 2)  AS retention_pct
FROM retention r
JOIN cohort_size cs ON r.cohort_month = cs.cohort_month
ORDER BY r.cohort_month, r.months_since_signup;


-- ============================================================
-- QUERY 35: RFM Scoring — Recency, Frequency, Monetary
-- Business Question: How can we score and segment customers
--                    for precision marketing?
-- Scores 1–5: 5 = best (most recent, most frequent, highest spend)
-- ============================================================

WITH rfm_base AS (
    SELECT
        customer_id,
        MAX(order_date)                          AS last_order_date,
        CURRENT_DATE - MAX(order_date)           AS recency_days,
        COUNT(order_id)                          AS frequency,
        ROUND(SUM(total_amount), 2)              AS monetary
    FROM orders
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days ASC)   AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC)     AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)      AS m_score
    FROM rfm_base
)
SELECT
    customer_id,
    last_order_date,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    r_score + f_score + m_score                  AS rfm_total_score,
    CASE
        WHEN r_score + f_score + m_score >= 13 THEN 'Champion'
        WHEN r_score + f_score + m_score >= 10 THEN 'Loyal Customer'
        WHEN r_score + f_score + m_score >= 7  THEN 'Potential Loyalist'
        WHEN r_score >= 4 AND f_score <= 2      THEN 'New Customer'
        WHEN r_score <= 2 AND f_score >= 3      THEN 'At Risk'
        ELSE 'Needs Attention'
    END                                          AS rfm_segment
FROM rfm_scores
ORDER BY rfm_total_score DESC;

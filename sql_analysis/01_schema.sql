-- ============================================================
-- FILE: 11_business_insights.sql
-- ============================================================


-- ============================================================
-- INSIGHT 1: Revenue Concentration (Pareto / 80-20 Rule)
-- Finding: The top 20% of products typically account for ~80% of revenue. Focus inventory and marketing on these products.
-- ============================================================

WITH product_rev AS (
    SELECT
        p.product_id,
        p.product_name,
        ROUND(SUM(oi.quantity * oi.price_at_purchase), 2)   AS revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
),
running AS (
    SELECT *,
        SUM(revenue) OVER (ORDER BY revenue DESC)   AS running_total,
        SUM(revenue) OVER ()                        AS grand_total
    FROM product_rev
)
SELECT
    product_id,
    product_name,
    revenue,
    ROUND(running_total * 100.0 / grand_total, 2)   AS cumulative_revenue_pct
FROM running
WHERE running_total * 100.0 / grand_total <= 80
ORDER BY revenue DESC;


-- ============================================================
-- INSIGHT 2: Returning Customer Revenue Premium
-- Finding: Returning customers generate higher average order values than one-time buyers — retention > acquisition.
-- ============================================================

WITH order_counts AS (
    SELECT
        customer_id,
        COUNT(order_id)              AS num_orders,
        ROUND(SUM(total_amount), 2)  AS total_spent,
        ROUND(AVG(total_amount), 2)  AS avg_order_value
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN num_orders = 1 THEN 'One-Time Buyer'
        ELSE 'Returning Customer'
    END                              AS customer_type,
    COUNT(*)                         AS customer_count,
    ROUND(AVG(total_spent), 2)       AS avg_lifetime_spend,
    ROUND(AVG(avg_order_value), 2)   AS avg_order_value
FROM order_counts
GROUP BY 1;


-- ============================================================
-- INSIGHT 3: Payment Failure Revenue Leakage
-- Finding: Failed transactions represent direct revenue loss. Certain payment methods may have disproportionate 
-- failure rates, indicating integration or UX issues.
-- ============================================================

SELECT
    p.payment_method,
    COUNT(CASE WHEN p.payment_status = 'Success' THEN 1 END)    AS successful,
    COUNT(CASE WHEN p.payment_status = 'Failed'  THEN 1 END)    AS failed,
    ROUND(
        COUNT(CASE WHEN p.payment_status = 'Failed' THEN 1 END) * 100.0 /
        NULLIF(COUNT(*), 0),
    2)                                                           AS failure_rate_pct,
    ROUND(SUM(CASE WHEN p.payment_status = 'Failed'
                   THEN o.total_amount ELSE 0 END), 2)           AS revenue_at_risk
FROM payments p
JOIN orders o ON p.order_id = o.order_id
GROUP BY p.payment_method
ORDER BY revenue_at_risk DESC;


-- ============================================================
-- INSIGHT 4: City-Level Revenue Concentration
-- Finding: A small number of cities drive most of the revenue. Action: Improve delivery SLAs and warehouse capacity in
-- top cities; run awareness campaigns in underperforming ones.
-- ============================================================

SELECT
    c.city,
    COUNT(DISTINCT c.customer_id)                               AS customers,
    COUNT(o.order_id)                                           AS total_orders,
    ROUND(SUM(o.total_amount), 2)                               AS city_revenue,
    ROUND(
        SUM(o.total_amount) * 100.0 /
        SUM(SUM(o.total_amount)) OVER (),
    2)                                                          AS pct_of_total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY city_revenue DESC;


-- ============================================================
-- INSIGHT 5: Seasonal / Monthly Revenue Patterns
-- Finding: Revenue peaks correlate with festivals, sales events, or promotional campaigns.
-- ============================================================

SELECT
    TO_CHAR(order_date, 'YYYY-MM')   AS month,
    COUNT(order_id)                  AS total_orders,
    ROUND(SUM(total_amount), 2)      AS monthly_revenue,
    ROUND(AVG(total_amount), 2)      AS avg_order_value,
    ROUND(
        SUM(SUM(total_amount)) OVER (ORDER BY TO_CHAR(order_date, 'YYYY-MM')),
    2)                               AS running_total_revenue
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;


-- ============================================================
-- INSIGHT 6: Cohort Retention Drop-Off
-- Finding: Retention typically drops sharply after Month 1. Improving Month-1 to Month-3 retention by 5% compounds
-- significantly over a full year.
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
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_customers
    FROM cohort GROUP BY cohort_month
),
retention AS (
    SELECT
        cohort_month,
        order_month,
        COUNT(DISTINCT customer_id)         AS active_customers,
        EXTRACT(MONTH FROM AGE(order_month, cohort_month)) AS months_since_signup
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
WHERE r.months_since_signup BETWEEN 0 AND 6
ORDER BY r.cohort_month, r.months_since_signup;


-- ============================================================
-- INSIGHT 7: Never-Purchased Customers (Activation Gap)
-- Finding: Customers who registered but never ordered already have brand awareness — they are the cheapest segment to
-- convert compared to cold acquisition.
-- ============================================================

SELECT
    COUNT(*)                         AS never_ordered_customers,
    ROUND(AVG(CURRENT_DATE - c.signup_date), 0) AS avg_days_since_signup
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- ============================================================
-- INSIGHT 8: RFM Segment Distribution
-- Finding: Identifying Champions, Loyal, At-Risk, and New customers enables different marketing strategies per segment.
-- ============================================================

WITH rfm_base AS (
    SELECT
        customer_id,
        CURRENT_DATE - MAX(order_date)   AS recency_days,
        COUNT(order_id)                  AS frequency,
        ROUND(SUM(total_amount), 2)      AS monetary
    FROM orders
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days ASC)   AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC)     AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)      AS m_score
    FROM rfm_base
),
segments AS (
    SELECT *,
        r_score + f_score + m_score AS rfm_total,
        CASE
            WHEN r_score + f_score + m_score >= 13 THEN 'Champion'
            WHEN r_score + f_score + m_score >= 10 THEN 'Loyal Customer'
            WHEN r_score + f_score + m_score >= 7  THEN 'Potential Loyalist'
            WHEN r_score >= 4 AND f_score <= 2      THEN 'New Customer'
            WHEN r_score <= 2 AND f_score >= 3      THEN 'At Risk'
            ELSE 'Needs Attention'
        END AS rfm_segment
    FROM rfm_scores
)
SELECT
    rfm_segment,
    COUNT(*)                         AS customers,
    ROUND(AVG(monetary), 2)          AS avg_spend,
    ROUND(AVG(frequency), 1)         AS avg_orders
FROM segments
GROUP BY rfm_segment
ORDER BY avg_spend DESC;

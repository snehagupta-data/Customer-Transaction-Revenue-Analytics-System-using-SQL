# 🛒 E-Commerce SQL Data Analytics Project

> **Production-grade SQL analytics portfolio** built on a simulated e-commerce database.
> Demonstrates the complete analyst workflow: schema design → validation → EDA → business KPIs → advanced SQL → insights.

---

## 📌 Project Overview

This project analyses a five-table e-commerce database to answer real business questions around revenue, customer behaviour, product performance, and payment health. It mirrors the analytics workflow used at companies like Amazon, Flipkart, and Meesho.

| Attribute        | Detail                                              |
|------------------|-----------------------------------------------------|
| **Database**     | PostgreSQL (pgAdmin compatible)                     |
| **Total Queries**| 35 categorised SQL queries                          |
| **Tables**       | 5 (customers, products, orders, order_items, payments) |
| **Domain**       | E-Commerce / Retail Analytics                       |
| **Suitable For** | Fresher DA interviews, internships, GitHub portfolio |

---

## 🗄️ Dataset / Schema Description

The database follows **Third Normal Form (3NF)** with full referential integrity.

```
customers
│   customer_id (PK), name, email, city, signup_date
│
└──▶ orders
     │   order_id (PK), customer_id (FK), order_date, total_amount, payment_method
     │
     ├──▶ order_items
     │        order_item_id (PK), order_id (FK), product_id (FK), quantity, price_at_purchase
     │
     └──▶ payments
              payment_id (PK), order_id (FK), payment_date, payment_method, payment_status

products
    product_id (PK), product_name, category, price
```

**Entity Relationships:**
- One customer → many orders
- One order → many order_items
- Each order_item → one product
- Each order → one payment record

---

## 🛠️ Tools Used

- **PostgreSQL** — Primary database engine
- **pgAdmin** — Query execution and database management
- **SQL** — Core analytics language

---

## 📁 File Structure

```
SQL_PROJECT/
│
├── README.md                  ← Project overview (this file)
├── 01_schema.sql              ← CREATE TABLE statements with constraints
├── 02_data_loading.sql        ← Table creation order + COPY commands
├── 03_data_validation.sql     ← NULL checks, duplicates, FK integrity
├── 04_eda.sql                 ← Exploratory data analysis
├── 05_revenue_analysis.sql    ← Revenue KPIs and trends
├── 06_customer_analysis.sql   ← CLV, segmentation, retention
├── 07_product_analysis.sql    ← Best sellers, Pareto, category ranking
├── 08_order_analysis.sql      ← AOV, frequency, peak periods
├── 09_payment_analysis.sql    ← Payment methods, failures, revenue at risk
├── 10_advanced_sql.sql        ← Window functions, cohort, RFM, MoM growth
├── 11_business_insights.sql   ← Annotated insights as SQL comments
```

---

## 📊 Key Business Insights

1. **Revenue is concentrated** — Top 20% of products typically generate ~80% of revenue (Pareto principle).
2. **Returning customers** have significantly higher lifetime value than one-time buyers.
3. **Payment failures** represent measurable revenue leakage by payment method.
4. **City-level concentration** — A few cities drive a disproportionate share of orders.
5. **Seasonal patterns** — Monthly revenue trends reveal campaign and festival-driven peaks.
6. **High-tenure, low-frequency customers** are re-engagement opportunities.
7. **Top customer segment** accounts for outsized revenue despite being a small fraction of users.
8. **Cohort retention** drops sharply after Month 1 — improving this curve has a compounding revenue effect.
9. **Category pricing gaps** — High-volume, low-revenue categories signal pricing opportunities.
10. **AOV trend** indicates whether upselling/cross-selling efforts are working.
11. **Never-ordered customers** are a high-priority activation segment.
12. **RFM scoring** enables precision targeting: Champions need loyalty rewards; At-Risk need win-back campaigns.


## 🎯 SQL Skills Demonstrated

| Skill                              | File(s)                        |
|------------------------------------|--------------------------------|
| Schema Design & Constraints        | 01_schema.sql                  |
| JOINs (INNER, LEFT)                | 05–10_*.sql                    |
| CTEs (WITH clause)                 | 06, 07, 10_*.sql               |
| Aggregate Functions                | 04–09_*.sql                    |
| RANK / DENSE_RANK / ROW_NUMBER     | 10_advanced_sql.sql            |
| LAG / LEAD                         | 10_advanced_sql.sql            |
| Running Totals & Moving Averages   | 10_advanced_sql.sql            |
| NTILE Bucketing                    | 10_advanced_sql.sql            |
| CASE WHEN Segmentation             | 06, 07, 10_*.sql               |
| Date Functions                     | 04, 05, 08, 10_*.sql           |
| Cohort Analysis                    | 10_advanced_sql.sql            |
| RFM Scoring                        | 10_advanced_sql.sql            |
| NULL Handling                      | 03_data_validation.sql         |
| PERCENTILE_CONT                    | 04_eda.sql                     |




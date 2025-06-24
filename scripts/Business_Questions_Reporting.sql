/* ============================================================================
   Script: Business Questions Reporting.sql
   Author: Mayuresh Chourikar
   Project: SQL Data Warehouse

   Overview:
   This script answers key business questions using the Gold Layer of the 
   data warehouse. It focuses on customer distribution, product segmentation, 
   revenue breakdowns, and top/bottom performance analysis.

   Usage:
   - Execute after the Gold views (`fact_sales`, `dim_products`, `dim_customers`) are created
   - Useful for ad-hoc reporting, validation, and dashboard prep

   Key Topics Covered:
   - Customer demographics
   - Product categories and cost analysis
   - Revenue by customer, category, subcategory
   - Product and customer ranking
============================================================================ */

-- =============================================================
-- 1. Customer Demographics
-- =============================================================

-- Total customers by country
SELECT
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Total customers by gender
SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- =============================================================
-- 2. Product Distribution
-- =============================================================

-- Total products by category
SELECT
    category,
    COUNT(product_id) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Average product cost per category
SELECT
    category,
    COUNT(product_id) AS total_products,
    AVG(cost) AS average_cost
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- =============================================================
-- 3. Revenue Analysis
-- =============================================================

-- Total revenue by category
SELECT
    p.category,
    SUM(f.sales_price) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Total revenue by customer
SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_price) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- Distribution of items sold by country
SELECT
    c.country,
    SUM(f.sales_quantity) AS total_quantity_sold
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_quantity_sold DESC;

-- =============================================================
-- 4. Product Performance
-- =============================================================

-- Top 5 best-selling products by revenue
SELECT TOP 5
    p.product_name,
    SUM(f.sales_price) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Bottom 5 worst-performing products by revenue
SELECT TOP 5
    p.product_name,
    SUM(f.sales_price) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;

-- Top 5 best-selling subcategories by revenue
SELECT TOP 5
    p.subcategory,
    SUM(f.sales_price) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY p.subcategory
ORDER BY total_revenue DESC;

-- =============================================================
-- 5. Customer Ranking
-- =============================================================

-- Top 10 customers by revenue
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_price) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- Bottom 3 customers by number of orders placed
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders ASC;

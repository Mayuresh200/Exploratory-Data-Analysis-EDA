/* ============================================================================
   Script: Advanced Data Analytics and Trend Analysis
   Author: Mayuresh Chourikar
   Project: SQL Data Warehouse

   Overview:
   This script performs advanced analytics on the Gold Layer to derive business 
   insights through time-series, segmentation, and comparative analysis.

   Trends Analyzed:
   - Sales trends over time (yearly, monthly)
   - Running totals and moving averages
   - Year-over-year and average-based product performance
   - Proportional contribution of product categories
   - Product and customer segmentation based on cost and spending behavior

   Usage:
   - Execute after the Gold Layer views (`fact_sales`, `dim_products`, `dim_customers`) are populated.
   - Supports trend detection, reporting, and business intelligence modeling.
============================================================================ */

USE DataWarehouse;
GO

-- =============================================================
-- 1. Sales Trends Over Time (Yearly)
-- =============================================================
SELECT
    YEAR(f.order_date) AS order_year,
    SUM(f.sales_price) AS total_sales,
    COUNT(DISTINCT f.customer_key) AS total_customers,
    SUM(f.sales_quantity) AS total_quantity
FROM gold.fact_sales f
WHERE f.order_date IS NOT NULL
GROUP BY YEAR(f.order_date)
ORDER BY order_year;

-- =============================================================
-- 2. Sales Trends Over Time (Monthly)
-- =============================================================
SELECT
    DATETRUNC(MONTH, f.order_date) AS order_month,
    SUM(f.sales_price) AS total_sales,
    COUNT(DISTINCT f.customer_key) AS total_customers,
    SUM(f.sales_quantity) AS total_quantity
FROM gold.fact_sales f
WHERE f.order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, f.order_date)
ORDER BY order_month;

-- =============================================================
-- 3. Cumulative and Moving Average Analysis (Yearly)
-- =============================================================
SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM (
    SELECT 
        DATETRUNC(YEAR, order_date) AS order_date,
        SUM(sales) AS total_sales,
        AVG(sales_price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(YEAR, order_date)
) AS t;

-- =============================================================
-- 4. Product Performance Analysis (Year-over-Year & Average)
-- =============================================================
WITH yearly_product_sales AS (
    SELECT 
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_price) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
)
SELECT 
    order_year,
    product_name,
    current_sales,
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_year_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS yoy_difference,
    CASE   
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase' 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change' 
    END AS yoy_trend,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_from_avg,
    CASE   
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average' 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
        ELSE 'At Average'
    END AS avg_comparison
FROM yearly_product_sales
ORDER BY product_name, order_year;

-- =============================================================
-- 5. Part-to-Whole Analysis (Sales Share by Category)
-- =============================================================
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_price) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    GROUP BY p.category
)
SELECT 
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    CONCAT(ROUND(CAST(total_sales AS FLOAT) / SUM(total_sales) OVER () * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;

-- =============================================================
-- 6. Product Segmentation by Cost Range
-- =============================================================
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

-- =============================================================
-- 7. Customer Segmentation by Behavior (VIP, Regular, New)
-- =============================================================
WITH customer_spending AS (
    SELECT 
        c.customer_key,
        SUM(f.sales_price) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT
    customer_segment,
    COUNT(customer_key) AS customer_count
FROM (
    SELECT
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segments
GROUP BY customer_segment;

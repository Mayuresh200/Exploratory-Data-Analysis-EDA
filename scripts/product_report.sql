/* ============================================================================
   Script: Product Report for Dashboarding
   Author: Mayuresh Chourikar
   Project: SQL Data Warehouse

   Purpose:
   This report consolidates key product-level metrics for use in dashboards 
   and business analysis. It helps identify product performance, profitability, 
   and engagement trends across categories and customer segments.

   Highlights:
   - Retrieves essential product details (name, category, subcategory, cost)
   - Segments products into performance tiers: High, Mid, Low
   - Calculates:
     * Total Orders
     * Total Sales
     * Total Quantity Sold
     * Unique Customers
     * Lifespan in Months
     * Recency (months since last sale)
     * Average Order Revenue (AOR)
     * Average Monthly Revenue

   Usage:
   - Create this view before using Power BI or other BI tools
   - Supports product-level visuals, filters, KPI indicators, and trend analysis
============================================================================ */

USE DataWarehouse;
GO

-- Drop view if it already exists
IF OBJECT_ID('gold.product_report', 'V') IS NOT NULL
    DROP VIEW gold.product_report;
GO

CREATE VIEW gold.product_report AS
-- Step 1: Extract product-related transactional data
WITH product_base_query AS (
    SELECT 
        f.order_number,
        f.customer_key,
        f.order_date,
        f.sales_price,
        f.sales_quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

-- Step 2: Aggregate metrics at the product level
product_aggregations AS (
    SELECT 
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_price) AS total_sales,
        SUM(sales_quantity) AS total_quantity,
        COUNT(DISTINCT customer_key) AS total_customers,
        MAX(order_date) AS last_sale_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        ROUND(AVG(CAST(sales_price AS FLOAT) / NULLIF(sales_quantity, 0)), 2) AS average_cost
    FROM product_base_query
    GROUP BY 
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

-- Step 3: Enrich and finalize the report view
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,

    -- Product segmentation by total sales
    CASE 
        WHEN total_sales > 50000 THEN 'High-Performers'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performers'
    END AS product_segment,

    average_cost,
    total_customers,
    total_orders,
    total_sales,
    total_quantity,
    last_sale_date,

    -- Recency in months since last sale
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,

    -- Average Order Revenue (AOR)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM product_aggregations;
GO

-- Preview the product report
SELECT * FROM gold.product_report;

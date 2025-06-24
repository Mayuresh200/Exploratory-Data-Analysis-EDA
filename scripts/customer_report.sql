/* ============================================================================
   Script: Customer Report for Dashboarding
   Author: Mayuresh Chourikar
   Project: SQL Data Warehouse

   Purpose:
   This report consolidates key customer metrics from the Gold Layer to provide 
   a single, aggregated view per customer. It supports dynamic segmentation 
   and KPI analysis in Power BI or other BI tools.

   Highlights:
   - Extracts demographic and transactional information
   - Segments customers by age group and engagement level
   - Calculates:
     * Total Orders
     * Total Sales
     * Total Quantity Purchased
     * Number of Distinct Products
     * Lifespan (in months)
     * Recency (months since last order)
     * Average Order Value (AOV)
     * Average Monthly Spend

   Usage:
   - Create this view in the database before connecting to Power BI
   - Use for customer-level charts, segmentation filters, and KPI cards
============================================================================ */

USE DataWarehouse;
GO

CREATE VIEW gold.report_customers AS
WITH base_query AS (
    -- Step 1: Retrieve core transactional and customer columns
    SELECT 
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_price,
        f.sales_quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
),
customer_aggregation AS (
    -- Step 2: Aggregate metrics at the customer level
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_price) AS total_sales,
        SUM(sales_quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)

-- Step 3: Enrich with KPIs and Segments
SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,

    -- Age Group Classification
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,

    -- Customer Segment Classification
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    -- Engagement Metrics
    last_order_date,
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,

    -- KPIs
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,

    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend

FROM customer_aggregation;
GO

-- Preview the report output
SELECT * FROM gold.report_customers;

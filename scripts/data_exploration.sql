/* ============================================================================
   Script: EDA_DataWarehouse.sql
   Author: Mayuresh Chourikar
   Project: SQL Data Warehouse
   Purpose:
     - Perform exploratory data analysis (EDA) on the Gold Layer of the data warehouse.
     - Understand the structure, volume, and high-level insights from customer, product,
       and sales data.

   Usage:
     - Run this script after the Gold Layer views are created and populated.
     - Useful for data profiling, summary reporting, and early-stage analysis
       before building dashboards or ML models.

   Key Insights:
     - Dataset date range and completeness
     - Unique value distribution (countries, categories)
     - Total counts and aggregates for sales, orders, products, customers
     - Business metrics overview in a compact union query
============================================================================ */

-- =============================================================
-- Explore database structure
-- =============================================================

-- List all objects in the database
SELECT * 
FROM INFORMATION_SCHEMA.TABLES;

-- List all columns in the 'dim_customers' table
SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

-- =============================================================
-- Dimension Exploration
-- =============================================================

-- Distinct countries represented in customer data
SELECT DISTINCT country 
FROM gold.dim_customers;

-- Distinct product categories and subcategories
SELECT DISTINCT 
    category, 
    subcategory, 
    product_name 
FROM gold.dim_products
ORDER BY category, subcategory, product_name;

-- =============================================================
-- Temporal Data Exploration
-- =============================================================

-- Find the first and last order dates
SELECT
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order 
FROM gold.fact_sales;

-- Determine how many years and months of sales data are available
SELECT
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS sales_years,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS sales_months
FROM gold.fact_sales;

-- Find the youngest and oldest customers
SELECT
    MIN(birthdate) AS oldest_bday,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
    MAX(birthdate) AS youngest_bday,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;

-- =============================================================
-- Measure Exploration
-- =============================================================

-- View raw fact table (limit if needed for inspection)
SELECT TOP 100 * FROM gold.fact_sales;

-- Total sales
SELECT SUM(sales) AS total_sales 
FROM gold.fact_sales;

-- Total quantity sold
SELECT SUM(sales_quantity) AS total_quantity 
FROM gold.fact_sales;

-- Average selling price
SELECT AVG(sales_price) AS avg_selling_price 
FROM gold.fact_sales;

-- Total number of orders
SELECT COUNT(DISTINCT order_number) AS total_orders 
FROM gold.fact_sales;

-- Total number of unique products
SELECT COUNT(DISTINCT product_name) AS total_products 
FROM gold.dim_products;

-- Total number of product entries in fact table
SELECT COUNT(product_key) AS total_products_fact 
FROM gold.fact_sales;

-- Total number of customers
SELECT COUNT(DISTINCT customer_key) AS total_customers 
FROM gold.dim_customers;

-- Total number of customers who have placed orders
SELECT COUNT(DISTINCT customer_key) AS customers_with_orders 
FROM gold.fact_sales;

-- =============================================================
-- Summary Report of Key Business Metrics
-- =============================================================

SELECT 'Total Sales'       AS measure_name, SUM(sales)          AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity'    AS measure_name, SUM(sales_quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price'     AS measure_name, AVG(sales_price)    AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders'      AS measure_name, COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products'    AS measure_name, COUNT(DISTINCT product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Customers'   AS measure_name, COUNT(DISTINCT customer_key) FROM gold.dim_customers;

# 🧠 Exploratory Data Analysis using SQL

This project focuses on answering real-world business questions through structured SQL queries executed on a dimensional Data Warehouse built with a star schema. It aims to extract meaningful insights about customer behavior, product performance, sales trends, and revenue contribution.

---

## 🔍 Project Overview

- **Database:** `sql-data-warehouse-project`
- **Layers Used:** Gold Layer (Final Reporting Layer)
- **Tools:** Microsoft SQL Server (T-SQL)
- **Schema Type:** Star Schema (Fact and Dimension tables)
- **Methodology:** Business questions → SQL Queries → Insights → Strategy

---

## 📌 Key Analysis Areas

### 📊 Sales and Performance
- **Analyzed total and monthly sales over 5 years**
- **Calculated running totals and moving averages**
- **Performed YoY and average product performance comparison**

### 💰 Revenue and Contribution
- **Identified top-performing categories like Bikes (96%+ of revenue)**
- **Measured individual customer contributions and revenue gaps**
- **Calculated category-wise revenue share using proportional analysis**

### 🧑 Customer Behavior
- **Segmented customers into VIP, Regular, and New based on spend/lifespan**
- **Identified customer distributions across countries, genders, and age groups**
- **Ranked customers by sales contribution and order volume**

### 📦 Product Insights
- **Grouped products into cost and revenue tiers**
- **Determined the most and least profitable products**
- **Mapped subcategory performance and high-revenue drivers**

---

## 💡 Sample Insights

- 📈 **2013 was the highest revenue year**, contributing over 50% of all recorded sales.
- 🌍 **Most customers are from the US and Australia**, but Germany and France show higher revenue per customer.
- 🧓 **Majority of customers are aged 30-49**, signaling a target demographic.
- 🚲 **Bikes account for 96%+ of all revenue**, highlighting a product dependency.
- 🛍️ **Low-performing products** often belong to Accessories or Clothing with low volume and low sales.

---

## 📄 What’s Inside?

- `data_exploration.sql` – All EDA queries structured by topic
- `Trend_analysis.sql` – Analysis of trends in Business
- `Business_Questions_Reporting.sql` – Business questions + queries

---

## 📈 Why This Matters

This EDA bridges raw data and strategic thinking. It prepares a clean foundation for:

- Power BI dashboarding
- Business strategy suggestions
- Data storytelling in stakeholder reports



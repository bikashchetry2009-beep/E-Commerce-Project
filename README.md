E-Commerce Marketplace Analytics
📌 Project Overview

E-Commerce Marketplace Analytics is an end-to-end SQL data analytics project built using Microsoft SQL Server. The project analyzes an e-commerce marketplace dataset to uncover insights into customers, products, sellers, orders, payments, shipments, and sales performance.

All raw data is organized within a single bronze schema and analyzed using SQL to solve real-world business problems.

🎯 Project Objectives

The main objectives of this project are to:

Explore and understand e-commerce data
Analyze customer purchasing behavior
Identify top-performing products
Evaluate seller performance
Analyze order trends and order status
Calculate revenue and sales metrics
Analyze payment methods and transactions
Evaluate shipping and delivery performance
Analyze product categories and departments
Solve complex business problems using advanced SQL
🏗️ Project Architecture
                 CSV DATA
                    │
                    ▼
          ┌──────────────────┐
          │  Microsoft SQL   │
          │      Server      │
          └────────┬─────────┘
                   │
                   ▼
            ┌─────────────┐
            │   BRONZE    │
            │   SCHEMA    │
            └──────┬──────┘
                   │
       ┌───────────┼───────────┐
       │           │           │
       ▼           ▼           ▼
  Customers    Products     Sellers
       │           │           │
       └───────────┼───────────┘
                   │
       ┌───────────┼───────────┐
       ▼           ▼           ▼
    Orders     Payments    Shipments
       │
       ▼
 Order Items
       │
       ▼
 Categories
       │
       ▼
   SQL Analysis
       │
       ▼
 Business Insights
🗂️ Database Tables

The project contains 8 tables, all stored under the bronze schema.

Table	Description
bronze.customers	Customer information and demographic details
bronze.products	Product details, pricing, and product information
bronze.sellers	Seller information and seller details
bronze.orders	Customer order information and order status
bronze.order_items	Individual products, quantities, prices, discounts, and taxes within orders
bronze.payments	Payment transactions and payment information
bronze.categories	Product categories and departments
bronze.shipments	Shipping and delivery information for orders
🔗 Data Relationships

The tables are connected through common keys such as:

Customers
    │
    │ customer_id
    ▼
Orders
    │
    │ order_id
    ▼
Order_Items
    │
    ├── product_id ──► Products
    │                     │
    │                     └── category_id ──► Categories
    │
    └── seller_id ───► Sellers

Orders
    │
    ├──► Payments
    │
    └──► Shipments

These relationships allow the project to perform analysis across customers, orders, products, sellers, payments, categories, and shipments.

🔄 ETL Process

The project follows a basic ETL workflow.

1. Extract

Raw e-commerce data is provided in CSV files.

2. Transform

SQL is used to:

Validate data
Standardize data types
Handle missing values
Identify duplicate records
Clean inconsistent data
Create calculated metrics
Validate relationships between tables
3. Load

The datasets are loaded into Microsoft SQL Server under the bronze schema.

🛠️ Technologies Used
Microsoft SQL Server
SQL Server Management Studio (SSMS)
T-SQL
CSV
ETL
Data Analysis
🧠 SQL Concepts Used

The project covers SQL concepts from basic to advanced levels.

Basic SQL
SELECT
WHERE
ORDER BY
GROUP BY
HAVING
DISTINCT
TOP
CASE WHEN
Intermediate SQL
INNER JOIN
LEFT JOIN
Subqueries
Aggregate Functions
Date Functions
Conditional Aggregation
Advanced SQL
CTEs
Window Functions
ROW_NUMBER()
DENSE_RANK()
LAG()
LEAD()
Running Totals
Moving Averages
Ranking Analysis
Percentage Calculations
📊 Business Analysis
👥 Customer Analytics

The project analyzes:

Total customers
Customer spending
Average customer spending
Top-spending customers
Repeat customers
Customer order frequency
Customer segmentation
Customer purchasing patterns
Example Business Question

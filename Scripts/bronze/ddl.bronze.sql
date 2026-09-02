/*
==============================================================================
DDL Script: Create bronze Tables
==============================================================================
Script Purpose:
	This Script creates tables in the 'bronze' schema,dropping existing tables 
	if they already exist.
	Run this script to re-define the DDL structure of 'bronze' Tables
==============================================================================
*/

IF OBJECT_ID('bronze.categories', 'U') IS NOT NULL
DROP TABLE bronze.categories;
CREATE TABLE bronze.categories
(
category_id INT,
category_name VARCHAR(50),
department VARCHAR(50)
)
;

IF OBJECT_ID('bronze.customers', 'U') IS NOT NULL
DROP TABLE bronze.customers;
CREATE TABLE bronze.customers
(
customer_id INT,
customer_name VARCHAR(50),
gender VARCHAR(50),
age INT,
city VARCHAR(50),
state VARCHAR(50),
signup_date DATE,
customer_segment VARCHAR(50)

);

IF OBJECT_ID('bronze.order_items', '') IS NOT NULL
DROP TABLE bronze.order_items;
CREATE TABLE bronze.order_items
(
order_item_id INT,
order_id INT,
product_id INT,
seller_id INT,
quantity INT,
unit_price FLOAT,
discount FLOAT,
tax FLOAT,
line_total FLOAT
);


IF OBJECT_ID('bronze.orders', 'U') IS NOT NULL
DROP TABLE bronze.orders;
CREATE TABLE bronze.orders
(
order_id INT,
customer_id INT,
order_date DATE,
order_status VARCHAR(50),
shipping_city VARCHAR(50),
shipping_state VARCHAR(50),
total_amount FLOAT
);

IF OBJECT_ID('bronze.payments', 'U') IS NOT NULL
DROP TABLE bronze.payments;
CREATE TABLE bronze.payments
(
payment_id INT,
order_id INT,
payment_date DATE,
payment_method VARCHAR(50),
payment_amount FLOAT,
payment_status VARCHAR(50),
transaction_id VARCHAR(50)
);


IF OBJECT_ID('bronze.products', 'U') IS NOT NULL
DROP TABLE bronze.products;
CREATE TABLE bronze.products
(
product_id INT,
product_name VARCHAR(50),
category_id INT,
barnd VARCHAR(50),
cost_price FLOAT,
selling_price FLOAT,
weight_kg FLOAT
);

IF OBJECT_ID('bronze.sellers', 'U') IS NOT NULL
DROP TABLE bronze.sellers;
CREATE TABLE bronze.sellers
(
seller_id INT,
seller_name VARCHAR(50),
city VARCHAR(50),
state VARCHAR(50),
seller_rating FLOAT,
join_date DATE
);

IF OBJECT_ID('bronze.shipments', 'U') IS NOT NULL
DROP TABLE bronze.shipments;
CREATE TABLE bronze.shipments
(
shipment_id INT,
order_id INT,
seller_id INT,
shipping_date DATE,
expected_delivery_date DATE,
actual_delivery_date DATE,
shipping_method VARCHAR(50),
shipping_cost FLOAT,
deliver_status VARCHAR(50)
);

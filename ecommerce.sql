CREATE TABLE customers (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix INT,
    customer_city TEXT,
    customer_state TEXT
);
CREATE TABLE orders (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);
CREATE TABLE products (
    product_id TEXT,
    product_category_name TEXT,
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);
CREATE TABLE sellers (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city TEXT,
    seller_state TEXT
);
CREATE TABLE order_items (
    order_id TEXT,
    order_item_id INT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2)
);
CREATE TABLE payments (
    order_id TEXT,
    payment_sequential INT,
    payment_type TEXT,
    payment_installments INT,
    payment_value NUMERIC(10,2)
);
CREATE TABLE reviews (
    review_id TEXT,
    order_id TEXT,
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM reviews;
SELECT COUNT(*) FROM sellers;

CREATE TABLE master_orders AS
SELECT o.order_id, o.order_purchase_timestamp, o.order_status,
       c.customer_id,c.customer_city,c.customer_state,
	   oi.product_id,oi.seller_id,oi.price,oi.freight_value,
	   p.payment_value,p.payment_type,
	   r.review_score,
	   pr.product_category_name
FROM orders o
LEFT JOIN customers c on o.customer_id= c.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id 
LEFT JOIN payments p ON o.order_id = p.order_id 
LEFT JOIN reviews r ON o.order_id = r.order_id 
LEFT JOIN products pr ON oi.product_id = pr.product_id;

ALTER TABLE master_orders ADD COLUMN order_date DATE, ADD COLUMN order_month TEXT,ADD COLUMN revenue NUMERIC;
UPDATE master_orders
SET
order_date = DATE(order_purchase_timestamp),
order_month = TO_CHAR(order_purchase_timestamp, 'YYYY-MM'),
revenue = price + freight_value;

SELECT order_id, order_month, revenue
FROM master_orders
LIMIT 5;
'''Total Revenue'''
SELECT ROUND(SUM(revenue),2) as total_revenue
from master_orders;
'''Total order'''
SELECT COUNT(DISTINCT order_id) as total_orders
from master_orders;
'''total_customers'''
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM master_orders;
'''average order value'''
SELECT ROUND(SUM(revenue)/COUNT(DISTINCT order_id),2) AS AOV
FROM master_orders;
'''average review score'''
SELECT ROUND(AVG(review_score), 2) AS avg_review_score
FROM master_orders;
'''Monthly Revenue Trend'''
SELECT 
order_month,
ROUND(SUM(revenue),2) AS monthly_revenue,
COUNT(DISTINCT order_id) AS monthly_orders
FROM master_orders
GROUP BY order_month
ORDER BY order_month;
'''TOP PERFORMING PRODUCT CATEGORIES'''
SELECT
product_category_name,
ROUND(SUM(revenue),2) AS total_revenue
FROM master_orders
GROUP BY product_category_name
ORDER BY total_revenue DESC
LIMIT 10;
'''TOP STATES BY REVENUE'''
SELECT
customer_state,
ROUND(SUM(revenue),2) AS total_revenue
FROM master_orders
GROUP BY customer_state
ORDER BY total_revenue DESC;
'''PAYMENT METHOD ANALYSIS'''
SELECT
COALESCE(payment_type, 'Not Available') AS payment_type,
COUNT(*) AS total_transactions,
ROUND(COALESCE(SUM(payment_value),0),2) AS total_payment
FROM master_orders
GROUP BY COALESCE(payment_type, 'Not Available')
ORDER BY total_payment DESC;
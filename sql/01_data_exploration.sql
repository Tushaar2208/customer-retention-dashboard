/* ============================================================
   DATA EXPLORATION
============================================================ */

/* Order status distribution */
SELECT 
    order_status,
    COUNT(*) AS count
FROM raw_data.orders
GROUP BY order_status
ORDER BY count DESC;


/* Repeat customer frequency (delivered orders only) */
SELECT 
    customer_unique_id,
    COUNT(*) AS order_count
FROM raw_data.customers
JOIN raw_data.orders 
    ON customers.customer_id = orders.customer_id
WHERE order_status = 'delivered'
GROUP BY customer_unique_id
ORDER BY order_count DESC;


/* Total number of reviews */
SELECT 
    COUNT(*) 
FROM raw_data.order_reviews;
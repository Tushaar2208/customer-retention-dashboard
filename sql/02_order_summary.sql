/* ============================================================
 CREATE ORDER SUMMARY TABLE
 ============================================================ */
DROP TABLE IF EXISTS order_summary;
CREATE TABLE order_summary AS WITH order_cost AS (
    SELECT order_items.order_id,
        SUM(order_items.price + order_items.freight_value) AS total_cost
    FROM raw_data.order_items
    GROUP BY order_items.order_id
),
order_reviews AS (
    SELECT order_reviews.order_id,
        AVG(order_reviews.review_score) AS average_review_score
    FROM raw_data.order_reviews
    GROUP BY order_reviews.order_id
)
SELECT orders.order_id,
    COALESCE(order_cost.total_cost, 0) AS total_cost,
    COALESCE(order_reviews.average_review_score, 0) AS average_review_score,
    orders.customer_id,
    orders.order_purchase_timestamp
FROM raw_data.orders
    LEFT JOIN order_reviews ON orders.order_id = order_reviews.order_id
    LEFT JOIN order_cost ON orders.order_id = order_cost.order_id
WHERE orders.order_status = 'delivered';
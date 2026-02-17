/* ============================================================
 CREATE CUSTOMER SUMMARY TABLE
 ============================================================ */
DROP TABLE IF EXISTS customer_summary;
CREATE TABLE customer_summary AS WITH customer_orders AS (
    SELECT order_summary.order_id,
        customers.customer_unique_id,
        order_summary.order_purchase_timestamp,
        order_summary.total_cost,
        ROW_NUMBER() OVER (
            PARTITION BY customers.customer_unique_id
            ORDER BY order_summary.order_purchase_timestamp ASC
        ) AS purchase_number
    FROM order_summary
        JOIN raw_data.customers ON order_summary.customer_id = customers.customer_id
)
SELECT customer_unique_id,
    SUM(total_cost) AS lifetime_value,
    COUNT(*) AS total_orders,
    MIN(
        CASE
            WHEN purchase_number = 1 THEN order_purchase_timestamp
        END
    ) AS first_purchase,
    MIN(
        CASE
            WHEN purchase_number = 2 THEN order_purchase_timestamp
        END
    ) AS second_purchase,
    CASE
        WHEN COUNT(*) > 1 THEN TRUE
        ELSE FALSE
    END AS repeat_customer,
    CASE
        WHEN COUNT(*) > 1 THEN EXTRACT(
            DAY
            FROM (
                    MIN(
                        CASE
                            WHEN purchase_number = 2 THEN order_purchase_timestamp
                        END
                    ) - MIN(
                        CASE
                            WHEN purchase_number = 1 THEN order_purchase_timestamp
                        END
                    )
                )
        )
        ELSE NULL
    END AS gap_between_purchases
FROM customer_orders
GROUP BY customer_unique_id;
CREATE VIEW cache.fact_sales AS
SELECT 
    sd.sls_ord_num AS order_number,
    dp.product_key,
    dc.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS ship_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM staging.crm_sales_details AS sd
LEFT JOIN cache.dim_customer AS dc
    ON dc.customer_id = sd.sls_cust_id
LEFT JOIN cache.dim_product AS dp
    ON dp.product_number = sd.sls_prd_key

-- Insert cleaned and validated sales data into the target table 'stagecache.crm_sales_details'
INSERT INTO stagecache.crm_sales_details
(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    
    -- Validate and convert order date:
    -- If the date length is not exactly 8 characters (YYYYMMDD), set it to NULL.
    -- Otherwise, cast the string to a DATE type.
    CASE
        WHEN LEN(sls_order_dt) <> 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,
    
    -- Validate and convert ship date:
    CASE
        WHEN LEN(sls_ship_dt) <> 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,
    
    -- Validate and convert due date:
    CASE
        WHEN LEN(sls_due_dt) <> 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,
    
    -- Ensure sales amount is positive and consistent with quantity * price:
    -- If sales is missing, non-positive, or mismatched, recalculate.
    CASE
        WHEN sls_sales IS NULL 
             OR sls_sales <= 0 
             OR sls_sales <> sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE ABS(sls_sales)
    END AS sls_sales,
    
    sls_quantity,
    
    -- Validate price:
    -- If NULL or negative/zero, derive price from sales/quantity.
    -- Otherwise, take the absolute value.
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0 
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE ABS(sls_price)
    END AS sls_price

FROM staging.crm_sales_details;  -- Source table for raw sales data

/* --------------------------------------------------------------------
      DIM_CUSTOMER – Customer dimension view
   -------------------------------------------------------------------- */

/* If the view already exists, remove it so we can recreate it.  */
DROP VIEW IF EXISTS cache.dim_customer;
GO

CREATE VIEW cache.dim_customer AS
SELECT
    /* Surrogate key – deterministic for every refresh */
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,

    /* Natural / source keys */
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,

    /* Personal attributes */
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,

    /* Location – country */
    la.cntry AS country,

    /* Demographics */
    ci.cst_marital_status AS marital_status,

    /* Gender – prefer source value, fallback to ERP value */
    CASE
        WHEN ci.cst_gndr = 'n/a' THEN ISNULL(ca.gen,'n/a')
        ELSE ci.cst_gndr
    END AS gender,

    /* Birth date – from ERP table */
    ca.bdate AS birth_date,

    /* When the record was created */
    ci.cst_create_date AS create_date
FROM stagecache.crm_cust_info AS ci
LEFT JOIN stagecache.erp_cust_az12 AS ca
        ON ci.cst_key = ca.cid
LEFT JOIN stagecache.erp_loc_a101 AS la
        ON ci.cst_key = la.cid;
GO


/* --------------------------------------------------------------------
      DIM_PRODUCT – Product dimension view
   -------------------------------------------------------------------- */

/* Drop if the view already exists */
DROP VIEW IF EXISTS cache.dim_product;
GO

CREATE VIEW cache.dim_product AS
SELECT
    /* Surrogate key – deterministic on start date + product ID */
    ROW_NUMBER() OVER (ORDER BY pr.prd_start_dt, pr.prd_id)  AS product_key,

    /* Natural / source keys */
    pr.prd_id AS product_id,
    pr.prd_key AS product_number,

    /* Descriptive columns */
    pr.prd_nm AS product_name,
    pr.cat_id AS category_id,               -- FK to category
    pc.cat AS category,                     -- Category name
    pc.subcat AS sub_category,              -- Sub‑category name
    pc.maintenance AS maintenance,          -- Maintenance flag
    pr.prd_cost AS cost,
    pr.prd_line AS product_line,

    /* Validity period */
    pr.prd_start_dt AS start_date
FROM stagecache.crm_prd_info AS pr
LEFT JOIN stagecache.erp_px_cat_g1v2 AS pc
        ON pr.cat_id = pc.id
WHERE pr.prd_end_dt IS NULL;                -- Keep only active products
GO


/* --------------------------------------------------------------------
      FACT_SALES – Sales fact view
   -------------------------------------------------------------------- */

/* Drop if the view already exists */
DROP VIEW IF EXISTS cache.fact_sales;
GO

CREATE VIEW cache.fact_sales AS
SELECT
    /* Order header info */
    sd.sls_ord_num AS order_number,         -- CRM order number
    sd.sls_order_dt AS order_date,          -- Order date
    sd.sls_ship_dt AS ship_date,            -- Ship date
    sd.sls_due_dt AS due_date,              -- Invoice due date

    /* Dimension surrogate keys */
    dp.product_key AS product_key,          -- From dim_product
    dc.customer_key AS customer_key,        -- From dim_customer

    /* Sales metrics */
    sd.sls_sales AS sales_amount,           -- Total line amount
    sd.sls_quantity AS quantity,            -- Units sold
    sd.sls_price AS price                   -- Unit price
FROM staging.crm_sales_details AS sd

/* Join to customer dimension – keeps all sales lines even if customer
   missing in the dimension. */
LEFT JOIN cache.dim_customer AS dc
        ON dc.customer_id = sd.sls_cust_id

/* Join to product dimension – keeps all sales lines even if product
   missing in the dimension. */
LEFT JOIN cache.dim_product   AS dp
        ON dp.product_number = sd.sls_prd_key;
GO

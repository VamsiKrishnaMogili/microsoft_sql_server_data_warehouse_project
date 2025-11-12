/* --------------------------------------------------------------------
   VIEW: cache.dim_customer
   --------------------------------------------------------------------
   Purpose
   -------
   Build a customer dimension table for analytics.  
   The view pulls data from three staging tables, normalises the
   gender value, and creates a surrogate key (`customer_key`) that
   can be used as a primary key in downstream reporting models.

   Key points
   ----------
   1. **ROW_NUMBER()** generates a stable surrogate key.  
      It is ordered by the source primary key (`cst_id`) so that
      the key is deterministic across refreshes.
   2. **LEFT JOINs** keep all rows from `crm_cust_info` even if
      the customer has no matching record in the ERP tables.
   3. **Gender logic**:  
      - If `crm_cust_info.cst_gndr` is 'n/a', look for a real
        gender value in the ERP table (`erp_cust_az12.gen`).  
      - Otherwise, keep the source value.  
      The `ISNULL` call guarantees we never return a NULL gender.
   4. Columns are renamed to more friendly names for reporting.
   --------------------------------------------------------------------*/
CREATE VIEW cache.dim_customer AS
SELECT
    /* Surrogate key for the dimension */
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,

    /* Natural key from the source system */
    ci.cst_id AS customer_id,

    /* Alternate key / customer reference number */
    ci.cst_key AS customer_number,

    /* Personal details */
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,

    /* Location data – comes from the ERP location table */
    la.cntry AS country,

    /* Demographic data */
    ci.cst_marital_status AS marital_status,

    /* Resolve gender – prefer source, fallback to ERP value */
    CASE
        WHEN ci.cst_gndr = 'n/a' THEN ISNULL(ca.gen,'n/a')
        ELSE ci.cst_gndr
    END AS gender,

    /* Birth date – from the ERP customer table */
    ca.bdate AS birth_date,

    /* When the customer record was created in the source */
    ci.cst_create_date AS create_date
FROM stagecache.crm_cust_info AS ci          	-- base customer table
LEFT JOIN stagecache.erp_cust_az12 AS ca        -- ERP customer details
    ON ci.cst_key = ca.cid
LEFT JOIN stagecache.erp_loc_a101 AS la        	-- ERP location / country
    ON ci.cst_key = la.cid;

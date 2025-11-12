/* --------------------------------------------------------------------
   VIEW:  cache.dim_product
   --------------------------------------------------------------------
   Purpose
   -------
   Build a product dimension table that can be joined to fact tables
   in a data warehouse or BI layer.  The view exposes both the
   business‑key attributes from the source (CRM) and the descriptive
   hierarchy from the ERP catalogue.  A surrogate key is created
   with ROW_NUMBER() so that each row can be referenced by a
   stable integer.

   Key design decisions
   --------------------
   1. **Surrogate key** – ROW_NUMBER() is ordered by
      product start date and then product ID so that the key is
      deterministic across refreshes.
   2. **LEFT JOIN** – keeps every active product even if it has no
      corresponding category record in the ERP catalogue.
   3. **Active‑only filter** – the WHERE clause keeps only products
      whose `prd_end_dt` is NULL (i.e. currently active).
   4. **Column renaming** – friendly column names are chosen for
      downstream reporting (e.g. `product_name`, `category`,
      `sub_category`, `cost`).

   --------------------------------------------------------------------*/
CREATE VIEW cache.dim_product AS
SELECT
    /* Surrogate key for the dimension */
    ROW_NUMBER() OVER (ORDER BY pr.prd_start_dt, pr.prd_id)  AS product_key,

    /* Business keys (source system identifiers) */
    pr.prd_id AS product_id,
    pr.prd_key AS product_number,

    /* Descriptive attributes */
    pr.prd_nm AS product_name,
    pr.cat_id AS category_id,               -- FK to category
    pc.cat AS category,                     -- Category name
    pc.subcat AS sub_category,              -- Sub‑category name
    pc.maintenance AS maintenance,          -- Maintenance flag
    pr.prd_cost AS cost,
    pr.prd_line AS product_line,

    /* Validity period */
    pr.prd_start_dt AS start_date
FROM stagecache.crm_prd_info AS pr          -- Core product table
LEFT JOIN stagecache.erp_px_cat_g1v2 AS pc  -- Category & hierarchy table
    ON pr.cat_id = pc.id
WHERE pr.prd_end_dt IS NULL;                -- Only active products

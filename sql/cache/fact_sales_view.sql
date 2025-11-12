/* =======================================================================
   VIEW:  cache.fact_sales
   =======================================================================
   Purpose
   -------
   Create a sales fact table that can be fed directly into an
   analytical model or BI layer.  
   Each row represents a single line item in a sales order, enriched
   with surrogate keys from the product and customer dimensions.
   The view keeps all original source columns with descriptive aliases
   so that downstream reports can reference the fact using intuitive
   names.

   Design notes
   ------------
   1. **Source table** – `staging.crm_sales_details` (alias `sd`) holds
      the raw sales lines from the CRM system.
   2. **Dimension look‑ups** – Left joins to `cache.dim_customer` and
      `cache.dim_product` bring in the surrogate keys that are
      required for star‑schema joins.  The left join guarantees that
      every sales line is kept even if the customer or product cannot
      be found in the dimension (useful for data quality audits).
   3. **Column aliases** – Each selected column is renamed to a
      friendly, business‑friendly name that matches the typical
      dimensional modelling convention (e.g. `order_number`,
      `product_key`, `customer_key`, `order_date`, etc.).
   4. **Fact keys** – This view does not create its own surrogate
      key for the fact; the natural key (`order_number`) can be used
      as the primary key, or you can add a `ROW_NUMBER()` column if
      a surrogate key is required.
   =======================================================================
*/
CREATE VIEW cache.fact_sales AS
SELECT
    /* 1. Order header information  */
    sd.sls_ord_num AS order_number,         -- Original order number from CRM
    sd.sls_order_dt AS order_date,          -- Date the order was placed
    sd.sls_ship_dt AS ship_date,            -- Scheduled or actual ship date
    sd.sls_due_dt AS due_date,              -- Invoice due date

    /* 2. Dimension surrogate keys  */
    dp.product_key AS product_key,          -- Surrogate key from dim_product
    dc.customer_key AS customer_key,        -- Surrogate key from dim_customer

    /* 3. Sales detail values  */
    sd.sls_sales AS sales_amount,           -- Total line amount (price * qty)
    sd.sls_quantity AS quantity,            -- Units sold
    sd.sls_price AS price                   -- Unit price at time of sale

FROM staging.crm_sales_details AS sd

/* 4. Join to customer dimension – keeps all sales rows even if
   the customer record is missing in the dimension. */
LEFT JOIN cache.dim_customer AS dc
    ON dc.customer_id = sd.sls_cust_id

/* 5. Join to product dimension – keeps all sales rows even if
   the product record is missing in the dimension. */
LEFT JOIN cache.dim_product   AS dp
    ON dp.product_number = sd.sls_prd_key;

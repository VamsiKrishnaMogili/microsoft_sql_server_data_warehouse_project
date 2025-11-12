/*======================================================================
  Purpose :  Drop the existing staging tables (if any) and recreate
             them with a default `dwh_load_date` column that captures
             the exact moment the table was refreshed.
             
  Notes:
  ──────
  * All tables live in the `stagecache` schema.
  * The script uses `GO` to separate batches – each `DROP` and `CREATE`
    must be a separate batch so that the `OBJECT_ID` check can run
    before the table is recreated.
  * The original script accidentally dropped `erp_cust_az12` twice;
    that has been fixed – the correct table (`erp_loc_a101`) is now
    dropped and created.
  * No primary keys or constraints are defined – add them as needed
    (e.g. `PRIMARY KEY (cst_id)` for `crm_cust_info`).
  * `dwh_load_date` defaults to `GETDATE()`.  If UTC time is required,
    use `GETUTCDATE()` instead.
======================================================================*/
USE datawarehouse;
GO


/*----------------------------------------------------------------------
     Customer Information  –  crm_cust_info
----------------------------------------------------------------------*/
IF OBJECT_ID ('stagecache.crm_cust_info','U') IS NOT NULL
    DROP TABLE stagecache.crm_cust_info;
GO

CREATE TABLE stagecache.crm_cust_info
(
    cst_id            INT           NOT NULL,   -- Surrogate key from source
    cst_key           NVARCHAR(50)  NOT NULL,   -- Natural key (customer number)
    cst_firstname     NVARCHAR(50)  NULL,
    cst_lastname      NVARCHAR(50)  NULL,
    cst_marital_status NVARCHAR(50) NULL,
    cst_gndr          NVARCHAR(50)  NULL,
    cst_create_date   DATE          NULL,
    dwh_load_date     DATETIME      DEFAULT GETDATE()   -- Load timestamp
);
GO


/*----------------------------------------------------------------------
    Product Information  –  crm_prd_info
----------------------------------------------------------------------*/
IF OBJECT_ID ('stagecache.crm_prd_info','U') IS NOT NULL
    DROP TABLE stagecache.crm_prd_info;
GO

CREATE TABLE stagecache.crm_prd_info
(
    prd_id        INT           NOT NULL,
    cat_id        NVARCHAR(50)  NULL,
    prd_key       NVARCHAR(50)  NOT NULL,
    prd_nm        NVARCHAR(50)  NULL,
    prd_cost      INT           NULL,
    prd_line      NVARCHAR(50)  NULL,
    prd_start_dt  DATE          NULL,
    prd_end_dt    DATE          NULL,
    dwh_load_date DATETIME      DEFAULT GETDATE()
);
GO


/*----------------------------------------------------------------------
    Sales Details  –  crm_sales_details
----------------------------------------------------------------------*/
IF OBJECT_ID ('stagecache.crm_sales_details','U') IS NOT NULL
    DROP TABLE stagecache.crm_sales_details;
GO

CREATE TABLE stagecache.crm_sales_details
(
    sls_ord_num   NVARCHAR(50)  NOT NULL,
    sls_prd_key   NVARCHAR(50)  NOT NULL,
    sls_cust_id   INT           NOT NULL,
    sls_order_dt  INT           NULL,
    sls_ship_dt   INT           NULL,
    sls_due_dt    INT           NULL,
    sls_sales     INT           NULL,
    sls_quantity  INT           NULL,
    sls_price     INT           NULL,
    dwh_load_date DATETIME      DEFAULT GETDATE()
);
GO


/*----------------------------------------------------------------------
    ERP Customer –  erp_cust_az12
----------------------------------------------------------------------*/
IF OBJECT_ID ('stagecache.erp_cust_az12','U') IS NOT NULL
    DROP TABLE stagecache.erp_cust_az12;
GO

CREATE TABLE stagecache.erp_cust_az12
(
    cid          NVARCHAR(50)  NOT NULL,
    bdate        DATE          NULL,
    gen          NVARCHAR(50)  NULL,
    dwh_load_date DATETIME    DEFAULT GETDATE()
);
GO


/*----------------------------------------------------------------------
    ERP Location –  erp_loc_a101
----------------------------------------------------------------------*/

IF OBJECT_ID ('stagecache.erp_loc_a101','U') IS NOT NULL
    DROP TABLE stagecache.erp_loc_a101;
GO

CREATE TABLE stagecache.erp_loc_a101
(
    cid          NVARCHAR(50)  NOT NULL,
    cntry        NVARCHAR(50)  NULL,
    dwh_load_date DATETIME    DEFAULT GETDATE()
);
GO


/*----------------------------------------------------------------------
    ERP Product Category –  erp_px_cat_g1v2
----------------------------------------------------------------------*/
IF OBJECT_ID ('stagecache.erp_px_cat_g1v2','U') IS NOT NULL
    DROP TABLE stagecache.erp_px_cat_g1v2;
GO

CREATE TABLE stagecache.erp_px_cat_g1v2
(
    id           NVARCHAR(50)  NOT NULL,
    cat          NVARCHAR(50)  NULL,
    subcat       NVARCHAR(50)  NULL,
    maintenance  NVARCHAR(50)  NULL,
    dwh_load_date DATETIME    DEFAULT GETDATE()
);
GO
/*======================================================================
  End of script
======================================================================*/

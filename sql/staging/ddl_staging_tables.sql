/*=======================================================================
  PURPOSE :  Create the raw “staging” tables that will hold the
             un‑transformed data from the source systems (CRM & ERP).
  NOTES   :
      • Each table is dropped (if it exists) before being recreated
        – this guarantees that the schema is in a clean state every
          time the script runs.
      • The script uses `GO` to separate batches so that the
        `OBJECT_ID` checks execute before the `CREATE` statements.
      • Data types are chosen to match the source columns.
        (INT for integer IDs, NVARCHAR(50) for alphanumeric keys, DATE
         for dates, and INT for numeric values that are actually
         monetary amounts or counts – consider DECIMAL for money
         if precision is required).
      • No primary keys or constraints are defined.  Add them once
        the ETL process is finalized.
=======================================================================*/

USE datawarehouse;   -- Switch to the target database
GO


/*--------------------------------------------------------------------
    CRM – Customer Information
---------------------------------------------------------------------*/
IF OBJECT_ID ('staging.crm_cust_info','U') IS NOT NULL
    DROP TABLE staging.crm_cust_info;   -- Remove any existing table
GO

CREATE TABLE staging.crm_cust_info
(
    cst_id             INT          NOT NULL,   -- Surrogate key from source
    cst_key            NVARCHAR(50) NOT NULL,   -- Natural key (customer number)
    cst_firstname      NVARCHAR(50) NULL,
    cst_lastname       NVARCHAR(50) NULL,
    cst_marital_status NVARCHAR(50) NULL,
    cst_gndr           NVARCHAR(50) NULL,
    cst_create_date    DATE         NULL        -- Source create‑date
);
GO


/*--------------------------------------------------------------------
    CRM – Product Information
---------------------------------------------------------------------*/
IF OBJECT_ID ('staging.crm_prd_info','U') IS NOT NULL
    DROP TABLE staging.crm_prd_info;
GO

CREATE TABLE staging.crm_prd_info
(
    prd_id        INT          NOT NULL,   -- Surrogate key
    prd_key       NVARCHAR(50) NOT NULL,   -- Natural product key
    prd_nm        NVARCHAR(50) NULL,       -- Product name
    prd_cost      INT          NULL,       -- Cost in base currency
    prd_line      NVARCHAR(50) NULL,       -- Line code (e.g., ‘M’, ‘R’)
    prd_start_dt  DATE         NULL,       -- Valid from
    prd_end_dt    DATE         NULL        -- Valid to (NULL = open‑ended)
);
GO


/*--------------------------------------------------------------------
    CRM – Sales Detail
---------------------------------------------------------------------*/
IF OBJECT_ID ('staging.crm_sales_details','U') IS NOT NULL
    DROP TABLE staging.crm_sales_details;
GO

CREATE TABLE staging.crm_sales_details
(
    sls_ord_num  NVARCHAR(50) NOT NULL,   -- Order number (business key)
    sls_prd_key  NVARCHAR(50) NOT NULL,   -- Product key (FK to crm_prd_info)
    sls_cust_id  INT          NOT NULL,   -- Customer key (FK to crm_cust_info)
    sls_order_dt INT          NULL,       -- Stored as YYYYMMDD – consider DATE
    sls_ship_dt  INT          NULL,       -- Same as above
    sls_due_dt   INT          NULL,       -- Same as above
    sls_sales    INT          NULL,       -- Sales amount
    sls_quantity INT          NULL,       -- Quantity sold
    sls_price    INT          NULL        -- Unit price
);
GO


/*--------------------------------------------------------------------
    ERP – Customer (AZ12)
---------------------------------------------------------------------*/
IF OBJECT_ID ('staging.erp_cust_az12','U') IS NOT NULL
    DROP TABLE staging.erp_cust_az12;
GO

CREATE TABLE staging.erp_cust_az12
(
    cid   NVARCHAR(50) NOT NULL,   -- Customer ID in ERP
    bdate DATE         NULL,       -- Birth date
    gen   NVARCHAR(50) NULL        -- Gender code
);
GO


/*--------------------------------------------------------------------
    ERP – Location (A101)
---------------------------------------------------------------------*/
IF OBJECT_ID ('staging.erp_loc_a101','U') IS NOT NULL
    DROP TABLE staging.erp_loc_a101;
GO

CREATE TABLE staging.erp_loc_a101
(
    cid   NVARCHAR(50) NOT NULL,   -- Customer ID
    cntry NVARCHAR(50) NULL        -- Country code/name
);
GO


/*--------------------------------------------------------------------
    ERP – Product Category (PX_CAT_G1V2)
---------------------------------------------------------------------*/
IF OBJECT_ID ('staging.erp_px_cat_g1v2','U') IS NOT NULL
    DROP TABLE staging.erp_px_cat_g1v2;
GO

CREATE TABLE staging.erp_px_cat_g1v2
(
    id          NVARCHAR(50) NOT NULL,   -- Category ID
    cat         NVARCHAR(50) NULL,       -- Category description
    subcat      NVARCHAR(50) NULL,       -- Sub‑category description
    maintenance NVARCHAR(50) NULL        -- Maintenance flag (Y/N)
);
GO
/*=======================================================================
  End of DDL script
=======================================================================*/

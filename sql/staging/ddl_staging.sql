/* -------------  CREATE NEW TABLES IN THE DATABASE -------------- */

-- Create new tables in the staging schema:
--   • crm_cust_info
--   • crm_prd_info
--   • crm_sales_details
--   • erp_cust_az12
--   • erp_loc_a101
--   • erp_px_cat_g1v2

/* -------------  CAUTION  ---------------------------------------- */

-- Executing this script may drop the tables if they already exist in your database.

USE datawarehouse;
GO

IF OBJECT_ID ('staging.crm_cust_info','U') IS NOT NULL
	DROP TABLE staging.crm_cust_info;
GO

CREATE TABLE staging.crm_cust_info
(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);
GO

IF OBJECT_ID ('staging.crm_prd_info','U') IS NOT NULL
	DROP TABLE staging.crm_prd_info;
GO

CREATE TABLE staging.crm_prd_info
(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE
);
GO

IF OBJECT_ID ('staging.crm_sales_details','U') IS NOT NULL
	DROP TABLE staging.crm_sales_details;
GO

CREATE TABLE staging.crm_sales_details
(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);
GO

IF OBJECT_ID ('staging.erp_cust_az12','U') IS NOT NULL
	DROP TABLE staging.erp_cust_az12;
GO

CREATE TABLE staging.erp_cust_az12
(
	cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50)
);
GO

IF OBJECT_ID ('staging.erp_loc_a101','U') IS NOT NULL
	DROP TABLE staging.erp_cust_az12;
GO

CREATE TABLE staging.erp_loc_a101
(
	cid NVARCHAR(50),
    cntry NVARCHAR(50)
);
GO

IF OBJECT_ID ('staging.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE staging.erp_px_cat_g1v2;
GO

CREATE TABLE staging.erp_px_cat_g1v2
(
	id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);
GO

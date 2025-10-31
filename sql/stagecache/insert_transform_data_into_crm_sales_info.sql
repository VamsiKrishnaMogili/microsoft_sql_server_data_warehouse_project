/*
1. Insert data into 'stagecache.crm_sales_details' by selecting from 'staging.crm_sales_details' with transformations.
2. Validate and convert date fields (order, ship, due) from 8-character strings to DATE, else set NULL.
3. Calculate sales and price: Recalculate sales if NULL/invalid, and set price as sales divided by quantity if missing or invalid.
*/

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
	CASE
		WHEN LEN(sls_order_dt) <> 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE
		WHEN LEN(sls_ship_dt) <> 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
	CASE
		WHEN LEN(sls_due_dt) <> 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	CASE
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales <> sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
		ELSE ABS(sls_sales)
	END AS sls_sales,
	sls_quantity,
	CASE
		WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales/NULLIF(sls_quantity,0)
		ELSE ABS(sls_price)
	END AS sls_price
FROM staging.crm_sales_details

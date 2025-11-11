CREATE VIEW cache.dim_customer AS

SELECT
	ROW_NUMBER () OVER (ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr = 'n/a' THEN ISNULL(ca.gen,'n/a')
		ELSE ci.cst_gndr
	END AS gender,
	ca.bdate AS birth_date,
	ci.cst_create_date AS create_date
FROM stagecache.crm_cust_info AS ci
LEFT JOIN stagecache.erp_cust_az12 AS ca
	ON ci.cst_key = ca.cid
LEFT JOIN stagecache.erp_loc_a101 AS la
	ON ci.cst_key = la.cid

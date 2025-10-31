/*
1. Insert data into 'stagecache.crm_prd_info' by selecting and transforming records from 'staging.crm_prd_info'.
2. Transformations include trimming strings, replacing characters in product keys, categorizing product lines, and handling NULL costs.
3. Calculate 'prd_end_dt' as one day before the next product's start date per product key, using the LEAD window function.
*/

INSERT INTO stagecache.crm_prd_info
(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)

SELECT
	prd_id,
	REPLACE(SUBSTRING(TRIM(prd_key),1,5),'-','_') AS cat_id,
	SUBSTRING(TRIM(prd_key),7,LEN(TRIM(prd_key))) AS prd_key,
	TRIM(prd_nm) AS prd_nm,
	ISNULL(prd_cost,0) AS prd_cost,
	CASE 
		WHEN prd_line = 'M' THEN 'Mountain'
		WHEN prd_line = 'R' THEN 'Road'
		WHEN prd_line = 'S' THEN 'Sport'
		WHEN prd_line = 'T' THEN 'Touring'
		ELSE 'Others'
	END AS prd_line,
	prd_start_dt,
	DATEADD(DAY,-1,LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
FROM staging.crm_prd_info

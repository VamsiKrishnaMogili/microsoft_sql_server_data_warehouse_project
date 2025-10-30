/*

------------------------------ Identifies the latest record for each customer ---------------------------------------------

- A derived‑table (t) adds a ROW_NUMBER() column partitioned by cst_id and ordered by cst_create_date DESC. 
- Rows where that number is  1 (the newest per customer) are kept, after filtering out any rows with a null or empty cst_id.

------------------------------ Cleans and normalises the data before insertion ---------------------------------------------

- Trims whitespace from first‑ and last‑name fields.
- Translates marital‑status codes (M, S) to full words (“Married”, “Single”) or “n/a”.
- Translates gender codes (M, F) to “Male”, “Female” or “n/a”.
- Copies the cleaned, latest records into the target table

------------------------------ The INSERT … SELECT writes the transformed columns into stagecache.crm_cust_info. ------------

*/

INSERT INTO stagecache.crm_cust_info
(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
)

SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	ELSE 'n/a'
	END AS cst_marital_status,
	CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	ELSE 'n/a'
	END AS cst_gndr,
	cst_create_date
FROM
(
	SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS latest_data
	FROM staging.crm_cust_info
	WHERE ISNULL(cst_id,'') <> ''
) t
WHERE latest_data = 1

CREATE VIEW cache.dim_product AS

SELECT
	ROW_NUMBER() OVER (ORDER BY pr.prd_start_dt,pr.prd_id) AS product_key,
	pr.prd_id AS product_id,
	pr.prd_key AS product_number,
	pr.prd_nm AS product_name,
	pr.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS sub_category,
	pc.maintenance,
	pr.prd_cost AS cost,
	pr.prd_line AS product_line,
	pr.prd_start_dt AS start_date
FROM stagecache.crm_prd_info AS pr
LEFT JOIN stagecache.erp_px_cat_g1v2 AS pc
	on pr.cat_id = pc.id
WHERE pr.prd_end_dt IS NULL

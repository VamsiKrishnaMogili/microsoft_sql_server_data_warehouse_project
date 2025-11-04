/* Load ERP product category mappings into the stage cache */
INSERT INTO stagecache.erp_px_cat_g1v2 (id,cat,subcat,maintenance)

SELECT 
	id,
	cat,
	subcat,
	maintenance
FROM staging.erp_px_cat_g1v2

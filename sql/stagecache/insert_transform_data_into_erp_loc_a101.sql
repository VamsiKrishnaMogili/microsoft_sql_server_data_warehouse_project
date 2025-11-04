/* Load standardized ERP location records into the stage cache */
INSERT INTO stagecache.erp_loc_a101 (cid, cntry)
SELECT 
    -- Normalize customer id by removing hyphens
    REPLACE(cid, '-', '') AS cid,

    -- Normalize country:
    -- - Map 'DE' to 'Germany'
    -- - Treat NULL/blank as 'n/a'
    -- - Map 'USA' or 'US' to 'United States'
    -- - Otherwise, trim surrounding spaces and keep the value
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN ISNULL(TRIM(cntry), '') = '' THEN 'n/a'
        WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
        ELSE TRIM(cntry)
    END AS cntry
FROM staging.erp_loc_a101;

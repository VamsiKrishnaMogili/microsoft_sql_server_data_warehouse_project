/* Load curated product records into the stage cache table */
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
    /* Pass through the source product id */
    prd_id,

    /* Category: take first 5 chars of trimmed key, replace '-' with '_' to standardize */
    REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_') AS cat_id,

    /* Product key: take trimmed key from position 7 to end to drop the 'cat_id-' prefix */
    SUBSTRING(TRIM(prd_key), 7, LEN(TRIM(prd_key))) AS prd_key,

    /* Product name: strip leading/trailing whitespace */
    TRIM(prd_nm) AS prd_nm,

    /* Cost: coalesce nulls to zero to avoid null arithmetic downstream */
    ISNULL(prd_cost, 0) AS prd_cost,

    /* Map line codes to human-readable values; fall back to 'Others' for unknowns */
    CASE 
        WHEN prd_line = 'M' THEN 'Mountain'
        WHEN prd_line = 'R' THEN 'Road'
        WHEN prd_line = 'S' THEN 'Sport'
        WHEN prd_line = 'T' THEN 'Touring'
        ELSE 'Others'
    END AS prd_line,

    /* Start date: taken as-is from the source row */
    prd_start_dt,

    /* End date: next row's start date (within same normalized key) minus 1 day; open-ended if no next row */
    DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
FROM staging.crm_prd_info;

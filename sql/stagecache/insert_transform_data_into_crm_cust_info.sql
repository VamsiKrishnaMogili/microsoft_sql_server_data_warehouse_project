/* Load the latest, cleaned customer records into the stage cache table */
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
    -- Pass through identifiers and keys
    cst_id,
    cst_key,

    -- Clean names by removing leading/trailing whitespace
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname)  AS cst_lastname,

    -- Normalize marital status codes to readable values; default to 'n/a'
    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        ELSE 'n/a'
    END AS cst_marital_status,

    -- Normalize gender codes to readable values; default to 'n/a'
    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        ELSE 'n/a'
    END AS cst_gndr,

    -- Keep the create date from the selected latest record per customer
    cst_create_date
FROM
(
    /* Rank rows per customer by most recent create date to pick the latest record */
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS latest_data
    FROM staging.crm_cust_info
    WHERE ISNULL(cst_id, '') <> ''  -- Exclude rows with missing customer id
) t
WHERE latest_data = 1;               -- Keep only the most recent row per customer

CREATE OR ALTER PROCEDURE stagecache.load_stagecache
AS
BEGIN

    DECLARE @starttime DATETIME,
            @endtime DATETIME,
            @batch_start_time DATETIME,
            @batch_end_time DATETIME;
    
    BEGIN TRY

        SET @batch_start_time = GETDATE()

        PRINT '>> stagecache Load begin <<'
        
        PRINT ' '
        PRINT '>> ---------------------------------------------------------------------------------------------------- <<';
        PRINT ' '

        PRINT '>> stagecache.crm_cust_info truncate begin'

        TRUNCATE TABLE stagecache.crm_cust_info

        PRINT 'stagecache.crm_cust_info truncate end <<'

        SET @starttime = GETDATE()

        PRINT '>> Load stagecache.crm_cust_info begin from staging.crm_cust_info'

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

        PRINT 'Load stagecache.crm_cust_info completed from staging.crm_cust_info <<';

        SET @endtime = GETDATE();

        PRINT '>> Total time to load = ' + CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR) + 'seconds';
        
        PRINT ' '
        PRINT '>> ---------------------------------------------------------------------------------------------------- <<';
        PRINT ' '

        PRINT '>> stagecache.crm_prd_info truncate begin'

        TRUNCATE TABLE stagecache.crm_prd_info

        PRINT 'stagecache.crm_prd_info truncate end <<'

        SET @starttime = GETDATE()

        PRINT '>> Load stagecache.crm_prd_info begin from staging.crm_cust_info'

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
        
        PRINT 'Load stagecache.crm_prd_info completed from staging.crm_prd_info <<';

        SET @endtime = GETDATE();

        PRINT '>> Total time to load = ' + CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR) + 'seconds';
        
        PRINT ' '
        PRINT '>> ---------------------------------------------------------------------------------------------------- <<';
        PRINT ' '

        PRINT '>> stagecache.crm_sales_details truncate begin'

        TRUNCATE TABLE stagecache.crm_sales_details

        PRINT 'stagecache.crm_sales_details truncate end <<'

        SET @starttime = GETDATE()

        PRINT '>> Load stagecache.crm_sales_details begin from staging.crm_sales_details'

        -- Insert cleaned and validated sales data into the target table 'stagecache.crm_sales_details'
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
    
            -- Validate and convert order date:
            -- If the date length is not exactly 8 characters (YYYYMMDD), set it to NULL.
            -- Otherwise, cast the string to a DATE type.
            CASE
                WHEN LEN(sls_order_dt) <> 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt,
    
            -- Validate and convert ship date:
            CASE
                WHEN LEN(sls_ship_dt) <> 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,
    
            -- Validate and convert due date:
            CASE
                WHEN LEN(sls_due_dt) <> 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END AS sls_due_dt,
    
            -- Ensure sales amount is positive and consistent with quantity * price:
            -- If sales is missing, non-positive, or mismatched, recalculate.
            CASE
                WHEN sls_sales IS NULL 
                     OR sls_sales <= 0 
                     OR sls_sales <> sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE ABS(sls_sales)
            END AS sls_sales,
    
            sls_quantity,
    
            -- Validate price:
            -- If NULL or negative/zero, derive price from sales/quantity.
            -- Otherwise, take the absolute value.
            CASE
                WHEN sls_price IS NULL OR sls_price <= 0 
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE ABS(sls_price)
            END AS sls_price

        FROM staging.crm_sales_details;  -- Source table for raw sales data
        
        PRINT 'Load stagecache.crm_sales_details completed from staging.crm_sales_details <<';

        SET @endtime = GETDATE();

        PRINT '>> Total time to load = ' + CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR) + 'seconds';
        
        PRINT ' '
        PRINT '>> ---------------------------------------------------------------------------------------------------- <<';
        PRINT ' '

        PRINT '>> stagecache.erp_cust_az12 truncate begin'

        TRUNCATE TABLE stagecache.erp_cust_az12

        PRINT 'stagecache.erp_cust_az12 truncate end <<'

        SET @starttime = GETDATE()

        PRINT '>> Load stagecache.erp_cust_az12 begin from staging.erp_cust_az12'

        -- Insert processed data into the target table 'stagecache.erp_cust_az12'
        INSERT INTO stagecache.erp_cust_az12 (cid, bdate, gen)
        SELECT
            -- Clean and extract 'cid' by trimming spaces and taking substring 
            -- starting one character before 'W' up to the full string length.
            TRIM(SUBSTRING(cid, CHARINDEX('W', cid) - 1, LEN(cid))) AS cid,
    
            -- Replace future birthdates with NULL, otherwise keep original date.
            CASE 
                WHEN bdate >= GETDATE() THEN NULL
                ELSE bdate
            END AS bdate,
    
            -- Standardize gender values:
            -- Convert 'M' or 'MALE' (case insensitive) to 'Male'
            -- Convert 'F' or 'FEMALE' to 'Female'
            -- If not matching any, assign 'n/a'
            CASE
                WHEN UPPER(gen) = 'M' OR UPPER(gen) = 'MALE' THEN 'Male'
                WHEN UPPER(gen) = 'F' OR UPPER(gen) = 'FEMALE' THEN 'Female'
                ELSE 'n/a'
            END AS gen
        FROM staging.erp_cust_az12;  -- Source table for staging data

        PRINT 'Load stagecache.erp_cust_az12 completed from staging.erp_cust_az12 <<';

        SET @endtime = GETDATE();

        PRINT '>> Total time to load = ' + CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR) + 'seconds';
        
        PRINT ' '
        PRINT '>> ---------------------------------------------------------------------------------------------------- <<';
        PRINT ' '

        PRINT '>> stagecache.erp_loc_a101 truncate begin'

        TRUNCATE TABLE stagecache.erp_loc_a101

        PRINT 'stagecache.erp_loc_a101 truncate end <<'

        SET @starttime = GETDATE()

        PRINT '>> Load stagecache.erp_loc_a101 begin from staging.erp_loc_a101'

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
        
        PRINT 'Load stagecache.erp_loc_a101 completed from staging.erp_loc_a101 <<';

        SET @endtime = GETDATE();

        PRINT '>> Total time to load = ' + CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR) + 'seconds';
        
        PRINT ' '
        PRINT '>> ---------------------------------------------------------------------------------------------------- <<';
        PRINT ' '

        PRINT '>> stagecache.erp_px_cat_g1v2 truncate begin'

        TRUNCATE TABLE stagecache.erp_px_cat_g1v2

        PRINT 'stagecache.erp_px_cat_g1v2 truncate end <<'

        SET @starttime = GETDATE()

        PRINT '>> Load stagecache.erp_px_cat_g1v2 begin from staging.erp_px_cat_g1v2'

        /* Load ERP product category mappings into the stage cache */
        INSERT INTO stagecache.erp_px_cat_g1v2 (id,cat,subcat,maintenance)

        SELECT 
	        id,
	        cat,
	        subcat,
	        maintenance
        FROM staging.erp_px_cat_g1v2
        
        PRINT 'Load stagecache.erp_px_cat_g1v2 completed from staging.erp_px_cat_g1v2 <<';

        SET @endtime = GETDATE();

        PRINT '>> Total time to load = ' + CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR) + 'seconds';
        
        PRINT ' '
        PRINT '>> ---------------------------------------------------------------------------------------------------- <<';
        PRINT ' '

        SET @batch_end_time = GETDATE()

        PRINT '>> stagecache Load completed <<'

        PRINT '>> Total time to load the batch = ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS VARCHAR) + 'seconds';

    END TRY

    BEGIN CATCH
        
        PRINT 'Error while loading stagecache'
        PRINT 'Error message' + ERROR_MESSAGE()
        PRINT 'Error message' + CAST(ERROR_NUMBER() AS VARCHAR)
        PRINT 'Error message' + CAST(ERROR_STATE() AS VARCHAR)
        
    END CATCH

END

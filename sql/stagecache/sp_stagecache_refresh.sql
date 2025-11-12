/*********************************************************************************************
 *  PROCEDURE:  stagecache.load_stagecache
 *  ---------------------------------------------------------------------------------------
 *  Purpose
 *  -------
 *      Refresh the *stagecache* schema by:
 *          1. Truncating each staging table (customer, product, sales,
 *             ERP customer, ERP location, ERP product‑category).
 *          2. Inserting cleaned & normalised rows from the corresponding
 *             tables in the *staging* schema.
 *
 *      The procedure is written as a single batch that can be called
 *      manually or scheduled as a SQL‑Agent job.  All SQL Server
 *      objects (tables, views, procedures) are owned by the
 *      *stagecache* schema.
 *
 *  Notes
 *  -----
 *  • `CREATE OR ALTER` allows the same script to be run repeatedly.
 *  • `TRUNCATE TABLE` is DDL; it removes all rows and resets the
 *    identity column.  It is faster than `DELETE` and it requires
 *    no explicit `GO` inside a stored procedure.
 *  • The `PRINT` statements are useful for debugging and for
 *    monitoring progress when the procedure runs as a job.
 *  • Timing columns (`@starttime` / `@endtime`) give an estimate of
 *    how long each table load takes.  They are printed, but can be
 *    stored in a log table if needed.
 *  • All transformations are done in the `INSERT … SELECT` statement
 *    for each target table.  Complex logic is broken into CASE
 *    expressions, `ROW_NUMBER()` windows, and date conversion
 *    functions.
 *  • Error handling is provided by a TRY / CATCH block; on error the
 *    messages are printed.  For production use, replace the
 *    `PRINT` statements with an error‑logging table.
 *********************************************************************************************/

CREATE OR ALTER PROCEDURE stagecache.load_stagecache
AS
BEGIN
    /* ------------------------------------------------------------------
     *  Variable section – used to time the procedure and each individual
     *  table load.
     * ------------------------------------------------------------------ */
    DECLARE @starttime        DATETIME,          -- Time when a table load starts
            @endtime          DATETIME,          -- Time when a table load ends
            @batch_start_time DATETIME,          -- Time when the whole batch starts
            @batch_end_time   DATETIME;          -- Time when the whole batch ends

    BEGIN TRY
        /* ------------------------------------------------------------------
         *  Batch start time – used for overall load duration.
         * ------------------------------------------------------------------ */
        SET @batch_start_time = GETDATE();

        PRINT '>> stagecache Load begin <<';
        PRINT ' ';

        /****************************************************************************
         *  CUSTOMER INFO
         ****************************************************************************/
        PRINT '>> stagecache.crm_cust_info truncate begin <<';
        TRUNCATE TABLE stagecache.crm_cust_info;
        PRINT 'stagecache.crm_cust_info truncate end <<';

        SET @starttime = GETDATE();
        PRINT '>> Load stagecache.crm_cust_info begin from staging.crm_cust_info';

        /* ---------------------------------------------------------------
         *  Clean & normalise customer data.
         *
         *  • Keep the latest record per customer (by create date).
         *  • Trim names.
         *  • Map marital status and gender to readable values.
         *  • Preserve the original create date.
         * --------------------------------------------------------------- */
        INSERT INTO stagecache.crm_cust_info
        (cst_id, cst_key, cst_firstname, cst_lastname,
         cst_marital_status, cst_gndr, cst_create_date)
        SELECT
            /* 1. Identifiers – passed through unchanged */
            cst_id,
            cst_key,

            /* 2. Trimmed names */
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname)  AS cst_lastname,

            /* 3. Normalised marital status (M = Married, S = Single) */
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                ELSE 'n/a'
            END AS cst_marital_status,

            /* 4. Normalised gender (M/F) */
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                ELSE 'n/a'
            END AS cst_gndr,

            /* 5. Keep the original create date */
            cst_create_date
        FROM
        (
            /* Sub‑query selects the most recent row for each customer */
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rn
            FROM staging.crm_cust_info
            WHERE ISNULL(cst_id,'') <> ''      -- Reject rows with no customer id
        ) t
        WHERE rn = 1;                          -- Keep only the latest record

        SET @endtime = GETDATE();
        PRINT 'Load stagecache.crm_cust_info completed from staging.crm_cust_info <<';
        PRINT '>> Total time to load = ' + CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR) + ' seconds';
        PRINT ' ';

        /****************************************************************************
         *  PRODUCT INFO
         ****************************************************************************/
        PRINT '>> stagecache.crm_prd_info truncate begin <<';
        TRUNCATE TABLE stagecache.crm_prd_info;
        PRINT 'stagecache.crm_prd_info truncate end <<';

        SET @starttime = GETDATE();
        PRINT '>> Load stagecache.crm_prd_info begin from staging.crm_prd_info';

        /* ---------------------------------------------------------------
         *  Build a clean product table:
         *
         *  • `cat_id` – first 5 trimmed characters of the key,
         *    hyphens replaced by underscores.
         *  • `prd_key` – remainder of the key after the first 6 chars.
         *  • Trimmed product name.
         *  • Zero out NULL cost.
         *  • Map line codes (M,R,S,T) to full names.
         *  • Compute `prd_end_dt` as the day before the next product’s
         *    start date (or NULL if it’s the latest product).
         * --------------------------------------------------------------- */
        INSERT INTO stagecache.crm_prd_info
        (prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line,
         prd_start_dt, prd_end_dt)
        SELECT
            prd_id,
            REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_') AS cat_id,
            SUBSTRING(TRIM(prd_key), 7, LEN(TRIM(prd_key))) AS prd_key,
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
            DATEADD(DAY, -1,
                LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)
            ) AS prd_end_dt
        FROM staging.crm_prd_info;

        SET @endtime = GETDATE();
        PRINT 'Load stagecache.crm_prd_info completed from staging.crm_prd_info <<';
        PRINT '>> Total time to load = ' + CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR) + ' seconds';
        PRINT ' ';

        /****************************************************************************
         *  SALES DETAILS
         ****************************************************************************/
        PRINT '>> stagecache.crm_sales_details truncate begin <<';
        TRUNCATE TABLE stagecache.crm_sales_details;
        PRINT 'stagecache.crm_sales_details truncate end <<';

        SET @starttime = GETDATE();
        PRINT '>> Load stagecache.crm_sales_details begin from staging.crm_sales_details';

        /* ---------------------------------------------------------------
         *  Clean & validate sales data:
         *
         *  • Date columns – only keep values that are exactly 8 digits
         *    (YYYYMMDD).  Others are set to NULL.
         *  • Sales – if missing, non‑positive, or inconsistent with
         *    quantity × price, recompute it.
         *  • Price – if missing or non‑positive, derive from sales/qty.
         *  • All numeric values are made absolute to avoid negative
         *    figures caused by data entry errors.
         * --------------------------------------------------------------- */
        INSERT INTO stagecache.crm_sales_details
        (sls_ord_num, sls_prd_key, sls_cust_id,
         sls_order_dt, sls_ship_dt, sls_due_dt,
         sls_sales, sls_quantity, sls_price)
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            /* Order, ship & due dates – validated & cast to DATE */
            CASE WHEN LEN(sls_order_dt) <> 8 THEN NULL
                 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END AS sls_order_dt,
            CASE WHEN LEN(sls_ship_dt) <> 8 THEN NULL
                 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END AS sls_ship_dt,
            CASE WHEN LEN(sls_due_dt) <> 8 THEN NULL
                 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END AS sls_due_dt,

            /* Sales – recalc if needed */
            CASE
                WHEN sls_sales IS NULL
                  OR sls_sales <= 0
                  OR sls_sales <> sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE ABS(sls_sales)
            END AS sls_sales,

            sls_quantity,

            /* Price – derive if null or non‑positive */
            CASE
                WHEN sls_price IS NULL OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity,0)
                ELSE ABS(sls_price)
            END AS sls_price
        FROM staging.crm_sales_details;

        SET @endtime = GETDATE();
        PRINT 'Load stagecache.crm_sales_details completed from staging.crm_sales_details <<';
        PRINT '>> Total time to load = ' + CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR) + ' seconds';
        PRINT ' ';

        /****************************************************************************
         *  ERP CUSTOMER (AZ12)
         ****************************************************************************/
        PRINT '>> stagecache.erp_cust_az12 truncate begin <<';
        TRUNCATE TABLE stagecache.erp_cust_az12;
        PRINT 'stagecache.erp_cust_az12 truncate end <<';

        SET @starttime = GETDATE();
        PRINT '>> Load stagecache.erp_cust_az12 begin from staging.erp_cust_az12';

        /* ---------------------------------------------------------------
         *  Extract customer ID, clean birth date, normalise gender.
         * --------------------------------------------------------------- */
        INSERT INTO stagecache.erp_cust_az12 (cid, bdate, gen)
        SELECT
            TRIM(SUBSTRING(cid, CHARINDEX('W', cid) - 1, LEN(cid))) AS cid,

            CASE WHEN bdate >= GETDATE() THEN NULL ELSE bdate END AS bdate,

            CASE
                WHEN UPPER(gen) IN ('M','MALE')   THEN 'Male'
                WHEN UPPER(gen) IN ('F','FEMALE') THEN 'Female'
                ELSE 'n/a'
            END AS gen
        FROM staging.erp_cust_az12;

        SET @endtime = GETDATE();
        PRINT 'Load stagecache.erp_cust_az12 completed from staging.erp_cust_az12 <<';
        PRINT '>> Total time to load = ' + CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR) + ' seconds';
        PRINT ' ';

        /****************************************************************************
         *  ERP LOCATION (A101)
         ****************************************************************************/
        PRINT '>> stagecache.erp_loc_a101 truncate begin <<';
        TRUNCATE TABLE stagecache.erp_loc_a101;
        PRINT 'stagecache.erp_loc_a101 truncate end <<';

        SET @starttime = GETDATE();
        PRINT '>> Load stagecache.erp_loc_a101 begin from staging.erp_loc_a101';

        /* ---------------------------------------------------------------
         *  Standardise customer ID and country:
         *      • Remove hyphens from cid.
         *      • Map DE → Germany, USA/US → United States,
         *        blank → n/a, otherwise trim.
         * --------------------------------------------------------------- */
        INSERT INTO stagecache.erp_loc_a101 (cid, cntry)
        SELECT
            REPLACE(cid,'-','') AS cid,

            CASE
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN ISNULL(TRIM(cntry), '') = '' THEN 'n/a'
                WHEN TRIM(cntry) IN ('USA','US') THEN 'United States'
                ELSE TRIM(cntry)
            END AS cntry
        FROM staging.erp_loc_a101;

        SET @endtime = GETDATE();
        PRINT 'Load stagecache.erp_loc_a101 completed from staging.erp_loc_a101 <<';
        PRINT '>> Total time to load = ' + CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR) + ' seconds';
        PRINT ' ';

        /****************************************************************************
         *  6️⃣  ERP PRODUCT CATEGORY (PX_CAT_G1V2)
         ****************************************************************************/
        PRINT '>> stagecache.erp_px_cat_g1v2 truncate begin <<';
        TRUNCATE TABLE stagecache.erp_px_cat_g1v2;
        PRINT 'stagecache.erp_px_cat_g1v2 truncate end <<';

        SET @starttime = GETDATE();
        PRINT '>> Load stagecache.erp_px_cat_g1v2 begin from staging.erp_px_cat_g1v2';

        /* ---------------------------------------------------------------
         *  Direct copy – the ERP table is already clean.
         * --------------------------------------------------------------- */
        INSERT INTO stagecache.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
        SELECT id, cat, subcat, maintenance
        FROM staging.erp_px_cat_g1v2;

        SET @endtime = GETDATE();
        PRINT 'Load stagecache.erp_px_cat_g1v2 completed from staging.erp_px_cat_g1v2 <<';
        PRINT '>> Total time to load = ' + CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR) + ' seconds';
        PRINT ' ';

        /* ------------------------------------------------------------------
         *  Batch end – calculate and print overall duration.
         * ------------------------------------------------------------------ */
        SET @batch_end_time = GETDATE();
        PRINT '>> stagecache Load completed <<';
        PRINT '>> Total time to load the batch = ' +
              CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS VARCHAR) + ' seconds';

    END TRY
    BEGIN CATCH
        /* ------------------------------------------------------------------
         *  Error handling – print diagnostic information.
         *  In a production environment you would insert these details
         *  into an error‑log table instead of using PRINT.
         * ------------------------------------------------------------------ */
        PRINT 'Error while loading stagecache';
        PRINT 'Error number   : ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error state    : ' + CAST(ERROR_STATE()  AS VARCHAR);
        PRINT 'Error procedure: ' + ERROR_PROCEDURE();
        PRINT 'Error line     : ' + CAST(ERROR_LINE()    AS VARCHAR);
        PRINT 'Error message  : ' + ERROR_MESSAGE();
    END CATCH
END
GO

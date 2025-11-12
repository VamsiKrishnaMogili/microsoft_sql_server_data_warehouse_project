/****************************************************************************************
  PROCEDURE:   staging.load
  PURPOSE:     Load raw CSV files into the *staging* schema.
  NOTES:
    • The procedure is wrapped in TRY…CATCH so any error stops the load
      and prints a diagnostic message.
    • Each destination table is truncated first – the load is “replace‑all”.
    • BULK INSERT is used for speed; the files must be readable by the
      SQL Server service account.
    • For production use you might want to log the timings to a table
      instead of using PRINT, but PRINT is handy for manual runs / jobs.
    • File paths are hard‑coded for demo purposes – in a real project
      you could pass them in as parameters or read them from a config
      table.
****************************************************************************************/

CREATE OR ALTER PROCEDURE staging.load
AS
BEGIN
    /*--------------------------------------------------------------
     * Suppress the "(n rows affected)" messages that BULK INSERT
     * would otherwise produce.  This keeps the console output tidy.
     *--------------------------------------------------------------*/
    SET NOCOUNT ON;

    /*---------------------------------
     * Variables – all for timing
     *---------------------------------*/
    DECLARE
        @batch_start_time DATETIME,
        @batch_end_time   DATETIME,

        @crm_start_time   DATETIME,
        @crm_end_time     DATETIME,
        @erp_start_time   DATETIME,
        @erp_end_time     DATETIME,

        @start_time       DATETIME,
        @end_time         DATETIME;

    BEGIN TRY
        /*=========================================================
         *  Batch – entire procedure
         *=========================================================*/
        SET @batch_start_time = GETDATE();
        PRINT '===== Loading Staging – Start =====';

        /*----------------------------------------------------------
         *  Load CRM tables
         *----------------------------------------------------------*/
        SET @crm_start_time = GETDATE();
        PRINT '--- CRM tables loading – Start ---';

        /*--- Customer Info ----------------------------------------*/
        SET @start_time = GETDATE();
        PRINT '$ Truncate table staging.crm_cust_info start';
        TRUNCATE TABLE staging.crm_cust_info;
        PRINT '$ Truncate table staging.crm_cust_info end';

        PRINT '$ Bulk insert start';
        BULK INSERT staging.crm_cust_info
        FROM 'H:\SQL_PROJECTS\sql-data-warehouse-project-2025\datasets\source_crm\cust_info.csv'
        WITH
        (
            FIRSTROW       = 2,            -- Skip header row
            FIELDTERMINATOR = ',',         -- CSV delimiter
            TABLOCK                        -- Faster bulk insert
        );
        PRINT '$ Bulk insert end';

        SET @end_time = GETDATE();
        PRINT '$ Load Time of cust_info.csv = ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) +
              ' seconds';
        /*--- End Customer Info ------------------------------------*/

        /*--- Product Info ----------------------------------------*/
        SET @start_time = GETDATE();
        PRINT '$ Truncate table staging.crm_prd_info start';
        TRUNCATE TABLE staging.crm_prd_info;
        PRINT '$ Truncate table staging.crm_prd_info end';

        PRINT '$ Bulk insert start';
        BULK INSERT staging.crm_prd_info
        FROM 'H:\SQL_PROJECTS\sql-data-warehouse-project-2025\datasets\source_crm\prd_info.csv'
        WITH
        (
            FIRSTROW       = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        PRINT '$ Bulk insert end';

        SET @end_time = GETDATE();
        PRINT '$ Load Time of prd_info.csv = ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) +
              ' seconds';
        /*--- End Product Info -----------------------------------*/

        /*--- Sales Details --------------------------------------*/
        SET @start_time = GETDATE();
        PRINT '$ Truncate table staging.crm_sales_details start';
        TRUNCATE TABLE staging.crm_sales_details;
        PRINT '$ Truncate table staging.crm_sales_details end';

        PRINT '$ Bulk insert start';
        BULK INSERT staging.crm_sales_details
        FROM 'H:\SQL_PROJECTS\sql-data-warehouse-project-2025\datasets\source_crm\sales_details.csv'
        WITH
        (
            FIRSTROW       = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        PRINT '$ Bulk insert end';

        SET @end_time = GETDATE();
        PRINT '$ Load Time of sales_details.csv = ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) +
              ' seconds';
        /*--- End Sales Details ---------------------------------*/

        SET @crm_end_time = GETDATE();
        PRINT '$ CRM load time = ' +
              CAST(DATEDIFF(SECOND, @crm_start_time, @crm_end_time) AS NVARCHAR(20)) +
              ' seconds';
        PRINT '--- CRM tables loading – End ---';

        /*=========================================================
         *  Load ERP tables
         *=========================================================*/
        SET @erp_start_time = GETDATE();
        PRINT '--- ERP tables loading – Start ---';

        /*--- ERP Customer ----------------------------------------*/
        SET @start_time = GETDATE();
        PRINT '$ Truncate table staging.erp_cust_az12 start';
        TRUNCATE TABLE staging.erp_cust_az12;
        PRINT '$ Truncate table staging.erp_cust_az12 end';

        PRINT '$ Bulk insert start';
        BULK INSERT staging.erp_cust_az12
        FROM 'H:\SQL_PROJECTS\sql-data-warehouse-project-2025\datasets\source_erp\CUST_AZ12.csv'
        WITH
        (
            FIRSTROW       = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        PRINT '$ Bulk insert end';

        SET @end_time = GETDATE();
        PRINT '$ Load Time of CUST_AZ12.csv = ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) +
              ' seconds';
        /*--- End ERP Customer -----------------------------------*/

        /*--- ERP Location ----------------------------------------*/
        SET @start_time = GETDATE();
        PRINT '$ Truncate table staging.erp_loc_a101 start';
        TRUNCATE TABLE staging.erp_loc_a101;
        PRINT '$ Truncate table staging.erp_loc_a101 end';

        PRINT '$ Bulk insert start';
        BULK INSERT staging.erp_loc_a101
        FROM 'H:\SQL_PROJECTS\sql-data-warehouse-project-2025\datasets\source_erp\LOC_A101.csv'
        WITH
        (
            FIRSTROW       = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        PRINT '$ Bulk insert end';

        SET @end_time = GETDATE();
        PRINT '$ Load Time of LOC_A101.csv = ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) +
              ' seconds';
        /*--- End ERP Location -----------------------------------*/

        /*--- ERP Product Category --------------------------------*/
        SET @start_time = GETDATE();
        PRINT '$ Truncate table staging.erp_px_cat_g1v2 start';
        TRUNCATE TABLE staging.erp_px_cat_g1v2;
        PRINT '$ Truncate table staging.erp_px_cat_g1v2 end';

        PRINT '$ Bulk insert start';
        BULK INSERT staging.erp_px_cat_g1v2
        FROM 'H:\SQL_PROJECTS\sql-data-warehouse-project-2025\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH
        (
            FIRSTROW       = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        PRINT '$ Bulk insert end';

        SET @end_time = GETDATE();
        PRINT '$ Load Time of PX_CAT_G1V2.csv = ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) +
              ' seconds';
        /*--- End ERP Product Category ---------------------------*/

        SET @erp_end_time = GETDATE();
        PRINT '$ ERP load time = ' +
              CAST(DATEDIFF(SECOND, @erp_start_time, @erp_end_time) AS NVARCHAR(20)) +
              ' seconds';
        PRINT '--- ERP tables loading – End ---';

        /*---------------------------------
         *  Batch end
         *---------------------------------*/
        SET @batch_end_time = GETDATE();
        PRINT '===== Loading Staging – End =====';
        PRINT '$ Batch load time = ' +
              CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(20)) +
              ' seconds';

    END TRY
    BEGIN CATCH
        /*----------------------------------------------------------
         *  Simple error handling – print useful details.
         *  In a real system you’d probably log the error to a
         *  dedicated table or use a TRY…CATCH hierarchy.
         *----------------------------------------------------------*/
        PRINT '===== ERROR IN staging.load =====';
        PRINT 'Error message:   ' + ERROR_MESSAGE();
        PRINT 'Error number:   ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error state:    ' + CAST(ERROR_STATE() AS NVARCHAR(20));
        PRINT 'Error severity: ' + CAST(ERROR_SEVERITY() AS NVARCHAR(20));
    END CATCH;
END;
GO

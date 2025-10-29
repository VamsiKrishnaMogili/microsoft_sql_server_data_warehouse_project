/*** Creates a new stored procedure called load in the staging schema, or replaces the definition of that procedure if it already ***/
-- Replace the file location of crm load - H:\SQL_PROJECTS\sql-data-warehouse-project-2025\datasets\source_crm
-- Replace the file location of erp load - H:\SQL_PROJECTS\sql-data-warehouse-project-2025\datasets\source_erp
-- To execute the query using - EXEC staging.load

CREATE OR ALTER PROCEDURE staging.load AS
BEGIN
	DECLARE
		@start_time DATETIME,
		@end_time DATETIME,
		@batch_start_time DATETIME,
		@batch_end_time DATETIME,
		@crm_start_time DATETIME,
		@crm_end_time DATETIME,
		@erp_start_time DATETIME,
		@erp_end_time DATETIME

	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '***************************************************************';
		PRINT '-------------------- Loading staging start --------------------';
		PRINT '***************************************************************';

		SET @crm_start_time = GETDATE()
		PRINT '***************************************************************';
		PRINT '------------------ CRM tables Loading start -------------------';
		PRINT '***************************************************************';

		SET @start_time = GETDATE();
		PRINT '$ Truncate table staging.crm_cust_info start';
		TRUNCATE TABLE staging.crm_cust_info;
		PRINT '$ Truncate table staging.crm_cust_info end';
		
		PRINT '$ Bluk insert start';
		BULK INSERT staging.crm_cust_info
		FROM 'H:\SQL_PROJECTS\sql-data-warehouse-project-2025\datasets\source_crm\cust_info.csv'
		WITH
			(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		PRINT '$ Bluk insert end';

		SET @end_time = GETDATE();
		PRINT '$ Load Time of cust_info.csv = ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' second';

		SET @start_time = GETDATE();
		PRINT '$ Truncate table staging.crm_prd_info start';
		TRUNCATE TABLE staging.crm_prd_info;
		PRINT '$ Truncate table staging.crm_prd_info end';
		
		PRINT '$ Bluk insert start';
		BULK INSERT staging.crm_prd_info
		FROM 'H:\SQL_PROJECTS\sql-data-warehouse-project-2025\datasets\source_crm\prd_info.csv'
		WITH
			(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		PRINT '$ Bluk insert end';

		SET @end_time = GETDATE();
		PRINT '$ Load Time of prd_info.csv = ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' second';

		SET @start_time = GETDATE();
		PRINT '$ Truncate table staging.crm_sales_details start';
		TRUNCATE TABLE staging.crm_sales_details;
		PRINT '$ Truncate table staging.crm_sales_details end';
		
		PRINT '$ Bluk insert start';
		BULK INSERT staging.crm_sales_details
		FROM 'H:\SQL_PROJECTS\sql-data-warehouse-project-2025\datasets\source_crm\sales_details.csv'
		WITH
			(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		PRINT '$ Bluk insert end';

		SET @end_time = GETDATE();
		PRINT '$ Load Time of sales_details.csv = ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' second';
		
		SET @crm_end_time = GETDATE()
		PRINT '$ CRM load time = ' + CAST(DATEDIFF(second,@crm_start_time,@crm_end_time) AS NVARCHAR) + ' second';

		PRINT '***************************************************************';
		PRINT '------------------ CRM tables Loading end -------------------';
		PRINT '***************************************************************';

		SET @erp_start_time = GETDATE()
		PRINT '***************************************************************';
		PRINT '------------------ ERP tables Loading start -------------------';
		PRINT '***************************************************************';

		SET @start_time = GETDATE();
		PRINT '$ Truncate table staging.erp_cust_az12 start';
		TRUNCATE TABLE staging.erp_cust_az12
		PRINT '$ Truncate table staging.erp_cust_az12 end';

		PRINT '$ Bluk insert start';
		BULK INSERT staging.erp_cust_az12
		FROM 'H:\SQL_PROJECTS\sql-data-warehouse-project-2025\datasets\source_erp\CUST_AZ12.csv'
		WITH
			(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		PRINT '$ Bluk insert end';

		SET @end_time = GETDATE();
		PRINT '$ Load Time of CUST_AZ12.csv = ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' second';

		SET @start_time = GETDATE();
		PRINT '$ Truncate table staging.erp_loc_a101 start';
		TRUNCATE TABLE staging.erp_loc_a101
		PRINT '$ Truncate table staging.erp_loc_a101 end';

		PRINT '$ Bluk insert start';
		BULK INSERT staging.erp_loc_a101
		FROM 'H:\SQL_PROJECTS\sql-data-warehouse-project-2025\datasets\source_erp\LOC_A101.csv'
		WITH
			(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		PRINT '$ Bluk insert end';

		SET @end_time = GETDATE();
		PRINT '$ Load Time of LOC_A101.csv = ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' second';		SET @start_time = GETDATE();
		
		PRINT '$ Truncate table staging.erp_px_cat_g1v2 start';
		TRUNCATE TABLE staging.erp_px_cat_g1v2
		PRINT '$ Truncate table staging.erp_px_cat_g1v2 end';

		PRINT '$ Bluk insert start';
		BULK INSERT staging.erp_px_cat_g1v2
		FROM 'H:\SQL_PROJECTS\sql-data-warehouse-project-2025\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH
			(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		PRINT '$ Bluk insert end';

		SET @end_time = GETDATE();
		PRINT '$ Load Time of PX_CAT_G1V2.csv = ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' second';

		SET @erp_end_time = GETDATE()
		PRINT '$ ERP load time = ' + CAST(DATEDIFF(second,@erp_start_time,@erp_end_time) AS NVARCHAR) + ' second';

		PRINT '***************************************************************';
		PRINT '------------------ ERP tables Loading end -------------------';
		PRINT '***************************************************************';

		SET @batch_end_time = GETDATE();
		PRINT '$ Batch load time = ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' second';

		PRINT '***************************************************************';
		PRINT '-------------------- Loading staging end --------------------';
		PRINT '***************************************************************';

	END TRY

	BEGIN CATCH
		PRINT '***************************************************************';
		PRINT 'Error message: ' + ERROR_MESSAGE();
		PRINT 'Error message: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error message: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '***************************************************************';
	END CATCH
END;

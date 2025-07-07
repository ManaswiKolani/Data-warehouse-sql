/*
===============================================================================
 Procedure:    bronze.load_bronze
 Description:  
     - Performs a full load of raw data into the Bronze layer from flat CSV files.
     - Loads data from CRM and ERP systems into staging tables.
     - Truncates existing records before inserting new data using BULK INSERT.
     - Log messages for each stage and capture any errors during the process.
Parameters:
	-None
	- This stored procedure does not accept or return any values
 WARNING:
     This is a full load. All existing data in the bronze tables will be deleted 
     before new data is loaded.
Usage Example:
	EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @full_start_time DATETIME, @full_end_time DATETIME
	BEGIN TRY
        SET @full_start_time = GETDATE();

		-- Begin Bronze Layer Load
		PRINT '===========================';
		PRINT 'Loading Bronze Layer';
		PRINT '===========================';


		-- Load CRM Tables
		PRINT '---------------------------';
		PRINT 'Loading CRM Tables...';
		PRINT '---------------------------';

		-- Load CRM Customer Info
		PRINT '> Loading data to bronze.crm_cust_info';
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_cust_info
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\manas\OneDrive\Desktop\projects\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE()
		PRINT '>	Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)  + ' seconds';
		PRINT '...........................';
		
		-- Load CRM Product Info
        PRINT '> Loading data to bronze.crm_prd_info';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_prd_info;
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\manas\OneDrive\Desktop\projects\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        SET @end_time = GETDATE();
        PRINT '>	Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '...........................';

		-- Load CRM Sales Details
        PRINT '> Loading data to bronze.crm_sales_details';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_sales_details;
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\manas\OneDrive\Desktop\projects\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        SET @end_time = GETDATE();
        PRINT '>	Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '...........................';



		-- Load ERP Tables
		PRINT '---------------------------';
		PRINT 'Loading ERP Tables...';
		PRINT '---------------------------';

		-- Load ERP Customer Info (az12)
        PRINT '> Loading data to bronze.erp_cust_az12';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_cust_az12;
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\manas\OneDrive\Desktop\projects\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        SET @end_time = GETDATE();
        PRINT '>	Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '...........................';

		-- Load ERP Location Info (a101)
        PRINT '> Loading data to bronze.erp_loc_a101';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_loc_a101;
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\manas\OneDrive\Desktop\projects\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        SET @end_time = GETDATE();
        PRINT '>    Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '...........................';

		-- Load ERP Pricing Category (g1v2)
        PRINT '> Loading data to bronze.erp_px_cat_g1v2';
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\manas\OneDrive\Desktop\projects\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        SET @end_time = GETDATE();
        PRINT '>    Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '...........................';



		 -- Print success
		PRINT '===========================';
		PRINT 'FULL LOAD SUCCESSFUL';
        SET @full_end_time = GETDATE();
        PRINT 'TOTAL LOAD DURATION: ' + FORMAT(CAST(DATEDIFF(MILLISECOND, @full_start_time, @full_end_time) AS DECIMAL(10,3)) / 1000.0, '0.###') + ' seconds';
	    PRINT '===========================';


    END TRY
	BEGIN CATCH
		-- Handle errors during data load
		PRINT '=======================================';
		PRINT 'ERROR: LOADING DATA INTO BRONZE TABLES';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT '========================================';
	END CATCH
END

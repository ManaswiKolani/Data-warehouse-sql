/*
===============================================================================
 Procedure:    silver.load_silver
 Description:  
     - Performs ETL (Extract, Transform, Load) process to load data into the Silver layer.
     - Extracts data from the Bronze layer and applies cleaning, standardization,
       type casting, and business logic transformations.
     - Truncates existing records before inserting new data into Silver tables.
Parameters:
    - None
    - This stored procedure does not accept or return any values
 WARNING:
     This is a full load. All existing data in the silver tables will be deleted 
     before new data is loaded.
Usage Example:
    EXEC silver.load_silver;
===============================================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @full_start_time DATETIME, @full_end_time DATETIME
	
	BEGIN TRY
		SET @full_start_time = GETDATE();

		-- Begin Silver Layer Load
		PRINT '===========================';
		PRINT 'Loading Silver Layer';
		PRINT '===========================';

		-- Load CRM Tables
		PRINT '---------------------------';
		PRINT 'Loading CRM Tables...';
		PRINT '---------------------------';

		-- ========================================================
		PRINT '> Loading data to silver.crm_cust_info';
		-- Truncate and Insert data into silver.crm_cust_info
		TRUNCATE TABLE silver.crm_cust_info;
		INSERT INTO silver.crm_cust_info (
			cst_id, 
			cst_key, 
			cst_firstname, 
			cst_lastname, 
			cst_marital_status, 
			cst_gndr, 
			cst_create_date
			)
		-- Perform Transformation and Cleaning
		SELECT 
			cst_id,
			cst_key,
			-- Removing whitespace
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			-- Standardization of cst_marital_status
			CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				 ELSE 'N/A'
			END AS cst_marital_status,
			-- Standardization of cst_gndr
			CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				 ELSE 'N/A'
			END AS cst_gndr,
			cst_create_date
			-- Remving Duplicates and Null Primary keys
			FROM (
				SELECT *,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
				FROM bronze.crm_cust_info
				WHERE cst_id IS NOT NULL
			)t 
		WHERE flag_last = 1;

		SET @end_time = GETDATE()
		PRINT '>	Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)  + ' seconds';
		PRINT '...........................';

		-- ========================================================
		PRINT '> Loading data to silver.crm_prd_info';
		SET @start_time = GETDATE();
		-- Truncate and Insert data into silver.crm_prd_info
		TRUNCATE TABLE silver.crm_prd_info;
		INSERT INTO silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		-- Perform Transformation and Cleaning
		SELECT 
			prd_id, 
			-- Create and add cat_id column
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
			-- Create new prd_key
			SUBSTRING(prd_key, 7,LEN(prd_key)) AS prd_key,
			prd_nm, 
			-- Set null values to 0 in prd_cost
			ISNULL(prd_cost, 0) AS prd_cost,
			-- Standardize prd_line
			CASE UPPER(TRIM(prd_line))
				 WHEN  'M' THEN 'Mountain'
				 WHEN  'R' THEN 'Road'
				 WHEN  'S' THEN 'Other Sales'
				 WHEN  'T' THEN 'Touring'
				 ELSE 'N/A'
			END AS prd_line,
			-- Transform start and end dates
			CAST(prd_start_dt AS DATE) AS prd_start_dt, 
			CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
		FROM bronze.crm_prd_info;

		SET @end_time = GETDATE();
        PRINT '>	Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '...........................';


		--=========================================================
		 PRINT '> Loading data to silver.crm_sales_details';
         SET @start_time = GETDATE();
		-- Truncate and Insert into silver.crm_sales_details
		TRUNCATE TABLE silver.crm_sales_details;
		INSERT INTO silver.crm_sales_details(
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
		-- Perform Transformation and Cleaning
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,

			-- Standardization of order date
			CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST (CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			-- Standardization of ship date
			CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST (CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			-- Standardization of due date
			CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST (CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			-- Transformation for sales
			CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
					  THEN sls_quantity * ABS(sls_price)
				 ELSE sls_sales
			END AS sls_sales,

			sls_quantity,
			-- Transformation for price
			CASE WHEN sls_price IS NULL OR sls_price <= 0
				THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;
		
		SET @end_time = GETDATE();
        PRINT '>	Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '...........................';


		
		-- Load ERP Tables
		PRINT '---------------------------';
		PRINT 'Loading ERP Tables...';
		PRINT '---------------------------';

		--=========================================================

		PRINT '> Loading data to silver.erp_cust_az12';
        SET @start_time = GETDATE();

		-- Truncate and Insert into silver.erp_cust_az12
		TRUNCATE TABLE silver.erp_cust_az12;
		INSERT INTO silver.erp_cust_az12(
			cid, 
			bdate,
			gen
		)
		-- Perform Transformation and Cleaning
		SELECT 
			-- Standardize cid
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
				 ELSE cid 
			END AS cid,
			-- Remove unusual dates
			CASE WHEN bdate > GETDATE() THEN NULL
				 ELSE bdate
			END AS bdate,
			-- Standardize gen
			CASE WHEN UPPER(TRIM(gen)) IN ('F' , 'FEMALE') THEN 'Female'
				 WHEN UPPER(TRIM(gen)) IN ('M' , 'MALE') THEN 'Male'
				 ELSE 'N/A'
			END AS gen
		FROM bronze.erp_cust_az12;

		SET @end_time = GETDATE();
        PRINT '>    Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '...........................';

		--=========================================================

		PRINT '> Loading data to silver.erp_loc_a101';
        SET @start_time = GETDATE();

		-- Truncate and Insert into silver.erp_loc_a101
		TRUNCATE TABLE silver.erp_loc_a101;
		INSERT INTO silver.erp_loc_a101(
			cid,
			cntry
		)
		-- Perform Transformation and Cleaning
		SELECT 
			-- Standardize cid
			REPLACE(cid, '-', '') AS cid,
			-- Standardize cntry
			CASE WHEN UPPER(TRIM(cntry)) = '' OR cntry is NULL THEN 'N/A'
				 WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
				 WHEN UPPER(TRIM(cntry)) IN  ('USA', 'US') THEN 'United States'
				 ELSE TRIM(cntry)
			END AS cntry
		FROM bronze.erp_loc_a101;

		SET @end_time = GETDATE();
        PRINT '>    Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '...........................';

		--=========================================================
		PRINT '> Loading data to silver.erp_px_cat_g1v2';
        SET @start_time = GETDATE();
		-- Truncate and Insert into silver.erp_px_cat_g1v2
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT 
			id, 
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;

		SET @end_time = GETDATE();
        PRINT '>    Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '...........................';

		--=========================================================

		 -- Print success
		PRINT '===========================';
		PRINT 'FULL LOAD SUCCESSFUL';
        SET @full_end_time = GETDATE();
        PRINT 'TOTAL LOAD DURATION: ' + FORMAT(CAST(DATEDIFF(MILLISECOND, @full_start_time, @full_end_time) AS DECIMAL(10,3)) / 1000.0, '0.###') + ' seconds';
	    PRINT '===========================';

	END TRY
	BEGIN CATCH 
		PRINT '=======================================';
		PRINT 'ERROR: LOADING DATA INTO SILVER TABLES';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT '========================================';
	END CATCH
END

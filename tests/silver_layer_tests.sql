/*
===============================================================================
 Script:    Silver Layer Data Checks
 Purpose:   Run quality checks after ingesting data from Bronze to Silver layer.
 Checks:
     - Duplicates and NULLs in keys
     - Whitespace issues
     - Referential integrity
     - Value consistency and standardization
     - Logical validations

 Note:    No data is modified.
===============================================================================
*/
--=============================================================================

/*
CHECK FOR silver.crm_cust_info
*/
-- Check for NULLs or Duplicates in Key
SELECT 
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);
SELECT 
    cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
SELECT 
    cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Data Standardization & Consistency
SELECT DISTINCT 
    cst_gndr 
FROM silver.crm_cust_info;
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;

-- Final check
SELECT * 
FROM silver.crm_cust_info;

--======================================================
/*
CHECK FOR silver.crm_prd_info
*/

-- Check for NULLs or Duplicates in Key
SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for whitespaces
SELECT prd_nm
FROM silver.crm_prd_info
WHERE TRIM(prd_nm) != prd_nm;

-- Check if there's null or negative cost
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check all possibel values in prd_line
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check for invalid dates and inconsistency
SELECT * FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Final check
SELECT * 
FROM silver.crm_prd_info;

-- =====================================================
/*
CHECK FOR silver.crm_sales_details
*/

-- Check for unwanted spaces issue
SELECT 
sls_ord_num
FROM silver.crm_sales_details
WHERE TRIM(sls_ord_num) != sls_ord_num;

SELECT 
sls_prd_key
FROM silver.crm_sales_details
WHERE TRIM(sls_prd_key) != sls_prd_key;

-- Check if all keys and ids are present in other tables
SELECT sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key  NOT IN (
SELECT prd_key FROM silver.crm_prd_info);

SELECT sls_cust_id
FROM silver.crm_sales_details
WHERE sls_cust_id  NOT IN (
SELECT  cst_id FROM silver.crm_cust_info);

-- Check consistency with quantity, price and unusual values
SELECT sls_price, sls_quantity, sls_sales
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price;

SELECT sls_price, sls_quantity, sls_sales
FROM silver.crm_sales_details
WHERE sls_price <= 0 OR sls_quantity <=0 OR sls_sales <= 0;

SELECT sls_price, sls_quantity, sls_sales
FROM silver.crm_sales_details
WHERE sls_price IS NULL OR sls_quantity IS NULL OR sls_sales IS NULL;

-- Final Check
SELECT * FROM silver.crm_sales_details;

-- =====================================================
/*
CHECK FOR silver.erp_cust_az12
*/

-- Check if  values in cid match cst_id in silver.crm_cust_info
SELECT cid
FROM silver.erp_cust_az12
WHERE cid NOT IN (
SELECT cst_key FROM silver.crm_cust_info);

-- Check for unusual bdate values
SELECT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1900-01-01' OR bdate > GETDATE();

-- Standardize gen column
SELECT DISTINCT gen
FROM silver.erp_cust_az12;

-- Final Check
SELECT * FROM silver.erp_cust_az12;

-- =====================================================
/*
CHECK FOR silver.erp_loc_a101
*/

-- Check if cid matched with cst_key in silver.crm_cust_info
SELECT cid
FROM silver.erp_loc_a101
WHERE cid LIKE 'AW-%';

SELECT cid
FROM silver.erp_loc_a101
WHERE cid NOT IN (
    SELECT cst_key FROM silver.crm_cust_info);

-- Standardize cntry column
 SELECT DISTINCT cntry
 FROM  silver.erp_loc_a101;

-- Final check
SELECT * FROM silver.erp_loc_a101;

-- =====================================================
/*
CHECK FOR silver.erp_px_cat_g1v2
*/

-- Check if whitespaces exists in columns
SELECT cat 
FROM silver.erp_px_cat_g1v2
WHERE TRIM(cat) != cat;

SELECT subcat 
FROM silver.erp_px_cat_g1v2
WHERE TRIM(subcat) != subcat;

-- Check Standardization in cat column
SELECT DISTINCT cat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;

-- Final Check
SELECT * FROM silver.erp_px_cat_g1v2;

-- =====================================================






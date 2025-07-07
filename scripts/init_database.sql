/*
==================================================================================
 Script:        Create Database and Schemas
 Description:   
     - Creates a new database named 'Datawarehouse'.
     - If the database already exists, it will be dropped first.
     - Defines three schemas within the database: 'bronze', 'silver', and 'gold'.
 
 WARNING: 
     This script will drop the entire 'Datawarehouse' database if it exists.
     All existing data within the database will be permanently deleted.
==================================================================================
*/

USE master;
GO
-- Check if Database already exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO
-- Create Database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

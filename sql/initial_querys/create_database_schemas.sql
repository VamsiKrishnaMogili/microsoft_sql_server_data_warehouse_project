/* -------------  CREATE NEW DATABASE AND SCHEMAS  -------------- */
	
-- Create a new database named 'datawarehouse' with the following schemas:
--	  • staging
--	  • stagecache
--	  • cache
	
/* -------------  CAUTION    ------------------------------------ */
-- Executing this script may delete the database if it already exists on your server.

-- This query will use the master database.

USE master;
GO

-- This query checks whether a database named 'datawarehouse' already exists on the server; if so, it drops that database.

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'datawarehouse')
BEGIN 
	ALTER DATABASE datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE datawearhouse
END;
GO

-- This query creates a new database named 'datawarehouse' on the server.

CREATE DATABASE datawarehouse;
GO

-- This query sets the current database context to 'datawarehouse', so subsequent queries run against it.

USE datawarehouse;
GO

-- These queries create schemas in the database: staging, stagecache, and cache.

CREATE SCHEMA staging;
GO

CREATE SCHEMA stagecache;
GO

CREATE SCHEMA cache;
GO

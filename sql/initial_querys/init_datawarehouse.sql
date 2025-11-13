/*=============================================================
  Script:  init_datawarehouse.sql
  Purpose: Drop an existing “datawarehouse” database (if any) and
           create a brand‑new one with the required schemas.
============================================================*/

--      Make sure we are connected to the *master* catalog
--     (the only database that can create or drop other databases)
USE master;
GO


/*=============================================================
      Drop the database if it already exists
============================================================*/
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = N'datawarehouse')
BEGIN
    /* 
       * Set the database to SINGLE_USER so that all other connections
       * are forcefully disconnected.  WITH ROLLBACK IMMEDIATE tells
       * SQL Server to roll back any in‑progress transactions before
       * the database is dropped.
    */
    ALTER DATABASE datawarehouse
        SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    /* Drop the database once it is the only user */
    DROP DATABASE datawarehouse;
END;
GO


/*=============================================================
      Create a fresh database
============================================================*/
CREATE DATABASE datawarehouse;
GO


/*=============================================================
      Switch context to the new database
============================================================*/
USE datawarehouse;
GO


/*=============================================================
      Create the required schemas
  - staging   : raw, un‑transformed data
  - stagecache: cleaned data ready for the ETL pipeline
  - cache     : fact/dimension tables used by downstream analytics
============================================================*/
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'staging')
BEGIN
    CREATE SCHEMA staging;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'stagecache')
BEGIN
    CREATE SCHEMA stagecache;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'cache')
BEGIN
    CREATE SCHEMA cache;
END;
GO


/*=============================================================
      Final confirmation
============================================================*/
PRINT N'Database ''datawarehouse'' created successfully with schemas: staging, stagecache, cache.';

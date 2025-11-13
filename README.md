# Dataware House Project
Data‑migration pipeline for Microsoft SQL Server

- CSV → Staging → StageCache → Cache

This repository contains a set of T‑SQL scripts that move data from CSV files into three layers of a SQL‑Server database:

- Staging – raw, one‑to‑one copy of the CSV rows
- StageCache – cleaned / transformed copy that can be queried quickly
- Cache – final table that is used by downstream applications
  
The scripts are intentionally simple and idempotent – you can run them any number of times without breaking the data flow.


**Project Overview**

This project focuses on building a streamlined data‑migration pipeline from CSV files to a Microsoft SQL Server database, with the data flowing through three distinct layers: **Staging**, **StageCache**, and **Cache**. The repository includes scripts for:

- **Data Architecture** – design of the three layers and their inter‑relationships.  
- **ETL Pipelines** – extracting CSV data, loading it into **Staging**, transforming it for **StageCache**, and finally populating the **Cache** table.  
- **Data Modeling** – defining the schema of each layer to support efficient querying.  
- **Analytics & Reporting** – sample SQL queries and simple dashboards that read from the final **Cache** table to deliver actionable insights.

This repository is an excellent resource for professionals and students looking to showcase expertise in:

- SQL Development  
- Data Engineering  
- ETL Pipeline Development  
- Data Migration  
- Data Modeling  
- Data Analytics

**Project Requirements – Data‑Migration Pipeline**

Objective
Build a robust, SQL Server‑based data‑migration pipeline that loads raw CSV files into a three‑layer data model (Staging → StageCache → Cache). The goal is to provide a clean, analytics‑ready dataset that supports fast reporting and informed decision‑making.

**Specifications**

**Data Sources** - Import sales data from CSV files (e.g., ERP exports, CRM exports). The pipeline is designed to ingest the most recent snapshot; historic archiving is not required.

**Data Quality** - Perform cleansing and standardisation in the Staging layer (e.g., trimming whitespace, normalising date formats). Transform and de‑duplicate rows in StageCache before loading the final Cache table.

Integration	Consolidate all source files into a single, user‑friendly schema across the three layers. The design follows a medallion‑style architecture:
	• Staging – raw, 1:1 copy of the CSV rows.
	• StageCache – cleaned and transformed data ready for analytics.
	• Cache – final, aggregated tables for quick queries and dashboards.

**Scope** - Only the latest dataset is loaded each run; incremental loading or historisation is outside the scope of this repository.

**Documentation** - Provide clear, concise documentation (README, schema diagrams, and usage notes) so business stakeholders and analytics teams understand the data flow and can query the Cache layer directly.

This repository serves as a lightweight reference implementation for anyone needing a repeatable, maintainable data‑migration solution in Microsoft SQL Server.

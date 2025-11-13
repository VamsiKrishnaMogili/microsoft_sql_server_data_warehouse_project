# Dataware House Project
Data‑migration pipeline for Microsoft SQL Server

	CSV → Staging → StageCache → Cache

This repository contains a set of T‑SQL scripts that move data from CSV files into three layers of a SQL‑Server database:

	Staging – raw, one‑to‑one copy of the CSV rows
	StageCache – cleaned / transformed copy that can be queried quickly
	Cache – final table that is used by downstream applications
  
The scripts are intentionally simple and idempotent – you can run them any number of times without breaking the data flow.


**Project Overview**

This project focuses on building a streamlined data‑migration pipeline from CSV files to a Microsoft SQL Server database, with the data flowing through three distinct layers: **Staging**, **StageCache**, and **Cache**. The repository includes scripts for:

- **Data Architecture** – design of the three layers and their inter‑relationships.  
- **ETL Pipelines** – extracting CSV data, loading it into **Staging**, transforming it for **StageCache**, and finally populating the **Cache** table.  
- **Data Modeling** – defining the schema of each layer to support efficient querying.  
- **Analytics & Reporting** – sample SQL queries and simple dashboards that read from the final **Cache** table to deliver actionable insights.

🎯 This repository is an excellent resource for professionals and students looking to showcase expertise in:

- SQL Development  
- Data Engineering  
- ETL Pipeline Development  
- Data Migration  
- Data Modeling  
- Data Analytics

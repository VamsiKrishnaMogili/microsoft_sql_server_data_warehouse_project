# Dataware House – CSV‑to‑SQL Server Pipeline

A lightweight, repeatable data‑migration pipeline that loads CSV exports into a SQL Server data model.

## Architecture

CSV files → Staging (raw, 1:1) → StageCache (cleaned, de‑duplicated) → Cache (final, analytics‑ready)


| Layer | Purpose | Typical Content |
|-------|---------|-----------------|
| **Staging** | One‑to‑one copy of the CSV rows | Raw rows, minimal transformation |
| **StageCache** | Clean & transform | Trim whitespace, normalize dates, remove duplicates |
| **Cache** | Final read‑optimized tables | Aggregated / fact tables for dashboards |

> *All scripts are idempotent – you can re‑run them safely.*

---

## Project Overview

* **Data Architecture** – Design of the three layers and their relationships.  
* **ETL Pipelines** – Extract CSV → Load Staging → Transform → StageCache → Load Cache.  
* **Data Modeling** – Schema definitions that support fast querying.  
* **Analytics & Reporting** – Sample SQL queries and dashboards built on `Cache`.

---

## Getting Started

> **Prerequisites**  
> • Microsoft SQL Server 2019 (or later)  
> • SQL Server Management Studio (SSMS) or Azure Data Studio  
> • One of the supported OSes (Windows / Linux / macOS) – you’ll only run T‑SQL scripts

### 1. Clone the repo
```
git clone https://github.com/VamsiKrishnaMogili/microsoft_sql_server_data_warehouse_project.git

cd microsoft_sql_server_data_warehouse_project
```

### 2. Create the database & schema

-- Run these scripts in SSMS / Azure Data Studio

exec sql/initial_querys/init_datawarehouse.sql

### 3. Drop in your CSV files

Place the files in the datasets/ folder (one file per source).
The script expects a header row and uses BULK INSERT.

## Folder Structure

```
Dataware House – CSV‑to‑SQL Server Pipeline/
├─ datasets/                  # Raw CSV files that will be imported
├─ docs/
│   ├─ SQL_PROJECT.drawio.png # Visual diagram of the pipeline (draw.io export)
├─ sql/
│   ├─ cache/                 # T‑SQL scripts that create and populate the Cache layer
│   ├─ initial_querys/        # Scripts to create database and schemas
│   ├─ stagecache/            # Scripts that clean, transform and de‑duplicate into StageCache
│   ├─ staging/               # Scripts that bulk‑load raw CSV rows into the Staging layer
└─ README.md                  # Project overview, usage, and documentation
```

## License
MIT – see the LICENSE file for details.


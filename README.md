# Dataware House Project
Data‑migration pipeline for Microsoft SQL Server 
\n CSV → Staging → StageCache → Cache

This repository contains a set of T‑SQL scripts that move data from CSV files into three layers of a SQL‑Server database:

  Staging – raw, one‑to‑one copy of the CSV rows
  StageCache – cleaned / transformed copy that can be queried quickly
  Cache – final table that is used by downstream applications
  
The scripts are intentionally simple and idempotent – you can run them any number of times without breaking the data flow.

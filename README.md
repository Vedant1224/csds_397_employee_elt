# CSDS 397 HW2 - Employee ELT Pipeline

## Overview

This project implements an Employee ELT pipeline using SQLite in SQLiteStudio.
The workflow follows an ELT approach:

- Load the source CSV into a raw table first
- Profile the raw data to identify quality issues
- Clean and transform the data inside the database
- Export a final cleaned dataset for submission

## Repository Structure

```text
.
├── data/
│   └── employee_data.csv
├── sql/
│   ├── 01_create_sources_raw.sql
│   ├── 02_profiling.sql
│   ├── 03_create_staging_3nf.sql
│   ├── 04_transform_load_staging.sql
│   └── 05_final_export_view.sql
├── Report/
└── README.md
```

## How to Run

1. Create or open a SQLite database in SQLiteStudio.
2. Run `sql/01_create_sources_raw.sql`.
3. Import `data/employee_data.csv` into the raw table using SQLiteStudio:
   `Tools -> Import -> Table from CSV`.
4. Run `sql/02_profiling.sql` to inspect data quality issues.
5. Run `sql/03_create_staging_3nf.sql`.
6. Run `sql/04_transform_load_staging.sql`.
7. Run `sql/05_final_export_view.sql`.
8. Export the final cleaned dataset to `data/cleaned_employee_dataset.csv` using SQLiteStudio:
   `Tools -> Export`.

## Deliverables

- [x] SQL scripts for raw load, profiling, staging, transformation, and final export view
- [ ] Cleaned dataset export
- [ ] Report with writeup and screenshots in `Report/`
- [ ] Video link

## Notes

- SQLite does not support schemas in the same way as other relational databases.
- This project uses table name prefixes such as `sources_*` and `staging_*` instead.

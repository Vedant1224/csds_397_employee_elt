# CSDS 397 HW2 - Employee ELT Pipeline

## Overview

This project implements an Employee ELT pipeline using **MySQL 8 in Docker**.
The flow is ELT-first:

- Land source data as-is in `sources.employee_raw`
- Profile data quality issues in the raw layer
- Clean, standardize, and deduplicate in database tables under `staging`
- Export a final cleaned dataset from `staging.vw_employee_clean`

## Repository Structure

```text
.
├── data/
│   ├── employee_data.csv
│   └── cleaned_employee_dataset.csv
├── sql/
│   ├── 01_create_sources_raw.sql
│   ├── 02_profiling.sql
│   ├── 03_create_staging_3nf.sql
│   ├── 04_transform_load_staging.sql
│   └── 05_final_export_view.sql
├── Report/
│   ├── profiling_output.txt
│   ├── 03_create_staging_output.txt
│   ├── 04_transform_load_output.txt
│   └── 05_final_view_output.txt
├── .gitignore
└── README.md
```

## Prerequisites

- Docker Desktop
- Git
- Terminal (zsh/bash)

Create a local `.env` file in the repo root with:

```bash
MYSQL_ROOT_PASSWORD=your_password_here
```

`.env` is gitignored and should not be committed.

## Quickstart

```bash
# 1) Start MySQL 8 container (port 3307 on host, secure-file-priv set to /tmp)
docker run --name csds397-mysql --env-file .env -p 3307:3306 -d mysql:8 --secure-file-priv=/tmp

# 2) Load environment variable for this shell
set -a; source .env; set +a

# 3) Create databases/tables (sources + staging raw table)
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql/01_create_sources_raw.sql

# 4) Copy CSV into container
docker cp data/employee_data.csv csds397-mysql:/tmp/employee_data.csv

# 5) Load CSV into sources.employee_raw (rerunnable)
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot -e "
USE sources;
TRUNCATE TABLE employee_raw;

LOAD DATA INFILE '/tmp/employee_data.csv'
INTO TABLE employee_raw
FIELDS TERMINATED BY ',' ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(employee_id, name, age, department, date_of_joining, years_of_experience, country, salary, performance_rating, total_sales, support_rating);
"

# 6) Profiling
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql/02_profiling.sql

# 7) Create 3NF staging tables
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql/03_create_staging_3nf.sql

# 8) Transform + load staging tables
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql/04_transform_load_staging.sql

# 9) Create final export view
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql/05_final_export_view.sql

# 10) Export final cleaned dataset
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot --batch --raw -e "
SELECT * FROM staging.vw_employee_clean;
" | sed 's/\t/,/g' > data/cleaned_employee_dataset.csv
```

Observed run checks:

- Raw rows: `735`
- Distinct employee IDs in raw: `681`
- Employees loaded to staging (`staging.dim_employee`): `681`

## Deliverables Checklist

- [x] SQL scripts in `sql/` (raw, profiling, 3NF, transform/load, final view)
- [x] Cleaned output dataset: `data/cleaned_employee_dataset.csv`
- [x] Report outputs in `Report/`
- [ ] Final report document/screenshots
- [ ] Video link

## Troubleshooting

- Port conflict on `3306`: keep host mapping as `-p 3307:3306` (as above).
- Container name conflict: run `docker rm -f csds397-mysql` and re-run `docker run`.
- CSV path/load errors: use `docker cp data/employee_data.csv csds397-mysql:/tmp/employee_data.csv` and load from `/tmp`.
- Authentication issues: ensure `source .env` was run and `MYSQL_ROOT_PASSWORD` matches the container setup.

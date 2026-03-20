# CSDS 397 HW3

## Overview

This assignment builds on the staged dataset and creates business-facing insight tables in a new schema called `gold`. 

## Repository Items Used for HW3

- `data_assignment3/Assignment3_CleanData.csv`
- `sql_hw3/06_gold_analyses.sql`
- `hw3_trends_and_insights/gold_exports/`

## Repository Structure

```text
.
├── data/
│   ├── employee_data.csv
│   └── cleaned_employee_dataset.csv
├── data_assignment3/
│   └── Assignment3_CleanData.csv
├── hw3_trends_and_insights/
│   └── gold_exports/
│       ├── performance_by_salary_analysis.csv
│       ├── salary_to_country_analysis.csv
│       ├── salary_to_department_analysis.csv
│       ├── salary_to_tenure_analysis.csv
│       ├── sales_to_salary_analysis.csv
│       └── support_rating_to_salary_analysis.csv
├── sql/
│   ├── 01_create_sources_raw.sql
│   ├── 02_profiling.sql
│   ├── 03_create_staging_3nf.sql
│   ├── 04_transform_load_staging.sql
│   └── 05_final_export_view.sql
├── sql_hw3/
│   └── 06_gold_analyses.sql
├── Report/
│   ├── profiling_output.txt
│   ├── 03_create_staging_output.txt
│   ├── 04_transform_load_output.txt
│   └── 05_final_view_output.txt
├── .gitignore
└── README.md
```

## HW3 Run Steps

- Start the MySQL container and load environment variables.
- Copy the Assignment 3 cleaned dataset into the container.
- Create and load the Assignment 3 source table in `sources`.
- Run the HW3 SQL to create the staging view and gold tables.
- Export each gold table to CSV.

## HW3 Quickstart

```bash
# 1) Start existing container and load env
docker start csds397-mysql
set -a; source .env; set +a

# 2) Copy the cleaned dataset into the container
docker cp data_assignment3/Assignment3_CleanData.csv csds397-mysql:/tmp/Assignment3_CleanData.csv

# 3) Create the sources table for the provided cleaned data
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot -e "
CREATE DATABASE IF NOT EXISTS sources;
DROP TABLE IF EXISTS sources.employee_clean_hw3;
CREATE TABLE sources.employee_clean_hw3 (
  employee_id INT,
  name TEXT,
  age INT,
  department TEXT,
  date_of_joining DATE,
  years_of_experience INT,
  country TEXT,
  salary DECIMAL(12,2),
  performance_rating INT,
  total_sales DECIMAL(14,2),
  support_rating INT
);
"

# 4) Load the CSV into sources.employee_clean_hw3
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot -e "
TRUNCATE TABLE sources.employee_clean_hw3;
LOAD DATA INFILE '/tmp/Assignment3_CleanData.csv'
INTO TABLE sources.employee_clean_hw3
FIELDS TERMINATED BY ',' ENCLOSED BY '\"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(employee_id, name, age, department, date_of_joining, years_of_experience, country, salary, performance_rating, total_sales, support_rating);
SELECT COUNT(*) AS hw3_clean_rows FROM sources.employee_clean_hw3;
"

# 5) Run the HW3 SQL to create the staging view and gold tables
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql_hw3/06_gold_analyses.sql

# 6) Export each gold table to CSV
mkdir -p hw3_trends_and_insights/gold_exports

docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot --batch --raw -e "SELECT * FROM gold.salary_to_department_analysis;" | sed 's/\t/,/g' > hw3_trends_and_insights/gold_exports/salary_to_department_analysis.csv
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot --batch --raw -e "SELECT * FROM gold.salary_to_tenure_analysis;" | sed 's/\t/,/g' > hw3_trends_and_insights/gold_exports/salary_to_tenure_analysis.csv
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot --batch --raw -e "SELECT * FROM gold.performance_by_salary_analysis;" | sed 's/\t/,/g' > hw3_trends_and_insights/gold_exports/performance_by_salary_analysis.csv
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot --batch --raw -e "SELECT * FROM gold.salary_to_country_analysis;" | sed 's/\t/,/g' > hw3_trends_and_insights/gold_exports/salary_to_country_analysis.csv
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot --batch --raw -e "SELECT * FROM gold.sales_to_salary_analysis;" | sed 's/\t/,/g' > hw3_trends_and_insights/gold_exports/sales_to_salary_analysis.csv
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot --batch --raw -e "SELECT * FROM gold.support_rating_to_salary_analysis;" | sed 's/\t/,/g' > hw3_trends_and_insights/gold_exports/support_rating_to_salary_analysis.csv

# 7) Stop the container when finished
docker stop csds397-mysql
```

## Notes

- `sql_hw3/06_gold_analyses.sql` creates `staging.vw_employee_clean_hw3` and then builds the final `gold` analysis tables.
- The HW3 staging view keeps `total_sales` only for `Sales` employees and `support_rating` only for `Support` employees, treating `0` as not applicable in those role-specific fields.


# CSDS 397 HW2 - Employee ELT Pipeline

## Overview

This project implements an Employee ELT pipeline using MySQL 8 in Docker. The workflow is ELT-first.

- Land source data as-is in `sources.employee_raw`
- Profile data quality issues in the raw layer
- Clean, standardize, and deduplicate into normalized staging tables under `staging`
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
- Terminal

Create a local `.env` file in the repo root with:

```bash
MYSQL_ROOT_PASSWORD=your_password_here
```

`.env` is gitignored and should not be committed.

## Quickstart

```bash
docker run --name csds397-mysql --env-file .env -p 3307:3306 -d mysql:8 --secure-file-priv=/tmp

set -a; source .env; set +a

docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql/01_create_sources_raw.sql

docker cp data/employee_data.csv csds397-mysql:/tmp/employee_data.csv

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

docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql/02_profiling.sql

docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql/03_create_staging_3nf.sql

docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql/04_transform_load_staging.sql

docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql/05_final_export_view.sql

docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot --batch --raw -e "
SELECT * FROM staging.vw_employee_clean;
" | sed 's/\t/,/g' > data/cleaned_employee_dataset.csv
```

## Observed Run Checks

- Raw rows (`sources.employee_raw`): `735`
- Distinct employee IDs in raw: `681`
- Employees in staging employee table: `681`


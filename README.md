# CSDS 397 Employee ELT Repository

This repository contains the cleaned ELT pipeline from HW2 and the business-facing gold transformations from HW3.

For HW3, the key files to review are the cleaned dataset, the SQL script in `sql_hw3`, and the exported gold CSV outputs.

## HW3 Overview

HW3 builds on the staged employee dataset and creates business-facing insight tables in a new schema called `gold`. The input is the provided cleaned dataset for Assignment 3 so that the same results can be reproduced consistently.

The main HW3 deliverable is `sql_hw3/06_gold_analyses.sql`. That script recreates `staging.vw_employee_clean_hw3` and then builds all gold analysis tables from that standardized view.

## Repository Items Used for HW3

- `data_assignment3/Assignment3_CleanData.csv` - cleaned input dataset used for HW3
- `sql_hw3/06_gold_analyses.sql` - main HW3 SQL script that creates the staging view and gold tables
- `hw3_trends_and_insights/gold_exports/` - exported CSV outputs from the gold analysis tables

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

- `data/`, `sql/`, and `Report/` mainly contain the earlier HW2 pipeline assets.
- `data_assignment3/`, `sql_hw3/`, and `hw3_trends_and_insights/gold_exports/` are the primary HW3 submission materials.

## HW3 Pipeline Notes

`sql_hw3/06_gold_analyses.sql` first creates `staging.vw_employee_clean_hw3` and then uses that standardized view as the input for all gold analyses.

Business rule note:
`total_sales` is only retained for `Sales` employees, and `support_rating` is only retained for `Support` employees. A value of `0` is treated as not applicable in those role-specific fields.

## HW3 Run Steps

HW3 assumes the MySQL Docker setup from the earlier assignment already exists, so these steps start the existing container rather than creating a new one.

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

## HW2 Background

HW2 established the original employee ELT pipeline in MySQL using Docker. That earlier work loads raw employee data into `sources`, profiles data quality issues, transforms the dataset into normalized staging tables, and exports a cleaned final dataset from `staging.vw_employee_clean`. HW3 builds directly on that foundation by taking a cleaned employee dataset and producing business-facing gold analysis tables.

## HW2 Reference

- Raw rows (`sources.employee_raw`): `735`
- Distinct employee IDs in raw: `681`
- Employees in staging employee table: `681`

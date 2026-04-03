#!/bin/bash
set -e

REPO_ROOT="/Users/vedantgupta/Desktop/CSDS397_HW2"
cd "$REPO_ROOT"

set -a
source .env
set +a

docker start csds397-mysql >/dev/null 2>&1 || true

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

SELECT COUNT(*) AS loaded_rows FROM employee_raw;
"

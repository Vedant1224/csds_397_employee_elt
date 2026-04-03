#!/bin/bash
set -e
cd /Users/vedantgupta/Desktop/CSDS397_HW2
set -a
source .env
set +a
docker start csds397-mysql >/dev/null 2>&1 || true
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < hw5_airflow/sql_transformations/support_rating_to_salary_analysis.sql

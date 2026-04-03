#!/bin/bash
set -e

REPO_ROOT="/Users/vedantgupta/Desktop/CSDS397_HW2"
cd "$REPO_ROOT"

set -a
source .env
set +a

docker start csds397-mysql >/dev/null 2>&1 || true

docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql/02_profiling.sql
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql/03_create_staging_3nf.sql
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql/04_transform_load_staging.sql
docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot < sql/05_final_export_view.sql

docker exec -i -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" csds397-mysql mysql -uroot -e "
SELECT COUNT(*) AS cleaned_rows FROM staging.vw_employee_clean;
"

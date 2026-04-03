# CSDS 397 Employee ELT Repository

This repository is currently centered on HW5, which uses Apache Airflow to orchestrate the employee pipeline tasks developed in earlier assignments. The primary deliverables are the HW5 DAG, its supporting scripts and SQL transformations, and the Airflow UI screenshots, with HW4, HW3, and HW2 retained below as reference context.

## HW5 Overview

HW5 adds Apache Airflow orchestration on top of the earlier employee pipeline work. It reuses the prior ingestion, cleaning, normalization, and transformation logic, and schedules those steps through a single DAG instead of running them manually.

The Airflow DAG orchestrates dependencies in this order:

- `ingest_data`
- `clean_and_normalize`
- six transformation tasks that run after cleaning

Retries and scheduling are configured directly in the DAG, and Airflow UI screenshots are stored in `hw5_airflow/screenshots/`.

## HW5 Key Files

These are the primary HW5 submission materials:

- `hw5_airflow/dags/employee_pipeline_dag.py` - main Airflow DAG definition
- `hw5_airflow/scripts/` - shell scripts used by the DAG for ingestion, cleaning, and task execution
- `hw5_airflow/sql_transformations/` - SQL files used for the transformation tasks
- `hw5_airflow/screenshots/` - Airflow UI screenshots showing DAG execution and task logs

## HW5 Notes

HW5 was run locally with Airflow standalone and orchestrates the MySQL-based employee pipeline tasks from the earlier assignments. The DAG executes ingestion first, then cleaning and normalization, and then the six downstream transformation tasks in parallel after the cleaned layer is ready.

## Repository Structure

```text
.
├── hw5_airflow/
│   ├── dags/
│   │   └── employee_pipeline_dag.py
│   ├── screenshots/
│   │   ├── 01_dag_success_overview.png
│   │   ├── 02_dag_graph_view.png
│   │   ├── 03_ingest_data_log_success.png
│   │   ├── 04_clean_and_normalize_log_success.png
│   │   ├── 05_transformation_log_success.png
│   │   └── 06_dag_code_view.png
│   ├── scripts/
│   │   ├── clean_and_normalize.sh
│   │   ├── ingest_data.sh
│   │   ├── run_performance_by_salary.sh
│   │   ├── run_salary_to_country.sh
│   │   ├── run_salary_to_department.sh
│   │   ├── run_salary_to_tenure.sh
│   │   ├── run_sales_to_salary.sh
│   │   └── run_support_rating_to_salary.sh
│   └── sql_transformations/
│       ├── performance_by_salary_analysis.sql
│       ├── salary_to_country_analysis.sql
│       ├── salary_to_department_analysis.sql
│       ├── salary_to_tenure_analysis.sql
│       ├── sales_to_salary_analysis.sql
│       └── support_rating_to_salary_analysis.sql
├── data/
├── data_assignment3/
├── hw3_trends_and_insights/
│   └── gold_exports/
├── hw4_dbt/
│   └── employee_hw4/
│       ├── dbt_project.yml
│       └── models/
├── hw4_outputs/
├── Report/
├── sql/
├── sql_hw3/
│   └── 06_gold_analyses.sql
└── README.md
```

- `hw5_airflow/` contains the newest HW5 orchestration materials.
- `hw4_dbt/employee_hw4/` and `hw4_outputs/` contain the HW4 dbt implementation and exported outputs.
- `sql_hw3/` and `hw3_trends_and_insights/gold_exports/` keep the HW3 SQL implementation and outputs for reference.
- `sql/`, `data/`, and `Report/` contain the original HW2 pipeline assets.

## Earlier Assignments

HW4 re-implemented the six employee insight transformations in dbt using PostgreSQL as the target warehouse. The core project lives in `hw4_dbt/employee_hw4/`, where dbt reads from `public.employee_clean_hw4` and materializes the same business-facing outputs that were previously built in SQL. Exported CSV results are stored in `hw4_outputs/`.

HW3 built six gold tables in MySQL from the cleaned Assignment 3 dataset. Its main SQL deliverable is `sql_hw3/06_gold_analyses.sql`, and the resulting outputs are stored in `hw3_trends_and_insights/gold_exports/`.

HW2 created the original employee ELT pipeline in MySQL using Docker. Raw employee data was loaded, profiled, transformed into staging tables, and exported as a cleaned dataset that later assignments build on.

## Assignment Mapping

- HW5: Airflow orchestration of ingestion, cleaning, and transformation tasks
- HW4: dbt reimplementation of analytical transformations
- HW3: SQL gold transformations
- HW2: foundational ELT pipeline

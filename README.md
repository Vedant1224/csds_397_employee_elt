# CSDS 397 Employee ELT Repository

This repository contains the HW2 foundational ELT pipeline, the HW3 SQL-based gold transformations, the HW4 dbt reimplementation of those analytical transformations, and the HW5 Apache Airflow orchestration of the earlier pipeline tasks. The main deliverables are the HW5 Airflow DAG and supporting assets, the HW4 dbt project, and the earlier HW3 SQL work for reference.

## HW5 Overview

HW5 adds Apache Airflow orchestration on top of the earlier employee pipeline work. It reuses the prior ingestion, cleaning and normalization, and transformation logic, and schedules those steps through a single DAG instead of running them manually.

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

## HW4 Overview

HW4 re-implements the six employee insight transformations from the previous assignment using dbt. The cleaned dataset is loaded into PostgreSQL, dbt models build modular and reusable transformation tables, and the transformed tables are also exported as CSV outputs for submission and review.

## HW4 Key Files

These are the primary HW4 submission materials:

- `hw4_dbt/employee_hw4/dbt_project.yml` - dbt project configuration
- `hw4_dbt/employee_hw4/models/sources.yml` - source definitions for the HW4 dbt models
- `hw4_dbt/employee_hw4/models/` - the six dbt models that recreate the analytical transformations
- `hw4_outputs/` - exported CSV outputs generated from the HW4 transformed tables

## Repository Structure

```text
.
├── data/
├── data_assignment3/
├── hw3_trends_and_insights/
│   └── gold_exports/
├── hw4_dbt/
│   └── employee_hw4/
│       ├── dbt_project.yml
│       └── models/
├── hw4_outputs/
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

## HW4 Pipeline Notes

HW4 uses PostgreSQL as the target warehouse. dbt reads from the source table `public.employee_clean_hw4`, and the six dbt models recreate the same business-facing insight tables produced earlier in HW3. These outputs are materialized as tables and then exported to CSV, showing the same transformation logic implemented in a more modular and reusable framework than plain SQL scripts.

## HW3 Overview

HW3 built six gold tables in MySQL from the cleaned Assignment 3 dataset. The main file is `sql_hw3/06_gold_analyses.sql`, and the resulting outputs are stored in `hw3_trends_and_insights/gold_exports/`.

## HW2 Background

HW2 created the original employee ELT pipeline in MySQL using Docker. Raw employee data was loaded, profiled, transformed into staging tables, and exported as a cleaned dataset. HW3, HW4, and HW5 build conceptually on that earlier work.

## Assignment Mapping

- HW2: foundational ELT pipeline
- HW3: SQL gold transformations
- HW4: dbt reimplementation of analytical transformations
- HW5: Airflow orchestration of ingestion, cleaning, and transformation tasks

# CSDS 397 Employee ELT Repository

This repository contains the HW2 foundational ELT pipeline, the HW3 SQL-based gold transformations, and the HW4 dbt reimplementation of the same analytical transformations. The main current deliverables are the HW3 SQL work and the HW4 dbt project plus exported outputs.

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
│       ├── README.md
│       └── models/
│           ├── sources.yml
│           ├── performance_by_salary_analysis.sql
│           ├── salary_to_country_analysis.sql
│           ├── salary_to_department_analysis.sql
│           ├── salary_to_tenure_analysis.sql
│           ├── sales_to_salary_analysis.sql
│           └── support_rating_to_salary_analysis.sql
├── hw4_outputs/
│   ├── performance_by_salary_analysis.csv
│   ├── salary_to_country_analysis.csv
│   ├── salary_to_department_analysis.csv
│   ├── salary_to_tenure_analysis.csv
│   ├── sales_to_salary_analysis.csv
│   └── support_rating_to_salary_analysis.csv
├── Report/
├── sql/
├── sql_hw3/
│   └── 06_gold_analyses.sql
└── README.md
```

- `hw4_dbt/employee_hw4/` and `hw4_outputs/` contain the newest HW4 submission materials.
- `sql_hw3/` and `hw3_trends_and_insights/gold_exports/` keep the earlier HW3 SQL implementation and outputs for reference.
- `sql/`, `data/`, and `Report/` contain the original HW2 pipeline assets.

## HW4 Pipeline Notes

HW4 uses PostgreSQL as the target warehouse. dbt reads from the source table `public.employee_clean_hw4`, and the six dbt models recreate the same business-facing insight tables produced earlier in HW3. These outputs are materialized as tables and then exported to CSV, showing the same transformation logic implemented in a more modular and reusable framework than plain SQL scripts.

## HW3 Overview

HW3 built six gold tables in MySQL from the cleaned Assignment 3 dataset. The main file is `sql_hw3/06_gold_analyses.sql`, and the resulting outputs are stored in `hw3_trends_and_insights/gold_exports/`.

## HW2 Background

HW2 created the original employee ELT pipeline in MySQL using Docker. Raw employee data was loaded, profiled, transformed into staging tables, and exported as a cleaned dataset. HW3 and HW4 build conceptually on that earlier work.

## Assignment Mapping

- HW2 -> foundational ELT pipeline
- HW3 -> SQL gold transformations
- HW4 -> dbt reimplementation of analytical transformations

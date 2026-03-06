-- @author Vedant Gupta
-- Step 3: create the staging tables in 3NF with real types and constraints.

DROP DATABASE IF EXISTS staging;
CREATE DATABASE staging;
USE staging;

-- Dimensions
CREATE TABLE dim_department (
  dept_id INT AUTO_INCREMENT PRIMARY KEY,
  dept_raw VARCHAR(50) NOT NULL,
  dept_standard VARCHAR(20) NOT NULL,
  UNIQUE KEY uq_dept_raw (dept_raw),
  CHECK (dept_standard IN ('Sales','Support','Marketing','Other'))
);

CREATE TABLE dim_country (
  country_id INT AUTO_INCREMENT PRIMARY KEY,
  country_raw VARCHAR(50) NOT NULL,
  country_standard VARCHAR(50) NOT NULL,
  UNIQUE KEY uq_country_raw (country_raw)
);

-- Core entity
CREATE TABLE dim_employee (
  employee_id INT PRIMARY KEY,
  full_name VARCHAR(100) NULL,
  age INT NULL,
  join_date DATE NULL,
  years_experience INT NULL,
  dept_id INT NOT NULL,
  country_id INT NOT NULL,
  CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES dim_department(dept_id),
  CONSTRAINT fk_emp_country FOREIGN KEY (country_id) REFERENCES dim_country(country_id),
  CHECK (age IS NULL OR age BETWEEN 0 AND 120),
  CHECK (years_experience IS NULL OR years_experience BETWEEN 0 AND 80)
);

-- Facts / metrics
CREATE TABLE fact_compensation (
  employee_id INT PRIMARY KEY,
  salary DECIMAL(12,2) NULL,
  CONSTRAINT fk_comp_emp FOREIGN KEY (employee_id) REFERENCES dim_employee(employee_id),
  CHECK (salary IS NULL OR salary >= 0)
);

CREATE TABLE fact_performance (
  employee_id INT PRIMARY KEY,
  performance_rating INT NULL,
  CONSTRAINT fk_perf_emp FOREIGN KEY (employee_id) REFERENCES dim_employee(employee_id),
  CHECK (performance_rating IS NULL OR performance_rating BETWEEN 1 AND 5)
);

CREATE TABLE fact_sales (
  employee_id INT PRIMARY KEY,
  total_sales DECIMAL(14,2) NULL,
  CONSTRAINT fk_sales_emp FOREIGN KEY (employee_id) REFERENCES dim_employee(employee_id),
  CHECK (total_sales IS NULL OR total_sales >= 0)
);

CREATE TABLE fact_support (
  employee_id INT PRIMARY KEY,
  support_rating INT NULL,
  CONSTRAINT fk_support_emp FOREIGN KEY (employee_id) REFERENCES dim_employee(employee_id),
  CHECK (support_rating IS NULL OR support_rating BETWEEN 1 AND 5)
);
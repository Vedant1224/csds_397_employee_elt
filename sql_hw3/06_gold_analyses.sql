-- author Vedant Gupta
-- hw3 gold tables

-- create the hw3 view in staging so the gold script is fully reproducible
CREATE DATABASE IF NOT EXISTS staging;

DROP VIEW IF EXISTS staging.vw_employee_clean_hw3;

CREATE VIEW staging.vw_employee_clean_hw3 AS
SELECT
  employee_id,
  name,
  age,
  department,
  date_of_joining,
  years_of_experience,
  country,
  salary,
  performance_rating,

  -- keep sales only for Sales
  CASE
    WHEN department = 'Sales' THEN NULLIF(total_sales, 0)
    ELSE NULL
  END AS total_sales,

  -- keep support rating only for Support and treat 0 as not applicable
  CASE
    WHEN department = 'Support' THEN NULLIF(support_rating, 0)
    ELSE NULL
  END AS support_rating
FROM sources.employee_clean_hw3;

-- gold tables store the final trend outputs for business use
CREATE DATABASE IF NOT EXISTS gold;
USE gold;

DROP TABLE IF EXISTS salary_to_department_analysis;
DROP TABLE IF EXISTS salary_to_tenure_analysis;
DROP TABLE IF EXISTS performance_by_salary_analysis;
DROP TABLE IF EXISTS salary_to_country_analysis;
DROP TABLE IF EXISTS sales_to_salary_analysis;
DROP TABLE IF EXISTS support_rating_to_salary_analysis;

-- average salary by department
CREATE TABLE salary_to_department_analysis AS
SELECT
  department,
  COUNT(*) AS employee_count,
  ROUND(AVG(salary), 2) AS avg_salary
FROM staging.vw_employee_clean_hw3
WHERE salary IS NOT NULL
  AND department IS NOT NULL
GROUP BY department
ORDER BY avg_salary DESC;

-- average salary by experience buckets of 3 years
CREATE TABLE salary_to_tenure_analysis AS
SELECT
  CONCAT(FLOOR(years_of_experience / 3) * 3, ' to ', FLOOR(years_of_experience / 3) * 3 + 2) AS experience_bucket,
  COUNT(*) AS employee_count,
  ROUND(AVG(salary), 2) AS avg_salary
FROM staging.vw_employee_clean_hw3
WHERE salary IS NOT NULL
  AND years_of_experience IS NOT NULL
GROUP BY experience_bucket
ORDER BY MIN(years_of_experience);

-- average salary by performance rating
CREATE TABLE performance_by_salary_analysis AS
SELECT
  performance_rating,
  COUNT(*) AS employee_count,
  ROUND(AVG(salary), 2) AS avg_salary
FROM staging.vw_employee_clean_hw3
WHERE salary IS NOT NULL
  AND performance_rating IS NOT NULL
GROUP BY performance_rating
ORDER BY performance_rating;

-- average salary by country
CREATE TABLE salary_to_country_analysis AS
SELECT
  country,
  COUNT(*) AS employee_count,
  ROUND(AVG(salary), 2) AS avg_salary
FROM staging.vw_employee_clean_hw3
WHERE salary IS NOT NULL
  AND country IS NOT NULL
GROUP BY country
ORDER BY avg_salary DESC;

-- sales bucket to salary for Sales employees only
CREATE TABLE sales_to_salary_analysis AS
SELECT
  CONCAT(FLOOR(total_sales / 50000) * 50000, ' to ', FLOOR(total_sales / 50000) * 50000 + 49999) AS sales_bucket,
  COUNT(*) AS employee_count,
  ROUND(AVG(salary), 2) AS avg_salary,
  ROUND(AVG(total_sales), 2) AS avg_total_sales
FROM staging.vw_employee_clean_hw3
WHERE department = 'Sales'
  AND salary IS NOT NULL
  AND total_sales IS NOT NULL
GROUP BY sales_bucket
ORDER BY MIN(total_sales);

-- support rating to salary for Support employees only
CREATE TABLE support_rating_to_salary_analysis AS
SELECT
  support_rating,
  COUNT(*) AS employee_count,
  ROUND(AVG(salary), 2) AS avg_salary
FROM staging.vw_employee_clean_hw3
WHERE department = 'Support'
  AND salary IS NOT NULL
  AND support_rating IS NOT NULL
GROUP BY support_rating
ORDER BY support_rating;

SELECT * FROM salary_to_department_analysis;
SELECT * FROM salary_to_tenure_analysis;
SELECT * FROM performance_by_salary_analysis;
SELECT * FROM salary_to_country_analysis;
SELECT * FROM sales_to_salary_analysis;
SELECT * FROM support_rating_to_salary_analysis;
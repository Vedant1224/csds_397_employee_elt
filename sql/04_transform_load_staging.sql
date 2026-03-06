-- @author Vedant Gupta
-- Step 4: clean the raw data and load it into staging.

USE staging;

-- Make re-runs safe (FK-safe delete order)
DELETE FROM fact_support;
DELETE FROM fact_sales;
DELETE FROM fact_performance;
DELETE FROM fact_compensation;
DELETE FROM dim_employee;
DELETE FROM dim_country;
DELETE FROM dim_department;

-- 1) Department dimension: raw -> standard
INSERT INTO dim_department (dept_raw, dept_standard)
SELECT DISTINCT
  TRIM(department) AS dept_raw,
  CASE
    WHEN LOWER(TRIM(department)) IN ('sales','sale','sls','slaes','saless') THEN 'Sales'
    WHEN LOWER(TRIM(department)) IN ('support','supp','supprt','supportt','suport') THEN 'Support'
    WHEN LOWER(TRIM(department)) IN ('marketing','markting','marketingg','mkt','mktg') THEN 'Marketing'
    ELSE 'Other'
  END AS dept_standard
FROM sources.employee_raw;

-- 2) Country dimension: standardize case
INSERT INTO dim_country (country_raw, country_standard)
SELECT DISTINCT
  TRIM(country) AS country_raw,
  UPPER(TRIM(country)) AS country_standard
FROM sources.employee_raw;

-- 3) Clean raw into temp table
DROP TEMPORARY TABLE IF EXISTS tmp_clean;
CREATE TEMPORARY TABLE tmp_clean AS
SELECT
  CAST(TRIM(employee_id) AS UNSIGNED) AS employee_id,
  NULLIF(TRIM(name),'') AS full_name,

  CASE
    WHEN TRIM(age) REGEXP '^-?[0-9]+$' AND CAST(TRIM(age) AS SIGNED) BETWEEN 0 AND 120
      THEN CAST(TRIM(age) AS SIGNED)
    ELSE NULL
  END AS age,

  CASE
    WHEN TRIM(date_of_joining) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
      THEN STR_TO_DATE(TRIM(date_of_joining), '%Y-%m-%d')
    WHEN TRIM(date_of_joining) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
      THEN STR_TO_DATE(TRIM(date_of_joining), '%m/%d/%Y')
    WHEN TRIM(date_of_joining) REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
      THEN STR_TO_DATE(TRIM(date_of_joining), '%Y/%m/%d')
    WHEN TRIM(date_of_joining) REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
      THEN STR_TO_DATE(TRIM(date_of_joining), '%m-%d-%Y')
    ELSE NULL
  END AS join_date,

  CASE
    WHEN TRIM(years_of_experience) REGEXP '^-?[0-9]+$' AND CAST(TRIM(years_of_experience) AS SIGNED) BETWEEN 0 AND 80
      THEN CAST(TRIM(years_of_experience) AS SIGNED)
    ELSE NULL
  END AS years_experience,

  TRIM(department) AS dept_raw,
  TRIM(country) AS country_raw,

  CASE
    WHEN TRIM(salary) REGEXP '^-?[0-9]+(\\.[0-9]+)?$' AND CAST(TRIM(salary) AS DECIMAL(12,2)) >= 0
      THEN CAST(TRIM(salary) AS DECIMAL(12,2))
    ELSE NULL
  END AS salary,

  CASE
    WHEN TRIM(performance_rating) REGEXP '^[1-5]$' THEN CAST(TRIM(performance_rating) AS UNSIGNED)
    WHEN LOWER(TRIM(performance_rating)) = 'high performer' THEN 5
    WHEN LOWER(TRIM(performance_rating)) = 'medium high' THEN 4
    WHEN LOWER(TRIM(performance_rating)) = 'medium' THEN 3
    WHEN LOWER(TRIM(performance_rating)) = 'medium low' THEN 2
    WHEN LOWER(TRIM(performance_rating)) = 'low performer' THEN 1
    ELSE NULL
  END AS performance_rating,

  CASE
    WHEN TRIM(total_sales) REGEXP '^-?[0-9]+(\\.[0-9]+)?$' AND CAST(TRIM(total_sales) AS DECIMAL(14,2)) >= 0
      THEN CAST(TRIM(total_sales) AS DECIMAL(14,2))
    ELSE NULL
  END AS total_sales,

  CASE
    WHEN TRIM(support_rating) REGEXP '^[0-5]$' THEN CAST(TRIM(support_rating) AS UNSIGNED)
    ELSE NULL
  END AS support_rating
FROM sources.employee_raw;

-- 4) Deduplicate: keep best row per employee_id
-- Rule: latest join_date first; if tie, prefer non-null salary; if tie, higher performance_rating
DROP TEMPORARY TABLE IF EXISTS tmp_best;
CREATE TEMPORARY TABLE tmp_best AS
SELECT *
FROM (
  SELECT
    tc.*,
    ROW_NUMBER() OVER (
      PARTITION BY employee_id
      ORDER BY
        join_date DESC,
        (salary IS NOT NULL) DESC,
        salary DESC,
        performance_rating DESC
    ) AS rn
  FROM tmp_clean tc
) ranked
WHERE rn = 1;

-- 5) Load employee dimension
INSERT INTO dim_employee (employee_id, full_name, age, join_date, years_experience, dept_id, country_id)
SELECT
  b.employee_id,
  b.full_name,
  b.age,
  b.join_date,
  b.years_experience,
  d.dept_id,
  c.country_id
FROM tmp_best b
JOIN dim_department d ON d.dept_raw = b.dept_raw
JOIN dim_country c ON c.country_raw = b.country_raw;

-- 6) Load facts
INSERT INTO fact_compensation (employee_id, salary)
SELECT employee_id, salary
FROM tmp_best;

INSERT INTO fact_performance (employee_id, performance_rating)
SELECT employee_id, performance_rating
FROM tmp_best;

-- Sales only
INSERT INTO fact_sales (employee_id, total_sales)
SELECT b.employee_id, b.total_sales
FROM tmp_best b
JOIN dim_department d ON d.dept_raw = b.dept_raw
WHERE d.dept_standard = 'Sales';

-- Support only (ignore 0)
INSERT INTO fact_support (employee_id, support_rating)
SELECT b.employee_id, NULLIF(b.support_rating,0)
FROM tmp_best b
JOIN dim_department d ON d.dept_raw = b.dept_raw
WHERE d.dept_standard = 'Support';

-- Sanity counts
SELECT COUNT(*) AS staging_employees FROM dim_employee;
SELECT COUNT(*) AS staging_departments FROM dim_department;
SELECT COUNT(*) AS staging_countries FROM dim_country;
-- @author Vedant Gupta
-- Step 2: profile the raw sources table to see what’s broken before cleaning.

USE sources;

-- Basic counts
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT employee_id) AS distinct_employee_ids
FROM employee_raw;

-- Duplicate employee IDs (top 20)
SELECT employee_id, COUNT(*) AS cnt
FROM employee_raw
GROUP BY employee_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC, employee_id
LIMIT 20;

-- Missing values (key columns)
SELECT
  SUM(employee_id IS NULL OR TRIM(employee_id)='') AS missing_employee_id,
  SUM(name IS NULL OR TRIM(name)='')              AS missing_name,
  SUM(department IS NULL OR TRIM(department)='')  AS missing_department,
  SUM(date_of_joining IS NULL OR TRIM(date_of_joining)='') AS missing_join_date,
  SUM(salary IS NULL OR TRIM(salary)='')          AS missing_salary
FROM employee_raw;

-- Department value distribution (= unexpected categories)
SELECT department, COUNT(*) AS cnt
FROM employee_raw
GROUP BY department
ORDER BY cnt DESC;

-- Standardizing date format patterns (multiple formats show up in the raw file)
SELECT
  SUM(date_of_joining REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$') AS fmt_yyyy_mm_dd,
  SUM(date_of_joining REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$') AS fmt_mm_dd_yyyy_slash,
  SUM(date_of_joining REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$') AS fmt_yyyy_mm_dd_slash,
  SUM(date_of_joining REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$') AS fmt_mm_dd_yyyy_dash,
  SUM(date_of_joining IS NULL OR TRIM(date_of_joining)='')   AS missing
FROM employee_raw;

-- Performance rating distribution (mix of numbers + text labels)
SELECT performance_rating, COUNT(*) AS cnt
FROM employee_raw
GROUP BY performance_rating
ORDER BY cnt DESC;
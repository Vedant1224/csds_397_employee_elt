CREATE DATABASE IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.salary_to_department_analysis;

CREATE TABLE gold.salary_to_department_analysis AS
SELECT
    department,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS avg_salary
FROM staging.vw_employee_clean
WHERE salary IS NOT NULL
  AND department IS NOT NULL
GROUP BY department
ORDER BY avg_salary DESC;

SELECT * FROM gold.salary_to_department_analysis;

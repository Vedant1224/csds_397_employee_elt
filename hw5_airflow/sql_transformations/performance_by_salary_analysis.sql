CREATE DATABASE IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.performance_by_salary_analysis;

CREATE TABLE gold.performance_by_salary_analysis AS
SELECT
    performance_rating,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS avg_salary
FROM staging.vw_employee_clean
WHERE salary IS NOT NULL
  AND performance_rating IS NOT NULL
GROUP BY performance_rating
ORDER BY performance_rating;

SELECT * FROM gold.performance_by_salary_analysis;

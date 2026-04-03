CREATE DATABASE IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.salary_to_country_analysis;

CREATE TABLE gold.salary_to_country_analysis AS
SELECT
    country,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS avg_salary
FROM staging.vw_employee_clean
WHERE salary IS NOT NULL
  AND country IS NOT NULL
GROUP BY country
ORDER BY avg_salary DESC;

SELECT * FROM gold.salary_to_country_analysis;

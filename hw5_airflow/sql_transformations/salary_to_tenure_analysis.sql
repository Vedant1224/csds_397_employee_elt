CREATE DATABASE IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.salary_to_tenure_analysis;

CREATE TABLE gold.salary_to_tenure_analysis AS
SELECT
    CONCAT(FLOOR(years_of_experience / 3) * 3, ' to ', FLOOR(years_of_experience / 3) * 3 + 2) AS experience_bucket,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS avg_salary
FROM staging.vw_employee_clean
WHERE salary IS NOT NULL
  AND years_of_experience IS NOT NULL
GROUP BY experience_bucket
ORDER BY MIN(years_of_experience);

SELECT * FROM gold.salary_to_tenure_analysis;

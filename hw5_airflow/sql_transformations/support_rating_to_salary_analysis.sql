CREATE DATABASE IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.support_rating_to_salary_analysis;

CREATE TABLE gold.support_rating_to_salary_analysis AS
SELECT
    support_rating,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS avg_salary
FROM staging.vw_employee_clean
WHERE department = 'Support'
  AND salary IS NOT NULL
  AND support_rating IS NOT NULL
  AND support_rating <> 0
GROUP BY support_rating
ORDER BY support_rating;

SELECT * FROM gold.support_rating_to_salary_analysis;

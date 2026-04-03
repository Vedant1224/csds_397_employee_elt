CREATE DATABASE IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.sales_to_salary_analysis;

CREATE TABLE gold.sales_to_salary_analysis AS
SELECT
    CONCAT(FLOOR(total_sales / 50000) * 50000, ' to ', FLOOR(total_sales / 50000) * 50000 + 49999) AS sales_bucket,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(AVG(total_sales), 2) AS avg_total_sales
FROM staging.vw_employee_clean
WHERE department = 'Sales'
  AND salary IS NOT NULL
  AND total_sales IS NOT NULL
  AND total_sales <> 0
GROUP BY sales_bucket
ORDER BY MIN(total_sales);

SELECT * FROM gold.sales_to_salary_analysis;

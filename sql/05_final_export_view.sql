-- @author Vedant Gupta
-- Step 5: create a final clean view to export for analysis.

USE staging;

DROP VIEW IF EXISTS vw_employee_clean;

CREATE VIEW vw_employee_clean AS
SELECT
  e.employee_id AS employee_id,
  e.full_name AS name,
  e.age,
  d.dept_standard AS department,
  e.join_date AS date_of_joining,
  e.years_experience AS years_of_experience,
  c.country_standard AS country,
  comp.salary,
  perf.performance_rating,
  sales.total_sales,
  sup.support_rating
FROM dim_employee e
JOIN dim_department d ON e.dept_id = d.dept_id
JOIN dim_country c ON e.country_id = c.country_id
LEFT JOIN fact_compensation comp ON e.employee_id = comp.employee_id
LEFT JOIN fact_performance perf ON e.employee_id = perf.employee_id
LEFT JOIN fact_sales sales ON e.employee_id = sales.employee_id
LEFT JOIN fact_support sup ON e.employee_id = sup.employee_id;
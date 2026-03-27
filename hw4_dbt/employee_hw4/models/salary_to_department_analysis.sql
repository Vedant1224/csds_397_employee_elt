select
  department,
  count(*) as employee_count,
  round(avg(salary), 2) as avg_salary
from {{ source('employee_source', 'employee_clean_hw4') }}
where salary is not null
  and department is not null
group by department
order by avg_salary desc
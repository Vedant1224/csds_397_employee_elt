select
  performance_rating,
  count(*) as employee_count,
  round(avg(salary), 2) as avg_salary
from {{ source('employee_source', 'employee_clean_hw4') }}
where salary is not null
  and performance_rating is not null
group by performance_rating
order by performance_rating
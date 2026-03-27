select
  support_rating,
  count(*) as employee_count,
  round(avg(salary), 2) as avg_salary
from {{ source('employee_source', 'employee_clean_hw4') }}
where department = 'Support'
  and salary is not null
  and support_rating is not null
  and support_rating <> 0
group by support_rating
order by support_rating
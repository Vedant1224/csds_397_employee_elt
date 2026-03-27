select
  concat(floor(years_of_experience / 3) * 3, ' to ', floor(years_of_experience / 3) * 3 + 2) as experience_bucket,
  count(*) as employee_count,
  round(avg(salary), 2) as avg_salary
from {{ source('employee_source', 'employee_clean_hw4') }}
where salary is not null
  and years_of_experience is not null
group by experience_bucket
order by min(years_of_experience)
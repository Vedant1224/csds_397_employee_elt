select
  concat(floor(total_sales / 50000) * 50000, ' to ', floor(total_sales / 50000) * 50000 + 49999) as sales_bucket,
  count(*) as employee_count,
  round(avg(salary), 2) as avg_salary,
  round(avg(total_sales), 2) as avg_total_sales
from {{ source('employee_source', 'employee_clean_hw4') }}
where department = 'Sales'
  and salary is not null
  and total_sales is not null
  and total_sales <> 0
group by sales_bucket
order by min(total_sales)
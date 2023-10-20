-- Use the `ref` function to select from other models

select *
from ANALYTICS.dbt.first_model
where id = 1
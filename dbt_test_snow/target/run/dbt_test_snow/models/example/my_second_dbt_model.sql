
  
    

        create or replace transient table ANALYTICS.dbt.my_second_dbt_model
         as
        (-- Use the `ref` function to select from other models

select *
from ANALYTICS.dbt.first_model
where id = 1
        );
      
  
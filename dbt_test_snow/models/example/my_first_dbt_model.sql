
/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

{{ config(materialized='table', alias = 'first_model') }}

with source_data as (

    select 1 as id
    union all
    select null as id

)


-- SELECT * FROM source_data


SELECT *, {{ var('my_first_variable') }} as first_variable
FROM source_data
WHERE id >= {{ var('my_third_variable') }}


/*
    Uncomment the line below to remove records with null `id` values
*/

-- where id is not null

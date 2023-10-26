# dbt tutorial

dbt is a transformation workflow that helps you get more work done while producing higher quality results.

## Concepts

### dbt models
Models are primarily written as a select statement and saved as a .sql file.

A model is a function that reads in dbt sources or other models, applies a series of transformations, and returns a transformed dataset.

You can build dependencies between models by using the ref function

```
with customer_orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders

    from jaffle_shop.orders

    group by 1
)

select
    customers.customer_id,
    customers.first_name,
    customers.last_name,
    customer_orders.first_order_date,
    customer_orders.most_recent_order_date,
    coalesce(customer_orders.number_of_orders, 0) as number_of_orders

from jaffle_shop.customers

left join customer_orders using (customer_id)
```

### materializations

Materializations are strategies for persisting dbt models in a warehouse. There are five types of materializations built into dbt. They are:
- table
- view
- incremental
- ephemeral
- materialized view

### seeds 
Seeds are CSV files in your dbt project (typically in your seeds directory), that dbt can load into your data warehouse using the dbt seed command.

Good use-cases for seeds:
- A list of mappings of country codes to country names
- A list of test emails to exclude from analysis
- A list of employee account IDs

### sources

Sources make it possible to name and describe the data loaded into your warehouse by your Extract and Load tools. By declaring these tables as sources in dbt, you can then:
- select from source tables in your models using the {{ source() }} function, helping define the lineage of your data
- test your assumptions about your source data
- calculate the freshness of your source data

Example:
```
version: 2

sources:
  - name: jaffle_shop
    database: raw  
    schema: jaffle_shop  
    tables:
      - name: orders
      - name: customers

  - name: stripe
    tables:
      - name: payments
```

### snapshots 

Analysts often need to "look back in time" at previous data states in their mutable tables. While some source data systems are built in a way that makes accessing historical data possible, this is not always the case. dbt provides a mechanism, snapshots, which records changes to a mutable table over time.

Snapshots implement type-2 Slowly Changing Dimensions over mutable source tables. These Slowly Changing Dimensions (or SCDs) identify how a row in a table changes over time.

id | status	| updated_at	| dbt_valid_from	| dbt_valid_to
1	 | pending|	2019-01-01	| 2019-01-01	    | 2019-01-02
1	 | shipped|	2019-01-02	| 2019-01-02	    | null

```
{% snapshot orders_snapshot %}

{{
    config(
      target_database='analytics',
      target_schema='snapshots',
      unique_key='id',

      strategy='timestamp',
      updated_at='updated_at',
    )
}}

select * from {{ source('jaffle_shop', 'orders') }}

{% endsnapshot %}
```

### tests

Tests are assertions you make about your models and other resources in your dbt project (e.g. sources, seeds and snapshots). When you run dbt test, dbt will tell you if each test in your project passes or fails.

You can use tests to improve the integrity of the SQL in each model by making assertions about the results generated.

Out of the box, dbt ships with four generic tests already defined: unique, not_null, accepted_values and relationships. Here's a full example using those tests on an orders model:

```
version: 2

models:
  - name: orders
    columns:
      - name: order_id
        tests:
          - unique
          - not_null
      - name: status
        tests:
          - accepted_values:
              values: ['placed', 'shipped', 'completed', 'returned']
      - name: customer_id
        tests:
          - relationships:
              to: ref('customers')
              field: id
```

#### Singular tests

These tests are defined in .sql files, typically in your tests directory

```
select
    order_id,
    sum(amount) as total_amount
from {{ ref('fct_payments' )}}
group by 1
having not(total_amount >= 0)
```

#### Generic tests

Certain tests are generic: they can be reused over and over again. A generic test is defined in a test block, which contains a parametrized query and accepts arguments. It might look like:

```
{% test not_null(model, column_name) %}

    select *
    from {{ model }}
    where {{ column_name }} is null

{% endtest %}
```

You'll notice that there are two arguments, model and column_name, which are then templated into the query. This is what makes the test "generic": it can be defined on as many columns as you like, across as many models as you like, and dbt will pass the values of model and column_name accordingly.

### Jinja and macros

In dbt, you can combine SQL with Jinja, a templating language.

Using Jinja turns your dbt project into a programming environment for SQL, giving you the ability to do things that aren't normally possible in SQL. For example, with Jinja you can:
- Use control structures (e.g. if statements and for loops) in SQL
- Use environment variables in your dbt project for production deployments
- Change the way your project builds based on the current target.

```
{% set payment_methods = ["bank_transfer", "credit_card", "gift_card"] %}

select
    order_id,
    {% for payment_method in payment_methods %}
    sum(case when payment_method = '{{payment_method}}' then amount end) as {{payment_method}}_amount,
    {% endfor %}
    sum(amount) as total_amount
from app_data.payments
group by 1
```

Macros in Jinja are pieces of code that can be reused multiple times – they are analogous to "functions" in other programming languages, and are extremely useful if you find yourself repeating code across multiple models. Macros are defined in .sql files, typically in your macros directory (docs).

```
{% macro cents_to_dollars(column_name, scale=2) %}
    ({{ column_name }} / 100)::numeric(16, {{ scale }})
{% endmacro %}
```

```
select
  id as payment_id,
  {{ cents_to_dollars('amount') }} as amount_usd,
  ...
from app_data.payments
```

## use postgresql

### run postgras container

```
port			5432
POSTGRES_USER		postgres
POSTGRES_PASSWORD	postpass
POSTGRES_HOST_AUTH_METHOD trust
```

### run pgadmin container

https://hub.docker.com/r/dpage/pgadmin4/

```
Name: 		pgadmin
HOST PORT: 	1234:80
PGADMIN_DEFAULT_EMAIL: test@test.com
PGADMIN_DEFAULT_PASSWORD: postpass
```

### connect containers

```
docker network ls
docker network create --driver bridge pgnetwork
docker network connect pgnetwork pgadmin
docker network connect pgnetwork postgres
docker network inspect pgnetwork
```

### setup db

http://localhost:1234/browser/

```
Add Server: 	General
Name: 		postgres
Connection
Hostname: 	postgres
Port: 		5432
database: 	postgres
username: 	postgres
password: 	password you have defined

create database:	testdb
schema:			dbt_schema
```


## install dbt

https://docs.getdbt.com/docs/core/pip-install

### enable longpath in Windowns

New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
-Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force

### install

```
pip install dbt-core
pip install dbt-postgres
pip install dbt-snowflake
```

### initialize

```
dbt init dbt_test   # postgresql
dbt init dbt_test_snow  # snowflake
```

### connect to database

https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup

```
dbt debug --config-dir
edit C:\Users\kjezak\.dbt\profiles.yml
dbt_test:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      user: postgres
      password: postpass
      port: 5432
      dbname: testdb
      schema: dbt_schema
      threads: 1
      keepalives_idle: 0 # default 0, indicating the system default. See below
      connect_timeout: 5 # default 10 seconds
      retries: 1  # default 1 retry on error/timeout when opening connections
```

### test connecto to postgresql

```
cd C:\Krzys\git-krzysztof\dbt-test\dbt_test
dbt debug
```

### debug

```
Test-NetConnection localhost -Port 5432
```

### run

```
dbt run
```


## connect to snowflake

### login to snowflake
https://cifynsh-gya10556.snowflakecomputing.com/console/login

```
username:   krzysztofj
password:   
```

Switch role to: ACCOUNTADMIN

Warehouse:  TRANSFORM_WH  size: x-small

User: transform_user
Password: Password123
Role:   TRANSFORM_ROLE
Database:   ANALYTICS
Schema:     dbt

### created profile

/home/kj/.dbt/profiles.yml 

```
dbt_test_snow:
  outputs:
    dev:
      account: cifynsh-gya10556
      database: ANALYTICS
      password: Password123
      role: TRANSFORM_ROLE
      schema: dbt
      threads: 1
      type: snowflake
      user: transform_user
      warehouse: TRANSFORM_WH
      client_session_keep_alive: False
  target: dev
```

### test snowflake-dbt config

test

```
cd dbt_test_snow
dbt debug
```

run

```
dbt run
```


test

```
dbt test
```



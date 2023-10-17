# dbt tutorial

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
```

### initialize

```
dbt init dbt_test
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

### create database: Data -> Databases




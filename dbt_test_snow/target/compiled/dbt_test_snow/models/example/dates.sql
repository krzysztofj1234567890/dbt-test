

SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.DATE_DIM
WHERE d_date <= current_date


    and d_date > (SELECT max(d_date) FROM ANALYTICS.dbt.dates )

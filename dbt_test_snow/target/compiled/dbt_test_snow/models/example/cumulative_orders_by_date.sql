SELECT DISTINCT
    o_orderdate,
    sum(o_totalprice) OVER (order by o_orderdate) AS cumulative_sales
FROM "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."ORDERS"
ORDER BY o_orderdate
{# SQE read_parquet over a dlt-landed folder (directory form; SQE rejects globs). #}
{% macro cbs_landing(table_name) %}
    read_parquet('{{ var("cbs_landing_url") }}/{{ table_name }}/')
{% endmacro %}

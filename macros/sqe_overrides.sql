{% macro trino__list_relations_without_caching(schema_relation) %}
  {% call statement('list_relations_without_caching', fetch_result=True) -%}
    select
      t.table_catalog as database,
      t.table_name as name,
      t.table_schema as schema,
      case when t.table_type = 'BASE TABLE' then 'table'
           when t.table_type = 'VIEW' then 'view'
           else t.table_type
      end as table_type
    from {{ schema_relation.information_schema_only() }}.tables t
    where t.table_schema = '{{ schema_relation.schema }}'
  {%- endcall %}
  {{ return(load_result('list_relations_without_caching').table) }}
{% endmacro %}

{% macro filter_sparse_rows(columns, max_nulls=10) %}

(
    {% for col in columns %}
        IFF({{ col }} IS NULL, 1, 0)
        {% if not loop.last %} + {% endif %}
    {% endfor %}
) <= {{ max_nulls }}

{% endmacro %}

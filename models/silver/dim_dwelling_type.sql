select key as dwelling_type_key, title as dwelling_type
from {{ ref('br_dwelling_types') }}

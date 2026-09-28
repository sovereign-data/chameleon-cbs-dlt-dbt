select cast(key as varchar) as key, cast(title as varchar) as title
from {{ cbs_landing('energy_tariffs__btw') }}

select cast(key as varchar) as key, cast(title as varchar) as title
from {{ cbs_landing('energy_use_dwellings__woningkenmerken') }}

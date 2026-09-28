-- Period keys are 'YYYYJJ00' (yearly) for this table.
select
    cast(substr(period_key, 1, 4) as integer) as year,
    region_key,
    dwelling_type_key,
    gas_m3,
    electricity_kwh,
    net_electricity_kwh,
    district_heating_pct
from {{ ref('br_energy_use_dwellings') }}
where substr(period_key, 5, 2) = 'JJ'

select
    cast(woningkenmerken as varchar)                         as dwelling_type_key,
    cast(regio_s as varchar)                                 as region_key,
    cast(perioden as varchar)                                as period_key,
    cast(gemiddeld_aardgasverbruik_1 as double)              as gas_m3,
    cast(gemiddelde_elektriciteitslevering_2 as double)      as electricity_kwh,
    cast(gemiddelde_netto_elektriciteitslevering_3 as double) as net_electricity_kwh,
    cast(stadsverwarming_4 as double)                        as district_heating_pct
from {{ cbs_landing('energy_use_dwellings') }}

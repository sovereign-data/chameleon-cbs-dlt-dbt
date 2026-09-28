select
    cast(btw as varchar)                                       as vat_key,
    cast(perioden as varchar)                                  as period_key,
    cast(transporttarief_1 as double)                          as gas_transport_eur_year,
    cast(vast_leveringstarief_vaste_en_var_2 as double)        as gas_fixed_supply_eur_year,
    cast(variabel_leveringstarief_contractprijs_3 as double)   as gas_price_eur_m3,
    cast(opslag_duurzame_energie_ode_5 as double)              as gas_ode_eur_m3,
    cast(energiebelasting_6 as double)                         as gas_tax_eur_m3,
    cast(transporttarief_7 as double)                          as elec_transport_eur_year,
    cast(vast_leveringstarief_vaste_en_var_8 as double)        as elec_fixed_supply_eur_year,
    cast(variabel_leveringstarief_contractprijs_9 as double)   as elec_price_eur_kwh,
    cast(opslag_duurzame_energie_ode_13 as double)             as elec_ode_eur_kwh,
    cast(energiebelasting_14 as double)                        as elec_tax_eur_kwh,
    cast(vermindering_energiebelasting_15 as double)           as tax_reduction_eur_year
from {{ cbs_landing('energy_tariffs') }}

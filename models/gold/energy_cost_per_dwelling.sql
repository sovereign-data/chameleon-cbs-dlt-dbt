-- Estimated yearly energy bill (EUR, incl. VAT) of an average dwelling, per
-- municipality/province and dwelling type: CBS average use x CBS average
-- tariffs of that year. Only years with both use and tariffs survive the join.
with cost as (
    select
        u.year,
        u.region_key,
        u.dwelling_type_key,
        u.gas_m3,
        coalesce(u.net_electricity_kwh, u.electricity_kwh) as electricity_kwh,
        coalesce(u.gas_m3, 0) * t.gas_variable_eur_m3
            + t.gas_transport_eur_year + t.gas_fixed_supply_eur_year as gas_cost_eur,
        coalesce(u.net_electricity_kwh, u.electricity_kwh, 0) * t.elec_variable_eur_kwh
            + t.elec_transport_eur_year + t.elec_fixed_supply_eur_year as electricity_cost_eur,
        t.tax_reduction_eur_year
    from {{ ref('fct_energy_use_yearly') }} u
    join {{ ref('fct_energy_tariff_yearly') }} t on t.year = u.year
)
select
    c.year,
    r.region_key,
    r.region_name,
    r.region_level,
    d.dwelling_type,
    c.gas_m3,
    c.electricity_kwh,
    round(c.gas_cost_eur, 2)                                                   as gas_cost_eur,
    round(c.electricity_cost_eur, 2)                                           as electricity_cost_eur,
    round(c.gas_cost_eur + c.electricity_cost_eur + c.tax_reduction_eur_year, 2) as total_cost_eur
from cost c
join {{ ref('dim_region') }} r on r.region_key = c.region_key
join {{ ref('dim_dwelling_type') }} d on d.dwelling_type_key = c.dwelling_type_key
where r.region_level in ('country', 'province', 'municipality')

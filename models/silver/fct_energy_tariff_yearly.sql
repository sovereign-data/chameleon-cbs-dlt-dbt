-- Yearly average of the monthly ('YYYYMMnn') consumer tariffs, VAT included.
-- ODE (opslag duurzame energie) was abolished in 2023: CBS reports it as NULL.
select
    cast(substr(t.period_key, 1, 4) as integer) as year,
    count(*)                         as months,
    avg(gas_transport_eur_year)      as gas_transport_eur_year,
    avg(gas_fixed_supply_eur_year)   as gas_fixed_supply_eur_year,
    avg(gas_price_eur_m3 + coalesce(gas_ode_eur_m3, 0) + gas_tax_eur_m3)       as gas_variable_eur_m3,
    avg(elec_transport_eur_year)     as elec_transport_eur_year,
    avg(elec_fixed_supply_eur_year)  as elec_fixed_supply_eur_year,
    avg(elec_price_eur_kwh + coalesce(elec_ode_eur_kwh, 0) + elec_tax_eur_kwh) as elec_variable_eur_kwh,
    avg(tax_reduction_eur_year)      as tax_reduction_eur_year
from {{ ref('br_energy_tariffs') }} t
join {{ ref('br_vat') }} v on v.key = t.vat_key
where v.title = 'Inclusief btw'
  and substr(t.period_key, 5, 2) = 'MM'
group by 1

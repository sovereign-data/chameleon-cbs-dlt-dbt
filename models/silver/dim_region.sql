select
    key as region_key,
    title as region_name,
    case substr(key, 1, 2)
        when 'NL' then 'country'
        when 'LD' then 'landsdeel'
        when 'PV' then 'province'
        when 'GM' then 'municipality'
        else 'other'
    end as region_level
from {{ ref('br_regions') }}

select
    country_id,
    country_name,
    country_code
from {{source('raw', 'countries')}}
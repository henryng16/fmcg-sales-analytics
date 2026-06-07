select
    city_id,
    city_name,
    zipcode,
    country_id
from {{source('raw', 'cities')}}
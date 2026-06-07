select
    customer_id,
    first_name,
    middle_initial,
    last_name,
    city_id,
    address
from {{source('raw', 'customers')}}

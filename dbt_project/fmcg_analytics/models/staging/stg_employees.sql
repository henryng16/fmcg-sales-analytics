select
    employee_id,
    first_name,
    middle_initial,
    last_name,
    birth_date,
    gender,
    city_id,
    hire_date
from {{source('raw', 'employees')}}
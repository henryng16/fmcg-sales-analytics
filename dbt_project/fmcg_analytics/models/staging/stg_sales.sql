-- cast sales_date to date (raw has timestamp)
-- total_price is 0 in raw data - will fix in intermediate
-- business logic (calculating revenue) belongs in intermediate layer
select
    sales_id,
    sales_person_id,
    customer_id,
    product_id,
    quantity,
    discount,
    total_price,
    sales_date,
    transaction_number
from {{source('raw', 'sales')}}
-- cast vitality_days to integer (stored as decimal in raw)

select
    product_id,
    product_name,
    price,
    category_id,
    class,
    modify_date,
    resistant,
    is_allergic,
    vitality_days::int as vitality_days
from {{source('raw', 'products')}}
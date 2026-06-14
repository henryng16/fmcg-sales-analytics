{{ config(materialized='table')}}

with sales as (
    select
        sales_id,
        sales_date,
        sales_person_id,
        customer_id,
        product_id,
        quantity,
        discount,
        transaction_number
    from {{ ref('stg_sales')}}
),

products as (
    select
        product_id,
        category_id,
        price as unit_price
    from {{ref('stg_products')}}
),

joined as (
    select
        s.sales_id,
        s.sales_date,
        s.sales_person_id,
        s.customer_id,
        s.product_id,
        p.category_id,
        s.quantity,
        p.unit_price,
        s.discount,

        --Reusable measures, computed once at the fact grain (DRY),
        --Marts just aggregate these, never re-derive the formula
        (p.unit_price * s.quantity)::numeric(12,2)
            as gross_revenue,
        (p.unit_price * s.quantity * s.discount)::numeric(12,2)
            as discount_amount,
        (p.unit_price * s.quantity * (1-s.discount))::numeric(12,2)
            as net_revenue,
        
        s.transaction_number
    from sales s
    inner join products p
        on s.product_id = p.product_id
)

select * from joined
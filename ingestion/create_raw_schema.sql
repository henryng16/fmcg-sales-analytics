-- create_raw_schema.sql
-- Defines the raw-layer tables that the ingestion script (load_csv_to_postgres.py)
-- loads the CSVs into. Run this ONCE before the first load.
--
-- Idempotent: DROP ... IF EXISTS at the top means re-running rebuilds cleanly.
-- Parent tables (countries, cities, categories) are created before the children
-- that reference them, so the foreign keys resolve.

drop table if exists
    raw.sales,
    raw.customers,
    raw.employees,
    raw.products,
    raw.cities,
    raw.countries,
    raw.categories
cascade;

create table raw.countries (
    country_id   int primary key,
    country_name varchar(45),
    country_code varchar(2)
);

create table raw.cities (
    city_id    int primary key,
    city_name  varchar(45),
    zipcode    varchar(5),                                   -- FIX: was decimal(5,0).
                                                             -- Zip codes are identifiers, not numbers;
                                                             -- numeric would drop leading zeros (07039 -> 7039).
    country_id int references raw.countries(country_id)
);

create table raw.categories (
    category_id   int primary key,
    category_name varchar(45)
);

create table raw.customers (
    customer_id    int primary key,
    first_name     varchar(45),
    middle_initial varchar(1),
    last_name      varchar(45),
    city_id        int references raw.cities(city_id),
    address        varchar(90)
);

create table raw.employees (
    employee_id    int primary key,
    first_name     varchar(45),
    middle_initial varchar(45),
    last_name      varchar(45),
    birth_date     date,
    gender         varchar(1),
    city_id        int references raw.cities(city_id),
    hire_date      date                                     -- matches the HireDate CSV column directly
                                                             -- (no more address->hire_date rename hack)
);

create table raw.products (
    product_id    int primary key,
    product_name  varchar(45),
    price         decimal(10,4),                             -- FIX: was decimal(10,0), which ROUNDED every
                                                             -- price to a whole number (74.2988 -> 74) and
                                                             -- silently corrupted all downstream revenue.
    category_id   int references raw.categories(category_id),
    class         varchar(45),
    modify_date   date,
    resistant     varchar(45),
    is_allergic   varchar(10),
    vitality_days decimal(5,1)                               -- FIX: was decimal(3,0). Source has values like
                                                             -- 111.0; widened + 1 decimal to avoid truncation.
);

create table raw.sales (
    sales_id           int primary key,
    sales_person_id    int,
    customer_id        int,
    product_id         int,
    quantity           int,
    discount           decimal(10,2),
    total_price        decimal(10,2),                        -- 0 for all source rows; real revenue is derived
                                                             -- later in the dbt intermediate layer.
    sales_date         timestamp,
    transaction_number varchar(155)
);

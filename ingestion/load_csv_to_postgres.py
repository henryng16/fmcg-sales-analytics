import os
import time
# pyrefly: ignore [missing-import]
from sqlalchemy import create_engine, text
# pyrefly: ignore [missing-import]
from dotenv import load_dotenv
load_dotenv() # reads .env into environment variables automatically

# configuration
# Format: postgresql://USER:PASSWORD@HOST:PORT/DATABASE
DB_URL = os.environ.get("DATABASE_URL")
if not DB_URL:
    raise ValueError(
        "DATABASE_URL is not set. Add it to your .env file or export it."
    )

# Where all the csvs live
DATA_DIR = os.path.expanduser("~/projects/fmcg-sales-analytics/data")

# Parent tables must load before child tables
LOAD_ORDER = [
    "countries",
    "cities",
    "categories",
    "customers",
    "employees",
    "products",
    "sales",
]

# Column mapping: CSV header → database column name
COLUMN_MAP = {
    "countries": {
        "CountryID": "country_id",
        "CountryName": "country_name",
        "CountryCode": "country_code",
    },
    "cities": {
        "CityID": "city_id",
        "CityName": "city_name",
        "Zipcode": "zipcode",
        "CountryID": "country_id",
    },
    "categories": {
        "CategoryID": "category_id",
        "CategoryName": "category_name",
    },
    "customers": {
        "CustomerID": "customer_id",
        "FirstName": "first_name",
        "MiddleInitial": "middle_initial",
        "LastName": "last_name",
        "CityID": "city_id",
        "Address": "address",
    },
    "employees": {
        "EmployeeID": "employee_id",
        "FirstName": "first_name",
        "MiddleInitial": "middle_initial",
        "LastName": "last_name",
        "BirthDate": "birth_date",
        "Gender": "gender",
        "CityID": "city_id",
        "HireDate": "hire_date",
    },
    "products": {
        "ProductID": "product_id",
        "ProductName": "product_name",
        "Price": "price",
        "CategoryID": "category_id",
        "Class": "class",
        "ModifyDate": "modify_date",
        "Resistant": "resistant",
        "IsAllergic": "is_allergic",
        "VitalityDays": "vitality_days",
    },
    "sales": {
        "SalesID": "sales_id",
        "SalesPersonID": "sales_person_id",
        "CustomerID": "customer_id",
        "ProductID": "product_id",
        "Quantity": "quantity",
        "Discount": "discount",
        "TotalPrice": "total_price",
        "SalesDate": "sales_date",
        "TransactionNumber": "transaction_number",
    },
}


def load_table(engine, table_name: str) -> None:
    csv_path = os.path.join(DATA_DIR, f"{table_name}.csv")
    column_map  = COLUMN_MAP[table_name]

    start = time.time()

    # Read CSV and rename headers
    with open(csv_path, "r", encoding="utf-8") as f:
        original_header = f.readline().strip().split(",")
        # Map camelcase -> snake_case using column_map
        new_header = [column_map[col] for col in original_header]
        remaining_data = f.read()
    
    # Create a temporary CSV with snake_case headers
    temp_path = csv_path + ".tmp"
    with open(temp_path, "w", encoding="utf-8") as f:
        cleaned_data = remaining_data.replace('"NULL"','').replace(',NULL,',',,').replace(',NULL\n','\n,')
        f.write(",".join(new_header) + "\n")
        f.write(cleaned_data)

    # Clear old data (makes this idempotent - safe to re-run)
    with engine.connect() as conn:
        conn.execute(text(f"TRUNCATE TABLE raw.{table_name} CASCADE"))
        conn.commit()

    # Bulk-load using PostgreSQL COPY
    with open(temp_path, "r", encoding="utf-8") as f:
        raw_conn =  engine.raw_connection()
        cursor = raw_conn.cursor()
        cursor.copy_expert(
            f"COPY raw.{table_name} FROM STDIN WITH CSV HEADER",
            f
        )
        raw_conn.commit()
        cursor.close()
        raw_conn.close()
    
    # Clean up temp file
    os.remove(temp_path)

    # Report results
    elapsed = time.time() - start
    with engine.connect() as conn:
        result = conn.execute(text(f"SELECT count(*) FROM raw.{table_name}"))
        count = result.scalar()
        print(f"Loaded raw.{table_name}: {count:>10,} rows ({elapsed:.1f}s)")


def main() -> None:
    print("Starting data load...\n")
    engine = create_engine(DB_URL)

    for table_name in LOAD_ORDER:
        load_table(engine, table_name)

    print("\nAll data loaded successfully!")

if __name__ == "__main__":
    main()



    
    
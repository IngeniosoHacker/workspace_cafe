CREATE SCHEMA IF NOT EXISTS datamart;


-- DIM_RESTAURANT

CREATE TABLE IF NOT EXISTS datamart.dim_restaurant (
    restaurant_sk SERIAL PRIMARY KEY,
    restaurant_id TEXT UNIQUE,
    restaurant_name TEXT,
    subzone TEXT,
    city TEXT,
    first_seen TIMESTAMP DEFAULT NOW(),
    last_seen TIMESTAMP DEFAULT NOW()
);


-- DIM_LOCATION  

CREATE TABLE IF NOT EXISTS datamart.dim_location (
    location_sk SERIAL PRIMARY KEY,
    city TEXT,
    subzone TEXT,
    location_name TEXT,
    UNIQUE(city, subzone, location_name)
);


-- DIM_CUSTOMER

CREATE TABLE IF NOT EXISTS datamart.dim_customer (
    customer_sk SERIAL PRIMARY KEY,
    customer_id TEXT UNIQUE,
    first_seen TIMESTAMP DEFAULT NOW(),
    last_seen TIMESTAMP DEFAULT NOW()
);

-- DIM_ITEM (a futuro)

CREATE TABLE IF NOT EXISTS datamart.dim_item (
    item_sk SERIAL PRIMARY KEY,
    item_name TEXT UNIQUE,
    first_seen TIMESTAMP DEFAULT NOW(),
    last_seen TIMESTAMP DEFAULT NOW()
);


-- DIM_DATE

CREATE TABLE IF NOT EXISTS datamart.dim_date (
    date_sk SERIAL PRIMARY KEY,
    date_id DATE UNIQUE,
    year INT,
    quarter INT,
    month INT,
    month_name TEXT,
    day INT,
    weekday INT,
    is_weekend BOOLEAN
);

-- Función para poblar fechas
CREATE OR REPLACE FUNCTION datamart.fn_populate_dim_date(start_date DATE, end_date DATE)
RETURNS VOID AS
$$
BEGIN
    INSERT INTO datamart.dim_date (date_id, year, quarter, month, month_name, day, weekday, is_weekend)
    SELECT d,
           EXTRACT(YEAR FROM d),
           EXTRACT(QUARTER FROM d),
           EXTRACT(MONTH FROM d),
           TO_CHAR(d, 'Month'),
           EXTRACT(DAY FROM d),
           EXTRACT(DOW FROM d),
           EXTRACT(DOW FROM d) IN (0,6)
    FROM generate_series(start_date, end_date, '1 day') d
    ON CONFLICT (date_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- 1. Cargar CSV a tabla staging 
TRUNCATE staging_orders;

COPY staging_orders
FROM '/Users/ginebraestrada/Documents/cafeteria/workspace_cafe/datamart/raw/order_history_kaggle_data.csv'
DELIMITER ','
CSV HEADER;

-- 2. Poblar dim_location
INSERT INTO dim_location (subzone, city)
SELECT DISTINCT subzone, city
FROM staging_orders
ON CONFLICT DO NOTHING;

-- 3. Poblar dim_restaurant
INSERT INTO dim_restaurant (restaurant_id, restaurant_name, location_sk)
SELECT DISTINCT 
    restaurant_id,
    restaurant_name,
    l.location_sk
FROM staging_orders s
JOIN dim_location l ON s.subzone = l.subzone AND s.city = l.city
ON CONFLICT DO NOTHING;

-- 4. Poblar dim_customer
INSERT INTO dim_customer (customer_id)
SELECT DISTINCT customer_id
FROM staging_orders
ON CONFLICT DO NOTHING;

-- 5. Poblar dim_date
INSERT INTO dim_date (date_actual, year, month, day)
SELECT DISTINCT
    order_placed_at::date,
    EXTRACT(YEAR FROM order_placed_at),
    EXTRACT(MONTH FROM order_placed_at),
    EXTRACT(DAY FROM order_placed_at)
FROM staging_orders
ON CONFLICT DO NOTHING;

-- 6. Poblar fact_orders
INSERT INTO fact_orders (
    order_id,
    restaurant_sk,
    customer_sk,
    item_count,
    subtotal,
    packaging_charges,
    discount,
    total,
    rating,
    distance_km,
    delivery_type,
    order_status,
    kpt_minutes,
    rider_wait_minutes,
    date_sk
)
SELECT
    s.order_id,
    r.restaurant_sk,
    c.customer_sk,
    s.items_in_order,
    s.bill_subtotal,
    s.packaging_charges,
    COALESCE(s.restaurant_promo_discount, 0) +
    COALESCE(s.restaurant_flat_discount, 0) +
    COALESCE(s.brand_pack_discount, 0),
    s.total,
    s.rating,
    REPLACE(s.distance, 'km', '')::NUMERIC,
    s.delivery,
    s.order_status,
    s.kpt_duration,
    s.rider_wait_time,
    d.date_sk
FROM staging_orders s
JOIN dim_restaurant r ON s.restaurant_id = r.restaurant_id
JOIN dim_customer c ON s.customer_id = c.customer_id
JOIN dim_date d ON s.order_placed_at::date = d.date_actual;

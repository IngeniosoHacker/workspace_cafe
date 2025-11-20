
TRUNCATE staging_orders;

COPY staging_orders
FROM '/Users/ginebraestrada/Documents/cafeteria/workspace_cafe/datamart/raw/order_history_kaggle_data.csv'
DELIMITER E'\t'
CSV HEADER;


-- Poblar dimensiones


-- DIM_RESTAURANT
INSERT INTO datamart.dim_restaurant (restaurant_id, restaurant_name, subzone, city)
SELECT DISTINCT restaurant_id, restaurant_name, subzone, city
FROM staging_orders
WHERE restaurant_id IS NOT NULL
ON CONFLICT (restaurant_id) DO NOTHING;

-- DIM_CUSTOMER
INSERT INTO datamart.dim_customer (customer_id)
SELECT DISTINCT customer_id
FROM staging_orders
WHERE customer_id IS NOT NULL
ON CONFLICT (customer_id) DO NOTHING;

-- DIM_DATE
SELECT datamart.fn_populate_dim_date(
    MIN(order_placed_at::date),
    MAX(order_placed_at::date)
)
FROM staging_orders;

----------------------------------------
-- 4. Poblar fact_orders
----------------------------------------
INSERT INTO datamart.fact_orders (
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
    -- contar items separando por coma
    CASE WHEN s.items_raw IS NULL THEN 0
         ELSE array_length(string_to_array(s.items_raw, ','), 1)
    END,
    s.bill_subtotal,
    s.packaging_charges,
    COALESCE(s.promo_discount,0)
        + COALESCE(s.flat_discount,0)
        + COALESCE(s.gold_discount,0)
        + COALESCE(s.brand_discount,0),
    s.total,
    s.rating,
    NULLIF(REPLACE(s.distance_raw,'km',''),'')::NUMERIC,
    s.delivery_method,
    s.order_status,
    s.kpt_duration,
    s.rider_wait,
    d.date_sk
FROM staging_orders s
JOIN datamart.dim_restaurant r ON s.restaurant_id = r.restaurant_id
JOIN datamart.dim_customer c ON s.customer_id = c.customer_id
JOIN datamart.dim_date d ON s.order_placed_at::date = d.date_id;

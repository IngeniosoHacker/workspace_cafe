-- Crear tabla de pedidos RAW
CREATE TABLE raw_pedidos (
    restaurant_id TEXT,
    restaurant_name TEXT,
    subzone TEXT,
    city TEXT,
    order_id TEXT,
    order_placed_at TEXT,
    order_status TEXT,
    delivery_distance TEXT,
    items_in_order TEXT,
    packaging_charge TEXT,
    delivery_fee TEXT,
    delivery_tip TEXT,
    taxes TEXT,
    charges_on_bill TEXT,
    bill_total TEXT,
    bill_subtotal TEXT,
    discount_applied TEXT,
    discount_type TEXT,
    zomato_pro_savings TEXT,
    total TEXT,
    payment_method TEXT,
    paid_by_customer TEXT,
    refund_amount TEXT,
    delivery_time_minutes TEXT,
    prep_time_minutes TEXT,
    rider_wait_time_minutes TEXT,
    order_ready_marked TEXT,
    customer_complaint_tag TEXT,
    customer_id TEXT
);

-- Copiar data de CSV
COPY raw_pedidos 
FROM 'order_history_kaggle_data.csv' 
DELIMITER ',' 
CSV HEADER;

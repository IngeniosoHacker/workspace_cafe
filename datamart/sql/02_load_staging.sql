COPY staging_orders
FROM '/Users/ginebraestrada/Documents/cafeteria/workspace_cafe/datamart/raw/order_history_kaggle_data.csv'
DELIMITER E'\t'
CSV HEADER;

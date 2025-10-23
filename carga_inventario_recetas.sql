
BEGIN;

-- Limpieza de datos previos
TRUNCATE TABLE receta RESTART IDENTITY CASCADE;
TRUNCATE TABLE inventario RESTART IDENTITY CASCADE;
TRUNCATE TABLE menu RESTART IDENTITY CASCADE;
TRUNCATE TABLE sede RESTART IDENTITY CASCADE;

-- Sede
INSERT INTO sede (id, direccion) VALUES (1, 'Sede Central');

-- Menu base (10 platillos)
INSERT INTO menu (descripcion, tipo) VALUES
('Burrito tex-mex clasico', 'burrito'),
('Ensalada fresca de pollo y frijol', 'ensalada'),
('Bowl street corn', 'bowl'),
('Panini ranchero', 'panini'),
('Burrito de frijol y maiz', 'burrito'),
('Ensalada suroeste con lima', 'ensalada'),
('Bowl proteico de pollo', 'bowl'),
('Panini capri-mex', 'panini'),
('Burrito verde ligero', 'burrito'),
('Ensalada crujiente con queso', 'ensalada');

-- Inventario
INSERT INTO inventario (producto, existencia, caducidad, sede_id) VALUES
('tortilla harina', 100, '2025-12-31', 1),
('arroz', 100, '2025-12-31', 1),
('frijoles negros', 100, '2025-12-31', 1),
('pollo deshebrado', 100, '2025-12-31', 1),
('lechuga', 100, '2025-12-31', 1),
('tomate', 100, '2025-12-31', 1),
('cebolla morada', 100, '2025-12-31', 1),
('maiz', 100, '2025-12-31', 1),
('queso rallado', 100, '2025-12-31', 1),
('aguacate', 100, '2025-12-31', 1),
('cilantro', 100, '2025-12-31', 1),
('salsa', 100, '2025-12-31', 1),
('limon', 100, '2025-12-31', 1),
('aderezo yogur-lima', 100, '2025-12-31', 1),
('panini/baguette', 100, '2025-12-31', 1),
('mayonesa chipotle', 100, '2025-12-31', 1),
('jalapeno en rodajas', 100, '2025-12-31', 1),
('pepino', 100, '2025-12-31', 1),
('aceite de oliva', 100, '2025-12-31', 1),
('vinagreta', 100, '2025-12-31', 1),
('tiritas de tortilla horneadas', 100, '2025-12-31', 1),
('pimiento rojo en tiras', 100, '2025-12-31', 1);

-- Recetas
-- 1 Burrito tex-mex clasico
INSERT INTO receta (menuid, inventid) SELECT 1, id FROM inventario WHERE producto IN
('tortilla harina','arroz','frijoles negros','pollo deshebrado','lechuga','tomate','cebolla morada','maiz','queso rallado','aguacate','cilantro','salsa','limon');

-- 2 Ensalada fresca de pollo y frijol
INSERT INTO receta (menuid, inventid) SELECT 2, id FROM inventario WHERE producto IN
('lechuga','arroz','frijoles negros','pollo deshebrado','tomate','cebolla morada','maiz','queso rallado','aguacate','cilantro','aderezo yogur-lima');

-- 3 Bowl street corn
INSERT INTO receta (menuid, inventid) SELECT 3, id FROM inventario WHERE producto IN
('arroz','frijoles negros','pollo deshebrado','maiz','queso rallado','cebolla morada','tomate','aguacate','cilantro','salsa','limon');

-- 4 Panini ranchero
INSERT INTO receta (menuid, inventid) SELECT 4, id FROM inventario WHERE producto IN
('panini/baguette','pollo deshebrado','queso rallado','tomate','cebolla morada','aguacate','cilantro','mayonesa chipotle');

-- 5 Burrito de frijol y maiz
INSERT INTO receta (menuid, inventid) SELECT 5, id FROM inventario WHERE producto IN
('tortilla harina','arroz','frijoles negros','maiz','tomate','cebolla morada','lechuga','queso rallado','salsa','jalapeno en rodajas');

-- 6 Ensalada suroeste con lima
INSERT INTO receta (menuid, inventid) SELECT 6, id FROM inventario WHERE producto IN
('lechuga','pollo deshebrado','frijoles negros','maiz','tomate','cebolla morada','queso rallado','aguacate','cilantro','vinagreta');

-- 7 Bowl proteico de pollo
INSERT INTO receta (menuid, inventid) SELECT 7, id FROM inventario WHERE producto IN
('arroz','pollo deshebrado','frijoles negros','tomate','cebolla morada','lechuga','queso rallado','aguacate','salsa','pimiento rojo en tiras');

-- 8 Panini capri-mex
INSERT INTO receta (menuid, inventid) SELECT 8, id FROM inventario WHERE producto IN
('panini/baguette','pollo deshebrado','frijoles negros','queso rallado','tomate','cebolla morada','pepino','aguacate','aceite de oliva','cilantro');

-- 9 Burrito verde ligero
INSERT INTO receta (menuid, inventid) SELECT 9, id FROM inventario WHERE producto IN
('tortilla harina','arroz','pollo deshebrado','lechuga','tomate','cebolla morada','aguacate','cilantro','aderezo yogur-lima');

-- 10 Ensalada crujiente con queso
INSERT INTO receta (menuid, inventid) SELECT 10, id FROM inventario WHERE producto IN
('lechuga','arroz','frijoles negros','pollo deshebrado','tomate','cebolla morada','maiz','queso rallado','aguacate','tiritas de tortilla horneadas','aderezo yogur-lima');

COMMIT;

SELECT m.descripcion AS menu, i.producto AS ingrediente
FROM receta r
JOIN menu m ON r.menuid = m.id
JOIN inventario i ON r.inventid = i.id
ORDER BY m.id;

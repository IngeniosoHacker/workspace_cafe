
-- inserts para la base

-- sedes
INSERT INTO sede (direccion) VALUES
('Zona 15, Ciudad de Guatemala'),
('Centro Histórico, Ciudad de Guatemala');

-- espacios
INSERT INTO espacio (tipo, precio) VALUES
('Mesa', 30.00),
('Sala de reuniones', 200.00),
('Cabina', 150.00),
('Escritorio pequeño', 30.00),
('Sala creativa',200.00),
('Área de coworking',100.00),
('Sala de conferencias',300.00),
('Auditorio',500.00),
('Sala lounge',250.00);


-- Personal
-- sede_id: 1 = Zona 15,  2 = Zona 1
INSERT INTO personal (nombre, puesto, password, salary, sede_id) VALUES
('Laura Gómez', 'Gerente', 'pass123', 8500.00, 1),
('Andrés Martínez', 'Barista', 'cafe2025', 4200.00, 1),
('Sofía Hernández', 'Mesera', 'sofiaH', 3500.00, 1),
('Luis Torres', 'Chef', 'chefL123', 6000.00, 2),
('Elena Castillo', 'Mesera', 'elenaC', 3400.00, 2),
('Pedro Morales', 'Administrador', 'adminPM', 9000.00, 2);

-- inventario para nuevos platillos
INSERT INTO inventario (producto, existencia, unidad, caducidad, sede_id) VALUES
('tortilla harina', 200, 'pieza', '2025-12-31', 1),
('tortilla harina', 200, 'pieza', '2025-12-31', 2),
('arroz', 150, 'taza', '2025-09-30', 1),
('arroz', 150, 'taza', '2025-09-30', 2),
('frijoles negros', 140, 'taza', '2025-10-31', 1),
('frijoles negros', 140, 'taza', '2025-10-31', 2),
('pollo', 40, 'kg', '2025-07-31', 1),
('pollo', 40, 'kg', '2025-07-31', 2),
('lechuga', 60, 'pieza', '2025-04-30', 1),
('lechuga', 60, 'pieza', '2025-04-30', 2),
('tomate', 80, 'kg', '2025-04-15', 1),
('tomate', 80, 'kg', '2025-04-15', 2),
('cebolla morada', 70, 'kg', '2025-05-15', 1),
('cebolla morada', 70, 'kg', '2025-05-15', 2),
('maiz', 100, 'taza', '2025-08-31', 1),
('maiz', 100, 'taza', '2025-08-31', 2),
('queso rallado', 90, 'taza', '2025-09-30', 1),
('queso rallado', 90, 'taza', '2025-09-30', 2),
('aguacate', 60, 'pieza', '2025-04-15', 1),
('aguacate', 60, 'pieza', '2025-04-15', 2),
('cilantro', 50, 'manojo', '2025-03-31', 1),
('cilantro', 50, 'manojo', '2025-03-31', 2),
('salsa', 80, 'frasco', '2025-12-31', 1),
('salsa', 80, 'frasco', '2025-12-31', 2),
('limon', 120, 'pieza', '2025-05-31', 1),
('limon', 120, 'pieza', '2025-05-31', 2),
('mix lechuga espinaca', 40, 'bolsa', '2025-04-30', 1),
('mix lechuga espinaca', 40, 'bolsa', '2025-04-30', 2),
('aderezo yogur lima', 60, 'frasco', '2025-11-30', 1),
('aderezo yogur lima', 60, 'frasco', '2025-11-30', 2),
('panini baguette', 100, 'pieza', '2025-06-30', 1),
('panini baguette', 100, 'pieza', '2025-06-30', 2),
('mayonesa chipotle', 50, 'frasco', '2025-10-31', 1),
('mayonesa chipotle', 50, 'frasco', '2025-10-31', 2),
('jalapeno rodajas', 60, 'frasco', '2025-10-31', 1),
('jalapeno rodajas', 60, 'frasco', '2025-10-31', 2),
('vinagreta lima', 45, 'frasco', '2025-11-30', 1),
('vinagreta lima', 45, 'frasco', '2025-11-30', 2),
('pimiento rojo', 70, 'pieza', '2025-04-15', 1),
('pimiento rojo', 70, 'pieza', '2025-04-15', 2),
('aceite oliva', 80, 'litro', '2026-01-31', 1),
('aceite oliva', 80, 'litro', '2026-01-31', 2),
('pepino', 60, 'pieza', '2025-04-15', 1),
('pepino', 60, 'pieza', '2025-04-15', 2),
('tiritas tortilla', 50, 'bolsa', '2025-08-31', 1),
('tiritas tortilla', 50, 'bolsa', '2025-08-31', 2);

-- menú de platillos basados en ingredientes anteriores
INSERT INTO menu (descripcion, precio, tipo) VALUES
('Burrito tex-mex clásico', 55.00, 'burrito'),
('Ensalada fresca de pollo y frijol', 52.00, 'ensalada'),
('Bowl street corn', 58.00, 'bowl'),
('Panini ranchero', 60.00, 'panini'),
('Burrito de frijol y maíz', 48.00, 'burrito'),
('Ensalada suroeste con lima', 54.00, 'ensalada'),
('Bowl proteico de pollo', 62.00, 'bowl'),
('Panini capri-mex', 59.00, 'panini'),
('Burrito verde ligero', 53.00, 'burrito'),
('Ensalada crujiente con queso', 57.00, 'ensalada');

-- recetas vinculadas a ingredientes (sede 2)
-- Burrito tex-mex clásico
INSERT INTO receta (menuid, inventid) VALUES
(1, 2),
(1, 4),
(1, 6),
(1, 8),
(1, 10),
(1, 12),
(1, 14),
(1, 16),
(1, 18),
(1, 20),
(1, 22),
(1, 24),
(1, 26);

-- Ensalada fresca de pollo y frijol
INSERT INTO receta (menuid, inventid) VALUES
(2, 28),
(2, 4),
(2, 6),
(2, 8),
(2, 12),
(2, 14),
(2, 16),
(2, 18),
(2, 20),
(2, 22),
(2, 30);

-- Bowl street corn
INSERT INTO receta (menuid, inventid) VALUES
(3, 4),
(3, 6),
(3, 8),
(3, 16),
(3, 18),
(3, 14),
(3, 12),
(3, 20),
(3, 22),
(3, 24),
(3, 26);

-- Panini ranchero
INSERT INTO receta (menuid, inventid) VALUES
(4, 32),
(4, 8),
(4, 18),
(4, 12),
(4, 14),
(4, 20),
(4, 22),
(4, 34);

-- Burrito de frijol y maíz
INSERT INTO receta (menuid, inventid) VALUES
(5, 2),
(5, 4),
(5, 6),
(5, 16),
(5, 12),
(5, 14),
(5, 10),
(5, 18),
(5, 24),
(5, 36);

-- Ensalada suroeste con lima
INSERT INTO receta (menuid, inventid) VALUES
(6, 10),
(6, 8),
(6, 6),
(6, 16),
(6, 12),
(6, 14),
(6, 18),
(6, 20),
(6, 22),
(6, 38);

-- Bowl proteico de pollo
INSERT INTO receta (menuid, inventid) VALUES
(7, 4),
(7, 8),
(7, 6),
(7, 12),
(7, 14),
(7, 10),
(7, 18),
(7, 20),
(7, 24),
(7, 40);

-- Panini capri-mex
INSERT INTO receta (menuid, inventid) VALUES
(8, 32),
(8, 8),
(8, 6),
(8, 18),
(8, 12),
(8, 14),
(8, 44),
(8, 20),
(8, 42),
(8, 22);

-- Burrito verde ligero
INSERT INTO receta (menuid, inventid) VALUES
(9, 2),
(9, 4),
(9, 8),
(9, 10),
(9, 12),
(9, 14),
(9, 20),
(9, 22),
(9, 30);

-- Ensalada crujiente con queso
INSERT INTO receta (menuid, inventid) VALUES
(10, 28),
(10, 4),
(10, 6),
(10, 8),
(10, 12),
(10, 14),
(10, 16),
(10, 18),
(10, 20),
(10, 46),
(10, 30);

-- recetas vinculadas a ingredientes (sede 1)
-- Burrito tex-mex clásico
INSERT INTO receta (menuid, inventid) VALUES
(1, 1),
(1, 3),
(1, 5),
(1, 7),
(1, 9),
(1, 11),
(1, 13),
(1, 15),
(1, 17),
(1, 19),
(1, 21),
(1, 23),
(1, 25);

-- Ensalada fresca de pollo y frijol
INSERT INTO receta (menuid, inventid) VALUES
(2, 27),
(2, 3),
(2, 5),
(2, 7),
(2, 11),
(2, 13),
(2, 15),
(2, 17),
(2, 19),
(2, 21),
(2, 29);

-- Bowl street corn
INSERT INTO receta (menuid, inventid) VALUES
(3, 3),
(3, 5),
(3, 7),
(3, 15),
(3, 17),
(3, 13),
(3, 11),
(3, 19),
(3, 21),
(3, 23),
(3, 25);

-- Panini ranchero
INSERT INTO receta (menuid, inventid) VALUES
(4, 31),
(4, 7),
(4, 17),
(4, 11),
(4, 13),
(4, 19),
(4, 21),
(4, 33);

-- Burrito de frijol y maíz
INSERT INTO receta (menuid, inventid) VALUES
(5, 1),
(5, 3),
(5, 5),
(5, 15),
(5, 11),
(5, 13),
(5, 9),
(5, 17),
(5, 23),
(5, 35);

-- Ensalada suroeste con lima
INSERT INTO receta (menuid, inventid) VALUES
(6, 9),
(6, 7),
(6, 5),
(6, 15),
(6, 11),
(6, 13),
(6, 17),
(6, 19),
(6, 21),
(6, 37);

-- Bowl proteico de pollo
INSERT INTO receta (menuid, inventid) VALUES
(7, 3),
(7, 7),
(7, 5),
(7, 11),
(7, 13),
(7, 9),
(7, 17),
(7, 19),
(7, 23),
(7, 39);

-- Panini capri-mex
INSERT INTO receta (menuid, inventid) VALUES
(8, 31),
(8, 7),
(8, 5),
(8, 17),
(8, 11),
(8, 13),
(8, 43),
(8, 19),
(8, 41),
(8, 21);

-- Burrito verde ligero
INSERT INTO receta (menuid, inventid) VALUES
(9, 1),
(9, 3),
(9, 7),
(9, 9),
(9, 11),
(9, 13),
(9, 19),
(9, 21),
(9, 29);

-- Ensalada crujiente con queso
INSERT INTO receta (menuid, inventid) VALUES
(10, 27),
(10, 3),
(10, 5),
(10, 7),
(10, 11),
(10, 13),
(10, 15),
(10, 17),
(10, 19),
(10, 45),
(10, 29);


-- clientes
INSERT INTO cliente (nombre, telefono, platoFav, suscripcion) VALUES
('María Fernanda López', 55512345, 1, 'Gold'),
('Carlos Pérez', 55567890, 2, 'Silver'),
('Ana Sofía Morales', 55599887, 3, 'Básica'),
('Jorge Ramírez', 55533444, 1, 'Gold'),
('Lucía Estrada', 55511223, 2, 'Básica'),
('Renata Gutiérrez', 55544556, 4, 'Gold'),
('Sebastián López', 55577665, 5, 'Silver'),
('Valeria Chávez', 55588776, 6, 'Básica'),
('Diego Fernández', 55599881, 7, 'Gold'),
('Camila Méndez', 55533221, 8, 'Silver'),
('Isabella Pineda', 55522143, 9, 'Gold'),
('Mateo Rojas', 55578912, 10, 'Básica'),
('Gabriela Soto', 55566754, 4, 'Silver'),
('Héctor Aguilar', 55544321, 5, 'Gold'),
('Paola Velásquez', 55590876, 6, 'Básica'),
('Andrés Cifuentes', 55576543, 7, 'Silver'),
('Karla Domínguez', 55565432, 8, 'Gold'),
('Mauricio Castellanos', 55554321, 9, 'Básica'),
('Fernanda Juárez', 55543210, 10, 'Gold'),
('Rodrigo Herrera', 55532109, 4, 'Silver'),
('Daniela Campos', 55521098, 5, 'Gold'),
('Santiago Alvarado', 55510987, 6, 'Básica'),
('Lilian Arévalo', 55509876, 7, 'Silver'),
('Carolina Méndez', 55598765, 8, 'Gold'),
('Julio Pérez', 55587654, 9, 'Básica'),
('Marisol Rivera', 55576521, 10, 'Silver'),
('Ignacio Lara', 55565410, 4, 'Gold'),
('Ximena Rosales', 55554310, 5, 'Silver'),
('Patricio Molina', 55543265, 6, 'Básica'),
('Verónica Salazar', 55532145, 7, 'Gold'),
('Mariano Cabrera', 55521076, 8, 'Silver'),
('Laura Ortiz', 55512098, 9, 'Básica'),
('Pablo Núñez', 55588991, 10, 'Gold'),
('Jimena Carrillo', 55577882, 5, 'Silver'),
('Esteban Robles', 55566789, 4, 'Básica'),
('Natalia Acevedo', 55555678, 6, 'Gold'),
('Ricardo Morales', 55544567, 7, 'Silver'),
('Beatriz Sandoval', 55533412, 8, 'Básica'),
('Oscar Zamora', 55522331, 9, 'Gold');


-- reservas
INSERT INTO reserva (horaFecha, numPersonas, status, espacio_fk, sede_fk, cliente_fk, personal_fk, observaciones) VALUES
('2025-03-01 19:00:00', 2, 'Completada', 1, 1, 1, 3, 'Cena aniversario'),
('2025-03-02 13:00:00', 4, 'Completada', 2, 1, 2, 1, 'Reunión de negocios mediodía'),
('2025-03-03 08:30:00', 1, 'Completada', 4, 2, 3, 5, 'Trabajo individual desde temprano'),
('2025-03-04 18:00:00', 3, 'Completada', 3, 1, 4, 3, 'Cena con colegas'),
('2025-03-05 20:30:00', 5, 'Completada', 5, 2, 5, 6, 'Networking emprendedores'),
('2025-03-06 12:00:00', 2, 'Completada', 6, 1, 6, 2, 'Almuerzo ejecutivo'),
('2025-03-07 09:00:00', 6, 'Completada', 7, 2, 7, 4, 'Workshop matutino'),
('2025-03-08 21:00:00', 2, 'Completada', 8, 1, 8, 3, 'Concierto acústico íntimo'),
('2025-03-09 10:30:00', 3, 'Completada', 9, 2, 9, 5, 'Planeación semanal'),
('2025-03-10 14:00:00', 2, 'Completada', 1, 2, 10, 5, 'Almuerzo con inversionistas'),
('2025-03-11 19:30:00', 4, 'Completada', 2, 2, 11, 4, 'Cena familiar'),
('2025-03-12 17:00:00', 3, 'Completada', 3, 2, 12, 5, 'Presentación de producto'),
('2025-03-13 08:00:00', 2, 'Completada', 4, 1, 13, 2, 'Desayuno de coaching'),
('2025-03-14 18:30:00', 5, 'Completada', 5, 1, 14, 1, 'Celebración de logros'),
('2025-03-15 11:00:00', 2, 'Completada', 6, 2, 15, 6, 'Brunch con amigas'),
('2025-03-16 16:00:00', 3, 'Completada', 7, 1, 16, 3, 'Círculo de lectura'),
('2025-03-17 13:30:00', 6, 'Completada', 8, 2, 17, 4, 'Reunión regional'),
('2025-03-18 20:00:00', 2, 'Cancelada', 9, 1, 18, 2, 'Cancelado por enfermedad'),
('2025-03-19 12:30:00', 4, 'Completada', 2, 1, 19, 1, 'Comida con proveedores'),
('2025-03-20 19:45:00', 2, 'Completada', 3, 1, 20, 3, 'Cena sorpresa'),
('2025-03-21 12:00:00', 3, 'Completada', 6, 1, 4, 2, 'Capacitación breve'),
('2025-03-22 20:00:00', 4, 'Completada', 5, 2, 5, 6, 'Cena degustación'),
('2025-03-23 09:30:00', 2, 'Completada', 4, 1, 2, 1, 'Sesión de mentoría'),
('2025-03-24 19:15:00', 3, 'Completada', 3, 2, 7, 4, 'Cena temática'),
('2025-03-25 13:00:00', 5, 'Completada', 7, 1, 6, 3, 'Planeación trimestral'),
('2025-03-26 18:45:00', 2, 'Completada', 2, 2, 8, 5, 'Cena rápida antes de evento'),
('2025-03-27 17:30:00', 4, 'Completada', 1, 1, 9, 2, 'After office del equipo'),
('2025-03-28 08:15:00', 6, 'Completada', 8, 2, 10, 5, 'Simposio matutino'),
('2025-03-29 19:00:00', 2, 'Completada', 3, 1, 1, 3, 'Cena ligera en pareja'),
('2025-03-30 12:45:00', 3, 'Completada', 6, 2, 11, 4, 'Almuerzo familiar'),
('2025-03-31 10:00:00', 2, 'Completada', 4, 1, 12, 1, 'Reunión de avance'),
('2025-04-01 19:30:00', 5, 'Completada', 9, 2, 13, 5, 'Lanzamiento a clientes'),
('2025-04-02 18:00:00', 3, 'Completada', 2, 1, 14, 2, 'Cena ejecutiva'),
('2025-04-03 07:30:00', 2, 'Completada', 4, 2, 15, 4, 'Desayuno de networking'),
('2025-04-04 20:15:00', 4, 'Completada', 5, 1, 16, 3, 'Celebración de aniversario'),
('2025-04-05 15:00:00', 6, 'Cancelada', 7, 2, 17, 6, 'Reunión cancelada por logística'),
('2025-04-06 11:00:00', 3, 'Completada', 6, 1, 18, 1, 'Brunch familiar'),
('2025-04-07 18:45:00', 2, 'Completada', 3, 2, 19, 5, 'Cita de negocios'),
('2025-04-08 09:00:00', 4, 'Completada', 8, 1, 20, 2, 'Taller creativo'),
('2025-04-09 19:00:00', 5, 'Completada', 1, 2, 21, 4, 'Cena con socios'),
('2025-10-28 12:30:00', 2, 'Activa', 1, 1, 3, 2, 'Almuerzo ejecutivo pendiente'),
('2025-10-28 19:00:00', 4, 'Activa', 3, 1, 5, 3, 'Cena de seguimiento'),
('2025-10-29 09:00:00', 6, 'Activa', 7, 2, 8, 4, 'Sesión de estrategia'),
('2025-10-29 18:30:00', 3, 'Activa', 2, 2, 10, 6, 'Revisión de proyecto'),
('2025-10-30 08:00:00', 2, 'Activa', 4, 1, 12, 2, 'Desayuno con mentora'),
('2025-10-30 20:00:00', 5, 'Activa', 5, 2, 14, 5, 'Cena de celebración'),
('2025-10-31 13:00:00', 3, 'Activa', 6, 1, 16, 3, 'Reunión financiera'),
('2025-10-31 21:00:00', 2, 'Activa', 8, 1, 18, 1, 'Velada acústica'),
('2025-11-01 11:30:00', 4, 'Activa', 9, 2, 20, 4, 'Brunch corporativo'),
('2025-11-01 19:45:00', 2, 'Activa', 3, 2, 1, 6, 'Cena íntima de aniversario');


-- inserts pedidos
INSERT INTO pide (reservaid, menuid) VALUES
(1, 1), (1, 2),
(2, 4), (2, 3),
(3, 3),
(4, 7), (4, 1),
(5, 2), (5, 6), (5, 8),
(6, 4),
(7, 7), (7, 3),
(8, 8), (8, 10),
(9, 5), (9, 6),
(10, 9), (10, 2),
(11, 1), (11, 7),
(12, 3), (12, 5),
(13, 4), (13, 9),
(14, 2), (14, 10),
(15, 6), (15, 8),
(16, 7), (16, 5),
(17, 8), (17, 1),
(18, 5),
(19, 3), (19, 9), (19, 10),
(20, 2), (20, 4),
(21, 1), (21, 5),
(22, 4), (22, 2),
(23, 3),
(24, 7), (24, 9),
(25, 2), (25, 6), (25, 8),
(26, 5), (26, 10),
(27, 1), (27, 4),
(28, 3), (28, 7), (28, 10),
(29, 9), (29, 2),
(30, 6), (30, 8),
(31, 5),
(32, 2), (32, 3), (32, 4),
(33, 7),
(34, 10), (34, 6),
(35, 8), (35, 1),
(36, 4), (36, 9),
(37, 3), (37, 5),
(38, 2), (38, 8),
(39, 7), (39, 10), (39, 5),
(40, 1), (40, 6),
(41, 3), (41, 5),
(42, 1), (42, 7),
(43, 2), (43, 6), (43, 8),
(44, 4), (44, 9),
(45, 5), (45, 10),
(46, 7), (46, 2),
(47, 3), (47, 8),
(48, 9), (48, 4),
(49, 6), (49, 1),
(50, 2), (50, 5);

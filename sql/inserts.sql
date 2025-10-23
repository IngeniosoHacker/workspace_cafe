
-- inserts para la base

-- sedes
INSERT INTO sede (direccion) VALUES
('Zona 15, Ciudad de Guatemala'),
('Centro Histórico, Ciudad de Guatemala');

-- espacios
INSERT INTO espacio (tipo, precio) VALUES
('Mesa individual', 25.00),
('Mesa para 2 personas', 40.00),
('Mesa familiar', 70.00),
('Terraza', 60.00),
('Sala privada', 120.00);


-- clientes
INSERT INTO cliente (nombre, telefono, platoFav, suscripcion) VALUES
('María Fernanda López', 55512345, 1, 'Gold'),
('Carlos Pérez', 55567890, 2, 'Silver'),
('Ana Sofía Morales', 55599887, 3, 'Básica'),
('Jorge Ramírez', 55533444, 1, 'Gold'),
('Lucía Estrada', 55511223, 2, 'Básica');


-- sedes
-- sede_id: 1 = Zona 15,  2 = Zona 1
INSERT INTO personal (nombre, puesto, password, salary, sede_id) VALUES
('Laura Gómez', 'Gerente', 'pass123', 8500.00, 1),
('Andrés Martínez', 'Barista', 'cafe2025', 4200.00, 1),
('Sofía Hernández', 'Mesera', 'sofiaH', 3500.00, 1),
('Luis Torres', 'Chef', 'chefL123', 6000.00, 2),
('Elena Castillo', 'Mesera', 'elenaC', 3400.00, 2),
('Pedro Morales', 'Administrador', 'adminPM', 9000.00, 2);



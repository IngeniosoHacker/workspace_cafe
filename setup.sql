
-- Eliminación previa (para evitar conflictos al recrear)
DROP TABLE IF EXISTS Bitacora, Cambia, Pide, Receta, Reserva, Realiza, Pertenece CASCADE;
DROP TABLE IF EXISTS Cliente, Personal, Menu, Inventario, Espacio, Sede CASCADE;


CREATE TABLE Sede (
    id SERIAL PRIMARY KEY,
    direccion VARCHAR(255) NOT NULL
);

CREATE TABLE Espacio (
    id SERIAL PRIMARY KEY,
    tipo VARCHAR(100),
    precio FLOAT
);

CREATE TABLE Cliente (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono BIGINT,
    platoFavMen INT,
    suscripcion VARCHAR(50)
);

CREATE TABLE Personal (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    puesto VARCHAR(50),
    password VARCHAR(100),
    salario FLOAT,
    sede_id INT REFERENCES Sede(id)
);

CREATE TABLE Menu (
    id SERIAL PRIMARY KEY,
    descripcion VARCHAR(255),
    precio FLOAT,
    tipo VARCHAR(50)
);

CREATE TABLE Inventario (
    id SERIAL PRIMARY KEY,
    producto VARCHAR(100),
    existencia INT,
    caducidad DATE,
    sede_id INT REFERENCES Sede(id)
);

CREATE TABLE Reserva (
    id SERIAL PRIMARY KEY,
    horaFecha TIMESTAMP,
    espacio_id INT REFERENCES Espacio(id),
    cliente_id INT REFERENCES Cliente(id),
    numPersonas INT,
    status VARCHAR(50),
    sede_id INT REFERENCES Sede(id)
);

CREATE TABLE Pide (
    reserva_id INT REFERENCES Reserva(id) ON DELETE CASCADE,
    menu_id INT REFERENCES Menu(id) ON DELETE CASCADE,
    cantidad INT DEFAULT 1,
    PRIMARY KEY (reserva_id, menu_id)
);

CREATE TABLE Receta (
    menu_id INT REFERENCES Menu(id) ON DELETE CASCADE,
    inventario_id INT REFERENCES Inventario(id) ON DELETE CASCADE,
    cantidadNecesaria INT DEFAULT 1,
    PRIMARY KEY (menu_id, inventario_id)
);

CREATE TABLE Bitacora (
    id SERIAL PRIMARY KEY,
    esquema VARCHAR(100),
    id_afectado INT,
    operacion VARCHAR(50),
    personal_id INT REFERENCES Personal(id),
    fecha TIMESTAMP DEFAULT NOW(),
    detalle VARCHAR(255)
);


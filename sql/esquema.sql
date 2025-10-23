DROP TABLE IF EXISTS Bitacora, Cambia, Pide, Receta, Reserva, Realiza, Pertenece CASCADE;
DROP TABLE IF EXISTS Cliente, Personal, Menu, Inventario, Espacio, Sede CASCADE;


CREATE TABLE IF NOT EXISTS menu(
	id serial PRIMARY KEY,
	descripcion varchar(200),
	precio numeric(10,2),
	tipo varchar(50)
);

CREATE TABLE IF NOT EXISTS sede(
	id serial PRIMARY KEY,
	direccion varchar(120) not null
);

CREATE TABLE IF NOT EXISTS inventario(
	id serial PRIMARY KEY,
	producto varchar(50),
	existencia int not null,
	unidad varchar(10),
	caducidad date not null,
	sede_id int REFERENCES sede(id)
);

CREATE TABLE IF NOT EXISTS receta(
	menuid int REFERENCES menu(id),
	inventid int REFERENCES inventario(id)
);

CREATE TABLE IF NOT EXISTS cliente(
	id serial PRIMARY KEY,
	nombre varchar(120) not null,
	telefono bigint,
	platoFav int,
	suscripcion varchar(50),
	FOREIGN KEY (platoFav) REFERENCES menu(id)
);

CREATE TABLE IF NOT EXISTS espacio(
	id serial PRIMARY KEY,
	tipo varchar(50) not null,
	precio numeric(10,2)
);


CREATE TABLE IF NOT EXISTS personal(
	id serial PRIMARY KEY,
	nombre varchar(120) not null,
	puesto varchar(50) not null,
	password varchar(20) not null,
	salary numeric(10,2),
	sede_id int REFERENCES sede(id)
);

CREATE TABLE IF NOT EXISTS reserva(
	id serial PRIMARY KEY,
	horaFecha timestamp DEFAULT NOW(),
	numPersonas int not null,
	status varchar(20),
	espacio_fk int REFERENCES espacio(id),
	sede_fk int REFERENCES sede(id),
	cliente_fk int REFERENCES cliente(id),
	personal_fk int REFERENCES personal(id)
);

CREATE TABLE IF NOT EXISTS pide(
	reservaid int REFERENCES reserva(id),
	menuid int REFERENCES menu(id)
);

CREATE TABLE IF NOT EXISTS bitacora(
	id serial PRIMARY KEY,
	esquema varchar(50) not null,
	id_afectado int not null,
	operacion varchar(50),
	fecha timestamp DEFAULT NOW(),
	detalle varchar(120),
	personal_id int not null
);
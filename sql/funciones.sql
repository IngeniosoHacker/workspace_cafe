-- Función para obtener la contraseña de un miembro del personal por su ID.
CREATE OR REPLACE FUNCTION get_password(p_personal_id int)
RETURNS text AS
$$
DECLARE
    v_password personal.password%TYPE;
BEGIN
    SELECT password
      INTO v_password
      FROM personal
     WHERE id = p_personal_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe personal con id %', p_personal_id;
    END IF;

    RETURN v_password;
END;
$$
LANGUAGE plpgsql
STABLE;


-- Búsqueda de reservas por campos opcionales.
CREATE OR REPLACE FUNCTION buscar_reservas(
    p_reserva_id int DEFAULT NULL,
    p_hora timestamp DEFAULT NULL,
    p_cliente_id int DEFAULT NULL,
    p_personal_id int DEFAULT NULL
)
RETURNS TABLE (
    id int,
    horaFecha timestamp,
    numPersonas int,
    status varchar,
    espacio_fk int,
    sede_fk int,
    cliente_fk int,
    personal_fk int,
    observaciones varchar
) AS
$$
BEGIN
    RETURN QUERY
    SELECT r.id,
           r.horaFecha,
           r.numPersonas,
           r.status,
           r.espacio_fk,
           r.sede_fk,
           r.cliente_fk,
           r.personal_fk,
           r.observaciones
      FROM reserva r
     WHERE (p_reserva_id IS NULL OR r.id = p_reserva_id)
       AND (p_hora IS NULL OR r.horaFecha = p_hora)
       AND (p_cliente_id IS NULL OR r.cliente_fk = p_cliente_id)
       AND (p_personal_id IS NULL OR r.personal_fk = p_personal_id)
     ORDER BY r.horaFecha;
END;
$$
LANGUAGE plpgsql
STABLE;


-- Top 10 de platillos más vendidos según la tabla pide.
CREATE OR REPLACE FUNCTION top_menu()
RETURNS TABLE (
    menu_id int,
    descripcion varchar,
    total_vendidos bigint
) AS
$$
    SELECT m.id,
           m.descripcion,
           COUNT(*) AS total_vendidos
      FROM pide p
      JOIN menu m ON m.id = p.menuid
     GROUP BY m.id, m.descripcion
     ORDER BY total_vendidos DESC, m.descripcion
     LIMIT 10;
$$
LANGUAGE sql
STABLE;


-- Búsqueda de insumos de cocina
CREATE OR REPLACE FUNCTION s_inventario(
    p_sede_id int,
    p_producto varchar DEFAULT NULL
)
RETURNS TABLE (
    inventario_id int,
    producto varchar,
    existencia int,
    unidad varchar,
    caducidad date,
    sede_id int
) AS
$$
    SELECT i.id,
           i.producto,
           i.existencia,
           i.unidad,
           i.caducidad,
           i.sede_id
      FROM inventario i
     WHERE i.sede_id = p_sede_id
       AND (p_producto IS NULL OR i.producto ILIKE p_producto);
$$
LANGUAGE sql
STABLE;


-- Historial de visitas de un cliente 
CREATE OR REPLACE FUNCTION historial_cliente(p_cliente_id int)
RETURNS TABLE (
    cliente_id int,
    cliente_nombre varchar,
    reserva_id int,
    horaFecha timestamp,
    numPersonas int,
    status varchar,
    sede_id int,
    sede_direccion varchar,
    espacio_id int,
    observaciones varchar,
    platillo_favorito_id int,
    platillo_favorito varchar,
    platillos_consumidos text
) AS
$$
    SELECT c.id AS cliente_id,
           c.nombre AS cliente_nombre,
           r.id AS reserva_id,
           r.horaFecha,
           r.numPersonas,
           r.status,
           r.sede_fk AS sede_id,
           s.direccion AS sede_direccion,
           r.espacio_fk AS espacio_id,
           r.observaciones,
           c.platoFav AS platillo_favorito_id,
           fav.descripcion AS platillo_favorito,
           string_agg(DISTINCT m.descripcion, ', ' ORDER BY m.descripcion) AS platillos_consumidos
      FROM cliente c
      JOIN reserva r ON r.cliente_fk = c.id
      LEFT JOIN pide p ON p.reservaid = r.id
      LEFT JOIN menu m ON m.id = p.menuid
      LEFT JOIN menu fav ON fav.id = c.platoFav
      LEFT JOIN sede s ON s.id = r.sede_fk
     WHERE c.id = p_cliente_id
     GROUP BY c.id,
              c.nombre,
              r.id,
              r.horaFecha,
              r.numPersonas,
              r.status,
              r.sede_fk,
              s.direccion,
              r.espacio_fk,
              r.observaciones,
              c.platoFav,
              fav.descripcion
     ORDER BY r.horaFecha DESC;
$$
LANGUAGE sql
STABLE;

-- Top 10 de clientes más frecuentes 
CREATE OR REPLACE FUNCTION top_clientes()
RETURNS TABLE (
    cliente_id int,
    nombre varchar,
    total_reservas bigint
) AS
$$
    SELECT c.id,
           c.nombre,
           COUNT(*) AS total_reservas
      FROM cliente c
      JOIN reserva r ON r.cliente_fk = c.id
     WHERE COALESCE(r.status, 'Activa') <> 'Cancelada'
     GROUP BY c.id, c.nombre
     ORDER BY total_reservas DESC, c.nombre
     LIMIT 10;
$$
LANGUAGE sql
STABLE;


-- Top 5 de clientes con más reservas 
CREATE OR REPLACE FUNCTION top_reservas()
RETURNS TABLE (
    cliente_id int,
    nombre varchar,
    total_reservas bigint,
    plato_favorito_id int,
    plato_favorito varchar
) AS
$$
    SELECT c.id,
           c.nombre,
           COUNT(*) AS total_reservas,
           c.platoFav AS plato_favorito_id,
           m.descripcion AS plato_favorito
      FROM cliente c
      JOIN reserva r ON r.cliente_fk = c.id
      LEFT JOIN menu m ON m.id = c.platoFav
     WHERE COALESCE(r.status, 'Activa') <> 'Cancelada'
     GROUP BY c.id, c.nombre, c.platoFav, m.descripcion
     ORDER BY total_reservas DESC, c.nombre
     LIMIT 5;
$$
LANGUAGE sql
STABLE;


-- Reporte mensual de insumos con bajo stock o próximos a caducar.
CREATE OR REPLACE FUNCTION reporte_inventario_mensual()
RETURNS TABLE (
    inventario_id int,
    producto varchar,
    sede_id int,
    existencia int,
    caducidad date,
    dias_para_caducar int,
    tipo_alerta text
) AS
$$
    SELECT i.id,
           i.producto,
           i.sede_id,
           i.existencia,
           i.caducidad,
           (i.caducidad - CURRENT_DATE) AS dias_para_caducar,
           CASE
               WHEN i.existencia <= 20 AND i.caducidad <= CURRENT_DATE THEN 'Bajo stock y caducado'
               WHEN i.existencia <= 20 AND i.caducidad <= CURRENT_DATE + INTERVAL '30 days' THEN 'Bajo stock y por caducar'
               WHEN i.existencia <= 20 THEN 'Bajo stock'
               WHEN i.caducidad <= CURRENT_DATE THEN 'Caducado'
               WHEN i.caducidad <= CURRENT_DATE + INTERVAL '30 days' THEN 'Por caducar'
           END AS tipo_alerta
      FROM inventario i
     WHERE i.existencia <= 20
        OR i.caducidad <= CURRENT_DATE + INTERVAL '30 days'
     ORDER BY i.caducidad, i.producto;
$$
LANGUAGE sql
STABLE;


-- Comportamiento de sucursales con mayor actividad en reservas y ventas.
CREATE OR REPLACE FUNCTION resumen_sucursales()
RETURNS TABLE (
    sede_id int,
    direccion varchar,
    total_reservas bigint,
    reservas_no_canceladas bigint,
    total_ventas numeric
) AS
$$
    SELECT s.id AS sede_id,
           s.direccion,
           COUNT(DISTINCT r.id) AS total_reservas,
           COUNT(DISTINCT CASE WHEN COALESCE(r.status, 'Activa') <> 'Cancelada' THEN r.id END) AS reservas_no_canceladas,
           COALESCE(SUM(CASE WHEN COALESCE(r.status, 'Activa') <> 'Cancelada' THEN m.precio END), 0) AS total_ventas
      FROM sede s
      LEFT JOIN reserva r ON r.sede_fk = s.id
      LEFT JOIN pide p ON p.reservaid = r.id
      LEFT JOIN menu m ON m.id = p.menuid
     GROUP BY s.id, s.direccion
     ORDER BY total_reservas DESC, total_ventas DESC;
$$
LANGUAGE sql
STABLE;


-- Consulta parametrizable de la bitácora.
CREATE OR REPLACE FUNCTION bitacora_listar(p_limite int DEFAULT 20)
RETURNS TABLE (
    id int,
    esquema varchar,
    id_afectado int,
    operacion varchar,
    fecha timestamp,
    detalle varchar,
    personal_id int
) AS
$$
    SELECT b.id,
           b.esquema,
           b.id_afectado,
           b.operacion,
           b.fecha,
           b.detalle,
           b.personal_id
      FROM bitacora b
     ORDER BY b.fecha DESC
     LIMIT CASE
               WHEN p_limite IS NULL OR p_limite <= 0 THEN 20
               WHEN p_limite > 200 THEN 200
               ELSE p_limite
           END;
$$
LANGUAGE sql
STABLE;

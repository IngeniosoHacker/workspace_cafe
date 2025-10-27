-- Alerta de inventario cuando un producto se agota o se acerca a caducar.
CREATE OR REPLACE FUNCTION fn_alerta_inventario()
RETURNS trigger AS
$$
DECLARE
    total_existencia integer;
    fecha_cercana date;
    dias_para_caducar integer;
    limite_existencia CONSTANT integer := 20;
    ventana_caducidad CONSTANT integer := 7;
BEGIN
    SELECT SUM(existencia), MIN(caducidad)
      INTO total_existencia, fecha_cercana
      FROM inventario
     WHERE producto = NEW.producto
       AND sede_id = NEW.sede_id;

    IF total_existencia IS NOT NULL AND total_existencia <= limite_existencia THEN
        RAISE WARNING 'Alerta inventario bajo: producto % con existencia % en sede %.', NEW.producto, total_existencia, NEW.sede_id;
    END IF;

    IF fecha_cercana IS NOT NULL THEN
        dias_para_caducar := fecha_cercana - CURRENT_DATE;

        IF dias_para_caducar <= 0 THEN
            RAISE WARNING 'Alerta de caducidad: producto % caducado desde % en sede %.', NEW.producto, fecha_cercana, NEW.sede_id;
        ELSIF dias_para_caducar <= ventana_caducidad THEN
            RAISE WARNING 'Alerta de caducidad: producto % en sede % caduca el % (en % días).', NEW.producto, NEW.sede_id, fecha_cercana, dias_para_caducar;
        END IF;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_alerta_inventario ON inventario;

CREATE TRIGGER trg_alerta_inventario
AFTER INSERT OR UPDATE OF existencia, caducidad ON inventario
FOR EACH ROW
EXECUTE FUNCTION fn_alerta_inventario();

-- trigger para validar disponibilidad de espacio en reservas
CREATE OR REPLACE FUNCTION validar_dispo()
RETURNS trigger AS
$$
DECLARE
    conflicto_id reserva.id%TYPE;
BEGIN
    SELECT r.id
      INTO conflicto_id
      FROM reserva r
     WHERE r.espacio_fk = NEW.espacio_fk
       AND r.sede_fk = NEW.sede_fk
       AND DATE(r.horaFecha) = DATE(NEW.horaFecha)
       AND COALESCE(r.status, 'Activa') <> 'Cancelada'
     LIMIT 1;

    IF conflicto_id IS NOT NULL THEN
        RAISE EXCEPTION
            USING MESSAGE = format(
                'El espacio % en la sede % ya está reservado para la fecha % (reserva existente: %).',
                NEW.espacio_fk,
                NEW.sede_fk,
                to_char(NEW.horaFecha, 'YYYY-MM-DD-HH24-MI'),
                conflicto_id
            );
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS trg_validar_disponibilidad ON reserva;

CREATE TRIGGER trg_validar_disponibilidad
BEFORE INSERT ON reserva
FOR EACH ROW
EXECUTE FUNCTION validar_dispo();

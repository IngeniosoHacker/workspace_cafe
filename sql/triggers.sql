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


-- Bitácora automática de cambios en tablas operativas.
CREATE OR REPLACE FUNCTION fn_registro_bitacora()
RETURNS trigger AS
$$
DECLARE
    v_json jsonb;
    v_id_text text;
    v_id int := 0;
    v_personal_text text;
    v_personal int := 0;
    v_detalle text;
    v_context_personal text;
BEGIN
    IF TG_TABLE_NAME = 'bitacora' THEN
        RETURN NULL;
    END IF;

    IF TG_OP = 'DELETE' THEN
        v_json := to_jsonb(OLD);
    ELSE
        v_json := to_jsonb(NEW);
    END IF;

    v_id_text := COALESCE(
        v_json ->> 'id',
        v_json ->> 'reservaid',
        v_json ->> 'menuid',
        v_json ->> 'inventid',
        v_json ->> 'cliente_fk',
        v_json ->> 'personal_fk'
    );

    IF v_id_text IS NOT NULL AND v_id_text ~ '^\d+$' THEN
        v_id := v_id_text::int;
    END IF;

    v_personal_text := COALESCE(
        v_json ->> 'personal_fk',
        v_json ->> 'personal_id',
        NULL
    );

    v_context_personal := current_setting('app.current_personal_id', true);

    IF (v_personal_text IS NULL OR v_personal_text = '') AND v_context_personal IS NOT NULL AND v_context_personal <> '' THEN
        v_personal_text := v_context_personal;
    END IF;

    IF v_personal_text IS NOT NULL AND v_personal_text ~ '^\d+$' THEN
        v_personal := v_personal_text::int;
    END IF;

    v_detalle := left(v_json::text, 120);

    INSERT INTO bitacora(esquema, id_afectado, operacion, detalle, personal_id)
    VALUES (
        format('%I.%I', TG_TABLE_SCHEMA, TG_TABLE_NAME),
        v_id,
        TG_OP,
        v_detalle,
        v_personal
    );

    RETURN NULL;
END;
$$
LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS trg_bitacora_menu ON menu;
CREATE TRIGGER trg_bitacora_menu
AFTER INSERT OR UPDATE OR DELETE ON menu
FOR EACH ROW
EXECUTE FUNCTION fn_registro_bitacora();

DROP TRIGGER IF EXISTS trg_bitacora_sede ON sede;
CREATE TRIGGER trg_bitacora_sede
AFTER INSERT OR UPDATE OR DELETE ON sede
FOR EACH ROW
EXECUTE FUNCTION fn_registro_bitacora();

DROP TRIGGER IF EXISTS trg_bitacora_inventario ON inventario;
CREATE TRIGGER trg_bitacora_inventario
AFTER INSERT OR UPDATE OR DELETE ON inventario
FOR EACH ROW
EXECUTE FUNCTION fn_registro_bitacora();

DROP TRIGGER IF EXISTS trg_bitacora_receta ON receta;
CREATE TRIGGER trg_bitacora_receta
AFTER INSERT OR UPDATE OR DELETE ON receta
FOR EACH ROW
EXECUTE FUNCTION fn_registro_bitacora();

DROP TRIGGER IF EXISTS trg_bitacora_cliente ON cliente;
CREATE TRIGGER trg_bitacora_cliente
AFTER INSERT OR UPDATE OR DELETE ON cliente
FOR EACH ROW
EXECUTE FUNCTION fn_registro_bitacora();

DROP TRIGGER IF EXISTS trg_bitacora_espacio ON espacio;
CREATE TRIGGER trg_bitacora_espacio
AFTER INSERT OR UPDATE OR DELETE ON espacio
FOR EACH ROW
EXECUTE FUNCTION fn_registro_bitacora();

DROP TRIGGER IF EXISTS trg_bitacora_personal ON personal;
CREATE TRIGGER trg_bitacora_personal
AFTER INSERT OR UPDATE OR DELETE ON personal
FOR EACH ROW
EXECUTE FUNCTION fn_registro_bitacora();

DROP TRIGGER IF EXISTS trg_bitacora_reserva ON reserva;
CREATE TRIGGER trg_bitacora_reserva
AFTER INSERT OR UPDATE OR DELETE ON reserva
FOR EACH ROW
EXECUTE FUNCTION fn_registro_bitacora();

DROP TRIGGER IF EXISTS trg_bitacora_pide ON pide;
CREATE TRIGGER trg_bitacora_pide
AFTER INSERT OR UPDATE OR DELETE ON pide
FOR EACH ROW
EXECUTE FUNCTION fn_registro_bitacora();

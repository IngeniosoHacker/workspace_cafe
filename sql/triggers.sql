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

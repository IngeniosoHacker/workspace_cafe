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

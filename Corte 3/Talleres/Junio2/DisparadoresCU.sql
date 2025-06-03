-- 1. Descripción del Problema:
-- El estado de un programa de entrenamiento asignado a un cliente (client_training_program.status)
-- necesita reflejar si el programa está 'Activo', 'Finalizado' o 'Pendiente' basándose en sus
-- fechas de inicio (start_date) y fin (end_date). 

-- Solución Implementada:
-- Un disparador BEFORE INSERT OR UPDATE en la tabla client_training_program
-- establecerá automáticamente el estado. No modificará el estado si ya está 'Cancelado'.

CREATE OR REPLACE FUNCTION actualizar_estado_programa_cliente_func()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo actualiza el estado si no ha sido  'Cancelado'
    IF NEW.status IS DISTINCT FROM 'Cancelado' THEN
        -- Si la fecha de fin ya pasó, el programa está finalizado
        IF NEW.end_date < CURRENT_TIMESTAMP THEN
            NEW.status := 'Finalizado';
        -- Si la fecha actual está dentro del rango del programa, está activo
        ELSIF NEW.start_date <= CURRENT_TIMESTAMP AND NEW.end_date >= CURRENT_TIMESTAMP THEN
            NEW.status := 'Activo';
        -- Si la fecha de inicio aún no ha llegado, el programa está pendiente
        ELSIF NEW.start_date > CURRENT_TIMESTAMP THEN
            NEW.status := 'Pendiente';
        END IF;
    END IF;
    RETURN NEW; 
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER actualizar_estado_programa_cliente
BEFORE INSERT OR UPDATE ON client_training_program
FOR EACH ROW
EXECUTE FUNCTION actualizar_estado_programa_cliente_func();



UPDATE client_training_program
SET start_date = start_date; 

select * from client_training_program ctp 




-- 2. Descripción del Problema:
-- La disponibilidad de un coach (coach.availability) debería reflejar si tiene alguna
-- rutina asignada en la tabla schedule. Si un coach no tiene horarios, debería ser 'inactivo';
-- si tiene, 'activo'. 

-- Solución Implementada:
-- Un disparador AFTER INSERT OR UPDATE OR DELETE en la tabla schedule.
-- Cuando se modifica el horario de un coach, la función asociada cuenta cuántas
-- entradas tiene ese coach en schedule. Si es 0, actualiza coach.availability a 'inactivo';
-- si es mayor que 0, a 'activo'.


CREATE OR REPLACE FUNCTION actualizar_disponibilidad_coach_func()
RETURNS TRIGGER AS $$
DECLARE
    v_coach_id INT;
    v_num_schedules INT;
BEGIN
    
    IF TG_OP = 'DELETE' THEN
        v_coach_id := OLD.coach_id;
    ELSE 
        v_coach_id := NEW.coach_id;
    END IF;

    -- Contar cuántos horarios tiene el coach
    SELECT COUNT(*) INTO v_num_schedules
    FROM schedule
    WHERE coach_id = v_coach_id;

    -- Actualizar la disponibilidad del coach
    IF v_num_schedules > 0 THEN
        UPDATE coach
        SET availability = 'activo'
        WHERE coach_id = v_coach_id;
    ELSE
        UPDATE coach
        SET availability = 'inactivo'
        WHERE coach_id = v_coach_id;
    END IF;

    RETURN NULL; 
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER actualizar_disponibilidad_coach
AFTER INSERT OR UPDATE OR DELETE ON schedule
FOR EACH ROW
EXECUTE FUNCTION actualizar_disponibilidad_coach_func();


UPDATE schedule
SET start_time = start_time; 

select * from coach c 


-- 3. Descripción del Problema:
-- Los pagos 'Pendiente' cuya fecha de pago ya ha pasado deberían cambiar
-- automáticamente a 'Vencido'.

-- Solución Implementada:
-- Un disparador BEFORE INSERT OR UPDATE en la tabla payments.
-- Si el pago está 'Pendiente' y la payment_date es anterior a la fecha actual,
-- el estado se actualiza automáticamente a 'Vencido'.

CREATE OR REPLACE FUNCTION actualizar_estado_pago_vencido_func()
RETURNS TRIGGER AS $$
BEGIN
    -- Si el estado es 'Pendiente' y la fecha de pago ya pasó, actualizar a 'Vencido'
    IF NEW.status = 'Pendiente' AND NEW.payment_date < CURRENT_DATE THEN
        NEW.status := 'Vencido';
    END IF;
    RETURN NEW; 
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER actualizar_estado_pago_vencido
BEFORE INSERT OR UPDATE ON payments
FOR EACH ROW
EXECUTE FUNCTION actualizar_estado_pago_vencido_func();



UPDATE payments
SET payment_date = payment_date;

select * from payments p 

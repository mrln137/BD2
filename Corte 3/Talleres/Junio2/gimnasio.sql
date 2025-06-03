--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2025-06-02 23:19:28

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE gimnasio;
--
-- TOC entry 4981 (class 1262 OID 34142)
-- Name: gimnasio; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE gimnasio WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'es-CO';


ALTER DATABASE gimnasio OWNER TO postgres;

\connect gimnasio

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 4982 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 229 (class 1255 OID 34265)
-- Name: actualizar_disponibilidad_coach_func(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_disponibilidad_coach_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.actualizar_disponibilidad_coach_func() OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 34267)
-- Name: actualizar_estado_pago_vencido_func(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_estado_pago_vencido_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Si el estado es 'Pendiente' y la fecha de pago ya pasó, actualizar a 'Vencido'
    IF NEW.status = 'Pendiente' AND NEW.payment_date < CURRENT_DATE THEN
        NEW.status := 'Vencido';
    END IF;
    RETURN NEW; 
END;
$$;


ALTER FUNCTION public.actualizar_estado_pago_vencido_func() OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 34263)
-- Name: actualizar_estado_programa_cliente_func(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_estado_programa_cliente_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Solo actualiza el estado si no ha sido explícitamente 'Cancelado'
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
    RETURN NEW; -- Retorna el nuevo registro (modificado si aplica)
END;
$$;


ALTER FUNCTION public.actualizar_estado_programa_cliente_func() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 34143)
-- Name: client; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client (
    client_id integer NOT NULL,
    name character varying(30),
    last_name character varying(30),
    phone integer,
    email character varying(30)
);


ALTER TABLE public.client OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 34248)
-- Name: client_schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client_schedule (
    client_schedule_id integer NOT NULL,
    schedule_id integer,
    client_id integer
);


ALTER TABLE public.client_schedule OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 34160)
-- Name: client_training_program; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client_training_program (
    client_training_program_id integer NOT NULL,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    status character varying,
    client_id integer,
    training_program integer
);


ALTER TABLE public.client_training_program OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 34148)
-- Name: coach; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.coach (
    coach_id integer NOT NULL,
    name character varying(30),
    last_name character varying(30),
    phone integer,
    email character varying(30),
    availability character varying,
    specialty character varying(30)
);


ALTER TABLE public.coach OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 34211)
-- Name: exercises; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exercises (
    exercises_id integer NOT NULL,
    name character varying(30),
    description text,
    muscle_group character varying(50),
    type text,
    required_equipment text,
    duration_aprox_seconds integer
);


ALTER TABLE public.exercises OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 34177)
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    payments_id integer NOT NULL,
    price numeric(10,2),
    payment_date timestamp without time zone,
    status character varying,
    client_training_program_id integer
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 34189)
-- Name: routine; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.routine (
    routine_id integer NOT NULL,
    name character varying(30),
    description text,
    objective character varying(80),
    level character varying,
    duration_weeks integer,
    days_of_the_week integer
);


ALTER TABLE public.routine OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 34218)
-- Name: routine_exercises; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.routine_exercises (
    routine_exercises_id integer NOT NULL,
    routine_id integer,
    exercises_id integer,
    client_id integer
);


ALTER TABLE public.routine_exercises OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 34196)
-- Name: routine_training_program; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.routine_training_program (
    routine_training_program_id integer NOT NULL,
    status boolean,
    routine_id integer,
    training_program integer
);


ALTER TABLE public.routine_training_program OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 34233)
-- Name: schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schedule (
    schedule_id integer NOT NULL,
    coach_id integer,
    routine_id integer,
    start_time time without time zone,
    end_time time without time zone
);


ALTER TABLE public.schedule OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 34155)
-- Name: training_program; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.training_program (
    training_program_id integer NOT NULL,
    name character varying(30),
    price integer,
    goal character varying(60)
);


ALTER TABLE public.training_program OWNER TO postgres;

--
-- TOC entry 4965 (class 0 OID 34143)
-- Dependencies: 217
-- Data for Name: client; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.client VALUES (1, 'Ana', 'García', 123456789, 'ana.garcia@email.com');
INSERT INTO public.client VALUES (2, 'Luis', 'Martínez', 987654321, 'luis.martinez@email.com');
INSERT INTO public.client VALUES (3, 'Sofía', 'Rodríguez', 555111222, 'sofia.r@email.com');
INSERT INTO public.client VALUES (4, 'Carlos', 'López', 333444555, 'carlos.l@email.com');
INSERT INTO public.client VALUES (5, 'Elena', 'Fernández', 777888999, 'elena.f@email.com');
INSERT INTO public.client VALUES (6, 'Diego', 'Pérez', 111222333, 'diego.p@email.com');


--
-- TOC entry 4975 (class 0 OID 34248)
-- Dependencies: 227
-- Data for Name: client_schedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.client_schedule VALUES (1001, 901, 1);
INSERT INTO public.client_schedule VALUES (1002, 902, 3);
INSERT INTO public.client_schedule VALUES (1003, 903, 2);
INSERT INTO public.client_schedule VALUES (1004, 904, 4);
INSERT INTO public.client_schedule VALUES (1005, 901, 5);
INSERT INTO public.client_schedule VALUES (1006, 905, 6);


--
-- TOC entry 4968 (class 0 OID 34160)
-- Dependencies: 220
-- Data for Name: client_training_program; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.client_training_program VALUES (301, '2024-01-15 09:00:00', '2024-04-15 09:00:00', 'Finalizado', 1, 201);
INSERT INTO public.client_training_program VALUES (302, '2024-02-01 10:00:00', '2024-05-01 10:00:00', 'Finalizado', 2, 202);
INSERT INTO public.client_training_program VALUES (303, '2023-10-20 11:00:00', '2024-01-20 11:00:00', 'Finalizado', 3, 203);
INSERT INTO public.client_training_program VALUES (304, '2024-03-10 12:00:00', '2024-06-10 12:00:00', 'Finalizado', 4, 204);
INSERT INTO public.client_training_program VALUES (305, '2024-01-05 13:00:00', '2024-03-05 13:00:00', 'Cancelado', 5, 201);
INSERT INTO public.client_training_program VALUES (306, '2024-04-01 14:00:00', '2024-07-01 14:00:00', 'Finalizado', 6, 205);


--
-- TOC entry 4966 (class 0 OID 34148)
-- Dependencies: 218
-- Data for Name: coach; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.coach VALUES (103, 'Pedro', 'Díaz', 600505606, 'pedro.d@email.com', 'inactivo', 'Nutrición');
INSERT INTO public.coach VALUES (102, 'María', 'González', 600303404, 'maria.g@email.com', 'activo', 'Cardio');
INSERT INTO public.coach VALUES (101, 'Javier', 'Sánchez', 600101202, 'javier.s@email.com', 'activo', 'Fuerza');
INSERT INTO public.coach VALUES (104, 'Laura', 'Ruiz', 600707808, 'laura.r@email.com', 'activo', 'Yoga');
INSERT INTO public.coach VALUES (105, 'Miguel', 'Hernández', 600909000, 'miguel.h@email.com', 'activo', 'Crossfit');
INSERT INTO public.coach VALUES (106, 'Andrea', 'Jiménez', 600112233, 'andrea.j@email.com', 'activo', 'Pilates');


--
-- TOC entry 4972 (class 0 OID 34211)
-- Dependencies: 224
-- Data for Name: exercises; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.exercises VALUES (701, 'Sentadilla', 'Ejercicio compuesto para piernas y glúteos.', 'Piernas, Glúteos', 'Fuerza', 'Barra, Mancuernas', 60);
INSERT INTO public.exercises VALUES (702, 'Flexiones de Pecho', 'Ejercicio para pecho, hombros y tríceps.', 'Pecho, Hombros, Tríceps', 'Fuerza', 'Ninguno', 45);
INSERT INTO public.exercises VALUES (703, 'Remo con Barra', 'Ejercicio para la espalda y bíceps.', 'Espalda, Bíceps', 'Fuerza', 'Barra', 60);
INSERT INTO public.exercises VALUES (704, 'Plancha', 'Ejercicio isométrico para el core.', 'Core, Abdominales', 'Resistencia', 'Ninguno', 30);
INSERT INTO public.exercises VALUES (705, 'Press de Hombros', 'Ejercicio para los hombros.', 'Hombros, Tríceps', 'Fuerza', 'Mancuernas', 50);
INSERT INTO public.exercises VALUES (706, 'Burpees', 'Ejercicio de cuerpo completo cardiovascular.', 'Cuerpo Completo', 'Cardio', 'Ninguno', 90);


--
-- TOC entry 4969 (class 0 OID 34177)
-- Dependencies: 221
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.payments VALUES (401, 150.00, '2024-01-10 08:00:00', 'Pagado', 301);
INSERT INTO public.payments VALUES (402, 200.00, '2024-01-28 09:00:00', 'Pagado', 302);
INSERT INTO public.payments VALUES (403, 120.00, '2023-10-15 10:00:00', 'Pagado', 303);
INSERT INTO public.payments VALUES (404, 100.00, '2024-03-05 11:00:00', 'Vencido', 304);
INSERT INTO public.payments VALUES (405, 180.00, '2024-01-01 12:00:00', 'Vencido', 305);
INSERT INTO public.payments VALUES (406, 180.00, '2024-03-28 13:00:00', 'Pagado', 306);


--
-- TOC entry 4970 (class 0 OID 34189)
-- Dependencies: 222
-- Data for Name: routine; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.routine VALUES (501, 'Full Body Principiante', 'Rutina para trabajar todos los grupos musculares, ideal para empezar.', 'Ganar fuerza general y resistencia', 'principiante', 8, 3);
INSERT INTO public.routine VALUES (502, 'Hipertrofia Avanzada', 'Rutina dividida para máxima ganancia muscular.', 'Aumento significativo de masa muscular', 'avanzado', 12, 5);
INSERT INTO public.routine VALUES (503, 'Cardio Quema Grasa', 'Sesiones de cardio de alta intensidad para quemar calorías.', 'Reducción de porcentaje de grasa corporal', 'intermedio', 6, 4);
INSERT INTO public.routine VALUES (504, 'Yoga Flexibilidad', 'Serie de posturas para mejorar la flexibilidad y el equilibrio.', 'Mejorar la flexibilidad y reducir el estrés', 'principiante', 10, 3);
INSERT INTO public.routine VALUES (505, 'Fuerza Explosiva', 'Entrenamiento enfocado en la potencia y la fuerza máxima.', 'Incrementar la fuerza explosiva y el rendimiento deportivo', 'avanzado', 8, 4);
INSERT INTO public.routine VALUES (506, 'Core y Estabilidad', 'Ejercicios para fortalecer el centro del cuerpo y mejorar la postura.', 'Fortalecer el core y prevenir lesiones', 'intermedio', 6, 3);


--
-- TOC entry 4973 (class 0 OID 34218)
-- Dependencies: 225
-- Data for Name: routine_exercises; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.routine_exercises VALUES (801, 501, 701, 1);
INSERT INTO public.routine_exercises VALUES (802, 501, 702, 1);
INSERT INTO public.routine_exercises VALUES (803, 502, 703, 2);
INSERT INTO public.routine_exercises VALUES (804, 503, 706, 3);
INSERT INTO public.routine_exercises VALUES (805, 504, 704, 4);
INSERT INTO public.routine_exercises VALUES (806, 501, 705, 1);
INSERT INTO public.routine_exercises VALUES (807, 502, 701, 2);


--
-- TOC entry 4971 (class 0 OID 34196)
-- Dependencies: 223
-- Data for Name: routine_training_program; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.routine_training_program VALUES (601, true, 501, 201);
INSERT INTO public.routine_training_program VALUES (602, true, 502, 202);
INSERT INTO public.routine_training_program VALUES (603, true, 503, 201);
INSERT INTO public.routine_training_program VALUES (604, true, 504, 204);
INSERT INTO public.routine_training_program VALUES (605, false, 505, 202);
INSERT INTO public.routine_training_program VALUES (606, true, 506, 204);


--
-- TOC entry 4974 (class 0 OID 34233)
-- Dependencies: 226
-- Data for Name: schedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.schedule VALUES (901, 101, 501, '08:00:00', '09:00:00');
INSERT INTO public.schedule VALUES (902, 102, 503, '10:00:00', '11:00:00');
INSERT INTO public.schedule VALUES (903, 101, 502, '14:00:00', '15:30:00');
INSERT INTO public.schedule VALUES (904, 104, 504, '17:00:00', '18:00:00');
INSERT INTO public.schedule VALUES (905, 105, 505, '09:00:00', '10:30:00');
INSERT INTO public.schedule VALUES (906, 106, 506, '11:00:00', '12:00:00');


--
-- TOC entry 4967 (class 0 OID 34155)
-- Dependencies: 219
-- Data for Name: training_program; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.training_program VALUES (201, 'Transformación Total', 150, 'Pérdida de peso y tonificación muscular');
INSERT INTO public.training_program VALUES (202, 'Ganancia Muscular', 200, 'Aumento de masa muscular y fuerza');
INSERT INTO public.training_program VALUES (203, 'Maratón Ready', 120, 'Preparación para carrera de larga distancia');
INSERT INTO public.training_program VALUES (204, 'Bienestar Integral', 100, 'Mejora de la salud general y flexibilidad');
INSERT INTO public.training_program VALUES (205, 'Definición Extrema', 180, 'Reducción de grasa y definición muscular');
INSERT INTO public.training_program VALUES (206, 'Rehabilitación Post-lesión', 90, 'Recuperación y fortalecimiento tras una lesión');


--
-- TOC entry 4785 (class 2606 OID 34147)
-- Name: client client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (client_id);


--
-- TOC entry 4805 (class 2606 OID 34252)
-- Name: client_schedule client_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_schedule
    ADD CONSTRAINT client_schedule_pkey PRIMARY KEY (client_schedule_id);


--
-- TOC entry 4791 (class 2606 OID 34166)
-- Name: client_training_program client_training_program_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_training_program
    ADD CONSTRAINT client_training_program_pkey PRIMARY KEY (client_training_program_id);


--
-- TOC entry 4787 (class 2606 OID 34154)
-- Name: coach coach_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coach
    ADD CONSTRAINT coach_pkey PRIMARY KEY (coach_id);


--
-- TOC entry 4799 (class 2606 OID 34217)
-- Name: exercises exercises_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exercises
    ADD CONSTRAINT exercises_pkey PRIMARY KEY (exercises_id);


--
-- TOC entry 4793 (class 2606 OID 34183)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payments_id);


--
-- TOC entry 4801 (class 2606 OID 34222)
-- Name: routine_exercises routine_exercises_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routine_exercises
    ADD CONSTRAINT routine_exercises_pkey PRIMARY KEY (routine_exercises_id);


--
-- TOC entry 4795 (class 2606 OID 34195)
-- Name: routine routine_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routine
    ADD CONSTRAINT routine_pkey PRIMARY KEY (routine_id);


--
-- TOC entry 4797 (class 2606 OID 34200)
-- Name: routine_training_program routine_training_program_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routine_training_program
    ADD CONSTRAINT routine_training_program_pkey PRIMARY KEY (routine_training_program_id);


--
-- TOC entry 4803 (class 2606 OID 34237)
-- Name: schedule schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (schedule_id);


--
-- TOC entry 4789 (class 2606 OID 34159)
-- Name: training_program training_program_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.training_program
    ADD CONSTRAINT training_program_pkey PRIMARY KEY (training_program_id);


--
-- TOC entry 4819 (class 2620 OID 34266)
-- Name: schedule actualizar_disponibilidad_coach; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER actualizar_disponibilidad_coach AFTER INSERT OR DELETE OR UPDATE ON public.schedule FOR EACH ROW EXECUTE FUNCTION public.actualizar_disponibilidad_coach_func();


--
-- TOC entry 4818 (class 2620 OID 34268)
-- Name: payments actualizar_estado_pago_vencido; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER actualizar_estado_pago_vencido BEFORE INSERT OR UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.actualizar_estado_pago_vencido_func();


--
-- TOC entry 4817 (class 2620 OID 34264)
-- Name: client_training_program actualizar_estado_programa_cliente; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER actualizar_estado_programa_cliente BEFORE INSERT OR UPDATE ON public.client_training_program FOR EACH ROW EXECUTE FUNCTION public.actualizar_estado_programa_cliente_func();


--
-- TOC entry 4815 (class 2606 OID 34258)
-- Name: client_schedule client_schedule_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_schedule
    ADD CONSTRAINT client_schedule_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.client(client_id);


--
-- TOC entry 4816 (class 2606 OID 34253)
-- Name: client_schedule client_schedule_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_schedule
    ADD CONSTRAINT client_schedule_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.schedule(schedule_id);


--
-- TOC entry 4806 (class 2606 OID 34167)
-- Name: client_training_program client_training_program_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_training_program
    ADD CONSTRAINT client_training_program_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.client(client_id);


--
-- TOC entry 4807 (class 2606 OID 34172)
-- Name: client_training_program client_training_program_training_program_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_training_program
    ADD CONSTRAINT client_training_program_training_program_fkey FOREIGN KEY (training_program) REFERENCES public.training_program(training_program_id);


--
-- TOC entry 4808 (class 2606 OID 34184)
-- Name: payments payments_client_training_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_client_training_program_id_fkey FOREIGN KEY (client_training_program_id) REFERENCES public.client_training_program(client_training_program_id);


--
-- TOC entry 4811 (class 2606 OID 34228)
-- Name: routine_exercises routine_exercises_exercises_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routine_exercises
    ADD CONSTRAINT routine_exercises_exercises_id_fkey FOREIGN KEY (exercises_id) REFERENCES public.exercises(exercises_id);


--
-- TOC entry 4812 (class 2606 OID 34223)
-- Name: routine_exercises routine_exercises_routine_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routine_exercises
    ADD CONSTRAINT routine_exercises_routine_id_fkey FOREIGN KEY (routine_id) REFERENCES public.routine(routine_id);


--
-- TOC entry 4809 (class 2606 OID 34201)
-- Name: routine_training_program routine_training_program_routine_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routine_training_program
    ADD CONSTRAINT routine_training_program_routine_id_fkey FOREIGN KEY (routine_id) REFERENCES public.routine(routine_id);


--
-- TOC entry 4810 (class 2606 OID 34206)
-- Name: routine_training_program routine_training_program_training_program_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routine_training_program
    ADD CONSTRAINT routine_training_program_training_program_fkey FOREIGN KEY (training_program) REFERENCES public.training_program(training_program_id);


--
-- TOC entry 4813 (class 2606 OID 34238)
-- Name: schedule schedule_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedule
    ADD CONSTRAINT schedule_coach_id_fkey FOREIGN KEY (coach_id) REFERENCES public.coach(coach_id);


--
-- TOC entry 4814 (class 2606 OID 34243)
-- Name: schedule schedule_routine_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedule
    ADD CONSTRAINT schedule_routine_id_fkey FOREIGN KEY (routine_id) REFERENCES public.routine(routine_id);


-- Completed on 2025-06-02 23:19:28

--
-- PostgreSQL database dump complete
--


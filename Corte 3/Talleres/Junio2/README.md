# Disparadores (Triggers) en Bases de Datos

## ¿Qué son y para qué sirven?

En el contexto de las bases de datos, un **disparador** (o *trigger*) es un tipo especial de procedimiento almacenado que se ejecuta automáticamente, o "se dispara", en respuesta a un evento específico en la base de datos. Estos eventos suelen ser operaciones de manipulación de datos (DML) como `INSERT`, `UPDATE`, o `DELETE` en una tabla específica.

Los disparadores sirven principalmente para:

* **Mantener la integridad referencial y de datos:** Asegurar que los datos cumplan con ciertas reglas o restricciones que no pueden ser impuestas por las restricciones de clave primaria/foránea tradicionales o por los `CHECK` constraints.
* **Auditoría y registro de cambios:** Registrar quién, cuándo y cómo se modificaron los datos en una tabla, creando un historial de transacciones.
* **Automatización de tareas:** Realizar acciones automáticamente cuando ocurren ciertos eventos, como actualizar una tabla de resumen, enviar notificaciones o realizar cálculos.
* **Implementar reglas de negocio complejas:** Codificar lógica de negocio que va más allá de las validaciones simples.
* **Sincronización de datos:** Mantener la consistencia entre tablas relacionadas o incluso entre diferentes bases de datos.

## Ventajas y Desventajas

### Ventajas

* **Automatización:** Ejecutan tareas repetitivas de forma automática, reduciendo la necesidad de intervención manual y el riesgo de errores humanos.
* **Integridad de datos:** Ayudan a mantener la consistencia y la validez de los datos al aplicar reglas de negocio complejas.
* **Centralización de la lógica:** La lógica de negocio puede ser encapsulada dentro del disparador, lo que facilita el mantenimiento y la modificación.
* **Transparencia para el usuario/aplicación:** La aplicación no necesita conocer la lógica interna del disparador; simplemente realiza la operación DML y el disparador se encarga del resto.
* **Seguridad:** Pueden ser utilizados para implementar reglas de seguridad adicionales o para auditar el acceso y las modificaciones a los datos.

### Desventajas

* **Dificultad de depuración:** Pueden ser difíciles de depurar y entender, ya que su ejecución es implícita y no directamente invocada por la aplicación.
* **Rendimiento:** Un diseño ineficiente o un uso excesivo de disparadores puede impactar negativamente el rendimiento de la base de datos, especialmente en operaciones con grandes volúmenes de datos.
* **Comportamiento inesperado:** Si no se diseñan cuidadosamente, los disparadores pueden llevar a comportamientos inesperados o a "side effects" no deseados.
* **Dependencia oculta:** Pueden crear dependencias complejas y ocultas entre tablas o módulos, lo que dificulta el mantenimiento y la comprensión del sistema.
* **Portabilidad:** La sintaxis y las características de los disparadores pueden variar entre diferentes sistemas de gestión de bases de datos (DBMS), lo que puede dificultar la migración.

# Sintaxis básica de un disparador en PostgreSQL

En PostgreSQL, para crear un disparador (**trigger**) se necesitan dos pasos principales:

---

## 1. Crear la función que será llamada por el disparador

Esta función debe tener un tipo de retorno `trigger` y definirse con `PL/pgSQL`.

```sql
CREATE OR REPLACE FUNCTION nombre_funcion()
RETURNS trigger AS $$
BEGIN
    -- Aquí va la lógica del trigger (por ejemplo, insertar en otra tabla, validar, etc.)
    RAISE NOTICE 'Se activó el trigger';
    RETURN NEW;  -- o RETURN OLD dependiendo del tipo de evento
END;
$$ LANGUAGE plpgsql;

```

## 2.Creación del Disparador
Una vez que tienes la función de disparador, puedes crear el disparador real que la asocia a una tabla y a los eventos deseados.

```sql
CREATE TRIGGER nombre_del_trigger
[BEFORE | AFTER | INSTEAD OF]  -- Momento en que se ejecuta el trigger
[INSERT OR UPDATE OR DELETE]   -- Evento que lo activa, Puedes usar varios combinados.
ON nombre_tabla                -- Tabla sobre la que actúa
[FOR EACH ROW | FOR EACH STATEMENT]  -- Nivel de ejecución
WHEN (condición)              -- (opcional) Condición para ejecutar
EXECUTE FUNCTION nombre_funcion_trigger();


```

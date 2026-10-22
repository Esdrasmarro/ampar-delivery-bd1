-- =====================================================================
-- Proyecto Final Base de Datos 1 - Sistema de Control de Delivery "Ampar"
-- Script 04: procedimientos almacenados
-- Ejecutar conectado como: AMPAR
-- Estudiante: Esdras Lemuel Marroquín Rojas - Carné 3190-13-13335
-- =====================================================================
-- Un procedimiento ejecuta una tarea (INSERT, UPDATE, validaciones) y no devuelve
-- un valor directamente (puede devolver datos con parámetros OUT).
-- Los procedimientos de los movimientos principales están en los paquetes (script 07).

-- ---------------------------------------------------------------------
-- pr_bitacora: guarda un evento en la bitácora.
-- La usan los triggers de bitácora y el inicio de sesión.
-- El usuario es el de la aplicación (CLIENT_IDENTIFIER que la aplicación coloca
-- en la sesión); si no hay, se guarda el usuario de Oracle.
-- No hace COMMIT: el evento queda en la misma transacción de la operación.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_bitacora (
    p_tabla       IN VARCHAR2,
    p_operacion   IN VARCHAR2,
    p_id_registro IN VARCHAR2,
    p_anterior    IN VARCHAR2,
    p_nuevo       IN VARCHAR2
)
IS
BEGIN
    INSERT INTO bitacora (usuario, tabla, operacion, id_registro, valor_anterior, valor_nuevo)
    VALUES (SUBSTR(NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER), 1, 50),
            UPPER(p_tabla),
            p_operacion,
            SUBSTR(p_id_registro, 1, 30),
            SUBSTR(p_anterior, 1, 4000),
            SUBSTR(p_nuevo, 1, 4000));
END pr_bitacora;
/

-- ---------------------------------------------------------------------
-- pr_actualizar_ubicacion: el repartidor envía su ubicación (tracking).
-- Transacción: UPDATE + COMMIT; si falla, ROLLBACK.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_actualizar_ubicacion (
    p_id_repartidor IN NUMBER,
    p_latitud       IN NUMBER,
    p_longitud      IN NUMBER
)
IS
BEGIN
    IF p_latitud IS NULL OR p_longitud IS NULL
       OR p_latitud NOT BETWEEN -90 AND 90 OR p_longitud NOT BETWEEN -180 AND 180 THEN
        RAISE_APPLICATION_ERROR(-20060, 'La ubicación no es válida.');
    END IF;

    UPDATE repartidor
       SET latitud         = p_latitud,
           longitud        = p_longitud,
           fecha_ubicacion = SYSDATE
     WHERE id_repartidor = p_id_repartidor
       AND estado        = 'A';

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20061, 'El repartidor no existe o está inactivo.');
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END pr_actualizar_ubicacion;
/

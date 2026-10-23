-- Script 04: procedimientos. Ejecutar como AMPAR
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

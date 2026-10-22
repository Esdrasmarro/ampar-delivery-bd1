SET DEFINE OFF
-- =====================================================================
-- Proyecto Final Base de Datos 1 - Sistema de Control de Delivery "Ampar"
-- Script 13: pruebas de la base de datos
-- Ejecutar conectado como: AMPAR (después de cargar los datos de prueba)
-- Estudiante: Esdras Lemuel Marroquín Rojas - Carné 3190-13-13335
-- =====================================================================
-- Cada bloque prueba una regla del negocio y escribe OK o FALLÓ.
-- Ejecutar con F5 (Ejecutar script) y revisar la pestaña "Salida de Script".
-- Las pruebas crean pedidos nuevos con el negocio 1 (abierto las 24 horas).

SET SERVEROUTPUT ON

-- ---------------------------------------------------------------------
-- Prueba 1: inicio de sesión correcto y contraseña encriptada
-- ---------------------------------------------------------------------
DECLARE
    v_id NUMBER; v_rol NUMBER; v_nombre_rol VARCHAR2(30); v_nombre VARCHAR2(100);
    v_c NUMBER; v_n NUMBER; v_r NUMBER;
    v_clave usuario.clave%TYPE;
BEGIN
    pkg_seguridad.pr_login('admin', 'Ampar2026', v_id, v_rol, v_nombre_rol, v_nombre, v_c, v_n, v_r);
    SELECT clave INTO v_clave FROM usuario WHERE nombre_usuario = 'admin';
    IF v_nombre_rol = 'ADMINISTRADOR' AND LENGTH(v_clave) = 64 AND v_clave <> 'Ampar2026' THEN
        DBMS_OUTPUT.PUT_LINE('OK     Prueba 1: login correcto; la clave se guarda encriptada: ' || SUBSTR(v_clave, 1, 16) || '...');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 1');
    END IF;
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 1: ' || SQLERRM);
END;
/

-- ---------------------------------------------------------------------
-- Prueba 2: contraseña incorrecta (debe rechazarse y quedar en la bitácora)
-- ---------------------------------------------------------------------
DECLARE
    v_id NUMBER; v_rol NUMBER; v_nombre_rol VARCHAR2(30); v_nombre VARCHAR2(100);
    v_c NUMBER; v_n NUMBER; v_r NUMBER;
BEGIN
    pkg_seguridad.pr_login('admin', 'claveMala', v_id, v_rol, v_nombre_rol, v_nombre, v_c, v_n, v_r);
    DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 2: entró con una clave incorrecta');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20010 THEN
            DBMS_OUTPUT.PUT_LINE('OK     Prueba 2: login rechazado -> ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 2: ' || SQLERRM);
        END IF;
END;
/

-- ---------------------------------------------------------------------
-- Prueba 3: seguridad entre módulos (permisos del menú en la BD)
-- ---------------------------------------------------------------------
DECLARE
    v_id_cliente NUMBER;
BEGIN
    SELECT id_usuario INTO v_id_cliente FROM usuario WHERE nombre_usuario = 'ana.perez@correo.com';
    IF pkg_seguridad.fn_tiene_permiso(v_id_cliente, '/pedidos/nuevo') = 'S'
       AND pkg_seguridad.fn_tiene_permiso(v_id_cliente, '/pedidos/mis-pedidos/15') = 'S'
       AND pkg_seguridad.fn_tiene_permiso(v_id_cliente, '/reportes/dashboard') = 'N'
       AND pkg_seguridad.fn_tiene_permiso(v_id_cliente, '/seguridad/usuarios') = 'N' THEN
        DBMS_OUTPUT.PUT_LINE('OK     Prueba 3: el cliente entra a Pedidos pero no a Reportes ni a Seguridad');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 3');
    END IF;
END;
/

-- ---------------------------------------------------------------------
-- Prueba 4: función de distancia (Haversine) y horario de negocio
-- ---------------------------------------------------------------------
DECLARE
    v_km NUMBER;
BEGIN
    -- de la Zona 1 a la Zona 10 hay unos 4.6 km en línea recta
    v_km := fn_distancia_km(14.6407, -90.5133, 14.6000, -90.5120);
    -- el Comedor Doña Chepita no entrega en domingo
    IF v_km BETWEEN 4 AND 5
       AND fn_negocio_abierto(6, TRUNC(SYSDATE, 'IW') + 6 + 10/24) = 'N'
       AND fn_negocio_abierto(1) = 'S' THEN
        DBMS_OUTPUT.PUT_LINE('OK     Prueba 4: distancia Zona 1 - Zona 10 = ' || v_km || ' km; horarios correctos');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 4: distancia = ' || v_km);
    END IF;
END;
/

-- ---------------------------------------------------------------------
-- Prueba 5: TRANSACCIÓN - tarjeta rechazada: no debe quedar nada guardado
-- ---------------------------------------------------------------------
DECLARE
    v_antes   NUMBER;
    v_despues NUMBER;
    v_id      NUMBER;
    v_msg     VARCHAR2(400);
BEGIN
    SELECT COUNT(*) INTO v_antes FROM pedido;
    BEGIN
        pkg_pedido.pr_crear_pedido(2, 1, 2, 2, '1:1,3:2', '4000 0000 0000 0002', 12, 2030, v_id, v_msg);
        DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 5: se aceptó una tarjeta que debía rechazarse');
    EXCEPTION
        WHEN OTHERS THEN
            SELECT COUNT(*) INTO v_despues FROM pedido;
            IF SQLCODE = -20037 AND v_antes = v_despues THEN
                DBMS_OUTPUT.PUT_LINE('OK     Prueba 5: tarjeta rechazada, ROLLBACK, pedidos antes = '
                                     || v_antes || ', después = ' || v_despues);
            ELSE
                DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 5: ' || SQLERRM);
            END IF;
    END;
END;
/

-- ---------------------------------------------------------------------
-- Prueba 6: dirección fuera de la cobertura de 10 km (Villa Nueva)
-- ---------------------------------------------------------------------
DECLARE
    v_id  NUMBER;
    v_msg VARCHAR2(400);
BEGIN
    pkg_pedido.pr_crear_pedido(7, 1, 9, 1, '3:1', NULL, NULL, NULL, v_id, v_msg);
    DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 6: se aceptó un pedido fuera de cobertura');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20033 THEN
            DBMS_OUTPUT.PUT_LINE('OK     Prueba 6: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 6: ' || SQLERRM);
        END IF;
END;
/

-- ---------------------------------------------------------------------
-- Prueba 7: pedido con tarjeta aprobada, asignación automática del
--           repartidor más cercano, historial y notificaciones
-- ---------------------------------------------------------------------
DECLARE
    v_id     NUMBER;
    v_msg    VARCHAR2(400);
    v_estado VARCHAR2(20);
    v_rep    NUMBER;
    v_notif  NUMBER;
    v_pago   NUMBER;
BEGIN
    pkg_pedido.pr_crear_pedido(2, 1, 2, 2, '1:1,3:2', '4111 1111 1111 1111', 12, 2030, v_id, v_msg);

    SELECT estado, id_repartidor INTO v_estado, v_rep FROM vw_pedido WHERE id_pedido = v_id;
    SELECT COUNT(*) INTO v_notif FROM notificacion WHERE id_pedido = v_id;
    SELECT COUNT(*) INTO v_pago FROM pago WHERE id_pedido = v_id AND tipo = 'PAGO';

    IF v_estado = 'ASIGNADO' AND v_rep IS NOT NULL AND v_notif = 4 AND v_pago = 1 THEN
        DBMS_OUTPUT.PUT_LINE('OK     Prueba 7: ' || v_msg);
    ELSE
        DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 7: estado ' || v_estado || ', notificaciones ' || v_notif || ' -> ' || v_msg);
    END IF;
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 7: ' || SQLERRM);
END;
/

-- ---------------------------------------------------------------------
-- Prueba 8: el repartidor cancela la entrega y el pedido se reasigna
--           a otro repartidor (el que canceló queda excluido)
-- ---------------------------------------------------------------------
DECLARE
    v_id        NUMBER;
    v_rep_antes NUMBER;
    v_rep_nuevo NUMBER;
    v_msg       VARCHAR2(400);
BEGIN
    SELECT MAX(id_pedido) INTO v_id FROM pedido WHERE id_cliente = 2;
    SELECT id_repartidor INTO v_rep_antes FROM pedido WHERE id_pedido = v_id;

    pkg_despacho.pr_cancelar_entrega(v_id, v_rep_antes, 4, 'Prueba: se pinchó la llanta', v_msg);

    SELECT id_repartidor INTO v_rep_nuevo FROM pedido WHERE id_pedido = v_id;
    IF v_rep_nuevo IS NOT NULL AND v_rep_nuevo <> v_rep_antes THEN
        DBMS_OUTPUT.PUT_LINE('OK     Prueba 8: repartidor ' || v_rep_antes || ' canceló. ' || v_msg);
    ELSE
        DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 8: ' || v_msg);
    END IF;
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 8: ' || SQLERRM);
END;
/

-- ---------------------------------------------------------------------
-- Prueba 9: no se puede saltar estados (ASIGNADO -> ENTREGADO)
-- ---------------------------------------------------------------------
DECLARE
    v_id  NUMBER;
    v_rep NUMBER;
BEGIN
    SELECT MAX(id_pedido) INTO v_id FROM pedido WHERE id_cliente = 2;
    SELECT id_repartidor INTO v_rep FROM pedido WHERE id_pedido = v_id;
    pkg_despacho.pr_cambiar_estado(v_id, v_rep, 'ENTREGADO');
    DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 9: permitió saltar estados');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20053 THEN
            DBMS_OUTPUT.PUT_LINE('OK     Prueba 9: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 9: ' || SQLERRM);
        END IF;
END;
/

-- ---------------------------------------------------------------------
-- Prueba 10: flujo completo de la entrega y calificación del repartidor
-- ---------------------------------------------------------------------
DECLARE
    v_id     NUMBER;
    v_rep    NUMBER;
    v_estado VARCHAR2(20);
    v_disp   CHAR(1);
BEGIN
    SELECT MAX(id_pedido) INTO v_id FROM pedido WHERE id_cliente = 2;
    SELECT id_repartidor INTO v_rep FROM pedido WHERE id_pedido = v_id;

    pkg_despacho.pr_cambiar_estado(v_id, v_rep, 'RECOGIDO');
    pr_actualizar_ubicacion(v_rep, 14.6390, -90.5140);
    pkg_despacho.pr_cambiar_estado(v_id, v_rep, 'EN RUTA');
    pkg_despacho.pr_cambiar_estado(v_id, v_rep, 'ENTREGADO');
    pkg_pedido.pr_calificar(v_id, 2, 5, 'Prueba: excelente servicio');

    SELECT estado INTO v_estado FROM vw_pedido WHERE id_pedido = v_id;
    SELECT disponible INTO v_disp FROM repartidor WHERE id_repartidor = v_rep;
    IF v_estado = 'ENTREGADO' AND v_disp = 'S' THEN
        DBMS_OUTPUT.PUT_LINE('OK     Prueba 10: pedido ' || v_id || ' ENTREGADO y calificado; el repartidor quedó disponible');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 10');
    END IF;

    -- no se puede calificar dos veces
    BEGIN
        pkg_pedido.pr_calificar(v_id, 2, 1, 'Segunda calificación');
        DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 10b: permitió calificar dos veces');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('OK     Prueba 10b: ' || SQLERRM);
    END;
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 10: ' || SQLERRM);
END;
/

-- ---------------------------------------------------------------------
-- Prueba 11: cancelación en efectivo dentro de los 5 minutos (zona roja).
--            El 15 % queda pendiente y se suma al siguiente pedido.
-- ---------------------------------------------------------------------
DECLARE
    v_id1   NUMBER;
    v_id2   NUMBER;
    v_msg   VARCHAR2(400);
    v_cargo NUMBER;
    v_cobro NUMBER;
    v_roja  CHAR(1);
BEGIN
    pkg_pedido.pr_crear_pedido(3, 1, 4, 1, '5:2', NULL, NULL, NULL, v_id1, v_msg);
    SELECT zona_roja INTO v_roja FROM pedido WHERE id_pedido = v_id1;

    pkg_pedido.pr_cancelar_pedido(v_id1, 3, 2, v_msg);
    DBMS_OUTPUT.PUT_LINE('       Prueba 11: ' || v_msg);
    SELECT monto_cobro INTO v_cobro FROM cancelacion_pedido WHERE id_pedido = v_id1;

    pkg_pedido.pr_crear_pedido(3, 1, 4, 1, '3:1', NULL, NULL, NULL, v_id2, v_msg);
    SELECT cargo_anterior INTO v_cargo FROM pedido WHERE id_pedido = v_id2;

    IF v_roja = 'S' AND v_cargo = v_cobro AND v_cargo > 0 THEN
        DBMS_OUTPUT.PUT_LINE('OK     Prueba 11: pedido en zona roja; cargo de Q' || v_cargo
                             || ' sumado al pedido ' || v_id2);
    ELSE
        DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 11: cargo = ' || v_cargo || ', cobro = ' || v_cobro);
    END IF;
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 11: ' || SQLERRM);
END;
/

-- ---------------------------------------------------------------------
-- Prueba 12: no se puede cancelar después de 5 minutos.
--            (se simula que el pedido se hizo hace 10 minutos)
-- ---------------------------------------------------------------------
DECLARE
    v_id  NUMBER;
    v_msg VARCHAR2(400);
BEGIN
    pkg_pedido.pr_crear_pedido(1, 1, 1, 1, '4:1', NULL, NULL, NULL, v_id, v_msg);

    UPDATE pedido SET fecha_pedido = SYSDATE - 10 / 1440 WHERE id_pedido = v_id;
    COMMIT;

    pkg_pedido.pr_cancelar_pedido(v_id, 1, 1, v_msg);
    DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 12: permitió cancelar después de 5 minutos');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20042 THEN
            DBMS_OUTPUT.PUT_LINE('OK     Prueba 12: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 12: ' || SQLERRM);
        END IF;
END;
/

-- ---------------------------------------------------------------------
-- Prueba 13: constraints (CHECK y FK) rechazan datos inválidos
-- ---------------------------------------------------------------------
DECLARE
    v_ok NUMBER := 0;
BEGIN
    BEGIN
        INSERT INTO producto (id_negocio, id_categoria, nombre, precio) VALUES (1, 1, 'Precio negativo', -5);
    EXCEPTION WHEN OTHERS THEN v_ok := v_ok + 1;   -- CH_PRODUCTO_PRECIO
    END;
    BEGIN
        INSERT INTO zona (id_municipio, nombre) VALUES (999, 'Zona inexistente');
    EXCEPTION WHEN OTHERS THEN v_ok := v_ok + 1;   -- FK_ZONA_MUNI
    END;
    BEGIN
        INSERT INTO horario_negocio (id_negocio, dia_semana, hora_apertura, hora_cierre) VALUES (2, 8, '08:00', '17:00');
    EXCEPTION WHEN OTHERS THEN v_ok := v_ok + 1;   -- CH_HORARIO_DIA
    END;
    ROLLBACK;
    IF v_ok = 3 THEN
        DBMS_OUTPUT.PUT_LINE('OK     Prueba 13: los constraints rechazaron los 3 datos inválidos');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 13: solo se rechazaron ' || v_ok || ' de 3');
    END IF;
END;
/

-- ---------------------------------------------------------------------
-- Prueba 14: la bitácora registra las operaciones
-- ---------------------------------------------------------------------
DECLARE
    v_eventos NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_eventos FROM bitacora
     WHERE tabla IN ('PEDIDO', 'USUARIO') AND fecha >= SYSDATE - 1/24;
    IF v_eventos > 0 THEN
        DBMS_OUTPUT.PUT_LINE('OK     Prueba 14: la bitácora tiene ' || v_eventos || ' eventos de la última hora');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 14');
    END IF;
END;
/

-- ---------------------------------------------------------------------
-- Prueba 15: optimización de ruta y tiempo estimado de llegada
--   ASIGNADO: la ruta es repartidor -> negocio -> cliente
-- ---------------------------------------------------------------------
DECLARE
    v_id_pedido NUMBER;
    v_ruta      NUMBER;
    v_esperado  NUMBER;
    v_minutos   NUMBER;
    v_deptos    NUMBER;
BEGIN
    SELECT MIN(id_pedido) INTO v_id_pedido FROM vw_pedido WHERE estado = 'ASIGNADO';

    SELECT fn_distancia_km(lat_repartidor, lon_repartidor, lat_negocio, lon_negocio)
         + fn_distancia_km(lat_negocio, lon_negocio, lat_entrega, lon_entrega),
           ruta_km, minutos_estimados
      INTO v_esperado, v_ruta, v_minutos
      FROM vw_pedido
     WHERE id_pedido = v_id_pedido;

    SELECT COUNT(*) INTO v_deptos FROM departamento;

    IF v_ruta = v_esperado AND v_minutos > 0 AND v_deptos = 22 THEN
        DBMS_OUTPUT.PUT_LINE('OK     Prueba 15: pedido ' || v_id_pedido || ', ruta repartidor-negocio-cliente = '
                             || v_ruta || ' km, llegada estimada ' || v_minutos || ' min; 22 departamentos');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 15: ruta ' || v_ruta || ' esperado ' || v_esperado
                             || ', minutos ' || v_minutos || ', departamentos ' || v_deptos);
    END IF;
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('FALLÓ  Prueba 15: ' || SQLERRM);
END;
/

-- Resumen de los reportes estadísticos con los datos de prueba
SELECT repartidor, SUM(entregas) AS entregas
  FROM vw_rep_entregas_area
 GROUP BY repartidor
 ORDER BY entregas DESC;

SELECT repartidor, cancelaciones, entregas, calificacion_promedio
  FROM vw_rep_cancelaciones_repartidor
 ORDER BY cancelaciones DESC;

SELECT zona, municipio, zona_roja, pedidos, entregados, cancelados, cancelaciones_repartidor
  FROM vw_rep_zonas
 WHERE pedidos > 0
 ORDER BY zona_roja DESC, pedidos DESC;

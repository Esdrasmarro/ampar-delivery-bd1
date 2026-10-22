-- =====================================================================
-- Proyecto Final Base de Datos 1 - Sistema de Control de Delivery "Ampar"
-- Script 07: paquetes (especificación y cuerpo)
-- Ejecutar conectado como: AMPAR
-- Estudiante: Esdras Lemuel Marroquín Rojas - Carné 3190-13-13335
-- =====================================================================
-- Un paquete agrupa funciones y procedimientos de un mismo módulo.
--   * La ESPECIFICACIÓN (PACKAGE) dice qué se puede usar desde afuera.
--   * El CUERPO (PACKAGE BODY) tiene el código.
--
-- TRANSACCIONES: cada procedimiento que modifica datos termina con COMMIT.
-- Si ocurre cualquier error, el bloque EXCEPTION hace ROLLBACK, así no queda
-- nada a medias (operación atómica). Los errores del negocio se lanzan con
-- RAISE_APPLICATION_ERROR(-20xxx, 'mensaje') y la aplicación muestra el mensaje.
--
-- Paquetes:
--   pkg_seguridad : inicio de sesión, permisos por menú, usuarios
--   pkg_negocio   : afiliación de negocios y horarios
--   pkg_despacho  : asignación de repartidores, estados de la entrega
--   pkg_pedido    : crear, pagar, cancelar y calificar pedidos

-- =====================================================================
-- ESPECIFICACIONES
-- =====================================================================

CREATE OR REPLACE PACKAGE pkg_seguridad AS
    -- Valida usuario y contraseña. Si son incorrectos lanza el error -20010.
    PROCEDURE pr_login (
        p_usuario       IN  VARCHAR2,
        p_clave         IN  VARCHAR2,
        p_id_usuario    OUT NUMBER,
        p_id_rol        OUT NUMBER,
        p_rol           OUT VARCHAR2,
        p_nombre        OUT VARCHAR2,
        p_id_cliente    OUT NUMBER,
        p_id_negocio    OUT NUMBER,
        p_id_repartidor OUT NUMBER
    );

    -- 'S' si el rol del usuario tiene asignada la opción de menú de esa URL.
    -- Así se controla el acceso entre módulos desde la base de datos.
    FUNCTION fn_tiene_permiso (
        p_id_usuario IN NUMBER,
        p_url        IN VARCHAR2
    ) RETURN VARCHAR2;

    PROCEDURE pr_crear_usuario (
        p_id_rol          IN  NUMBER,
        p_nombre_usuario  IN  VARCHAR2,
        p_clave           IN  VARCHAR2,
        p_nombre_completo IN  VARCHAR2,
        p_id_cliente      IN  NUMBER,
        p_id_negocio      IN  NUMBER,
        p_id_repartidor   IN  NUMBER,
        p_id_usuario      OUT NUMBER
    );

    PROCEDURE pr_modificar_usuario (
        p_id_usuario      IN NUMBER,
        p_id_rol          IN NUMBER,
        p_nombre_completo IN VARCHAR2,
        p_estado          IN VARCHAR2
    );

    PROCEDURE pr_cambiar_clave (
        p_id_usuario  IN NUMBER,
        p_clave_nueva IN VARCHAR2
    );

    -- Registro público de clientes: crea el cliente y su usuario (una sola transacción).
    PROCEDURE pr_registrar_cliente (
        p_nombres    IN  VARCHAR2,
        p_apellidos  IN  VARCHAR2,
        p_telefono   IN  VARCHAR2,
        p_correo     IN  VARCHAR2,
        p_clave      IN  VARCHAR2,
        p_id_cliente OUT NUMBER
    );
END pkg_seguridad;
/

CREATE OR REPLACE PACKAGE pkg_negocio AS
    -- Formulario público de afiliación: el negocio queda PENDIENTE.
    PROCEDURE pr_solicitar_afiliacion (
        p_id_tipo_negocio IN  NUMBER,
        p_id_zona         IN  NUMBER,
        p_nombre          IN  VARCHAR2,
        p_nit             IN  VARCHAR2,
        p_propietario     IN  VARCHAR2,
        p_telefono        IN  VARCHAR2,
        p_correo          IN  VARCHAR2,
        p_direccion       IN  VARCHAR2,
        p_latitud         IN  NUMBER,
        p_longitud        IN  NUMBER,
        p_id_negocio      OUT NUMBER
    );

    -- Aprueba la solicitud: activa el negocio, crea su usuario y un horario inicial.
    PROCEDURE pr_aprobar (
        p_id_negocio    IN NUMBER,
        p_clave_inicial IN VARCHAR2
    );

    PROCEDURE pr_rechazar (
        p_id_negocio IN NUMBER
    );

    -- Crea o modifica el horario de un día (1 = lunes ... 7 = domingo).
    PROCEDURE pr_guardar_horario (
        p_id_negocio   IN NUMBER,
        p_dia_semana   IN NUMBER,
        p_apertura     IN VARCHAR2,
        p_cierre       IN VARCHAR2,
        p_hace_entrega IN VARCHAR2
    );
END pkg_negocio;
/

CREATE OR REPLACE PACKAGE pkg_despacho AS
    -- Asigna el pedido al repartidor DISPONIBLE más cercano al negocio (Haversine),
    -- dentro del límite de km. Si no hay, el pedido queda pendiente (no es error).
    PROCEDURE pr_asignar_automatico (
        p_id_pedido     IN  NUMBER,
        p_id_repartidor OUT NUMBER,
        p_mensaje       OUT VARCHAR2
    );

    -- El operador asigna o reasigna manualmente.
    PROCEDURE pr_asignar_manual (
        p_id_pedido     IN NUMBER,
        p_id_repartidor IN NUMBER
    );

    -- El repartidor avanza el estado: RECOGIDO -> EN RUTA -> ENTREGADO.
    PROCEDURE pr_cambiar_estado (
        p_id_pedido     IN NUMBER,
        p_id_repartidor IN NUMBER,
        p_estado        IN VARCHAR2
    );

    -- El repartidor cancela la entrega: se registra y el pedido se reasigna.
    PROCEDURE pr_cancelar_entrega (
        p_id_pedido     IN  NUMBER,
        p_id_repartidor IN  NUMBER,
        p_id_motivo     IN  NUMBER,
        p_observacion   IN  VARCHAR2,
        p_mensaje       OUT VARCHAR2
    );
END pkg_despacho;
/

CREATE OR REPLACE PACKAGE pkg_pedido AS
    -- Crea el pedido completo en UNA transacción: encabezado, detalle, pago y estado.
    -- p_detalle trae los productos así: 'id_producto:cantidad,id_producto:cantidad'
    -- Ejemplo: '1:2,3:1' = 2 unidades del producto 1 y 1 unidad del producto 3.
    -- Para efectivo, los datos de la tarjeta van vacíos (NULL).
    PROCEDURE pr_crear_pedido (
        p_id_cliente     IN  NUMBER,
        p_id_negocio     IN  NUMBER,
        p_id_direccion   IN  NUMBER,
        p_id_metodo_pago IN  NUMBER,
        p_detalle        IN  VARCHAR2,
        p_num_tarjeta    IN  VARCHAR2,
        p_mes_vence      IN  NUMBER,
        p_anio_vence     IN  NUMBER,
        p_id_pedido      OUT NUMBER,
        p_mensaje        OUT VARCHAR2
    );

    -- Cancelación del cliente dentro de los primeros 5 minutos, cobrando el 15 %.
    PROCEDURE pr_cancelar_pedido (
        p_id_pedido  IN  NUMBER,
        p_id_cliente IN  NUMBER,
        p_id_motivo  IN  NUMBER,
        p_mensaje    OUT VARCHAR2
    );

    -- Calificación (1 a 5) y comentario del repartidor de un pedido entregado.
    PROCEDURE pr_calificar (
        p_id_pedido  IN NUMBER,
        p_id_cliente IN NUMBER,
        p_puntuacion IN NUMBER,
        p_comentario IN VARCHAR2
    );

    -- Minutos que han pasado desde que se hizo el pedido (para mostrar si se puede cancelar).
    FUNCTION fn_minutos_transcurridos (
        p_id_pedido IN NUMBER
    ) RETURN NUMBER;
END pkg_pedido;
/

-- =====================================================================
-- CUERPOS
-- =====================================================================

CREATE OR REPLACE PACKAGE BODY pkg_seguridad AS

    PROCEDURE pr_login (
        p_usuario       IN  VARCHAR2,
        p_clave         IN  VARCHAR2,
        p_id_usuario    OUT NUMBER,
        p_id_rol        OUT NUMBER,
        p_rol           OUT VARCHAR2,
        p_nombre        OUT VARCHAR2,
        p_id_cliente    OUT NUMBER,
        p_id_negocio    OUT NUMBER,
        p_id_repartidor OUT NUMBER
    ) IS
        v_clave_encriptada usuario.clave%TYPE;
    BEGIN
        v_clave_encriptada := fn_encriptar(p_clave);

        BEGIN
            SELECT u.id_usuario, u.id_rol, r.nombre, u.nombre_completo,
                   u.id_cliente, u.id_negocio, u.id_repartidor
              INTO p_id_usuario, p_id_rol, p_rol, p_nombre,
                   p_id_cliente, p_id_negocio, p_id_repartidor
              FROM usuario u
              JOIN rol r ON r.id_rol = u.id_rol
             WHERE u.nombre_usuario = LOWER(TRIM(p_usuario))
               AND u.clave          = v_clave_encriptada
               AND u.estado         = 'A'
               AND r.estado         = 'A';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- se registra el intento fallido y se confirma aunque falle el login
                pr_bitacora('USUARIO', 'LOGIN_FALLIDO', NULL, NULL,
                            'Intento fallido de inicio de sesión con el usuario: ' || p_usuario);
                COMMIT;
                RAISE_APPLICATION_ERROR(-20010, 'Usuario o contraseña incorrectos.');
        END;

        pr_bitacora('USUARIO', 'LOGIN', p_id_usuario, NULL, 'Inicio de sesión de ' || p_usuario);
        COMMIT;
    END pr_login;

    FUNCTION fn_tiene_permiso (
        p_id_usuario IN NUMBER,
        p_url        IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_cantidad NUMBER;
    BEGIN
        -- la URL pedida debe ser la de una opción del menú del rol, o una página
        -- dentro de esa opción (por ejemplo /catalogos/zonas/editar/3)
        SELECT COUNT(*)
          INTO v_cantidad
          FROM usuario u
          JOIN rol r       ON r.id_rol    = u.id_rol
          JOIN rol_menu rm ON rm.id_rol   = u.id_rol
          JOIN menu m      ON m.id_menu   = rm.id_menu
          JOIN modulo mo   ON mo.id_modulo = m.id_modulo
         WHERE u.id_usuario = p_id_usuario
           AND u.estado  = 'A'
           AND r.estado  = 'A'
           AND m.estado  = 'A'
           AND mo.estado = 'A'
           AND (p_url = m.url OR p_url LIKE m.url || '/%');

        IF v_cantidad > 0 THEN
            RETURN 'S';
        ELSE
            RETURN 'N';
        END IF;
    END fn_tiene_permiso;

    PROCEDURE pr_crear_usuario (
        p_id_rol          IN  NUMBER,
        p_nombre_usuario  IN  VARCHAR2,
        p_clave           IN  VARCHAR2,
        p_nombre_completo IN  VARCHAR2,
        p_id_cliente      IN  NUMBER,
        p_id_negocio      IN  NUMBER,
        p_id_repartidor   IN  NUMBER,
        p_id_usuario      OUT NUMBER
    ) IS
    BEGIN
        IF p_clave IS NULL OR LENGTH(p_clave) < 6 THEN
            RAISE_APPLICATION_ERROR(-20012, 'La contraseña debe tener al menos 6 caracteres.');
        END IF;

        INSERT INTO usuario (id_rol, nombre_usuario, clave, nombre_completo,
                             id_cliente, id_negocio, id_repartidor)
        VALUES (p_id_rol, LOWER(TRIM(p_nombre_usuario)), fn_encriptar(p_clave), p_nombre_completo,
                p_id_cliente, p_id_negocio, p_id_repartidor)
        RETURNING id_usuario INTO p_id_usuario;

        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20011, 'Ya existe ese nombre de usuario o la persona ya tiene usuario.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END pr_crear_usuario;

    PROCEDURE pr_modificar_usuario (
        p_id_usuario      IN NUMBER,
        p_id_rol          IN NUMBER,
        p_nombre_completo IN VARCHAR2,
        p_estado          IN VARCHAR2
    ) IS
    BEGIN
        UPDATE usuario
           SET id_rol          = p_id_rol,
               nombre_completo = p_nombre_completo,
               estado          = p_estado
         WHERE id_usuario = p_id_usuario;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20014, 'El usuario no existe.');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END pr_modificar_usuario;

    PROCEDURE pr_cambiar_clave (
        p_id_usuario  IN NUMBER,
        p_clave_nueva IN VARCHAR2
    ) IS
    BEGIN
        IF p_clave_nueva IS NULL OR LENGTH(p_clave_nueva) < 6 THEN
            RAISE_APPLICATION_ERROR(-20012, 'La contraseña debe tener al menos 6 caracteres.');
        END IF;

        UPDATE usuario
           SET clave = fn_encriptar(p_clave_nueva)
         WHERE id_usuario = p_id_usuario;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20014, 'El usuario no existe.');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END pr_cambiar_clave;

    PROCEDURE pr_registrar_cliente (
        p_nombres    IN  VARCHAR2,
        p_apellidos  IN  VARCHAR2,
        p_telefono   IN  VARCHAR2,
        p_correo     IN  VARCHAR2,
        p_clave      IN  VARCHAR2,
        p_id_cliente OUT NUMBER
    ) IS
        v_id_rol rol.id_rol%TYPE;
    BEGIN
        IF p_clave IS NULL OR LENGTH(p_clave) < 6 THEN
            RAISE_APPLICATION_ERROR(-20012, 'La contraseña debe tener al menos 6 caracteres.');
        END IF;

        SELECT id_rol INTO v_id_rol FROM rol WHERE nombre = 'CLIENTE';

        -- 1. el cliente
        INSERT INTO cliente (nombres, apellidos, telefono, correo)
        VALUES (p_nombres, p_apellidos, p_telefono, LOWER(TRIM(p_correo)))
        RETURNING id_cliente INTO p_id_cliente;

        -- 2. su usuario (el correo es el nombre de usuario)
        INSERT INTO usuario (id_rol, nombre_usuario, clave, nombre_completo, id_cliente)
        VALUES (v_id_rol, LOWER(TRIM(p_correo)), fn_encriptar(p_clave),
                p_nombres || ' ' || p_apellidos, p_id_cliente);

        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20013, 'Ya existe una cuenta con ese correo.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END pr_registrar_cliente;

END pkg_seguridad;
/

CREATE OR REPLACE PACKAGE BODY pkg_negocio AS

    PROCEDURE pr_solicitar_afiliacion (
        p_id_tipo_negocio IN  NUMBER,
        p_id_zona         IN  NUMBER,
        p_nombre          IN  VARCHAR2,
        p_nit             IN  VARCHAR2,
        p_propietario     IN  VARCHAR2,
        p_telefono        IN  VARCHAR2,
        p_correo          IN  VARCHAR2,
        p_direccion       IN  VARCHAR2,
        p_latitud         IN  NUMBER,
        p_longitud        IN  NUMBER,
        p_id_negocio      OUT NUMBER
    ) IS
    BEGIN
        INSERT INTO negocio (id_tipo_negocio, id_zona, nombre, nit, propietario, telefono,
                             correo, direccion, latitud, longitud, estado)
        VALUES (p_id_tipo_negocio, p_id_zona, p_nombre, UPPER(TRIM(p_nit)), p_propietario, p_telefono,
                LOWER(TRIM(p_correo)), p_direccion, p_latitud, p_longitud, 'PENDIENTE')
        RETURNING id_negocio INTO p_id_negocio;

        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20023, 'Ya existe un negocio registrado con ese NIT.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END pr_solicitar_afiliacion;

    PROCEDURE pr_aprobar (
        p_id_negocio    IN NUMBER,
        p_clave_inicial IN VARCHAR2
    ) IS
        v_estado negocio.estado%TYPE;
        v_correo negocio.correo%TYPE;
        v_nombre negocio.nombre%TYPE;
        v_id_rol rol.id_rol%TYPE;
    BEGIN
        IF p_clave_inicial IS NULL OR LENGTH(p_clave_inicial) < 6 THEN
            RAISE_APPLICATION_ERROR(-20012, 'La contraseña debe tener al menos 6 caracteres.');
        END IF;

        -- FOR UPDATE bloquea el registro mientras dura la transacción
        SELECT estado, correo, nombre
          INTO v_estado, v_correo, v_nombre
          FROM negocio
         WHERE id_negocio = p_id_negocio
           FOR UPDATE;

        IF v_estado <> 'PENDIENTE' THEN
            RAISE_APPLICATION_ERROR(-20020, 'Solo se pueden aprobar solicitudes pendientes.');
        END IF;

        SELECT id_rol INTO v_id_rol FROM rol WHERE nombre = 'NEGOCIO';

        -- 1. activar el negocio
        UPDATE negocio SET estado = 'ACTIVO' WHERE id_negocio = p_id_negocio;

        -- 2. crear su usuario (el correo del negocio es el nombre de usuario)
        INSERT INTO usuario (id_rol, nombre_usuario, clave, nombre_completo, id_negocio)
        VALUES (v_id_rol, v_correo, fn_encriptar(p_clave_inicial), v_nombre, p_id_negocio);

        -- 3. horario inicial: lunes a sábado de 08:00 a 18:00 (el negocio lo puede cambiar)
        FOR v_dia IN 1 .. 7 LOOP
            INSERT INTO horario_negocio (id_negocio, dia_semana, hora_apertura, hora_cierre, hace_entrega)
            SELECT p_id_negocio, v_dia, '08:00', '18:00', CASE WHEN v_dia = 7 THEN 'N' ELSE 'S' END
              FROM dual
             WHERE NOT EXISTS (SELECT 1 FROM horario_negocio
                                WHERE id_negocio = p_id_negocio AND dia_semana = v_dia);
        END LOOP;

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20024, 'El negocio no existe.');
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20021, 'Ya existe un usuario con el correo de este negocio.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END pr_aprobar;

    PROCEDURE pr_rechazar (
        p_id_negocio IN NUMBER
    ) IS
    BEGIN
        UPDATE negocio
           SET estado = 'RECHAZADO'
         WHERE id_negocio = p_id_negocio
           AND estado     = 'PENDIENTE';

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20020, 'Solo se pueden rechazar solicitudes pendientes.');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END pr_rechazar;

    PROCEDURE pr_guardar_horario (
        p_id_negocio   IN NUMBER,
        p_dia_semana   IN NUMBER,
        p_apertura     IN VARCHAR2,
        p_cierre       IN VARCHAR2,
        p_hace_entrega IN VARCHAR2
    ) IS
    BEGIN
        IF NOT REGEXP_LIKE(p_apertura, '^([01][0-9]|2[0-3]):[0-5][0-9]$')
           OR NOT REGEXP_LIKE(p_cierre, '^([01][0-9]|2[0-3]):[0-5][0-9]$') THEN
            RAISE_APPLICATION_ERROR(-20022, 'Las horas deben tener el formato HH:MM (24 horas).');
        END IF;

        -- MERGE: si ya existe el horario de ese día lo modifica; si no, lo inserta
        MERGE INTO horario_negocio h
        USING (SELECT p_id_negocio AS id_negocio, p_dia_semana AS dia_semana FROM dual) s
           ON (h.id_negocio = s.id_negocio AND h.dia_semana = s.dia_semana)
        WHEN MATCHED THEN
            UPDATE SET h.hora_apertura = p_apertura,
                       h.hora_cierre   = p_cierre,
                       h.hace_entrega  = p_hace_entrega
        WHEN NOT MATCHED THEN
            INSERT (id_negocio, dia_semana, hora_apertura, hora_cierre, hace_entrega)
            VALUES (p_id_negocio, p_dia_semana, p_apertura, p_cierre, p_hace_entrega);

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END pr_guardar_horario;

END pkg_negocio;
/

CREATE OR REPLACE PACKAGE BODY pkg_despacho AS

    -- Procedimiento privado (solo se usa dentro del paquete):
    -- deja el pedido ASIGNADO al repartidor y lo marca como no disponible.
    PROCEDURE pr_marcar_asignado (
        p_id_pedido     IN NUMBER,
        p_id_repartidor IN NUMBER
    ) IS
    BEGIN
        UPDATE repartidor
           SET disponible = 'N'
         WHERE id_repartidor = p_id_repartidor;

        -- al cambiar el estado se dispara TRG_PEDIDO_SEGUIMIENTO (historial y notificaciones)
        UPDATE pedido
           SET id_repartidor    = p_id_repartidor,
               id_estado_pedido = fn_id_estado('ASIGNADO')
         WHERE id_pedido = p_id_pedido;
    END pr_marcar_asignado;

    PROCEDURE pr_asignar_automatico (
        p_id_pedido     IN  NUMBER,
        p_id_repartidor OUT NUMBER,
        p_mensaje       OUT VARCHAR2
    ) IS
        v_estado    pedido.id_estado_pedido%TYPE;
        v_latitud   negocio.latitud%TYPE;
        v_longitud  negocio.longitud%TYPE;
        v_km_limite NUMBER;
        v_distancia NUMBER;
        v_nombre    VARCHAR2(130);
    BEGIN
        SELECT p.id_estado_pedido, n.latitud, n.longitud
          INTO v_estado, v_latitud, v_longitud
          FROM pedido p
          JOIN negocio n ON n.id_negocio = p.id_negocio
         WHERE p.id_pedido = p_id_pedido
           FOR UPDATE OF p.id_estado_pedido;

        IF v_estado <> fn_id_estado('CONFIRMADO') THEN
            RAISE_APPLICATION_ERROR(-20050, 'El pedido no está pendiente de asignación.');
        END IF;

        v_km_limite := fn_parametro('KM_LIMITE');

        -- repartidor activo, disponible, con ubicación, que no haya cancelado este
        -- mismo pedido, ordenados del más cercano al más lejano
        BEGIN
            SELECT id_repartidor, distancia
              INTO p_id_repartidor, v_distancia
              FROM (SELECT r.id_repartidor,
                           fn_distancia_km(v_latitud, v_longitud, r.latitud, r.longitud) AS distancia
                      FROM repartidor r
                     WHERE r.estado     = 'A'
                       AND r.disponible = 'S'
                       AND r.latitud IS NOT NULL
                       AND NOT EXISTS (SELECT 1
                                         FROM cancelacion_entrega c
                                        WHERE c.id_pedido     = p_id_pedido
                                          AND c.id_repartidor = r.id_repartidor)
                     ORDER BY distancia)
             WHERE distancia <= v_km_limite
               AND ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                ROLLBACK;  -- libera el bloqueo; no se cambió nada
                p_id_repartidor := NULL;
                p_mensaje := 'No hay repartidores disponibles a menos de ' || v_km_limite
                          || ' km. El pedido queda pendiente de asignación.';
                RETURN;
        END;

        pr_marcar_asignado(p_id_pedido, p_id_repartidor);

        SELECT nombres || ' ' || apellidos INTO v_nombre
          FROM repartidor WHERE id_repartidor = p_id_repartidor;

        p_mensaje := 'Asignado al repartidor ' || v_nombre || ', a ' || v_distancia || ' km del negocio.';
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END pr_asignar_automatico;

    PROCEDURE pr_asignar_manual (
        p_id_pedido     IN NUMBER,
        p_id_repartidor IN NUMBER
    ) IS
        v_estado     pedido.id_estado_pedido%TYPE;
        v_disponible repartidor.disponible%TYPE;
        v_activo     repartidor.estado%TYPE;
    BEGIN
        SELECT id_estado_pedido INTO v_estado
          FROM pedido WHERE id_pedido = p_id_pedido
           FOR UPDATE;

        IF v_estado <> fn_id_estado('CONFIRMADO') THEN
            RAISE_APPLICATION_ERROR(-20050, 'El pedido no está pendiente de asignación.');
        END IF;

        SELECT disponible, estado INTO v_disponible, v_activo
          FROM repartidor WHERE id_repartidor = p_id_repartidor
           FOR UPDATE;

        IF v_disponible <> 'S' OR v_activo <> 'A' THEN
            RAISE_APPLICATION_ERROR(-20051, 'El repartidor no está disponible.');
        END IF;

        pr_marcar_asignado(p_id_pedido, p_id_repartidor);
        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20054, 'El pedido o el repartidor no existe.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END pr_asignar_manual;

    PROCEDURE pr_cambiar_estado (
        p_id_pedido     IN NUMBER,
        p_id_repartidor IN NUMBER,
        p_estado        IN VARCHAR2
    ) IS
        v_repartidor   pedido.id_repartidor%TYPE;
        v_orden_actual estado_pedido.orden%TYPE;
        v_estado_pago  pedido.estado_pago%TYPE;
        v_total        pedido.total%TYPE;
        v_pasarela     metodo_pago.usa_pasarela%TYPE;
        v_id_nuevo     estado_pedido.id_estado_pedido%TYPE;
        v_orden_nuevo  estado_pedido.orden%TYPE;
    BEGIN
        SELECT p.id_repartidor, e.orden, p.estado_pago, p.total, m.usa_pasarela
          INTO v_repartidor, v_orden_actual, v_estado_pago, v_total, v_pasarela
          FROM pedido p
          JOIN estado_pedido e ON e.id_estado_pedido = p.id_estado_pedido
          JOIN metodo_pago m   ON m.id_metodo_pago   = p.id_metodo_pago
         WHERE p.id_pedido = p_id_pedido
           FOR UPDATE OF p.id_estado_pedido;

        IF v_repartidor IS NULL OR v_repartidor <> p_id_repartidor THEN
            RAISE_APPLICATION_ERROR(-20052, 'El pedido no está asignado a este repartidor.');
        END IF;

        IF UPPER(p_estado) NOT IN ('RECOGIDO', 'EN RUTA', 'ENTREGADO') THEN
            RAISE_APPLICATION_ERROR(-20053, 'Estado no permitido para el repartidor.');
        END IF;

        SELECT id_estado_pedido, orden INTO v_id_nuevo, v_orden_nuevo
          FROM estado_pedido WHERE nombre = UPPER(p_estado);

        -- solo se puede avanzar al estado siguiente (no se puede saltar estados)
        IF v_orden_nuevo <> v_orden_actual + 1 THEN
            RAISE_APPLICATION_ERROR(-20053, 'No se puede pasar a ' || UPPER(p_estado)
                                        || ' desde el estado actual del pedido.');
        END IF;

        UPDATE pedido SET id_estado_pedido = v_id_nuevo WHERE id_pedido = p_id_pedido;

        IF UPPER(p_estado) = 'ENTREGADO' THEN
            -- el repartidor queda libre para otro pedido
            UPDATE repartidor SET disponible = 'S' WHERE id_repartidor = p_id_repartidor;

            -- pago en efectivo: se registra el cobro al entregar
            IF v_pasarela = 'N' AND v_estado_pago = 'PENDIENTE' THEN
                INSERT INTO pago (id_pedido, tipo, monto) VALUES (p_id_pedido, 'PAGO', v_total);
                UPDATE pedido SET estado_pago = 'PAGADO' WHERE id_pedido = p_id_pedido;
            END IF;
        END IF;

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20054, 'El pedido no existe.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END pr_cambiar_estado;

    PROCEDURE pr_cancelar_entrega (
        p_id_pedido     IN  NUMBER,
        p_id_repartidor IN  NUMBER,
        p_id_motivo     IN  NUMBER,
        p_observacion   IN  VARCHAR2,
        p_mensaje       OUT VARCHAR2
    ) IS
        v_repartidor pedido.id_repartidor%TYPE;
        v_estado     estado_pedido.nombre%TYPE;
        v_nuevo      NUMBER;
        v_msg        VARCHAR2(300);
    BEGIN
        SELECT p.id_repartidor, e.nombre
          INTO v_repartidor, v_estado
          FROM pedido p
          JOIN estado_pedido e ON e.id_estado_pedido = p.id_estado_pedido
         WHERE p.id_pedido = p_id_pedido
           FOR UPDATE OF p.id_estado_pedido;

        IF v_repartidor IS NULL OR v_repartidor <> p_id_repartidor THEN
            RAISE_APPLICATION_ERROR(-20052, 'El pedido no está asignado a este repartidor.');
        END IF;

        IF v_estado NOT IN ('ASIGNADO', 'RECOGIDO', 'EN RUTA') THEN
            RAISE_APPLICATION_ERROR(-20055, 'La entrega ya no se puede cancelar.');
        END IF;

        -- 1. se registra la cancelación (control de conductores que cancelan)
        INSERT INTO cancelacion_entrega (id_pedido, id_repartidor, id_motivo, observacion)
        VALUES (p_id_pedido, p_id_repartidor, p_id_motivo, p_observacion);

        -- 2. el pedido vuelve a CONFIRMADO, sin repartidor
        UPDATE pedido
           SET id_repartidor    = NULL,
               id_estado_pedido = fn_id_estado('CONFIRMADO')
         WHERE id_pedido = p_id_pedido;

        -- 3. el repartidor queda libre
        UPDATE repartidor SET disponible = 'S' WHERE id_repartidor = p_id_repartidor;

        COMMIT;

        -- 4. se busca otro repartidor (el que canceló queda excluido)
        BEGIN
            pr_asignar_automatico(p_id_pedido, v_nuevo, v_msg);
        EXCEPTION
            WHEN OTHERS THEN
                v_msg := 'El pedido queda pendiente de asignación.';
        END;

        p_mensaje := 'Entrega cancelada. ' || v_msg;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20054, 'El pedido no existe.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END pr_cancelar_entrega;

END pkg_despacho;
/

CREATE OR REPLACE PACKAGE BODY pkg_pedido AS

    PROCEDURE pr_crear_pedido (
        p_id_cliente     IN  NUMBER,
        p_id_negocio     IN  NUMBER,
        p_id_direccion   IN  NUMBER,
        p_id_metodo_pago IN  NUMBER,
        p_detalle        IN  VARCHAR2,
        p_num_tarjeta    IN  VARCHAR2,
        p_mes_vence      IN  NUMBER,
        p_anio_vence     IN  NUMBER,
        p_id_pedido      OUT NUMBER,
        p_mensaje        OUT VARCHAR2
    ) IS
        v_lat_negocio   negocio.latitud%TYPE;
        v_lon_negocio   negocio.longitud%TYPE;
        v_radio         negocio.radio_cobertura_km%TYPE;
        v_estado_neg    negocio.estado%TYPE;
        v_lat_dir       direccion_cliente.latitud%TYPE;
        v_lon_dir       direccion_cliente.longitud%TYPE;
        v_cliente_dir   direccion_cliente.id_cliente%TYPE;
        v_pasarela      metodo_pago.usa_pasarela%TYPE;
        v_distancia     NUMBER;
        v_km_limite     NUMBER;
        v_subtotal      NUMBER := 0;
        v_envio         NUMBER;
        v_cargo         NUMBER;
        v_total         NUMBER;
        v_item          VARCHAR2(50);
        v_i             NUMBER;
        v_linea         NUMBER := 0;
        v_id_producto   producto.id_producto%TYPE;
        v_cantidad      NUMBER;
        v_precio        producto.precio%TYPE;
        v_disponible    producto.disponible%TYPE;
        v_estado_prod   producto.estado%TYPE;
        v_negocio_prod  producto.id_negocio%TYPE;
        v_resultado     VARCHAR2(10);
        v_id_repartidor NUMBER;
        v_msg_asigna    VARCHAR2(300);
    BEGIN
        -- 1. el negocio debe estar activo y abierto (horario y día de entrega)
        SELECT latitud, longitud, radio_cobertura_km, estado
          INTO v_lat_negocio, v_lon_negocio, v_radio, v_estado_neg
          FROM negocio
         WHERE id_negocio = p_id_negocio;

        IF v_estado_neg <> 'ACTIVO' THEN
            RAISE_APPLICATION_ERROR(-20030, 'El negocio no está activo.');
        END IF;

        IF fn_negocio_abierto(p_id_negocio) = 'N' THEN
            RAISE_APPLICATION_ERROR(-20031, 'El negocio está cerrado o no hace entregas en este horario.');
        END IF;

        -- 2. la dirección debe ser del cliente y estar dentro de la cobertura
        SELECT latitud, longitud, id_cliente
          INTO v_lat_dir, v_lon_dir, v_cliente_dir
          FROM direccion_cliente
         WHERE id_direccion = p_id_direccion
           AND estado = 'A';

        IF v_cliente_dir <> p_id_cliente THEN
            RAISE_APPLICATION_ERROR(-20032, 'La dirección no pertenece al cliente.');
        END IF;

        v_distancia := fn_distancia_km(v_lat_negocio, v_lon_negocio, v_lat_dir, v_lon_dir);
        v_km_limite := LEAST(v_radio, fn_parametro('KM_LIMITE'));

        IF v_distancia > v_km_limite THEN
            RAISE_APPLICATION_ERROR(-20033, 'La dirección está a ' || v_distancia
                || ' km del negocio y el límite de entrega es de ' || v_km_limite || ' km.');
        END IF;

        -- 3. método de pago
        SELECT usa_pasarela INTO v_pasarela
          FROM metodo_pago
         WHERE id_metodo_pago = p_id_metodo_pago
           AND estado = 'A';

        -- 4. recorrer los productos para validar y calcular el subtotal
        IF p_detalle IS NULL THEN
            RAISE_APPLICATION_ERROR(-20034, 'El pedido debe tener al menos un producto.');
        END IF;

        v_i := 1;
        LOOP
            v_item := REGEXP_SUBSTR(p_detalle, '[^,]+', 1, v_i);   -- '5:2'
            EXIT WHEN v_item IS NULL;

            v_id_producto := TO_NUMBER(SUBSTR(v_item, 1, INSTR(v_item, ':') - 1));
            v_cantidad    := TO_NUMBER(SUBSTR(v_item, INSTR(v_item, ':') + 1));

            SELECT precio, disponible, estado, id_negocio
              INTO v_precio, v_disponible, v_estado_prod, v_negocio_prod
              FROM producto
             WHERE id_producto = v_id_producto;

            IF v_negocio_prod <> p_id_negocio OR v_disponible <> 'S' OR v_estado_prod <> 'A' THEN
                RAISE_APPLICATION_ERROR(-20035, 'El producto ' || v_id_producto
                                            || ' no está disponible en este negocio.');
            END IF;

            IF v_cantidad IS NULL OR v_cantidad <= 0 THEN
                RAISE_APPLICATION_ERROR(-20036, 'La cantidad de cada producto debe ser mayor que cero.');
            END IF;

            v_subtotal := v_subtotal + v_cantidad * v_precio;
            v_i := v_i + 1;
        END LOOP;

        -- 5. totales: subtotal + envío (tarifa única) + cargo pendiente por cancelación
        v_envio := fn_parametro('TARIFA_ENVIO');
        v_cargo := fn_cargo_pendiente(p_id_cliente);
        v_total := v_subtotal + v_envio + v_cargo;

        -- 6. encabezado del pedido (los triggers marcan zona roja, historial y notificaciones)
        INSERT INTO pedido (id_cliente, id_negocio, id_direccion, id_metodo_pago, id_estado_pedido,
                            subtotal, costo_envio, cargo_anterior, total, distancia_km, estado_pago)
        VALUES (p_id_cliente, p_id_negocio, p_id_direccion, p_id_metodo_pago, fn_id_estado('CONFIRMADO'),
                v_subtotal, v_envio, v_cargo, v_total, v_distancia, 'PENDIENTE')
        RETURNING id_pedido INTO p_id_pedido;

        -- 7. detalle del pedido (una línea por producto)
        v_i := 1;
        LOOP
            v_item := REGEXP_SUBSTR(p_detalle, '[^,]+', 1, v_i);
            EXIT WHEN v_item IS NULL;

            v_id_producto := TO_NUMBER(SUBSTR(v_item, 1, INSTR(v_item, ':') - 1));
            v_cantidad    := TO_NUMBER(SUBSTR(v_item, INSTR(v_item, ':') + 1));

            SELECT precio INTO v_precio FROM producto WHERE id_producto = v_id_producto;

            v_linea := v_linea + 1;
            INSERT INTO detalle_pedido (id_pedido, linea, id_producto, cantidad, precio_unitario, subtotal)
            VALUES (p_id_pedido, v_linea, v_id_producto, v_cantidad, v_precio, v_cantidad * v_precio);

            v_i := v_i + 1;
        END LOOP;

        -- 8. si se cobró un cargo pendiente, queda marcado como APLICADO en este pedido
        IF v_cargo > 0 THEN
            UPDATE cancelacion_pedido
               SET estado_cargo       = 'APLICADO',
                   id_pedido_aplicado = p_id_pedido
             WHERE estado_cargo = 'PENDIENTE'
               AND id_pedido IN (SELECT id_pedido FROM pedido WHERE id_cliente = p_id_cliente);
        END IF;

        -- 9. pago con tarjeta en línea por la pasarela simulada.
        --    Si se rechaza, el error lleva al EXCEPTION y el ROLLBACK deshace
        --    el encabezado y el detalle: no queda nada guardado (operación atómica).
        IF v_pasarela = 'S' THEN
            v_resultado := fn_validar_tarjeta(p_num_tarjeta, p_mes_vence, p_anio_vence);

            IF v_resultado = 'RECHAZADA' THEN
                RAISE_APPLICATION_ERROR(-20037, 'La pasarela rechazó la tarjeta. El pedido no se guardó.');
            END IF;

            INSERT INTO pago (id_pedido, tipo, monto, ultimos4, autorizacion)
            VALUES (p_id_pedido, 'PAGO', v_total,
                    SUBSTR(REPLACE(REPLACE(p_num_tarjeta, ' ', ''), '-', ''), -4),
                    'AUT-' || TO_CHAR(SYSDATE, 'YYMMDDHH24MISS'));

            UPDATE pedido SET estado_pago = 'PAGADO' WHERE id_pedido = p_id_pedido;

            p_mensaje := 'Pedido No. ' || p_id_pedido || ' confirmado y pagado con tarjeta (Q'
                      || TO_CHAR(v_total, 'FM999990.00') || ').';
        ELSE
            p_mensaje := 'Pedido No. ' || p_id_pedido || ' confirmado. Pagará Q'
                      || TO_CHAR(v_total, 'FM999990.00') || ' en efectivo al recibir.';
        END IF;

        COMMIT;   -- fin de la transacción del pedido

        -- 10. asignación automática del repartidor más cercano (transacción aparte)
        BEGIN
            pkg_despacho.pr_asignar_automatico(p_id_pedido, v_id_repartidor, v_msg_asigna);
        EXCEPTION
            WHEN OTHERS THEN
                v_msg_asigna := 'El pedido queda pendiente de asignación.';
        END;

        p_mensaje := p_mensaje || ' ' || v_msg_asigna;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            p_id_pedido := NULL;
            RAISE_APPLICATION_ERROR(-20038, 'Datos del pedido no válidos: el negocio, la dirección, '
                                        || 'el método de pago o algún producto no existe.');
        WHEN OTHERS THEN
            ROLLBACK;
            p_id_pedido := NULL;
            RAISE;
    END pr_crear_pedido;

    PROCEDURE pr_cancelar_pedido (
        p_id_pedido  IN  NUMBER,
        p_id_cliente IN  NUMBER,
        p_id_motivo  IN  NUMBER,
        p_mensaje    OUT VARCHAR2
    ) IS
        v_cliente      pedido.id_cliente%TYPE;
        v_estado       estado_pedido.nombre%TYPE;
        v_repartidor   pedido.id_repartidor%TYPE;
        v_fecha        pedido.fecha_pedido%TYPE;
        v_total        pedido.total%TYPE;
        v_pasarela     metodo_pago.usa_pasarela%TYPE;
        v_minutos      NUMBER;
        v_limite       NUMBER;
        v_porcentaje   NUMBER;
        v_cobro        NUMBER;
        v_reembolso    NUMBER;
        v_estado_cargo cancelacion_pedido.estado_cargo%TYPE;
    BEGIN
        SELECT p.id_cliente, e.nombre, p.id_repartidor, p.fecha_pedido, p.total, m.usa_pasarela
          INTO v_cliente, v_estado, v_repartidor, v_fecha, v_total, v_pasarela
          FROM pedido p
          JOIN estado_pedido e ON e.id_estado_pedido = p.id_estado_pedido
          JOIN metodo_pago m   ON m.id_metodo_pago   = p.id_metodo_pago
         WHERE p.id_pedido = p_id_pedido
           FOR UPDATE OF p.id_estado_pedido;

        IF v_cliente <> p_id_cliente THEN
            RAISE_APPLICATION_ERROR(-20040, 'El pedido no pertenece al cliente.');
        END IF;

        IF v_estado NOT IN ('CONFIRMADO', 'ASIGNADO') THEN
            RAISE_APPLICATION_ERROR(-20041, 'El pedido ya no se puede cancelar porque está ' || v_estado || '.');
        END IF;

        -- regla de los 5 minutos (SYSDATE - fecha da días; * 24 * 60 = minutos)
        v_minutos := (SYSDATE - v_fecha) * 24 * 60;
        v_limite  := fn_parametro('MIN_CANCELACION');

        IF v_minutos > v_limite THEN
            RAISE_APPLICATION_ERROR(-20042, 'Solo se puede cancelar dentro de los primeros ' || v_limite
                || ' minutos. Ya pasaron ' || TRUNC(v_minutos) || ' minutos.');
        END IF;

        -- cobro por cancelación: porcentaje del total (15 %)
        v_porcentaje := fn_parametro('PORC_CANCELACION');
        v_cobro      := ROUND(v_total * v_porcentaje / 100, 2);

        IF v_pasarela = 'S' THEN
            -- tarjeta: se cobra el 15 % y se reembolsa el resto
            v_reembolso    := v_total - v_cobro;
            v_estado_cargo := 'COBRADO';
            IF v_reembolso > 0 THEN
                INSERT INTO pago (id_pedido, tipo, monto)
                VALUES (p_id_pedido, 'REEMBOLSO', v_reembolso);
            END IF;
        ELSE
            -- efectivo: el 15 % queda pendiente y se suma al siguiente pedido
            v_reembolso    := 0;
            v_estado_cargo := 'PENDIENTE';
            UPDATE pedido SET estado_pago = 'ANULADO' WHERE id_pedido = p_id_pedido;
        END IF;

        INSERT INTO cancelacion_pedido (id_pedido, id_motivo, porcentaje, monto_cobro, monto_reembolso, estado_cargo)
        VALUES (p_id_pedido, p_id_motivo, v_porcentaje, v_cobro, v_reembolso, v_estado_cargo);

        UPDATE pedido
           SET id_estado_pedido = fn_id_estado('CANCELADO')
         WHERE id_pedido = p_id_pedido;

        IF v_repartidor IS NOT NULL THEN
            UPDATE repartidor SET disponible = 'S' WHERE id_repartidor = v_repartidor;
        END IF;

        IF v_pasarela = 'S' THEN
            p_mensaje := 'Pedido cancelado. Cargo por cancelación (' || v_porcentaje || ' %): Q'
                      || TO_CHAR(v_cobro, 'FM999990.00') || '. Reembolso a su tarjeta: Q'
                      || TO_CHAR(v_reembolso, 'FM999990.00') || '.';
        ELSE
            p_mensaje := 'Pedido cancelado. El cargo por cancelación (' || v_porcentaje || ' %) de Q'
                      || TO_CHAR(v_cobro, 'FM999990.00') || ' se sumará a su siguiente pedido.';
        END IF;

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20054, 'El pedido no existe.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END pr_cancelar_pedido;

    PROCEDURE pr_calificar (
        p_id_pedido  IN NUMBER,
        p_id_cliente IN NUMBER,
        p_puntuacion IN NUMBER,
        p_comentario IN VARCHAR2
    ) IS
        v_cliente pedido.id_cliente%TYPE;
        v_estado  estado_pedido.nombre%TYPE;
    BEGIN
        SELECT p.id_cliente, e.nombre
          INTO v_cliente, v_estado
          FROM pedido p
          JOIN estado_pedido e ON e.id_estado_pedido = p.id_estado_pedido
         WHERE p.id_pedido = p_id_pedido;

        IF v_cliente <> p_id_cliente THEN
            RAISE_APPLICATION_ERROR(-20040, 'El pedido no pertenece al cliente.');
        END IF;

        IF v_estado <> 'ENTREGADO' THEN
            RAISE_APPLICATION_ERROR(-20043, 'Solo se pueden calificar pedidos entregados.');
        END IF;

        IF p_puntuacion IS NULL OR p_puntuacion NOT BETWEEN 1 AND 5 THEN
            RAISE_APPLICATION_ERROR(-20044, 'La calificación debe ser de 1 a 5 estrellas.');
        END IF;

        INSERT INTO calificacion (id_pedido, puntuacion, comentario)
        VALUES (p_id_pedido, p_puntuacion, p_comentario);

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20054, 'El pedido no existe.');
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20045, 'Este pedido ya fue calificado.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END pr_calificar;

    FUNCTION fn_minutos_transcurridos (
        p_id_pedido IN NUMBER
    ) RETURN NUMBER IS
        v_minutos NUMBER;
    BEGIN
        SELECT ROUND((SYSDATE - fecha_pedido) * 24 * 60, 1)
          INTO v_minutos
          FROM pedido
         WHERE id_pedido = p_id_pedido;

        RETURN v_minutos;
    END fn_minutos_transcurridos;

END pkg_pedido;
/

-- =====================================================================
-- Proyecto Final Base de Datos 1 - Sistema de Control de Delivery "Ampar"
-- Script 03: funciones
-- Ejecutar conectado como: AMPAR
-- Estudiante: Esdras Lemuel Marroquín Rojas - Carné 3190-13-13335
-- =====================================================================
-- Una función recibe parámetros, hace un cálculo o una consulta y DEVUELVE un valor.
-- Se pueden usar dentro de un SELECT, de un procedimiento o de un paquete.

-- ---------------------------------------------------------------------
-- fn_parametro: devuelve el valor de un parámetro del sistema
-- Ejemplo: fn_parametro('TARIFA_ENVIO') -> 25
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_parametro (
    p_codigo IN VARCHAR2
) RETURN NUMBER
IS
    v_valor parametro.valor%TYPE;
BEGIN
    SELECT valor
      INTO v_valor
      FROM parametro
     WHERE codigo = p_codigo;

    RETURN v_valor;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20100, 'No existe el parámetro ' || p_codigo);
END fn_parametro;
/

-- ---------------------------------------------------------------------
-- fn_distancia_km: distancia en kilómetros entre dos puntos (latitud, longitud)
-- usando la fórmula de Haversine (radio de la Tierra = 6371 km).
-- Se usa para elegir al repartidor más cercano y validar la cobertura.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_distancia_km (
    p_lat1 IN NUMBER,
    p_lon1 IN NUMBER,
    p_lat2 IN NUMBER,
    p_lon2 IN NUMBER
) RETURN NUMBER
IS
    c_radio CONSTANT NUMBER := 6371;
    c_pi    CONSTANT NUMBER := ACOS(-1);
    v_dlat  NUMBER;
    v_dlon  NUMBER;
    v_a     NUMBER;
BEGIN
    IF p_lat1 IS NULL OR p_lon1 IS NULL OR p_lat2 IS NULL OR p_lon2 IS NULL THEN
        RETURN NULL;
    END IF;

    -- diferencias en radianes
    v_dlat := (p_lat2 - p_lat1) * c_pi / 180;
    v_dlon := (p_lon2 - p_lon1) * c_pi / 180;

    v_a := POWER(SIN(v_dlat / 2), 2)
         + COS(p_lat1 * c_pi / 180) * COS(p_lat2 * c_pi / 180) * POWER(SIN(v_dlon / 2), 2);

    RETURN ROUND(c_radio * 2 * ASIN(LEAST(1, SQRT(v_a))), 2);
END fn_distancia_km;
/

-- ---------------------------------------------------------------------
-- fn_encriptar: encripta una contraseña con el algoritmo SHA-256.
-- Devuelve 64 caracteres hexadecimales. La contraseña nunca se guarda en texto plano.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_encriptar (
    p_clave IN VARCHAR2
) RETURN VARCHAR2
IS
    v_hash VARCHAR2(64);
BEGIN
    SELECT RAWTOHEX(STANDARD_HASH(p_clave, 'SHA256'))
      INTO v_hash
      FROM dual;

    RETURN v_hash;
END fn_encriptar;
/

-- ---------------------------------------------------------------------
-- fn_dia_semana: número del día de la semana (1 = lunes ... 7 = domingo)
-- No depende de la configuración regional de Oracle.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_dia_semana (
    p_fecha IN DATE
) RETURN NUMBER
IS
BEGIN
    -- TRUNC(fecha, 'IW') devuelve el lunes de esa semana
    RETURN TRUNC(p_fecha) - TRUNC(p_fecha, 'IW') + 1;
END fn_dia_semana;
/

-- ---------------------------------------------------------------------
-- fn_negocio_abierto: 'S' si el negocio está ACTIVO, atiende a esa hora
-- y ese día hace entregas; 'N' en caso contrario.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_negocio_abierto (
    p_id_negocio IN NUMBER,
    p_fecha      IN DATE DEFAULT SYSDATE
) RETURN VARCHAR2
IS
    v_hora     VARCHAR2(5) := TO_CHAR(p_fecha, 'HH24:MI');
    v_cantidad NUMBER;
BEGIN
    SELECT COUNT(*)
      INTO v_cantidad
      FROM negocio n
      JOIN horario_negocio h ON h.id_negocio = n.id_negocio
     WHERE n.id_negocio   = p_id_negocio
       AND n.estado       = 'ACTIVO'
       AND h.dia_semana   = fn_dia_semana(p_fecha)
       AND h.hace_entrega = 'S'
       AND v_hora >= h.hora_apertura
       AND v_hora <  h.hora_cierre;

    IF v_cantidad > 0 THEN
        RETURN 'S';
    ELSE
        RETURN 'N';
    END IF;
END fn_negocio_abierto;
/

-- ---------------------------------------------------------------------
-- fn_id_estado: devuelve el id de un estado de pedido a partir de su nombre
-- Ejemplo: fn_id_estado('ENTREGADO') -> 5
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_id_estado (
    p_nombre IN VARCHAR2
) RETURN NUMBER
IS
    v_id estado_pedido.id_estado_pedido%TYPE;
BEGIN
    SELECT id_estado_pedido
      INTO v_id
      FROM estado_pedido
     WHERE nombre = UPPER(p_nombre);

    RETURN v_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20101, 'No existe el estado de pedido ' || p_nombre);
END fn_id_estado;
/

-- ---------------------------------------------------------------------
-- fn_validar_tarjeta: pasarela de pagos SIMULADA.
-- Reglas: 16 dígitos y fecha de vencimiento vigente = APROBADA.
--         La tarjeta de prueba 4000 0000 0000 0002 siempre es RECHAZADA
--         (fondos insuficientes). La 4111 1111 1111 1111 se aprueba.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_validar_tarjeta (
    p_numero IN VARCHAR2,
    p_mes    IN NUMBER,
    p_anio   IN NUMBER
) RETURN VARCHAR2
IS
    v_numero VARCHAR2(30);
    v_anio   NUMBER := p_anio;
    v_vence  DATE;
BEGIN
    -- quitar espacios y guiones
    v_numero := REPLACE(REPLACE(p_numero, ' ', ''), '-', '');

    IF v_numero IS NULL OR NOT REGEXP_LIKE(v_numero, '^[0-9]{16}$') THEN
        RETURN 'RECHAZADA';
    END IF;

    IF v_numero = '4000000000000002' THEN
        RETURN 'RECHAZADA';
    END IF;

    IF p_mes IS NULL OR p_mes NOT BETWEEN 1 AND 12 OR v_anio IS NULL THEN
        RETURN 'RECHAZADA';
    END IF;

    IF v_anio < 100 THEN
        v_anio := v_anio + 2000;  -- año escrito con dos dígitos (ej. 28)
    END IF;

    -- la tarjeta vence el último día del mes indicado
    v_vence := LAST_DAY(TO_DATE(TO_CHAR(v_anio) || LPAD(TO_CHAR(p_mes), 2, '0'), 'YYYYMM'));

    IF v_vence < TRUNC(SYSDATE) THEN
        RETURN 'RECHAZADA';
    END IF;

    RETURN 'APROBADA';
END fn_validar_tarjeta;
/

-- ---------------------------------------------------------------------
-- fn_cargo_pendiente: suma de los cargos por cancelación (15 %) que el
-- cliente tiene pendientes por pedidos en efectivo que canceló.
-- Ese monto se suma al total de su siguiente pedido.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_cargo_pendiente (
    p_id_cliente IN NUMBER
) RETURN NUMBER
IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(c.monto_cobro), 0)
      INTO v_total
      FROM cancelacion_pedido c
      JOIN pedido p ON p.id_pedido = c.id_pedido
     WHERE p.id_cliente   = p_id_cliente
       AND c.estado_cargo = 'PENDIENTE';

    RETURN v_total;
END fn_cargo_pendiente;
/

-- ---------------------------------------------------------------------
-- fn_promedio_repartidor: calificación promedio (1 a 5) de un repartidor
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_promedio_repartidor (
    p_id_repartidor IN NUMBER
) RETURN NUMBER
IS
    v_promedio NUMBER;
BEGIN
    SELECT ROUND(AVG(c.puntuacion), 2)
      INTO v_promedio
      FROM calificacion c
      JOIN pedido p ON p.id_pedido = c.id_pedido
     WHERE p.id_repartidor = p_id_repartidor;

    RETURN NVL(v_promedio, 0);
END fn_promedio_repartidor;
/

-- ---------------------------------------------------------------------
-- fn_ruta_km: optimización de la ruta del repartidor para un pedido.
-- La ruta más corta para entregar es ir primero al negocio a recoger y
-- luego directo al cliente. Se calcula con Haversine (fn_distancia_km):
--   ASIGNADO            : repartidor -> negocio -> cliente
--   RECOGIDO o EN RUTA  : repartidor -> cliente
--   otros estados       : NULL (no hay ruta activa)
-- Como la asignación automática elige al repartidor más cercano al negocio,
-- también se elige la ruta total más corta.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_ruta_km (
    p_id_pedido IN NUMBER
) RETURN NUMBER
IS
    v_estado  estado_pedido.nombre%TYPE;
    v_lat_rep NUMBER;
    v_lon_rep NUMBER;
    v_lat_neg NUMBER;
    v_lon_neg NUMBER;
    v_lat_ent NUMBER;
    v_lon_ent NUMBER;
BEGIN
    SELECT e.nombre, r.latitud, r.longitud, n.latitud, n.longitud, d.latitud, d.longitud
      INTO v_estado, v_lat_rep, v_lon_rep, v_lat_neg, v_lon_neg, v_lat_ent, v_lon_ent
      FROM pedido p
      JOIN estado_pedido e     ON e.id_estado_pedido = p.id_estado_pedido
      JOIN negocio n           ON n.id_negocio       = p.id_negocio
      JOIN direccion_cliente d ON d.id_direccion     = p.id_direccion
      LEFT JOIN repartidor r   ON r.id_repartidor    = p.id_repartidor
     WHERE p.id_pedido = p_id_pedido;

    IF v_estado = 'ASIGNADO' THEN
        RETURN fn_distancia_km(v_lat_rep, v_lon_rep, v_lat_neg, v_lon_neg)
             + fn_distancia_km(v_lat_neg, v_lon_neg, v_lat_ent, v_lon_ent);
    ELSIF v_estado IN ('RECOGIDO', 'EN RUTA') THEN
        RETURN fn_distancia_km(v_lat_rep, v_lon_rep, v_lat_ent, v_lon_ent);
    ELSE
        RETURN NULL;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END fn_ruta_km;
/

-- ---------------------------------------------------------------------
-- fn_minutos_estimados: tiempo estimado de llegada (en minutos) para
-- recorrer una distancia, con la velocidad promedio del parámetro
-- VELOCIDAD_PROMEDIO (km/h).
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_minutos_estimados (
    p_km IN NUMBER
) RETURN NUMBER
IS
BEGIN
    IF p_km IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN CEIL(p_km / fn_parametro('VELOCIDAD_PROMEDIO') * 60);
END fn_minutos_estimados;
/

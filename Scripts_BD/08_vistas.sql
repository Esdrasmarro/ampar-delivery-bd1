-- =====================================================================
-- Proyecto Final Base de Datos 1 - Sistema de Control de Delivery "Ampar"
-- Script 08: vistas
-- Ejecutar conectado como: AMPAR
-- Estudiante: Esdras Lemuel Marroquín Rojas - Carné 3190-13-13335
-- =====================================================================
-- Una vista es una "consulta con nombre" (CREATE VIEW nombre AS consulta).
-- La aplicación usa estas vistas para el menú, las consultas en pantalla
-- y los reportes, sin repetir los JOIN en el código.

-- ---------------------------------------------------------------------
-- Menú de cada usuario según su rol (configuración del menú en la BD)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_menu_usuario AS
SELECT u.id_usuario,
       mo.id_modulo,
       mo.nombre AS modulo,
       mo.orden  AS orden_modulo,
       me.id_menu,
       me.nombre AS opcion,
       me.url,
       me.orden  AS orden_menu
  FROM usuario u
  JOIN rol r       ON r.id_rol     = u.id_rol
  JOIN rol_menu rm ON rm.id_rol    = u.id_rol
  JOIN menu me     ON me.id_menu   = rm.id_menu
  JOIN modulo mo   ON mo.id_modulo = me.id_modulo
 WHERE u.estado  = 'A'
   AND r.estado  = 'A'
   AND me.estado = 'A'
   AND mo.estado = 'A';

-- ---------------------------------------------------------------------
-- RG-01 Pedidos: datos completos de cada pedido (gestión centralizada de órdenes)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_pedido AS
SELECT p.id_pedido,
       p.fecha_pedido,
       c.id_cliente,
       c.nombres || ' ' || c.apellidos AS cliente,
       c.telefono                      AS telefono_cliente,
       n.id_negocio,
       n.nombre                        AS negocio,
       e.id_estado_pedido,
       e.nombre                        AS estado,
       e.orden                         AS orden_estado,
       m.nombre                        AS metodo_pago,
       m.usa_pasarela,
       p.estado_pago,
       p.id_repartidor,
       NVL2(r.id_repartidor, r.nombres || ' ' || r.apellidos, 'Sin asignar') AS repartidor,
       d.direccion                     AS direccion_entrega,
       d.referencia,
       z.nombre                        AS zona,
       mu.nombre                       AS municipio,
       de.nombre                       AS departamento,
       p.zona_roja,
       p.subtotal,
       p.costo_envio,
       p.cargo_anterior,
       p.total,
       p.distancia_km,
       n.latitud  AS lat_negocio,
       n.longitud AS lon_negocio,
       d.latitud  AS lat_entrega,
       d.longitud AS lon_entrega,
       r.latitud  AS lat_repartidor,
       r.longitud AS lon_repartidor,
       fn_ruta_km(p.id_pedido)                       AS ruta_km,           -- ruta del repartidor
       fn_minutos_estimados(fn_ruta_km(p.id_pedido)) AS minutos_estimados  -- tiempo estimado de llegada
  FROM pedido p
  JOIN cliente c            ON c.id_cliente        = p.id_cliente
  JOIN negocio n            ON n.id_negocio        = p.id_negocio
  JOIN estado_pedido e      ON e.id_estado_pedido  = p.id_estado_pedido
  JOIN metodo_pago m        ON m.id_metodo_pago    = p.id_metodo_pago
  JOIN direccion_cliente d  ON d.id_direccion      = p.id_direccion
  JOIN zona z               ON z.id_zona           = d.id_zona
  JOIN municipio mu         ON mu.id_municipio     = z.id_municipio
  JOIN departamento de      ON de.id_departamento  = mu.id_departamento
  LEFT JOIN repartidor r    ON r.id_repartidor     = p.id_repartidor;

-- ---------------------------------------------------------------------
-- Tracking: historial de estados de cada pedido
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_tracking AS
SELECT h.id_historial,
       h.id_pedido,
       e.nombre AS estado,
       e.orden,
       h.fecha,
       h.latitud,
       h.longitud
  FROM historial_estado h
  JOIN estado_pedido e ON e.id_estado_pedido = h.id_estado_pedido;

-- ---------------------------------------------------------------------
-- RG-02 Negocios con horarios, días de entrega y si están abiertos ahora
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_negocio_horario AS
SELECT n.id_negocio,
       n.nombre  AS negocio,
       t.nombre  AS tipo_negocio,
       z.nombre  AS zona,
       mu.nombre AS municipio,
       n.telefono,
       n.estado,
       h.dia_semana,
       CASE h.dia_semana
            WHEN 1 THEN 'Lunes'   WHEN 2 THEN 'Martes'  WHEN 3 THEN 'Miércoles'
            WHEN 4 THEN 'Jueves'  WHEN 5 THEN 'Viernes' WHEN 6 THEN 'Sábado'
            WHEN 7 THEN 'Domingo'
       END AS dia,
       h.hora_apertura,
       h.hora_cierre,
       h.hace_entrega,
       fn_negocio_abierto(n.id_negocio) AS abierto_ahora
  FROM negocio n
  JOIN tipo_negocio t       ON t.id_tipo_negocio = n.id_tipo_negocio
  JOIN zona z               ON z.id_zona         = n.id_zona
  JOIN municipio mu         ON mu.id_municipio   = z.id_municipio
  LEFT JOIN horario_negocio h ON h.id_negocio    = n.id_negocio;

-- ---------------------------------------------------------------------
-- RG-03 Catálogo digital de productos por negocio
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_catalogo_producto AS
SELECT p.id_producto,
       p.nombre      AS producto,
       p.descripcion,
       p.precio,
       p.disponible,
       c.id_categoria,
       c.nombre      AS categoria,
       n.id_negocio,
       n.nombre      AS negocio,
       t.nombre      AS tipo_negocio,
       fn_negocio_abierto(n.id_negocio) AS abierto_ahora
  FROM producto p
  JOIN categoria_producto c ON c.id_categoria    = p.id_categoria
  JOIN negocio n            ON n.id_negocio      = p.id_negocio
  JOIN tipo_negocio t       ON t.id_tipo_negocio = n.id_tipo_negocio
 WHERE p.estado = 'A'
   AND n.estado = 'ACTIVO';

-- ---------------------------------------------------------------------
-- RG-04 Notificaciones enviadas por SMS y WhatsApp
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_notificacion AS
SELECT nt.id_notificacion,
       nt.id_pedido,
       c.nombres || ' ' || c.apellidos AS cliente,
       nt.canal,
       nt.telefono,
       nt.mensaje,
       nt.fecha_envio,
       nt.estado
  FROM notificacion nt
  JOIN pedido p  ON p.id_pedido  = nt.id_pedido
  JOIN cliente c ON c.id_cliente = p.id_cliente;

-- ---------------------------------------------------------------------
-- RG-05 Cancelaciones de pedidos con el monto cobrado (15 %)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_cancelacion_pedido AS
SELECT ca.id_cancelacion,
       ca.id_pedido,
       ca.fecha,
       c.nombres || ' ' || c.apellidos AS cliente,
       n.nombre        AS negocio,
       m.nombre        AS metodo_pago,
       mo.descripcion  AS motivo,
       p.total,
       ca.porcentaje,
       ca.monto_cobro,
       ca.monto_reembolso,
       ca.estado_cargo,
       ca.id_pedido_aplicado
  FROM cancelacion_pedido ca
  JOIN pedido p              ON p.id_pedido      = ca.id_pedido
  JOIN cliente c             ON c.id_cliente     = p.id_cliente
  JOIN negocio n             ON n.id_negocio     = p.id_negocio
  JOIN metodo_pago m         ON m.id_metodo_pago = p.id_metodo_pago
  JOIN motivo_cancelacion mo ON mo.id_motivo     = ca.id_motivo;

-- ---------------------------------------------------------------------
-- RG-06 Calificaciones y comentarios de los repartidores
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_calificacion AS
SELECT ca.id_calificacion,
       ca.id_pedido,
       r.id_repartidor,
       r.nombres || ' ' || r.apellidos AS repartidor,
       c.nombres || ' ' || c.apellidos AS cliente,
       ca.puntuacion,
       ca.comentario,
       ca.fecha
  FROM calificacion ca
  JOIN pedido p     ON p.id_pedido     = ca.id_pedido
  JOIN repartidor r ON r.id_repartidor = p.id_repartidor
  JOIN cliente c    ON c.id_cliente    = p.id_cliente;

-- ---------------------------------------------------------------------
-- RE-01 Reporte: entregas de cada repartidor por departamento, municipio y zona
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_rep_entregas_area AS
SELECT r.id_repartidor,
       r.nombres || ' ' || r.apellidos AS repartidor,
       de.nombre AS departamento,
       mu.nombre AS municipio,
       z.nombre  AS zona,
       COUNT(*)  AS entregas
  FROM pedido p
  JOIN estado_pedido e     ON e.id_estado_pedido = p.id_estado_pedido
  JOIN repartidor r        ON r.id_repartidor    = p.id_repartidor
  JOIN direccion_cliente d ON d.id_direccion     = p.id_direccion
  JOIN zona z              ON z.id_zona          = d.id_zona
  JOIN municipio mu        ON mu.id_municipio    = z.id_municipio
  JOIN departamento de     ON de.id_departamento = mu.id_departamento
 WHERE e.nombre = 'ENTREGADO'
 GROUP BY r.id_repartidor, r.nombres, r.apellidos, de.nombre, mu.nombre, z.nombre;

-- ---------------------------------------------------------------------
-- RE-02 Reporte: repartidores que cancelan entregas y su calificación promedio
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_rep_cancelaciones_repartidor AS
SELECT r.id_repartidor,
       r.nombres || ' ' || r.apellidos AS repartidor,
       (SELECT COUNT(*)
          FROM cancelacion_entrega ce
         WHERE ce.id_repartidor = r.id_repartidor) AS cancelaciones,
       (SELECT COUNT(*)
          FROM pedido p
          JOIN estado_pedido e ON e.id_estado_pedido = p.id_estado_pedido
         WHERE p.id_repartidor = r.id_repartidor
           AND e.nombre = 'ENTREGADO') AS entregas,
       fn_promedio_repartidor(r.id_repartidor) AS calificacion_promedio
  FROM repartidor r;

-- ---------------------------------------------------------------------
-- RE-03 Reporte: pedidos, entregas y cancelaciones por zona (zonas rojas)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_rep_zonas AS
SELECT z.id_zona,
       z.nombre  AS zona,
       mu.nombre AS municipio,
       z.zona_roja,
       COUNT(p.id_pedido) AS pedidos,
       SUM(CASE WHEN e.nombre = 'ENTREGADO' THEN 1 ELSE 0 END) AS entregados,
       SUM(CASE WHEN e.nombre = 'CANCELADO' THEN 1 ELSE 0 END) AS cancelados,
       (SELECT COUNT(*)
          FROM cancelacion_entrega ce
          JOIN pedido p2            ON p2.id_pedido    = ce.id_pedido
          JOIN direccion_cliente d2 ON d2.id_direccion = p2.id_direccion
         WHERE d2.id_zona = z.id_zona) AS cancelaciones_repartidor
  FROM zona z
  JOIN municipio mu             ON mu.id_municipio    = z.id_municipio
  LEFT JOIN direccion_cliente d ON d.id_zona          = z.id_zona
  LEFT JOIN pedido p            ON p.id_direccion     = d.id_direccion
  LEFT JOIN estado_pedido e     ON e.id_estado_pedido = p.id_estado_pedido
 GROUP BY z.id_zona, z.nombre, mu.nombre, z.zona_roja;

-- ---------------------------------------------------------------------
-- Dashboard gerencial: indicadores del día
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_dashboard AS
SELECT (SELECT COUNT(*) FROM pedido
         WHERE TRUNC(fecha_pedido) = TRUNC(SYSDATE)) AS pedidos_hoy,
       (SELECT NVL(SUM(p.total), 0)
          FROM pedido p JOIN estado_pedido e ON e.id_estado_pedido = p.id_estado_pedido
         WHERE e.nombre = 'ENTREGADO' AND TRUNC(p.fecha_pedido) = TRUNC(SYSDATE)) AS ventas_hoy,
       (SELECT COUNT(*)
          FROM pedido p JOIN estado_pedido e ON e.id_estado_pedido = p.id_estado_pedido
         WHERE e.nombre = 'ENTREGADO' AND TRUNC(p.fecha_pedido) = TRUNC(SYSDATE)) AS entregados_hoy,
       (SELECT COUNT(*)
          FROM pedido p JOIN estado_pedido e ON e.id_estado_pedido = p.id_estado_pedido
         WHERE e.nombre = 'CANCELADO' AND TRUNC(p.fecha_pedido) = TRUNC(SYSDATE)) AS cancelados_hoy,
       (SELECT COUNT(*)
          FROM pedido p JOIN estado_pedido e ON e.id_estado_pedido = p.id_estado_pedido
         WHERE e.nombre IN ('CONFIRMADO', 'ASIGNADO', 'RECOGIDO', 'EN RUTA')) AS pedidos_activos,
       (SELECT COUNT(*) FROM repartidor
         WHERE estado = 'A' AND disponible = 'S') AS repartidores_disponibles,
       (SELECT COUNT(*) FROM negocio WHERE estado = 'ACTIVO') AS negocios_activos,
       (SELECT COUNT(*) FROM negocio WHERE estado = 'PENDIENTE') AS solicitudes_pendientes
  FROM dual;

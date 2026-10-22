-- =====================================================================
-- Proyecto Final Base de Datos 1 - Sistema de Control de Delivery "Ampar"
-- Script 11: configuración del menú y seguridad de la aplicación en la BD
-- Ejecutar conectado como: AMPAR
-- Estudiante: Esdras Lemuel Marroquín Rojas - Carné 3190-13-13335
-- =====================================================================
-- ROL       : roles de la aplicación
-- MODULO    : módulos del sistema (agrupan el menú)
-- MENU      : opciones del menú (cada una es una página de la aplicación)
-- ROL_MENU  : qué opciones del menú puede usar cada rol (permisos)
-- USUARIO   : usuarios de la aplicación con su clave encriptada (SHA-256)
--
-- La aplicación arma el menú con la vista VW_MENU_USUARIO y antes de abrir
-- cualquier página pregunta a pkg_seguridad.fn_tiene_permiso si el rol puede entrar.

-- ---------------------------------------------------------------------
-- Roles de la aplicación
-- ---------------------------------------------------------------------
INSERT INTO rol (nombre, descripcion) VALUES ('ADMINISTRADOR', 'Administración total del sistema');                  -- 1
INSERT INTO rol (nombre, descripcion) VALUES ('OPERADOR', 'Operador / despachador de pedidos');                     -- 2
INSERT INTO rol (nombre, descripcion) VALUES ('NEGOCIO', 'Usuario del negocio afiliado');                          -- 3
INSERT INTO rol (nombre, descripcion) VALUES ('REPARTIDOR', 'Conductor de Ampar');                                  -- 4
INSERT INTO rol (nombre, descripcion) VALUES ('CLIENTE', 'Cliente que compra en línea');                            -- 5
INSERT INTO rol (nombre, descripcion) VALUES ('GERENCIA', 'Consultas gerenciales y reportes');                      -- 6

-- ---------------------------------------------------------------------
-- Módulos
-- ---------------------------------------------------------------------
INSERT INTO modulo (nombre, orden) VALUES ('Seguridad', 1);    -- 1
INSERT INTO modulo (nombre, orden) VALUES ('Catálogos', 2);    -- 2
INSERT INTO modulo (nombre, orden) VALUES ('Negocios', 3);     -- 3
INSERT INTO modulo (nombre, orden) VALUES ('Pedidos', 4);      -- 4
INSERT INTO modulo (nombre, orden) VALUES ('Despacho', 5);     -- 5
INSERT INTO modulo (nombre, orden) VALUES ('Repartidor', 6);   -- 6
INSERT INTO modulo (nombre, orden) VALUES ('Reportes', 7);     -- 7

-- ---------------------------------------------------------------------
-- Opciones del menú (url = página de la aplicación)
-- ---------------------------------------------------------------------
-- Seguridad
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (1, 'Usuarios', '/seguridad/usuarios', 1);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (1, 'Roles', '/seguridad/roles', 2);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (1, 'Módulos', '/seguridad/modulos', 3);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (1, 'Opciones de menú', '/seguridad/menus', 4);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (1, 'Permisos por rol', '/seguridad/permisos', 5);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (1, 'Bitácora', '/seguridad/bitacora', 6);
-- Catálogos
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (2, 'Departamentos', '/catalogos/departamentos', 1);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (2, 'Municipios', '/catalogos/municipios', 2);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (2, 'Zonas y zonas rojas', '/catalogos/zonas', 3);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (2, 'Tipos de negocio', '/catalogos/tipos-negocio', 4);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (2, 'Categorías de producto', '/catalogos/categorias', 5);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (2, 'Tipos de vehículo', '/catalogos/tipos-vehiculo', 6);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (2, 'Métodos de pago', '/catalogos/metodos-pago', 7);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (2, 'Estados de pedido', '/catalogos/estados-pedido', 8);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (2, 'Motivos de cancelación', '/catalogos/motivos', 9);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (2, 'Parámetros', '/catalogos/parametros', 10);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (2, 'Clientes', '/catalogos/clientes', 11);
-- Negocios
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (3, 'Negocios afiliados', '/negocios/lista', 1);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (3, 'Solicitudes de afiliación', '/negocios/solicitudes', 2);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (3, 'Mi negocio', '/negocios/mi-negocio', 3);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (3, 'Horarios y días de entrega', '/negocios/horarios', 4);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (3, 'Catálogo de productos', '/negocios/productos', 5);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (3, 'Pedidos del negocio', '/negocios/pedidos', 6);
-- Pedidos
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (4, 'Hacer un pedido', '/pedidos/nuevo', 1);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (4, 'Mis pedidos', '/pedidos/mis-pedidos', 2);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (4, 'Mis direcciones', '/pedidos/direcciones', 3);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (4, 'Consulta de pedidos', '/pedidos/consulta', 4);
-- Despacho
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (5, 'Monitor de pedidos', '/despacho/monitor', 1);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (5, 'Asignar repartidor', '/despacho/asignar', 2);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (5, 'Repartidores', '/despacho/repartidores', 3);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (5, 'Notificaciones enviadas', '/despacho/notificaciones', 4);
-- Repartidor
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (6, 'Mi entrega', '/repartidor/entrega', 1);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (6, 'Mis calificaciones', '/repartidor/calificaciones', 2);
-- Reportes
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Dashboard', '/reportes/dashboard', 1);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Entregas por área geográfica', '/reportes/entregas-area', 2);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Repartidores que cancelan', '/reportes/cancelaciones-repartidor', 3);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Zonas rojas', '/reportes/zonas', 4);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Consulta de pedidos', '/reportes/pedidos', 5);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Negocios y horarios', '/reportes/negocios', 6);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Catálogo de productos', '/reportes/productos', 7);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Cancelaciones de pedidos', '/reportes/cancelaciones', 8);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Calificaciones de repartidores', '/reportes/calificaciones', 9);

-- ---------------------------------------------------------------------
-- Permisos: opciones del menú de cada rol
-- ---------------------------------------------------------------------
-- ADMINISTRADOR: todas las opciones excepto las páginas propias de negocio, cliente y repartidor
INSERT INTO rol_menu (id_rol, id_menu)
SELECT 1, id_menu FROM menu
 WHERE url NOT IN ('/negocios/mi-negocio', '/negocios/horarios', '/negocios/productos', '/negocios/pedidos',
                   '/pedidos/nuevo', '/pedidos/mis-pedidos', '/pedidos/direcciones',
                   '/repartidor/entrega', '/repartidor/calificaciones');

-- OPERADOR: despacho, consulta de pedidos y consultas generales
INSERT INTO rol_menu (id_rol, id_menu)
SELECT 2, id_menu FROM menu
 WHERE url IN ('/despacho/monitor', '/despacho/asignar', '/despacho/repartidores', '/despacho/notificaciones',
               '/pedidos/consulta', '/reportes/pedidos', '/reportes/negocios', '/reportes/productos',
               '/reportes/cancelaciones', '/reportes/calificaciones');

-- NEGOCIO: su negocio, horarios, catálogo de productos y sus pedidos
INSERT INTO rol_menu (id_rol, id_menu)
SELECT 3, id_menu FROM menu
 WHERE url IN ('/negocios/mi-negocio', '/negocios/horarios', '/negocios/productos', '/negocios/pedidos');

-- REPARTIDOR: su entrega y sus calificaciones
INSERT INTO rol_menu (id_rol, id_menu)
SELECT 4, id_menu FROM menu
 WHERE url IN ('/repartidor/entrega', '/repartidor/calificaciones');

-- CLIENTE: hacer pedidos, ver sus pedidos (tracking, cancelar, calificar) y sus direcciones
INSERT INTO rol_menu (id_rol, id_menu)
SELECT 5, id_menu FROM menu
 WHERE url IN ('/pedidos/nuevo', '/pedidos/mis-pedidos', '/pedidos/direcciones');

-- GERENCIA: todo el módulo de reportes
INSERT INTO rol_menu (id_rol, id_menu)
SELECT 6, id_menu FROM menu WHERE id_modulo = 7;

-- ---------------------------------------------------------------------
-- Usuarios internos (la contraseña se guarda encriptada con fn_encriptar)
-- Contraseña de prueba para todos: Ampar2026
-- ---------------------------------------------------------------------
INSERT INTO usuario (id_rol, nombre_usuario, clave, nombre_completo)
VALUES (1, 'admin', fn_encriptar('Ampar2026'), 'Administrador del sistema');
INSERT INTO usuario (id_rol, nombre_usuario, clave, nombre_completo)
VALUES (2, 'operador', fn_encriptar('Ampar2026'), 'Operador de despacho');
INSERT INTO usuario (id_rol, nombre_usuario, clave, nombre_completo)
VALUES (6, 'gerente', fn_encriptar('Ampar2026'), 'Gerente general');

COMMIT;

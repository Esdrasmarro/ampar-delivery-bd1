-- Script 11: menu y seguridad. Ejecutar como AMPAR
INSERT INTO rol (nombre, descripcion) VALUES ('ADMINISTRADOR', 'Administración total del sistema');
INSERT INTO rol (nombre, descripcion) VALUES ('OPERADOR', 'Operador / despachador de pedidos');
INSERT INTO rol (nombre, descripcion) VALUES ('NEGOCIO', 'Usuario del negocio afiliado');
INSERT INTO rol (nombre, descripcion) VALUES ('REPARTIDOR', 'Conductor de Ampar');
INSERT INTO rol (nombre, descripcion) VALUES ('CLIENTE', 'Cliente que compra en línea');
INSERT INTO rol (nombre, descripcion) VALUES ('GERENCIA', 'Consultas gerenciales y reportes');

INSERT INTO modulo (nombre, orden) VALUES ('Seguridad', 1);
INSERT INTO modulo (nombre, orden) VALUES ('Catálogos', 2);
INSERT INTO modulo (nombre, orden) VALUES ('Negocios', 3);
INSERT INTO modulo (nombre, orden) VALUES ('Pedidos', 4);
INSERT INTO modulo (nombre, orden) VALUES ('Despacho', 5);
INSERT INTO modulo (nombre, orden) VALUES ('Repartidor', 6);
INSERT INTO modulo (nombre, orden) VALUES ('Reportes', 7);

INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (1, 'Usuarios', '/seguridad/usuarios', 1);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (1, 'Roles', '/seguridad/roles', 2);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (1, 'Módulos', '/seguridad/modulos', 3);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (1, 'Opciones de menú', '/seguridad/menus', 4);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (1, 'Permisos por rol', '/seguridad/permisos', 5);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (1, 'Bitácora', '/seguridad/bitacora', 6);
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
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (3, 'Negocios afiliados', '/negocios/lista', 1);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (3, 'Solicitudes de afiliación', '/negocios/solicitudes', 2);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (3, 'Mi negocio', '/negocios/mi-negocio', 3);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (3, 'Horarios y días de entrega', '/negocios/horarios', 4);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (3, 'Catálogo de productos', '/negocios/productos', 5);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (3, 'Pedidos del negocio', '/negocios/pedidos', 6);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (4, 'Hacer un pedido', '/pedidos/nuevo', 1);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (4, 'Mis pedidos', '/pedidos/mis-pedidos', 2);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (4, 'Mis direcciones', '/pedidos/direcciones', 3);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (4, 'Consulta de pedidos', '/pedidos/consulta', 4);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (5, 'Monitor de pedidos', '/despacho/monitor', 1);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (5, 'Asignar repartidor', '/despacho/asignar', 2);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (5, 'Repartidores', '/despacho/repartidores', 3);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (5, 'Notificaciones enviadas', '/despacho/notificaciones', 4);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (6, 'Mi entrega', '/repartidor/entrega', 1);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (6, 'Mis calificaciones', '/repartidor/calificaciones', 2);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Dashboard', '/reportes/dashboard', 1);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Entregas por área geográfica', '/reportes/entregas-area', 2);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Repartidores que cancelan', '/reportes/cancelaciones-repartidor', 3);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Zonas rojas', '/reportes/zonas', 4);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Consulta de pedidos', '/reportes/pedidos', 5);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Negocios y horarios', '/reportes/negocios', 6);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Catálogo de productos', '/reportes/productos', 7);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Cancelaciones de pedidos', '/reportes/cancelaciones', 8);
INSERT INTO menu (id_modulo, nombre, url, orden) VALUES (7, 'Calificaciones de repartidores', '/reportes/calificaciones', 9);

INSERT INTO rol_menu (id_rol, id_menu)
SELECT 1, id_menu FROM menu
 WHERE url NOT IN ('/negocios/mi-negocio', '/negocios/horarios', '/negocios/productos', '/negocios/pedidos',
                   '/pedidos/nuevo', '/pedidos/mis-pedidos', '/pedidos/direcciones',
                   '/repartidor/entrega', '/repartidor/calificaciones');

INSERT INTO rol_menu (id_rol, id_menu)
SELECT 2, id_menu FROM menu
 WHERE url IN ('/despacho/monitor', '/despacho/asignar', '/despacho/repartidores', '/despacho/notificaciones',
               '/pedidos/consulta', '/reportes/pedidos', '/reportes/negocios', '/reportes/productos',
               '/reportes/cancelaciones', '/reportes/calificaciones');

INSERT INTO rol_menu (id_rol, id_menu)
SELECT 3, id_menu FROM menu
 WHERE url IN ('/negocios/mi-negocio', '/negocios/horarios', '/negocios/productos', '/negocios/pedidos');

INSERT INTO rol_menu (id_rol, id_menu)
SELECT 4, id_menu FROM menu
 WHERE url IN ('/repartidor/entrega', '/repartidor/calificaciones');

INSERT INTO rol_menu (id_rol, id_menu)
SELECT 5, id_menu FROM menu
 WHERE url IN ('/pedidos/nuevo', '/pedidos/mis-pedidos', '/pedidos/direcciones');

INSERT INTO rol_menu (id_rol, id_menu)
SELECT 6, id_menu FROM menu WHERE id_modulo = 7;

INSERT INTO usuario (id_rol, nombre_usuario, clave, nombre_completo)
VALUES (1, 'admin', fn_encriptar('Ampar2026'), 'Administrador del sistema');
INSERT INTO usuario (id_rol, nombre_usuario, clave, nombre_completo)
VALUES (2, 'operador', fn_encriptar('Ampar2026'), 'Operador de despacho');
INSERT INTO usuario (id_rol, nombre_usuario, clave, nombre_completo)
VALUES (6, 'gerente', fn_encriptar('Ampar2026'), 'Gerente general');

COMMIT;

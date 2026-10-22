-- =====================================================================
-- Proyecto Final Base de Datos 1 - Sistema de Control de Delivery "Ampar"
-- Script de tablas (modelo físico) para importar en Oracle SQL Developer Data Modeler
-- Estudiante: Esdras Lemuel Marroquín Rojas - Carné 3190-13-13335
-- Constraints con nombre al final de cada tabla: PK_, FK_, UK_, CH_
-- =====================================================================

-- DEPARTAMENTO: Departamentos del país. Se carga el departamento de Guatemala.
CREATE TABLE departamento (
    id_departamento  NUMBER(10) NOT NULL,
    nombre           VARCHAR2(60) NOT NULL,
    estado           CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_DEPTO PRIMARY KEY (id_departamento),
    CONSTRAINT UK_DEPTO_NOMBRE UNIQUE (nombre),
    CONSTRAINT CH_DEPTO_ESTADO CHECK (estado IN ('A','I'))
);

-- MUNICIPIO: Municipios de cada departamento (17 del departamento de Guatemala).
CREATE TABLE municipio (
    id_municipio     NUMBER(10) NOT NULL,
    id_departamento  NUMBER(10) NOT NULL,
    nombre           VARCHAR2(60) NOT NULL,
    estado           CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_MUNI PRIMARY KEY (id_municipio),
    CONSTRAINT UK_MUNI_NOMBRE UNIQUE (id_departamento, nombre),
    CONSTRAINT FK_MUNI_DEPTO FOREIGN KEY (id_departamento) REFERENCES departamento (id_departamento),
    CONSTRAINT CH_MUNI_ESTADO CHECK (estado IN ('A','I'))
);

-- ZONA: Zonas de cada municipio. Indica si la zona es roja.
CREATE TABLE zona (
    id_zona       NUMBER(10) NOT NULL,
    id_municipio  NUMBER(10) NOT NULL,
    nombre        VARCHAR2(60) NOT NULL,
    zona_roja     CHAR(1) DEFAULT 'N' NOT NULL,
    observacion   VARCHAR2(200),
    estado        CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_ZONA PRIMARY KEY (id_zona),
    CONSTRAINT UK_ZONA_NOMBRE UNIQUE (id_municipio, nombre),
    CONSTRAINT FK_ZONA_MUNI FOREIGN KEY (id_municipio) REFERENCES municipio (id_municipio),
    CONSTRAINT CH_ZONA_ROJA CHECK (zona_roja IN ('S','N')),
    CONSTRAINT CH_ZONA_ESTADO CHECK (estado IN ('A','I'))
);

-- TIPO_NEGOCIO: Tipos de negocio que se pueden afiliar.
CREATE TABLE tipo_negocio (
    id_tipo_negocio  NUMBER(10) NOT NULL,
    nombre           VARCHAR2(50) NOT NULL,
    descripcion      VARCHAR2(200),
    estado           CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_TIPO_NEG PRIMARY KEY (id_tipo_negocio),
    CONSTRAINT UK_TIPO_NEG_NOMBRE UNIQUE (nombre),
    CONSTRAINT CH_TIPO_NEG_ESTADO CHECK (estado IN ('A','I'))
);

-- NEGOCIO: Negocios afiliados a Ampar que publican su catálogo digital.
CREATE TABLE negocio (
    id_negocio          NUMBER(10) NOT NULL,
    id_tipo_negocio     NUMBER(10) NOT NULL,
    id_zona             NUMBER(10) NOT NULL,
    nombre              VARCHAR2(100) NOT NULL,
    nit                 VARCHAR2(15) NOT NULL,
    propietario         VARCHAR2(100) NOT NULL,
    telefono            VARCHAR2(15) NOT NULL,
    correo              VARCHAR2(100) NOT NULL,
    direccion           VARCHAR2(200) NOT NULL,
    latitud             NUMBER(9,6) NOT NULL,
    longitud            NUMBER(9,6) NOT NULL,
    radio_cobertura_km  NUMBER(5,2) DEFAULT 10 NOT NULL,
    estado              VARCHAR2(10) DEFAULT 'PENDIENTE' NOT NULL,
    fecha_registro      DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT PK_NEGOCIO PRIMARY KEY (id_negocio),
    CONSTRAINT UK_NEGOCIO_NIT UNIQUE (nit),
    CONSTRAINT FK_NEGOCIO_TIPO_NEG FOREIGN KEY (id_tipo_negocio) REFERENCES tipo_negocio (id_tipo_negocio),
    CONSTRAINT FK_NEGOCIO_ZONA FOREIGN KEY (id_zona) REFERENCES zona (id_zona),
    CONSTRAINT CH_NEGOCIO_RADIO CHECK (radio_cobertura_km > 0),
    CONSTRAINT CH_NEGOCIO_ESTADO CHECK (estado IN ('PENDIENTE','ACTIVO','RECHAZADO','INACTIVO'))
);

-- HORARIO_NEGOCIO: Horario de atención y días de entrega de cada negocio.
CREATE TABLE horario_negocio (
    id_horario     NUMBER(10) NOT NULL,
    id_negocio     NUMBER(10) NOT NULL,
    dia_semana     NUMBER(1) NOT NULL,
    hora_apertura  VARCHAR2(5) NOT NULL,
    hora_cierre    VARCHAR2(5) NOT NULL,
    hace_entrega   CHAR(1) DEFAULT 'S' NOT NULL,
    CONSTRAINT PK_HORARIO PRIMARY KEY (id_horario),
    CONSTRAINT UK_HORARIO_DIA UNIQUE (id_negocio, dia_semana),
    CONSTRAINT FK_HORARIO_NEGOCIO FOREIGN KEY (id_negocio) REFERENCES negocio (id_negocio),
    CONSTRAINT CH_HORARIO_DIA CHECK (dia_semana BETWEEN 1 AND 7),
    CONSTRAINT CH_HORARIO_HORAS CHECK (hora_apertura < hora_cierre),
    CONSTRAINT CH_HORARIO_ENTREGA CHECK (hace_entrega IN ('S','N'))
);

-- CATEGORIA_PRODUCTO: Categorías para clasificar los productos del catálogo digital.
CREATE TABLE categoria_producto (
    id_categoria  NUMBER(10) NOT NULL,
    nombre        VARCHAR2(50) NOT NULL,
    descripcion   VARCHAR2(200),
    estado        CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_CATEG PRIMARY KEY (id_categoria),
    CONSTRAINT UK_CATEG_NOMBRE UNIQUE (nombre),
    CONSTRAINT CH_CATEG_ESTADO CHECK (estado IN ('A','I'))
);

-- PRODUCTO: Productos del catálogo digital de cada negocio.
CREATE TABLE producto (
    id_producto   NUMBER(10) NOT NULL,
    id_negocio    NUMBER(10) NOT NULL,
    id_categoria  NUMBER(10) NOT NULL,
    nombre        VARCHAR2(100) NOT NULL,
    descripcion   VARCHAR2(300),
    precio        NUMBER(10,2) NOT NULL,
    disponible    CHAR(1) DEFAULT 'S' NOT NULL,
    estado        CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_PRODUCTO PRIMARY KEY (id_producto),
    CONSTRAINT FK_PRODUCTO_NEGOCIO FOREIGN KEY (id_negocio) REFERENCES negocio (id_negocio),
    CONSTRAINT FK_PRODUCTO_CATEG FOREIGN KEY (id_categoria) REFERENCES categoria_producto (id_categoria),
    CONSTRAINT CH_PRODUCTO_PRECIO CHECK (precio > 0),
    CONSTRAINT CH_PRODUCTO_DISPONIBLE CHECK (disponible IN ('S','N')),
    CONSTRAINT CH_PRODUCTO_ESTADO CHECK (estado IN ('A','I'))
);

-- CLIENTE: Clientes que compran en línea.
CREATE TABLE cliente (
    id_cliente      NUMBER(10) NOT NULL,
    nombres         VARCHAR2(60) NOT NULL,
    apellidos       VARCHAR2(60) NOT NULL,
    telefono        VARCHAR2(15) NOT NULL,
    correo          VARCHAR2(100) NOT NULL,
    fecha_registro  DATE DEFAULT SYSDATE NOT NULL,
    estado          CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (id_cliente),
    CONSTRAINT UK_CLIENTE_CORREO UNIQUE (correo),
    CONSTRAINT CH_CLIENTE_ESTADO CHECK (estado IN ('A','I'))
);

-- DIRECCION_CLIENTE: Direcciones de entrega de cada cliente.
CREATE TABLE direccion_cliente (
    id_direccion  NUMBER(10) NOT NULL,
    id_cliente    NUMBER(10) NOT NULL,
    id_zona       NUMBER(10) NOT NULL,
    nombre        VARCHAR2(30) NOT NULL,
    direccion     VARCHAR2(200) NOT NULL,
    referencia    VARCHAR2(200),
    latitud       NUMBER(9,6) NOT NULL,
    longitud      NUMBER(9,6) NOT NULL,
    estado        CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_DIRECCION PRIMARY KEY (id_direccion),
    CONSTRAINT FK_DIRECCION_CLIENTE FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT FK_DIRECCION_ZONA FOREIGN KEY (id_zona) REFERENCES zona (id_zona),
    CONSTRAINT CH_DIRECCION_ESTADO CHECK (estado IN ('A','I'))
);

-- TIPO_VEHICULO: Tipos de vehículo de los repartidores.
CREATE TABLE tipo_vehiculo (
    id_tipo_vehiculo  NUMBER(10) NOT NULL,
    nombre            VARCHAR2(40) NOT NULL,
    estado            CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_TIPO_VEH PRIMARY KEY (id_tipo_vehiculo),
    CONSTRAINT UK_TIPO_VEH_NOMBRE UNIQUE (nombre),
    CONSTRAINT CH_TIPO_VEH_ESTADO CHECK (estado IN ('A','I'))
);

-- REPARTIDOR: Repartidores (conductores) de Ampar y su última ubicación.
CREATE TABLE repartidor (
    id_repartidor     NUMBER(10) NOT NULL,
    id_tipo_vehiculo  NUMBER(10) NOT NULL,
    nombres           VARCHAR2(60) NOT NULL,
    apellidos         VARCHAR2(60) NOT NULL,
    dpi               VARCHAR2(13) NOT NULL,
    telefono          VARCHAR2(15) NOT NULL,
    licencia          VARCHAR2(20) NOT NULL,
    placa             VARCHAR2(10),
    latitud           NUMBER(9,6),
    longitud          NUMBER(9,6),
    fecha_ubicacion   DATE,
    disponible        CHAR(1) DEFAULT 'S' NOT NULL,
    estado            CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_REPARTIDOR PRIMARY KEY (id_repartidor),
    CONSTRAINT UK_REPARTIDOR_DPI UNIQUE (dpi),
    CONSTRAINT FK_REPARTIDOR_TIPO_VEH FOREIGN KEY (id_tipo_vehiculo) REFERENCES tipo_vehiculo (id_tipo_vehiculo),
    CONSTRAINT CH_REPARTIDOR_DISPONIBLE CHECK (disponible IN ('S','N')),
    CONSTRAINT CH_REPARTIDOR_ESTADO CHECK (estado IN ('A','I'))
);

-- METODO_PAGO: Métodos de pago: efectivo al recibir y tarjeta en línea.
CREATE TABLE metodo_pago (
    id_metodo_pago  NUMBER(10) NOT NULL,
    nombre          VARCHAR2(40) NOT NULL,
    usa_pasarela    CHAR(1) NOT NULL,
    estado          CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_MET_PAGO PRIMARY KEY (id_metodo_pago),
    CONSTRAINT UK_MET_PAGO_NOMBRE UNIQUE (nombre),
    CONSTRAINT CH_MET_PAGO_PASARELA CHECK (usa_pasarela IN ('S','N')),
    CONSTRAINT CH_MET_PAGO_ESTADO CHECK (estado IN ('A','I'))
);

-- ESTADO_PEDIDO: Estados por los que pasa un pedido.
CREATE TABLE estado_pedido (
    id_estado_pedido  NUMBER(10) NOT NULL,
    nombre            VARCHAR2(20) NOT NULL,
    orden             NUMBER(2) NOT NULL,
    CONSTRAINT PK_EST_PED PRIMARY KEY (id_estado_pedido),
    CONSTRAINT UK_EST_PED_NOMBRE UNIQUE (nombre)
);

-- MOTIVO_CANCELACION: Motivos para cancelar un pedido (cliente) o una entrega (repartidor).
CREATE TABLE motivo_cancelacion (
    id_motivo    NUMBER(10) NOT NULL,
    descripcion  VARCHAR2(100) NOT NULL,
    aplica_a     VARCHAR2(10) NOT NULL,
    estado       CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_MOTIVO PRIMARY KEY (id_motivo),
    CONSTRAINT CH_MOTIVO_APLICA CHECK (aplica_a IN ('CLIENTE','REPARTIDOR')),
    CONSTRAINT CH_MOTIVO_ESTADO CHECK (estado IN ('A','I'))
);

-- PARAMETRO: Valores configurables del sistema.
CREATE TABLE parametro (
    id_parametro  NUMBER(10) NOT NULL,
    codigo        VARCHAR2(30) NOT NULL,
    valor         NUMBER(10,2) NOT NULL,
    descripcion   VARCHAR2(200) NOT NULL,
    CONSTRAINT PK_PARAMETRO PRIMARY KEY (id_parametro),
    CONSTRAINT UK_PARAMETRO_CODIGO UNIQUE (codigo)
);

-- PEDIDO: Encabezado del pedido en línea (gestión centralizada de órdenes).
CREATE TABLE pedido (
    id_pedido         NUMBER(10) NOT NULL,
    id_cliente        NUMBER(10) NOT NULL,
    id_negocio        NUMBER(10) NOT NULL,
    id_direccion      NUMBER(10) NOT NULL,
    id_metodo_pago    NUMBER(10) NOT NULL,
    id_estado_pedido  NUMBER(10) NOT NULL,
    id_repartidor     NUMBER(10),
    fecha_pedido      DATE DEFAULT SYSDATE NOT NULL,
    subtotal          NUMBER(10,2) NOT NULL,
    costo_envio       NUMBER(10,2) NOT NULL,
    cargo_anterior    NUMBER(10,2) DEFAULT 0 NOT NULL,
    total             NUMBER(10,2) NOT NULL,
    distancia_km      NUMBER(6,2) NOT NULL,
    zona_roja         CHAR(1) DEFAULT 'N' NOT NULL,
    estado_pago       VARCHAR2(10) DEFAULT 'PENDIENTE' NOT NULL,
    CONSTRAINT PK_PEDIDO PRIMARY KEY (id_pedido),
    CONSTRAINT FK_PEDIDO_CLIENTE FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT FK_PEDIDO_NEGOCIO FOREIGN KEY (id_negocio) REFERENCES negocio (id_negocio),
    CONSTRAINT FK_PEDIDO_DIRECCION FOREIGN KEY (id_direccion) REFERENCES direccion_cliente (id_direccion),
    CONSTRAINT FK_PEDIDO_MET_PAGO FOREIGN KEY (id_metodo_pago) REFERENCES metodo_pago (id_metodo_pago),
    CONSTRAINT FK_PEDIDO_EST_PED FOREIGN KEY (id_estado_pedido) REFERENCES estado_pedido (id_estado_pedido),
    CONSTRAINT FK_PEDIDO_REPARTIDOR FOREIGN KEY (id_repartidor) REFERENCES repartidor (id_repartidor),
    CONSTRAINT CH_PEDIDO_SUBTOTAL CHECK (subtotal > 0),
    CONSTRAINT CH_PEDIDO_MONTOS CHECK (costo_envio >= 0 AND cargo_anterior >= 0 AND distancia_km >= 0),
    CONSTRAINT CH_PEDIDO_TOTAL CHECK (total = subtotal + costo_envio + cargo_anterior),
    CONSTRAINT CH_PEDIDO_ZONA_ROJA CHECK (zona_roja IN ('S','N')),
    CONSTRAINT CH_PEDIDO_ESTADO_PAGO CHECK (estado_pago IN ('PENDIENTE','PAGADO','ANULADO'))
);

-- DETALLE_PEDIDO: Productos de cada pedido (una línea por producto).
CREATE TABLE detalle_pedido (
    id_pedido        NUMBER(10) NOT NULL,
    linea            NUMBER(3) NOT NULL,
    id_producto      NUMBER(10) NOT NULL,
    cantidad         NUMBER(5) NOT NULL,
    precio_unitario  NUMBER(10,2) NOT NULL,
    subtotal         NUMBER(10,2) NOT NULL,
    CONSTRAINT PK_DETALLE PRIMARY KEY (id_pedido, linea),
    CONSTRAINT FK_DETALLE_PEDIDO FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido),
    CONSTRAINT FK_DETALLE_PRODUCTO FOREIGN KEY (id_producto) REFERENCES producto (id_producto),
    CONSTRAINT CH_DETALLE_LINEA CHECK (linea > 0),
    CONSTRAINT CH_DETALLE_CANTIDAD CHECK (cantidad > 0),
    CONSTRAINT CH_DETALLE_PRECIO CHECK (precio_unitario > 0),
    CONSTRAINT CH_DETALLE_SUBTOTAL CHECK (subtotal = cantidad * precio_unitario)
);

-- PAGO: Pagos y reembolsos de los pedidos (tarjeta en línea o efectivo al recibir).
CREATE TABLE pago (
    id_pago       NUMBER(10) NOT NULL,
    id_pedido     NUMBER(10) NOT NULL,
    tipo          VARCHAR2(10) DEFAULT 'PAGO' NOT NULL,
    monto         NUMBER(10,2) NOT NULL,
    fecha_pago    DATE DEFAULT SYSDATE NOT NULL,
    ultimos4      VARCHAR2(4),
    autorizacion  VARCHAR2(20),
    CONSTRAINT PK_PAGO PRIMARY KEY (id_pago),
    CONSTRAINT FK_PAGO_PEDIDO FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido),
    CONSTRAINT CH_PAGO_TIPO CHECK (tipo IN ('PAGO','REEMBOLSO')),
    CONSTRAINT CH_PAGO_MONTO CHECK (monto > 0)
);

-- HISTORIAL_ESTADO: Historial de estados del pedido (tracking) con fecha, hora y ubicación.
CREATE TABLE historial_estado (
    id_historial      NUMBER(10) NOT NULL,
    id_pedido         NUMBER(10) NOT NULL,
    id_estado_pedido  NUMBER(10) NOT NULL,
    fecha             DATE DEFAULT SYSDATE NOT NULL,
    latitud           NUMBER(9,6),
    longitud          NUMBER(9,6),
    observacion       VARCHAR2(200),
    CONSTRAINT PK_HISTORIAL PRIMARY KEY (id_historial),
    CONSTRAINT FK_HISTORIAL_PEDIDO FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido),
    CONSTRAINT FK_HISTORIAL_EST_PED FOREIGN KEY (id_estado_pedido) REFERENCES estado_pedido (id_estado_pedido)
);

-- CANCELACION_PEDIDO: Cancelaciones hechas por el cliente dentro de los 5 minutos, con el cobro del 15 %.
CREATE TABLE cancelacion_pedido (
    id_cancelacion      NUMBER(10) NOT NULL,
    id_pedido           NUMBER(10) NOT NULL,
    id_motivo           NUMBER(10) NOT NULL,
    fecha               DATE DEFAULT SYSDATE NOT NULL,
    porcentaje          NUMBER(5,2) NOT NULL,
    monto_cobro         NUMBER(10,2) NOT NULL,
    monto_reembolso     NUMBER(10,2) DEFAULT 0 NOT NULL,
    estado_cargo        VARCHAR2(10) NOT NULL,
    id_pedido_aplicado  NUMBER(10),
    CONSTRAINT PK_CANC_PED PRIMARY KEY (id_cancelacion),
    CONSTRAINT UK_CANC_PED_PEDIDO UNIQUE (id_pedido),
    CONSTRAINT FK_CANC_PED_PEDIDO FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido),
    CONSTRAINT FK_CANC_PED_MOTIVO FOREIGN KEY (id_motivo) REFERENCES motivo_cancelacion (id_motivo),
    CONSTRAINT FK_CANC_PED_PEDIDO_APLIC FOREIGN KEY (id_pedido_aplicado) REFERENCES pedido (id_pedido),
    CONSTRAINT CH_CANC_PED_MONTOS CHECK (monto_cobro >= 0 AND monto_reembolso >= 0),
    CONSTRAINT CH_CANC_PED_ESTADO CHECK (estado_cargo IN ('COBRADO','PENDIENTE','APLICADO'))
);

-- CANCELACION_ENTREGA: Entregas canceladas por los repartidores (para el control de conductores que cancelan).
CREATE TABLE cancelacion_entrega (
    id_cancelacion_entrega  NUMBER(10) NOT NULL,
    id_pedido               NUMBER(10) NOT NULL,
    id_repartidor           NUMBER(10) NOT NULL,
    id_motivo               NUMBER(10) NOT NULL,
    fecha                   DATE DEFAULT SYSDATE NOT NULL,
    observacion             VARCHAR2(200),
    CONSTRAINT PK_CANC_ENT PRIMARY KEY (id_cancelacion_entrega),
    CONSTRAINT FK_CANC_ENT_PEDIDO FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido),
    CONSTRAINT FK_CANC_ENT_REPARTIDOR FOREIGN KEY (id_repartidor) REFERENCES repartidor (id_repartidor),
    CONSTRAINT FK_CANC_ENT_MOTIVO FOREIGN KEY (id_motivo) REFERENCES motivo_cancelacion (id_motivo)
);

-- CALIFICACION: Calificación y comentario del cliente al repartidor de un pedido entregado.
CREATE TABLE calificacion (
    id_calificacion  NUMBER(10) NOT NULL,
    id_pedido        NUMBER(10) NOT NULL,
    puntuacion       NUMBER(1) NOT NULL,
    comentario       VARCHAR2(300),
    fecha            DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT PK_CALIF PRIMARY KEY (id_calificacion),
    CONSTRAINT UK_CALIF_PEDIDO UNIQUE (id_pedido),
    CONSTRAINT FK_CALIF_PEDIDO FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido),
    CONSTRAINT CH_CALIF_PUNTUACION CHECK (puntuacion BETWEEN 1 AND 5)
);

-- NOTIFICACION: Notificaciones automáticas por SMS y WhatsApp (simuladas).
CREATE TABLE notificacion (
    id_notificacion  NUMBER(10) NOT NULL,
    id_pedido        NUMBER(10) NOT NULL,
    canal            VARCHAR2(10) NOT NULL,
    telefono         VARCHAR2(15) NOT NULL,
    mensaje          VARCHAR2(300) NOT NULL,
    fecha_envio      DATE DEFAULT SYSDATE NOT NULL,
    estado           VARCHAR2(10) DEFAULT 'ENVIADA' NOT NULL,
    CONSTRAINT PK_NOTIF PRIMARY KEY (id_notificacion),
    CONSTRAINT FK_NOTIF_PEDIDO FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido),
    CONSTRAINT CH_NOTIF_CANAL CHECK (canal IN ('SMS','WHATSAPP')),
    CONSTRAINT CH_NOTIF_ESTADO CHECK (estado IN ('ENVIADA'))
);

-- ROL: Roles de la aplicación.
CREATE TABLE rol (
    id_rol       NUMBER(10) NOT NULL,
    nombre       VARCHAR2(30) NOT NULL,
    descripcion  VARCHAR2(200),
    estado       CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_ROL PRIMARY KEY (id_rol),
    CONSTRAINT UK_ROL_NOMBRE UNIQUE (nombre),
    CONSTRAINT CH_ROL_ESTADO CHECK (estado IN ('A','I'))
);

-- MODULO: Módulos del sistema (agrupan las opciones del menú).
CREATE TABLE modulo (
    id_modulo  NUMBER(10) NOT NULL,
    nombre     VARCHAR2(40) NOT NULL,
    orden      NUMBER(2) NOT NULL,
    estado     CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_MODULO PRIMARY KEY (id_modulo),
    CONSTRAINT UK_MODULO_NOMBRE UNIQUE (nombre),
    CONSTRAINT CH_MODULO_ESTADO CHECK (estado IN ('A','I'))
);

-- MENU: Opciones del menú (páginas) de cada módulo.
CREATE TABLE menu (
    id_menu    NUMBER(10) NOT NULL,
    id_modulo  NUMBER(10) NOT NULL,
    nombre     VARCHAR2(50) NOT NULL,
    url        VARCHAR2(100) NOT NULL,
    orden      NUMBER(2) NOT NULL,
    estado     CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_MENU PRIMARY KEY (id_menu),
    CONSTRAINT UK_MENU_URL UNIQUE (url),
    CONSTRAINT FK_MENU_MODULO FOREIGN KEY (id_modulo) REFERENCES modulo (id_modulo),
    CONSTRAINT CH_MENU_ESTADO CHECK (estado IN ('A','I'))
);

-- ROL_MENU: Permisos: opciones de menú asignadas a cada rol (relación N-N).
CREATE TABLE rol_menu (
    id_rol   NUMBER(10) NOT NULL,
    id_menu  NUMBER(10) NOT NULL,
    CONSTRAINT PK_ROL_MENU PRIMARY KEY (id_rol, id_menu),
    CONSTRAINT FK_ROL_MENU_ROL FOREIGN KEY (id_rol) REFERENCES rol (id_rol),
    CONSTRAINT FK_ROL_MENU_MENU FOREIGN KEY (id_menu) REFERENCES menu (id_menu)
);

-- USUARIO: Usuarios de la aplicación con su clave encriptada.
CREATE TABLE usuario (
    id_usuario       NUMBER(10) NOT NULL,
    id_rol           NUMBER(10) NOT NULL,
    nombre_usuario   VARCHAR2(50) NOT NULL,
    clave            VARCHAR2(64) NOT NULL,
    nombre_completo  VARCHAR2(100) NOT NULL,
    id_cliente       NUMBER(10),
    id_negocio       NUMBER(10),
    id_repartidor    NUMBER(10),
    fecha_creacion   DATE DEFAULT SYSDATE NOT NULL,
    estado           CHAR(1) DEFAULT 'A' NOT NULL,
    CONSTRAINT PK_USUARIO PRIMARY KEY (id_usuario),
    CONSTRAINT UK_USUARIO_NOMBRE UNIQUE (nombre_usuario),
    CONSTRAINT UK_USUARIO_CLIENTE UNIQUE (id_cliente),
    CONSTRAINT UK_USUARIO_NEGOCIO UNIQUE (id_negocio),
    CONSTRAINT UK_USUARIO_REPARTIDOR UNIQUE (id_repartidor),
    CONSTRAINT FK_USUARIO_ROL FOREIGN KEY (id_rol) REFERENCES rol (id_rol),
    CONSTRAINT FK_USUARIO_CLIENTE FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT FK_USUARIO_NEGOCIO FOREIGN KEY (id_negocio) REFERENCES negocio (id_negocio),
    CONSTRAINT FK_USUARIO_REPARTIDOR FOREIGN KEY (id_repartidor) REFERENCES repartidor (id_repartidor),
    CONSTRAINT CH_USUARIO_ESTADO CHECK (estado IN ('A','I'))
);

-- BITACORA: Bitácora de eventos para auditoría (la llenan los triggers).
CREATE TABLE bitacora (
    id_bitacora     NUMBER(10) NOT NULL,
    usuario         VARCHAR2(50) NOT NULL,
    fecha           DATE DEFAULT SYSDATE NOT NULL,
    tabla           VARCHAR2(30) NOT NULL,
    operacion       VARCHAR2(15) NOT NULL,
    id_registro     VARCHAR2(30),
    valor_anterior  VARCHAR2(4000),
    valor_nuevo     VARCHAR2(4000),
    CONSTRAINT PK_BITACORA PRIMARY KEY (id_bitacora),
    CONSTRAINT CH_BITACORA_OPERACION CHECK (operacion IN ('INSERT','UPDATE','DELETE','LOGIN','LOGIN_FALLIDO'))
);

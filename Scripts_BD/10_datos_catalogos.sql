-- =====================================================================
-- Proyecto Final Base de Datos 1 - Sistema de Control de Delivery "Ampar"
-- Script 10: datos iniciales de los catálogos
-- Ejecutar conectado como: AMPAR
-- Estudiante: Esdras Lemuel Marroquín Rojas - Carné 3190-13-13335
-- =====================================================================
-- La llave primaria NO se escribe: la asigna la secuencia (script 02).
-- Como las tablas están vacías, los id empiezan en 1 en el orden de los INSERT.

-- ---------------------------------------------------------------------
-- Los 22 departamentos del país. Guatemala es el id 1: ahí está la
-- operación (municipios, zonas y datos de prueba). En los demás se pueden
-- agregar municipios y zonas desde los catálogos cuando Ampar crezca.
-- ---------------------------------------------------------------------
INSERT INTO departamento (nombre) VALUES ('Guatemala');        -- 1
INSERT INTO departamento (nombre) VALUES ('El Progreso');     -- 2
INSERT INTO departamento (nombre) VALUES ('Sacatepéquez');    -- 3
INSERT INTO departamento (nombre) VALUES ('Chimaltenango');   -- 4
INSERT INTO departamento (nombre) VALUES ('Escuintla');       -- 5
INSERT INTO departamento (nombre) VALUES ('Santa Rosa');      -- 6
INSERT INTO departamento (nombre) VALUES ('Sololá');          -- 7
INSERT INTO departamento (nombre) VALUES ('Totonicapán');     -- 8
INSERT INTO departamento (nombre) VALUES ('Quetzaltenango');  -- 9
INSERT INTO departamento (nombre) VALUES ('Suchitepéquez');   -- 10
INSERT INTO departamento (nombre) VALUES ('Retalhuleu');      -- 11
INSERT INTO departamento (nombre) VALUES ('San Marcos');      -- 12
INSERT INTO departamento (nombre) VALUES ('Huehuetenango');   -- 13
INSERT INTO departamento (nombre) VALUES ('Quiché');          -- 14
INSERT INTO departamento (nombre) VALUES ('Baja Verapaz');    -- 15
INSERT INTO departamento (nombre) VALUES ('Alta Verapaz');    -- 16
INSERT INTO departamento (nombre) VALUES ('Petén');           -- 17
INSERT INTO departamento (nombre) VALUES ('Izabal');          -- 18
INSERT INTO departamento (nombre) VALUES ('Zacapa');          -- 19
INSERT INTO departamento (nombre) VALUES ('Chiquimula');      -- 20
INSERT INTO departamento (nombre) VALUES ('Jalapa');          -- 21
INSERT INTO departamento (nombre) VALUES ('Jutiapa');         -- 22

-- ---------------------------------------------------------------------
-- Los 17 municipios del departamento de Guatemala (id 1 a 17)
-- ---------------------------------------------------------------------
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Guatemala');               -- 1
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Santa Catarina Pinula');   -- 2
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'San José Pinula');         -- 3
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'San José del Golfo');      -- 4
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Palencia');                -- 5
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Chinautla');               -- 6
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'San Pedro Ayampuc');       -- 7
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Mixco');                   -- 8
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'San Pedro Sacatepéquez');  -- 9
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'San Juan Sacatepéquez');   -- 10
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'San Raymundo');            -- 11
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Chuarrancho');             -- 12
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Fraijanes');               -- 13
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Amatitlán');               -- 14
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Villa Nueva');             -- 15
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Villa Canales');           -- 16
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'San Miguel Petapa');       -- 17

-- ---------------------------------------------------------------------
-- Zonas de la Ciudad de Guatemala (id 1 a 22)
-- Zona 1 a Zona 19 tienen id 1 a 19; Zona 21 = 20, Zona 24 = 21, Zona 25 = 22
-- ---------------------------------------------------------------------
BEGIN
    FOR v_zona IN 1 .. 19 LOOP
        INSERT INTO zona (id_municipio, nombre) VALUES (1, 'Zona ' || v_zona);
    END LOOP;
END;
/
INSERT INTO zona (id_municipio, nombre) VALUES (1, 'Zona 21');   -- 20
INSERT INTO zona (id_municipio, nombre) VALUES (1, 'Zona 24');   -- 21
INSERT INTO zona (id_municipio, nombre) VALUES (1, 'Zona 25');   -- 22

-- Zona 1 de los otros 16 municipios (id 23 a 38: municipio 2 -> zona 23 ... municipio 17 -> zona 38)
-- Ejemplos: Mixco Zona 1 = id 29, Villa Nueva Zona 1 = id 36
BEGIN
    FOR v_municipio IN 2 .. 17 LOOP
        INSERT INTO zona (id_municipio, nombre) VALUES (v_municipio, 'Zona 1');
    END LOOP;
END;
/

-- Zonas rojas (datos de prueba)
UPDATE zona SET zona_roja = 'S', observacion = 'Zona roja: alta incidencia de asaltos a repartidores (dato de prueba).'
 WHERE id_municipio = 1 AND nombre IN ('Zona 3', 'Zona 6', 'Zona 18');

-- ---------------------------------------------------------------------
-- Tipos de negocio
-- ---------------------------------------------------------------------
INSERT INTO tipo_negocio (nombre, descripcion) VALUES ('Repuestos automotrices', 'Tiendas de repuestos para carro');         -- 1
INSERT INTO tipo_negocio (nombre, descripcion) VALUES ('Repuestos de motocicleta', 'Tiendas de repuestos para moto');        -- 2
INSERT INTO tipo_negocio (nombre, descripcion) VALUES ('Restaurante', 'Restaurantes con servicio a domicilio');              -- 3
INSERT INTO tipo_negocio (nombre, descripcion) VALUES ('Comida a domicilio', 'Pequeños negocios de comida solo a domicilio'); -- 4
INSERT INTO tipo_negocio (nombre, descripcion) VALUES ('Farmacia', 'Farmacias y productos de salud');                       -- 5

-- ---------------------------------------------------------------------
-- Categorías de producto
-- ---------------------------------------------------------------------
INSERT INTO categoria_producto (nombre) VALUES ('Frenos');                  -- 1
INSERT INTO categoria_producto (nombre) VALUES ('Motor');                   -- 2
INSERT INTO categoria_producto (nombre) VALUES ('Suspensión y dirección');  -- 3
INSERT INTO categoria_producto (nombre) VALUES ('Sistema eléctrico');       -- 4
INSERT INTO categoria_producto (nombre) VALUES ('Filtros y lubricantes');   -- 5
INSERT INTO categoria_producto (nombre) VALUES ('Llantas');                 -- 6
INSERT INTO categoria_producto (nombre) VALUES ('Comida');                  -- 7
INSERT INTO categoria_producto (nombre) VALUES ('Bebidas');                 -- 8
INSERT INTO categoria_producto (nombre) VALUES ('Medicamentos');            -- 9

-- ---------------------------------------------------------------------
-- Tipos de vehículo
-- ---------------------------------------------------------------------
INSERT INTO tipo_vehiculo (nombre) VALUES ('Motocicleta');   -- 1
INSERT INTO tipo_vehiculo (nombre) VALUES ('Automóvil');     -- 2
INSERT INTO tipo_vehiculo (nombre) VALUES ('Pickup');        -- 3
INSERT INTO tipo_vehiculo (nombre) VALUES ('Bicicleta');     -- 4

-- ---------------------------------------------------------------------
-- Métodos de pago
-- ---------------------------------------------------------------------
INSERT INTO metodo_pago (nombre, usa_pasarela) VALUES ('Efectivo al recibir', 'N');   -- 1
INSERT INTO metodo_pago (nombre, usa_pasarela) VALUES ('Tarjeta en línea', 'S');      -- 2

-- ---------------------------------------------------------------------
-- Estados del pedido (el campo orden define la secuencia permitida)
-- ---------------------------------------------------------------------
INSERT INTO estado_pedido (nombre, orden) VALUES ('CONFIRMADO', 1);   -- 1
INSERT INTO estado_pedido (nombre, orden) VALUES ('ASIGNADO', 2);     -- 2
INSERT INTO estado_pedido (nombre, orden) VALUES ('RECOGIDO', 3);     -- 3
INSERT INTO estado_pedido (nombre, orden) VALUES ('EN RUTA', 4);      -- 4
INSERT INTO estado_pedido (nombre, orden) VALUES ('ENTREGADO', 5);    -- 5
INSERT INTO estado_pedido (nombre, orden) VALUES ('CANCELADO', 9);    -- 6

-- ---------------------------------------------------------------------
-- Motivos de cancelación
-- ---------------------------------------------------------------------
INSERT INTO motivo_cancelacion (descripcion, aplica_a) VALUES ('Me equivoqué en el pedido', 'CLIENTE');      -- 1
INSERT INTO motivo_cancelacion (descripcion, aplica_a) VALUES ('Ya no lo necesito', 'CLIENTE');              -- 2
INSERT INTO motivo_cancelacion (descripcion, aplica_a) VALUES ('Encontré mejor precio', 'CLIENTE');          -- 3
INSERT INTO motivo_cancelacion (descripcion, aplica_a) VALUES ('Falla del vehículo', 'REPARTIDOR');          -- 4
INSERT INTO motivo_cancelacion (descripcion, aplica_a) VALUES ('Zona de riesgo', 'REPARTIDOR');              -- 5
INSERT INTO motivo_cancelacion (descripcion, aplica_a) VALUES ('Emergencia personal', 'REPARTIDOR');         -- 6
INSERT INTO motivo_cancelacion (descripcion, aplica_a) VALUES ('No encuentro la dirección', 'REPARTIDOR');   -- 7

-- ---------------------------------------------------------------------
-- Parámetros del sistema
-- ---------------------------------------------------------------------
INSERT INTO parametro (codigo, valor, descripcion) VALUES ('PORC_CANCELACION', 15, 'Porcentaje del total que se cobra al cancelar un pedido');
INSERT INTO parametro (codigo, valor, descripcion) VALUES ('MIN_CANCELACION', 5, 'Minutos que tiene el cliente para cancelar un pedido');
INSERT INTO parametro (codigo, valor, descripcion) VALUES ('KM_LIMITE', 10, 'Distancia máxima (km) para entregar y para asignar repartidor');
INSERT INTO parametro (codigo, valor, descripcion) VALUES ('TARIFA_ENVIO', 25, 'Tarifa única de envío por pedido (Q)');
INSERT INTO parametro (codigo, valor, descripcion) VALUES ('VELOCIDAD_PROMEDIO', 25, 'Velocidad promedio del repartidor en la ciudad (km/h) para el tiempo estimado');

COMMIT;

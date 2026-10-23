-- Script 10: datos de catalogos. Ejecutar como AMPAR
INSERT INTO departamento (nombre) VALUES ('Guatemala');
INSERT INTO departamento (nombre) VALUES ('El Progreso');
INSERT INTO departamento (nombre) VALUES ('Sacatepéquez');
INSERT INTO departamento (nombre) VALUES ('Chimaltenango');
INSERT INTO departamento (nombre) VALUES ('Escuintla');
INSERT INTO departamento (nombre) VALUES ('Santa Rosa');
INSERT INTO departamento (nombre) VALUES ('Sololá');
INSERT INTO departamento (nombre) VALUES ('Totonicapán');
INSERT INTO departamento (nombre) VALUES ('Quetzaltenango');
INSERT INTO departamento (nombre) VALUES ('Suchitepéquez');
INSERT INTO departamento (nombre) VALUES ('Retalhuleu');
INSERT INTO departamento (nombre) VALUES ('San Marcos');
INSERT INTO departamento (nombre) VALUES ('Huehuetenango');
INSERT INTO departamento (nombre) VALUES ('Quiché');
INSERT INTO departamento (nombre) VALUES ('Baja Verapaz');
INSERT INTO departamento (nombre) VALUES ('Alta Verapaz');
INSERT INTO departamento (nombre) VALUES ('Petén');
INSERT INTO departamento (nombre) VALUES ('Izabal');
INSERT INTO departamento (nombre) VALUES ('Zacapa');
INSERT INTO departamento (nombre) VALUES ('Chiquimula');
INSERT INTO departamento (nombre) VALUES ('Jalapa');
INSERT INTO departamento (nombre) VALUES ('Jutiapa');

INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Guatemala');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Santa Catarina Pinula');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'San José Pinula');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'San José del Golfo');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Palencia');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Chinautla');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'San Pedro Ayampuc');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Mixco');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'San Pedro Sacatepéquez');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'San Juan Sacatepéquez');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'San Raymundo');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Chuarrancho');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Fraijanes');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Amatitlán');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Villa Nueva');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'Villa Canales');
INSERT INTO municipio (id_departamento, nombre) VALUES (1, 'San Miguel Petapa');

BEGIN
    FOR v_zona IN 1 .. 19 LOOP
        INSERT INTO zona (id_municipio, nombre) VALUES (1, 'Zona ' || v_zona);
    END LOOP;
END;
/
INSERT INTO zona (id_municipio, nombre) VALUES (1, 'Zona 21');
INSERT INTO zona (id_municipio, nombre) VALUES (1, 'Zona 24');
INSERT INTO zona (id_municipio, nombre) VALUES (1, 'Zona 25');

BEGIN
    FOR v_municipio IN 2 .. 17 LOOP
        INSERT INTO zona (id_municipio, nombre) VALUES (v_municipio, 'Zona 1');
    END LOOP;
END;
/

UPDATE zona SET zona_roja = 'S', observacion = 'Zona roja: alta incidencia de asaltos a repartidores (dato de prueba).'
 WHERE id_municipio = 1 AND nombre IN ('Zona 3', 'Zona 6', 'Zona 18');

INSERT INTO tipo_negocio (nombre, descripcion) VALUES ('Repuestos automotrices', 'Tiendas de repuestos para carro');
INSERT INTO tipo_negocio (nombre, descripcion) VALUES ('Repuestos de motocicleta', 'Tiendas de repuestos para moto');
INSERT INTO tipo_negocio (nombre, descripcion) VALUES ('Restaurante', 'Restaurantes con servicio a domicilio');
INSERT INTO tipo_negocio (nombre, descripcion) VALUES ('Comida a domicilio', 'Pequeños negocios de comida solo a domicilio');
INSERT INTO tipo_negocio (nombre, descripcion) VALUES ('Farmacia', 'Farmacias y productos de salud');

INSERT INTO categoria_producto (nombre) VALUES ('Frenos');
INSERT INTO categoria_producto (nombre) VALUES ('Motor');
INSERT INTO categoria_producto (nombre) VALUES ('Suspensión y dirección');
INSERT INTO categoria_producto (nombre) VALUES ('Sistema eléctrico');
INSERT INTO categoria_producto (nombre) VALUES ('Filtros y lubricantes');
INSERT INTO categoria_producto (nombre) VALUES ('Llantas');
INSERT INTO categoria_producto (nombre) VALUES ('Comida');
INSERT INTO categoria_producto (nombre) VALUES ('Bebidas');
INSERT INTO categoria_producto (nombre) VALUES ('Medicamentos');

INSERT INTO tipo_vehiculo (nombre) VALUES ('Motocicleta');
INSERT INTO tipo_vehiculo (nombre) VALUES ('Automóvil');
INSERT INTO tipo_vehiculo (nombre) VALUES ('Pickup');
INSERT INTO tipo_vehiculo (nombre) VALUES ('Bicicleta');

INSERT INTO metodo_pago (nombre, usa_pasarela) VALUES ('Efectivo al recibir', 'N');
INSERT INTO metodo_pago (nombre, usa_pasarela) VALUES ('Tarjeta en línea', 'S');

INSERT INTO estado_pedido (nombre, orden) VALUES ('CONFIRMADO', 1);
INSERT INTO estado_pedido (nombre, orden) VALUES ('ASIGNADO', 2);
INSERT INTO estado_pedido (nombre, orden) VALUES ('RECOGIDO', 3);
INSERT INTO estado_pedido (nombre, orden) VALUES ('EN RUTA', 4);
INSERT INTO estado_pedido (nombre, orden) VALUES ('ENTREGADO', 5);
INSERT INTO estado_pedido (nombre, orden) VALUES ('CANCELADO', 9);

INSERT INTO motivo_cancelacion (descripcion, aplica_a) VALUES ('Me equivoqué en el pedido', 'CLIENTE');
INSERT INTO motivo_cancelacion (descripcion, aplica_a) VALUES ('Ya no lo necesito', 'CLIENTE');
INSERT INTO motivo_cancelacion (descripcion, aplica_a) VALUES ('Encontré mejor precio', 'CLIENTE');
INSERT INTO motivo_cancelacion (descripcion, aplica_a) VALUES ('Falla del vehículo', 'REPARTIDOR');
INSERT INTO motivo_cancelacion (descripcion, aplica_a) VALUES ('Zona de riesgo', 'REPARTIDOR');
INSERT INTO motivo_cancelacion (descripcion, aplica_a) VALUES ('Emergencia personal', 'REPARTIDOR');
INSERT INTO motivo_cancelacion (descripcion, aplica_a) VALUES ('No encuentro la dirección', 'REPARTIDOR');

INSERT INTO parametro (codigo, valor, descripcion) VALUES ('PORC_CANCELACION', 15, 'Porcentaje del total que se cobra al cancelar un pedido');
INSERT INTO parametro (codigo, valor, descripcion) VALUES ('MIN_CANCELACION', 5, 'Minutos que tiene el cliente para cancelar un pedido');
INSERT INTO parametro (codigo, valor, descripcion) VALUES ('KM_LIMITE', 10, 'Distancia máxima (km) para entregar y para asignar repartidor');
INSERT INTO parametro (codigo, valor, descripcion) VALUES ('TARIFA_ENVIO', 25, 'Tarifa única de envío por pedido (Q)');
INSERT INTO parametro (codigo, valor, descripcion) VALUES ('VELOCIDAD_PROMEDIO', 25, 'Velocidad promedio del repartidor en la ciudad (km/h) para el tiempo estimado');

COMMIT;

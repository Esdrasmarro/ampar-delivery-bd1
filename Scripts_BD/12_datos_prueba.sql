-- Script 12: datos de prueba. Ejecutar como AMPAR
INSERT INTO negocio (id_tipo_negocio, id_zona, nombre, nit, propietario, telefono, correo, direccion, latitud, longitud, radio_cobertura_km, estado)
VALUES (1, 1, 'Repuestos El Pistón', '1234567-1', 'Roberto García', '22301001', 'elpiston@ampar.com', '6a. Avenida 15-20, Zona 1', 14.640700, -90.513300, 10, 'ACTIVO');
INSERT INTO negocio (id_tipo_negocio, id_zona, nombre, nit, propietario, telefono, correo, direccion, latitud, longitud, radio_cobertura_km, estado)
VALUES (1, 11, 'AutoPartes La Bujía', '2345678-2', 'Claudia Ramírez', '22301002', 'labujia@ampar.com', 'Calzada Roosevelt 12-50, Zona 11', 14.603000, -90.545000, 10, 'ACTIVO');
INSERT INTO negocio (id_tipo_negocio, id_zona, nombre, nit, propietario, telefono, correo, direccion, latitud, longitud, radio_cobertura_km, estado)
VALUES (2, 12, 'Moto Repuestos Veloz', '3456789-3', 'Mario Cifuentes', '22301003', 'veloz@ampar.com', 'Avenida Petapa 40-15, Zona 12', 14.582000, -90.530000, 10, 'ACTIVO');
INSERT INTO negocio (id_tipo_negocio, id_zona, nombre, nit, propietario, telefono, correo, direccion, latitud, longitud, radio_cobertura_km, estado)
VALUES (1, 18, 'Repuestos y Accesorios del Norte', '4567890-4', 'Hugo Barrios', '22301004', 'delnorte@ampar.com', 'Colonia El Paraíso, Zona 18', 14.660000, -90.490000, 8, 'ACTIVO');
INSERT INTO negocio (id_tipo_negocio, id_zona, nombre, nit, propietario, telefono, correo, direccion, latitud, longitud, radio_cobertura_km, estado)
VALUES (3, 10, 'Pollo Dorado Express', '5678901-5', 'Andrea Solís', '22301005', 'pollodorado@ampar.com', '2a. Avenida 13-40, Zona 10', 14.599500, -90.508000, 6, 'ACTIVO');
INSERT INTO negocio (id_tipo_negocio, id_zona, nombre, nit, propietario, telefono, correo, direccion, latitud, longitud, radio_cobertura_km, estado)
VALUES (4, 7, 'Comedor Doña Chepita', '6789012-6', 'Josefina Pérez', '22301006', 'chepita@ampar.com', '30 Avenida 5-10, Colonia Kaminal Juyú, Zona 7', 14.637000, -90.548000, 5, 'ACTIVO');
INSERT INTO negocio (id_tipo_negocio, id_zona, nombre, nit, propietario, telefono, correo, direccion, latitud, longitud, radio_cobertura_km, estado)
VALUES (5, 29, 'Farmacia Buena Salud', '7890123-7', 'Luis Monterroso', '22301007', 'buenasalud@ampar.com', 'Calzada Roosevelt km 14, Mixco', 14.633000, -90.606400, 10, 'PENDIENTE');

BEGIN
    FOR v_dia IN 1 .. 7 LOOP
        INSERT INTO horario_negocio (id_negocio, dia_semana, hora_apertura, hora_cierre, hace_entrega)
        VALUES (1, v_dia, '00:00', '23:59', 'S');

        INSERT INTO horario_negocio (id_negocio, dia_semana, hora_apertura, hora_cierre, hace_entrega)
        VALUES (2, v_dia, '07:00', '19:00', CASE WHEN v_dia = 7 THEN 'N' ELSE 'S' END);

        INSERT INTO horario_negocio (id_negocio, dia_semana, hora_apertura, hora_cierre, hace_entrega)
        VALUES (3, v_dia, '08:00', '20:00', 'S');

        INSERT INTO horario_negocio (id_negocio, dia_semana, hora_apertura, hora_cierre, hace_entrega)
        VALUES (4, v_dia, '08:00', '18:00', CASE WHEN v_dia = 7 THEN 'N' ELSE 'S' END);

        INSERT INTO horario_negocio (id_negocio, dia_semana, hora_apertura, hora_cierre, hace_entrega)
        VALUES (5, v_dia, '10:00', '22:00', 'S');

        INSERT INTO horario_negocio (id_negocio, dia_semana, hora_apertura, hora_cierre, hace_entrega)
        VALUES (6, v_dia, '07:00', '15:00', CASE WHEN v_dia >= 6 THEN 'N' ELSE 'S' END);
    END LOOP;
END;
/

INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (1, 1, 'Pastillas de freno delanteras', 'Juego de 4 pastillas, cerámica', 285.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (1, 1, 'Disco de freno ventilado', 'Disco delantero 256 mm', 450.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (1, 5, 'Filtro de aceite', 'Rosca 3/4-16', 65.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (1, 5, 'Aceite de motor 20W-50 galón', 'Aceite mineral, 1 galón', 210.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (1, 4, 'Bujía de iridio', 'Unidad', 95.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (1, 4, 'Batería 12V 45Ah', 'Libre de mantenimiento, 12 meses de garantía', 895.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (1, 3, 'Amortiguador delantero', 'Unidad, tipo gas', 520.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (2, 2, 'Banda de distribución', 'Kit con tensor', 340.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (2, 2, 'Bomba de agua', 'Con empaque', 610.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (2, 4, 'Faro delantero', 'Lado izquierdo', 760.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (2, 5, 'Filtro de aire', 'Panel', 90.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (2, 6, 'Llanta 185/65 R15', 'Radial', 725.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (3, 2, 'Kit de arrastre', 'Cadena, piñón y catalina', 395.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (3, 1, 'Pastillas de freno para moto', 'Juego delantero', 120.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (3, 6, 'Llanta para moto 90/90-17', 'Uso urbano', 340.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (3, 5, 'Aceite 4T litro', 'Para motor de 4 tiempos', 75.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (3, 4, 'Batería para moto 12V', '7 Ah', 310.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (4, 3, 'Terminal de dirección', 'Unidad', 180.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (4, 4, 'Bombilla H4', '12V 60/55W', 45.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (4, 4, 'Fusibles surtidos', 'Caja de 40 piezas', 35.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (4, 1, 'Líquido de frenos DOT4', 'Medio litro', 60.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (5, 7, 'Combo 2 piezas', 'Pollo, papas y refresco', 45.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (5, 7, 'Combo familiar 8 piezas', 'Pollo, papas grandes y refresco 1.5 L', 155.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (5, 7, 'Papas grandes', 'Porción grande', 22.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (5, 8, 'Refresco 1.5 litros', 'Sabor a elección', 18.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (6, 7, 'Almuerzo del día', 'Plato del día con tortillas y bebida', 35.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (6, 7, 'Pepián de pollo', 'Con arroz y tortillas', 45.00);
INSERT INTO producto (id_negocio, id_categoria, nombre, descripcion, precio) VALUES (6, 8, 'Licuado de fruta', 'Vaso de 16 oz', 15.00);

INSERT INTO cliente (nombres, apellidos, telefono, correo) VALUES ('Ana Lucía', 'Pérez López', '55510001', 'ana.perez@correo.com');
INSERT INTO cliente (nombres, apellidos, telefono, correo) VALUES ('Carlos Eduardo', 'Méndez Ruiz', '55510002', 'carlos.mendez@correo.com');
INSERT INTO cliente (nombres, apellidos, telefono, correo) VALUES ('María José', 'Gómez Castañeda', '55510003', 'maria.gomez@correo.com');
INSERT INTO cliente (nombres, apellidos, telefono, correo) VALUES ('José Luis', 'Ramírez Oliva', '55510004', 'jose.ramirez@correo.com');
INSERT INTO cliente (nombres, apellidos, telefono, correo) VALUES ('Sofía Alejandra', 'Castillo Paz', '55510005', 'sofia.castillo@correo.com');
INSERT INTO cliente (nombres, apellidos, telefono, correo) VALUES ('Diego Andrés', 'Herrera Sosa', '55510006', 'diego.herrera@correo.com');
INSERT INTO cliente (nombres, apellidos, telefono, correo) VALUES ('Laura Beatriz', 'Morales Díaz', '55510007', 'laura.morales@correo.com');

INSERT INTO direccion_cliente (id_cliente, id_zona, nombre, direccion, referencia, latitud, longitud)
VALUES (1, 10, 'Casa', '5a. Avenida 10-25, Zona 10', 'Edificio blanco, apto. 302', 14.600000, -90.512000);
INSERT INTO direccion_cliente (id_cliente, id_zona, nombre, direccion, referencia, latitud, longitud)
VALUES (2, 1, 'Casa', '10a. Calle 8-40, Zona 1', 'Portón negro', 14.638000, -90.515000);
INSERT INTO direccion_cliente (id_cliente, id_zona, nombre, direccion, referencia, latitud, longitud)
VALUES (2, 4, 'Trabajo', 'Vía 5 4-50, Zona 4', 'Oficina 2do. nivel', 14.623000, -90.515000);
INSERT INTO direccion_cliente (id_cliente, id_zona, nombre, direccion, referencia, latitud, longitud)
VALUES (3, 18, 'Casa', 'Colonia Lavarreda, Zona 18', 'Frente a la escuela', 14.662000, -90.488000);
INSERT INTO direccion_cliente (id_cliente, id_zona, nombre, direccion, referencia, latitud, longitud)
VALUES (4, 12, 'Casa', 'Colonia La Reformita, Zona 12', 'Casa esquina', 14.580000, -90.533000);
INSERT INTO direccion_cliente (id_cliente, id_zona, nombre, direccion, referencia, latitud, longitud)
VALUES (5, 7, 'Casa', 'Colonia Kaminal Juyú, Zona 7', 'Casa verde', 14.640000, -90.550000);
INSERT INTO direccion_cliente (id_cliente, id_zona, nombre, direccion, referencia, latitud, longitud)
VALUES (6, 6, 'Casa', 'Colonia Cipresales, Zona 6', 'Por la tienda', 14.654000, -90.507000);
INSERT INTO direccion_cliente (id_cliente, id_zona, nombre, direccion, referencia, latitud, longitud)
VALUES (7, 29, 'Casa', 'Colonia El Milagro, Mixco', 'Casa de dos niveles', 14.630000, -90.600000);
INSERT INTO direccion_cliente (id_cliente, id_zona, nombre, direccion, referencia, latitud, longitud)
VALUES (7, 36, 'Trabajo', 'Centro de Villa Nueva', 'Fuera de cobertura (más de 10 km)', 14.525000, -90.588000);

INSERT INTO repartidor (id_tipo_vehiculo, nombres, apellidos, dpi, telefono, licencia, placa, latitud, longitud, fecha_ubicacion)
VALUES (1, 'Pedro', 'Xicará Tum', '2501123450101', '44410001', 'M-250112345', 'M123ABC', 14.635000, -90.514000, SYSDATE);
INSERT INTO repartidor (id_tipo_vehiculo, nombres, apellidos, dpi, telefono, licencia, placa, latitud, longitud, fecha_ubicacion)
VALUES (1, 'Juan', 'Ajú Pérez', '2502234560101', '44410002', 'M-250223456', 'M234BCD', 14.605000, -90.515000, SYSDATE);
INSERT INTO repartidor (id_tipo_vehiculo, nombres, apellidos, dpi, telefono, licencia, placa, latitud, longitud, fecha_ubicacion)
VALUES (2, 'Luis', 'Coc Caal', '2503345670101', '44410003', 'B-250334567', 'P345CDE', 14.585000, -90.525000, SYSDATE);
INSERT INTO repartidor (id_tipo_vehiculo, nombres, apellidos, dpi, telefono, licencia, placa, latitud, longitud, fecha_ubicacion)
VALUES (1, 'Marcos', 'Tzoc Ixcoy', '2504456780101', '44410004', 'M-250445678', 'M456DEF', 14.655000, -90.495000, SYSDATE);
INSERT INTO repartidor (id_tipo_vehiculo, nombres, apellidos, dpi, telefono, licencia, placa, latitud, longitud, fecha_ubicacion)
VALUES (1, 'Kevin', 'Morales Lima', '2505567890101', '44410005', 'M-250556789', 'M567EFG', 14.628000, -90.542000, SYSDATE);
INSERT INTO repartidor (id_tipo_vehiculo, nombres, apellidos, dpi, telefono, licencia, placa, latitud, longitud, fecha_ubicacion)
VALUES (4, 'Erick', 'Pop Choc', '2506678900101', '44410006', 'C-250667890', NULL, 14.600000, -90.505000, SYSDATE);
INSERT INTO repartidor (id_tipo_vehiculo, nombres, apellidos, dpi, telefono, licencia, placa, latitud, longitud, fecha_ubicacion)
VALUES (3, 'Josué', 'Chávez Orellana', '2507789010101', '44410007', 'A-250778901', 'P789GHI', 14.570000, -90.540000, SYSDATE);
INSERT INTO repartidor (id_tipo_vehiculo, nombres, apellidos, dpi, telefono, licencia, placa, latitud, longitud, fecha_ubicacion)
VALUES (1, 'Brayan', 'López Ajanel', '2508890120101', '44410008', 'M-250889012', 'M890HIJ', 14.645000, -90.470000, SYSDATE);

BEGIN
    FOR n IN (SELECT id_negocio, correo, nombre FROM negocio WHERE estado = 'ACTIVO') LOOP
        INSERT INTO usuario (id_rol, nombre_usuario, clave, nombre_completo, id_negocio)
        VALUES (3, n.correo, fn_encriptar('Ampar2026'), n.nombre, n.id_negocio);
    END LOOP;

    FOR r IN (SELECT id_repartidor, nombres, apellidos FROM repartidor) LOOP
        INSERT INTO usuario (id_rol, nombre_usuario, clave, nombre_completo, id_repartidor)
        VALUES (4, 'repartidor' || r.id_repartidor, fn_encriptar('Ampar2026'),
                r.nombres || ' ' || r.apellidos, r.id_repartidor);
    END LOOP;

    FOR c IN (SELECT id_cliente, correo, nombres, apellidos FROM cliente) LOOP
        INSERT INTO usuario (id_rol, nombre_usuario, clave, nombre_completo, id_cliente)
        VALUES (5, c.correo, fn_encriptar('Ampar2026'), c.nombres || ' ' || c.apellidos, c.id_cliente);
    END LOOP;
END;
/

COMMIT;

DECLARE
    v_id_pedido  NUMBER;
    v_direccion  NUMBER;
    v_cliente    NUMBER;
    v_negocio    NUMBER;
    v_repartidor NUMBER;
    v_rep_cancela NUMBER;
    v_metodo     NUMBER;
    v_estado     NUMBER;
    v_prod1      NUMBER;
    v_prod2      NUMBER;
    v_precio1    NUMBER;
    v_precio2    NUMBER;
    v_cant1      NUMBER;
    v_subtotal   NUMBER;
    v_total      NUMBER;
    v_cobro      NUMBER;
    v_distancia  NUMBER;
    v_fecha      DATE;
    v_puntos     NUMBER;
BEGIN
    FOR i IN 1 .. 90 LOOP
        v_direccion := MOD(i, 8) + 1;
        v_negocio   := MOD(i * 5, 6) + 1;

        SELECT id_cliente INTO v_cliente FROM direccion_cliente WHERE id_direccion = v_direccion;

        SELECT fn_distancia_km(n.latitud, n.longitud, d.latitud, d.longitud)
          INTO v_distancia
          FROM negocio n, direccion_cliente d
         WHERE n.id_negocio = v_negocio
           AND d.id_direccion = v_direccion;

        CONTINUE WHEN v_distancia > 10;

        SELECT MIN(id_producto), MAX(id_producto) INTO v_prod1, v_prod2
          FROM producto WHERE id_negocio = v_negocio;
        SELECT precio INTO v_precio1 FROM producto WHERE id_producto = v_prod1;
        SELECT precio INTO v_precio2 FROM producto WHERE id_producto = v_prod2;

        v_cant1    := MOD(i, 3) + 1;
        v_subtotal := v_cant1 * v_precio1 + v_precio2;
        v_total    := v_subtotal + 25;

        v_repartidor := CASE WHEN MOD(i, 5) = 0 THEN 1
                             WHEN MOD(i, 4) = 0 THEN 4
                             ELSE MOD(i, 8) + 1 END;

        IF MOD(i, 9) = 0 THEN
            v_estado := 6;
            v_metodo := 2;
        ELSE
            v_estado := 5;
            v_metodo := MOD(i, 2) + 1;
        END IF;

        v_fecha := TRUNC(SYSDATE) - MOD(i * 7, 30) - 1 + (10 + MOD(i, 9)) / 24;

        INSERT INTO pedido (id_cliente, id_negocio, id_direccion, id_metodo_pago, id_estado_pedido,
                            id_repartidor, fecha_pedido, subtotal, costo_envio, cargo_anterior, total,
                            distancia_km, estado_pago)
        VALUES (v_cliente, v_negocio, v_direccion, v_metodo, v_estado,
                CASE WHEN v_estado = 5 THEN v_repartidor END, v_fecha, v_subtotal, 25, 0, v_total,
                v_distancia, 'PAGADO')
        RETURNING id_pedido INTO v_id_pedido;

        INSERT INTO detalle_pedido (id_pedido, linea, id_producto, cantidad, precio_unitario, subtotal)
        VALUES (v_id_pedido, 1, v_prod1, v_cant1, v_precio1, v_cant1 * v_precio1);
        INSERT INTO detalle_pedido (id_pedido, linea, id_producto, cantidad, precio_unitario, subtotal)
        VALUES (v_id_pedido, 2, v_prod2, 1, v_precio2, v_precio2);

        INSERT INTO pago (id_pedido, tipo, monto, fecha_pago, ultimos4, autorizacion)
        VALUES (v_id_pedido, 'PAGO', v_total, v_fecha + 1/24,
                CASE WHEN v_metodo = 2 THEN '1111' END,
                CASE WHEN v_metodo = 2 THEN 'AUT-HIST-' || i END);

        IF v_estado = 6 THEN
            v_cobro := ROUND(v_total * 15 / 100, 2);
            INSERT INTO cancelacion_pedido (id_pedido, id_motivo, fecha, porcentaje, monto_cobro, monto_reembolso, estado_cargo)
            VALUES (v_id_pedido, MOD(i, 3) + 1, v_fecha + 3/1440, 15, v_cobro, v_total - v_cobro, 'COBRADO');
            INSERT INTO pago (id_pedido, tipo, monto, fecha_pago)
            VALUES (v_id_pedido, 'REEMBOLSO', v_total - v_cobro, v_fecha + 3/1440);
        ELSE
            IF MOD(i, 4) <> 3 THEN
                v_puntos := CASE WHEN v_repartidor = 7 THEN 2 + MOD(i, 2) ELSE 4 + MOD(i, 2) END;
                INSERT INTO calificacion (id_pedido, puntuacion, comentario, fecha)
                VALUES (v_id_pedido, v_puntos,
                        CASE v_puntos WHEN 5 THEN 'Excelente servicio, muy rápido.'
                                      WHEN 4 THEN 'Buen servicio.'
                                      WHEN 3 THEN 'Llegó tarde.'
                                      ELSE 'El pedido llegó tarde y el repartidor fue descortés.' END,
                        v_fecha + 2/24);
            END IF;

            IF MOD(i, 6) = 0 OR MOD(i, 7) = 0 THEN
                v_rep_cancela := CASE WHEN MOD(i, 2) = 0 THEN 7 ELSE 3 END;
                IF v_rep_cancela = v_repartidor THEN
                    v_rep_cancela := 8;
                END IF;
                INSERT INTO cancelacion_entrega (id_pedido, id_repartidor, id_motivo, fecha, observacion)
                VALUES (v_id_pedido, v_rep_cancela, 4 + MOD(i, 4), v_fecha + 10/1440, 'Dato de prueba');
            END IF;
        END IF;

        UPDATE historial_estado SET fecha = v_fecha + 1/24 WHERE id_pedido = v_id_pedido;
        UPDATE notificacion SET fecha_envio = v_fecha + 1/24 WHERE id_pedido = v_id_pedido;
    END LOOP;

    COMMIT;
END;
/

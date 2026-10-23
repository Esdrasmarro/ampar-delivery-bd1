-- Script 05: triggers de bitacora. Ejecutar como AMPAR
CREATE OR REPLACE TRIGGER TRG_BIT_ZONA
AFTER INSERT OR UPDATE OR DELETE ON zona
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_zona;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_zona;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_zona;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_zona=' || :OLD.id_zona || '; ' ||
                      'id_municipio=' || :OLD.id_municipio || '; ' ||
                      'nombre=' || :OLD.nombre || '; ' ||
                      'zona_roja=' || :OLD.zona_roja || '; ' ||
                      'observacion=' || :OLD.observacion || '; ' ||
                      'estado=' || :OLD.estado;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_zona=' || :NEW.id_zona || '; ' ||
                      'id_municipio=' || :NEW.id_municipio || '; ' ||
                      'nombre=' || :NEW.nombre || '; ' ||
                      'zona_roja=' || :NEW.zona_roja || '; ' ||
                      'observacion=' || :NEW.observacion || '; ' ||
                      'estado=' || :NEW.estado;
    END IF;

    pr_bitacora('ZONA', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_ZONA;
/

CREATE OR REPLACE TRIGGER TRG_BIT_NEGOCIO
AFTER INSERT OR UPDATE OR DELETE ON negocio
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_negocio;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_negocio;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_negocio;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_negocio=' || :OLD.id_negocio || '; ' ||
                      'id_tipo_negocio=' || :OLD.id_tipo_negocio || '; ' ||
                      'id_zona=' || :OLD.id_zona || '; ' ||
                      'nombre=' || :OLD.nombre || '; ' ||
                      'nit=' || :OLD.nit || '; ' ||
                      'propietario=' || :OLD.propietario || '; ' ||
                      'telefono=' || :OLD.telefono || '; ' ||
                      'correo=' || :OLD.correo || '; ' ||
                      'direccion=' || :OLD.direccion || '; ' ||
                      'latitud=' || :OLD.latitud || '; ' ||
                      'longitud=' || :OLD.longitud || '; ' ||
                      'radio_cobertura_km=' || :OLD.radio_cobertura_km || '; ' ||
                      'estado=' || :OLD.estado || '; ' ||
                      'fecha_registro=' || :OLD.fecha_registro;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_negocio=' || :NEW.id_negocio || '; ' ||
                      'id_tipo_negocio=' || :NEW.id_tipo_negocio || '; ' ||
                      'id_zona=' || :NEW.id_zona || '; ' ||
                      'nombre=' || :NEW.nombre || '; ' ||
                      'nit=' || :NEW.nit || '; ' ||
                      'propietario=' || :NEW.propietario || '; ' ||
                      'telefono=' || :NEW.telefono || '; ' ||
                      'correo=' || :NEW.correo || '; ' ||
                      'direccion=' || :NEW.direccion || '; ' ||
                      'latitud=' || :NEW.latitud || '; ' ||
                      'longitud=' || :NEW.longitud || '; ' ||
                      'radio_cobertura_km=' || :NEW.radio_cobertura_km || '; ' ||
                      'estado=' || :NEW.estado || '; ' ||
                      'fecha_registro=' || :NEW.fecha_registro;
    END IF;

    pr_bitacora('NEGOCIO', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_NEGOCIO;
/

CREATE OR REPLACE TRIGGER TRG_BIT_HORARIO
AFTER INSERT OR UPDATE OR DELETE ON horario_negocio
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_horario;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_horario;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_horario;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_horario=' || :OLD.id_horario || '; ' ||
                      'id_negocio=' || :OLD.id_negocio || '; ' ||
                      'dia_semana=' || :OLD.dia_semana || '; ' ||
                      'hora_apertura=' || :OLD.hora_apertura || '; ' ||
                      'hora_cierre=' || :OLD.hora_cierre || '; ' ||
                      'hace_entrega=' || :OLD.hace_entrega;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_horario=' || :NEW.id_horario || '; ' ||
                      'id_negocio=' || :NEW.id_negocio || '; ' ||
                      'dia_semana=' || :NEW.dia_semana || '; ' ||
                      'hora_apertura=' || :NEW.hora_apertura || '; ' ||
                      'hora_cierre=' || :NEW.hora_cierre || '; ' ||
                      'hace_entrega=' || :NEW.hace_entrega;
    END IF;

    pr_bitacora('HORARIO_NEGOCIO', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_HORARIO;
/

CREATE OR REPLACE TRIGGER TRG_BIT_PRODUCTO
AFTER INSERT OR UPDATE OR DELETE ON producto
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_producto;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_producto;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_producto;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_producto=' || :OLD.id_producto || '; ' ||
                      'id_negocio=' || :OLD.id_negocio || '; ' ||
                      'id_categoria=' || :OLD.id_categoria || '; ' ||
                      'nombre=' || :OLD.nombre || '; ' ||
                      'descripcion=' || :OLD.descripcion || '; ' ||
                      'precio=' || :OLD.precio || '; ' ||
                      'disponible=' || :OLD.disponible || '; ' ||
                      'estado=' || :OLD.estado;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_producto=' || :NEW.id_producto || '; ' ||
                      'id_negocio=' || :NEW.id_negocio || '; ' ||
                      'id_categoria=' || :NEW.id_categoria || '; ' ||
                      'nombre=' || :NEW.nombre || '; ' ||
                      'descripcion=' || :NEW.descripcion || '; ' ||
                      'precio=' || :NEW.precio || '; ' ||
                      'disponible=' || :NEW.disponible || '; ' ||
                      'estado=' || :NEW.estado;
    END IF;

    pr_bitacora('PRODUCTO', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_PRODUCTO;
/

CREATE OR REPLACE TRIGGER TRG_BIT_CLIENTE
AFTER INSERT OR UPDATE OR DELETE ON cliente
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_cliente;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_cliente;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_cliente;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_cliente=' || :OLD.id_cliente || '; ' ||
                      'nombres=' || :OLD.nombres || '; ' ||
                      'apellidos=' || :OLD.apellidos || '; ' ||
                      'telefono=' || :OLD.telefono || '; ' ||
                      'correo=' || :OLD.correo || '; ' ||
                      'fecha_registro=' || :OLD.fecha_registro || '; ' ||
                      'estado=' || :OLD.estado;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_cliente=' || :NEW.id_cliente || '; ' ||
                      'nombres=' || :NEW.nombres || '; ' ||
                      'apellidos=' || :NEW.apellidos || '; ' ||
                      'telefono=' || :NEW.telefono || '; ' ||
                      'correo=' || :NEW.correo || '; ' ||
                      'fecha_registro=' || :NEW.fecha_registro || '; ' ||
                      'estado=' || :NEW.estado;
    END IF;

    pr_bitacora('CLIENTE', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_CLIENTE;
/

CREATE OR REPLACE TRIGGER TRG_BIT_DIRECCION
AFTER INSERT OR UPDATE OR DELETE ON direccion_cliente
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_direccion;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_direccion;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_direccion;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_direccion=' || :OLD.id_direccion || '; ' ||
                      'id_cliente=' || :OLD.id_cliente || '; ' ||
                      'id_zona=' || :OLD.id_zona || '; ' ||
                      'nombre=' || :OLD.nombre || '; ' ||
                      'direccion=' || :OLD.direccion || '; ' ||
                      'referencia=' || :OLD.referencia || '; ' ||
                      'latitud=' || :OLD.latitud || '; ' ||
                      'longitud=' || :OLD.longitud || '; ' ||
                      'estado=' || :OLD.estado;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_direccion=' || :NEW.id_direccion || '; ' ||
                      'id_cliente=' || :NEW.id_cliente || '; ' ||
                      'id_zona=' || :NEW.id_zona || '; ' ||
                      'nombre=' || :NEW.nombre || '; ' ||
                      'direccion=' || :NEW.direccion || '; ' ||
                      'referencia=' || :NEW.referencia || '; ' ||
                      'latitud=' || :NEW.latitud || '; ' ||
                      'longitud=' || :NEW.longitud || '; ' ||
                      'estado=' || :NEW.estado;
    END IF;

    pr_bitacora('DIRECCION_CLIENTE', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_DIRECCION;
/

CREATE OR REPLACE TRIGGER TRG_BIT_REPARTIDOR
AFTER INSERT OR UPDATE OR DELETE ON repartidor
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_repartidor;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_repartidor;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_repartidor;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_repartidor=' || :OLD.id_repartidor || '; ' ||
                      'id_tipo_vehiculo=' || :OLD.id_tipo_vehiculo || '; ' ||
                      'nombres=' || :OLD.nombres || '; ' ||
                      'apellidos=' || :OLD.apellidos || '; ' ||
                      'dpi=' || :OLD.dpi || '; ' ||
                      'telefono=' || :OLD.telefono || '; ' ||
                      'licencia=' || :OLD.licencia || '; ' ||
                      'placa=' || :OLD.placa || '; ' ||
                      'latitud=' || :OLD.latitud || '; ' ||
                      'longitud=' || :OLD.longitud || '; ' ||
                      'fecha_ubicacion=' || :OLD.fecha_ubicacion || '; ' ||
                      'disponible=' || :OLD.disponible || '; ' ||
                      'estado=' || :OLD.estado;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_repartidor=' || :NEW.id_repartidor || '; ' ||
                      'id_tipo_vehiculo=' || :NEW.id_tipo_vehiculo || '; ' ||
                      'nombres=' || :NEW.nombres || '; ' ||
                      'apellidos=' || :NEW.apellidos || '; ' ||
                      'dpi=' || :NEW.dpi || '; ' ||
                      'telefono=' || :NEW.telefono || '; ' ||
                      'licencia=' || :NEW.licencia || '; ' ||
                      'placa=' || :NEW.placa || '; ' ||
                      'latitud=' || :NEW.latitud || '; ' ||
                      'longitud=' || :NEW.longitud || '; ' ||
                      'fecha_ubicacion=' || :NEW.fecha_ubicacion || '; ' ||
                      'disponible=' || :NEW.disponible || '; ' ||
                      'estado=' || :NEW.estado;
    END IF;

    pr_bitacora('REPARTIDOR', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_REPARTIDOR;
/

CREATE OR REPLACE TRIGGER TRG_BIT_PARAMETRO
AFTER INSERT OR UPDATE OR DELETE ON parametro
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_parametro;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_parametro;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_parametro;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_parametro=' || :OLD.id_parametro || '; ' ||
                      'codigo=' || :OLD.codigo || '; ' ||
                      'valor=' || :OLD.valor || '; ' ||
                      'descripcion=' || :OLD.descripcion;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_parametro=' || :NEW.id_parametro || '; ' ||
                      'codigo=' || :NEW.codigo || '; ' ||
                      'valor=' || :NEW.valor || '; ' ||
                      'descripcion=' || :NEW.descripcion;
    END IF;

    pr_bitacora('PARAMETRO', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_PARAMETRO;
/

CREATE OR REPLACE TRIGGER TRG_BIT_PEDIDO
AFTER INSERT OR UPDATE OR DELETE ON pedido
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_pedido;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_pedido;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_pedido;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_pedido=' || :OLD.id_pedido || '; ' ||
                      'id_cliente=' || :OLD.id_cliente || '; ' ||
                      'id_negocio=' || :OLD.id_negocio || '; ' ||
                      'id_direccion=' || :OLD.id_direccion || '; ' ||
                      'id_metodo_pago=' || :OLD.id_metodo_pago || '; ' ||
                      'id_estado_pedido=' || :OLD.id_estado_pedido || '; ' ||
                      'id_repartidor=' || :OLD.id_repartidor || '; ' ||
                      'fecha_pedido=' || :OLD.fecha_pedido || '; ' ||
                      'subtotal=' || :OLD.subtotal || '; ' ||
                      'costo_envio=' || :OLD.costo_envio || '; ' ||
                      'cargo_anterior=' || :OLD.cargo_anterior || '; ' ||
                      'total=' || :OLD.total || '; ' ||
                      'distancia_km=' || :OLD.distancia_km || '; ' ||
                      'zona_roja=' || :OLD.zona_roja || '; ' ||
                      'estado_pago=' || :OLD.estado_pago;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_pedido=' || :NEW.id_pedido || '; ' ||
                      'id_cliente=' || :NEW.id_cliente || '; ' ||
                      'id_negocio=' || :NEW.id_negocio || '; ' ||
                      'id_direccion=' || :NEW.id_direccion || '; ' ||
                      'id_metodo_pago=' || :NEW.id_metodo_pago || '; ' ||
                      'id_estado_pedido=' || :NEW.id_estado_pedido || '; ' ||
                      'id_repartidor=' || :NEW.id_repartidor || '; ' ||
                      'fecha_pedido=' || :NEW.fecha_pedido || '; ' ||
                      'subtotal=' || :NEW.subtotal || '; ' ||
                      'costo_envio=' || :NEW.costo_envio || '; ' ||
                      'cargo_anterior=' || :NEW.cargo_anterior || '; ' ||
                      'total=' || :NEW.total || '; ' ||
                      'distancia_km=' || :NEW.distancia_km || '; ' ||
                      'zona_roja=' || :NEW.zona_roja || '; ' ||
                      'estado_pago=' || :NEW.estado_pago;
    END IF;

    pr_bitacora('PEDIDO', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_PEDIDO;
/

CREATE OR REPLACE TRIGGER TRG_BIT_DETALLE
AFTER INSERT OR UPDATE OR DELETE ON detalle_pedido
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_pedido || '-' || :NEW.linea;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_pedido || '-' || :NEW.linea;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_pedido || '-' || :OLD.linea;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_pedido=' || :OLD.id_pedido || '; ' ||
                      'linea=' || :OLD.linea || '; ' ||
                      'id_producto=' || :OLD.id_producto || '; ' ||
                      'cantidad=' || :OLD.cantidad || '; ' ||
                      'precio_unitario=' || :OLD.precio_unitario || '; ' ||
                      'subtotal=' || :OLD.subtotal;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_pedido=' || :NEW.id_pedido || '; ' ||
                      'linea=' || :NEW.linea || '; ' ||
                      'id_producto=' || :NEW.id_producto || '; ' ||
                      'cantidad=' || :NEW.cantidad || '; ' ||
                      'precio_unitario=' || :NEW.precio_unitario || '; ' ||
                      'subtotal=' || :NEW.subtotal;
    END IF;

    pr_bitacora('DETALLE_PEDIDO', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_DETALLE;
/

CREATE OR REPLACE TRIGGER TRG_BIT_PAGO
AFTER INSERT OR UPDATE OR DELETE ON pago
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_pago;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_pago;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_pago;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_pago=' || :OLD.id_pago || '; ' ||
                      'id_pedido=' || :OLD.id_pedido || '; ' ||
                      'tipo=' || :OLD.tipo || '; ' ||
                      'monto=' || :OLD.monto || '; ' ||
                      'fecha_pago=' || :OLD.fecha_pago || '; ' ||
                      'ultimos4=' || :OLD.ultimos4 || '; ' ||
                      'autorizacion=' || :OLD.autorizacion;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_pago=' || :NEW.id_pago || '; ' ||
                      'id_pedido=' || :NEW.id_pedido || '; ' ||
                      'tipo=' || :NEW.tipo || '; ' ||
                      'monto=' || :NEW.monto || '; ' ||
                      'fecha_pago=' || :NEW.fecha_pago || '; ' ||
                      'ultimos4=' || :NEW.ultimos4 || '; ' ||
                      'autorizacion=' || :NEW.autorizacion;
    END IF;

    pr_bitacora('PAGO', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_PAGO;
/

CREATE OR REPLACE TRIGGER TRG_BIT_CANC_PED
AFTER INSERT OR UPDATE OR DELETE ON cancelacion_pedido
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_cancelacion;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_cancelacion;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_cancelacion;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_cancelacion=' || :OLD.id_cancelacion || '; ' ||
                      'id_pedido=' || :OLD.id_pedido || '; ' ||
                      'id_motivo=' || :OLD.id_motivo || '; ' ||
                      'fecha=' || :OLD.fecha || '; ' ||
                      'porcentaje=' || :OLD.porcentaje || '; ' ||
                      'monto_cobro=' || :OLD.monto_cobro || '; ' ||
                      'monto_reembolso=' || :OLD.monto_reembolso || '; ' ||
                      'estado_cargo=' || :OLD.estado_cargo || '; ' ||
                      'id_pedido_aplicado=' || :OLD.id_pedido_aplicado;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_cancelacion=' || :NEW.id_cancelacion || '; ' ||
                      'id_pedido=' || :NEW.id_pedido || '; ' ||
                      'id_motivo=' || :NEW.id_motivo || '; ' ||
                      'fecha=' || :NEW.fecha || '; ' ||
                      'porcentaje=' || :NEW.porcentaje || '; ' ||
                      'monto_cobro=' || :NEW.monto_cobro || '; ' ||
                      'monto_reembolso=' || :NEW.monto_reembolso || '; ' ||
                      'estado_cargo=' || :NEW.estado_cargo || '; ' ||
                      'id_pedido_aplicado=' || :NEW.id_pedido_aplicado;
    END IF;

    pr_bitacora('CANCELACION_PEDIDO', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_CANC_PED;
/

CREATE OR REPLACE TRIGGER TRG_BIT_CANC_ENT
AFTER INSERT OR UPDATE OR DELETE ON cancelacion_entrega
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_cancelacion_entrega;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_cancelacion_entrega;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_cancelacion_entrega;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_cancelacion_entrega=' || :OLD.id_cancelacion_entrega || '; ' ||
                      'id_pedido=' || :OLD.id_pedido || '; ' ||
                      'id_repartidor=' || :OLD.id_repartidor || '; ' ||
                      'id_motivo=' || :OLD.id_motivo || '; ' ||
                      'fecha=' || :OLD.fecha || '; ' ||
                      'observacion=' || :OLD.observacion;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_cancelacion_entrega=' || :NEW.id_cancelacion_entrega || '; ' ||
                      'id_pedido=' || :NEW.id_pedido || '; ' ||
                      'id_repartidor=' || :NEW.id_repartidor || '; ' ||
                      'id_motivo=' || :NEW.id_motivo || '; ' ||
                      'fecha=' || :NEW.fecha || '; ' ||
                      'observacion=' || :NEW.observacion;
    END IF;

    pr_bitacora('CANCELACION_ENTREGA', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_CANC_ENT;
/

CREATE OR REPLACE TRIGGER TRG_BIT_CALIF
AFTER INSERT OR UPDATE OR DELETE ON calificacion
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_calificacion;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_calificacion;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_calificacion;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_calificacion=' || :OLD.id_calificacion || '; ' ||
                      'id_pedido=' || :OLD.id_pedido || '; ' ||
                      'puntuacion=' || :OLD.puntuacion || '; ' ||
                      'comentario=' || :OLD.comentario || '; ' ||
                      'fecha=' || :OLD.fecha;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_calificacion=' || :NEW.id_calificacion || '; ' ||
                      'id_pedido=' || :NEW.id_pedido || '; ' ||
                      'puntuacion=' || :NEW.puntuacion || '; ' ||
                      'comentario=' || :NEW.comentario || '; ' ||
                      'fecha=' || :NEW.fecha;
    END IF;

    pr_bitacora('CALIFICACION', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_CALIF;
/

CREATE OR REPLACE TRIGGER TRG_BIT_ROL
AFTER INSERT OR UPDATE OR DELETE ON rol
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_rol;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_rol;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_rol;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_rol=' || :OLD.id_rol || '; ' ||
                      'nombre=' || :OLD.nombre || '; ' ||
                      'descripcion=' || :OLD.descripcion || '; ' ||
                      'estado=' || :OLD.estado;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_rol=' || :NEW.id_rol || '; ' ||
                      'nombre=' || :NEW.nombre || '; ' ||
                      'descripcion=' || :NEW.descripcion || '; ' ||
                      'estado=' || :NEW.estado;
    END IF;

    pr_bitacora('ROL', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_ROL;
/

CREATE OR REPLACE TRIGGER TRG_BIT_MENU
AFTER INSERT OR UPDATE OR DELETE ON menu
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_menu;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_menu;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_menu;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_menu=' || :OLD.id_menu || '; ' ||
                      'id_modulo=' || :OLD.id_modulo || '; ' ||
                      'nombre=' || :OLD.nombre || '; ' ||
                      'url=' || :OLD.url || '; ' ||
                      'orden=' || :OLD.orden || '; ' ||
                      'estado=' || :OLD.estado;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_menu=' || :NEW.id_menu || '; ' ||
                      'id_modulo=' || :NEW.id_modulo || '; ' ||
                      'nombre=' || :NEW.nombre || '; ' ||
                      'url=' || :NEW.url || '; ' ||
                      'orden=' || :NEW.orden || '; ' ||
                      'estado=' || :NEW.estado;
    END IF;

    pr_bitacora('MENU', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_MENU;
/

CREATE OR REPLACE TRIGGER TRG_BIT_ROL_MENU
AFTER INSERT OR UPDATE OR DELETE ON rol_menu
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_rol || '-' || :NEW.id_menu;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_rol || '-' || :NEW.id_menu;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_rol || '-' || :OLD.id_menu;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_rol=' || :OLD.id_rol || '; ' ||
                      'id_menu=' || :OLD.id_menu;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_rol=' || :NEW.id_rol || '; ' ||
                      'id_menu=' || :NEW.id_menu;
    END IF;

    pr_bitacora('ROL_MENU', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_ROL_MENU;
/

CREATE OR REPLACE TRIGGER TRG_BIT_USUARIO
AFTER INSERT OR UPDATE OR DELETE ON usuario
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(15);
    v_llave     VARCHAR2(30);
    v_anterior  VARCHAR2(4000);
    v_nuevo     VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        v_llave := :NEW.id_usuario;
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        v_llave := :NEW.id_usuario;
    ELSE
        v_operacion := 'DELETE';
        v_llave := :OLD.id_usuario;
    END IF;

    IF UPDATING OR DELETING THEN
        v_anterior := 'id_usuario=' || :OLD.id_usuario || '; ' ||
                      'id_rol=' || :OLD.id_rol || '; ' ||
                      'nombre_usuario=' || :OLD.nombre_usuario || '; ' ||
                      'clave=******' || '; ' ||
                      'nombre_completo=' || :OLD.nombre_completo || '; ' ||
                      'id_cliente=' || :OLD.id_cliente || '; ' ||
                      'id_negocio=' || :OLD.id_negocio || '; ' ||
                      'id_repartidor=' || :OLD.id_repartidor || '; ' ||
                      'fecha_creacion=' || :OLD.fecha_creacion || '; ' ||
                      'estado=' || :OLD.estado;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_nuevo := 'id_usuario=' || :NEW.id_usuario || '; ' ||
                      'id_rol=' || :NEW.id_rol || '; ' ||
                      'nombre_usuario=' || :NEW.nombre_usuario || '; ' ||
                      'clave=******' || '; ' ||
                      'nombre_completo=' || :NEW.nombre_completo || '; ' ||
                      'id_cliente=' || :NEW.id_cliente || '; ' ||
                      'id_negocio=' || :NEW.id_negocio || '; ' ||
                      'id_repartidor=' || :NEW.id_repartidor || '; ' ||
                      'fecha_creacion=' || :NEW.fecha_creacion || '; ' ||
                      'estado=' || :NEW.estado;
    END IF;

    pr_bitacora('USUARIO', v_operacion, v_llave, v_anterior, v_nuevo);
END TRG_BIT_USUARIO;
/

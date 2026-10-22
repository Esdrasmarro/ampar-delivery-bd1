-- =====================================================================
-- Proyecto Final Base de Datos 1 - Sistema de Control de Delivery "Ampar"
-- Script 06: triggers con reglas del negocio
-- Ejecutar conectado como: AMPAR
-- Estudiante: Esdras Lemuel Marroquín Rojas - Carné 3190-13-13335
-- =====================================================================

-- ---------------------------------------------------------------------
-- TRG_PEDIDO_ZONA_ROJA (BEFORE INSERT, nivel de fila)
-- Antes de guardar un pedido, revisa si la dirección de entrega está en
-- una zona roja y marca el pedido (regla RN-15).
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_PEDIDO_ZONA_ROJA
BEFORE INSERT ON pedido
FOR EACH ROW
BEGIN
    SELECT z.zona_roja
      INTO :NEW.zona_roja
      FROM direccion_cliente d
      JOIN zona z ON z.id_zona = d.id_zona
     WHERE d.id_direccion = :NEW.id_direccion;
END TRG_PEDIDO_ZONA_ROJA;
/

-- ---------------------------------------------------------------------
-- TRG_PEDIDO_SEGUIMIENTO (AFTER INSERT OR UPDATE OF estado, nivel de fila)
-- Cada vez que un pedido se crea o cambia de estado:
--   1. Guarda el cambio en HISTORIAL_ESTADO (tracking) con la ubicación
--      del repartidor, si tiene uno asignado.
--   2. Envía (simula) las notificaciones automáticas por SMS y WhatsApp
--      al cliente (reglas RN-13 y RN-14).
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_PEDIDO_SEGUIMIENTO
AFTER INSERT OR UPDATE OF id_estado_pedido ON pedido
FOR EACH ROW
DECLARE
    v_estado   estado_pedido.nombre%TYPE;
    v_telefono cliente.telefono%TYPE;
    v_latitud  repartidor.latitud%TYPE;
    v_longitud repartidor.longitud%TYPE;
    v_mensaje  VARCHAR2(300);
BEGIN
    -- solo si es un pedido nuevo o si el estado realmente cambió
    IF INSERTING OR :OLD.id_estado_pedido <> :NEW.id_estado_pedido THEN

        SELECT nombre INTO v_estado
          FROM estado_pedido
         WHERE id_estado_pedido = :NEW.id_estado_pedido;

        SELECT telefono INTO v_telefono
          FROM cliente
         WHERE id_cliente = :NEW.id_cliente;

        IF :NEW.id_repartidor IS NOT NULL THEN
            SELECT latitud, longitud INTO v_latitud, v_longitud
              FROM repartidor
             WHERE id_repartidor = :NEW.id_repartidor;
        END IF;

        -- 1. historial del pedido (tracking)
        INSERT INTO historial_estado (id_pedido, id_estado_pedido, latitud, longitud)
        VALUES (:NEW.id_pedido, :NEW.id_estado_pedido, v_latitud, v_longitud);

        -- 2. notificaciones automáticas (simuladas: se guardan como ENVIADA)
        v_mensaje := 'Ampar: su pedido No. ' || :NEW.id_pedido || ' está ' || v_estado || '.';
        IF :NEW.zona_roja = 'S' THEN
            v_mensaje := v_mensaje || ' Aviso: la entrega es en zona roja.';
        END IF;

        INSERT INTO notificacion (id_pedido, canal, telefono, mensaje)
        VALUES (:NEW.id_pedido, 'SMS', v_telefono, v_mensaje);

        INSERT INTO notificacion (id_pedido, canal, telefono, mensaje)
        VALUES (:NEW.id_pedido, 'WHATSAPP', v_telefono, v_mensaje);
    END IF;
END TRG_PEDIDO_SEGUIMIENTO;
/

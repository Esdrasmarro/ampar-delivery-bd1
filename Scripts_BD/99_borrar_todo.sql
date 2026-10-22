-- =====================================================================
-- Proyecto Final Base de Datos 1 - Sistema de Control de Delivery "Ampar"
-- Script 99: borra todo para volver a instalar desde cero
-- Ejecutar conectado como: SYSTEM
-- ¡CUIDADO! Borra el esquema AMPAR con todos sus datos.
-- Estudiante: Esdras Lemuel Marroquín Rojas - Carné 3190-13-13335
-- =====================================================================

DROP USER ampar_admin CASCADE;
DROP USER ampar_operador CASCADE;
DROP USER ampar_negocio CASCADE;
DROP USER ampar_repartidor CASCADE;
DROP USER ampar_cliente CASCADE;
DROP USER ampar_gerencia CASCADE;

DROP ROLE ROL_ADMINISTRADOR;
DROP ROLE ROL_OPERADOR;
DROP ROLE ROL_NEGOCIO;
DROP ROLE ROL_REPARTIDOR;
DROP ROLE ROL_CLIENTE;
DROP ROLE ROL_GERENCIA;

DROP USER ampar CASCADE;

-- Si algún usuario o rol no existe, Oracle muestra un error en esa línea; se puede ignorar.

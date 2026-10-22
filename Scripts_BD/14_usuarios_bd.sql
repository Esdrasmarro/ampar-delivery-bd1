-- =====================================================================
-- Proyecto Final Base de Datos 1 - Sistema de Control de Delivery "Ampar"
-- Script 14: usuarios de la base de datos con sus roles
-- Ejecutar conectado como: SYSTEM (después de instalar_todo.sql, porque
-- los roles los crea el script 09 con el usuario AMPAR)
-- Estudiante: Esdras Lemuel Marroquín Rojas - Carné 3190-13-13335
-- =====================================================================
-- Cada usuario de base de datos recibe un rol. Con el rol obtiene solo los
-- privilegios de su función (por ejemplo, la gerencia solo puede consultar).
-- Para consultar con estos usuarios se antepone el esquema: SELECT * FROM ampar.vw_dashboard;

CREATE USER ampar_admin IDENTIFIED BY "Admin2026";
GRANT CREATE SESSION TO ampar_admin;
GRANT ROL_ADMINISTRADOR TO ampar_admin;

CREATE USER ampar_operador IDENTIFIED BY "Operador2026";
GRANT CREATE SESSION TO ampar_operador;
GRANT ROL_OPERADOR TO ampar_operador;

CREATE USER ampar_negocio IDENTIFIED BY "Negocio2026";
GRANT CREATE SESSION TO ampar_negocio;
GRANT ROL_NEGOCIO TO ampar_negocio;

CREATE USER ampar_repartidor IDENTIFIED BY "Repartidor2026";
GRANT CREATE SESSION TO ampar_repartidor;
GRANT ROL_REPARTIDOR TO ampar_repartidor;

CREATE USER ampar_cliente IDENTIFIED BY "Cliente2026";
GRANT CREATE SESSION TO ampar_cliente;
GRANT ROL_CLIENTE TO ampar_cliente;

CREATE USER ampar_gerencia IDENTIFIED BY "Gerencia2026";
GRANT CREATE SESSION TO ampar_gerencia;
GRANT ROL_GERENCIA TO ampar_gerencia;

-- Prueba: conectarse como ampar_gerencia y ejecutar
--   SELECT * FROM ampar.vw_dashboard;      -> funciona
--   DELETE FROM ampar.pedido;              -> ORA-00942 / ORA-01031 (no tiene privilegio)

-- =====================================================================
-- Proyecto Final Base de Datos 1 - Sistema de Control de Delivery "Ampar"
-- Script 00: crear el usuario (esquema) AMPAR, dueño de todos los objetos
-- Ejecutar conectado como: SYSTEM (o un usuario administrador)
--   IMPORTANTE: la conexión debe apuntar a la base de datos conectable:
--   Oracle 21c XE  -> nombre del servicio XEPDB1
--   Oracle 23ai Free -> nombre del servicio FREEPDB1
-- Estudiante: Esdras Lemuel Marroquín Rojas - Carné 3190-13-13335
-- =====================================================================

CREATE USER ampar IDENTIFIED BY "Ampar2026"
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA UNLIMITED ON users;

-- privilegios de sistema que necesita AMPAR para crear sus objetos
GRANT CREATE SESSION   TO ampar;
GRANT CREATE TABLE     TO ampar;
GRANT CREATE SEQUENCE  TO ampar;
GRANT CREATE TRIGGER   TO ampar;
GRANT CREATE VIEW      TO ampar;
GRANT CREATE PROCEDURE TO ampar;
GRANT CREATE ROLE      TO ampar;

-- Después de ejecutar este script:
-- 1. En SQL Developer crear una conexión nueva:
--      Nombre: AMPAR   Usuario: ampar   Contraseña: Ampar2026
--      Nombre del servicio: XEPDB1 (21c XE) o FREEPDB1 (23ai Free)
-- 2. Con la conexión AMPAR abrir y ejecutar (F5) el script instalar_todo.sql

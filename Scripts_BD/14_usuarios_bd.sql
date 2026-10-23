-- Script 14: usuarios de la base de datos. Ejecutar como SYSTEM
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

-- Instalador de los scripts 01 a 12. Ejecutar como AMPAR
SET DEFINE OFF
SET SERVEROUTPUT ON

PROMPT === 01 Tablas ===
@@01_tablas.sql
PROMPT === 02 Secuencias ===
@@02_secuencias.sql
PROMPT === 03 Funciones ===
@@03_funciones.sql
PROMPT === 04 Procedimientos ===
@@04_procedimientos.sql
PROMPT === 05 Triggers de bitácora ===
@@05_triggers_bitacora.sql
PROMPT === 06 Triggers del negocio ===
@@06_triggers_negocio.sql
PROMPT === 07 Paquetes ===
@@07_paquetes.sql
PROMPT === 08 Vistas ===
@@08_vistas.sql
PROMPT === 09 Roles ===
@@09_roles.sql
PROMPT === 10 Datos de catálogos ===
@@10_datos_catalogos.sql
PROMPT === 11 Menú y seguridad ===
@@11_menu_seguridad.sql
PROMPT === 12 Datos de prueba ===
@@12_datos_prueba.sql

PROMPT === Objetos con errores (debe salir vacío) ===
SELECT object_type, object_name FROM user_objects WHERE status = 'INVALID' ORDER BY 1, 2;

PROMPT === Instalación terminada ===

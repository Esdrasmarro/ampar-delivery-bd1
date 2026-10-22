package com.ampar.delivery.datos;

import java.sql.SQLException;

public class ErrorBd {

    public static String mensaje(Throwable error) {
        Throwable t = error;
        while (t != null && !(t instanceof SQLException)) {
            t = t.getCause();
        }
        String texto = (t != null ? t.getMessage() : error.getMessage());
        if (texto == null) {
            return "Ocurrió un error inesperado.";
        }

        int pos = texto.indexOf("ORA-20");
        if (pos >= 0) {
            String resto = texto.substring(pos + 10).trim();
            int fin = resto.indexOf('\n');
            return fin > 0 ? resto.substring(0, fin).trim() : resto;
        }

        if (texto.contains("ORA-00001")) return "Ya existe un registro con esos datos (valor duplicado).";
        if (texto.contains("ORA-02292")) return "No se puede eliminar porque el registro tiene datos relacionados.";
        if (texto.contains("ORA-02291")) return "El registro relacionado no existe.";
        if (texto.contains("ORA-02290")) return "Algún dato no cumple las reglas de validación.";
        if (texto.contains("ORA-01400")) return "Falta llenar un dato obligatorio.";
        if (texto.contains("ORA-12899")) return "Algún dato es demasiado largo.";
        if (texto.contains("ORA-01722") || texto.contains("ORA-01858")) return "Algún número o fecha no tiene el formato correcto.";

        int fin = texto.indexOf('\n');
        return fin > 0 ? texto.substring(0, fin) : texto;
    }
}

package com.ampar.delivery.config;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

public class Sesion {

    public static final String ATRIBUTO = "usuario";

    public static UsuarioSesion actual() {
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs == null) {
            return null;
        }
        HttpServletRequest request = attrs.getRequest();
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (UsuarioSesion) session.getAttribute(ATRIBUTO);
    }

    public static String nombreUsuario() {
        UsuarioSesion u = actual();
        return u == null ? "anonimo" : u.getUsuario();
    }
}

package com.ampar.delivery.config;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class DatosGlobales {

    @ModelAttribute("usuarioSesion")
    public UsuarioSesion usuarioSesion() {
        return Sesion.actual();
    }

    @ModelAttribute("rutaActual")
    public String rutaActual(HttpServletRequest request) {
        return request.getRequestURI().substring(request.getContextPath().length());
    }
}

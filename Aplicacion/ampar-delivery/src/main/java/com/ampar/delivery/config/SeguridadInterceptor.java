package com.ampar.delivery.config;

import com.ampar.delivery.datos.Bd;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class SeguridadInterceptor implements HandlerInterceptor {

    private final Bd bd;

    public SeguridadInterceptor(Bd bd) {
        this.bd = bd;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String ruta = request.getRequestURI().substring(request.getContextPath().length());

        if (esPublica(ruta)) {
            return true;
        }

        UsuarioSesion usuario = (UsuarioSesion) request.getSession().getAttribute(Sesion.ATRIBUTO);
        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }

        if (esComun(ruta)) {
            return true;
        }

        Object permiso = bd.valor("SELECT pkg_seguridad.fn_tiene_permiso(?, ?) FROM dual",
                usuario.getIdUsuario(), ruta);
        if ("S".equals(permiso)) {
            return true;
        }

        response.sendRedirect(request.getContextPath() + "/acceso-denegado");
        return false;
    }

    private boolean esPublica(String ruta) {
        return ruta.equals("/") || ruta.equals("/login") || ruta.equals("/registro")
                || ruta.equals("/afiliacion") || ruta.equals("/error") || ruta.equals("/favicon.ico")
                || ruta.startsWith("/lib/") || ruta.startsWith("/css/") || ruta.startsWith("/js/");
    }

    private boolean esComun(String ruta) {
        return ruta.equals("/logout") || ruta.equals("/acceso-denegado") || ruta.equals("/perfil/clave");
    }
}

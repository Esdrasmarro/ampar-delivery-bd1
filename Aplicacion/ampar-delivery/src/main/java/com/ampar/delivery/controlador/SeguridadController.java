package com.ampar.delivery.controlador;

import com.ampar.delivery.datos.Bd;
import com.ampar.delivery.datos.ErrorBd;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.sql.PreparedStatement;
import java.sql.Types;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class SeguridadController {

    private final Bd bd;

    public SeguridadController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping("/seguridad/usuarios")
    public String usuarios(@RequestParam(required = false) String buscar, Model model) {
        String filtro = buscar == null ? "" : buscar.trim().toLowerCase();
        model.addAttribute("usuarios", bd.lista(
                "SELECT u.id_usuario, u.nombre_usuario, u.nombre_completo, r.nombre AS rol, u.estado, "
                        + "u.fecha_creacion FROM usuario u JOIN rol r ON r.id_rol = u.id_rol "
                        + "WHERE LOWER(u.nombre_usuario || ' ' || u.nombre_completo) LIKE ? ORDER BY u.id_usuario",
                "%" + filtro + "%"));
        model.addAttribute("buscar", buscar);
        return "seguridad/usuarios";
    }

    @GetMapping("/seguridad/usuarios/nuevo")
    public String nuevoUsuario(Model model) {
        Map<String, Object> u = new HashMap<>();
        u.put("ESTADO", "A");
        return formularioUsuario(u, model);
    }

    @GetMapping("/seguridad/usuarios/editar/{id}")
    public String editarUsuario(@PathVariable Long id, Model model) {
        return formularioUsuario(bd.uno("SELECT * FROM usuario WHERE id_usuario = ?", id), model);
    }

    private String formularioUsuario(Map<String, Object> u, Model model) {
        model.addAttribute("u", u);
        model.addAttribute("roles", bd.lista("SELECT id_rol, nombre FROM rol WHERE estado = 'A' ORDER BY id_rol"));
        model.addAttribute("clientes", bd.lista(
                "SELECT id_cliente AS id, nombres || ' ' || apellidos AS texto FROM cliente ORDER BY 2"));
        model.addAttribute("negocios", bd.lista("SELECT id_negocio AS id, nombre AS texto FROM negocio ORDER BY 2"));
        model.addAttribute("repartidores", bd.lista(
                "SELECT id_repartidor AS id, nombres || ' ' || apellidos AS texto FROM repartidor ORDER BY 2"));
        return "seguridad/usuario-form";
    }

    @PostMapping("/seguridad/usuarios/guardar")
    public String guardarUsuario(@RequestParam Map<String, String> d, Model model, RedirectAttributes flash) {
        Long id = Bd.aLong(d.get("id"));
        try {
            if (id == null) {
                bd.llamar("pkg_seguridad.pr_crear_usuario", new Object[]{
                        Bd.aLong(d.get("idRol")), d.get("nombreUsuario"), d.get("clave"), d.get("nombreCompleto"),
                        Bd.aLong(d.get("idCliente")), Bd.aLong(d.get("idNegocio")), Bd.aLong(d.get("idRepartidor"))
                }, Types.NUMERIC);
                flash.addFlashAttribute("exito", "Usuario creado.");
            } else {
                bd.llamar("pkg_seguridad.pr_modificar_usuario", new Object[]{
                        id, Bd.aLong(d.get("idRol")), d.get("nombreCompleto"), d.get("estado")});
                if (Bd.texto(d.get("clave")) != null) {
                    bd.llamar("pkg_seguridad.pr_cambiar_clave", new Object[]{id, d.get("clave")});
                }
                flash.addFlashAttribute("exito", "Usuario modificado.");
            }
            return "redirect:/seguridad/usuarios";
        } catch (Exception e) {
            Map<String, Object> u = new HashMap<>();
            u.put("ID_USUARIO", id);
            u.put("ID_ROL", d.get("idRol"));
            u.put("NOMBRE_USUARIO", d.get("nombreUsuario"));
            u.put("NOMBRE_COMPLETO", d.get("nombreCompleto"));
            u.put("ESTADO", d.getOrDefault("estado", "A"));
            model.addAttribute("error", ErrorBd.mensaje(e));
            return formularioUsuario(u, model);
        }
    }

    @GetMapping("/seguridad/permisos")
    public String permisos(@RequestParam(required = false) Long idRol, Model model) {
        List<Map<String, Object>> roles = bd.lista("SELECT id_rol, nombre FROM rol ORDER BY id_rol");
        if (idRol == null && !roles.isEmpty()) {
            idRol = Bd.aLong(roles.get(0).get("ID_ROL"));
        }
        model.addAttribute("roles", roles);
        model.addAttribute("idRol", idRol);
        model.addAttribute("opciones", bd.lista(
                "SELECT m.id_menu, mo.nombre AS modulo, m.nombre AS opcion, m.url, "
                        + "CASE WHEN rm.id_menu IS NULL THEN 'N' ELSE 'S' END AS asignado "
                        + "FROM menu m JOIN modulo mo ON mo.id_modulo = m.id_modulo "
                        + "LEFT JOIN rol_menu rm ON rm.id_menu = m.id_menu AND rm.id_rol = ? "
                        + "ORDER BY mo.orden, m.orden", idRol));
        return "seguridad/permisos";
    }

    @PostMapping("/seguridad/permisos")
    public String guardarPermisos(@RequestParam Long idRol,
                                  @RequestParam(required = false) List<Long> menus,
                                  RedirectAttributes flash) {
        try {
            bd.transaccion(con -> {
                try (PreparedStatement borrar = con.prepareStatement("DELETE FROM rol_menu WHERE id_rol = ?")) {
                    borrar.setLong(1, idRol);
                    borrar.executeUpdate();
                }
                if (menus != null) {
                    try (PreparedStatement insertar = con.prepareStatement(
                            "INSERT INTO rol_menu (id_rol, id_menu) VALUES (?, ?)")) {
                        for (Long idMenu : menus) {
                            insertar.setLong(1, idRol);
                            insertar.setLong(2, idMenu);
                            insertar.executeUpdate();
                        }
                    }
                }
            });
            flash.addFlashAttribute("exito", "Permisos guardados. Los usuarios del rol verán el cambio al volver a iniciar sesión.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/seguridad/permisos?idRol=" + idRol;
    }
}

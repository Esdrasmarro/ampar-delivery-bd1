package com.ampar.delivery.controlador;

import com.ampar.delivery.config.Sesion;
import com.ampar.delivery.config.UsuarioSesion;
import com.ampar.delivery.datos.Bd;
import com.ampar.delivery.datos.ErrorBd;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Controller
public class InicioController {

    private static final int MAX_INTENTOS = 3;

    private final Bd bd;

    public InicioController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping("/")
    public String inicio(HttpSession session, Model model) {
        UsuarioSesion usuario = (UsuarioSesion) session.getAttribute(Sesion.ATRIBUTO);
        if (usuario == null) {
            return "index";
        }
        return "panel";
    }

    @GetMapping("/acceso-denegado")
    public String accesoDenegado() {
        return "acceso-denegado";
    }

    @GetMapping("/login")
    public String login(HttpSession session, Model model) {
        Integer intentos = (Integer) session.getAttribute("intentos");
        model.addAttribute("intentos", intentos == null ? 0 : intentos);
        return "login";
    }

    @PostMapping("/login")
    public String entrar(@RequestParam String usuario, @RequestParam String clave,
                         HttpSession session, RedirectAttributes flash) {
        try {
            List<Object> r = bd.llamarComo(usuario, "pkg_seguridad.pr_login",
                    new Object[]{usuario, clave},
                    Types.NUMERIC, Types.NUMERIC, Types.VARCHAR, Types.VARCHAR,
                    Types.NUMERIC, Types.NUMERIC, Types.NUMERIC);

            UsuarioSesion u = new UsuarioSesion();
            u.setIdUsuario(Bd.aLong(r.get(0)));
            u.setIdRol(Bd.aLong(r.get(1)));
            u.setRol((String) r.get(2));
            u.setNombre((String) r.get(3));
            u.setIdCliente(Bd.aLong(r.get(4)));
            u.setIdNegocio(Bd.aLong(r.get(5)));
            u.setIdRepartidor(Bd.aLong(r.get(6)));
            u.setUsuario(usuario.trim().toLowerCase());
            u.setMenu(cargarMenu(u.getIdUsuario()));

            session.removeAttribute("intentos");
            session.setAttribute(Sesion.ATRIBUTO, u);
            return "redirect:/";
        } catch (Exception e) {
            Integer intentos = (Integer) session.getAttribute("intentos");
            intentos = (intentos == null ? 1 : intentos + 1);

            if (intentos >= MAX_INTENTOS) {
                session.removeAttribute("intentos");
                flash.addFlashAttribute("error",
                        "Superó los " + MAX_INTENTOS + " intentos permitidos. Vuelva a intentarlo desde el inicio.");
                return "redirect:/";
            }
            session.setAttribute("intentos", intentos);
            flash.addFlashAttribute("error", ErrorBd.mensaje(e) + " Intento " + intentos + " de " + MAX_INTENTOS + ".");
            return "redirect:/login";
        }
    }

    private List<UsuarioSesion.Modulo> cargarMenu(Long idUsuario) {
        List<Map<String, Object>> filas = bd.lista(
                "SELECT modulo, opcion, url FROM vw_menu_usuario WHERE id_usuario = ? "
                        + "ORDER BY orden_modulo, orden_menu", idUsuario);

        List<UsuarioSesion.Modulo> menu = new ArrayList<>();
        UsuarioSesion.Modulo actual = null;
        for (Map<String, Object> f : filas) {
            String modulo = (String) f.get("MODULO");
            if (actual == null || !actual.getNombre().equals(modulo)) {
                actual = new UsuarioSesion.Modulo(modulo);
                menu.add(actual);
            }
            actual.getOpciones().add(new UsuarioSesion.Opcion((String) f.get("OPCION"), (String) f.get("URL")));
        }
        return menu;
    }

    @GetMapping("/logout")
    public String salir(HttpSession session) {
        session.invalidate();
        return "redirect:/";
    }

    @GetMapping("/registro")
    public String registro() {
        return "registro";
    }

    @PostMapping("/registro")
    public String registrar(@RequestParam String nombres, @RequestParam String apellidos,
                            @RequestParam String telefono, @RequestParam String correo,
                            @RequestParam String clave, @RequestParam String clave2,
                            RedirectAttributes flash, Model model) {
        if (!clave.equals(clave2)) {
            model.addAttribute("error", "Las contraseñas no coinciden.");
            return "registro";
        }
        try {
            bd.llamarComo(correo, "pkg_seguridad.pr_registrar_cliente",
                    new Object[]{nombres, apellidos, telefono, correo, clave}, Types.NUMERIC);
            flash.addFlashAttribute("exito", "Cuenta creada. Inicie sesión con su correo y contraseña.");
            return "redirect:/login";
        } catch (Exception e) {
            model.addAttribute("error", ErrorBd.mensaje(e));
            return "registro";
        }
    }

    @GetMapping("/afiliacion")
    public String afiliacion(Model model) {
        cargarListasAfiliacion(model);
        return "afiliacion";
    }

    @PostMapping("/afiliacion")
    public String solicitarAfiliacion(@RequestParam Long idTipoNegocio, @RequestParam Long idZona,
                                      @RequestParam String nombre, @RequestParam String nit,
                                      @RequestParam String propietario, @RequestParam String telefono,
                                      @RequestParam String correo, @RequestParam String direccion,
                                      @RequestParam String latitud, @RequestParam String longitud,
                                      RedirectAttributes flash, Model model) {
        try {
            List<Object> r = bd.llamarComo(correo, "pkg_negocio.pr_solicitar_afiliacion",
                    new Object[]{idTipoNegocio, idZona, nombre, nit, propietario, telefono, correo, direccion,
                            Bd.aDecimal(latitud), Bd.aDecimal(longitud)},
                    Types.NUMERIC);
            flash.addFlashAttribute("exito", "Solicitud No. " + Bd.aLong(r.get(0))
                    + " enviada. Ampar revisará sus datos y le enviará su usuario.");
            return "redirect:/";
        } catch (Exception e) {
            model.addAttribute("error", ErrorBd.mensaje(e));
            cargarListasAfiliacion(model);
            return "afiliacion";
        }
    }

    private void cargarListasAfiliacion(Model model) {
        model.addAttribute("tipos", bd.lista(
                "SELECT id_tipo_negocio AS id, nombre FROM tipo_negocio WHERE estado = 'A' ORDER BY nombre"));
        model.addAttribute("zonas", bd.lista(
                "SELECT z.id_zona AS id, z.nombre || ' - ' || m.nombre AS nombre "
                        + "FROM zona z JOIN municipio m ON m.id_municipio = z.id_municipio "
                        + "WHERE z.estado = 'A' ORDER BY m.id_municipio, z.id_zona"));
    }

    @GetMapping("/perfil/clave")
    public String clave() {
        return "perfil/clave";
    }

    @PostMapping("/perfil/clave")
    public String cambiarClave(@RequestParam String actual, @RequestParam String nueva,
                               @RequestParam String nueva2, Model model) {
        UsuarioSesion u = Sesion.actual();
        Object correcta = bd.valor(
                "SELECT COUNT(*) FROM usuario WHERE id_usuario = ? AND clave = fn_encriptar(?)",
                u.getIdUsuario(), actual);
        if (Bd.aLong(correcta) == 0) {
            model.addAttribute("error", "La contraseña actual no es correcta.");
        } else if (!nueva.equals(nueva2)) {
            model.addAttribute("error", "Las contraseñas nuevas no coinciden.");
        } else {
            try {
                bd.llamar("pkg_seguridad.pr_cambiar_clave", new Object[]{u.getIdUsuario(), nueva});
                model.addAttribute("exito", "Contraseña cambiada correctamente.");
            } catch (Exception e) {
                model.addAttribute("error", ErrorBd.mensaje(e));
            }
        }
        return "perfil/clave";
    }
}

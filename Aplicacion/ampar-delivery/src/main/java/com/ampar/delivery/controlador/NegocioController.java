package com.ampar.delivery.controlador;

import com.ampar.delivery.config.Sesion;
import com.ampar.delivery.datos.Bd;
import com.ampar.delivery.datos.ErrorBd;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;

@Controller
public class NegocioController {

    private final Bd bd;

    public NegocioController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping("/negocios/solicitudes")
    public String solicitudes(Model model) {
        String sql = "SELECT n.id_negocio, n.nombre, n.nit, n.propietario, n.telefono, n.correo, n.direccion, "
                + "n.fecha_registro, n.estado, t.nombre AS tipo, z.nombre || ' - ' || m.nombre AS zona "
                + "FROM negocio n JOIN tipo_negocio t ON t.id_tipo_negocio = n.id_tipo_negocio "
                + "JOIN zona z ON z.id_zona = n.id_zona JOIN municipio m ON m.id_municipio = z.id_municipio ";
        model.addAttribute("pendientes", bd.lista(sql + "WHERE n.estado = 'PENDIENTE' ORDER BY n.fecha_registro"));
        model.addAttribute("procesadas", bd.lista(sql + "WHERE n.estado <> 'PENDIENTE' ORDER BY n.id_negocio DESC"));
        return "negocios/solicitudes";
    }

    @PostMapping("/negocios/solicitudes/{id}/aprobar")
    public String aprobar(@PathVariable Long id, @RequestParam String clave, RedirectAttributes flash) {
        try {
            bd.llamar("pkg_negocio.pr_aprobar", new Object[]{id, clave});
            flash.addFlashAttribute("exito", "Negocio aprobado. Su usuario es el correo del negocio.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/negocios/solicitudes";
    }

    @PostMapping("/negocios/solicitudes/{id}/rechazar")
    public String rechazar(@PathVariable Long id, RedirectAttributes flash) {
        try {
            bd.llamar("pkg_negocio.pr_rechazar", new Object[]{id});
            flash.addFlashAttribute("exito", "Solicitud rechazada.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/negocios/solicitudes";
    }

    @GetMapping("/negocios/mi-negocio")
    public String miNegocio(Model model) {
        Long id = Sesion.actual().getIdNegocio();
        model.addAttribute("n", bd.uno(
                "SELECT n.*, t.nombre AS tipo, z.nombre || ' - ' || m.nombre AS zona, fn_negocio_abierto(n.id_negocio) AS abierto "
                        + "FROM negocio n JOIN tipo_negocio t ON t.id_tipo_negocio = n.id_tipo_negocio "
                        + "JOIN zona z ON z.id_zona = n.id_zona JOIN municipio m ON m.id_municipio = z.id_municipio "
                        + "WHERE n.id_negocio = ?", id));
        return "negocios/mi-negocio";
    }

    @PostMapping("/negocios/mi-negocio")
    public String guardarMiNegocio(@RequestParam Map<String, String> d, RedirectAttributes flash) {
        Long id = Sesion.actual().getIdNegocio();
        try {
            bd.ejecutar("UPDATE negocio SET nombre = ?, propietario = ?, telefono = ?, direccion = ?, "
                            + "latitud = ?, longitud = ?, radio_cobertura_km = ? WHERE id_negocio = ?",
                    Bd.texto(d.get("nombre")), Bd.texto(d.get("propietario")), Bd.texto(d.get("telefono")),
                    Bd.texto(d.get("direccion")), Bd.aDecimal(d.get("latitud")), Bd.aDecimal(d.get("longitud")),
                    Bd.aDecimal(d.get("radio")), id);
            flash.addFlashAttribute("exito", "Datos del negocio guardados.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/negocios/mi-negocio";
    }

    @GetMapping("/negocios/horarios")
    public String horarios(Model model) {
        Long id = Sesion.actual().getIdNegocio();
        model.addAttribute("dias", bd.lista(
                "SELECT d.dia, "
                        + "CASE d.dia WHEN 1 THEN 'Lunes' WHEN 2 THEN 'Martes' WHEN 3 THEN 'Miércoles' "
                        + "WHEN 4 THEN 'Jueves' WHEN 5 THEN 'Viernes' WHEN 6 THEN 'Sábado' ELSE 'Domingo' END AS nombre, "
                        + "NVL(h.hora_apertura, '08:00') AS apertura, NVL(h.hora_cierre, '18:00') AS cierre, "
                        + "NVL(h.hace_entrega, 'N') AS entrega "
                        + "FROM (SELECT LEVEL AS dia FROM dual CONNECT BY LEVEL <= 7) d "
                        + "LEFT JOIN horario_negocio h ON h.dia_semana = d.dia AND h.id_negocio = ? "
                        + "ORDER BY d.dia", id));
        model.addAttribute("abierto", bd.valor("SELECT fn_negocio_abierto(?) FROM dual", id));
        return "negocios/horarios";
    }

    @PostMapping("/negocios/horarios")
    public String guardarHorarios(@RequestParam Map<String, String> d, RedirectAttributes flash) {
        Long id = Sesion.actual().getIdNegocio();
        try {
            for (int dia = 1; dia <= 7; dia++) {
                String entrega = d.containsKey("entrega" + dia) ? "S" : "N";
                bd.llamar("pkg_negocio.pr_guardar_horario", new Object[]{
                        id, dia, d.get("apertura" + dia), d.get("cierre" + dia), entrega});
            }
            flash.addFlashAttribute("exito", "Horarios guardados.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/negocios/horarios";
    }
}

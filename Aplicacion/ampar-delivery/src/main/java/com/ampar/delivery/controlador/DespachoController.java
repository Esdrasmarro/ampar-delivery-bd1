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

import java.sql.Types;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class DespachoController {

    private final Bd bd;

    public DespachoController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping("/despacho/monitor")
    public String monitor(Model model) {
        model.addAttribute("pedidos", bd.lista(
                "SELECT * FROM vw_pedido WHERE estado IN ('CONFIRMADO', 'ASIGNADO', 'RECOGIDO', 'EN RUTA') "
                        + "ORDER BY orden_estado, id_pedido"));
        model.addAttribute("repartidores", bd.lista(
                "SELECT r.id_repartidor, r.nombres || ' ' || r.apellidos AS nombre, r.latitud, r.longitud, "
                        + "r.disponible, r.fecha_ubicacion, t.nombre AS vehiculo FROM repartidor r "
                        + "JOIN tipo_vehiculo t ON t.id_tipo_vehiculo = r.id_tipo_vehiculo "
                        + "WHERE r.estado = 'A' ORDER BY r.disponible DESC, r.id_repartidor"));
        return "despacho/monitor";
    }

    @GetMapping("/despacho/asignar")
    public String asignar(Model model) {
        List<Map<String, Object>> pendientes = bd.lista(
                "SELECT * FROM vw_pedido WHERE estado = 'CONFIRMADO' ORDER BY id_pedido");

        Map<Object, List<Map<String, Object>>> cercanos = new HashMap<>();
        for (Map<String, Object> p : pendientes) {
            cercanos.put(p.get("ID_PEDIDO"), bd.lista(
                    "SELECT r.id_repartidor, r.nombres || ' ' || r.apellidos AS nombre, "
                            + "fn_distancia_km(?, ?, r.latitud, r.longitud) AS distancia "
                            + "FROM repartidor r WHERE r.estado = 'A' AND r.disponible = 'S' AND r.latitud IS NOT NULL "
                            + "ORDER BY distancia",
                    p.get("LAT_NEGOCIO"), p.get("LON_NEGOCIO")));
        }
        model.addAttribute("pendientes", pendientes);
        model.addAttribute("cercanos", cercanos);
        model.addAttribute("kmLimite", bd.valor("SELECT fn_parametro('KM_LIMITE') FROM dual"));
        return "despacho/asignar";
    }

    @PostMapping("/despacho/asignar/{id}/auto")
    public String asignarAutomatico(@PathVariable Long id, RedirectAttributes flash) {
        try {
            List<Object> r = bd.llamar("pkg_despacho.pr_asignar_automatico", new Object[]{id},
                    Types.NUMERIC, Types.VARCHAR);
            flash.addFlashAttribute(r.get(0) == null ? "error" : "exito", "Pedido " + id + ": " + r.get(1));
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/despacho/asignar";
    }

    @PostMapping("/despacho/asignar/{id}/manual")
    public String asignarManual(@PathVariable Long id, @RequestParam Long idRepartidor, RedirectAttributes flash) {
        try {
            bd.llamar("pkg_despacho.pr_asignar_manual", new Object[]{id, idRepartidor});
            flash.addFlashAttribute("exito", "Pedido " + id + " asignado manualmente.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/despacho/asignar";
    }
}

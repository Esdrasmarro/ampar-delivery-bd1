package com.ampar.delivery.controlador;

import com.ampar.delivery.config.Sesion;
import com.ampar.delivery.datos.Bd;
import com.ampar.delivery.datos.ErrorBd;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.sql.Types;
import java.util.List;
import java.util.Map;

@Controller
public class RepartidorController {

    private final Bd bd;

    public RepartidorController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping("/repartidor/entrega")
    public String entrega(Model model) {
        Long idRepartidor = Sesion.actual().getIdRepartidor();
        Map<String, Object> pedido = bd.uno(
                "SELECT * FROM vw_pedido WHERE id_repartidor = ? AND estado IN ('ASIGNADO', 'RECOGIDO', 'EN RUTA') "
                        + "ORDER BY id_pedido FETCH FIRST 1 ROWS ONLY", idRepartidor);
        model.addAttribute("p", pedido);
        model.addAttribute("yo", bd.uno("SELECT * FROM repartidor WHERE id_repartidor = ?", idRepartidor));

        if (pedido != null) {
            model.addAttribute("lineas", bd.lista(
                    "SELECT pr.nombre AS producto, d.cantidad FROM detalle_pedido d "
                            + "JOIN producto pr ON pr.id_producto = d.id_producto WHERE d.id_pedido = ? ORDER BY d.linea",
                    pedido.get("ID_PEDIDO")));
            String siguiente = switch ((String) pedido.get("ESTADO")) {
                case "ASIGNADO" -> "RECOGIDO";
                case "RECOGIDO" -> "EN RUTA";
                default -> "ENTREGADO";
            };
            model.addAttribute("siguiente", siguiente);
            model.addAttribute("ruta", bd.uno(
                    "SELECT fn_distancia_km(lat_repartidor, lon_repartidor, lat_negocio, lon_negocio) AS al_negocio, "
                            + "fn_distancia_km(lat_negocio, lon_negocio, lat_entrega, lon_entrega) AS al_cliente, "
                            + "ruta_km, minutos_estimados FROM vw_pedido WHERE id_pedido = ?",
                    pedido.get("ID_PEDIDO")));
            model.addAttribute("motivos", bd.lista(
                    "SELECT id_motivo, descripcion FROM motivo_cancelacion WHERE aplica_a = 'REPARTIDOR' AND estado = 'A'"));
        }
        model.addAttribute("ultimas", bd.lista(
                "SELECT id_pedido, fecha_pedido, negocio, zona, total FROM vw_pedido "
                        + "WHERE id_repartidor = ? AND estado = 'ENTREGADO' ORDER BY id_pedido DESC FETCH FIRST 5 ROWS ONLY",
                idRepartidor));
        return "repartidor/entrega";
    }

    @PostMapping("/repartidor/entrega/estado")
    public String cambiarEstado(@RequestParam Long idPedido, @RequestParam String estado, RedirectAttributes flash) {
        try {
            bd.llamar("pkg_despacho.pr_cambiar_estado",
                    new Object[]{idPedido, Sesion.actual().getIdRepartidor(), estado});
            flash.addFlashAttribute("exito", "Pedido " + idPedido + " cambió a " + estado
                    + ". Se notificó al cliente por SMS y WhatsApp.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/repartidor/entrega";
    }

    @PostMapping("/repartidor/entrega/ubicacion")
    public String ubicacion(@RequestParam String latitud, @RequestParam String longitud, RedirectAttributes flash) {
        try {
            bd.llamar("pr_actualizar_ubicacion",
                    new Object[]{Sesion.actual().getIdRepartidor(), Bd.aDecimal(latitud), Bd.aDecimal(longitud)});
            flash.addFlashAttribute("exito", "Ubicación actualizada.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/repartidor/entrega";
    }

    @PostMapping("/repartidor/entrega/ubicacion-auto")
    @ResponseBody
    public String ubicacionAutomatica(@RequestParam String latitud, @RequestParam String longitud) {
        try {
            bd.llamar("pr_actualizar_ubicacion",
                    new Object[]{Sesion.actual().getIdRepartidor(), Bd.aDecimal(latitud), Bd.aDecimal(longitud)});
            return "OK";
        } catch (Exception e) {
            return ErrorBd.mensaje(e);
        }
    }

    @PostMapping("/repartidor/entrega/cancelar")
    public String cancelar(@RequestParam Long idPedido, @RequestParam Long idMotivo,
                           @RequestParam(required = false) String observacion, RedirectAttributes flash) {
        try {
            List<Object> r = bd.llamar("pkg_despacho.pr_cancelar_entrega",
                    new Object[]{idPedido, Sesion.actual().getIdRepartidor(), idMotivo, Bd.texto(observacion)},
                    Types.VARCHAR);
            flash.addFlashAttribute("exito", r.get(0));
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/repartidor/entrega";
    }
}

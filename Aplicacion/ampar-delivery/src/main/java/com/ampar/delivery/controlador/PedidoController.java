package com.ampar.delivery.controlador;

import com.ampar.delivery.config.Sesion;
import com.ampar.delivery.datos.Bd;
import com.ampar.delivery.datos.ErrorBd;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Controller
public class PedidoController {

    private final Bd bd;

    public PedidoController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping("/pedidos/nuevo")
    public String negocios(@RequestParam(required = false) String tipo, Model model) {
        String sql = "SELECT n.id_negocio, n.nombre, t.nombre AS tipo, z.nombre || ' - ' || m.nombre AS zona, "
                + "n.radio_cobertura_km, fn_negocio_abierto(n.id_negocio) AS abierto "
                + "FROM negocio n JOIN tipo_negocio t ON t.id_tipo_negocio = n.id_tipo_negocio "
                + "JOIN zona z ON z.id_zona = n.id_zona JOIN municipio m ON m.id_municipio = z.id_municipio "
                + "WHERE n.estado = 'ACTIVO' ";
        if (Bd.texto(tipo) == null) {
            model.addAttribute("negocios", bd.lista(sql + "ORDER BY abierto DESC, n.nombre"));
        } else {
            model.addAttribute("negocios", bd.lista(sql + "AND t.nombre = ? ORDER BY abierto DESC, n.nombre", tipo));
        }
        model.addAttribute("tipos", bd.lista("SELECT nombre FROM tipo_negocio WHERE estado = 'A' ORDER BY nombre"));
        model.addAttribute("tipo", tipo);
        return "pedidos/negocios";
    }

    @GetMapping("/pedidos/nuevo/{idNegocio}")
    public String productos(@PathVariable Long idNegocio, Model model) {
        Map<String, Object> negocio = bd.uno(
                "SELECT n.*, fn_negocio_abierto(n.id_negocio) AS abierto FROM negocio n "
                        + "WHERE n.id_negocio = ? AND n.estado = 'ACTIVO'", idNegocio);
        if (negocio == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }
        model.addAttribute("negocio", negocio);
        model.addAttribute("productos", bd.lista(
                "SELECT * FROM vw_catalogo_producto WHERE id_negocio = ? AND disponible = 'S' "
                        + "ORDER BY categoria, producto", idNegocio));
        model.addAttribute("horario", bd.lista(
                "SELECT dia, hora_apertura, hora_cierre, hace_entrega FROM vw_negocio_horario "
                        + "WHERE id_negocio = ? ORDER BY dia_semana", idNegocio));
        return "pedidos/productos";
    }

    @PostMapping("/pedidos/nuevo/pago")
    public String pago(@RequestParam Long idNegocio, @RequestParam Map<String, String> datos,
                       Model model, RedirectAttributes flash) {
        Map<Long, Integer> cantidades = new LinkedHashMap<>();
        for (Map.Entry<String, String> e : datos.entrySet()) {
            if (e.getKey().startsWith("cant_") && Bd.texto(e.getValue()) != null) {
                int cantidad = Integer.parseInt(e.getValue().trim());
                if (cantidad > 0) {
                    cantidades.put(Long.valueOf(e.getKey().substring(5)), cantidad);
                }
            }
        }
        if (cantidades.isEmpty()) {
            flash.addFlashAttribute("error", "Seleccione al menos un producto.");
            return "redirect:/pedidos/nuevo/" + idNegocio;
        }
        prepararPago(idNegocio, cantidades, model);
        return "pedidos/pago";
    }

    private void prepararPago(Long idNegocio, Map<Long, Integer> cantidades, Model model) {
        Long idCliente = Sesion.actual().getIdCliente();
        List<Map<String, Object>> lineas = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        StringBuilder detalle = new StringBuilder();

        for (Map.Entry<Long, Integer> e : cantidades.entrySet()) {
            Map<String, Object> p = bd.uno("SELECT producto, precio FROM vw_catalogo_producto "
                    + "WHERE id_producto = ? AND id_negocio = ?", e.getKey(), idNegocio);
            if (p == null) {
                continue;
            }
            BigDecimal precio = (BigDecimal) p.get("PRECIO");
            BigDecimal sub = precio.multiply(BigDecimal.valueOf(e.getValue()));
            Map<String, Object> linea = new LinkedHashMap<>();
            linea.put("producto", p.get("PRODUCTO"));
            linea.put("precio", precio);
            linea.put("cantidad", e.getValue());
            linea.put("subtotal", sub);
            lineas.add(linea);
            subtotal = subtotal.add(sub);
            detalle.append(detalle.length() == 0 ? "" : ",").append(e.getKey()).append(":").append(e.getValue());
        }

        BigDecimal envio = (BigDecimal) bd.valor("SELECT fn_parametro('TARIFA_ENVIO') FROM dual");
        BigDecimal cargo = (BigDecimal) bd.valor("SELECT fn_cargo_pendiente(?) FROM dual", idCliente);

        model.addAttribute("negocio", bd.uno("SELECT id_negocio, nombre, radio_cobertura_km FROM negocio WHERE id_negocio = ?", idNegocio));
        model.addAttribute("lineas", lineas);
        model.addAttribute("detalle", detalle.toString());
        model.addAttribute("subtotal", subtotal);
        model.addAttribute("envio", envio);
        model.addAttribute("cargo", cargo);
        model.addAttribute("total", subtotal.add(envio).add(cargo));
        model.addAttribute("metodos", bd.lista("SELECT * FROM metodo_pago WHERE estado = 'A' ORDER BY id_metodo_pago"));
        model.addAttribute("direcciones", bd.lista(
                "SELECT d.id_direccion, d.nombre, d.direccion, z.nombre AS zona, z.zona_roja, "
                        + "fn_distancia_km(n.latitud, n.longitud, d.latitud, d.longitud) AS distancia, "
                        + "LEAST(n.radio_cobertura_km, fn_parametro('KM_LIMITE')) AS limite "
                        + "FROM direccion_cliente d JOIN zona z ON z.id_zona = d.id_zona, negocio n "
                        + "WHERE d.id_cliente = ? AND d.estado = 'A' AND n.id_negocio = ? ORDER BY d.id_direccion",
                idCliente, idNegocio));
    }

    @PostMapping("/pedidos/nuevo/confirmar")
    public String confirmar(@RequestParam Long idNegocio, @RequestParam String detalle,
                            @RequestParam(required = false) Long idDireccion, @RequestParam Long idMetodo,
                            @RequestParam(required = false) String tarjeta,
                            @RequestParam(required = false) String mes,
                            @RequestParam(required = false) String anio,
                            Model model, RedirectAttributes flash) {
        try {
            if (idDireccion == null) {
                throw new IllegalArgumentException("Seleccione la dirección de entrega.");
            }
            List<Object> r = bd.llamar("pkg_pedido.pr_crear_pedido", new Object[]{
                    Sesion.actual().getIdCliente(), idNegocio, idDireccion, idMetodo, detalle,
                    Bd.texto(tarjeta), Bd.aLong(mes), Bd.aLong(anio)
            }, Types.NUMERIC, Types.VARCHAR);
            flash.addFlashAttribute("exito", r.get(1));
            return "redirect:/pedidos/mis-pedidos/" + Bd.aLong(r.get(0));
        } catch (Exception e) {
            Map<Long, Integer> cantidades = new LinkedHashMap<>();
            for (String item : detalle.split(",")) {
                String[] partes = item.split(":");
                cantidades.put(Long.valueOf(partes[0]), Integer.valueOf(partes[1]));
            }
            prepararPago(idNegocio, cantidades, model);
            model.addAttribute("error", e instanceof IllegalArgumentException ? e.getMessage() : ErrorBd.mensaje(e));
            return "pedidos/pago";
        }
    }

    @GetMapping("/pedidos/mis-pedidos")
    public String misPedidos(Model model) {
        model.addAttribute("pedidos", bd.lista(
                "SELECT * FROM vw_pedido WHERE id_cliente = ? ORDER BY id_pedido DESC",
                Sesion.actual().getIdCliente()));
        return "pedidos/mis-pedidos";
    }

    @GetMapping("/pedidos/mis-pedidos/{id}")
    public String detalle(@PathVariable Long id, Model model) {
        Long idCliente = Sesion.actual().getIdCliente();
        Map<String, Object> pedido = bd.uno("SELECT * FROM vw_pedido WHERE id_pedido = ? AND id_cliente = ?", id, idCliente);
        if (pedido == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }
        BigDecimal minutos = (BigDecimal) bd.valor("SELECT pkg_pedido.fn_minutos_transcurridos(?) FROM dual", id);
        BigDecimal limite = (BigDecimal) bd.valor("SELECT fn_parametro('MIN_CANCELACION') FROM dual");
        String estado = (String) pedido.get("ESTADO");
        boolean puedeCancelar = (estado.equals("CONFIRMADO") || estado.equals("ASIGNADO"))
                && minutos.compareTo(limite) <= 0;

        model.addAttribute("p", pedido);
        model.addAttribute("lineas", bd.lista(
                "SELECT d.linea, pr.nombre AS producto, d.cantidad, d.precio_unitario, d.subtotal "
                        + "FROM detalle_pedido d JOIN producto pr ON pr.id_producto = d.id_producto "
                        + "WHERE d.id_pedido = ? ORDER BY d.linea", id));
        model.addAttribute("tracking", bd.lista("SELECT * FROM vw_tracking WHERE id_pedido = ? ORDER BY id_historial", id));
        model.addAttribute("pagos", bd.lista("SELECT * FROM pago WHERE id_pedido = ? ORDER BY id_pago", id));
        model.addAttribute("calificacion", bd.uno("SELECT * FROM calificacion WHERE id_pedido = ?", id));
        model.addAttribute("cancelacion", bd.uno("SELECT * FROM vw_cancelacion_pedido WHERE id_pedido = ?", id));
        model.addAttribute("motivos", bd.lista(
                "SELECT id_motivo, descripcion FROM motivo_cancelacion WHERE aplica_a = 'CLIENTE' AND estado = 'A'"));
        model.addAttribute("minutos", minutos);
        model.addAttribute("limite", limite);
        model.addAttribute("puedeCancelar", puedeCancelar);
        model.addAttribute("activo", List.of("CONFIRMADO", "ASIGNADO", "RECOGIDO", "EN RUTA").contains(estado));
        return "pedidos/detalle";
    }

    @PostMapping("/pedidos/mis-pedidos/{id}/cancelar")
    public String cancelar(@PathVariable Long id, @RequestParam Long idMotivo, RedirectAttributes flash) {
        try {
            List<Object> r = bd.llamar("pkg_pedido.pr_cancelar_pedido",
                    new Object[]{id, Sesion.actual().getIdCliente(), idMotivo}, Types.VARCHAR);
            flash.addFlashAttribute("exito", r.get(0));
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/pedidos/mis-pedidos/" + id;
    }

    @PostMapping("/pedidos/mis-pedidos/{id}/calificar")
    public String calificar(@PathVariable Long id, @RequestParam Integer puntuacion,
                            @RequestParam(required = false) String comentario, RedirectAttributes flash) {
        try {
            bd.llamar("pkg_pedido.pr_calificar",
                    new Object[]{id, Sesion.actual().getIdCliente(), puntuacion, Bd.texto(comentario)});
            flash.addFlashAttribute("exito", "¡Gracias por calificar al repartidor!");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/pedidos/mis-pedidos/" + id;
    }
}

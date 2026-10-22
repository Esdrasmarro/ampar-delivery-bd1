package com.ampar.delivery.catalogo;

import com.ampar.delivery.datos.Bd;
import com.ampar.delivery.datos.ErrorBd;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/catalogos/estados-pedido")
public class EstadoPedidoController {

    private final Bd bd;

    public EstadoPedidoController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping
    public String lista(@RequestParam(required = false) String buscar, Model model) {
        String filtro = buscar == null ? "" : buscar.trim().toLowerCase();
        String sql = "SELECT e.id_estado_pedido, e.nombre, e.orden "
                + "FROM estado_pedido e "
                + "WHERE LOWER(e.nombre) LIKE ? ORDER BY e.id_estado_pedido";
        model.addAttribute("filas", bd.lista(sql, "%" + filtro + "%"));
        model.addAttribute("buscar", buscar);
        return "catalogos/estados-pedido-lista";
    }

    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id, Model model) {
        Map<String, Object> fila = bd.uno("SELECT * FROM estado_pedido WHERE id_estado_pedido = ?", id);
        if (fila == null) {
            return "redirect:/catalogos/estados-pedido";
        }
        return formulario(fila, model);
    }

    private String formulario(Map<String, Object> fila, Model model) {
        model.addAttribute("fila", fila);
        return "catalogos/estados-pedido-form";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(required = false) Long id,
                          @RequestParam String nombre,
                          @RequestParam Long orden,
                          Model model,
                          RedirectAttributes flash) {
        try {
            bd.ejecutar("UPDATE estado_pedido SET nombre = ?, orden = ? "
                    + "WHERE id_estado_pedido = ?",
                    nombre, orden, id);
            flash.addFlashAttribute("exito", "Registro modificado correctamente.");
            return "redirect:/catalogos/estados-pedido";
        } catch (Exception e) {
            Map<String, Object> fila = new HashMap<>();
            fila.put("ID_ESTADO_PEDIDO", id);
            fila.put("NOMBRE", nombre);
            fila.put("ORDEN", orden);
            model.addAttribute("error", ErrorBd.mensaje(e));
            return formulario(fila, model);
        }
    }
}

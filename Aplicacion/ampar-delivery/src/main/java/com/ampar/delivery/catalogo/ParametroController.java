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

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/catalogos/parametros")
public class ParametroController {

    private final Bd bd;

    public ParametroController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping
    public String lista(@RequestParam(required = false) String buscar, Model model) {
        String filtro = buscar == null ? "" : buscar.trim().toLowerCase();
        String sql = "SELECT p.id_parametro, p.codigo, p.valor, p.descripcion "
                + "FROM parametro p "
                + "WHERE LOWER(p.codigo) LIKE ? ORDER BY p.id_parametro";
        model.addAttribute("filas", bd.lista(sql, "%" + filtro + "%"));
        model.addAttribute("buscar", buscar);
        return "catalogos/parametros-lista";
    }

    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id, Model model) {
        Map<String, Object> fila = bd.uno("SELECT * FROM parametro WHERE id_parametro = ?", id);
        if (fila == null) {
            return "redirect:/catalogos/parametros";
        }
        return formulario(fila, model);
    }

    private String formulario(Map<String, Object> fila, Model model) {
        model.addAttribute("fila", fila);
        return "catalogos/parametros-form";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(required = false) Long id,
                          @RequestParam String codigo,
                          @RequestParam BigDecimal valor,
                          @RequestParam String descripcion,
                          Model model,
                          RedirectAttributes flash) {
        try {
            bd.ejecutar("UPDATE parametro SET codigo = ?, valor = ?, descripcion = ? "
                    + "WHERE id_parametro = ?",
                    codigo, valor, descripcion, id);
            flash.addFlashAttribute("exito", "Registro modificado correctamente.");
            return "redirect:/catalogos/parametros";
        } catch (Exception e) {
            Map<String, Object> fila = new HashMap<>();
            fila.put("ID_PARAMETRO", id);
            fila.put("CODIGO", codigo);
            fila.put("VALOR", valor);
            fila.put("DESCRIPCION", descripcion);
            model.addAttribute("error", ErrorBd.mensaje(e));
            return formulario(fila, model);
        }
    }
}

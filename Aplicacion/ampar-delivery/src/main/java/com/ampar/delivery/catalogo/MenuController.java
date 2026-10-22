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
@RequestMapping("/seguridad/menus")
public class MenuController {

    private final Bd bd;

    public MenuController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping
    public String lista(@RequestParam(required = false) String buscar, Model model) {
        String filtro = buscar == null ? "" : buscar.trim().toLowerCase();
        String sql = "SELECT me.id_menu, mo.nombre AS modulo, me.nombre, me.url, me.orden, me.estado "
                + "FROM menu me "
                + "JOIN modulo mo ON mo.id_modulo = me.id_modulo "
                + "WHERE LOWER(me.nombre) LIKE ? ORDER BY me.id_menu";
        model.addAttribute("filas", bd.lista(sql, "%" + filtro + "%"));
        model.addAttribute("buscar", buscar);
        return "catalogos/menus-lista";
    }

    @GetMapping("/nuevo")
    public String nuevo(Model model) {
        Map<String, Object> fila = new HashMap<>();
        fila.put("ESTADO", "A");
        return formulario(fila, model);
    }

    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id, Model model) {
        Map<String, Object> fila = bd.uno("SELECT * FROM menu WHERE id_menu = ?", id);
        if (fila == null) {
            return "redirect:/seguridad/menus";
        }
        return formulario(fila, model);
    }

    private String formulario(Map<String, Object> fila, Model model) {
        model.addAttribute("fila", fila);
        model.addAttribute("modulos", bd.lista("SELECT id_modulo AS id, nombre AS texto FROM modulo ORDER BY orden"));
        return "catalogos/menus-form";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(required = false) Long id,
                          @RequestParam Long idModulo,
                          @RequestParam String nombre,
                          @RequestParam String url,
                          @RequestParam Long orden,
                          @RequestParam String estado,
                          Model model,
                          RedirectAttributes flash) {
        try {
            if (id == null) {
                bd.ejecutar("INSERT INTO menu (id_modulo, nombre, url, orden, estado) "
                        + "VALUES (?, ?, ?, ?, ?)",
                        idModulo, nombre, url, orden, estado);
                flash.addFlashAttribute("exito", "Registro creado correctamente.");
            } else {
                bd.ejecutar("UPDATE menu SET id_modulo = ?, nombre = ?, url = ?, orden = ?, estado = ? "
                        + "WHERE id_menu = ?",
                        idModulo, nombre, url, orden, estado, id);
                flash.addFlashAttribute("exito", "Registro modificado correctamente.");
            }
            return "redirect:/seguridad/menus";
        } catch (Exception e) {
            Map<String, Object> fila = new HashMap<>();
            fila.put("ID_MENU", id);
            fila.put("ID_MODULO", idModulo);
            fila.put("NOMBRE", nombre);
            fila.put("URL", url);
            fila.put("ORDEN", orden);
            fila.put("ESTADO", estado);
            model.addAttribute("error", ErrorBd.mensaje(e));
            return formulario(fila, model);
        }
    }

    @PostMapping("/baja/{id}")
    public String baja(@PathVariable Long id, RedirectAttributes flash) {
        try {
            bd.ejecutar("UPDATE menu SET estado = 'I' WHERE id_menu = ?", id);
            flash.addFlashAttribute("exito", "Registro dado de baja. Puede reactivarlo editándolo.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/seguridad/menus";
    }
}

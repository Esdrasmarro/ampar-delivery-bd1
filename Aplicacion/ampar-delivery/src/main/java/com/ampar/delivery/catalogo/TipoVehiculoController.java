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
@RequestMapping("/catalogos/tipos-vehiculo")
public class TipoVehiculoController {

    private final Bd bd;

    public TipoVehiculoController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping
    public String lista(@RequestParam(required = false) String buscar, Model model) {
        String filtro = buscar == null ? "" : buscar.trim().toLowerCase();
        String sql = "SELECT t.id_tipo_vehiculo, t.nombre, t.estado "
                + "FROM tipo_vehiculo t "
                + "WHERE LOWER(t.nombre) LIKE ? ORDER BY t.id_tipo_vehiculo";
        model.addAttribute("filas", bd.lista(sql, "%" + filtro + "%"));
        model.addAttribute("buscar", buscar);
        return "catalogos/tipos-vehiculo-lista";
    }

    @GetMapping("/nuevo")
    public String nuevo(Model model) {
        Map<String, Object> fila = new HashMap<>();
        fila.put("ESTADO", "A");
        return formulario(fila, model);
    }

    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id, Model model) {
        Map<String, Object> fila = bd.uno("SELECT * FROM tipo_vehiculo WHERE id_tipo_vehiculo = ?", id);
        if (fila == null) {
            return "redirect:/catalogos/tipos-vehiculo";
        }
        return formulario(fila, model);
    }

    private String formulario(Map<String, Object> fila, Model model) {
        model.addAttribute("fila", fila);
        return "catalogos/tipos-vehiculo-form";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(required = false) Long id,
                          @RequestParam String nombre,
                          @RequestParam String estado,
                          Model model,
                          RedirectAttributes flash) {
        try {
            if (id == null) {
                bd.ejecutar("INSERT INTO tipo_vehiculo (nombre, estado) "
                        + "VALUES (?, ?)",
                        nombre, estado);
                flash.addFlashAttribute("exito", "Registro creado correctamente.");
            } else {
                bd.ejecutar("UPDATE tipo_vehiculo SET nombre = ?, estado = ? "
                        + "WHERE id_tipo_vehiculo = ?",
                        nombre, estado, id);
                flash.addFlashAttribute("exito", "Registro modificado correctamente.");
            }
            return "redirect:/catalogos/tipos-vehiculo";
        } catch (Exception e) {
            Map<String, Object> fila = new HashMap<>();
            fila.put("ID_TIPO_VEHICULO", id);
            fila.put("NOMBRE", nombre);
            fila.put("ESTADO", estado);
            model.addAttribute("error", ErrorBd.mensaje(e));
            return formulario(fila, model);
        }
    }

    @PostMapping("/baja/{id}")
    public String baja(@PathVariable Long id, RedirectAttributes flash) {
        try {
            bd.ejecutar("UPDATE tipo_vehiculo SET estado = 'I' WHERE id_tipo_vehiculo = ?", id);
            flash.addFlashAttribute("exito", "Registro dado de baja. Puede reactivarlo editándolo.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/catalogos/tipos-vehiculo";
    }
}

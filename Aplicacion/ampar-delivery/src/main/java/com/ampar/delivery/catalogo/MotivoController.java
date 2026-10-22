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
@RequestMapping("/catalogos/motivos")
public class MotivoController {

    private final Bd bd;

    public MotivoController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping
    public String lista(@RequestParam(required = false) String buscar, Model model) {
        String filtro = buscar == null ? "" : buscar.trim().toLowerCase();
        String sql = "SELECT mo.id_motivo, mo.descripcion, mo.aplica_a, mo.estado "
                + "FROM motivo_cancelacion mo "
                + "WHERE LOWER(mo.descripcion) LIKE ? ORDER BY mo.id_motivo";
        model.addAttribute("filas", bd.lista(sql, "%" + filtro + "%"));
        model.addAttribute("buscar", buscar);
        return "catalogos/motivos-lista";
    }

    @GetMapping("/nuevo")
    public String nuevo(Model model) {
        Map<String, Object> fila = new HashMap<>();
        fila.put("ESTADO", "A");
        return formulario(fila, model);
    }

    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id, Model model) {
        Map<String, Object> fila = bd.uno("SELECT * FROM motivo_cancelacion WHERE id_motivo = ?", id);
        if (fila == null) {
            return "redirect:/catalogos/motivos";
        }
        return formulario(fila, model);
    }

    private String formulario(Map<String, Object> fila, Model model) {
        model.addAttribute("fila", fila);
        return "catalogos/motivos-form";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(required = false) Long id,
                          @RequestParam String descripcion,
                          @RequestParam String aplicaA,
                          @RequestParam String estado,
                          Model model,
                          RedirectAttributes flash) {
        try {
            if (id == null) {
                bd.ejecutar("INSERT INTO motivo_cancelacion (descripcion, aplica_a, estado) "
                        + "VALUES (?, ?, ?)",
                        descripcion, aplicaA, estado);
                flash.addFlashAttribute("exito", "Registro creado correctamente.");
            } else {
                bd.ejecutar("UPDATE motivo_cancelacion SET descripcion = ?, aplica_a = ?, estado = ? "
                        + "WHERE id_motivo = ?",
                        descripcion, aplicaA, estado, id);
                flash.addFlashAttribute("exito", "Registro modificado correctamente.");
            }
            return "redirect:/catalogos/motivos";
        } catch (Exception e) {
            Map<String, Object> fila = new HashMap<>();
            fila.put("ID_MOTIVO", id);
            fila.put("DESCRIPCION", descripcion);
            fila.put("APLICA_A", aplicaA);
            fila.put("ESTADO", estado);
            model.addAttribute("error", ErrorBd.mensaje(e));
            return formulario(fila, model);
        }
    }

    @PostMapping("/baja/{id}")
    public String baja(@PathVariable Long id, RedirectAttributes flash) {
        try {
            bd.ejecutar("UPDATE motivo_cancelacion SET estado = 'I' WHERE id_motivo = ?", id);
            flash.addFlashAttribute("exito", "Registro dado de baja. Puede reactivarlo editándolo.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/catalogos/motivos";
    }
}

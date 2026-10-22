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
@RequestMapping("/catalogos/zonas")
public class ZonaController {

    private final Bd bd;

    public ZonaController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping
    public String lista(@RequestParam(required = false) String buscar, Model model) {
        String filtro = buscar == null ? "" : buscar.trim().toLowerCase();
        String sql = "SELECT z.id_zona, m.nombre AS municipio, z.nombre, z.zona_roja, z.estado "
                + "FROM zona z "
                + "JOIN municipio m ON m.id_municipio = z.id_municipio "
                + "WHERE LOWER(z.nombre) LIKE ? ORDER BY z.id_zona";
        model.addAttribute("filas", bd.lista(sql, "%" + filtro + "%"));
        model.addAttribute("buscar", buscar);
        return "catalogos/zonas-lista";
    }

    @GetMapping("/nuevo")
    public String nuevo(Model model) {
        Map<String, Object> fila = new HashMap<>();
        fila.put("ESTADO", "A");
        return formulario(fila, model);
    }

    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id, Model model) {
        Map<String, Object> fila = bd.uno("SELECT * FROM zona WHERE id_zona = ?", id);
        if (fila == null) {
            return "redirect:/catalogos/zonas";
        }
        return formulario(fila, model);
    }

    private String formulario(Map<String, Object> fila, Model model) {
        model.addAttribute("fila", fila);
        model.addAttribute("municipios", bd.lista("SELECT id_municipio AS id, nombre AS texto FROM municipio ORDER BY nombre"));
        return "catalogos/zonas-form";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(required = false) Long id,
                          @RequestParam Long idMunicipio,
                          @RequestParam String nombre,
                          @RequestParam String zonaRoja,
                          @RequestParam(required = false) String observacion,
                          @RequestParam String estado,
                          Model model,
                          RedirectAttributes flash) {
        try {
            if (id == null) {
                bd.ejecutar("INSERT INTO zona (id_municipio, nombre, zona_roja, observacion, estado) "
                        + "VALUES (?, ?, ?, ?, ?)",
                        idMunicipio, nombre, zonaRoja, Bd.texto(observacion), estado);
                flash.addFlashAttribute("exito", "Registro creado correctamente.");
            } else {
                bd.ejecutar("UPDATE zona SET id_municipio = ?, nombre = ?, zona_roja = ?, observacion = ?, estado = ? "
                        + "WHERE id_zona = ?",
                        idMunicipio, nombre, zonaRoja, Bd.texto(observacion), estado, id);
                flash.addFlashAttribute("exito", "Registro modificado correctamente.");
            }
            return "redirect:/catalogos/zonas";
        } catch (Exception e) {
            Map<String, Object> fila = new HashMap<>();
            fila.put("ID_ZONA", id);
            fila.put("ID_MUNICIPIO", idMunicipio);
            fila.put("NOMBRE", nombre);
            fila.put("ZONA_ROJA", zonaRoja);
            fila.put("OBSERVACION", observacion);
            fila.put("ESTADO", estado);
            model.addAttribute("error", ErrorBd.mensaje(e));
            return formulario(fila, model);
        }
    }

    @PostMapping("/baja/{id}")
    public String baja(@PathVariable Long id, RedirectAttributes flash) {
        try {
            bd.ejecutar("UPDATE zona SET estado = 'I' WHERE id_zona = ?", id);
            flash.addFlashAttribute("exito", "Registro dado de baja. Puede reactivarlo editándolo.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/catalogos/zonas";
    }
}

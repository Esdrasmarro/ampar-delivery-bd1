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
@RequestMapping("/catalogos/municipios")
public class MunicipioController {

    private final Bd bd;

    public MunicipioController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping
    public String lista(@RequestParam(required = false) String buscar, Model model) {
        String filtro = buscar == null ? "" : buscar.trim().toLowerCase();
        String sql = "SELECT m.id_municipio, d.nombre AS departamento, m.nombre, m.estado "
                + "FROM municipio m "
                + "JOIN departamento d ON d.id_departamento = m.id_departamento "
                + "WHERE LOWER(m.nombre) LIKE ? ORDER BY m.id_municipio";
        model.addAttribute("filas", bd.lista(sql, "%" + filtro + "%"));
        model.addAttribute("buscar", buscar);
        return "catalogos/municipios-lista";
    }

    @GetMapping("/nuevo")
    public String nuevo(Model model) {
        Map<String, Object> fila = new HashMap<>();
        fila.put("ESTADO", "A");
        return formulario(fila, model);
    }

    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id, Model model) {
        Map<String, Object> fila = bd.uno("SELECT * FROM municipio WHERE id_municipio = ?", id);
        if (fila == null) {
            return "redirect:/catalogos/municipios";
        }
        return formulario(fila, model);
    }

    private String formulario(Map<String, Object> fila, Model model) {
        model.addAttribute("fila", fila);
        model.addAttribute("departamentos", bd.lista("SELECT id_departamento AS id, nombre AS texto FROM departamento ORDER BY nombre"));
        return "catalogos/municipios-form";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(required = false) Long id,
                          @RequestParam Long idDepartamento,
                          @RequestParam String nombre,
                          @RequestParam String estado,
                          Model model,
                          RedirectAttributes flash) {
        try {
            if (id == null) {
                bd.ejecutar("INSERT INTO municipio (id_departamento, nombre, estado) "
                        + "VALUES (?, ?, ?)",
                        idDepartamento, nombre, estado);
                flash.addFlashAttribute("exito", "Registro creado correctamente.");
            } else {
                bd.ejecutar("UPDATE municipio SET id_departamento = ?, nombre = ?, estado = ? "
                        + "WHERE id_municipio = ?",
                        idDepartamento, nombre, estado, id);
                flash.addFlashAttribute("exito", "Registro modificado correctamente.");
            }
            return "redirect:/catalogos/municipios";
        } catch (Exception e) {
            Map<String, Object> fila = new HashMap<>();
            fila.put("ID_MUNICIPIO", id);
            fila.put("ID_DEPARTAMENTO", idDepartamento);
            fila.put("NOMBRE", nombre);
            fila.put("ESTADO", estado);
            model.addAttribute("error", ErrorBd.mensaje(e));
            return formulario(fila, model);
        }
    }

    @PostMapping("/baja/{id}")
    public String baja(@PathVariable Long id, RedirectAttributes flash) {
        try {
            bd.ejecutar("UPDATE municipio SET estado = 'I' WHERE id_municipio = ?", id);
            flash.addFlashAttribute("exito", "Registro dado de baja. Puede reactivarlo editándolo.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/catalogos/municipios";
    }
}

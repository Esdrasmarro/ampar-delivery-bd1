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
@RequestMapping("/negocios/lista")
public class NegocioCatalogoController {

    private final Bd bd;

    public NegocioCatalogoController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping
    public String lista(@RequestParam(required = false) String buscar, Model model) {
        String filtro = buscar == null ? "" : buscar.trim().toLowerCase();
        String sql = "SELECT n.id_negocio, tn.nombre AS tipo, z.nombre AS zona, n.nombre, n.nit, n.telefono, n.radio_cobertura_km, n.estado "
                + "FROM negocio n "
                + "JOIN tipo_negocio tn ON tn.id_tipo_negocio = n.id_tipo_negocio "
                + "JOIN zona z ON z.id_zona = n.id_zona "
                + "WHERE LOWER(n.nombre) LIKE ? ORDER BY n.id_negocio";
        model.addAttribute("filas", bd.lista(sql, "%" + filtro + "%"));
        model.addAttribute("buscar", buscar);
        return "catalogos/negocios-lista";
    }

    @GetMapping("/nuevo")
    public String nuevo(Model model) {
        Map<String, Object> fila = new HashMap<>();
        fila.put("ESTADO", "ACTIVO");
        return formulario(fila, model);
    }

    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id, Model model) {
        Map<String, Object> fila = bd.uno("SELECT * FROM negocio WHERE id_negocio = ?", id);
        if (fila == null) {
            return "redirect:/negocios/lista";
        }
        return formulario(fila, model);
    }

    private String formulario(Map<String, Object> fila, Model model) {
        model.addAttribute("fila", fila);
        model.addAttribute("tipos", bd.lista("SELECT id_tipo_negocio AS id, nombre AS texto FROM tipo_negocio ORDER BY nombre"));
        model.addAttribute("zonas", bd.lista("SELECT z.id_zona AS id, z.nombre || ' - ' || m.nombre AS texto FROM zona z JOIN municipio m ON m.id_municipio = z.id_municipio ORDER BY m.nombre, z.id_zona"));
        return "catalogos/negocios-form";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(required = false) Long id,
                          @RequestParam Long idTipoNegocio,
                          @RequestParam Long idZona,
                          @RequestParam String nombre,
                          @RequestParam String nit,
                          @RequestParam String propietario,
                          @RequestParam String telefono,
                          @RequestParam String correo,
                          @RequestParam String direccion,
                          @RequestParam BigDecimal latitud,
                          @RequestParam BigDecimal longitud,
                          @RequestParam BigDecimal radioCoberturaKm,
                          @RequestParam String estado,
                          Model model,
                          RedirectAttributes flash) {
        try {
            if (id == null) {
                bd.ejecutar("INSERT INTO negocio (id_tipo_negocio, id_zona, nombre, nit, propietario, telefono, correo, direccion, latitud, longitud, radio_cobertura_km, estado) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                        idTipoNegocio, idZona, nombre, nit, propietario, telefono, correo, direccion, latitud, longitud, radioCoberturaKm, estado);
                flash.addFlashAttribute("exito", "Registro creado correctamente.");
            } else {
                bd.ejecutar("UPDATE negocio SET id_tipo_negocio = ?, id_zona = ?, nombre = ?, nit = ?, propietario = ?, telefono = ?, correo = ?, direccion = ?, latitud = ?, longitud = ?, radio_cobertura_km = ?, estado = ? "
                        + "WHERE id_negocio = ?",
                        idTipoNegocio, idZona, nombre, nit, propietario, telefono, correo, direccion, latitud, longitud, radioCoberturaKm, estado, id);
                flash.addFlashAttribute("exito", "Registro modificado correctamente.");
            }
            return "redirect:/negocios/lista";
        } catch (Exception e) {
            Map<String, Object> fila = new HashMap<>();
            fila.put("ID_NEGOCIO", id);
            fila.put("ID_TIPO_NEGOCIO", idTipoNegocio);
            fila.put("ID_ZONA", idZona);
            fila.put("NOMBRE", nombre);
            fila.put("NIT", nit);
            fila.put("PROPIETARIO", propietario);
            fila.put("TELEFONO", telefono);
            fila.put("CORREO", correo);
            fila.put("DIRECCION", direccion);
            fila.put("LATITUD", latitud);
            fila.put("LONGITUD", longitud);
            fila.put("RADIO_COBERTURA_KM", radioCoberturaKm);
            fila.put("ESTADO", estado);
            model.addAttribute("error", ErrorBd.mensaje(e));
            return formulario(fila, model);
        }
    }

    @PostMapping("/baja/{id}")
    public String baja(@PathVariable Long id, RedirectAttributes flash) {
        try {
            bd.ejecutar("UPDATE negocio SET estado = 'INACTIVO' WHERE id_negocio = ?", id);
            flash.addFlashAttribute("exito", "Registro dado de baja. Puede reactivarlo editándolo.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/negocios/lista";
    }
}

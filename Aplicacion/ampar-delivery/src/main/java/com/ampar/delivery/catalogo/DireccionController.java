package com.ampar.delivery.catalogo;

import com.ampar.delivery.config.Sesion;
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
@RequestMapping("/pedidos/direcciones")
public class DireccionController {

    private final Bd bd;

    public DireccionController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping
    public String lista(@RequestParam(required = false) String buscar, Model model) {
        String filtro = buscar == null ? "" : buscar.trim().toLowerCase();
        String sql = "SELECT d.id_direccion, z.nombre AS zona, d.nombre, d.direccion, d.referencia, d.estado "
                + "FROM direccion_cliente d "
                + "JOIN zona z ON z.id_zona = d.id_zona "
                + "WHERE d.id_cliente = ? AND LOWER(d.nombre) LIKE ? ORDER BY d.id_direccion";
        model.addAttribute("filas", bd.lista(sql, Sesion.actual().getIdCliente(), "%" + filtro + "%"));
        model.addAttribute("buscar", buscar);
        return "catalogos/direcciones-lista";
    }

    @GetMapping("/nuevo")
    public String nuevo(Model model) {
        Map<String, Object> fila = new HashMap<>();
        fila.put("ESTADO", "A");
        return formulario(fila, model);
    }

    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id, Model model) {
        Map<String, Object> fila = bd.uno("SELECT * FROM direccion_cliente WHERE id_direccion = ? AND id_cliente = ?",
                id, Sesion.actual().getIdCliente());
        if (fila == null) {
            return "redirect:/pedidos/direcciones";
        }
        return formulario(fila, model);
    }

    private String formulario(Map<String, Object> fila, Model model) {
        model.addAttribute("fila", fila);
        model.addAttribute("zonas", bd.lista("SELECT z.id_zona AS id, z.nombre || ' - ' || m.nombre AS texto FROM zona z JOIN municipio m ON m.id_municipio = z.id_municipio ORDER BY m.nombre, z.id_zona"));
        return "catalogos/direcciones-form";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(required = false) Long id,
                          @RequestParam Long idZona,
                          @RequestParam String nombre,
                          @RequestParam String direccion,
                          @RequestParam(required = false) String referencia,
                          @RequestParam BigDecimal latitud,
                          @RequestParam BigDecimal longitud,
                          @RequestParam String estado,
                          Model model,
                          RedirectAttributes flash) {
        try {
            if (id == null) {
                bd.ejecutar("INSERT INTO direccion_cliente (id_zona, nombre, direccion, referencia, latitud, longitud, estado, id_cliente) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                        idZona, nombre, direccion, Bd.texto(referencia), latitud, longitud, estado, Sesion.actual().getIdCliente());
                flash.addFlashAttribute("exito", "Registro creado correctamente.");
            } else {
                bd.ejecutar("UPDATE direccion_cliente SET id_zona = ?, nombre = ?, direccion = ?, referencia = ?, latitud = ?, longitud = ?, estado = ? "
                        + "WHERE id_direccion = ? AND id_cliente = ?",
                        idZona, nombre, direccion, Bd.texto(referencia), latitud, longitud, estado, id, Sesion.actual().getIdCliente());
                flash.addFlashAttribute("exito", "Registro modificado correctamente.");
            }
            return "redirect:/pedidos/direcciones";
        } catch (Exception e) {
            Map<String, Object> fila = new HashMap<>();
            fila.put("ID_DIRECCION", id);
            fila.put("ID_ZONA", idZona);
            fila.put("NOMBRE", nombre);
            fila.put("DIRECCION", direccion);
            fila.put("REFERENCIA", referencia);
            fila.put("LATITUD", latitud);
            fila.put("LONGITUD", longitud);
            fila.put("ESTADO", estado);
            model.addAttribute("error", ErrorBd.mensaje(e));
            return formulario(fila, model);
        }
    }

    @PostMapping("/baja/{id}")
    public String baja(@PathVariable Long id, RedirectAttributes flash) {
        try {
            bd.ejecutar("UPDATE direccion_cliente SET estado = 'I' WHERE id_direccion = ? AND id_cliente = ?",
                    id, Sesion.actual().getIdCliente());
            flash.addFlashAttribute("exito", "Registro dado de baja. Puede reactivarlo editándolo.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/pedidos/direcciones";
    }
}

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
@RequestMapping("/despacho/repartidores")
public class RepartidorCatalogoController {

    private final Bd bd;

    public RepartidorCatalogoController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping
    public String lista(@RequestParam(required = false) String buscar, Model model) {
        String filtro = buscar == null ? "" : buscar.trim().toLowerCase();
        String sql = "SELECT r.id_repartidor, tv.nombre AS vehiculo, r.nombres, r.apellidos, r.dpi, r.telefono, r.placa, r.disponible, r.estado "
                + "FROM repartidor r "
                + "JOIN tipo_vehiculo tv ON tv.id_tipo_vehiculo = r.id_tipo_vehiculo "
                + "WHERE LOWER(r.nombres || ' ' || r.apellidos) LIKE ? ORDER BY r.id_repartidor";
        model.addAttribute("filas", bd.lista(sql, "%" + filtro + "%"));
        model.addAttribute("buscar", buscar);
        return "catalogos/repartidores-lista";
    }

    @GetMapping("/nuevo")
    public String nuevo(Model model) {
        Map<String, Object> fila = new HashMap<>();
        fila.put("ESTADO", "A");
        return formulario(fila, model);
    }

    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id, Model model) {
        Map<String, Object> fila = bd.uno("SELECT * FROM repartidor WHERE id_repartidor = ?", id);
        if (fila == null) {
            return "redirect:/despacho/repartidores";
        }
        return formulario(fila, model);
    }

    private String formulario(Map<String, Object> fila, Model model) {
        model.addAttribute("fila", fila);
        model.addAttribute("vehiculos", bd.lista("SELECT id_tipo_vehiculo AS id, nombre AS texto FROM tipo_vehiculo ORDER BY nombre"));
        return "catalogos/repartidores-form";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(required = false) Long id,
                          @RequestParam Long idTipoVehiculo,
                          @RequestParam String nombres,
                          @RequestParam String apellidos,
                          @RequestParam String dpi,
                          @RequestParam String telefono,
                          @RequestParam String licencia,
                          @RequestParam(required = false) String placa,
                          @RequestParam(required = false) BigDecimal latitud,
                          @RequestParam(required = false) BigDecimal longitud,
                          @RequestParam String disponible,
                          @RequestParam String estado,
                          Model model,
                          RedirectAttributes flash) {
        try {
            if (id == null) {
                bd.ejecutar("INSERT INTO repartidor (id_tipo_vehiculo, nombres, apellidos, dpi, telefono, licencia, placa, latitud, longitud, disponible, estado) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                        idTipoVehiculo, nombres, apellidos, dpi, telefono, licencia, Bd.texto(placa), latitud, longitud, disponible, estado);
                flash.addFlashAttribute("exito", "Registro creado correctamente.");
            } else {
                bd.ejecutar("UPDATE repartidor SET id_tipo_vehiculo = ?, nombres = ?, apellidos = ?, dpi = ?, telefono = ?, licencia = ?, placa = ?, latitud = ?, longitud = ?, disponible = ?, estado = ? "
                        + "WHERE id_repartidor = ?",
                        idTipoVehiculo, nombres, apellidos, dpi, telefono, licencia, Bd.texto(placa), latitud, longitud, disponible, estado, id);
                flash.addFlashAttribute("exito", "Registro modificado correctamente.");
            }
            return "redirect:/despacho/repartidores";
        } catch (Exception e) {
            Map<String, Object> fila = new HashMap<>();
            fila.put("ID_REPARTIDOR", id);
            fila.put("ID_TIPO_VEHICULO", idTipoVehiculo);
            fila.put("NOMBRES", nombres);
            fila.put("APELLIDOS", apellidos);
            fila.put("DPI", dpi);
            fila.put("TELEFONO", telefono);
            fila.put("LICENCIA", licencia);
            fila.put("PLACA", placa);
            fila.put("LATITUD", latitud);
            fila.put("LONGITUD", longitud);
            fila.put("DISPONIBLE", disponible);
            fila.put("ESTADO", estado);
            model.addAttribute("error", ErrorBd.mensaje(e));
            return formulario(fila, model);
        }
    }

    @PostMapping("/baja/{id}")
    public String baja(@PathVariable Long id, RedirectAttributes flash) {
        try {
            bd.ejecutar("UPDATE repartidor SET estado = 'I' WHERE id_repartidor = ?", id);
            flash.addFlashAttribute("exito", "Registro dado de baja. Puede reactivarlo editándolo.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/despacho/repartidores";
    }
}

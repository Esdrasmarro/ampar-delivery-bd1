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
@RequestMapping("/negocios/productos")
public class ProductoController {

    private final Bd bd;

    public ProductoController(Bd bd) {
        this.bd = bd;
    }

    @GetMapping
    public String lista(@RequestParam(required = false) String buscar, Model model) {
        String filtro = buscar == null ? "" : buscar.trim().toLowerCase();
        String sql = "SELECT p.id_producto, c.nombre AS categoria, p.nombre, p.precio, p.disponible, p.estado "
                + "FROM producto p "
                + "JOIN categoria_producto c ON c.id_categoria = p.id_categoria "
                + "WHERE p.id_negocio = ? AND LOWER(p.nombre) LIKE ? ORDER BY p.id_producto";
        model.addAttribute("filas", bd.lista(sql, Sesion.actual().getIdNegocio(), "%" + filtro + "%"));
        model.addAttribute("buscar", buscar);
        return "catalogos/productos-lista";
    }

    @GetMapping("/nuevo")
    public String nuevo(Model model) {
        Map<String, Object> fila = new HashMap<>();
        fila.put("ESTADO", "A");
        return formulario(fila, model);
    }

    @GetMapping("/editar/{id}")
    public String editar(@PathVariable Long id, Model model) {
        Map<String, Object> fila = bd.uno("SELECT * FROM producto WHERE id_producto = ? AND id_negocio = ?",
                id, Sesion.actual().getIdNegocio());
        if (fila == null) {
            return "redirect:/negocios/productos";
        }
        return formulario(fila, model);
    }

    private String formulario(Map<String, Object> fila, Model model) {
        model.addAttribute("fila", fila);
        model.addAttribute("categorias", bd.lista("SELECT id_categoria AS id, nombre AS texto FROM categoria_producto ORDER BY nombre"));
        return "catalogos/productos-form";
    }

    @PostMapping("/guardar")
    public String guardar(@RequestParam(required = false) Long id,
                          @RequestParam Long idCategoria,
                          @RequestParam String nombre,
                          @RequestParam(required = false) String descripcion,
                          @RequestParam BigDecimal precio,
                          @RequestParam String disponible,
                          @RequestParam String estado,
                          Model model,
                          RedirectAttributes flash) {
        try {
            if (id == null) {
                bd.ejecutar("INSERT INTO producto (id_categoria, nombre, descripcion, precio, disponible, estado, id_negocio) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?)",
                        idCategoria, nombre, Bd.texto(descripcion), precio, disponible, estado, Sesion.actual().getIdNegocio());
                flash.addFlashAttribute("exito", "Registro creado correctamente.");
            } else {
                bd.ejecutar("UPDATE producto SET id_categoria = ?, nombre = ?, descripcion = ?, precio = ?, disponible = ?, estado = ? "
                        + "WHERE id_producto = ? AND id_negocio = ?",
                        idCategoria, nombre, Bd.texto(descripcion), precio, disponible, estado, id, Sesion.actual().getIdNegocio());
                flash.addFlashAttribute("exito", "Registro modificado correctamente.");
            }
            return "redirect:/negocios/productos";
        } catch (Exception e) {
            Map<String, Object> fila = new HashMap<>();
            fila.put("ID_PRODUCTO", id);
            fila.put("ID_CATEGORIA", idCategoria);
            fila.put("NOMBRE", nombre);
            fila.put("DESCRIPCION", descripcion);
            fila.put("PRECIO", precio);
            fila.put("DISPONIBLE", disponible);
            fila.put("ESTADO", estado);
            model.addAttribute("error", ErrorBd.mensaje(e));
            return formulario(fila, model);
        }
    }

    @PostMapping("/baja/{id}")
    public String baja(@PathVariable Long id, RedirectAttributes flash) {
        try {
            bd.ejecutar("UPDATE producto SET estado = 'I' WHERE id_producto = ? AND id_negocio = ?",
                    id, Sesion.actual().getIdNegocio());
            flash.addFlashAttribute("exito", "Registro dado de baja. Puede reactivarlo editándolo.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", ErrorBd.mensaje(e));
        }
        return "redirect:/negocios/productos";
    }
}

package com.ampar.delivery.reporte;

import com.ampar.delivery.config.Sesion;
import com.ampar.delivery.config.UsuarioSesion;
import com.ampar.delivery.datos.Bd;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Controller
public class ReporteController {

    private final Bd bd;
    private final Exportador exportador;

    public ReporteController(Bd bd, Exportador exportador) {
        this.bd = bd;
        this.exportador = exportador;
    }

    @GetMapping("/reportes/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("ind", bd.uno("SELECT * FROM vw_dashboard"));
        model.addAttribute("entregas", new Tabla("Repartidores con más entregas").grafico("Entregas por repartidor",
                bd.lista("SELECT repartidor, SUM(entregas) AS entregas FROM vw_rep_entregas_area "
                        + "GROUP BY repartidor ORDER BY 2 DESC"), "REPARTIDOR", "ENTREGAS"));
        model.addAttribute("cancelaciones", new Tabla("Repartidores que cancelan").grafico("Cancelaciones por repartidor",
                bd.lista("SELECT repartidor, cancelaciones FROM vw_rep_cancelaciones_repartidor "
                        + "WHERE cancelaciones > 0 ORDER BY 2 DESC"), "REPARTIDOR", "CANCELACIONES"));
        model.addAttribute("zonas", new Tabla("Pedidos por zona").grafico("Pedidos por zona",
                bd.lista("SELECT zona || ' (' || municipio || ')' AS zona, pedidos FROM vw_rep_zonas "
                        + "WHERE pedidos > 0 ORDER BY pedidos DESC"), "ZONA", "PEDIDOS"));
        model.addAttribute("zonasRojas", bd.lista(
                "SELECT zona, municipio, pedidos, cancelados, cancelaciones_repartidor FROM vw_rep_zonas "
                        + "WHERE zona_roja = 'S' ORDER BY pedidos DESC"));
        return "reportes/dashboard";
    }

    @GetMapping("/reportes/entregas-area")
    public Object entregasPorArea(@RequestParam Map<String, String> p, Model model) {
        String nivel = p.getOrDefault("nivel", "municipio");
        if (!List.of("departamento", "municipio", "zona").contains(nivel)) {
            nivel = "municipio";
        }
        String area = p.getOrDefault("area", "");

        Condiciones w = new Condiciones();
        if (!area.isEmpty()) {
            w.agregar(nivel + " = ?", area);
        }

        Tabla t = new Tabla("Repartidores con más entregas por " + nivel)
                .descripcion(area.isEmpty() ? "Todas las áreas" : "Área: " + area)
                .columna("AREA", nivel.substring(0, 1).toUpperCase() + nivel.substring(1))
                .columna("REPARTIDOR", "Repartidor")
                .columna("ENTREGAS", "Entregas");
        t.filas(bd.lista("SELECT " + nivel + " AS area, repartidor, SUM(entregas) AS entregas "
                + "FROM vw_rep_entregas_area" + w.where() + " GROUP BY " + nivel + ", repartidor "
                + "ORDER BY 1, 3 DESC", w.parametros()));
        t.grafico("Entregas por repartidor", bd.lista("SELECT repartidor, SUM(entregas) AS entregas "
                + "FROM vw_rep_entregas_area" + w.where() + " GROUP BY repartidor ORDER BY 2 DESC", w.parametros()),
                "REPARTIDOR", "ENTREGAS");

        List<Filtro> filtros = new ArrayList<>();
        filtros.add(new Filtro("nivel", "Nivel", "lista", opcionesFijas(
                "departamento", "Departamento", "municipio", "Municipio", "zona", "Zona"), nivel));
        filtros.add(new Filtro("area", "Área (opcional)", "lista", bd.lista(
                "SELECT DISTINCT " + nivel + " AS id, " + nivel + " AS texto FROM vw_rep_entregas_area ORDER BY 1"), area));
        return responder(t, filtros, p, model, "entregas_por_area");
    }

    @GetMapping("/reportes/cancelaciones-repartidor")
    public Object cancelacionesRepartidor(@RequestParam Map<String, String> p, Model model) {
        Tabla t = new Tabla("Repartidores que cancelan entregas")
                .descripcion("Cancelaciones de entregas, entregas realizadas y calificación promedio (1 a 5) de cada repartidor.")
                .columna("REPARTIDOR", "Repartidor")
                .columna("CANCELACIONES", "Entregas canceladas")
                .columna("ENTREGAS", "Entregas realizadas")
                .columna("CALIFICACION_PROMEDIO", "Calificación promedio");
        List<Map<String, Object>> filas = bd.lista(
                "SELECT repartidor, cancelaciones, entregas, calificacion_promedio "
                        + "FROM vw_rep_cancelaciones_repartidor ORDER BY cancelaciones DESC, repartidor");
        t.filas(filas).grafico("Entregas canceladas por repartidor", filas, "REPARTIDOR", "CANCELACIONES");
        return responder(t, new ArrayList<>(), p, model, "repartidores_que_cancelan");
    }

    @GetMapping("/reportes/zonas")
    public Object zonas(@RequestParam Map<String, String> p, Model model) {
        String soloRojas = p.getOrDefault("soloRojas", "N");
        Condiciones w = new Condiciones();
        w.agregar("pedidos > 0");
        if ("S".equals(soloRojas)) {
            w.agregar("zona_roja = 'S'");
        }
        Tabla t = new Tabla("Pedidos y cancelaciones por zona (zonas rojas)")
                .descripcion("Las zonas rojas aparecen con 'S' en la columna Zona roja.")
                .columna("ZONA", "Zona")
                .columna("MUNICIPIO", "Municipio")
                .columna("ZONA_ROJA", "Zona roja")
                .columna("PEDIDOS", "Pedidos")
                .columna("ENTREGADOS", "Entregados")
                .columna("CANCELADOS", "Cancelados por cliente")
                .columna("CANCELACIONES_REPARTIDOR", "Cancelaciones de repartidor");
        List<Map<String, Object>> filas = bd.lista(
                "SELECT zona, municipio, zona_roja, pedidos, entregados, cancelados, cancelaciones_repartidor, "
                        + "zona || ' - ' || municipio || CASE WHEN zona_roja = 'S' THEN ' (ROJA)' END AS etiqueta "
                        + "FROM vw_rep_zonas" + w.where() + " ORDER BY pedidos DESC", w.parametros());
        t.filas(filas).grafico("Pedidos por zona", filas, "ETIQUETA", "PEDIDOS");

        List<Filtro> filtros = List.of(new Filtro("soloRojas", "Mostrar", "lista",
                opcionesFijas("N", "Todas las zonas", "S", "Solo zonas rojas"), soloRojas));
        return responder(t, filtros, p, model, "zonas_rojas");
    }

    @GetMapping({"/reportes/pedidos", "/pedidos/consulta"})
    public Object pedidos(@RequestParam Map<String, String> p, Model model) {
        Condiciones w = new Condiciones();
        w.fechas("fecha_pedido", p);
        w.siHay("estado = ?", p.get("estado"));
        w.siHay("id_negocio = ?", p.get("negocio"));
        return consultaPedidos("Consulta de pedidos", w, p, model, true);
    }

    @GetMapping("/negocios/pedidos")
    public Object pedidosDelNegocio(@RequestParam Map<String, String> p, Model model) {
        UsuarioSesion u = Sesion.actual();
        Condiciones w = new Condiciones();
        w.agregar("id_negocio = ?", u.getIdNegocio());
        w.fechas("fecha_pedido", p);
        w.siHay("estado = ?", p.get("estado"));
        return consultaPedidos("Pedidos de mi negocio", w, p, model, false);
    }

    private Object consultaPedidos(String titulo, Condiciones w, Map<String, String> p, Model model, boolean filtroNegocio) {
        Tabla t = new Tabla(titulo)
                .columna("ID_PEDIDO", "No.")
                .columna("FECHA_PEDIDO", "Fecha")
                .columna("CLIENTE", "Cliente")
                .columna("NEGOCIO", "Negocio")
                .columna("ESTADO", "Estado")
                .columna("METODO_PAGO", "Pago")
                .columna("ESTADO_PAGO", "Estado del pago")
                .columna("REPARTIDOR", "Repartidor")
                .columna("ZONA", "Zona")
                .columna("MUNICIPIO", "Municipio")
                .columna("ZONA_ROJA", "Zona roja")
                .columna("TOTAL", "Total (Q)");
        t.filas(bd.lista("SELECT * FROM vw_pedido" + w.where() + " ORDER BY id_pedido DESC", w.parametros()));

        List<Filtro> filtros = new ArrayList<>(filtrosFecha(p));
        filtros.add(new Filtro("estado", "Estado", "lista",
                bd.lista("SELECT nombre AS id, nombre AS texto FROM estado_pedido ORDER BY orden"), p.get("estado")));
        if (filtroNegocio) {
            filtros.add(new Filtro("negocio", "Negocio", "lista",
                    bd.lista("SELECT id_negocio AS id, nombre AS texto FROM negocio ORDER BY nombre"), p.get("negocio")));
        }
        return responder(t, filtros, p, model, "pedidos");
    }

    @GetMapping("/reportes/negocios")
    public Object negocios(@RequestParam Map<String, String> p, Model model) {
        Condiciones w = new Condiciones();
        w.siHay("tipo_negocio = ?", p.get("tipo"));
        w.siHay("estado = ?", p.get("estado"));
        Tabla t = new Tabla("Negocios, horarios y días de entrega")
                .columna("NEGOCIO", "Negocio")
                .columna("TIPO_NEGOCIO", "Tipo")
                .columna("ZONA", "Zona")
                .columna("MUNICIPIO", "Municipio")
                .columna("ESTADO", "Estado")
                .columna("DIA", "Día")
                .columna("HORA_APERTURA", "Abre")
                .columna("HORA_CIERRE", "Cierra")
                .columna("HACE_ENTREGA", "Entrega")
                .columna("ABIERTO_AHORA", "Abierto ahora");
        t.filas(bd.lista("SELECT * FROM vw_negocio_horario" + w.where() + " ORDER BY negocio, dia_semana", w.parametros()));
        List<Filtro> filtros = List.of(
                new Filtro("tipo", "Tipo de negocio", "lista",
                        bd.lista("SELECT nombre AS id, nombre AS texto FROM tipo_negocio ORDER BY nombre"), p.get("tipo")),
                new Filtro("estado", "Estado", "lista", opcionesFijas("ACTIVO", "Activo", "PENDIENTE", "Pendiente",
                        "RECHAZADO", "Rechazado", "INACTIVO", "Inactivo"), p.get("estado")));
        return responder(t, filtros, p, model, "negocios_horarios");
    }

    @GetMapping("/reportes/productos")
    public Object productos(@RequestParam Map<String, String> p, Model model) {
        Condiciones w = new Condiciones();
        w.siHay("id_negocio = ?", p.get("negocio"));
        w.siHay("id_categoria = ?", p.get("categoria"));
        Tabla t = new Tabla("Catálogo de productos por negocio")
                .columna("NEGOCIO", "Negocio")
                .columna("CATEGORIA", "Categoría")
                .columna("PRODUCTO", "Producto")
                .columna("DESCRIPCION", "Descripción")
                .columna("PRECIO", "Precio (Q)")
                .columna("DISPONIBLE", "Disponible");
        t.filas(bd.lista("SELECT * FROM vw_catalogo_producto" + w.where() + " ORDER BY negocio, categoria, producto",
                w.parametros()));
        List<Filtro> filtros = List.of(
                new Filtro("negocio", "Negocio", "lista",
                        bd.lista("SELECT id_negocio AS id, nombre AS texto FROM negocio WHERE estado = 'ACTIVO' ORDER BY nombre"),
                        p.get("negocio")),
                new Filtro("categoria", "Categoría", "lista",
                        bd.lista("SELECT id_categoria AS id, nombre AS texto FROM categoria_producto ORDER BY nombre"),
                        p.get("categoria")));
        return responder(t, filtros, p, model, "productos");
    }

    @GetMapping("/reportes/cancelaciones")
    public Object cancelaciones(@RequestParam Map<String, String> p, Model model) {
        Condiciones w = new Condiciones();
        w.fechas("fecha", p);
        Tabla t = new Tabla("Cancelaciones de pedidos")
                .descripcion("Cobro del 15 % del total. Tarjeta: se reembolsa el resto. Efectivo: el cargo se suma al siguiente pedido.")
                .columna("ID_PEDIDO", "Pedido")
                .columna("FECHA", "Fecha")
                .columna("CLIENTE", "Cliente")
                .columna("NEGOCIO", "Negocio")
                .columna("METODO_PAGO", "Pago")
                .columna("MOTIVO", "Motivo")
                .columna("TOTAL", "Total (Q)")
                .columna("MONTO_COBRO", "Cobro (Q)")
                .columna("MONTO_REEMBOLSO", "Reembolso (Q)")
                .columna("ESTADO_CARGO", "Cargo");
        t.filas(bd.lista("SELECT * FROM vw_cancelacion_pedido" + w.where() + " ORDER BY fecha DESC", w.parametros()));
        return responder(t, filtrosFecha(p), p, model, "cancelaciones");
    }

    @GetMapping("/reportes/calificaciones")
    public Object calificaciones(@RequestParam Map<String, String> p, Model model) {
        Condiciones w = new Condiciones();
        w.fechas("fecha", p);
        w.siHay("id_repartidor = ?", p.get("repartidor"));
        List<Filtro> filtros = new ArrayList<>(filtrosFecha(p));
        filtros.add(new Filtro("repartidor", "Repartidor", "lista",
                bd.lista("SELECT id_repartidor AS id, nombres || ' ' || apellidos AS texto FROM repartidor ORDER BY 2"),
                p.get("repartidor")));
        return consultaCalificaciones("Calificaciones de repartidores", w, filtros, p, model);
    }

    @GetMapping("/repartidor/calificaciones")
    public Object misCalificaciones(@RequestParam Map<String, String> p, Model model) {
        Condiciones w = new Condiciones();
        w.agregar("id_repartidor = ?", Sesion.actual().getIdRepartidor());
        w.fechas("fecha", p);
        return consultaCalificaciones("Mis calificaciones", w, filtrosFecha(p), p, model);
    }

    private Object consultaCalificaciones(String titulo, Condiciones w, List<Filtro> filtros,
                                          Map<String, String> p, Model model) {
        Tabla t = new Tabla(titulo)
                .columna("ID_PEDIDO", "Pedido")
                .columna("FECHA", "Fecha")
                .columna("REPARTIDOR", "Repartidor")
                .columna("CLIENTE", "Cliente")
                .columna("PUNTUACION", "Estrellas")
                .columna("COMENTARIO", "Comentario");
        t.filas(bd.lista("SELECT * FROM vw_calificacion" + w.where() + " ORDER BY fecha DESC", w.parametros()));
        Object promedio = bd.valor("SELECT ROUND(AVG(puntuacion), 2) FROM vw_calificacion" + w.where(), w.parametros());
        t.descripcion("Calificación promedio: " + (promedio == null ? "sin calificaciones" : promedio + " de 5"));
        return responder(t, filtros, p, model, "calificaciones");
    }

    @GetMapping("/despacho/notificaciones")
    public Object notificaciones(@RequestParam Map<String, String> p, Model model) {
        Condiciones w = new Condiciones();
        w.fechas("fecha_envio", p);
        w.siHay("canal = ?", p.get("canal"));
        w.siHay("id_pedido = ?", p.get("pedido"));
        Tabla t = new Tabla("Notificaciones enviadas (SMS y WhatsApp)")
                .descripcion("Las notificaciones son simuladas: se guardan en la base de datos como ENVIADA.")
                .columna("ID_NOTIFICACION", "No.")
                .columna("FECHA_ENVIO", "Fecha")
                .columna("ID_PEDIDO", "Pedido")
                .columna("CLIENTE", "Cliente")
                .columna("CANAL", "Canal")
                .columna("TELEFONO", "Teléfono")
                .columna("MENSAJE", "Mensaje")
                .columna("ESTADO", "Estado");
        t.filas(bd.lista("SELECT * FROM vw_notificacion" + w.where()
                + " ORDER BY id_notificacion DESC FETCH FIRST 500 ROWS ONLY", w.parametros()));
        List<Filtro> filtros = new ArrayList<>(filtrosFecha(p));
        filtros.add(new Filtro("canal", "Canal", "lista", opcionesFijas("SMS", "SMS", "WHATSAPP", "WhatsApp"), p.get("canal")));
        filtros.add(new Filtro("pedido", "No. de pedido", "texto", null, p.get("pedido")));
        return responder(t, filtros, p, model, "notificaciones");
    }

    @GetMapping("/seguridad/bitacora")
    public Object bitacora(@RequestParam Map<String, String> p, Model model) {
        Condiciones w = new Condiciones();
        w.fechas("fecha", p);
        w.siHay("operacion = ?", p.get("operacion"));
        w.siHay("tabla = ?", p.get("tabla"));
        if (p.get("usuario") != null && !p.get("usuario").isBlank()) {
            w.agregar("LOWER(usuario) LIKE ?", "%" + p.get("usuario").trim().toLowerCase() + "%");
        }
        Tabla t = new Tabla("Bitácora de eventos")
                .descripcion("Registro de auditoría generado por los triggers de la base de datos (últimos 500 eventos del filtro).")
                .columna("ID_BITACORA", "No.")
                .columna("FECHA", "Fecha")
                .columna("USUARIO", "Usuario")
                .columna("TABLA", "Tabla")
                .columna("OPERACION", "Operación")
                .columna("ID_REGISTRO", "Registro")
                .columna("VALOR_ANTERIOR", "Valor anterior")
                .columna("VALOR_NUEVO", "Valor nuevo");
        t.filas(bd.lista("SELECT * FROM bitacora" + w.where() + " ORDER BY id_bitacora DESC FETCH FIRST 500 ROWS ONLY",
                w.parametros()));
        List<Filtro> filtros = new ArrayList<>(filtrosFecha(p));
        filtros.add(new Filtro("usuario", "Usuario", "texto", null, p.get("usuario")));
        filtros.add(new Filtro("tabla", "Tabla", "lista",
                bd.lista("SELECT DISTINCT tabla AS id, tabla AS texto FROM bitacora ORDER BY 1"), p.get("tabla")));
        filtros.add(new Filtro("operacion", "Operación", "lista", opcionesFijas("INSERT", "INSERT", "UPDATE", "UPDATE",
                "DELETE", "DELETE", "LOGIN", "LOGIN", "LOGIN_FALLIDO", "LOGIN_FALLIDO"), p.get("operacion")));
        return responder(t, filtros, p, model, "bitacora");
    }

    private Object responder(Tabla t, List<Filtro> filtros, Map<String, String> p, Model model, String archivo) {
        String formato = p.getOrDefault("formato", "");
        try {
            if (formato.equals("excel")) {
                return descarga(exportador.excel(t), archivo + ".xlsx",
                        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            }
            if (formato.equals("pdf")) {
                return descarga(exportador.pdf(t), archivo + ".pdf", "application/pdf");
            }
        } catch (Exception e) {
            throw new RuntimeException("No se pudo generar el archivo: " + e.getMessage(), e);
        }
        model.addAttribute("tabla", t);
        model.addAttribute("filtros", filtros);
        return "reportes/consulta";
    }

    private ResponseEntity<byte[]> descarga(byte[] contenido, String nombre, String tipo) {
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + nombre + "\"")
                .contentType(MediaType.parseMediaType(tipo))
                .body(contenido);
    }

    private List<Filtro> filtrosFecha(Map<String, String> p) {
        return List.of(new Filtro("desde", "Desde", "fecha", null, p.get("desde")),
                new Filtro("hasta", "Hasta", "fecha", null, p.get("hasta")));
    }

    private List<Map<String, Object>> opcionesFijas(String... valores) {
        List<Map<String, Object>> lista = new ArrayList<>();
        for (int i = 0; i + 1 < valores.length; i += 2) {
            lista.add(Map.of("ID", valores[i], "TEXTO", valores[i + 1]));
        }
        return lista;
    }

    static class Condiciones {
        private final List<String> condiciones = new ArrayList<>();
        private final List<Object> parametros = new ArrayList<>();

        void agregar(String condicion, Object... valores) {
            condiciones.add(condicion);
            parametros.addAll(List.of(valores));
        }

        void siHay(String condicion, String valor) {
            if (valor != null && !valor.isBlank()) {
                agregar(condicion, valor.trim());
            }
        }

        void fechas(String columna, Map<String, String> p) {
            siHay(columna + " >= TO_DATE(?, 'YYYY-MM-DD')", p.get("desde"));
            siHay(columna + " < TO_DATE(?, 'YYYY-MM-DD') + 1", p.get("hasta"));
        }

        String where() {
            return condiciones.isEmpty() ? "" : " WHERE " + String.join(" AND ", condiciones);
        }

        Object[] parametros() {
            return parametros.toArray();
        }
    }
}

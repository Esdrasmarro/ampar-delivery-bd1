package com.ampar.delivery.reporte;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Tabla {

    private final String titulo;
    private String descripcion = "";
    private final List<String[]> columnas = new ArrayList<>();
    private List<Map<String, Object>> filas = new ArrayList<>();

    private String tituloGrafico;
    private final List<String> etiquetas = new ArrayList<>();
    private final List<Number> valores = new ArrayList<>();

    public Tabla(String titulo) {
        this.titulo = titulo;
    }

    public Tabla columna(String columna, String etiqueta) {
        columnas.add(new String[]{columna.toUpperCase(), etiqueta});
        return this;
    }

    public Tabla descripcion(String d) { this.descripcion = d; return this; }
    public Tabla filas(List<Map<String, Object>> f) { this.filas = f; return this; }

    public Tabla grafico(String titulo, List<Map<String, Object>> datos, String columnaEtiqueta, String columnaValor) {
        this.tituloGrafico = titulo;
        etiquetas.clear();
        valores.clear();
        for (Map<String, Object> f : datos) {
            etiquetas.add(String.valueOf(f.get(columnaEtiqueta)));
            Object v = f.get(columnaValor);
            valores.add(v instanceof Number n ? n : 0);
        }
        return this;
    }

    public boolean tieneGrafico() { return tituloGrafico != null && !etiquetas.isEmpty(); }

    public String getTitulo() { return titulo; }
    public String getDescripcion() { return descripcion; }
    public List<String[]> getColumnas() { return columnas; }
    public List<Map<String, Object>> getFilas() { return filas; }
    public String getTituloGrafico() { return tituloGrafico; }
    public List<String> getEtiquetas() { return etiquetas; }
    public List<Number> getValores() { return valores; }
}

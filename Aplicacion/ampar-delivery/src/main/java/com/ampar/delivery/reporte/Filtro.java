package com.ampar.delivery.reporte;

import java.util.List;
import java.util.Map;

public class Filtro {

    private final String nombre;
    private final String etiqueta;
    private final String tipo;
    private final List<Map<String, Object>> opciones;
    private final String valor;

    public Filtro(String nombre, String etiqueta, String tipo, List<Map<String, Object>> opciones, String valor) {
        this.nombre = nombre;
        this.etiqueta = etiqueta;
        this.tipo = tipo;
        this.opciones = opciones;
        this.valor = valor == null ? "" : valor;
    }

    public String getNombre() { return nombre; }
    public String getEtiqueta() { return etiqueta; }
    public String getTipo() { return tipo; }
    public List<Map<String, Object>> getOpciones() { return opciones; }
    public String getValor() { return valor; }
}

package com.ampar.delivery.config;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class UsuarioSesion implements Serializable {

    private Long idUsuario;
    private String usuario;
    private String nombre;
    private Long idRol;
    private String rol;
    private Long idCliente;
    private Long idNegocio;
    private Long idRepartidor;
    private List<Modulo> menu = new ArrayList<>();

    public static class Modulo implements Serializable {
        private final String nombre;
        private final List<Opcion> opciones = new ArrayList<>();

        public Modulo(String nombre) { this.nombre = nombre; }
        public String getNombre() { return nombre; }
        public List<Opcion> getOpciones() { return opciones; }
    }

    public static class Opcion implements Serializable {
        private final String nombre;
        private final String url;

        public Opcion(String nombre, String url) { this.nombre = nombre; this.url = url; }
        public String getNombre() { return nombre; }
        public String getUrl() { return url; }
    }

    public Long getIdUsuario() { return idUsuario; }
    public void setIdUsuario(Long idUsuario) { this.idUsuario = idUsuario; }
    public String getUsuario() { return usuario; }
    public void setUsuario(String usuario) { this.usuario = usuario; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public Long getIdRol() { return idRol; }
    public void setIdRol(Long idRol) { this.idRol = idRol; }
    public String getRol() { return rol; }
    public void setRol(String rol) { this.rol = rol; }
    public Long getIdCliente() { return idCliente; }
    public void setIdCliente(Long idCliente) { this.idCliente = idCliente; }
    public Long getIdNegocio() { return idNegocio; }
    public void setIdNegocio(Long idNegocio) { this.idNegocio = idNegocio; }
    public Long getIdRepartidor() { return idRepartidor; }
    public void setIdRepartidor(Long idRepartidor) { this.idRepartidor = idRepartidor; }
    public List<Modulo> getMenu() { return menu; }
    public void setMenu(List<Modulo> menu) { this.menu = menu; }
}

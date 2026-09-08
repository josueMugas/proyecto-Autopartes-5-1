package com.demografia.modelo;

public class Usuario {
    private int idUsuario;
    private String nombreUsuario;
    private String clave;
    private boolean activo;
    private int idRol;

    public Usuario() {}

    public Usuario(int idUsuario, String nombreUsuario, String clave, boolean activo, int idRol) {
        this.idUsuario = idUsuario;
        this.nombreUsuario = nombreUsuario;
        this.clave = clave;
        this.activo = activo;
        this.idRol = idRol;
    }

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    public String getNombreUsuario() { return nombreUsuario; }
    public void setNombreUsuario(String nombreUsuario) { this.nombreUsuario = nombreUsuario; }

    public String getClave() { return clave; }
    public void setClave(String clave) { this.clave = clave; }

    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }

    public int getIdRol() { return idRol; }
    public void setIdRol(int idRol) { this.idRol = idRol; }
}
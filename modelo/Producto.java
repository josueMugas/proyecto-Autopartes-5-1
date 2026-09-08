package com.demografia.modelo;

public class Producto {
    private int idProducto;
    private String codigo;
    private String nombre;
    private String planoTecnicoUrl;

    public Producto() {}

    public Producto(int idProducto, String codigo, String nombre, String planoTecnicoUrl) {
        this.idProducto = idProducto;
        this.codigo = codigo;
        this.nombre = nombre;
        this.planoTecnicoUrl = planoTecnicoUrl;
    }

    public int getIdProducto() { return idProducto; }
    public void setIdProducto(int idProducto) { this.idProducto = idProducto; }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getPlanoTecnicoUrl() { return planoTecnicoUrl; }
    public void setPlanoTecnicoUrl(String planoTecnicoUrl) { this.planoTecnicoUrl = planoTecnicoUrl; }
}
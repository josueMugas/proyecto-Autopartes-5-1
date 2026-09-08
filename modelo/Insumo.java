package com.demografia.modelo;

public class Insumo {
    private int idInsumo;
    private String codigo;
    private String nombre;
    private String tipoMaterial;
    private int stockActual;
    private int stockMinimo;
    private String unidadMedida;

    public Insumo() {}

    public Insumo(int idInsumo, String codigo, String nombre, String tipoMaterial, 
                  int stockActual, int stockMinimo, String unidadMedida) {
        this.idInsumo = idInsumo;
        this.codigo = codigo;
        this.nombre = nombre;
        this.tipoMaterial = tipoMaterial;
        this.stockActual = stockActual;
        this.stockMinimo = stockMinimo;
        this.unidadMedida = unidadMedida;
    }

    public int getIdInsumo() { return idInsumo; }
    public void setIdInsumo(int idInsumo) { this.idInsumo = idInsumo; }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getTipoMaterial() { return tipoMaterial; }
    public void setTipoMaterial(String tipoMaterial) { this.tipoMaterial = tipoMaterial; }

    public int getStockActual() { return stockActual; }
    public void setStockActual(int stockActual) { this.stockActual = stockActual; }

    public int getStockMinimo() { return stockMinimo; }
    public void setStockMinimo(int stockMinimo) { this.stockMinimo = stockMinimo; }

    public String getUnidadMedida() { return unidadMedida; }
    public void setUnidadMedida(String unidadMedida) { this.unidadMedida = unidadMedida; }
}
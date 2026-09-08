package com.demografia.modelo;

import java.util.Date;

public class Presupuesto {
    private int idPresupuesto;
    private int idCliente;
    private int idUsuarioVenta;
    private Date fecha;
    private double total;
    private String estado;
    private String tipoFactura;
    private boolean esFormal;

    public Presupuesto() {}

    public Presupuesto(int idPresupuesto, int idCliente, int idUsuarioVenta, Date fecha, 
                       double total, String estado, String tipoFactura, boolean esFormal) {
        this.idPresupuesto = idPresupuesto;
        this.idCliente = idCliente;
        this.idUsuarioVenta = idUsuarioVenta;
        this.fecha = fecha;
        this.total = total;
        this.estado = estado;
        this.tipoFactura = tipoFactura;
        this.esFormal = esFormal;
    }

    public int getIdPresupuesto() { return idPresupuesto; }
    public void setIdPresupuesto(int idPresupuesto) { this.idPresupuesto = idPresupuesto; }

    public int getIdCliente() { return idCliente; }
    public void setIdCliente(int idCliente) { this.idCliente = idCliente; }

    public int getIdUsuarioVenta() { return idUsuarioVenta; }
    public void setIdUsuarioVenta(int idUsuarioVenta) { this.idUsuarioVenta = idUsuarioVenta; }

    public Date getFecha() { return fecha; }
    public void setFecha(Date fecha) { this.fecha = fecha; }

    public double getTotal() { return total; }
    public void setTotal(double total) { this.total = total; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getTipoFactura() { return tipoFactura; }
    public void setTipoFactura(String tipoFactura) { this.tipoFactura = tipoFactura; }

    public boolean isEsFormal() { return esFormal; }
    public void setEsFormal(boolean esFormal) { this.esFormal = esFormal; }
}
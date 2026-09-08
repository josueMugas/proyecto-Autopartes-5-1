package com.demografia.modelo;

import java.util.Date;

public class HojaDeRuta {
    private int idHojaRuta;
    private String codigoInalterable;
    private int idPresupuesto;
    private int idProducto;
    private int cantidad;
    private String lineaTrabajo;
    private String metodoProductivo;
    private String estado;
    private Date fechaInicio;
    private Date fechaEstimadaEntrega;

    public HojaDeRuta() {}

    public HojaDeRuta(int idHojaRuta, String codigoInalterable, int idPresupuesto, 
                      int idProducto, int cantidad, String lineaTrabajo, 
                      String metodoProductivo, String estado, Date fechaInicio, 
                      Date fechaEstimadaEntrega) {
        this.idHojaRuta = idHojaRuta;
        this.codigoInalterable = codigoInalterable;
        this.idPresupuesto = idPresupuesto;
        this.idProducto = idProducto;
        this.cantidad = cantidad;
        this.lineaTrabajo = lineaTrabajo;
        this.metodoProductivo = metodoProductivo;
        this.estado = estado;
        this.fechaInicio = fechaInicio;
        this.fechaEstimadaEntrega = fechaEstimadaEntrega;
    }

    public int getIdHojaRuta() { return idHojaRuta; }
    public void setIdHojaRuta(int idHojaRuta) { this.idHojaRuta = idHojaRuta; }

    public String getCodigoInalterable() { return codigoInalterable; }
    public void setCodigoInalterable(String codigoInalterable) { this.codigoInalterable = codigoInalterable; }

    public int getIdPresupuesto() { return idPresupuesto; }
    public void setIdPresupuesto(int idPresupuesto) { this.idPresupuesto = idPresupuesto; }

    public int getIdProducto() { return idProducto; }
    public void setIdProducto(int idProducto) { this.idProducto = idProducto; }

    public int getCantidad() { return cantidad; }
    public void setCantidad(int cantidad) { this.cantidad = cantidad; }

    public String getLineaTrabajo() { return lineaTrabajo; }
    public void setLineaTrabajo(String lineaTrabajo) { this.lineaTrabajo = lineaTrabajo; }

    public String getMetodoProductivo() { return metodoProductivo; }
    public void setMetodoProductivo(String metodoProductivo) { this.metodoProductivo = metodoProductivo; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public Date getFechaInicio() { return fechaInicio; }
    public void setFechaInicio(Date fechaInicio) { this.fechaInicio = fechaInicio; }

    public Date getFechaEstimadaEntrega() { return fechaEstimadaEntrega; }
    public void setFechaEstimadaEntrega(Date fechaEstimadaEntrega) { this.fechaEstimadaEntrega = fechaEstimadaEntrega; }
}
package com.demografia.modelo;

public class Cliente {
    private int idCliente;
    private String nombre;
    private String apellido;
    private String dni;
    private String cuil;
    private String razonSocial;
    private String condicionIva;
    private String direccionFiscal;
    private String telefono;
    private String email;

    public Cliente() {}

    public Cliente(int idCliente, String nombre, String apellido, String dni, String cuil, 
                   String razonSocial, String condicionIva, String direccionFiscal, 
                   String telefono, String email) {
        this.idCliente = idCliente;
        this.nombre = nombre;
        this.apellido = apellido;
        this.dni = dni;
        this.cuil = cuil;
        this.razonSocial = razonSocial;
        this.condicionIva = condicionIva;
        this.direccionFiscal = direccionFiscal;
        this.telefono = telefono;
        this.email = email;
    }

    public int getIdCliente() { return idCliente; }
    public void setIdCliente(int idCliente) { this.idCliente = idCliente; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getApellido() { return apellido; }
    public void setApellido(String apellido) { this.apellido = apellido; }

    public String getDni() { return dni; }
    public void setDni(String dni) { this.dni = dni; }

    public String getCuil() { return cuil; }
    public void setCuil(String cuil) { this.cuil = cuil; }

    public String getRazonSocial() { return razonSocial; }
    public void setRazonSocial(String razonSocial) { this.razonSocial = razonSocial; }

    public String getCondicionIva() { return condicionIva; }
    public void setCondicionIva(String condicionIva) { this.condicionIva = condicionIva; }

    public String getDireccionFiscal() { return direccionFiscal; }
    public void setDireccionFiscal(String direccionFiscal) { this.direccionFiscal = direccionFiscal; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
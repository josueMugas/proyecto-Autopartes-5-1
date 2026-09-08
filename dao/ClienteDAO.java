package com.demografia.dao;

import com.demografia.modelo.Cliente;
import com.demografia.config.Conexion;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ClienteDAO implements IClienteDAO {

    @Override
    public List<Cliente> listAll() {
        List<Cliente> lista = new ArrayList<>();
        String sql = "{CALL sp_ListAll_Clientes()}";
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {

            while (rs.next()) {
                lista.add(new Cliente(
                    rs.getInt("id_cliente"), rs.getString("nombre"), rs.getString("apellido"),
                    rs.getString("dni"), rs.getString("cuil"), rs.getString("razon_social"),
                    rs.getString("condicion_iva"), rs.getString("direccion_fiscal"),
                    rs.getString("telefono"), rs.getString("email")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return lista;
    }

    @Override
    public boolean insert(Cliente c) {
        String sql = "{CALL sp_Insert_Cliente(?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, c.getNombre()); cs.setString(2, c.getApellido());
            cs.setString(3, c.getDni()); cs.setString(4, c.getCuil());
            cs.setString(5, c.getRazonSocial()); cs.setString(6, c.getCondicionIva());
            cs.setString(7, c.getDireccionFiscal()); cs.setString(8, c.getTelefono());
            cs.setString(9, c.getEmail());
            return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean delete(int id) {
        String sql = "{CALL sp_Delete_Cliente(?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, id);
            return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean update(Cliente c) {
        String sql = "{CALL sp_Update_Cliente(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setInt(1, c.getIdCliente()); cs.setString(2, c.getNombre());
            cs.setString(3, c.getApellido()); cs.setString(4, c.getDni());
            cs.setString(5, c.getCuil()); cs.setString(6, c.getRazonSocial());
            cs.setString(7, c.getCondicionIva()); cs.setString(8, c.getDireccionFiscal());
            cs.setString(9, c.getTelefono()); cs.setString(10, c.getEmail());
            return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public Cliente listById(int id) {
        Cliente c = null;
        String sql = "{CALL sp_ListById_Cliente(?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, id);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    c = new Cliente(
                        rs.getInt("id_cliente"), rs.getString("nombre"), rs.getString("apellido"),
                        rs.getString("dni"), rs.getString("cuil"), rs.getString("razon_social"),
                        rs.getString("condicion_iva"), rs.getString("direccion_fiscal"),
                        rs.getString("telefono"), rs.getString("email")
                    );
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return c;
    }
}
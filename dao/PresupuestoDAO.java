package com.demografia.dao;

import com.demografia.modelo.Presupuesto;
import com.demografia.config.Conexion;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

public class PresupuestoDAO implements IPresupuestoDAO {

    @Override
    public List<Presupuesto> listAll() {
        List<Presupuesto> lista = new ArrayList<>();
        String sql = "{CALL sp_ListAll_Presupuestos()}";
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) {
                lista.add(new Presupuesto(
                    rs.getInt("id_presupuesto"), rs.getInt("id_cliente"), rs.getInt("id_usuario_venta"),
                    rs.getDate("fecha"), rs.getDouble("total"), rs.getString("estado"),
                    rs.getString("tipo_factura"), rs.getBoolean("es_formal")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return lista;
    }

    @Override
    public boolean insert(Presupuesto p) {
        String sql = "{CALL sp_Insert_Presupuesto(?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, p.getIdCliente()); cs.setInt(2, p.getIdUsuarioVenta());
            cs.setDate(3, new Date(p.getFecha().getTime())); cs.setDouble(4, p.getTotal());
            cs.setString(5, p.getEstado()); cs.setString(6, p.getTipoFactura());
            cs.setBoolean(7, p.isEsFormal());
            return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean delete(int id) {
        String sql = "{CALL sp_Delete_Presupuesto(?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, id); return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean update(Presupuesto p) {
        String sql = "{CALL sp_Update_Presupuesto(?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, p.getIdPresupuesto()); cs.setInt(2, p.getIdCliente());
            cs.setInt(3, p.getIdUsuarioVenta()); cs.setDate(4, new Date(p.getFecha().getTime()));
            cs.setDouble(5, p.getTotal()); cs.setString(6, p.getEstado());
            cs.setString(7, p.getTipoFactura()); cs.setBoolean(8, p.isEsFormal());
            return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public Presupuesto listById(int id) {
        Presupuesto p = null;
        String sql = "{CALL sp_ListById_Presupuesto(?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, id);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    p = new Presupuesto(
                        rs.getInt("id_presupuesto"), rs.getInt("id_cliente"), rs.getInt("id_usuario_venta"),
                        rs.getDate("fecha"), rs.getDouble("total"), rs.getString("estado"),
                        rs.getString("tipo_factura"), rs.getBoolean("es_formal")
                    );
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return p;
    }
}
package com.demografia.dao;

import com.demografia.modelo.Producto;
import com.demografia.config.Conexion;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ProductoDAO implements IProductoDAO {

    @Override
    public List<Producto> listAll() {
        List<Producto> lista = new ArrayList<>();
        String sql = "{CALL sp_ListAll_Productos()}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) {
                lista.add(new Producto(
                    rs.getInt("id_producto"), rs.getString("codigo"),
                    rs.getString("nombre"), rs.getString("plano_tecnico_url")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return lista;
    }

    @Override
    public boolean insert(Producto p) {
        String sql = "{CALL sp_Insert_Producto(?, ?, ?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, p.getCodigo()); cs.setString(2, p.getNombre());
            cs.setString(3, p.getPlanoTecnicoUrl());
            return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean delete(int id) {
        String sql = "{CALL sp_Delete_Producto(?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, id); return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean update(Producto p) {
        String sql = "{CALL sp_Update_Producto(?, ?, ?, ?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, p.getIdProducto()); cs.setString(2, p.getCodigo());
            cs.setString(3, p.getNombre()); cs.setString(4, p.getPlanoTecnicoUrl());
            return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public Producto listById(int id) {
        Producto p = null;
        String sql = "{CALL sp_ListById_Producto(?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, id);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    p = new Producto(
                        rs.getInt("id_producto"), rs.getString("codigo"),
                        rs.getString("nombre"), rs.getString("plano_tecnico_url")
                    );
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return p;
    }
}
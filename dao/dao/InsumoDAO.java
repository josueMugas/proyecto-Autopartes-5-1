package com.demografia.dao;

import com.demografia.modelo.Insumo;
import com.demografia.config.Conexion;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class InsumoDAO implements IInsumoDAO {

    @Override
    public List<Insumo> listAll() {
        List<Insumo> lista = new ArrayList<>();
        String sql = "{CALL sp_ListAll_Insumos()}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) {
                lista.add(new Insumo(
                    rs.getInt("id_insumo"), rs.getString("codigo"), rs.getString("nombre"),
                    rs.getString("tipo_material"), rs.getInt("stock_actual"),
                    rs.getInt("stock_minimo"), rs.getString("unidad_medida")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return lista;
    }

    @Override
    public boolean insert(Insumo insumo) {
        String sql = "{CALL sp_Insert_Insumo(?, ?, ?, ?, ?, ?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, insumo.getCodigo()); cs.setString(2, insumo.getNombre());
            cs.setString(3, insumo.getTipoMaterial()); cs.setInt(4, insumo.getStockActual());
            cs.setInt(5, insumo.getStockMinimo()); cs.setString(6, insumo.getUnidadMedida());
            return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean delete(int id) {
        String sql = "{CALL sp_Delete_Insumo(?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, id); return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean update(Insumo insumo) {
        String sql = "{CALL sp_Update_Insumo(?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, insumo.getIdInsumo()); cs.setString(2, insumo.getCodigo());
            cs.setString(3, insumo.getNombre()); cs.setString(4, insumo.getTipoMaterial());
            cs.setInt(5, insumo.getStockActual()); cs.setInt(6, insumo.getStockMinimo());
            cs.setString(7, insumo.getUnidadMedida());
            return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public Insumo listById(int id) {
        Insumo insumo = null;
        String sql = "{CALL sp_ListById_Insumo(?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, id);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    insumo = new Insumo(
                        rs.getInt("id_insumo"), rs.getString("codigo"), rs.getString("nombre"),
                        rs.getString("tipo_material"), rs.getInt("stock_actual"),
                        rs.getInt("stock_minimo"), rs.getString("unidad_medida")
                    );
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return insumo;
    }
}
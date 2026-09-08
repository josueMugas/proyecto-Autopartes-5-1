package com.demografia.dao;

import com.demografia.modelo.HojaDeRuta;
import com.demografia.config.Conexion;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

public class HojaDeRutaDAO implements IHojaDeRutaDAO {

    @Override
    public List<HojaDeRuta> listAll() {
        List<HojaDeRuta> lista = new ArrayList<>();
        String sql = "{CALL sp_ListAll_HojasDeRuta()}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) {
                lista.add(new HojaDeRuta(
                    rs.getInt("id_hoja_ruta"), rs.getString("codigo_inalterable"),
                    rs.getInt("id_presupuesto"), rs.getInt("id_producto"), rs.getInt("cantidad"),
                    rs.getString("linea_trabajo"), rs.getString("metodo_productivo"), rs.getString("estado"),
                    rs.getDate("fecha_inicio"), rs.getDate("fecha_estimada_entrega")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return lista;
    }

    @Override
    public boolean insert(HojaDeRuta hr) {
        String sql = "{CALL sp_Insert_HojaDeRuta(?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, hr.getCodigoInalterable()); cs.setInt(2, hr.getIdPresupuesto());
            cs.setInt(3, hr.getIdProducto()); cs.setInt(4, hr.getCantidad());
            cs.setString(5, hr.getLineaTrabajo()); cs.setString(6, hr.getMetodoProductivo());
            cs.setString(7, hr.getEstado()); cs.setDate(8, new Date(hr.getFechaInicio().getTime()));
            cs.setDate(9, new Date(hr.getFechaEstimadaEntrega().getTime()));
            return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean delete(int id) {
        String sql = "{CALL sp_Delete_HojaDeRuta(?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, id); return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean update(HojaDeRuta hr) {
        String sql = "{CALL sp_Update_HojaDeRuta(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, hr.getIdHojaRuta()); cs.setString(2, hr.getCodigoInalterable());
            cs.setInt(3, hr.getIdPresupuesto()); cs.setInt(4, hr.getIdProducto());
            cs.setInt(5, hr.getCantidad()); cs.setString(6, hr.getLineaTrabajo());
            cs.setString(7, hr.getMetodoProductivo()); cs.setString(8, hr.getEstado());
            cs.setDate(9, new Date(hr.getFechaInicio().getTime()));
            cs.setDate(10, new Date(hr.getFechaEstimadaEntrega().getTime()));
            return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public HojaDeRuta listById(int id) {
        HojaDeRuta hr = null;
        String sql = "{CALL sp_ListById_HojaDeRuta(?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, id);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    hr = new HojaDeRuta(
                        rs.getInt("id_hoja_ruta"), rs.getString("codigo_inalterable"),
                        rs.getInt("id_presupuesto"), rs.getInt("id_producto"), rs.getInt("cantidad"),
                        rs.getString("linea_trabajo"), rs.getString("metodo_productivo"), rs.getString("estado"),
                        rs.getDate("fecha_inicio"), rs.getDate("fecha_estimada_entrega")
                    );
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return hr;
    }
}
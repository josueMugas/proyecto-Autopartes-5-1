package com.demografia.dao;

import com.demografia.modelo.Rol;
import com.demografia.config.Conexion;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class RolDAO implements IRolDAO {

    @Override
    public List<Rol> listAll() {
        List<Rol> lista = new ArrayList<>();
        String sql = "{CALL sp_ListAll(?)}";
        
        try (Connection conn = Conexion.getConnection();
            CallableStatement cs = conn.prepareCall(sql)){
        	cs.setString(1, "Rol");
            ResultSet rs = cs.executeQuery();

            while (rs.next()) {
                lista.add(new Rol(
                    rs.getInt("id_rol"),
                    rs.getString("nombre_rol"),
                    rs.getString("descripcion")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    @Override
    public boolean insert(Rol rol) {
        String sql = "{CALL sp_Insert_Rol(?, ?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, rol.getNombreRol());
            cs.setString(2, rol.getDescripcion());

            return cs.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(int id) {
        String sql = "{CALL sp_Delete(?,?)}";
        try (Connection conn = Conexion.getConnection();
            CallableStatement cs = conn.prepareCall(sql)) {
        	cs.setString(1, "Rol");
            cs.setInt(2, id);
            return cs.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean update(Rol rol) {
        String sql = "{CALL sp_Update_Rol(?, ?, ?)}";
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setInt(1, rol.getIdRol());
            cs.setString(2, rol.getNombreRol());
            cs.setString(3, rol.getDescripcion());

            return cs.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Rol listById(int id) {
        Rol rol = null;
        String sql = "{CALL sp_ListById(?,?)}";
        try (Connection conn = Conexion.getConnection();
            CallableStatement cs = conn.prepareCall(sql)) {
        	cs.setString(1, "Rol");
            cs.setInt(2, id);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    rol = new Rol(
                        rs.getInt("id_rol"),
                        rs.getString("nombre_rol"),
                        rs.getString("descripcion")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rol;
    }
}
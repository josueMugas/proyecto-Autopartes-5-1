package com.demografia.dao;

import com.demografia.modelo.Usuario;
import com.demografia.config.Conexion;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO implements IUsuarioDAO {

    @Override
    public List<Usuario> listAll() {
        List<Usuario> lista = new ArrayList<>();
        String sql = "{CALL sp_ListAll(?)}";
        try (Connection conn = Conexion.getConnection();
            CallableStatement cs = conn.prepareCall(sql)){
        	cs.setString(1, "Usuario");
            ResultSet rs = cs.executeQuery();
            while (rs.next()) {
                lista.add(new Usuario(
                    rs.getInt("id_usuario"), rs.getString("nombre_usuario"),
                    rs.getString("clave"), rs.getBoolean("activo"), rs.getInt("id_rol")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return lista;
    }

    @Override
    public boolean insert(Usuario u) {
        String sql = "{CALL sp_Insert_Usuario(?, ?, ?, ?)}";
        try (Connection conn = Conexion.getConnection();
            CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, u.getNombreUsuario()); cs.setString(2, u.getClave());
            cs.setBoolean(3, u.isActivo()); cs.setInt(4, u.getIdRol());
            return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean delete(int id) {
        String sql = "{CALL sp_Delete(?,?)}";
        try (Connection conn = Conexion.getConnection();
            CallableStatement cs = conn.prepareCall(sql)) {
        	cs.setString(1, "Usuario");
        	cs.setInt(2, id); return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public boolean update(Usuario u) {
        String sql = "{CALL sp_Update_Usuario(?, ?, ?, ?, ?)}";
        try (Connection conn = Conexion.getConnection();
            CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, u.getIdUsuario()); cs.setString(2, u.getNombreUsuario());
            cs.setString(3, u.getClave()); cs.setBoolean(4, u.isActivo());
            cs.setInt(5, u.getIdRol());
            return cs.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    @Override
    public Usuario listById(int id) {
        Usuario u = null;
        String sql = "{CALL sp_ListById(?,?)}";
        try (Connection conn = Conexion.getConnection();
            CallableStatement cs = conn.prepareCall(sql)) {
        	cs.setString(1, "Usuario");
        	cs.setInt(2, id);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    u = new Usuario(
                        rs.getInt("id_usuario"), rs.getString("nombre_usuario"),
                        rs.getString("clave"), rs.getBoolean("activo"), rs.getInt("id_rol")
                    );
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return u;
    }
}
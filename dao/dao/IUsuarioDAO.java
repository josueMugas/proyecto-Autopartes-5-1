package com.demografia.dao;

import com.demografia.modelo.Usuario;
import java.util.List;

public interface IUsuarioDAO {
    List<Usuario> listAll();
    boolean insert(Usuario usuario);
    boolean delete(int id);
    boolean update(Usuario usuario);
    Usuario listById(int id);
}
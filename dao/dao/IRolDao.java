package com.demografia.dao;

import java.util.List;

import com.demografia.modelo.*;

public interface IRolDao {
	boolean insertar(Rol r);
	List <Rol> listar();
	boolean actualizar (Rol r);
	boolean eliminar(int id);
}

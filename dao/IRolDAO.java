package com.demografia.dao;

import java.util.List;

import com.demografia.modelo.*;

public interface IRolDAO {
	 List<Rol> listAll();
    boolean insert(Rol Rol);
    boolean delete(int id);
    boolean update(Rol Rol);
    Rol listById(int id);}

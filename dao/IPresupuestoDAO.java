package com.demografia.dao;


import com.demografia.modelo.Presupuesto;
import java.util.List;

public interface IPresupuestoDAO {
	 List<Presupuesto> listAll();
    boolean insert(Presupuesto presupuesto);
    boolean delete(int id);
    boolean update(Presupuesto presupuesto);
    Presupuesto listById(int id);
}
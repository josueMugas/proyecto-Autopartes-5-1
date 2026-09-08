package com.demografia.dao;

import com.demografia.modelo.Insumo;
import java.util.List;

public interface IInsumoDAO {
    List<Insumo> listAll();
    boolean insert(Insumo insumo);
    boolean delete(int id);
    boolean update(Insumo insumo);
    Insumo listById(int id);
}
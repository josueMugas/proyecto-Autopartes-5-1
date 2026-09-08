package com.demografia.dao;

import com.demografia.modelo.Producto;
import java.util.List;

public interface IProductoDAO {
    List<Producto> listAll();
    boolean insert(Producto producto);
    boolean delete(int id);
    boolean update(Producto producto);
    Producto listById(int id);
}
package com.demografia.dao;

import com.demografia.modelo.Cliente;
import java.util.List;

public interface IClienteDAO {
    List<Cliente> listAll();
    boolean insert(Cliente Cliente);
    boolean delete(int id);
    boolean update(Cliente Cliente);
    Cliente listById(int id);
}
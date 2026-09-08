package com.demografia.dao;

import com.demografia.modelo.HojaDeRuta;
import java.util.List;

public interface IHojaDeRutaDAO {
    List<HojaDeRuta> listAll();
    boolean insert(HojaDeRuta hojaDeRuta);
    boolean delete(int id);
    boolean update(HojaDeRuta hojaDeRuta);
    HojaDeRuta listById(int id);
}
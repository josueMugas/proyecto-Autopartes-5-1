package com.demografia.controller;

import com.demografia.dao.ProductoDAO;
import com.demografia.modelo.Producto;
import com.google.gson.Gson;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

// Esta va a ser la URL de tu API
@WebServlet("/api/productos")
public class ProductoServlet extends HttpServlet {
    
    // Instanciamos tu DAO de productos y Gson
    private ProductoDAO productoDAO = new ProductoDAO();
    private Gson gson = new Gson();

    // 1. ENDPOINT PARA LEER PRODUCTOS (GET)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Configuramos cabeceras JSON y CORS (vital para que Vanilla JS no se bloquee)
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*"); 
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");

        try {
            // Usamos el método de tu ProductoDAO (revisá si se llama listar() u obtenerTodos())
            List<Producto> lista = productoDAO.listAll(); 
            
            // Convertimos la lista de Java a un texto JSON
            String jsonResponse = this.gson.toJson(lista);
            
            PrintWriter out = response.getWriter();
            out.print(jsonResponse);
            out.flush();
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"error\": \"Error interno al obtener productos: " + e.getMessage() + "\"}");
        }
    }

    // 2. ENDPOINT PARA CREAR UN PRODUCTO (POST)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");

        try {
            Producto nuevoProducto = gson.fromJson(request.getReader(), Producto.class);
            
            productoDAO.insert(nuevoProducto); 
            
            response.setStatus(HttpServletResponse.SC_CREATED); // Estado 201 Created
            response.getWriter().print("{\"mensaje\": \"Autoparte agregada con éxito\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"error\": \"Error al procesar el JSON: " + e.getMessage() + "\"}");
        }
    }

    // SOPORTE PARA PETICIONES OPTIONS (Requerido por los navegadores en peticiones CORS)
    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setStatus(HttpServletResponse.SC_OK);
    }
}

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author izzat
 */
public class DBConnection {
 
    private static final String HOST = System.getenv().getOrDefault("DB_HOST",     "localhost");
    private static final String PORT = System.getenv().getOrDefault("DB_PORT",     "3306");
    private static final String NAME = System.getenv().getOrDefault("DB_NAME",     "railtrack");
    private static final String USER = System.getenv().getOrDefault("DB_USER",     "root");
    private static final String PASS = System.getenv().getOrDefault("DB_PASSWORD", "");
 
    private static final String URL =
            "jdbc:mysql://" + HOST + ":" + PORT + "/" + NAME
            + "?useSSL=false&serverTimezone=GMT%2B8&allowPublicKeyRetrieval=true";
 
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC driver not found", e);
        }
    }
 
    private DBConnection() {}
 
    public static Connection get() throws SQLException {
    try {
        Connection conn = DriverManager.getConnection(URL, USER, PASS);
        System.out.println("✅ DB CONNECTED: " + URL);
        return conn;

    } catch (SQLException e) {
        System.out.println("❌ DB CONNECTION FAILED");
        e.printStackTrace();
        throw e;
    }
}
    
}
 
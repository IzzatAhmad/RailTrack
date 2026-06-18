/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.playground;

import com.railtrack.system.util.DBConnection;
import java.sql.Connection;

/**
 *
 * @author izzat
 */
public class TestDB {
    public static void main(String[] args) {
        try {
            Connection c = DBConnection.get();
            System.out.println("SUCCESS");
            c.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
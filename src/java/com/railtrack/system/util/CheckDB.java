package com.railtrack.system.util;
import java.sql.*;
import com.railtrack.system.dao.DBConnection;
public class CheckDB {
    public static void main(String[] args) throws Exception {
        try(Connection c = DBConnection.get()) {
            c.createStatement().executeUpdate("DELETE FROM rubrics WHERE title='Imported Rubrics Content'");
            System.out.println("DELETED");
        }
    }
}

package com.railtrack.system.controller;

import com.railtrack.system.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/coordinator/databases")
public class CoordinatorDatabaseServlet extends HttpServlet {

    public static class StudentDatabase {
        public String dbName;
        public int projectId;
        public String studentName;
        public String matricNumber;
        public String sizeMb;
        public int tableCount;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"COORDINATOR".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<StudentDatabase> dbs = new ArrayList<>();
        
        String sql = "SELECT schema_name, " +
                     "  COALESCE((SELECT SUM(data_length + index_length)/1024/1024 FROM information_schema.tables WHERE table_schema = schema_name), 0) as size_mb, " +
                     "  (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = schema_name) as table_count " +
                     "FROM information_schema.schemata " +
                     "WHERE schema_name LIKE 'student_db_%'";
                     
        String projectSql = "SELECT p.id, u.name, u.matric_number " +
                            "FROM projects p " +
                            "JOIN users u ON p.student_id = u.id " +
                            "WHERE p.id = ?";

        try (Connection conn = DBConnection.get();
             PreparedStatement ps = conn.prepareStatement(sql);
             PreparedStatement psProj = conn.prepareStatement(projectSql)) {
             
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                StudentDatabase sdb = new StudentDatabase();
                sdb.dbName = rs.getString("schema_name");
                sdb.sizeMb = String.format("%.2f", rs.getDouble("size_mb"));
                sdb.tableCount = rs.getInt("table_count");
                
                // Extract project ID from student_db_X
                try {
                    sdb.projectId = Integer.parseInt(sdb.dbName.substring(11));
                    
                    psProj.setInt(1, sdb.projectId);
                    try (ResultSet rsProj = psProj.executeQuery()) {
                        if (rsProj.next()) {
                            sdb.studentName = rsProj.getString("name");
                            sdb.matricNumber = rsProj.getString("matric_number");
                        }
                    }
                } catch (Exception e) {
                    sdb.projectId = 0;
                }
                
                dbs.add(sdb);
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error fetching databases: " + e.getMessage());
        }

        request.setAttribute("studentDatabases", dbs);
        request.setAttribute("pageTitle", "Student Databases");
        request.getRequestDispatcher("/views/coordinator/student_databases.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"COORDINATOR".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String dbName = request.getParameter("dbName");

        if ("drop".equals(action) && dbName != null && dbName.startsWith("student_db_")) {
            try (Connection conn = DBConnection.get();
                 PreparedStatement ps = conn.prepareStatement("DROP DATABASE IF EXISTS `" + dbName + "`")) {
                ps.executeUpdate();
                request.getSession().setAttribute("successMessage", "Database " + dbName + " has been successfully dropped.");
            } catch (Exception e) {
                request.getSession().setAttribute("errorMessage", "Failed to drop database: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/coordinator/databases");
    }
}

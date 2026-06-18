<%@ page import="java.sql.*, com.railtrack.system.util.DBConnection" %>
<%
    try (Connection c = DBConnection.get();
         Statement s = c.createStatement()) {
        s.execute("ALTER TABLE projects ADD COLUMN chapter_progress VARCHAR(50) DEFAULT '0,0,0,0,0,0,0,0'");
        out.println("Migration successful!");
    } catch (Exception e) {
        out.println("Migration failed: " + e.getMessage());
    }
%>

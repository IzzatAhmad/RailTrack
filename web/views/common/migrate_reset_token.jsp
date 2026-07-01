<%@ page import="java.sql.*, com.railtrack.system.util.DBConnection" %>
<%
    // Migration: Add password reset token columns to users table
    try (Connection c = DBConnection.get();
         Statement s = c.createStatement()) {
        s.execute(
            "ALTER TABLE users " +
            "ADD COLUMN IF NOT EXISTS password_reset_token VARCHAR(64) NULL, " +
            "ADD COLUMN IF NOT EXISTS reset_token_expiry DATETIME NULL"
        );
        out.println("<b style='color:green'>Migration successful!</b> Added password_reset_token + reset_token_expiry columns to users.");
    } catch (Exception e) {
        out.println("<b style='color:red'>Migration failed:</b> " + e.getMessage());
    }
%>

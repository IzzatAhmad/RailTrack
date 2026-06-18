package com.railtrack.system.dao;

import com.railtrack.system.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class SystemSettingsDAO {

    public String getSetting(String key, String defaultValue) throws SQLException {
        String sql = "SELECT setting_value FROM system_settings WHERE setting_key = ?";
        try (Connection conn = DBConnection.get();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("setting_value");
                }
            }
        }
        return defaultValue;
    }

    public void setSetting(String key, String value) throws SQLException {
        String sql = "INSERT INTO system_settings (setting_key, setting_value) VALUES (?, ?) " +
                     "ON DUPLICATE KEY UPDATE setting_value = ?";
        try (Connection conn = DBConnection.get();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            ps.setString(2, value);
            ps.setString(3, value);
            ps.executeUpdate();
        }
    }
}

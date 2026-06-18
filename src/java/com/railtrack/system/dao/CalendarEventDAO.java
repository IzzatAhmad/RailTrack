package com.railtrack.system.dao;

import com.railtrack.system.model.CalendarEvent;
import com.railtrack.system.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class CalendarEventDAO {

    static {
        String sql = "CREATE TABLE IF NOT EXISTS `calendar_events` (\n" +
                     "  `id` int(11) NOT NULL AUTO_INCREMENT,\n" +
                     "  `title` varchar(200) NOT NULL,\n" +
                     "  `description` text DEFAULT NULL,\n" +
                     "  `start_date` date NOT NULL,\n" +
                     "  `end_date` date DEFAULT NULL,\n" +
                     "  `color` varchar(20) DEFAULT '#2563eb',\n" +
                     "  `created_by_id` int(11) NOT NULL,\n" +
                     "  `created_at` datetime NOT NULL DEFAULT current_timestamp(),\n" +
                     "  PRIMARY KEY (`id`),\n" +
                     "  FOREIGN KEY (`created_by_id`) REFERENCES `users` (`id`) ON DELETE CASCADE\n" +
                     ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;";
        try (Connection conn = DBConnection.get();
             Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private CalendarEvent map(ResultSet rs) throws SQLException {
        CalendarEvent event = new CalendarEvent();
        event.setId(rs.getInt("id"));
        event.setTitle(rs.getString("title"));
        event.setDescription(rs.getString("description"));
        
        Date startDate = rs.getDate("start_date");
        if (startDate != null) {
            event.setStartDate(startDate.toLocalDate());
        }

        Date endDate = rs.getDate("end_date");
        if (endDate != null) {
            event.setEndDate(endDate.toLocalDate());
        }

        event.setColor(rs.getString("color"));
        event.setCreatedById(rs.getInt("created_by_id"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            event.setCreatedAt(createdAt.toLocalDateTime());
        }

        return event;
    }

    public List<CalendarEvent> findAll() throws SQLException {
        String sql = "SELECT * FROM calendar_events ORDER BY start_date ASC";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            List<CalendarEvent> events = new ArrayList<>();
            while (rs.next()) {
                events.add(map(rs));
            }
            return events;
        }
    }

    public void insert(CalendarEvent event) throws SQLException {
        String sql = "INSERT INTO calendar_events (title, description, start_date, end_date, color, created_by_id) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, event.getTitle());
            ps.setString(2, event.getDescription());
            ps.setDate(3, event.getStartDate() != null ? Date.valueOf(event.getStartDate()) : null);
            ps.setDate(4, event.getEndDate() != null ? Date.valueOf(event.getEndDate()) : null);
            ps.setString(5, event.getColor());
            ps.setInt(6, event.getCreatedById());
            
            ps.executeUpdate();
            
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    event.setId(keys.getInt(1));
                }
            }
        }
    }

    public void update(CalendarEvent event) throws SQLException {
        String sql = "UPDATE calendar_events SET title = ?, description = ?, start_date = ?, end_date = ?, color = ? WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, event.getTitle());
            ps.setString(2, event.getDescription());
            ps.setDate(3, event.getStartDate() != null ? Date.valueOf(event.getStartDate()) : null);
            ps.setDate(4, event.getEndDate() != null ? Date.valueOf(event.getEndDate()) : null);
            ps.setString(5, event.getColor());
            ps.setInt(6, event.getId());
            ps.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM calendar_events WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}

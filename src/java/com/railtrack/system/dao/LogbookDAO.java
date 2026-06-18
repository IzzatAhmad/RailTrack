package com.railtrack.system.dao;

import com.railtrack.system.model.LogbookEntry;
import com.railtrack.system.model.LogbookImage;
import com.railtrack.system.util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class LogbookDAO {

    // ── LogbookEntry mapping ──────────────────────────────────────────────────

    private LogbookEntry map(ResultSet rs, Connection conn) throws SQLException {
        LogbookEntry entry = new LogbookEntry();
        entry.setId(rs.getInt("id"));
        entry.setStudentId(rs.getInt("student_id"));
        entry.setProjectId(rs.getInt("project_id"));

        Date d = rs.getDate("activity_date");
        if (d != null) entry.setActivityDate(d.toLocalDate());

        Time t = rs.getTime("activity_time");
        if (t != null) entry.setActivityTime(t.toLocalTime());

        entry.setActivityType(rs.getString("activity_type"));
        entry.setActivityDetails(rs.getString("activity_details"));
        entry.setProblems(rs.getString("problems"));
        entry.setSuggestions(rs.getString("suggestions"));
        entry.setVerified(rs.getBoolean("is_verified"));

        Timestamp c = rs.getTimestamp("created_at");
        if (c != null) entry.setCreatedAt(c.toLocalDateTime());

        Timestamp u = rs.getTimestamp("updated_at");
        if (u != null) entry.setUpdatedAt(u.toLocalDateTime());

        entry.setImages(loadImages(entry.getId(), conn));

        return entry;
    }

    // ── Load image metadata (NO binary data — avoids reading large BLOBs on list) ──

    private List<LogbookImage> loadImages(int logbookId, Connection conn) throws SQLException {
        String sql = "SELECT id, logbook_id, file_name, content_type, file_size, created_at " +
                     "FROM logbook_images WHERE logbook_id = ? ORDER BY id ASC";
        List<LogbookImage> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, logbookId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LogbookImage img = new LogbookImage();
                    img.setId(rs.getInt("id"));
                    img.setLogbookId(rs.getInt("logbook_id"));
                    img.setFileName(rs.getString("file_name"));
                    img.setContentType(rs.getString("content_type"));
                    img.setFileSize(rs.getInt("file_size"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) img.setCreatedAt(ts.toLocalDateTime());
                    list.add(img);
                }
            }
        }
        return list;
    }

    /**
     * Fetch the raw binary data for a single logbook image by its ID.
     * Returns null if not found.
     */
    public byte[] getImageData(int imageId) throws SQLException {
        String sql = "SELECT file_data FROM logbook_images WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, imageId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBytes("file_data");
                }
            }
        }
        return null;
    }

    /**
     * Fetch image metadata (no binary) for a single image — used by FileDownloadServlet
     * to set Content-Type and Content-Disposition before streaming.
     */
    public LogbookImage getImageMeta(int imageId) throws SQLException {
        String sql = "SELECT id, logbook_id, file_name, content_type, file_size, created_at " +
                     "FROM logbook_images WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, imageId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LogbookImage img = new LogbookImage();
                    img.setId(rs.getInt("id"));
                    img.setLogbookId(rs.getInt("logbook_id"));
                    img.setFileName(rs.getString("file_name"));
                    img.setContentType(rs.getString("content_type"));
                    img.setFileSize(rs.getInt("file_size"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) img.setCreatedAt(ts.toLocalDateTime());
                    return img;
                }
            }
        }
        return null;
    }

    // ── Queries ───────────────────────────────────────────────────────────────

    public List<LogbookEntry> findByStudent(int studentId) throws SQLException {
        String sql = "SELECT * FROM logbook WHERE student_id = ? ORDER BY activity_date DESC, activity_time DESC";
        List<LogbookEntry> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs, c));
                }
            }
        }
        return list;
    }

    public List<LogbookEntry> findByProject(int projectId) throws SQLException {
        String sql = "SELECT * FROM logbook WHERE project_id = ? ORDER BY activity_date DESC, activity_time DESC";
        List<LogbookEntry> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs, c));
                }
            }
        }
        return list;
    }

    public LogbookEntry findById(int id) throws SQLException {
        String sql = "SELECT * FROM logbook WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs, c);
                }
            }
        }
        return null;
    }

    public java.util.Map<String, Integer> getSystemWideMonthlySubmissions() throws SQLException {
        String sql = "SELECT MONTH(activity_date) as m, COUNT(*) as c FROM logbook WHERE activity_date IS NOT NULL GROUP BY MONTH(activity_date)";
        java.util.Map<String, Integer> map = new java.util.LinkedHashMap<>();
        String[] months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
        for (String m : months) map.put(m, 0);

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int month = rs.getInt("m");
                int count = rs.getInt("c");
                if (month >= 1 && month <= 12) {
                    map.put(months[month - 1], count);
                }
            }
        }
        return map;
    }

    // ── Save logbook entry + images ───────────────────────────────────────────

    public void save(LogbookEntry entry) throws SQLException {
        String sql = "INSERT INTO logbook (student_id, project_id, activity_date, activity_time, " +
                     "activity_type, activity_details, problems, suggestions, is_verified) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, entry.getStudentId());
            ps.setInt(2, entry.getProjectId());
            ps.setDate(3, Date.valueOf(entry.getActivityDate()));
            ps.setTime(4, Time.valueOf(entry.getActivityTime()));
            ps.setString(5, entry.getActivityType());
            ps.setString(6, entry.getActivityDetails());
            ps.setString(7, entry.getProblems());
            ps.setString(8, entry.getSuggestions());
            ps.setBoolean(9, entry.isVerified());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    entry.setId(keys.getInt(1));
                }
            }
        }
        if (entry.getImageBlobs() != null && !entry.getImageBlobs().isEmpty()) {
            saveImageBlobs(entry.getId(), entry.getImageBlobs());
        }
    }

    /**
     * Saves a list of image BLOBs to logbook_images.
     * Each element in the list is a LogbookImageUpload holding name, type, and raw bytes.
     */
    private void saveImageBlobs(int logbookId, List<LogbookImageUpload> uploads) throws SQLException {
        String sql = "INSERT INTO logbook_images (logbook_id, file_name, content_type, file_size, file_data) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            for (LogbookImageUpload u : uploads) {
                ps.setInt(1, logbookId);
                ps.setString(2, u.fileName);
                ps.setString(3, u.contentType);
                ps.setInt(4, u.data.length);
                ps.setBytes(5, u.data);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    public void updateVerification(int id, boolean verified) throws SQLException {
        String sql = "UPDATE logbook SET is_verified = ? WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setBoolean(1, verified);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    // ── Inner helper class for upload transfer ────────────────────────────────

    /** Transient holder: carries raw bytes from the servlet to the DAO during an upload. */
    public static class LogbookImageUpload {
        public final String fileName;
        public final String contentType;
        public final byte[] data;

        public LogbookImageUpload(String fileName, String contentType, byte[] data) {
            this.fileName = fileName;
            this.contentType = contentType;
            this.data = data;
        }
    }
}

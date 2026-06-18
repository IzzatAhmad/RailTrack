package com.railtrack.system.dao;

import com.railtrack.system.model.Rubric;
import com.railtrack.system.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RubricDAO {

    public List<Rubric> findAll() throws SQLException {
        ensureTable();
        String sql = "SELECT * FROM rubrics ORDER BY section ASC, sort_order ASC, id ASC";
        List<Rubric> rubrics = new ArrayList<>();
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) rubrics.add(map(rs));
        }
        return rubrics;
    }

    public List<Rubric> findEnabled() throws SQLException {
        ensureTable();
        String sql = "SELECT * FROM rubrics WHERE is_enabled = 1 ORDER BY section ASC, sort_order ASC, id ASC";
        List<Rubric> rubrics = new ArrayList<>();
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) rubrics.add(map(rs));
        }
        return rubrics;
    }

    public Rubric findById(int id) throws SQLException {
        ensureTable();
        String sql = "SELECT * FROM rubrics WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public void insert(Rubric rubric) throws SQLException {
        ensureTable();
        String sql = "INSERT INTO rubrics (section, title, content, sort_order, is_enabled) VALUES (?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, rubric.getSection());
            ps.setString(2, rubric.getTitle());
            ps.setString(3, rubric.getContent());
            ps.setInt(4, rubric.getSortOrder());
            ps.setInt(5, rubric.isEnabled() ? 1 : 0);
            ps.executeUpdate();
        }
    }

    public void update(Rubric rubric) throws SQLException {
        ensureTable();
        String sql = "UPDATE rubrics SET section=?, title=?, content=?, sort_order=?, is_enabled=? WHERE id=?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, rubric.getSection());
            ps.setString(2, rubric.getTitle());
            ps.setString(3, rubric.getContent());
            ps.setInt(4, rubric.getSortOrder());
            ps.setInt(5, rubric.isEnabled() ? 1 : 0);
            ps.setInt(6, rubric.getId());
            ps.executeUpdate();
        }
    }

    public void toggleEnabled(int id, boolean enabled) throws SQLException {
        ensureTable();
        String sql = "UPDATE rubrics SET is_enabled=? WHERE id=?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, enabled ? 1 : 0);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        ensureTable();
        String sql = "DELETE FROM rubrics WHERE id=?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private void ensureTable() throws SQLException {
        String createSql = "CREATE TABLE IF NOT EXISTS rubrics ("
                + "id int(11) NOT NULL AUTO_INCREMENT,"
                + "section varchar(100) NOT NULL,"
                + "title varchar(200) NOT NULL,"
                + "content longtext,"
                + "sort_order int(11) NOT NULL DEFAULT 0,"
                + "is_enabled tinyint(1) NOT NULL DEFAULT 1,"
                + "created_at timestamp NOT NULL DEFAULT current_timestamp(),"
                + "updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),"
                + "PRIMARY KEY (id),"
                + "KEY idx_rubrics_section (section),"
                + "KEY idx_rubrics_enabled (is_enabled)"
                + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci";
        try (Connection c = DBConnection.get();
             Statement st = c.createStatement()) {
            st.execute(createSql);
        }
    }

    private Rubric map(ResultSet rs) throws SQLException {
        return new Rubric(
                rs.getInt("id"),
                rs.getString("section"),
                rs.getString("title"),
                rs.getString("content"),
                rs.getInt("sort_order"),
                rs.getInt("is_enabled") == 1,
                rs.getTimestamp("created_at"),
                rs.getTimestamp("updated_at")
        );
    }
}

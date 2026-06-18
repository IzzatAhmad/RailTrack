package com.railtrack.system.dao;

import com.railtrack.system.model.MaterialLink;
import com.railtrack.system.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MaterialLinkDAO {

    public List<MaterialLink> findAll() throws SQLException {
        ensureTable();
        String sql = "SELECT * FROM material_links ORDER BY section ASC, sort_order ASC, id ASC";
        List<MaterialLink> links = new ArrayList<>();
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) links.add(map(rs));
        }
        return links;
    }

    public List<MaterialLink> findEnabled() throws SQLException {
        ensureTable();
        String sql = "SELECT * FROM material_links WHERE is_enabled = 1 ORDER BY section ASC, sort_order ASC, id ASC";
        List<MaterialLink> links = new ArrayList<>();
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) links.add(map(rs));
        }
        return links;
    }

    public MaterialLink findById(int id) throws SQLException {
        ensureTable();
        String sql = "SELECT * FROM material_links WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public void insert(MaterialLink link) throws SQLException {
        ensureTable();
        String sql = "INSERT INTO material_links (section, title, url, sort_order, is_enabled) VALUES (?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, link.getSection());
            ps.setString(2, link.getTitle());
            ps.setString(3, link.getUrl());
            ps.setInt(4, link.getSortOrder());
            ps.setInt(5, link.isEnabled() ? 1 : 0);
            ps.executeUpdate();
        }
    }

    public void update(MaterialLink link) throws SQLException {
        ensureTable();
        String sql = "UPDATE material_links SET section=?, title=?, url=?, sort_order=?, is_enabled=? WHERE id=?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, link.getSection());
            ps.setString(2, link.getTitle());
            ps.setString(3, link.getUrl());
            ps.setInt(4, link.getSortOrder());
            ps.setInt(5, link.isEnabled() ? 1 : 0);
            ps.setInt(6, link.getId());
            ps.executeUpdate();
        }
    }

    public void toggleEnabled(int id, boolean enabled) throws SQLException {
        ensureTable();
        String sql = "UPDATE material_links SET is_enabled=? WHERE id=?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, enabled ? 1 : 0);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        ensureTable();
        String sql = "DELETE FROM material_links WHERE id=?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private void ensureTable() throws SQLException {
        String createSql = "CREATE TABLE IF NOT EXISTS material_links ("
                + "id int(11) NOT NULL AUTO_INCREMENT,"
                + "section varchar(100) NOT NULL,"
                + "title varchar(200) NOT NULL,"
                + "url varchar(500) NOT NULL,"
                + "sort_order int(11) NOT NULL DEFAULT 0,"
                + "is_enabled tinyint(1) NOT NULL DEFAULT 1,"
                + "created_at timestamp NOT NULL DEFAULT current_timestamp(),"
                + "updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),"
                + "PRIMARY KEY (id),"
                + "KEY idx_material_links_section (section),"
                + "KEY idx_material_links_enabled (is_enabled)"
                + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci";
        try (Connection c = DBConnection.get();
             Statement st = c.createStatement()) {
            st.execute(createSql);
        }
    }

    private MaterialLink map(ResultSet rs) throws SQLException {
        return new MaterialLink(
                rs.getInt("id"),
                rs.getString("section"),
                rs.getString("title"),
                rs.getString("url"),
                rs.getInt("sort_order"),
                rs.getInt("is_enabled") == 1
        );
    }
}

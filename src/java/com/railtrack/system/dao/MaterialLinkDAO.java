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

    public int insert(MaterialLink link) throws SQLException {
        ensureTable();
        String sql = "INSERT INTO material_links (section, title, url, sort_order, is_enabled, file_name, file_type, file_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, link.getSection());
            ps.setString(2, link.getTitle());
            ps.setString(3, link.getUrl());
            ps.setInt(4, link.getSortOrder());
            ps.setInt(5, link.isEnabled() ? 1 : 0);
            ps.setString(6, link.getFileName());
            ps.setString(7, link.getFileType());
            if (link.getFileData() != null) {
                ps.setBytes(8, link.getFileData());
            } else {
                ps.setNull(8, java.sql.Types.BLOB);
            }
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    public void update(MaterialLink link) throws SQLException {
        ensureTable();
        String sql;
        if (link.getFileData() != null) {
            sql = "UPDATE material_links SET section=?, title=?, url=?, sort_order=?, is_enabled=?, file_name=?, file_type=?, file_data=? WHERE id=?";
        } else {
            sql = "UPDATE material_links SET section=?, title=?, url=?, sort_order=?, is_enabled=? WHERE id=?";
        }
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, link.getSection());
            ps.setString(2, link.getTitle());
            ps.setString(3, link.getUrl());
            ps.setInt(4, link.getSortOrder());
            ps.setInt(5, link.isEnabled() ? 1 : 0);
            if (link.getFileData() != null) {
                ps.setString(6, link.getFileName());
                ps.setString(7, link.getFileType());
                ps.setBytes(8, link.getFileData());
                ps.setInt(9, link.getId());
            } else {
                ps.setInt(6, link.getId());
            }
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

    public MaterialLink getFileData(int id) throws SQLException {
        ensureTable();
        String sql = "SELECT file_name, file_type, file_data FROM material_links WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    MaterialLink link = new MaterialLink();
                    link.setId(id);
                    link.setFileName(rs.getString("file_name"));
                    link.setFileType(rs.getString("file_type"));
                    link.setFileData(rs.getBytes("file_data"));
                    return link;
                }
            }
        }
        return null;
    }

    private void ensureTable() throws SQLException {
        String createSql = "CREATE TABLE IF NOT EXISTS material_links ("
                + "id int(11) NOT NULL AUTO_INCREMENT,"
                + "section varchar(100) NOT NULL,"
                + "title varchar(200) NOT NULL,"
                + "url varchar(500) NOT NULL,"
                + "sort_order int(11) NOT NULL DEFAULT 0,"
                + "is_enabled tinyint(1) NOT NULL DEFAULT 1,"
                + "file_name varchar(255) DEFAULT NULL,"
                + "file_type varchar(100) DEFAULT NULL,"
                + "file_data LONGBLOB DEFAULT NULL,"
                + "created_at timestamp NOT NULL DEFAULT current_timestamp(),"
                + "updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),"
                + "PRIMARY KEY (id),"
                + "KEY idx_material_links_section (section),"
                + "KEY idx_material_links_enabled (is_enabled)"
                + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci";
        try (Connection c = DBConnection.get();
             Statement st = c.createStatement()) {
            st.execute(createSql);
            
            // Try adding columns if they don't exist (for migration)
            try { st.execute("ALTER TABLE material_links ADD COLUMN file_name varchar(255) DEFAULT NULL"); } catch (Exception e) {}
            try { st.execute("ALTER TABLE material_links ADD COLUMN file_type varchar(100) DEFAULT NULL"); } catch (Exception e) {}
            try { st.execute("ALTER TABLE material_links ADD COLUMN file_data LONGBLOB DEFAULT NULL"); } catch (Exception e) {}
        }
    }

    private MaterialLink map(ResultSet rs) throws SQLException {
        MaterialLink link = new MaterialLink(
                rs.getInt("id"),
                rs.getString("section"),
                rs.getString("title"),
                rs.getString("url"),
                rs.getInt("sort_order"),
                rs.getInt("is_enabled") == 1
        );
        try { link.setFileName(rs.getString("file_name")); } catch (Exception e) {}
        try { link.setFileType(rs.getString("file_type")); } catch (Exception e) {}
        return link;
    }
}

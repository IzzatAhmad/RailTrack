/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.dao;

import com.railtrack.system.model.MenuItem;
import com.railtrack.system.util.DBConnection;
 
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
 

/**
 *
 * @author izzat
 */
public class MenuItemDAO {
 
    // ── Read ────────────────────────────────────────────────────────────
 
    /** All items ordered by sort_order (used by coordinator management page). */
    public List<MenuItem> findAll() throws SQLException {
        String sql = "SELECT * FROM student_menu_items ORDER BY sort_order ASC";
        List<MenuItem> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }
 
    /** Only enabled items – used by student dashboard. */
    public List<MenuItem> findEnabled() throws SQLException {
        String sql = "SELECT * FROM student_menu_items WHERE is_enabled = 1 ORDER BY sort_order ASC";
        List<MenuItem> list = new ArrayList<>();
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }
 
    public MenuItem findById(int id) throws SQLException {
        String sql = "SELECT * FROM student_menu_items WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }
 
    // ── Write ───────────────────────────────────────────────────────────
 
    public void insert(MenuItem m) throws SQLException {
        String sql = "INSERT INTO student_menu_items "
                   + "(item_key, label, icon, icon_color, url, sort_order, is_enabled) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, m.getItemKey());
            ps.setString(2, m.getLabel());
            ps.setString(3, m.getIcon());
            ps.setString(4, m.getIconColor());
            ps.setString(5, m.getUrl());
            ps.setInt   (6, m.getSortOrder());
            ps.setInt   (7, m.isEnabled() ? 1 : 0);
            ps.executeUpdate();
        }
    }
 
    public void update(MenuItem m) throws SQLException {
        String sql = "UPDATE student_menu_items "
                   + "SET label=?, icon=?, icon_color=?, url=?, sort_order=?, is_enabled=? "
                   + "WHERE id=?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, m.getLabel());
            ps.setString(2, m.getIcon());
            ps.setString(3, m.getIconColor());
            ps.setString(4, m.getUrl());
            ps.setInt   (5, m.getSortOrder());
            ps.setInt   (6, m.isEnabled() ? 1 : 0);
            ps.setInt   (7, m.getId());
            ps.executeUpdate();
        }
    }
 
    /** Toggle is_enabled for a single row. */
    public void toggleEnabled(int id, boolean enabled) throws SQLException {
        String sql = "UPDATE student_menu_items SET is_enabled=? WHERE id=?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, enabled ? 1 : 0);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }
 
    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM student_menu_items WHERE id=?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
 
    // ── Mapper ──────────────────────────────────────────────────────────
 
    private MenuItem map(ResultSet rs) throws SQLException {
        return new MenuItem(
            rs.getInt   ("id"),
            rs.getString("item_key"),
            rs.getString("label"),
            rs.getString("icon"),
            rs.getString("icon_color"),
            rs.getString("url"),
            rs.getInt   ("sort_order"),
            rs.getInt   ("is_enabled") == 1
        );
    }
}
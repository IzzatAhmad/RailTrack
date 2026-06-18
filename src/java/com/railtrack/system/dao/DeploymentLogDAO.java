/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.dao;

import com.railtrack.system.model.DeploymentLog;
import com.railtrack.system.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author izzat
 */
public class DeploymentLogDAO {

    // ── Mapping ───────────────────────────────────────────────────────────────
    private DeploymentLog map(ResultSet rs) throws SQLException {
        DeploymentLog log = new DeploymentLog();
        log.setId(rs.getInt("id"));
        log.setProjectId(rs.getInt("project_id"));
        log.setPerformedById(rs.getInt("performed_by_id"));
        log.setPerformedByName(rs.getString("performer_name"));
        log.setAction(DeploymentLog.Action.valueOf(rs.getString("action")));
        log.setOutcome(rs.getString("outcome"));
        log.setDetail(rs.getString("detail"));

        Timestamp ts = rs.getTimestamp("performed_at");
        if (ts != null) {
            log.setPerformedAt(ts.toLocalDateTime());
        }

        try {
            log.setProjectTitle(rs.getString("project_title"));
        } catch (SQLException ignored) {
            // project_title column not present in this ResultSet
        }

        return log;
    }

    // ── Read ──────────────────────────────────────────────────────────────────
    /**
     * All logs for a project, newest first.
     */
    public List<DeploymentLog> findByProject(int projectId) throws SQLException {
        String sql
                = "SELECT dl.*, u.full_name AS performer_name "
                + "FROM deployment_logs dl "
                + "JOIN users u ON u.id = dl.performed_by_id "
                + "WHERE dl.project_id = ? "
                + "ORDER BY dl.performed_at DESC";

        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, projectId);

            try (ResultSet rs = ps.executeQuery()) {
                List<DeploymentLog> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    /**
     * Most recent N logs for a project — used for the live log strip in the UI.
     */
    public List<DeploymentLog> findRecentByProject(int projectId, int limit) throws SQLException {
        String sql
                = "SELECT dl.*, u.full_name AS performer_name "
                + "FROM deployment_logs dl "
                + "JOIN users u ON u.id = dl.performed_by_id "
                + "WHERE dl.project_id = ? "
                + "ORDER BY dl.performed_at DESC "
                + "LIMIT ?";

        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            ps.setInt(2, limit);

            try (ResultSet rs = ps.executeQuery()) {
                List<DeploymentLog> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    // ── Create ────────────────────────────────────────────────────────────────
    public void insert(DeploymentLog log) throws SQLException {
        String sql
                = "INSERT INTO deployment_logs "
                + "(project_id, performed_by_id, action, outcome, detail) "
                + "VALUES (?, ?, ?, ?, ?)";

        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, log.getProjectId());
            ps.setInt(2, log.getPerformedById());
            ps.setString(3, log.getAction().name());
            ps.setString(4, log.getOutcome());
            ps.setString(5, log.getDetail());

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    log.setId(keys.getInt(1));
                }
            }
        }
    }

    /**
     * Convenience factory: create and persist a log entry in one call.
     */
    public void log(int projectId, int performedById,
            DeploymentLog.Action action, String outcome, String detail) throws SQLException {
        DeploymentLog entry = new DeploymentLog(projectId, performedById, action, outcome);
        entry.setDetail(detail);
        insert(entry);
    }

    /**
     * Fetches the most recent deployment logs across all projects.
     */
    public List<DeploymentLog> findRecent(int limit) throws SQLException {
        String sql
                = "SELECT dl.*, u.full_name AS performer_name, p.title AS project_title "
                + "FROM deployment_logs dl "
                + "JOIN users u ON u.id = dl.performed_by_id "
                + "LEFT JOIN projects p ON p.id = dl.project_id "
                + "ORDER BY dl.performed_at DESC "
                + "LIMIT ?";

        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, limit);

            try (ResultSet rs = ps.executeQuery()) {
                List<DeploymentLog> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }
}

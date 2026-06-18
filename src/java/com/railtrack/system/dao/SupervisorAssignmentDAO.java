package com.railtrack.system.dao;

import com.railtrack.system.model.SupervisorAssignment;
import com.railtrack.system.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SupervisorAssignmentDAO {

    // ── Mapping ───────────────────────────────────────────────────────────────

    private SupervisorAssignment map(ResultSet rs) throws SQLException {
        SupervisorAssignment sa = new SupervisorAssignment();
        sa.setId(rs.getInt("id"));
        sa.setProjectId(rs.getInt("project_id"));
        sa.setProjectTitle(rs.getString("project_title"));
        sa.setSupervisorId(rs.getInt("supervisor_id"));
        sa.setSupervisorName(rs.getString("supervisor_name"));
        sa.setAssignedById(rs.getInt("assigned_by_id"));
        sa.setAssignedByName(rs.getString("assigned_by_name"));
        sa.setNote(rs.getString("note"));

        Timestamp ts = rs.getTimestamp("assigned_at");
        if (ts != null) {
            sa.setAssignedAt(ts.toLocalDateTime());
        }

        return sa;
    }

    private static final String BASE_SELECT =
            "SELECT sa.*, " +
            "p.title AS project_title, " +
            "sv.full_name AS supervisor_name, " +
            "ab.full_name AS assigned_by_name " +
            "FROM supervisor_assignments sa " +
            "JOIN projects p ON p.id = sa.project_id " +
            "JOIN users sv ON sv.id = sa.supervisor_id " +
            "JOIN users ab ON ab.id = sa.assigned_by_id ";

    // ── Read ──────────────────────────────────────────────────────────────────

    public List<SupervisorAssignment> findByProject(int projectId) throws SQLException {
        String sql = BASE_SELECT +
                " WHERE sa.project_id = ? ORDER BY sa.assigned_at DESC";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, projectId);

            try (ResultSet rs = ps.executeQuery()) {
                List<SupervisorAssignment> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    public List<SupervisorAssignment> findByCoordinator(int coordinatorId) throws SQLException {
        String sql = BASE_SELECT +
                " WHERE sa.assigned_by_id = ? ORDER BY sa.assigned_at DESC";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, coordinatorId);

            try (ResultSet rs = ps.executeQuery()) {
                List<SupervisorAssignment> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    // ── Create ────────────────────────────────────────────────────────────────

    public void insert(SupervisorAssignment sa) throws SQLException {
        String sql =
                "INSERT INTO supervisor_assignments " +
                "(project_id, supervisor_id, assigned_by_id, note) " +
                "VALUES (?, ?, ?, ?)";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, sa.getProjectId());
            ps.setInt(2, sa.getSupervisorId());
            ps.setInt(3, sa.getAssignedById());
            ps.setString(4, sa.getNote());

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    sa.setId(keys.getInt(1));
                }
            }
        }
    }
}
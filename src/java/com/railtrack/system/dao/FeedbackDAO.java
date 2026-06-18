/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.dao;

import com.railtrack.system.model.Feedback;
import com.railtrack.system.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author izzat
 */
public class FeedbackDAO {

    // ── Mapping ───────────────────────────────────────────────────────────────
    private Feedback map(ResultSet rs) throws SQLException {
        Feedback f = new Feedback();
        f.setId(rs.getInt("id"));
        f.setProjectId(rs.getInt("project_id"));
        f.setAuthorId(rs.getInt("author_id"));
        f.setAuthorName(rs.getString("author_name"));
        f.setType(Feedback.FeedbackType.valueOf(rs.getString("type")));
        f.setContent(rs.getString("content"));
        f.setReadByStudent(rs.getBoolean("read_by_student"));

        int milestoneId = rs.getInt("milestone_id");
        f.setMilestoneId(rs.wasNull() ? null : milestoneId);

        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) {
            f.setCreatedAt(created.toLocalDateTime());
        }

        Timestamp read = rs.getTimestamp("read_at");
        if (read != null) {
            f.setReadAt(read.toLocalDateTime());
        }

        // project_title only in joined queries
        try {
            f.setProjectTitle(rs.getString("project_title"));
        } catch (SQLException ignored) {
        }

        return f;
    }

    private static final String BASE_SELECT
            = "SELECT f.*, "
            + "u.full_name AS author_name, "
            + "p.title AS project_title "
            + "FROM feedback f "
            + "JOIN users u ON u.id = f.author_id "
            + "JOIN projects p ON p.id = f.project_id ";

    // ── Read ──────────────────────────────────────────────────────────────────
    public Feedback findById(int id) throws SQLException {
        String sql = BASE_SELECT + " WHERE f.id = ?";
        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    /**
     * All feedback for a project, newest first.
     */
    public List<Feedback> findByProject(int projectId) throws SQLException {
        String sql = BASE_SELECT + " WHERE f.project_id = ? ORDER BY f.created_at DESC";
        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                List<Feedback> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    /**
     * Feedback tied to a specific milestone.
     */
    public List<Feedback> findByMilestone(int milestoneId) throws SQLException {
        String sql = BASE_SELECT + " WHERE f.milestone_id = ? ORDER BY f.created_at DESC";
        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, milestoneId);
            try (ResultSet rs = ps.executeQuery()) {
                List<Feedback> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    /**
     * Unread feedback for a student across all their projects.
     */
    public List<Feedback> findUnreadByStudent(int studentId) throws SQLException {
        String sql = BASE_SELECT
                + " JOIN projects pr ON pr.id = f.project_id "
                + " WHERE pr.student_id = ? "
                + " AND f.read_by_student = 0 "
                + " ORDER BY f.created_at DESC";

        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                List<Feedback> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    /**
     * All feedback written by a supervisor/coordinator.
     */
    public List<Feedback> findByAuthor(int authorId) throws SQLException {
        String sql = BASE_SELECT + " WHERE f.author_id = ? ORDER BY f.created_at DESC";
        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, authorId);
            try (ResultSet rs = ps.executeQuery()) {
                List<Feedback> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    // ── Create ────────────────────────────────────────────────────────────────
    public void insert(Feedback f) throws SQLException {
        String sql
                = "INSERT INTO feedback "
                + " (project_id, milestone_id, author_id, type, content) "
                + " VALUES (?, ?, ?, ?, ?)";

        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, f.getProjectId());

            if (f.getMilestoneId() != null) {
                ps.setInt(2, f.getMilestoneId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }

            ps.setInt(3, f.getAuthorId());
            ps.setString(4, f.getType().name());
            ps.setString(5, f.getContent());

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    f.setId(keys.getInt(1));
                }
            }
        }
    }

    // ── Update ────────────────────────────────────────────────────────────────
    public void updateContent(int feedbackId, String newContent) throws SQLException {
        String sql = "UPDATE feedback SET content = ? WHERE id = ?";
        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, newContent);
            ps.setInt(2, feedbackId);
            ps.executeUpdate();
        }
    }

    // ── Read tracking ─────────────────────────────────────────────────────────
    /**
     * Mark a single feedback item as read by the student.
     */
    public void markRead(int feedbackId) throws SQLException {
        String sql
                = "UPDATE feedback "
                + "SET read_by_student = 1, "
                + "    read_at = NOW() "
                + "WHERE id = ? AND read_by_student = 0";

        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, feedbackId);
            ps.executeUpdate();
        }
    }

    /**
     * Mark ALL unread feedback on a project as read — called when student opens
     * project page.
     */
    public void markAllReadForProject(int projectId) throws SQLException {
        String sql
                = "UPDATE feedback "
                + "SET read_by_student = 1, "
                + "    read_at = NOW() "
                + "WHERE project_id = ? AND read_by_student = 0";

        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            ps.executeUpdate();
        }
    }

    // ── Stats ─────────────────────────────────────────────────────────────────
    public long countUnreadByProject(int projectId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM feedback WHERE project_id = ? AND read_by_student = 0";
        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong(1) : 0;
            }
        }
    }

    // ── Delete ────────────────────────────────────────────────────────────────
    public void delete(int feedbackId) throws SQLException {
        String sql = "DELETE FROM feedback WHERE id = ?";
        try (Connection c = DBConnection.get(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, feedbackId);
            ps.executeUpdate();
        }
    }
}

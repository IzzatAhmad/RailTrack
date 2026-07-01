package com.railtrack.system.dao;

import com.railtrack.system.model.Milestone;
import com.railtrack.system.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MilestoneDAO {

    // ── Mapping ───────────────────────────────────────────────────────────────

    private Milestone map(ResultSet rs) throws SQLException {
        Milestone m = new Milestone();
        m.setId(rs.getInt("id"));
        m.setProjectId(rs.getInt("project_id"));
        m.setMilestoneNo(rs.getInt("milestone_no"));
        m.setTitle(rs.getString("title"));
        m.setDescription(rs.getString("description"));
        m.setStatus(Milestone.MilestoneStatus.valueOf(rs.getString("status")));
        m.setWeight(rs.getDouble("weight"));

        double grade = rs.getDouble("grade");
        m.setGrade(rs.wasNull() ? null : grade);

        m.setSupervisorNote(rs.getString("supervisor_note"));
        m.setSubmissionNote(rs.getString("submission_note"));

        Date due = rs.getDate("due_date");
        if (due != null) m.setDueDate(due.toLocalDate());

        Timestamp sub = rs.getTimestamp("submitted_at");
        if (sub != null) m.setSubmittedAt(sub.toLocalDateTime());

        Timestamp rev = rs.getTimestamp("reviewed_at");
        if (rev != null) m.setReviewedAt(rev.toLocalDateTime());

        Timestamp cre = rs.getTimestamp("created_at");
        if (cre != null) m.setCreatedAt(cre.toLocalDateTime());

        try {
            m.setProjectTitle(rs.getString("project_title"));
        } catch (SQLException ignored) {}

        m.setPitaStage(rs.getString("pita_stage"));

        return m;
    }

    // ── Read ──────────────────────────────────────────────────────────────────

    public Milestone findById(int id) throws SQLException {
        String sql =
                "SELECT m.*, p.title AS project_title " +
                "FROM milestones m " +
                "JOIN projects p ON p.id = m.project_id " +
                "WHERE m.id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public List<Milestone> findByProject(int projectId) throws SQLException {
        String sql =
                "SELECT m.*, p.title AS project_title " +
                "FROM milestones m " +
                "JOIN projects p ON p.id = m.project_id " +
                "WHERE m.project_id = ? " +
                "ORDER BY m.milestone_no";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, projectId);

            try (ResultSet rs = ps.executeQuery()) {
                List<Milestone> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    public Milestone findByProjectAndNo(int projectId, int milestoneNo) throws SQLException {
        String sql =
                "SELECT m.*, p.title AS project_title " +
                "FROM milestones m " +
                "JOIN projects p ON p.id = m.project_id " +
                "WHERE m.project_id = ? AND m.milestone_no = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            ps.setInt(2, milestoneNo);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public List<Milestone> findPendingBySupervisor(int supervisorId) throws SQLException {
        String sql =
                "SELECT m.*, p.title AS project_title " +
                "FROM milestones m " +
                "JOIN projects p ON p.id = m.project_id " +
                "WHERE p.supervisor_id = ? AND m.status = 'SUBMITTED' " +
                "ORDER BY m.submitted_at ASC";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, supervisorId);

            try (ResultSet rs = ps.executeQuery()) {
                List<Milestone> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    public List<Milestone> findAllPending() throws SQLException {
        String sql =
                "SELECT m.*, p.title AS project_title " +
                "FROM milestones m " +
                "JOIN projects p ON p.id = m.project_id " +
                "WHERE m.status = 'SUBMITTED' " +
                "ORDER BY m.submitted_at ASC";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Milestone> list = new ArrayList<>();
            while (rs.next()) {
                list.add(map(rs));
            }
            return list;
        }
    }

    // ── Create ────────────────────────────────────────────────────────────────

    public void insert(Milestone m) throws SQLException {
        String sql =
                "INSERT INTO milestones " +
                "(project_id, milestone_no, title, description, due_date, weight, pita_stage) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, m.getProjectId());
            ps.setInt(2, m.getMilestoneNo());
            ps.setString(3, m.getTitle());
            ps.setString(4, m.getDescription());
            ps.setDate(5, m.getDueDate() != null ? Date.valueOf(m.getDueDate()) : null);
            ps.setDouble(6, m.getWeight());
            ps.setString(7, m.getPitaStage());

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) m.setId(keys.getInt(1));
            }
        }
    }

    // ── Student actions ───────────────────────────────────────────────────────

    public void submit(int milestoneId, String submissionNote) throws SQLException {
        String sql =
                "UPDATE milestones " +
                "SET status = 'SUBMITTED', submission_note = ?, submitted_at = NOW() " +
                "WHERE id = ? AND status IN ('NOT_STARTED','IN_PROGRESS','REJECTED')";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, submissionNote);
            ps.setInt(2, milestoneId);
            ps.executeUpdate();
        }
    }

    public void markInProgress(int milestoneId) throws SQLException {
        String sql =
                "UPDATE milestones SET status = 'IN_PROGRESS' " +
                "WHERE id = ? AND status = 'NOT_STARTED'";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, milestoneId);
            ps.executeUpdate();
        }
    }

    // ── Supervisor actions ────────────────────────────────────────────────────

    public void approve(int milestoneId, double grade, String supervisorNote) throws SQLException {
        String sql =
                "UPDATE milestones " +
                "SET status = 'APPROVED', grade = ?, supervisor_note = ?, reviewed_at = NOW() " +
                "WHERE id = ? AND status = 'SUBMITTED'";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setDouble(1, grade);
            ps.setString(2, supervisorNote);
            ps.setInt(3, milestoneId);
            ps.executeUpdate();
        }
    }

    public void reject(int milestoneId, String supervisorNote) throws SQLException {
        String sql =
                "UPDATE milestones " +
                "SET status = 'REJECTED', supervisor_note = ?, reviewed_at = NOW() " +
                "WHERE id = ? AND status = 'SUBMITTED'";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, supervisorNote);
            ps.setInt(2, milestoneId);
            ps.executeUpdate();
        }
    }

    // ── Update ────────────────────────────────────────────────────────────────

    public void updateDetails(Milestone m) throws SQLException {
        String sql =
                "UPDATE milestones SET title = ?, description = ?, due_date = ?, weight = ?, pita_stage = ? " +
                "WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, m.getTitle());
            ps.setString(2, m.getDescription());
            ps.setDate(3, m.getDueDate() != null ? Date.valueOf(m.getDueDate()) : null);
            ps.setDouble(4, m.getWeight());
            ps.setString(5, m.getPitaStage());
            ps.setInt(6, m.getId());
            ps.executeUpdate();
        }
    }

    // ── Stats ─────────────────────────────────────────────────────────────────

    /**
     * Calculates the overall grade for a project using weight normalization.
     *
     * <p>Weights of approved milestones are summed and used as a divisor,
     * so the result is always correctly scaled to 0–100 regardless of whether
     * the coordinator-configured weights happen to sum to exactly 100%.
     *
     * <p>Formula: {@code SUM(grade * weight) / SUM(weight)}
     *
     * @param projectId the project to calculate the grade for
     * @return normalized overall grade in the range 0–100, or 0.0 if no approved milestones
     */
    public double calculateOverallGrade(int projectId) throws SQLException {
        // Normalize overall grade based on sum of weights of approved milestones.
        // If weights sum to 80% or 110%, they are mapped proportionally to a scale of 100.
        String sql =
                "SELECT SUM((grade * weight) / 100.0) / SUM(weight) * 100.0 AS normalized_grade " +
                "FROM milestones " +
                "WHERE project_id = ? AND status = 'APPROVED'";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, projectId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double val = rs.getDouble("normalized_grade");
                    return rs.wasNull() ? 0.0 : val;
                }
                return 0.0;
            }
        }
    }

    public long countPendingBySupervisor(int supervisorId) throws SQLException {
        String sql =
                "SELECT COUNT(*) FROM milestones m " +
                "JOIN projects p ON p.id = m.project_id " +
                "WHERE p.supervisor_id = ? AND m.status = 'SUBMITTED'";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, supervisorId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong(1) : 0;
            }
        }
    }

    // ── Delete ────────────────────────────────────────────────────────────────

    public void delete(int milestoneId) throws SQLException {
        String sql = "DELETE FROM milestones WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, milestoneId);
            ps.executeUpdate();
        }
    }
}
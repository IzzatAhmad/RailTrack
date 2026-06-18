package com.railtrack.system.dao;

import com.railtrack.system.model.PitaAssignment;
import com.railtrack.system.model.User;
import com.railtrack.system.util.DBConnection;
import com.railtrack.system.util.PasswordUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    // ── Mapping ───────────────────────────────────────────────────────────────

    private User map(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setDepartment(rs.getString("department"));
        double cgpaVal = rs.getDouble("cgpa");
        if (!rs.wasNull()) {
            u.setCgpa(cgpaVal);
        } else {
            u.setCgpa(null);
        }
        int supIdVal = rs.getInt("supervisor_id");
        u.setSupervisorId(rs.wasNull() ? null : supIdVal);
        try {
            u.setSupervisorName(rs.getString("supervisor_name"));
        } catch (SQLException ignored) {}
        u.setRole(User.Role.valueOf(rs.getString("role")));
        u.setActive(rs.getBoolean("active"));

        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) {
            u.setCreatedAt(created.toLocalDateTime());
        }

        Timestamp login = rs.getTimestamp("last_login");
        if (login != null) {
            u.setLastLogin(login.toLocalDateTime());
        }

        u.setEmailNotifEnabled(rs.getBoolean("email_notif_enabled"));

        return u;
    }

    // ── Auth ──────────────────────────────────────────────────────────────────

    public User authenticate(String username, String rawPassword) throws SQLException {
        String sql = "SELECT * FROM users WHERE username = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                User u = map(rs);

                if (!PasswordUtil.verify(rawPassword, u.getPasswordHash())) {
                    return null;
                }

                updateLastLogin(u.getId());
                updateActiveTurn(u.getId(), 1); // mark user as active/online on login
                return u;
            }
        }
    }

    public void updateLastLogin(int userId) throws SQLException {
        String sql = "UPDATE users SET last_login = NOW() WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    public void updateActiveTurn(int userId, int turnValue) throws SQLException {
        String sql = "UPDATE users SET active = ? WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, turnValue);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    // ── Read ──────────────────────────────────────────────────────────────────

    public User findById(int id) throws SQLException {
        String sql = "SELECT u.*, sv.full_name AS supervisor_name " +
                     "FROM users u " +
                     "LEFT JOIN users sv ON u.supervisor_id = sv.id " +
                     "WHERE u.id = ?";
 
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
 
            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public User findByUsername(String username) throws SQLException {
        String sql = "SELECT u.*, sv.full_name AS supervisor_name " +
                     "FROM users u " +
                     "LEFT JOIN users sv ON u.supervisor_id = sv.id " +
                     "WHERE u.username = ?";
 
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
 
            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT u.*, sv.full_name AS supervisor_name " +
                     "FROM users u " +
                     "LEFT JOIN users sv ON u.supervisor_id = sv.id " +
                     "WHERE u.email = ?";
 
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
 
            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public List<User> findAll() throws SQLException {
        String sql = "SELECT u.*, sv.full_name AS supervisor_name " +
                     "FROM users u " +
                     "LEFT JOIN users sv ON u.supervisor_id = sv.id " +
                     "ORDER BY u.role, u.full_name";
 
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<User> list = new ArrayList<>();
            while (rs.next()) {
                list.add(map(rs));
            }
            return list;
        }
    }

    public List<User> findByRole(User.Role role) throws SQLException {
        String sql = "SELECT u.*, sv.full_name AS supervisor_name " +
                     "FROM users u " +
                     "LEFT JOIN users sv ON u.supervisor_id = sv.id " +
                     "WHERE u.role = ? " +
                     "ORDER BY u.full_name";
 
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
 
            ps.setString(1, role.name());

            try (ResultSet rs = ps.executeQuery()) {
                List<User> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    public List<User> findAllSupervisors() throws SQLException {
        return findByRole(User.Role.SUPERVISOR);
    }

    public List<User> findAllStudents() throws SQLException {
        return findByRole(User.Role.STUDENT);
    }

    // ── Create ────────────────────────────────────────────────────────────────

    public void insert(User u) throws SQLException {
        if (u.getRole() == User.Role.COORDINATOR && u.getSupervisorId() != null) {
            throw new IllegalArgumentException("A coordinator cannot be assigned to a supervisor.");
        }
        if (u.getSupervisorId() != null && u.getSupervisorId() > 0) {
            User supervisor = findById(u.getSupervisorId());
            if (supervisor != null && supervisor.getRole() == User.Role.COORDINATOR) {
                throw new IllegalArgumentException("A coordinator cannot be assigned as a supervisor.");
            }
        }
        String sql =
                "INSERT INTO users " +
                "(username, password_hash, full_name, email, phone, department, cgpa, role, active, supervisor_id, " +
                "email_notif_enabled) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, u.getUsername());
            ps.setString(2, u.getPasswordHash());
            ps.setString(3, u.getFullName());
            ps.setString(4, u.getEmail());
            ps.setString(5, u.getPhone());
            ps.setString(6, u.getDepartment());
            if (u.getCgpa() != null) {
                ps.setDouble(7, u.getCgpa());
            } else {
                ps.setNull(7, java.sql.Types.DECIMAL);
            }
            ps.setString(8, u.getRole().name());
            ps.setBoolean(9, u.isActive());
            if (u.getSupervisorId() != null && u.getSupervisorId() > 0) {
                ps.setInt(10, u.getSupervisorId());
            } else {
                ps.setNull(10, java.sql.Types.INTEGER);
            }
            ps.setBoolean(11, u.isEmailNotifEnabled());

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    u.setId(keys.getInt(1));
                }
            }
        }
    }

    // ── Update ────────────────────────────────────────────────────────────────

    public void update(User u) throws SQLException {
        String sql =
                "UPDATE users SET full_name = ?, email = ?, phone = ?, department = ?, " +
                "email_notif_enabled = ? " +
                "WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPhone());
            ps.setString(4, u.getDepartment());
            ps.setBoolean(5, u.isEmailNotifEnabled());
            ps.setInt(6, u.getId());

            ps.executeUpdate();
        }
    }

    public void updatePassword(int userId, String newHash) throws SQLException {
        String sql = "UPDATE users SET password_hash = ? WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, newHash);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    // ── Delete / Deactivate ───────────────────────────────────────────────────

    public void deactivate(int userId) throws SQLException {
        String sql = "UPDATE users SET active = 0 WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    public void deactivateMultiple(List<Integer> ids) throws SQLException {
        if (ids == null || ids.isEmpty()) return;
        StringBuilder sb = new StringBuilder("UPDATE users SET active = 0 WHERE id IN (");
        for (int i = 0; i < ids.size(); i++) {
            sb.append(i == 0 ? "?" : ",?");
        }
        sb.append(")");
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sb.toString())) {
            for (int i = 0; i < ids.size(); i++) {
                ps.setInt(i + 1, ids.get(i));
            }
            ps.executeUpdate();
        }
    }

    public void delete(int userId) throws SQLException {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    public void deleteMultiple(List<Integer> ids) throws SQLException {
        if (ids == null || ids.isEmpty()) return;
        StringBuilder sb = new StringBuilder("DELETE FROM users WHERE id IN (");
        for (int i = 0; i < ids.size(); i++) {
            sb.append(i == 0 ? "?" : ",?");
        }
        sb.append(")");
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sb.toString())) {
            for (int i = 0; i < ids.size(); i++) {
                ps.setInt(i + 1, ids.get(i));
            }
            ps.executeUpdate();
        }
    }

    // ── Existence checks ──────────────────────────────────────────────────────

    public boolean usernameExists(String username) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE username = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ── Project Evaluators ───────────────────────────────────────────────────

    public List<User> findEvaluatorsByProjectAndStage(int projectId, String stage) throws SQLException {
        String sql = "SELECT u.* FROM users u " +
                     "JOIN project_evaluators pe ON u.id = pe.evaluator_id " +
                     "WHERE pe.project_id = ? AND pe.stage = ? " +
                     "ORDER BY u.full_name";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            ps.setString(2, stage);
            try (ResultSet rs = ps.executeQuery()) {
                List<User> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    public int countEvaluatorsByProjectAndStage(int projectId, String stage) throws SQLException {
        String sql = "SELECT COUNT(*) FROM project_evaluators WHERE project_id = ? AND stage = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            ps.setString(2, stage);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public void addEvaluator(int projectId, int evaluatorId, String stage) throws SQLException {
        int count = countEvaluatorsByProjectAndStage(projectId, stage);
        if (count >= 3) {
            throw new IllegalArgumentException("Maximum of 3 supervisors can be assigned for " + stage + " evaluation.");
        }
        String sql = "INSERT INTO project_evaluators (project_id, evaluator_id, stage) VALUES (?, ?, ?)";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            ps.setInt(2, evaluatorId);
            ps.setString(3, stage);
            ps.executeUpdate();
        }
    }

    public void removeEvaluator(int projectId, int evaluatorId, String stage) throws SQLException {
        String sql = "DELETE FROM project_evaluators WHERE project_id = ? AND evaluator_id = ? AND stage = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            ps.setInt(2, evaluatorId);
            ps.setString(3, stage);
            ps.executeUpdate();
        }
    }

    public void updateSupervisor(int studentId, Integer supervisorId) throws SQLException {
        User student = findById(studentId);
        if (student != null && student.getRole() == User.Role.COORDINATOR) {
            throw new IllegalArgumentException("A coordinator cannot be assigned to a supervisor.");
        }
        if (supervisorId != null && supervisorId > 0) {
            User supervisor = findById(supervisorId);
            if (supervisor != null && supervisor.getRole() == User.Role.COORDINATOR) {
                throw new IllegalArgumentException("A coordinator cannot be assigned as a supervisor.");
            }
        }
        String sql = "UPDATE users SET supervisor_id = ? WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            if (supervisorId != null && supervisorId > 0) {
                ps.setInt(1, supervisorId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setInt(2, studentId);
            ps.executeUpdate();
        }
    }

    // ── PITA Evaluations ─────────────────────────────────────────────────────

    public List<PitaAssignment> findAllPitaAssignments() throws SQLException {
        String sql = "SELECT pe.*, p.title AS project_title, u.full_name AS student_name " +
                     "FROM project_evaluators pe " +
                     "JOIN projects p ON p.id = pe.project_id " +
                     "JOIN users u ON u.id = p.student_id " +
                     "ORDER BY pe.stage, p.title";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<PitaAssignment> list = new ArrayList<>();
            while (rs.next()) {
                PitaAssignment pa = new PitaAssignment();
                pa.setId(rs.getInt("id"));
                pa.setProjectId(rs.getInt("project_id"));
                pa.setProjectTitle(rs.getString("project_title"));
                pa.setStudentName(rs.getString("student_name"));
                pa.setEvaluatorId(rs.getInt("evaluator_id"));
                pa.setStage(rs.getString("stage"));
                double grade = rs.getDouble("grade");
                pa.setGrade(rs.wasNull() ? null : grade);
                pa.setFeedback(rs.getString("feedback"));
                Timestamp evaluated = rs.getTimestamp("evaluated_at");
                if (evaluated != null) {
                    pa.setEvaluatedAt(evaluated.toLocalDateTime());
                }
                list.add(pa);
            }
            return list;
        }
    }

    public List<PitaAssignment> findPitaAssignmentsBySupervisor(int supervisorId) throws SQLException {
        String sql = "SELECT pe.*, p.title AS project_title, u.full_name AS student_name " +
                     "FROM project_evaluators pe " +
                     "JOIN projects p ON p.id = pe.project_id " +
                     "JOIN users u ON u.id = p.student_id " +
                     "WHERE pe.evaluator_id = ? " +
                     "ORDER BY pe.stage, p.title";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, supervisorId);
            try (ResultSet rs = ps.executeQuery()) {
                List<PitaAssignment> list = new ArrayList<>();
                while (rs.next()) {
                    PitaAssignment pa = new PitaAssignment();
                    pa.setId(rs.getInt("id"));
                    pa.setProjectId(rs.getInt("project_id"));
                    pa.setProjectTitle(rs.getString("project_title"));
                    pa.setStudentName(rs.getString("student_name"));
                    pa.setEvaluatorId(rs.getInt("evaluator_id"));
                    pa.setStage(rs.getString("stage"));
                    double grade = rs.getDouble("grade");
                    pa.setGrade(rs.wasNull() ? null : grade);
                    pa.setFeedback(rs.getString("feedback"));
                    Timestamp evaluated = rs.getTimestamp("evaluated_at");
                    if (evaluated != null) {
                        pa.setEvaluatedAt(evaluated.toLocalDateTime());
                    }
                    list.add(pa);
                }
                return list;
            }
        }
    }

    public PitaAssignment findPitaAssignment(int projectId, int evaluatorId, String stage) throws SQLException {
        String sql = "SELECT pe.*, p.title AS project_title, u.full_name AS student_name " +
                     "FROM project_evaluators pe " +
                     "JOIN projects p ON p.id = pe.project_id " +
                     "JOIN users u ON u.id = p.student_id " +
                     "WHERE pe.project_id = ? AND pe.evaluator_id = ? AND pe.stage = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            ps.setInt(2, evaluatorId);
            ps.setString(3, stage);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PitaAssignment pa = new PitaAssignment();
                    pa.setId(rs.getInt("id"));
                    pa.setProjectId(rs.getInt("project_id"));
                    pa.setProjectTitle(rs.getString("project_title"));
                    pa.setStudentName(rs.getString("student_name"));
                    pa.setEvaluatorId(rs.getInt("evaluator_id"));
                    pa.setStage(rs.getString("stage"));
                    double grade = rs.getDouble("grade");
                    pa.setGrade(rs.wasNull() ? null : grade);
                    pa.setFeedback(rs.getString("feedback"));
                    Timestamp evaluated = rs.getTimestamp("evaluated_at");
                    if (evaluated != null) {
                        pa.setEvaluatedAt(evaluated.toLocalDateTime());
                    }
                    return pa;
                }
            }
        }
        return null;
    }

    public void submitPitaEvaluation(int projectId, int evaluatorId, String stage, Double grade, String feedback) throws SQLException {
        String sql = "UPDATE project_evaluators " +
                     "SET grade = ?, feedback = ?, evaluated_at = NOW() " +
                     "WHERE project_id = ? AND evaluator_id = ? AND stage = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            if (grade != null) {
                ps.setDouble(1, grade);
            } else {
                ps.setNull(1, java.sql.Types.DECIMAL);
            }
            ps.setString(2, feedback);
            ps.setInt(3, projectId);
            ps.setInt(4, evaluatorId);
            ps.setString(5, stage);
            ps.executeUpdate();
        }
    }

    public List<PitaAssignment> findPitaAssignmentsByProject(int projectId) throws SQLException {
        String sql = "SELECT pe.*, p.title AS project_title, u.full_name AS student_name, ev.full_name AS evaluator_name " +
                     "FROM project_evaluators pe " +
                     "JOIN projects p ON p.id = pe.project_id " +
                     "JOIN users u ON u.id = p.student_id " +
                     "JOIN users ev ON ev.id = pe.evaluator_id " +
                     "WHERE pe.project_id = ? " +
                     "ORDER BY pe.stage, ev.full_name";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                List<PitaAssignment> list = new ArrayList<>();
                while (rs.next()) {
                    PitaAssignment pa = new PitaAssignment();
                    pa.setId(rs.getInt("id"));
                    pa.setProjectId(rs.getInt("project_id"));
                    pa.setProjectTitle(rs.getString("project_title"));
                    pa.setStudentName(rs.getString("student_name"));
                    pa.setEvaluatorId(rs.getInt("evaluator_id"));
                    pa.setEvaluatorName(rs.getString("evaluator_name"));
                    pa.setStage(rs.getString("stage"));
                    double grade = rs.getDouble("grade");
                    pa.setGrade(rs.wasNull() ? null : grade);
                    pa.setFeedback(rs.getString("feedback"));
                    Timestamp evaluated = rs.getTimestamp("evaluated_at");
                    if (evaluated != null) {
                        pa.setEvaluatedAt(evaluated.toLocalDateTime());
                    }
                    list.add(pa);
                }
                return list;
            }
        }
    }

    public List<User> findStudentsBySupervisor(int supervisorId) throws SQLException {
        String sql = "SELECT u.*, sv.full_name AS supervisor_name " +
                     "FROM users u " +
                     "LEFT JOIN users sv ON u.supervisor_id = sv.id " +
                     "WHERE u.role = 'STUDENT' AND u.supervisor_id = ? " +
                     "ORDER BY u.full_name";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, supervisorId);
            try (ResultSet rs = ps.executeQuery()) {
                List<User> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }
}
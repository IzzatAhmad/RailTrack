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
        try {
            u.setBanned(rs.getBoolean("is_banned"));
        } catch (SQLException ignored) {}

        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) {
            u.setCreatedAt(created.toLocalDateTime());
        }

        Timestamp login = rs.getTimestamp("last_login");
        if (login != null) {
            u.setLastLogin(login.toLocalDateTime());
        }

        // last_activity may not exist yet if migration hasn't been run
        try {
            Timestamp activity = rs.getTimestamp("last_activity");
            if (activity != null) {
                u.setLastActivity(activity.toLocalDateTime());
            }
        } catch (SQLException ignored) {}

        u.setEmailNotifEnabled(rs.getBoolean("email_notif_enabled"));
        try {
            u.setSemester(rs.getString("semester"));
        } catch (SQLException ignored) {}

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

                if (u.isBanned()) {
                    String sup = u.getSupervisorName();
                    if (sup != null && !sup.trim().isEmpty()) {
                        throw new IllegalArgumentException("Account suspended. Please contact supervisor (" + sup.trim() + ") or coordinator.");
                    } else {
                        throw new IllegalArgumentException("Account suspended. Please contact a coordinator.");
                    }
                }

                updateLastLogin(u.getId());
                updateLastActivity(u.getId()); // heartbeat-based online tracking
                
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

    /**
     * Updates last_activity to NOW() for the given user.
     * Called on login and by HeartbeatServlet every 2 minutes.
     * Silently ignored if the column hasn't been migrated yet.
     */
    public void updateLastActivity(int userId) {
        String sql = "UPDATE users SET last_activity = NOW() WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            String msg = e.getMessage() != null ? e.getMessage().toLowerCase() : "";
            if (msg.contains("unknown column") || msg.contains("doesn't exist") || e.getErrorCode() == 1054) {
                ensureLastActivityColumn();
                try (Connection c = DBConnection.get();
                     PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                } catch (SQLException ignored) {}
            }
        }
    }

    private void ensureLastActivityColumn() {
        try (Connection c = DBConnection.get();
             Statement s = c.createStatement()) {
            boolean hasCol = false;
            try (ResultSet rs = c.getMetaData().getColumns(null, null, "users", "last_activity")) {
                hasCol = rs.next();
            }
            if (!hasCol) {
                s.execute("ALTER TABLE users ADD COLUMN last_activity DATETIME NULL");
                System.out.println("[UserDAO] Auto-migrated: last_activity column added.");
            }
        } catch (SQLException ex) {
            System.err.println("[UserDAO] Auto-migration failed for last_activity: " + ex.getMessage());
        }
    }

    /**
     * Returns true if the user's last_activity is within the last 5 minutes.
     */
    public boolean isUserOnline(int userId) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE id = ? AND last_activity > NOW() - INTERVAL 5 MINUTE";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
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
                "email_notif_enabled, semester) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

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
            ps.setString(12, u.getSemester());

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
                "email_notif_enabled = ?, semester = ? " +
                "WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPhone());
            ps.setString(4, u.getDepartment());
            ps.setBoolean(5, u.isEmailNotifEnabled());
            ps.setString(6, u.getSemester());
            ps.setInt(7, u.getId());

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

    public void banUser(int userId, boolean isBanned) throws SQLException {
        String sql = "UPDATE users SET is_banned = ? WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, isBanned ? 1 : 0);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    public void updateRole(int userId, User.Role role) throws SQLException {
        String sql = "UPDATE users SET role = ? WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, role.name());
            ps.setInt(2, userId);
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

    /**
     * Persists a password-reset token (UUID) and its expiry on the user record.
     * <p>
     * Auto-migrates the required columns ({@code password_reset_token}, {@code reset_token_expiry})
     * the first time they are needed, so no manual migration step is required.
     */
    public void savePasswordResetToken(int userId, String token, java.time.LocalDateTime expiry)
            throws SQLException {
        String sql = "UPDATE users SET password_reset_token = ?, reset_token_expiry = ? WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setTimestamp(2, java.sql.Timestamp.valueOf(expiry));
            ps.setInt(3, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            // If the columns don't exist yet, add them and retry once
            String msg = e.getMessage() != null ? e.getMessage().toLowerCase() : "";
            if (msg.contains("unknown column") || msg.contains("doesn't exist") || e.getErrorCode() == 1054) {
                ensureResetTokenColumns();
                // Retry after migration
                try (Connection c = DBConnection.get();
                     PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setString(1, token);
                    ps.setTimestamp(2, java.sql.Timestamp.valueOf(expiry));
                    ps.setInt(3, userId);
                    ps.executeUpdate();
                }
            } else {
                throw e; // Unrelated error — rethrow
            }
        }
    }

    /**
     * Ensures the password reset token columns exist on the users table.
     * Called automatically by savePasswordResetToken on first use.
     */
    private void ensureResetTokenColumns() {
        try (Connection c = DBConnection.get();
             Statement s = c.createStatement()) {
            // Check if columns exist before altering to avoid duplicate-column errors
            boolean hasToken  = false;
            boolean hasExpiry = false;
            try (ResultSet rs = c.getMetaData().getColumns(null, null, "users", "password_reset_token")) {
                hasToken = rs.next();
            }
            try (ResultSet rs = c.getMetaData().getColumns(null, null, "users", "reset_token_expiry")) {
                hasExpiry = rs.next();
            }
            if (!hasToken) {
                s.execute("ALTER TABLE users ADD COLUMN password_reset_token VARCHAR(64) NULL");
            }
            if (!hasExpiry) {
                s.execute("ALTER TABLE users ADD COLUMN reset_token_expiry DATETIME NULL");
            }
            System.out.println("[UserDAO] Auto-migrated: password_reset_token / reset_token_expiry columns added.");
        } catch (SQLException ex) {
            System.err.println("[UserDAO] Auto-migration failed for reset token columns: " + ex.getMessage());
            ex.printStackTrace();
        }
    }

    /**
     * Finds a user by a valid, non-expired reset token.
     * Returns null if the token is not found or has expired.
     */
    public User findByValidResetToken(String token) throws SQLException {
        String sql = "SELECT u.*, sv.full_name AS supervisor_name " +
                     "FROM users u " +
                     "LEFT JOIN users sv ON u.supervisor_id = sv.id " +
                     "WHERE u.password_reset_token = ? AND u.reset_token_expiry > NOW()";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    /**
     * Clears the reset token after a successful password reset.
     */
    public void clearResetToken(int userId) throws SQLException {
        String sql = "UPDATE users SET password_reset_token = NULL, reset_token_expiry = NULL WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
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
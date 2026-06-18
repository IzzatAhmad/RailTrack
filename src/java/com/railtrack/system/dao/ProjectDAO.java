package com.railtrack.system.dao;

import com.railtrack.system.model.Project;
import com.railtrack.system.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProjectDAO {

    // ── Mapping ───────────────────────────────────────────────────────────────

    private Project map(ResultSet rs) throws SQLException {
        Project p = new Project();
        p.setId(rs.getInt("id"));
        p.setTitle(rs.getString("title"));
        p.setDescription(rs.getString("description"));
        p.setStudentId(rs.getInt("student_id"));
        p.setStudentName(rs.getString("student_name"));
        try { p.setStudentUsername(rs.getString("student_username")); } catch (SQLException ignored) {}
        try { p.setStudentDepartment(rs.getString("student_department")); } catch (SQLException ignored) {}

        double stdCgpa = rs.getDouble("student_cgpa");
        p.setStudentCgpa(rs.wasNull() ? null : stdCgpa);

        int supId = rs.getInt("supervisor_id");
        p.setSupervisorId(rs.wasNull() ? 0 : supId);
        p.setSupervisorName(rs.getString("supervisor_name"));

        p.setRepoUrl(rs.getString("repo_url"));
        p.setBranch(rs.getString("branch"));
        p.setImageTag(rs.getString("image_tag"));
        p.setDockerStatus(rs.getString("docker_status"));
        p.setContainerPort(rs.getInt("container_port"));
        p.setContainerId(rs.getString("container_id"));
        p.setBuildLog(rs.getString("build_log"));
        p.setErrorMessage(rs.getString("error_message"));
        p.setSemester(rs.getString("semester"));
        p.setStatus(Project.Status.valueOf(rs.getString("status")));
        p.setCurrentMilestoneNo(rs.getInt("current_milestone_no"));
        p.setRunningLimitSeconds(rs.getInt("running_limit_seconds"));

        double grade = rs.getDouble("overall_grade");
        p.setOverallGrade(rs.wasNull() ? null : grade);

        double obsMark = rs.getDouble("observation_mark");
        p.setObservationMark(rs.wasNull() ? 0.0 : obsMark);

        double contMark = rs.getDouble("continuous_mark");
        p.setContinuousMark(rs.wasNull() ? 0.0 : contMark);

        try { p.setChapterProgress(rs.getString("chapter_progress")); } catch (SQLException ignored) {}

        Timestamp sub = rs.getTimestamp("submitted_at");
        if (sub != null) p.setSubmittedAt(sub.toLocalDateTime());

        Timestamp upd = rs.getTimestamp("updated_at");
        if (upd != null) p.setUpdatedAt(upd.toLocalDateTime());

        return p;
    }

    // ── Base SELECT ───────────────────────────────────────────────────────────

    private static final String BASE_SELECT =
            "SELECT p.*, " +
            "s.full_name   AS student_name, " +
            "s.username    AS student_username, " +
            "s.department  AS student_department, " +
            "s.cgpa        AS student_cgpa, " +
            "sv.full_name  AS supervisor_name " +
            "FROM projects p " +
            "JOIN users s ON s.id = p.student_id " +
            "LEFT JOIN users sv ON sv.id = p.supervisor_id ";

    // ── Read ──────────────────────────────────────────────────────────────────

    public Project findById(int id) throws SQLException {
        String sql = BASE_SELECT + " WHERE p.id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public List<Project> findAll() throws SQLException {
        String sql = BASE_SELECT + " ORDER BY p.submitted_at DESC";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Project> list = new ArrayList<>();
            while (rs.next()) {
                list.add(map(rs));
            }
            return list;
        }
    }

    public List<Project> findByStudent(int studentId) throws SQLException {
        String sql = BASE_SELECT + " WHERE p.student_id = ? ORDER BY p.submitted_at DESC";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                List<Project> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    public List<Project> findBySupervisor(int supervisorId) throws SQLException {
        String sql = BASE_SELECT + " WHERE p.supervisor_id = ? ORDER BY p.submitted_at DESC";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, supervisorId);

            try (ResultSet rs = ps.executeQuery()) {
                List<Project> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    public List<Project> findByStatus(Project.Status status) throws SQLException {
        String sql = BASE_SELECT + " WHERE p.status = ? ORDER BY p.submitted_at DESC";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, status.name());

            try (ResultSet rs = ps.executeQuery()) {
                List<Project> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    public List<Project> findBySemester(String semester) throws SQLException {
        String sql = BASE_SELECT + " WHERE p.semester = ? ORDER BY p.title";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, semester);

            try (ResultSet rs = ps.executeQuery()) {
                List<Project> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    /**
     * Returns projects for a given semester ordered by supervisor name then student name,
     * suitable for the supervisor-grouped student list report.
     */
    public List<Project> findBySemesterOrderedBySupervisor(String semester) throws SQLException {
        String sql = BASE_SELECT +
                     " WHERE p.semester = ? " +
                     " ORDER BY sv.full_name, s.full_name";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, semester);

            try (ResultSet rs = ps.executeQuery()) {
                List<Project> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }

    /**
     * Returns distinct semester values that have at least one project, sorted descending.
     */
    public List<String> findDistinctSemesters() throws SQLException {
        String sql = "SELECT DISTINCT semester FROM projects " +
                     "WHERE semester IS NOT NULL AND semester <> '' " +
                     "ORDER BY semester DESC";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<String> list = new ArrayList<>();
            while (rs.next()) {
                list.add(rs.getString("semester"));
            }
            return list;
        }
    }

    /**
     * Returns ALL students (grouped by supervisor) with their project for the given semester.
     * Students who have no project for that semester are included with id=0 and null title.
     * Uses LEFT JOIN from users → projects so no student is omitted.
     */
    public List<Project> findAllStudentsWithProjectBySemester(String semester) throws SQLException {
        String sql =
            "SELECT " +
            "  u.id          AS student_id, " +
            "  u.full_name   AS student_name, " +
            "  u.username    AS student_username, " +
            "  u.department  AS student_department, " +
            "  u.cgpa        AS student_cgpa, " +
            "  sv.full_name  AS supervisor_name, " +
            "  COALESCE(sv.id, 0)     AS supervisor_id, " +
            "  COALESCE(p.id, 0)      AS id, " +
            "  p.title, " +
            "  p.description, " +
            "  p.semester, " +
            "  COALESCE(p.status, 'PENDING')         AS status, " +
            "  COALESCE(p.repo_url, '')               AS repo_url, " +
            "  COALESCE(p.branch, 'main')             AS branch, " +
            "  p.image_tag, " +
            "  COALESCE(p.docker_status, 'none')      AS docker_status, " +
            "  COALESCE(p.container_port, 0)          AS container_port, " +
            "  p.container_id, " +
            "  p.build_log, " +
            "  p.error_message, " +
            "  COALESCE(p.current_milestone_no, 1)    AS current_milestone_no, " +
            "  p.overall_grade, " +
            "  p.observation_mark, " +
            "  p.continuous_mark, " +
            "  p.submitted_at, " +
            "  p.updated_at, " +
            "  COALESCE(p.running_limit_seconds, 14400) AS running_limit_seconds " +
            "FROM users u " +
            "LEFT JOIN users sv ON u.supervisor_id = sv.id " +
            "LEFT JOIN projects p ON p.student_id = u.id AND p.semester = ? " +
            "WHERE u.role = 'STUDENT' " +
            "ORDER BY sv.full_name, u.full_name";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, semester);

            try (ResultSet rs = ps.executeQuery()) {
                List<Project> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(map(rs));
                }
                return list;
            }
        }
    }


    public List<Project> findUnassigned() throws SQLException {
        String sql = BASE_SELECT + " WHERE p.supervisor_id IS NULL ORDER BY p.submitted_at ASC";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Project> list = new ArrayList<>();
            while (rs.next()) {
                list.add(map(rs));
            }
            return list;
        }
    }

    // ── Stats ─────────────────────────────────────────────────────────────────

    public long countByStatus(Project.Status status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM projects WHERE status = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, status.name());

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong(1) : 0;
            }
        }
    }

    public long countBySupervisor(int supervisorId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM projects WHERE supervisor_id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, supervisorId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong(1) : 0;
            }
        }
    }

    // ── Create ────────────────────────────────────────────────────────────────

    public void insert(Project p) throws SQLException {
        String sql =
                "INSERT INTO projects " +
                "(title, description, student_id, supervisor_id, repo_url, branch, semester, status, running_limit_seconds) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, p.getTitle());
            ps.setString(2, p.getDescription());
            ps.setInt(3, p.getStudentId());
            if (p.getSupervisorId() > 0) {
                ps.setInt(4, p.getSupervisorId());
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            ps.setString(5, p.getRepoUrl());
            ps.setString(6, p.getBranch() != null ? p.getBranch() : "main");
            ps.setString(7, p.getSemester());
            ps.setString(8, p.getStatus().name());
            ps.setInt(9, p.getRunningLimitSeconds());

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    p.setId(keys.getInt(1));
                }
            }
        }
    }

    // ── Update ────────────────────────────────────────────────────────────────

    public void updateBasicInfo(Project p) throws SQLException {
        String sql =
                "UPDATE projects SET title = ?, description = ?, repo_url = ?, branch = ?, semester = ? " +
                "WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, p.getTitle());
            ps.setString(2, p.getDescription());
            ps.setString(3, p.getRepoUrl());
            ps.setString(4, p.getBranch());
            ps.setString(5, p.getSemester());
            ps.setInt(6, p.getId());

            ps.executeUpdate();
        }
    }

    public void updateStatus(int projectId, Project.Status status) throws SQLException {
        String sql = "UPDATE projects SET status = ? WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, status.name());
            ps.setInt(2, projectId);
            ps.executeUpdate();
        }
    }

    public void assignSupervisor(int projectId, int supervisorId) throws SQLException {
        String sql =
                "UPDATE projects SET supervisor_id = ?, " +
                "status = CASE WHEN status = 'PENDING' THEN 'ACTIVE' ELSE status END " +
                "WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, supervisorId);
            ps.setInt(2, projectId);
            ps.executeUpdate();
        }
    }

    public void updateDockerInfo(int projectId, String dockerStatus,
                                 String containerId, int port) throws SQLException {

        String sql =
                "UPDATE projects SET docker_status = ?, container_id = ?, container_port = ? " +
                "WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, dockerStatus);
            ps.setString(2, containerId);
            ps.setInt(3, port);
            ps.setInt(4, projectId);

            ps.executeUpdate();
        }
    }

    public void updateDockerStatus(int projectId, String dockerStatus) throws SQLException {
        String sql = "UPDATE projects SET docker_status = ? WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, dockerStatus);
            ps.setInt(2, projectId);
            ps.executeUpdate();
        }
    }

    public void updateBuildLog(int projectId, String buildLog, String errorMessage) throws SQLException {
        String sql = "UPDATE projects SET build_log = ?, error_message = ? WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, buildLog);
            ps.setString(2, errorMessage);
            ps.setInt(3, projectId);
            ps.executeUpdate();
        }
    }

    public void updateImageTag(int projectId, String imageTag) throws SQLException {
        String sql = "UPDATE projects SET image_tag = ? WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, imageTag);
            ps.setInt(2, projectId);
            ps.executeUpdate();
        }
    }

    public void updateRunningLimit(int projectId, int limitSeconds) throws SQLException {
        String sql = "UPDATE projects SET running_limit_seconds = ? WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, limitSeconds);
            ps.setInt(2, projectId);
            ps.executeUpdate();
        }
    }

    public void advanceMilestone(int projectId) throws SQLException {
        String sql =
                "UPDATE projects SET current_milestone_no = current_milestone_no + 1 WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            ps.executeUpdate();
        }
    }

    public void updateGrade(int projectId, double grade) throws SQLException {
        String sql = "UPDATE projects SET overall_grade = ? WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setDouble(1, grade);
            ps.setInt(2, projectId);
            ps.executeUpdate();
        }
    }

    public void updateMarks(int projectId, double observationMark, double continuousMark) throws SQLException {
        String sql = "UPDATE projects SET observation_mark = ?, continuous_mark = ? WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setDouble(1, observationMark);
            ps.setDouble(2, continuousMark);
            ps.setInt(3, projectId);
            ps.executeUpdate();
        }
    }

    public void updateChapterProgress(int projectId, String chapterProgress) throws SQLException {
        String sql = "UPDATE projects SET chapter_progress = ? WHERE id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, chapterProgress);
            ps.setInt(2, projectId);
            ps.executeUpdate();
        }
    }

    // ── Delete ────────────────────────────────────────────────────────────────

    public void delete(int projectId) throws SQLException {
        String sql = "DELETE FROM projects WHERE id = ?";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            ps.executeUpdate();
        }
    }

    public void updateSupervisorForStudent(int studentId, Integer supervisorId) throws SQLException {
        String sql = "UPDATE projects SET supervisor_id = ?, " +
                     "status = CASE WHEN status = 'PENDING' AND ? IS NOT NULL THEN 'ACTIVE' ELSE status END " +
                     "WHERE student_id = ?";
        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            if (supervisorId != null && supervisorId > 0) {
                ps.setInt(1, supervisorId);
                ps.setInt(2, supervisorId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setInt(3, studentId);
            ps.executeUpdate();
        }
    }
}
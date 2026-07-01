/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.service;

import com.railtrack.system.dao.DeploymentLogDAO;
import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.exception.DockerException;
import com.railtrack.system.model.DeploymentLog;
import com.railtrack.system.model.Project;
import com.railtrack.system.util.TerminalExecutor;
import com.railtrack.system.util.TerminalExecutor.Result;

import java.io.IOException;
import java.sql.SQLException;
import java.util.function.Consumer;
import com.railtrack.system.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 *
 * @author izzat
 */
public class DockerService {

    // Base directory for cloned repos. Override via env var RAILTRACK_WORK_DIR.
    private static final String WORK_DIR;

    static {
        String tmp = System.getenv("RAILTRACK_WORK_DIR");
        if (tmp == null) {
            // Force forward slashes for Docker/Git Bash compatibility
            tmp = System.getProperty("java.io.tmpdir")
                    .replace("\\", "/")
                    + "/railtrack";
        }
        WORK_DIR = tmp;
    }

    private final ProjectDAO projectDAO = new ProjectDAO();
    private final DeploymentLogDAO deploymentLogDAO = new DeploymentLogDAO();

    // ── Build ─────────────────────────────────────────────────────────────────
    /**
     * Clones the project repository and builds a Docker image.
     *
     * Steps: 1. Remove any stale container with the same name 2. Clone / pull
     * the repo 3. docker build → image tagged as rt-<projectId>
     * 4. Persist image tag and build log
     */
    public void buildProject(Project project, int performedById)
            throws DockerException, SQLException {

        int pid = project.getId();
        String imageTag = "rt-" + pid;
        String repoDir = (WORK_DIR + "/" + pid).replace("\\", "/"); // force forward slashes
        String branch = project.getBranch() != null ? project.getBranch() : "master";

        try {
            // 1. Remove stale container if it exists
            silentRemoveContainer(containerName(pid));

            // 2. Clone or pull
            String cloneCmd = buildCloneCommand(project.getRepoUrl(), branch, repoDir);
            Result cloneResult = TerminalExecutor.executeShell(cloneCmd);
            if (!cloneResult.success()) {
                throw new DockerException(pid, cloneCmd,
                        "Repository clone/pull failed:\n" + cloneResult.combined());
            }

            // 3. Build image (remove old image first to avoid cache issues)
            TerminalExecutor.executeShell("docker rmi -f " + imageTag);
            String buildCmd = "docker build -t " + imageTag + " \"" + repoDir + "\"";
            Result buildResult = TerminalExecutor.executeShell(buildCmd, 20); // use executeShell

            String fullLog = cloneResult.combined() + "\n\n--- BUILD ---\n" + buildResult.combined();

            if (!buildResult.success()) {
                projectDAO.updateBuildLog(pid, fullLog, "Build failed");
                projectDAO.updateDockerStatus(pid, "error");
                deploymentLogDAO.log(pid, performedById,
                        DeploymentLog.Action.BUILD, "failed", "Exit: " + buildResult.exitCode);
                throw new DockerException(pid, buildCmd,
                        "Docker build failed:\n" + buildResult.combined());
            }

            // 4. Persist
            projectDAO.updateImageTag(pid, imageTag);
            projectDAO.updateBuildLog(pid, fullLog, null);
            projectDAO.updateDockerStatus(pid, "built");
            deploymentLogDAO.log(pid, performedById,
                    DeploymentLog.Action.BUILD, "success", null);

        } catch (IOException | InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new DockerException(pid, "build",
                    "Unexpected error during build: " + e.getMessage(), e);
        }
    }

    // ── Start ─────────────────────────────────────────────────────────────────
    /**
     * Starts a container from the built image. Allocates a random free port in
     * the range 32000–33000. Resource limits: 1 CPU, 512 MB RAM, 120-minute
     * auto-stop.
     */
    public void startProject(Project project, int performedById)
            throws DockerException, SQLException {

        int pid = project.getId();
        String imageTag = project.getImageTag();
        String name = containerName(pid);

        // ✅ Java 8 safe check
        if (imageTag == null || imageTag.trim().isEmpty()) {
            throw new DockerException(pid, "start",
                    "No image found - please build the project first.");
        }

        try {
            // Ensure student database exists in the host database
            try (Connection conn = DBConnection.get();
                 PreparedStatement ps = conn.prepareStatement("CREATE DATABASE IF NOT EXISTS student_db_" + pid)) {
                ps.executeUpdate();
            }

            // Check for init.sql or railtrack.sql and execute it
            String repoDir = (WORK_DIR + "/" + pid).replace("\\", "/");
            java.io.File initSql = new java.io.File(repoDir, "init.sql");
            java.io.File railtrackSql = new java.io.File(repoDir, "railtrack.sql");
            java.io.File sqlToRun = initSql.exists() ? initSql : (railtrackSql.exists() ? railtrackSql : null);
            String dbPass = System.getenv().getOrDefault("DB_PASSWORD", "");
            String pFlag = dbPass.isEmpty() ? "" : "-p" + dbPass + " ";
            
            if (sqlToRun != null) {
                // Pipe the SQL file into a transient MySQL container to execute it against the host DB
                String sqlCmd = "cat \"" + sqlToRun.getAbsolutePath().replace("\\", "/") + "\" | docker run --rm -i mysql:8.0 mysql -h host.docker.internal -u root " + pFlag + "student_db_" + pid;
                Result sqlResult = TerminalExecutor.executeShell(sqlCmd);
                if (!sqlResult.success()) {
                    System.err.println("Warning: Failed to execute " + sqlToRun.getName() + " for project " + pid + "\n" + sqlResult.combined());
                }
            }

            // Remove any stopped container with the same name before starting a new one.
            // This avoids the "container name already in use" conflict error.
            silentRemoveContainer(name);

            String cmd = "docker run -d"
                    + " --name " + name
                    + " -p 8080"
                    + " --memory=512m"
                    + " --cpus=1.0"
                    + " --restart=no"
                    + " -e DB_HOST=host.docker.internal"
                    + " -e DB_PORT=3306"
                    + " -e DB_NAME=student_db_" + pid
                    + " -e DB_USER=root"
                    + " -e DB_PASSWORD=" + dbPass
                    + " " + imageTag;

            Result result = TerminalExecutor.execute(cmd);

            if (!result.success()) {
                projectDAO.updateDockerStatus(pid, "error");
                deploymentLogDAO.log(pid, performedById,
                        DeploymentLog.Action.START, "failed", result.stderr);

                throw new DockerException(pid, cmd,
                        "Container start failed:\n" + result.combined());
            }

            String containerId = result.stdout.trim();
            if (containerId.length() > 12) {
                containerId = containerId.substring(0, 12);
            }

            Result portResult = TerminalExecutor.execute("docker port " + name + " 8080");
            if (!portResult.success()) {
                throw new DockerException(pid, "port", "Failed to retrieve assigned port:\n" + portResult.combined());
            }
            
            // Output is like "0.0.0.0:32768" or multiple lines
            String portOutput = portResult.stdout.trim();
            String firstLine = portOutput.split("\n")[0].trim();
            int port = Integer.parseInt(firstLine.substring(firstLine.lastIndexOf(':') + 1));

            projectDAO.updateDockerInfo(pid, "running", containerId, port);
            deploymentLogDAO.log(pid, performedById,
                    DeploymentLog.Action.START, "success", "port=" + port);

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new DockerException(pid, "start",
                    "Process interrupted: " + e.getMessage(), e);

        } catch (IOException e) {
            throw new DockerException(pid, "start",
                    "IO error during start: " + e.getMessage(), e);
        }
    }

    // ── Stop ──────────────────────────────────────────────────────────────────
    public void stopProject(Project project, int performedById)
            throws DockerException, SQLException {

        int pid = project.getId();
        String name = containerName(pid);

        try {
            Result result = TerminalExecutor.execute("docker stop -t 3 " + name);

            if (!result.success() && !result.stderr.contains("No such container")) {
                deploymentLogDAO.log(pid, performedById,
                        DeploymentLog.Action.STOP, "failed", result.stderr);
                throw new DockerException(pid, "docker stop " + name,
                        "Stop failed:\n" + result.combined());
            }

            projectDAO.updateDockerStatus(pid, "stopped");
            deploymentLogDAO.log(pid, performedById,
                    DeploymentLog.Action.STOP, "success", null);

        } catch (IOException | InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new DockerException(pid, "stop", "Unexpected error during stop: " + e.getMessage(), e);
        }
    }

    // ── Rebuild ───────────────────────────────────────────────────────────────
    /**
     * Full rebuild: stop → remove → build → start.
     */
    public void rebuildProject(Project project, int performedById)
            throws DockerException, SQLException {

        int pid = project.getId();

        try {
            silentRemoveContainer(containerName(pid));
            deploymentLogDAO.log(pid, performedById,
                    DeploymentLog.Action.REBUILD, "success", "starting rebuild");

            buildProject(project, performedById);

            // Re-fetch updated project (image tag etc.)
            Project updated = projectDAO.findById(pid);
            startProject(updated, performedById);

        } catch (DockerException de) {
            deploymentLogDAO.log(pid, performedById,
                    DeploymentLog.Action.REBUILD, "failed", de.getMessage());
            throw de;
        } catch (SQLException e) {
            throw new DockerException(pid, "rebuild", "DB error during rebuild: " + e.getMessage(), e);
        }
    }

    // ── Remove ────────────────────────────────────────────────────────────────
    /**
     * Stops and removes the container AND deletes the image.
     */
    public void removeProject(Project project, int performedById)
            throws DockerException, SQLException {

        int pid = project.getId();
        String name = containerName(pid);
        String imageTag = "rt-" + pid;

        try {
            silentRemoveContainer(name);
            TerminalExecutor.executeShell("docker rmi -f " + imageTag);

            projectDAO.updateDockerInfo(pid, "none", null, 0);
            deploymentLogDAO.log(pid, performedById,
                    DeploymentLog.Action.REMOVE, "success", null);

        } catch (IOException | InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new DockerException(pid, "remove", "Unexpected error during remove: " + e.getMessage(), e);
        }
    }

    // ── Status & Stats ────────────────────────────────────────────────────────
    /**
     * Returns the current Docker state string: "running", "exited", "none",
     * etc. Queries Docker directly — use to refresh stale DB state.
     */
    public String getContainerState(int projectId) {
        try {
            Result r = TerminalExecutor.execute(
                    "docker inspect -f {{.State.Status}} " + containerName(projectId));
            if (r.success()) {
                return r.stdout.trim();
            }
        } catch (Exception ignored) {
        }
        return "none";
    }

    /**
     * Returns a compact stats string: "CPU: 0.15% | MEM: 71.25MiB / 512MiB"
     * Returns null if container is not running.
     */
    public String getContainerStats(int projectId) {
        String name = containerName(projectId);
        try {
            Result r = TerminalExecutor.executeShell(
                    "docker stats --no-stream --format 'CPU: {{.CPUPerc}} | MEM: {{.MemUsage}}' " + name);

            if (r.success() && r.stdout != null && !r.stdout.trim().isEmpty()) {
                return r.stdout.trim();
            }

        } catch (Exception ignored) {
        }

        return null;
    }

    /**
     * Returns the last N lines of container logs.
     */
    public String getContainerLogs(int projectId, int tailLines) {
        String name = containerName(projectId);
        try {
            Result r = TerminalExecutor.executeShell(
                    "docker logs --tail=" + tailLines + " " + name);
            if (r.success()) {
                return r.combined();
            }
        } catch (Exception ignored) {
        }
        return "";
    }

    /**
     * Streams live container logs to a Consumer<String>. Returns the underlying
     * Process — caller must call process.destroy() when done.
     */
    public Process streamLogs(int projectId, Consumer<String> lineConsumer) throws IOException {
        String cmd = "docker logs -f --tail=50 " + containerName(projectId);
        return TerminalExecutor.stream(cmd, lineConsumer);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    /**
     * Conventional container name for a project.
     */
    private String containerName(int projectId) {
        return "rt-project-" + projectId;
    }

    /**
     * Stops and removes a container by name, silently ignoring "not found"
     * errors. Used before build/rebuild to avoid name conflicts.
     */
    private void silentRemoveContainer(String name) {
        try {
            TerminalExecutor.executeShell("docker stop " + name);
            TerminalExecutor.executeShell("docker rm -f " + name);
        } catch (Exception ignored) {
        }
    }

    /**
     * Clones a repo if the directory doesn't exist, or pulls latest if it does.
     */
    private String buildCloneCommand(String repoUrl, String branch, String repoDir) {
        String repoDirUnix = repoDir.replace("\\", "/");

        String bashScript = "if [ -d \"" + repoDirUnix + "/.git\" ]; then "
                + "git -C \"" + repoDirUnix + "\" fetch origin && "
                + "git -C \"" + repoDirUnix + "\" checkout " + branch + " && "
                + "git -C \"" + repoDirUnix + "\" pull origin " + branch + "; "
                + "else "
                + "git clone --branch " + branch + " --depth 1 "
                + repoUrl + " \"" + repoDirUnix + "\"; "
                + "fi";

        return bashScript;
    }

    /**
     * Finds a free port in range 32000–33000 by checking what Docker is already
     * using.
     */
    private int findFreePort() throws IOException, InterruptedException {
        Result r = TerminalExecutor.executeShell(
                "docker ps --format '{{.Ports}}' | grep -oP '\\d+(?=->)' | sort -n");

        java.util.Set<Integer> usedPorts = new java.util.HashSet<>();
        if (r.success()) {
            for (String line : r.stdout.split("\n")) {
                try {
                    usedPorts.add(Integer.parseInt(line.trim()));
                } catch (NumberFormatException ignored) {
                }
            }
        }

        for (int port = 32000; port <= 33000; port++) {
            if (!usedPorts.contains(port)) {
                return port;
            }
        }
        throw new IOException("No free ports available in range 32000-33000");
    }

    // ── Daily Limit and Student Verification ───────────────────────────────────
    public static final long DAILY_LIMIT_SECONDS = 4 * 3600; // 4 hours

    public boolean wasContainerStartedByStudent(int projectId) throws SQLException {
        String sql = "SELECT u.role "
                + "FROM deployment_logs dl "
                + "JOIN users u ON dl.performed_by_id = u.id "
                + "WHERE dl.project_id = ? "
                + "  AND dl.action IN ('START', 'REBUILD') "
                + "  AND dl.outcome = 'success' "
                + "ORDER BY dl.performed_at DESC "
                + "LIMIT 1";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, projectId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String role = rs.getString("role");
                    return "STUDENT".equalsIgnoreCase(role);
                }
            }
        }
        return false;
    }

    public long getRunningDurationToday(int projectId) throws SQLException {
        LocalDateTime midnight = LocalDate.now().atStartOfDay();
        Timestamp midnightTs = Timestamp.valueOf(midnight);

        // 1. Find the last successful state-changing log before today
        String sqlBefore = "SELECT dl.action, dl.performed_at, u.role "
                + "FROM deployment_logs dl "
                + "JOIN users u ON dl.performed_by_id = u.id "
                + "WHERE dl.project_id = ? "
                + "  AND dl.outcome = 'success' "
                + "  AND dl.action IN ('START', 'REBUILD', 'STOP', 'REMOVE') "
                + "  AND dl.performed_at < ? "
                + "ORDER BY dl.performed_at DESC "
                + "LIMIT 1";

        boolean isRunning = false;
        LocalDateTime sessionStart = null;
        long totalSeconds = 0;

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sqlBefore)) {
            ps.setInt(1, projectId);
            ps.setTimestamp(2, midnightTs);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String action = rs.getString("action");
                    String role = rs.getString("role");
                    if (("START".equals(action) || "REBUILD".equals(action)) && "STUDENT".equals(role)) {
                        isRunning = true;
                        sessionStart = midnight; // Start counting from midnight today
                    }
                }
            }
        }

        // 2. Fetch all successful state-changing logs today
        String sqlToday = "SELECT dl.action, dl.performed_at, u.role "
                + "FROM deployment_logs dl "
                + "JOIN users u ON dl.performed_by_id = u.id "
                + "WHERE dl.project_id = ? "
                + "  AND dl.outcome = 'success' "
                + "  AND dl.action IN ('START', 'REBUILD', 'STOP', 'REMOVE') "
                + "  AND dl.performed_at >= ? "
                + "ORDER BY dl.performed_at ASC";

        try (Connection c = DBConnection.get();
             PreparedStatement ps = c.prepareStatement(sqlToday)) {
            ps.setInt(1, projectId);
            ps.setTimestamp(2, midnightTs);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String action = rs.getString("action");
                    String role = rs.getString("role");
                    Timestamp performedAtTs = rs.getTimestamp("performed_at");
                    LocalDateTime performedAt = performedAtTs != null ? performedAtTs.toLocalDateTime() : LocalDateTime.now();

                    if ("START".equals(action) || "REBUILD".equals(action)) {
                        if ("STUDENT".equals(role)) {
                            if (!isRunning) {
                                isRunning = true;
                                sessionStart = performedAt;
                            } else {
                                // Already running (perhaps double start log). Close previous and start new.
                                totalSeconds += Duration.between(sessionStart, performedAt).getSeconds();
                                sessionStart = performedAt;
                            }
                        } else {
                            // Supervisor or coordinator started it. Student session ends.
                            if (isRunning) {
                                totalSeconds += Duration.between(sessionStart, performedAt).getSeconds();
                                isRunning = false;
                                sessionStart = null;
                            }
                        }
                    } else if ("STOP".equals(action) || "REMOVE".equals(action)) {
                        if (isRunning) {
                            totalSeconds += Duration.between(sessionStart, performedAt).getSeconds();
                            isRunning = false;
                            sessionStart = null;
                        }
                    }
                }
            }
        }

        // 3. If still running and started by student, add elapsed time until now
        if (isRunning && sessionStart != null) {
            totalSeconds += Duration.between(sessionStart, LocalDateTime.now()).getSeconds();
        }

        return totalSeconds;
    }

    // ── Raw Engine Data ───────────────────────────────────────────────────────
    public static class RawImage {
        public String id, repo, tag, created, size;
    }

    public static class RawContainer {
        public String id, image, command, created, status, ports, names;
    }

    public java.util.List<RawImage> getAllRawImages() {
        java.util.List<RawImage> list = new java.util.ArrayList<>();
        try {
            String out = execDocker("docker", "images", "--format", "{{.ID}}|{{.Repository}}|{{.Tag}}|{{.CreatedAt}}|{{.Size}}");
            if (out != null && !out.trim().isEmpty()) {
                for (String line : out.split("\n")) {
                    String[] parts = line.trim().split("\\|", 5);
                    if (parts.length == 5) {
                        RawImage img = new RawImage();
                        img.id = parts[0]; img.repo = parts[1]; img.tag = parts[2]; img.created = parts[3]; img.size = parts[4];
                        list.add(img);
                    }
                }
            }
        } catch (Exception ignored) {}
        return list;
    }

    public java.util.List<RawContainer> getAllRawContainers() {
        java.util.List<RawContainer> list = new java.util.ArrayList<>();
        try {
            String out = execDocker("docker", "ps", "-a", "--format", "{{.ID}}|{{.Image}}|{{.Command}}|{{.CreatedAt}}|{{.Status}}|{{.Ports}}|{{.Names}}");
            if (out != null && !out.trim().isEmpty()) {
                for (String line : out.split("\n")) {
                    String[] parts = line.trim().split("\\|", 7);
                    if (parts.length >= 6) {
                        RawContainer c = new RawContainer();
                        c.id = parts[0]; c.image = parts[1]; c.command = parts[2]; c.created = parts[3]; c.status = parts[4]; c.ports = parts[5]; c.names = parts.length > 6 ? parts[6] : "";
                        list.add(c);
                    }
                }
            }
        } catch (Exception ignored) {}
        return list;
    }

    public java.util.Map<Integer, String[]> getAllContainerStatsMap() {
        java.util.Map<Integer, String[]> map = new java.util.HashMap<>();
        try {
            String out = execDocker("docker", "stats", "--no-stream", "--format", "{{.Name}}|{{.CPUPerc}}|{{.MemUsage}}|{{.MemPerc}}");
            if (out != null && !out.trim().isEmpty()) {
                for (String line : out.split("\n")) {
                    String[] parts = line.trim().split("\\|", 4);
                    if (parts.length >= 3) {
                        String name = parts[0].trim();
                        if (name.startsWith("rt-project-")) {
                            try {
                                int pid = Integer.parseInt(name.substring(11));
                                map.put(pid, new String[]{
                                    parts[1].trim(),
                                    parts[2].trim(),
                                    parts.length > 3 ? parts[3].trim() : ""
                                });
                            } catch (NumberFormatException ignored) {}
                        }
                    }
                }
            }
        } catch (Exception ignored) {}
        return map;
    }

    // ── System Info ───────────────────────────────────────────────────────────
    public static class SystemInfo {
        public int cpuCount;
        public long memTotalBytes;
        public String totalCpuPerc;   // sum of all container CPUs
        public String totalMemUsage;  // e.g. "134.3MB / 7.54GB"
        public double totalMemPercent;
    }

    public SystemInfo getSystemInfo() {
        SystemInfo info = new SystemInfo();
        try {
            String out = execDocker("docker", "info", "--format", "{{.NCPU}}|{{.MemTotal}}");
            if (out != null) {
                String[] parts = out.trim().split("\\|", 2);
                if (parts.length == 2) {
                    info.cpuCount = Integer.parseInt(parts[0].trim());
                    info.memTotalBytes = Long.parseLong(parts[1].trim());
                }
            }
        } catch (Exception ignored) {}

        try {
            String statsOut = execDocker("docker", "stats", "--no-stream", "--format", "{{.CPUPerc}}|{{.MemUsage}}");
            if (statsOut != null && !statsOut.trim().isEmpty()) {
                double totalCpu = 0;
                double totalUsedMib = 0;
                for (String line : statsOut.split("\n")) {
                    String[] parts = line.trim().split("\\|", 2);
                    if (parts.length == 2) {
                        try { totalCpu += Double.parseDouble(parts[0].replace("%", "").trim()); } catch (Exception ignored) {}
                        String memStr = parts[1].split("/")[0].trim();
                        totalUsedMib += parseMib(memStr);
                    }
                }
                info.totalCpuPerc = String.format("%.2f%%", totalCpu);
                double totalGb = info.memTotalBytes / 1073741824.0;
                double totalUsedMb = totalUsedMib * 1.048576;
                info.totalMemUsage = String.format("%.1fMB / %.2fGB", totalUsedMb, totalGb);
                info.totalMemPercent = info.memTotalBytes > 0 ? (totalUsedMib * 1048576.0 / info.memTotalBytes) * 100.0 : 0;
            }
        } catch (Exception ignored) {}
        return info;
    }

    /** Run docker directly via ProcessBuilder — bypasses shell/bash quoting issues on Windows. Returns stdout string, or null on failure. */
    private static String execDocker(String... args) throws java.io.IOException, InterruptedException {
        ProcessBuilder pb = new ProcessBuilder(args);
        pb.redirectErrorStream(false);
        Process p = pb.start();
        java.util.concurrent.Future<String> outF = captureStreamStatic(p.getInputStream());
        p.getErrorStream().close(); // discard stderr
        p.waitFor(2, java.util.concurrent.TimeUnit.MINUTES);
        try { return outF.get(5, java.util.concurrent.TimeUnit.SECONDS); } catch (Exception ignored) {}
        return null;
    }

    private static java.util.concurrent.Future<String> captureStreamStatic(java.io.InputStream is) {
        java.util.concurrent.ExecutorService pool = java.util.concurrent.Executors.newSingleThreadExecutor();
        return pool.submit(() -> {
            try (java.io.BufferedReader br = new java.io.BufferedReader(new java.io.InputStreamReader(is, java.nio.charset.StandardCharsets.UTF_8))) {
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) sb.append(line).append("\n");
                return sb.toString();
            }
        });
    }


    private static double parseMib(String s) {
        // handles "127MiB", "1.5GiB", "512kB" etc.
        s = s.trim();
        try {
            if (s.endsWith("GiB")) return Double.parseDouble(s.replace("GiB","").trim()) * 1024;
            if (s.endsWith("MiB")) return Double.parseDouble(s.replace("MiB","").trim());
            if (s.endsWith("kB"))  return Double.parseDouble(s.replace("kB","").trim()) / 1024;
            if (s.endsWith("MB"))  return Double.parseDouble(s.replace("MB","").trim()) / 1.048576;
            if (s.endsWith("GB"))  return Double.parseDouble(s.replace("GB","").trim()) * 953.674;
        } catch (Exception ignored) {}
        return 0;
    }
}

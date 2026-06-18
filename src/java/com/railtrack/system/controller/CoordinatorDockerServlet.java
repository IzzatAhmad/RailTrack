package com.railtrack.system.controller;

import com.railtrack.system.dao.DeploymentLogDAO;
import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.exception.DockerException;
import com.railtrack.system.model.DeploymentLog;
import com.railtrack.system.model.Project;
import com.railtrack.system.service.AuthService;
import com.railtrack.system.service.DockerService;
import com.railtrack.system.service.NotificationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Coordinator Docker Monitoring — /coordinator/docker
 * Provides a read/control view over all student containers.
 */
@WebServlet("/coordinator/docker")
public class CoordinatorDockerServlet extends HttpServlet {

    private final ProjectDAO       projectDAO  = new ProjectDAO();
    private final DeploymentLogDAO logDAO      = new DeploymentLogDAO();
    private final DockerService    dockerService = new DockerService();
    private final NotificationService notifService = new NotificationService();

    // ── GET ───────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!AuthService.isCoordinator(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            List<Project> projects = projectDAO.findAll();

            // Refresh docker status live from daemon for each project
            for (Project p : projects) {
                String liveState = dockerService.getContainerState(p.getId());
                if (!liveState.equals(p.getDockerStatus())) {
                    projectDAO.updateDockerStatus(p.getId(), liveState);
                    p.setDockerStatus(liveState);
                }
            }

            // Recent deployment logs across all projects (last 50)
            List<DeploymentLog> recentLogs = logDAO.findRecent(50);

            // Raw Engine Data
            List<DockerService.RawContainer> rawContainers = dockerService.getAllRawContainers();
            List<DockerService.RawImage> rawImages = dockerService.getAllRawImages();
            Map<Integer, String[]> containerStatsMap = dockerService.getAllContainerStatsMap();
            DockerService.SystemInfo systemInfo = dockerService.getSystemInfo();

            req.setAttribute("projects",    projects);
            req.setAttribute("recentLogs",  recentLogs);
            req.setAttribute("rawContainers", rawContainers);
            req.setAttribute("rawImages", rawImages);
            req.setAttribute("containerStatsMap", containerStatsMap);
            req.setAttribute("systemInfo", systemInfo);
            req.setAttribute("notif",       notifService.getCoordinatorCounts());

            // Flash messages
            String flashSuccess = (String) req.getSession().getAttribute("_dockerSuccess");
            String flashError   = (String) req.getSession().getAttribute("_dockerError");
            if (flashSuccess != null) { req.getSession().removeAttribute("_dockerSuccess"); req.setAttribute("flashSuccess", flashSuccess); }
            if (flashError   != null) { req.getSession().removeAttribute("_dockerError");   req.setAttribute("flashError",   flashError);   }

            req.getRequestDispatcher("/views/coordinator/docker.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Failed to load Docker overview", e);
        }
    }

    // ── POST ──────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!AuthService.isCoordinator(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int coordinatorId = AuthService.getSessionUserId(req);
        String action = req.getParameter("action");
        String redirect = req.getContextPath() + "/coordinator/docker";

        int projectId;
        try {
            projectId = Integer.parseInt(req.getParameter("projectId"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(redirect);
            return;
        }

        try {
            Project project = projectDAO.findById(projectId);
            if (project == null) {
                req.getSession().setAttribute("_dockerError", "Project #" + projectId + " not found.");
                resp.sendRedirect(redirect);
                return;
            }

            switch (action == null ? "" : action) {
                case "stop":
                    dockerService.stopProject(project, coordinatorId);
                    req.getSession().setAttribute("_dockerSuccess",
                        "Container for \"" + project.getTitle() + "\" stopped successfully.");
                    break;

                case "start":
                    dockerService.startProject(project, coordinatorId);
                    req.getSession().setAttribute("_dockerSuccess",
                        "Container for \"" + project.getTitle() + "\" started successfully.");
                    break;

                case "remove":
                    dockerService.removeProject(project, coordinatorId);
                    req.getSession().setAttribute("_dockerSuccess",
                        "Container and image for \"" + project.getTitle() + "\" removed.");
                    break;

                case "rebuild":
                    dockerService.rebuildProject(project, coordinatorId);
                    req.getSession().setAttribute("_dockerSuccess",
                        "Container for \"" + project.getTitle() + "\" rebuilt successfully.");
                    break;

                default:
                    break;
            }

        } catch (DockerException e) {
            getServletContext().log("Coordinator Docker action error on project " + projectId, e);
            req.getSession().setAttribute("_dockerError", "Docker error: " + e.getMessage());
        } catch (SQLException e) {
            throw new ServletException("Database error during Docker action", e);
        }

        resp.sendRedirect(redirect);
    }
}

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.railtrack.system.controller;

import com.railtrack.system.dao.FeedbackDAO;
import com.railtrack.system.dao.MilestoneDAO;
import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.dao.UserDAO;
import com.railtrack.system.model.Milestone;
import com.railtrack.system.model.Project;
import com.railtrack.system.model.PitaAssignment;
import com.railtrack.system.service.AuthService;
import com.railtrack.system.service.NotificationService;
import com.railtrack.system.service.ProjectService;
import com.railtrack.system.service.DockerService;
import com.railtrack.system.dao.DeploymentLogDAO;
import com.railtrack.system.exception.DockerException;
import com.railtrack.system.model.DeploymentLog;
import com.railtrack.system.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 *
 * @author izzat
 */
@WebServlet("/student/project/*")
public class StudentProjectServlet extends HttpServlet {

    private final ProjectDAO projectDAO = new ProjectDAO();
    private final MilestoneDAO milestoneDAO = new MilestoneDAO();
    private final FeedbackDAO feedbackDAO = new FeedbackDAO();
    private final UserDAO userDAO = new UserDAO();
    private final ProjectService projectService = new ProjectService();
    private final NotificationService notifService = new NotificationService();
    private final DockerService dockerService = new DockerService();
    private final DeploymentLogDAO logDAO = new DeploymentLogDAO();

    // ── GET ───────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int studentId = AuthService.getSessionUserId(req);
        int projectId = parseProjectId(req, resp);
        if (projectId < 0)
            return;

        try {
            Project project = projectDAO.findById(projectId);

            // Security: student can only view their own projects
            if (project == null || project.getStudentId() != studentId) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            List<Milestone> milestones = milestoneDAO.findByProject(projectId);

            // Enforce daily limit: if running, started by student, and exceeded, auto-stop
            long durationToday = dockerService.getRunningDurationToday(projectId);
            if ("running".equalsIgnoreCase(project.getDockerStatus()) && durationToday >= project.getRunningLimitSeconds() && dockerService.wasContainerStartedByStudent(projectId)) {
                dockerService.stopProject(project, studentId); // system stop
                project.setDockerStatus("stopped");
            }

            // Refresh docker status from daemon (non-blocking, best-effort)
            String liveState = dockerService.getContainerState(projectId);
            if (!liveState.equals(project.getDockerStatus())) {
                projectDAO.updateDockerStatus(projectId, liveState);
                project.setDockerStatus(liveState);
            }

            List<DeploymentLog> logs = logDAO.findRecentByProject(projectId, 20);
            String stats = dockerService.getContainerStats(projectId);

            // Mark all feedback as read when student opens project
            notifService.markProjectFeedbackRead(projectId);

            // Pick up flash error from session (set by doPost redirect on error)
            String flashError = (String) req.getSession().getAttribute("_flashError");
            if (flashError != null) {
                req.getSession().removeAttribute("_flashError");
                req.setAttribute("formError", flashError);
            }

            req.setAttribute("project", project);
            req.setAttribute("milestones", milestones);
            req.setAttribute("feedbacks", feedbackDAO.findByProject(projectId));
            req.setAttribute("pitaAssignments", userDAO.findPitaAssignmentsByProject(projectId));
            req.setAttribute("notif", notifService.getStudentCounts(studentId));
            req.setAttribute("durationToday", durationToday);
            req.setAttribute("deployLogs", logs);
            req.setAttribute("stats", stats);

            req.getRequestDispatcher("/views/student/project.jsp").forward(req, resp);

        } catch (SQLException | DockerException e) {
            throw new ServletException("Failed to load project", e);
        }
    }

    // ── POST ──────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int studentId = AuthService.getSessionUserId(req);
        int projectId = parseProjectId(req, resp);
        if (projectId < 0)
            return;

        String action = req.getParameter("action");
        String redirect = req.getContextPath() + "/student/project/" + projectId;

        try {
            Project project = projectDAO.findById(projectId);
            if (project == null || project.getStudentId() != studentId) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            switch (action == null ? "" : action) {
                case "submit": {
                    // Student submits a milestone for review
                    int milestoneId = ValidationUtil.parseIntSafe(req.getParameter("milestoneId"), -1);
                    String submissionNote = req.getParameter("submissionNote");
                    projectService.submitMilestone(milestoneId, submissionNote, studentId);
                    resp.sendRedirect(redirect + "?success=submitted");
                    break;
                }
                case "start-milestone": {
                    // Student marks milestone as in-progress
                    int milestoneId = ValidationUtil.parseIntSafe(req.getParameter("milestoneId"), -1);
                    milestoneDAO.markInProgress(milestoneId);
                    resp.sendRedirect(redirect + "?success=started");
                    break;
                }

                // ── Docker operations ─────────────────────────────────────────
                case "deploy": {
                    long durationToday = dockerService.getRunningDurationToday(projectId);
                    if (durationToday >= project.getRunningLimitSeconds()) {
                        throw new IllegalArgumentException("You have reached your daily running limit of " + (project.getRunningLimitSeconds() / 3600.0) + " hours.");
                    }
                    dockerService.buildProject(project, studentId);
                    // Re-fetch project so image tag is up-to-date before starting
                    Project builtProject = projectDAO.findById(projectId);
                    dockerService.startProject(builtProject, studentId);
                    resp.sendRedirect(redirect + "?success=deployed");
                    break;
                }

                case "start": {
                    long durationToday = dockerService.getRunningDurationToday(projectId);
                    if (durationToday >= project.getRunningLimitSeconds()) {
                        throw new IllegalArgumentException("You have reached your daily running limit of " + (project.getRunningLimitSeconds() / 3600.0) + " hours.");
                    }
                    dockerService.startProject(project, studentId);
                    resp.sendRedirect(redirect + "?success=started");
                    break;
                }

                case "stop":
                    dockerService.stopProject(project, studentId);
                    resp.sendRedirect(redirect + "?success=stopped");
                    break;

                case "rebuild": {
                    long durationToday = dockerService.getRunningDurationToday(projectId);
                    if (durationToday >= project.getRunningLimitSeconds()) {
                        throw new IllegalArgumentException("You have reached your daily running limit of " + (project.getRunningLimitSeconds() / 3600.0) + " hours.");
                    }
                    dockerService.rebuildProject(project, studentId);
                    resp.sendRedirect(redirect + "?success=rebuilt");
                    break;
                }

                case "remove":
                    dockerService.removeProject(project, studentId);
                    resp.sendRedirect(redirect + "?success=removed");
                    break;

                default:
                    resp.sendRedirect(redirect);
            }

        } catch (IllegalArgumentException e) {
            // Redirect back to project page with error — do NOT call doGet() from doPost()
            // as the response may already be committed (e.g., after SSE flush).
            req.getSession().setAttribute("_flashError", e.getMessage());
            resp.sendRedirect(redirect + "?error=1");

        } catch (DockerException e) {
            getServletContext().log("Docker error on project " + projectId, e);
            req.getSession().setAttribute("_flashError", "Docker error: " + e.getMessage());
            resp.sendRedirect(redirect + "?error=1");

        } catch (SQLException e) {
            throw new ServletException("Database or system error", e);
        }
    }

    // ── Helper ────────────────────────────────────────────────────────────────

    private int parseProjectId(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String info = req.getPathInfo(); // "/123"
        if (info == null || info.equals("/")) {
            if ("GET".equalsIgnoreCase(req.getMethod())) {
                resp.sendRedirect(req.getContextPath() + "/student/dashboard");
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid project id");
            }
            return -1;
        }
        try {
            return Integer.parseInt(info.substring(1));
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid project id");
            return -1;
        }
    }
}
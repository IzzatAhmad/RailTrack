/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.railtrack.system.controller;

import com.railtrack.system.dao.*;
import com.railtrack.system.exception.DockerException;
import com.railtrack.system.model.*;
import com.railtrack.system.service.*;
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
@WebServlet("/supervisor/project/*")
public class SupervisorProjectServlet extends HttpServlet {

    private final ProjectDAO projectDAO = new ProjectDAO();
    private final MilestoneDAO milestoneDAO = new MilestoneDAO();
    private final FeedbackDAO feedbackDAO = new FeedbackDAO();
    private final DeploymentLogDAO logDAO = new DeploymentLogDAO();
    private final ProjectService projectService = new ProjectService();
    private final DockerService dockerService = new DockerService();
    private final NotificationService notifService = new NotificationService();

    // ── GET ───────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int supervisorId = AuthService.getSessionUserId(req);
        int projectId = parseId(req, resp);
        if (projectId < 0)
            return;

        try {
            Project project = projectDAO.findById(projectId);
            if (project == null || project.getSupervisorId() != supervisorId) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            // Enforce daily limit: if running, started by student, and exceeded, auto-stop
            long durationToday = dockerService.getRunningDurationToday(projectId);
            if ("running".equalsIgnoreCase(project.getDockerStatus()) && durationToday >= project.getRunningLimitSeconds() && dockerService.wasContainerStartedByStudent(projectId)) {
                dockerService.stopProject(project, 0); // system stop
                project.setDockerStatus("stopped");
            }

            // Refresh docker status from daemon (non-blocking, best-effort)
            String liveState = dockerService.getContainerState(projectId);
            if (!liveState.equals(project.getDockerStatus())) {
                projectDAO.updateDockerStatus(projectId, liveState);
                project.setDockerStatus(liveState);
            }

            List<Milestone> milestones = milestoneDAO.findByProject(projectId);
            List<Feedback> feedbacks = feedbackDAO.findByProject(projectId);
            List<DeploymentLog> logs = logDAO.findRecentByProject(projectId, 20);
            String stats = dockerService.getContainerStats(projectId);

            req.setAttribute("project", project);
            req.setAttribute("milestones", milestones);
            req.setAttribute("feedbacks", feedbacks);
            req.setAttribute("deployLogs", logs);
            req.setAttribute("stats", stats);
            req.setAttribute("notif", notifService.getSupervisorCounts(supervisorId));

            req.getRequestDispatcher("/views/supervisor/project.jsp").forward(req, resp);

        } catch (SQLException | DockerException e) {
            throw new ServletException("Failed to load project", e);
        }
    }

    // ── POST ──────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int supervisorId = AuthService.getSessionUserId(req);
        int projectId = parseId(req, resp);
        if (projectId < 0)
            return;

        String action = req.getParameter("action");
        String redirect = req.getContextPath() + "/supervisor/project/" + projectId;

        try {
            Project project = projectDAO.findById(projectId);
            if (project == null || project.getSupervisorId() != supervisorId) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            switch (action == null ? "" : action) {

                // ── Milestone review ──────────────────────────────────────────
                case "approve": {
                    int mid = ValidationUtil.parseIntSafe(req.getParameter("milestoneId"), -1);
                    double grade = ValidationUtil.parseDoubleSafe(req.getParameter("grade"), -1);
                    String note = req.getParameter("supervisorNote");
                    projectService.approveMilestone(mid, grade, note, supervisorId);
                    resp.sendRedirect(redirect + "?success=approved");
                    break;
                }
                case "reject": {
                    int mid = ValidationUtil.parseIntSafe(req.getParameter("milestoneId"), -1);
                    String note = req.getParameter("supervisorNote");
                    projectService.rejectMilestone(mid, note);
                    resp.sendRedirect(redirect + "?success=rejected");
                    break;
                }

                // ── Feedback ──────────────────────────────────────────────────
                case "feedback": {
                    String content = req.getParameter("content");
                    String typeStr = req.getParameter("type");
                    Feedback.FeedbackType type = parseFeedbackType(typeStr);
                    projectService.postFeedback(projectId, null, supervisorId, type, content);
                    resp.sendRedirect(redirect + "?success=feedback");
                    break;
                }

                // ── Assessment Marks ──────────────────────────────────────────
                case "update_marks": {
                    double om = ValidationUtil.parseDoubleSafe(req.getParameter("observationMark"), 0.0);
                    double cm = ValidationUtil.parseDoubleSafe(req.getParameter("continuousMark"), 0.0);
                    projectDAO.updateMarks(projectId, om, cm);
                    resp.sendRedirect(redirect + "?success=marks_updated");
                    break;
                }

                // ── Docker operations ─────────────────────────────────────────
                case "deploy":
                    dockerService.buildProject(project, supervisorId);
                    resp.sendRedirect(redirect + "?success=built");
                    break;

                case "start":
                    dockerService.startProject(project, supervisorId);
                    resp.sendRedirect(redirect + "?success=started");
                    break;

                case "stop":
                    dockerService.stopProject(project, supervisorId);
                    resp.sendRedirect(redirect + "?success=stopped");
                    break;

                case "rebuild":
                    dockerService.rebuildProject(project, supervisorId);
                    resp.sendRedirect(redirect + "?success=rebuilt");
                    break;

                case "remove":
                    dockerService.removeProject(project, supervisorId);
                    resp.sendRedirect(redirect + "?success=removed");
                    break;

                default:
                    resp.sendRedirect(redirect);
            }

        } catch (IllegalArgumentException e) {
            req.setAttribute("formError", e.getMessage());
            doGet(req, resp);

        } catch (DockerException e) {
            getServletContext().log("Docker error on project " + projectId, e);
            req.setAttribute("formError", "Docker error: " + e.getMessage());
            doGet(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private int parseId(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            if ("GET".equalsIgnoreCase(req.getMethod())) {
                resp.sendRedirect(req.getContextPath() + "/supervisor/dashboard");
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
            return -1;
        }
        try {
            return Integer.parseInt(pathInfo.substring(1));
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return -1;
        }
    }

    private Feedback.FeedbackType parseFeedbackType(String s) {
        try {
            return Feedback.FeedbackType.valueOf(s);
        } catch (Exception e) {
            return Feedback.FeedbackType.GENERAL;
        }
    }
}

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.railtrack.system.controller;

import com.railtrack.system.dao.*;
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
@WebServlet("/coordinator/project/*")
public class CoordinatorProjectServlet extends HttpServlet {
 
    private final ProjectDAO              projectDAO              = new ProjectDAO();
    private final MilestoneDAO            milestoneDAO            = new MilestoneDAO();
    private final FeedbackDAO             feedbackDAO             = new FeedbackDAO();
    private final DeploymentLogDAO        logDAO                  = new DeploymentLogDAO();
    private final UserDAO                 userDAO                 = new UserDAO();
    private final SupervisorAssignmentDAO assignmentDAO           = new SupervisorAssignmentDAO();
    private final ProjectService          projectService          = new ProjectService();
    private final NotificationService     notifService            = new NotificationService();
 
    // ── GET ───────────────────────────────────────────────────────────────────
 
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        int coordinatorId = AuthService.getSessionUserId(req);
        int projectId     = parseId(req, resp);
        if (projectId == -2) return;
        if (projectId == -1) {
            try {
                List<Project> projects = projectDAO.findAll();
                List<User> supervisors = userDAO.findAllSupervisors();
                req.setAttribute("projects",    projects);
                req.setAttribute("supervisors", supervisors);
                req.setAttribute("notif",       notifService.getCoordinatorCounts());
                req.getRequestDispatcher("/views/coordinator/projects.jsp").forward(req, resp);
            } catch (SQLException e) {
                throw new ServletException("Failed to load project list", e);
            }
            return;
        }
 
        try {
            Project project = projectDAO.findById(projectId);
            if (project == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
 
            req.setAttribute("project",         project);
            req.setAttribute("milestones",      milestoneDAO.findByProject(projectId));
            req.setAttribute("feedbacks",       feedbackDAO.findByProject(projectId));
            req.setAttribute("deployLogs",      logDAO.findRecentByProject(projectId, 20));
            req.setAttribute("supervisors",     userDAO.findAllSupervisors());
            req.setAttribute("assignHistory",   assignmentDAO.findByProject(projectId));
            req.setAttribute("notif",           notifService.getCoordinatorCounts());
            req.setAttribute("pita1Evaluators",  userDAO.findEvaluatorsByProjectAndStage(projectId, "PITA1"));
            req.setAttribute("pita2Evaluators",  userDAO.findEvaluatorsByProjectAndStage(projectId, "PITA2"));
 
            req.getRequestDispatcher("/views/coordinator/project.jsp").forward(req, resp);
 
        } catch (SQLException e) {
            throw new ServletException("Failed to load project", e);
        }
    }
 
    // ── POST ──────────────────────────────────────────────────────────────────
 
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        int    coordinatorId = AuthService.getSessionUserId(req);
        int    projectId     = parseId(req, resp);
        String action        = req.getParameter("action");

        if (projectId < 0) {
            if (projectId == -1 && ("bulkDelete".equals(action) || "autoAssign".equals(action))) {
                // Allowed for bulk actions without project ID
            } else {
                if (projectId == -1) {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing project ID");
                }
                return;
            }
        }
 
        String redirect = req.getContextPath() + "/coordinator/project" + (projectId > 0 ? "/" + projectId : "");
 
        try {
            switch (action == null ? "" : action) {

                case "updateLimit": {
                    double limitHours = ValidationUtil.parseDoubleSafe(req.getParameter("limitHours"), -1);
                    if (limitHours < 0.1 || limitHours > 24.0) {
                        throw new IllegalArgumentException("Daily limit must be between 0.1 and 24.0 hours.");
                    }
                    int limitSeconds = (int) (limitHours * 3600);
                    projectDAO.updateRunningLimit(projectId, limitSeconds);
                    resp.sendRedirect(redirect + "?success=limit_updated");
                    break;
                }

                case "autoAssign": {
                    int assignedCount = projectService.autoAssignSupervisors(coordinatorId);
                    resp.sendRedirect(req.getContextPath() + "/coordinator/project?success=auto_assigned&count=" + assignedCount);
                    break;
                }

                case "assign": {
                    int    supId = ValidationUtil.parseIntSafe(req.getParameter("supervisorId"), -1);
                    String note  = req.getParameter("note");
                    if (supId < 1) throw new IllegalArgumentException("Please select a supervisor.");
                    projectService.assignSupervisor(projectId, supId, coordinatorId, note);
                    resp.sendRedirect(redirect + "?success=assigned");
                    break;
                }
 
                case "addEvaluator": {
                    int evaluatorId = ValidationUtil.parseIntSafe(req.getParameter("evaluatorId"), -1);
                    String stage = req.getParameter("stage");
                    if (evaluatorId < 1 || (!"PITA1".equals(stage) && !"PITA2".equals(stage))) {
                        throw new IllegalArgumentException("Invalid evaluator or stage.");
                    }
                    userDAO.addEvaluator(projectId, evaluatorId, stage);
                    resp.sendRedirect(redirect + "?success=evaluator_added");
                    break;
                }
 
                case "removeEvaluator": {
                    int evaluatorId = ValidationUtil.parseIntSafe(req.getParameter("evaluatorId"), -1);
                    String stage = req.getParameter("stage");
                    if (evaluatorId < 1 || (!"PITA1".equals(stage) && !"PITA2".equals(stage))) {
                        throw new IllegalArgumentException("Invalid evaluator or stage.");
                    }
                    userDAO.removeEvaluator(projectId, evaluatorId, stage);
                    resp.sendRedirect(redirect + "?success=evaluator_removed");
                    break;
                }
 
                case "reject": {
                    String reason = req.getParameter("reason");
                    projectService.rejectProject(projectId, coordinatorId, reason);
                    resp.sendRedirect(redirect + "?success=rejected");
                    break;
                }
 
                case "feedback": {
                    String content = req.getParameter("content");
                    String typeStr = req.getParameter("type");
                    Feedback.FeedbackType type;
                    try { type = Feedback.FeedbackType.valueOf(typeStr); }
                    catch (Exception e) { type = Feedback.FeedbackType.GENERAL; }
                    projectService.postFeedback(projectId, null, coordinatorId, type, content);
                    resp.sendRedirect(redirect + "?success=feedback");
                    break;
                }
 
                case "complete": {
                    projectDAO.updateStatus(projectId, Project.Status.COMPLETED);
                    resp.sendRedirect(redirect + "?success=completed");
                    break;
                }
 
                case "delete": {
                    Project project = projectDAO.findById(projectId);
                    if (project != null) {
                        try {
                            DockerService docker = new DockerService();
                            docker.removeProject(project, coordinatorId);
                        } catch (Exception ignored) {
                            // ignore container remove errors and proceed with DB deletion
                        }
                        projectDAO.delete(projectId);
                    }
                    resp.sendRedirect(req.getContextPath() + "/coordinator/project?success=deleted");
                    break;
                }

                case "bulkDelete": {
                    String[] ids = req.getParameterValues("ids");
                    if (ids != null && ids.length > 0) {
                        DockerService docker = new DockerService();
                        for (String idStr : ids) {
                            int pId = ValidationUtil.parseIntSafe(idStr, -1);
                            if (pId > 0) {
                                Project project = projectDAO.findById(pId);
                                if (project != null) {
                                    try {
                                        docker.removeProject(project, coordinatorId);
                                    } catch (Exception ignored) {}
                                    projectDAO.delete(pId);
                                }
                            }
                        }
                    }
                    resp.sendRedirect(req.getContextPath() + "/coordinator/project?success=bulk_deleted");
                    break;
                }

                case "createMilestone": {
                    int milestoneNo = Integer.parseInt(req.getParameter("milestoneNo"));
                    double weight = Double.parseDouble(req.getParameter("weight"));
                    String title = req.getParameter("title");
                    String dueDateStr = req.getParameter("dueDate");
                    String description = req.getParameter("description");
                    String pitaStage = req.getParameter("pitaStage");

                    if (ValidationUtil.isBlank(title) || ValidationUtil.isBlank(dueDateStr)) {
                        throw new IllegalArgumentException("Title and Due Date are required.");
                    }

                    Milestone m = new Milestone();
                    m.setProjectId(projectId);
                    m.setMilestoneNo(milestoneNo);
                    m.setTitle(title.trim());
                    m.setDueDate(java.time.LocalDate.parse(dueDateStr));
                    m.setWeight(weight);
                    m.setDescription(description != null ? description.trim() : null);
                    m.setPitaStage(pitaStage != null && !pitaStage.trim().isEmpty() ? pitaStage.trim() : null);

                    milestoneDAO.insert(m);
                    resp.sendRedirect(redirect + "?success=milestone_created");
                    break;
                }

                case "updateMilestone": {
                    int milestoneId = Integer.parseInt(req.getParameter("milestoneId"));
                    double weight = Double.parseDouble(req.getParameter("weight"));
                    String title = req.getParameter("title");
                    String dueDateStr = req.getParameter("dueDate");
                    String description = req.getParameter("description");
                    String pitaStage = req.getParameter("pitaStage");

                    if (ValidationUtil.isBlank(title) || ValidationUtil.isBlank(dueDateStr)) {
                        throw new IllegalArgumentException("Title and Due Date are required.");
                    }

                    Milestone m = milestoneDAO.findById(milestoneId);
                    if (m == null) {
                        throw new IllegalArgumentException("Milestone not found.");
                    }

                    m.setTitle(title.trim());
                    m.setDueDate(java.time.LocalDate.parse(dueDateStr));
                    m.setWeight(weight);
                    m.setDescription(description != null ? description.trim() : null);
                    m.setPitaStage(pitaStage != null && !pitaStage.trim().isEmpty() ? pitaStage.trim() : null);

                    milestoneDAO.updateDetails(m);
                    resp.sendRedirect(redirect + "?success=milestone_updated");
                    break;
                }

                case "deleteMilestone": {
                    int milestoneId = Integer.parseInt(req.getParameter("milestoneId"));
                    milestoneDAO.delete(milestoneId);
                    resp.sendRedirect(redirect + "?success=milestone_deleted");
                    break;
                }
 
                default:
                    resp.sendRedirect(redirect);
            }
 
        } catch (IllegalArgumentException e) {
            req.setAttribute("formError", e.getMessage());
            doGet(req, resp);
 
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }
 
    // ── Helper ────────────────────────────────────────────────────────────────
 
    private int parseId(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            return -1;
        }
        try { return Integer.parseInt(pathInfo.substring(1)); }
        catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return -2;
        }
    }
}
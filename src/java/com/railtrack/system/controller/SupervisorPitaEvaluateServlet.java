package com.railtrack.system.controller;

import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.dao.UserDAO;
import com.railtrack.system.model.Project;
import com.railtrack.system.model.PitaAssignment;
import com.railtrack.system.service.AuthService;
import com.railtrack.system.service.NotificationService;
import com.railtrack.system.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/supervisor/pita-evaluate")
public class SupervisorPitaEvaluateServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final ProjectDAO projectDAO = new ProjectDAO();
    private final NotificationService notifService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer supervisorId = AuthService.getSessionUserId(req);
        if (supervisorId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int projectId = ValidationUtil.parseIntSafe(req.getParameter("projectId"), -1);
        String stage = req.getParameter("stage");

        if (projectId < 1 || (!"PITA1".equals(stage) && !"PITA2".equals(stage))) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid project ID or evaluation stage.");
            return;
        }

        try {
            PitaAssignment assignment = userDAO.findPitaAssignment(projectId, supervisorId, stage);
            if (assignment == null) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not assigned to evaluate this project for this stage.");
                return;
            }

            Project project = projectDAO.findById(projectId);
            if (project == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Project not found.");
                return;
            }

            req.setAttribute("pitaAssignment", assignment);
            req.setAttribute("project", project);
            req.setAttribute("notif", notifService.getSupervisorCounts(supervisorId));

            req.getRequestDispatcher("/views/supervisor/pita_evaluate.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error loading PITA assignment", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer supervisorId = AuthService.getSessionUserId(req);
        if (supervisorId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int projectId = ValidationUtil.parseIntSafe(req.getParameter("projectId"), -1);
        String stage = req.getParameter("stage");
        String gradeStr = req.getParameter("grade");
        String feedback = req.getParameter("feedback");

        if (projectId < 1 || (!"PITA1".equals(stage) && !"PITA2".equals(stage))) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid parameters.");
            return;
        }

        try {
            // Verify access
            PitaAssignment assignment = userDAO.findPitaAssignment(projectId, supervisorId, stage);
            if (assignment == null) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not assigned to evaluate this project.");
                return;
            }

            // Validation - grade is optional, feedback is required
            Double grade = null;
            if (gradeStr != null && !gradeStr.trim().isEmpty()) {
                double parsedGrade = ValidationUtil.parseDoubleSafe(gradeStr, -1);
                if (parsedGrade < 0 || parsedGrade > 100) {
                    throw new IllegalArgumentException("Grade must be a valid number between 0 and 100.");
                }
                grade = parsedGrade;
            }
            if (feedback == null || feedback.trim().isEmpty()) {
                throw new IllegalArgumentException("Feedback / comments cannot be blank.");
            }

            // Persist
            userDAO.submitPitaEvaluation(projectId, supervisorId, stage, grade, feedback.trim());

            resp.sendRedirect(req.getContextPath() + "/supervisor/dashboard?success=pita_evaluated");

        } catch (IllegalArgumentException e) {
            req.setAttribute("formError", e.getMessage());
            doGet(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Database error saving PITA evaluation", e);
        }
    }
}

package com.railtrack.system.controller;

import com.railtrack.system.dao.LogbookDAO;
import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.dao.UserDAO;
import com.railtrack.system.model.LogbookEntry;
import com.railtrack.system.model.Project;
import com.railtrack.system.model.User;
import com.railtrack.system.service.AuthService;
import com.railtrack.system.service.NotificationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/supervisor/student/logbook")
public class SupervisorLogbookServlet extends HttpServlet {

    private final LogbookDAO logbookDAO = new LogbookDAO();
    private final ProjectDAO projectDAO = new ProjectDAO();
    private final UserDAO userDAO = new UserDAO();
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer supervisorId = AuthService.getSessionUserId(req);
        if (supervisorId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String studentIdStr = req.getParameter("studentId");
        if (studentIdStr == null || studentIdStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Student ID is required.");
            return;
        }

        try {
            int studentId = Integer.parseInt(studentIdStr);
            User student = userDAO.findById(studentId);
            if (student == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Student not found.");
                return;
            }

            // Verify authorization: this student must belong to this supervisor's projects
            List<Project> supervisorProjects = projectDAO.findBySupervisor(supervisorId);
            boolean isAssigned = supervisorProjects.stream()
                    .anyMatch(p -> p.getStudentId() == studentId);

            if (!isAssigned) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not authorized to view this student's logbook.");
                return;
            }

            List<LogbookEntry> entries = logbookDAO.findByStudent(studentId);

            req.setAttribute("student", student);
            req.setAttribute("entries", entries);
            req.setAttribute("notif", notificationService.getSupervisorCounts(supervisorId));

            req.getRequestDispatcher("/views/supervisor/student_logbook.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Student ID.");
        } catch (SQLException e) {
            throw new ServletException("Database error loading student logbook", e);
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

        String entryIdStr = req.getParameter("entryId");
        String action = req.getParameter("action"); // "verify" or "unverify"

        if (entryIdStr == null || entryIdStr.trim().isEmpty() || action == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid entryId or action.");
            return;
        }

        try {
            int entryId = Integer.parseInt(entryIdStr);
            LogbookEntry entry = logbookDAO.findById(entryId);
            if (entry == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Log entry not found.");
                return;
            }

            // Authorization check: Make sure this entry belongs to a student supervised by this supervisor
            List<Project> supervisorProjects = projectDAO.findBySupervisor(supervisorId);
            boolean isAssigned = supervisorProjects.stream()
                    .anyMatch(p -> p.getStudentId() == entry.getStudentId());

            if (!isAssigned) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not authorized to edit this student's logbook.");
                return;
            }

            boolean verifyStatus = "verify".equalsIgnoreCase(action);
            logbookDAO.updateVerification(entryId, verifyStatus);

            resp.sendRedirect(req.getContextPath() + "/supervisor/student/logbook?studentId=" + entry.getStudentId() + "&success=updated");

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid entry ID.");
        } catch (SQLException e) {
            throw new ServletException("Database error updating logbook entry verification status", e);
        }
    }
}

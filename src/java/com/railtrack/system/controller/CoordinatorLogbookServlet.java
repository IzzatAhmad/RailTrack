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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/coordinator/logbook")
public class CoordinatorLogbookServlet extends HttpServlet {

    private final LogbookDAO logbookDAO = new LogbookDAO();
    private final ProjectDAO projectDAO = new ProjectDAO();
    private final UserDAO userDAO = new UserDAO();
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer coordinatorId = AuthService.getSessionUserId(req);
        if (coordinatorId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String studentIdStr = req.getParameter("studentId");
        
        try {
            if (studentIdStr == null || studentIdStr.trim().isEmpty()) {
                // View all students logbook summaries
                List<User> students = userDAO.findAllStudents();
                Map<Integer, Integer> totalEntriesMap = new HashMap<>();
                Map<Integer, Integer> verifiedEntriesMap = new HashMap<>();
                
                for (User student : students) {
                    List<LogbookEntry> entries = logbookDAO.findByStudent(student.getId());
                    totalEntriesMap.put(student.getId(), entries.size());
                    int verified = (int) entries.stream().filter(LogbookEntry::isVerified).count();
                    verifiedEntriesMap.put(student.getId(), verified);
                }
                
                req.setAttribute("students", students);
                req.setAttribute("totalEntriesMap", totalEntriesMap);
                req.setAttribute("verifiedEntriesMap", verifiedEntriesMap);
                req.setAttribute("notif", notificationService.getCoordinatorCounts());

                req.getRequestDispatcher("/views/coordinator/logbooks.jsp").forward(req, resp);
            } else {
                // View detailed logbook for a specific student
                int studentId = Integer.parseInt(studentIdStr);
                User student = userDAO.findById(studentId);
                if (student == null) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Student not found.");
                    return;
                }

                List<LogbookEntry> entries = logbookDAO.findByStudent(studentId);

                req.setAttribute("student", student);
                req.setAttribute("entries", entries);
                req.setAttribute("notif", notificationService.getCoordinatorCounts());

                req.getRequestDispatcher("/views/coordinator/student_logbook.jsp").forward(req, resp);
            }
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Student ID.");
        } catch (SQLException e) {
            throw new ServletException("Database error loading logbooks", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer coordinatorId = AuthService.getSessionUserId(req);
        if (coordinatorId == null) {
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

            boolean verifyStatus = "verify".equalsIgnoreCase(action);
            logbookDAO.updateVerification(entryId, verifyStatus);

            resp.sendRedirect(req.getContextPath() + "/coordinator/logbook?studentId=" + entry.getStudentId() + "&success=updated");

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid entry ID.");
        } catch (SQLException e) {
            throw new ServletException("Database error updating logbook entry verification status", e);
        }
    }
}

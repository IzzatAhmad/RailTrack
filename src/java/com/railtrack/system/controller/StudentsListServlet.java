package com.railtrack.system.controller;

import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.model.Project;
import com.railtrack.system.service.AuthService;
import com.railtrack.system.service.NotificationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.*;

/**
 * Displays the student list grouped by supervisor, filtered by session/semester.
 * Accessible to STUDENT, SUPERVISOR, and COORDINATOR roles.
 *
 * URL: /students/list
 */
@WebServlet("/students/list")
public class StudentsListServlet extends HttpServlet {

    private final ProjectDAO          projectDAO   = new ProjectDAO();
    private final NotificationService notifService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userRole") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("userRole");

        try {
            // All distinct semesters for the dropdown
            List<String> semesters = projectDAO.findDistinctSemesters();
            req.setAttribute("semesters", semesters);

            // Default selected semester: first in list (most recent), or from param
            String selectedSemester = req.getParameter("semester");
            if (selectedSemester == null || selectedSemester.trim().isEmpty()) {
                selectedSemester = semesters.isEmpty() ? null : semesters.get(0);
            }
            req.setAttribute("selectedSemester", selectedSemester);

            if (selectedSemester != null) {
                List<Project> projects = projectDAO.findAllStudentsWithProjectBySemester(selectedSemester);

                // Group by supervisor — LinkedHashMap preserves insertion order
                Map<String, List<Project>> grouped = new LinkedHashMap<>();
                for (Project p : projects) {
                    String supName = p.getSupervisorName() != null && !p.getSupervisorName().isEmpty()
                            ? p.getSupervisorName() : "(Unassigned)";
                    grouped.computeIfAbsent(supName, k -> new ArrayList<>()).add(p);
                }
                req.setAttribute("grouped", grouped);
                req.setAttribute("totalCount", projects.size());
            }

            // Load role-appropriate notification counts (used by the header)
            try {
                if ("COORDINATOR".equals(role)) {
                    req.setAttribute("notif", notifService.getCoordinatorCounts());
                } else if ("SUPERVISOR".equals(role)) {
                    Integer supId = AuthService.getSessionUserId(req);
                    if (supId != null) {
                        req.setAttribute("notif", notifService.getSupervisorCounts(supId));
                    }
                } else if ("STUDENT".equals(role)) {
                    Integer stuId = AuthService.getSessionUserId(req);
                    if (stuId != null) {
                        req.setAttribute("notif", notifService.getStudentCounts(stuId));
                    }
                }
            } catch (Exception ignored) {
                // Non-fatal: notification counts are optional
            }

            req.setAttribute("pageTitle", "Student List");

            req.getRequestDispatcher("/views/coordinator/students_list.jsp")
               .forward(req, resp);

        } catch (Exception e) {
            throw new ServletException("Failed to load student list", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userRole") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        // Redirect to GET with selected semester as a query param
        String semester = req.getParameter("semester");
        String redirect = req.getContextPath() + "/students/list";
        if (semester != null && !semester.trim().isEmpty()) {
            redirect += "?semester=" + java.net.URLEncoder.encode(semester.trim(), "UTF-8");
        }
        resp.sendRedirect(redirect);
    }
}


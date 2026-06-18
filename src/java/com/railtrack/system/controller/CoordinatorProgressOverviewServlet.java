package com.railtrack.system.controller;

import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.dao.LogbookDAO;
import com.railtrack.system.model.Project;
import com.railtrack.system.model.LogbookEntry;
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

@WebServlet("/coordinator/progress_overview")
public class CoordinatorProgressOverviewServlet extends HttpServlet {

    private final ProjectDAO          projectDAO   = new ProjectDAO();
    private final LogbookDAO          logbookDAO   = new LogbookDAO();
    private final NotificationService notifService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userRole") == null || !"COORDINATOR".equals(session.getAttribute("userRole"))) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            List<String> semesters = projectDAO.findDistinctSemesters();
            req.setAttribute("semesters", semesters);

            String selectedSemester = req.getParameter("semester");
            if (selectedSemester == null || selectedSemester.trim().isEmpty()) {
                selectedSemester = semesters.isEmpty() ? null : semesters.get(0);
            }
            req.setAttribute("selectedSemester", selectedSemester);

            if (selectedSemester != null) {
                List<Project> projects = projectDAO.findAllStudentsWithProjectBySemester(selectedSemester);
                
                Map<Integer, Integer> verifiedLogbooksCount = new HashMap<>();
                for (Project p : projects) {
                    int count = 0;
                    if (p.getId() > 0) {
                        List<LogbookEntry> entries = logbookDAO.findByProject(p.getId());
                        for (LogbookEntry entry : entries) {
                            if (entry.isVerified()) {
                                count++;
                            }
                        }
                    }
                    verifiedLogbooksCount.put(p.getId(), count);
                }
                
                req.setAttribute("projects", projects);
                req.setAttribute("verifiedLogbooksCount", verifiedLogbooksCount);
                req.setAttribute("totalCount", projects.size());
            }

            try {
                req.setAttribute("notif", notifService.getCoordinatorCounts());
            } catch (Exception ignored) {}

            req.setAttribute("pageTitle", "Student Progress Overview");
            req.getRequestDispatcher("/views/coordinator/progress_overview.jsp").forward(req, resp);

        } catch (Exception e) {
            throw new ServletException("Failed to load progress overview", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userRole") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String semester = req.getParameter("semester");
        String redirect = req.getContextPath() + "/coordinator/progress_overview";
        if (semester != null && !semester.trim().isEmpty()) {
            redirect += "?semester=" + java.net.URLEncoder.encode(semester.trim(), "UTF-8");
        }
        resp.sendRedirect(redirect);
    }
}

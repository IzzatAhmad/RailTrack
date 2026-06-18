package com.railtrack.system.controller;

import com.railtrack.system.dao.LogbookDAO;
import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.model.LogbookEntry;
import com.railtrack.system.model.Project;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.*;

@WebServlet("/presentation")
public class PresentationEligibilityServlet extends HttpServlet {

    private final ProjectDAO projectDAO = new ProjectDAO();
    private final LogbookDAO logbookDAO = new LogbookDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userRole") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            // Semesters for dropdown
            List<String> semesters = projectDAO.findDistinctSemesters();
            req.setAttribute("semesters", semesters);

            String selectedSemester = req.getParameter("semester");
            if (selectedSemester == null || selectedSemester.trim().isEmpty()) {
                selectedSemester = semesters.isEmpty() ? null : semesters.get(0);
            }
            req.setAttribute("selectedSemester", selectedSemester);

            if (selectedSemester != null) {
                // Fetch projects
                List<Project> projects = projectDAO.findAllStudentsWithProjectBySemester(selectedSemester);
                
                // Map to store logbook count for each student/project
                Map<Integer, Integer> verifiedLogbookCounts = new HashMap<>();
                Map<Integer, Boolean> eligibilityMap = new HashMap<>();

                for (Project p : projects) {
                    List<LogbookEntry> logbooks = logbookDAO.findByStudent(p.getStudentId());
                    int verifiedCount = (int) logbooks.stream().filter(LogbookEntry::isVerified).count();
                    
                    verifiedLogbookCounts.put(p.getId(), verifiedCount);
                    
                    double observationMark = p.getObservationMark() != null ? p.getObservationMark() : 0.0;
                    boolean eligible = (verifiedCount >= 5) && (observationMark >= 50.0);
                    eligibilityMap.put(p.getId(), eligible);
                }

                // Group by supervisor
                Map<String, List<Project>> grouped = new LinkedHashMap<>();
                for (Project p : projects) {
                    String supName = p.getSupervisorName() != null && !p.getSupervisorName().isEmpty()
                            ? p.getSupervisorName() : "(Unassigned)";
                    grouped.computeIfAbsent(supName, k -> new ArrayList<>()).add(p);
                }
                
                req.setAttribute("grouped", grouped);
                req.setAttribute("totalCount", projects.size());
                req.setAttribute("verifiedLogbookCounts", verifiedLogbookCounts);
                req.setAttribute("eligibilityMap", eligibilityMap);
            }

        } catch (Exception e) {
            req.setAttribute("error", "Failed to load presentation eligibility list.");
        }

        req.getRequestDispatcher("/views/coordinator/presentation_list.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String semester = req.getParameter("semester");
        String redirect = req.getContextPath() + "/presentation";
        if (semester != null && !semester.trim().isEmpty()) {
            redirect += "?semester=" + java.net.URLEncoder.encode(semester.trim(), "UTF-8");
        }
        resp.sendRedirect(redirect);
    }
}

package com.railtrack.system.controller;

import com.railtrack.system.dao.MilestoneDAO;
import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.dao.UserDAO;
import com.railtrack.system.model.Project;
import com.railtrack.system.model.PitaAssignment;
import com.railtrack.system.service.AuthService;
import com.railtrack.system.service.NotificationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/supervisor/dashboard")
public class SupervisorDashboardServlet extends HttpServlet {

    private final ProjectDAO projectDAO = new ProjectDAO();
    private final MilestoneDAO milestoneDAO = new MilestoneDAO();
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

        try {
            List<Project> projects = projectDAO.findBySupervisor(supervisorId);
            com.railtrack.system.dao.UserDAO uDAO = new com.railtrack.system.dao.UserDAO();
            List<com.railtrack.system.model.User> students = uDAO.findStudentsBySupervisor(supervisorId);

            java.util.Set<Integer> studentIdsWithProjects = new java.util.HashSet<>();
            for (Project p : projects) {
                studentIdsWithProjects.add(p.getStudentId());
            }

            for (com.railtrack.system.model.User s : students) {
                if (!studentIdsWithProjects.contains(s.getId())) {
                    Project dummy = new Project();
                    dummy.setId(-1);
                    dummy.setTitle("(No project registered yet)");
                    dummy.setStudentId(s.getId());
                    dummy.setStudentName(s.getFullName());
                    dummy.setSupervisorId(supervisorId);
                    dummy.setSupervisorName(s.getSupervisorName());
                    dummy.setStatus(Project.Status.PENDING);
                    dummy.setDockerStatus("none");
                    dummy.setRepoUrl("");
                    dummy.setBranch("");
                    projects.add(dummy);
                }
            }

            long activeCount = projects.stream().filter(p -> "ACTIVE".equals(p.getStatus().name())).count();
            long pendingCount = projects.stream().filter(p -> "PENDING".equals(p.getStatus().name())).count();
            long completedCount = projects.stream().filter(p -> "COMPLETED".equals(p.getStatus().name())).count();

            req.setAttribute("projects", projects);
            req.setAttribute("activeCount", activeCount);
            req.setAttribute("pendingCount", pendingCount);
            req.setAttribute("completedCount", completedCount);
            req.setAttribute("pendingMilestones", milestoneDAO.findPendingBySupervisor(supervisorId));
            req.setAttribute("notif", notificationService.getSupervisorCounts(supervisorId));
            
            // PITA Assignments
            List<PitaAssignment> pitaAssignments = userDAO.findPitaAssignmentsBySupervisor(supervisorId);
            req.setAttribute("pitaAssignments", pitaAssignments);

            // Logbook Entries Aggregation by Month
            com.railtrack.system.dao.LogbookDAO logbookDAO = new com.railtrack.system.dao.LogbookDAO();
            java.util.Map<String, Integer> logbookCounts = new java.util.LinkedHashMap<>();
            String[] months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
            for (String m : months) logbookCounts.put(m, 0);

            for (Project p : projects) {
                if (p.getId() > 0) {
                    List<com.railtrack.system.model.LogbookEntry> entries = logbookDAO.findByProject(p.getId());
                    for (com.railtrack.system.model.LogbookEntry entry : entries) {
                        if (entry.getActivityDate() != null) {
                            String monthName = months[entry.getActivityDate().getMonthValue() - 1];
                            logbookCounts.put(monthName, logbookCounts.get(monthName) + 1);
                        }
                    }
                }
            }
            
            // Build simple JSON array string for logbook counts
            StringBuilder logbookJson = new StringBuilder("[");
            for (int i = 0; i < 12; i++) {
                logbookJson.append(logbookCounts.get(months[i]));
                if (i < 11) logbookJson.append(",");
            }
            logbookJson.append("]");
            req.setAttribute("logbookCountsJson", logbookJson.toString());

            req.getRequestDispatcher("/views/supervisor/dashboard.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Failed to load supervisor dashboard", e);
        }
    }
}

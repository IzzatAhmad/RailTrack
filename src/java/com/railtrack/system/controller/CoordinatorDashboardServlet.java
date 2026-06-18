/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.railtrack.system.controller;

import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.dao.UserDAO;
import com.railtrack.system.dao.LogbookDAO;
import com.railtrack.system.model.Project;
import com.railtrack.system.model.PitaAssignment;
import com.railtrack.system.service.AuthService;
import com.railtrack.system.service.NotificationService;
import com.google.gson.Gson;
 
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 *
 * @author izzat
 */
@WebServlet("/coordinator/dashboard")
public class CoordinatorDashboardServlet extends HttpServlet {

    private final ProjectDAO          projectDAO          = new ProjectDAO();
    private final UserDAO             userDAO             = new UserDAO();
    private final LogbookDAO          logbookDAO          = new LogbookDAO();
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            List<Project> allDbProjects = projectDAO.findAll();
            List<com.railtrack.system.model.User> allStudents = userDAO.findAllStudents();
            
            java.util.Set<Integer> validStudentIds = new java.util.HashSet<>();
            for (com.railtrack.system.model.User s : allStudents) {
                validStudentIds.add(s.getId());
            }

            List<Project> projects = new java.util.ArrayList<>();
            java.util.Set<Integer> studentIdsWithProjects = new java.util.HashSet<>();
            
            for (Project p : allDbProjects) {
                if (validStudentIds.contains(p.getStudentId())) {
                    projects.add(p);
                    studentIdsWithProjects.add(p.getStudentId());
                }
            }
            
            for (com.railtrack.system.model.User s : allStudents) {
                if (!studentIdsWithProjects.contains(s.getId())) {
                    Project dummy = new Project();
                    dummy.setId(-1);
                    dummy.setTitle("(No project registered yet)");
                    dummy.setStudentId(s.getId());
                    dummy.setStudentName(s.getFullName());
                    dummy.setStudentDepartment(s.getDepartment());
                    dummy.setSupervisorId(s.getSupervisorId() != null ? s.getSupervisorId() : 0);
                    dummy.setSupervisorName(s.getSupervisorName());
                    dummy.setStatus(Project.Status.PENDING);
                    dummy.setDockerStatus("none");
                    dummy.setRepoUrl("");
                    dummy.setBranch("");
                    projects.add(dummy);
                }
            }

            long activeCount     = projects.stream().filter(p -> p.getStatus() == Project.Status.ACTIVE).count();
            long pendingCount    = projects.stream().filter(p -> p.getStatus() == Project.Status.PENDING).count();
            long completedCount  = projects.stream().filter(p -> p.getStatus() == Project.Status.COMPLETED).count();
            long rejectedCount   = projects.stream().filter(p -> p.getStatus() == Project.Status.REJECTED).count();
            long underReviewCount= projects.stream().filter(p -> p.getStatus() == Project.Status.UNDER_REVIEW).count();

            req.setAttribute("projects",        projects);
            req.setAttribute("activeCount",     activeCount);
            req.setAttribute("pendingCount",    pendingCount);
            req.setAttribute("completedCount",  completedCount);
            req.setAttribute("rejectedCount",   rejectedCount);
            req.setAttribute("underReviewCount",underReviewCount);

            // keep old names too in case other parts of JSP use them
            req.setAttribute("allProjects",     projects);
            req.setAttribute("statActive",      activeCount);
            req.setAttribute("statPending",     pendingCount);
            req.setAttribute("statCompleted",   completedCount);
            req.setAttribute("statRejected",    rejectedCount);
            req.setAttribute("statUnderReview", underReviewCount);

            // Fetch System-wide PITA assignments and Logbook Stats
            List<PitaAssignment> pitaAssignments = userDAO.findAllPitaAssignments();
            req.setAttribute("pitaAssignments", pitaAssignments);

            // Logbook Stats handled in JSP now

            req.setAttribute("unassigned",      projectDAO.findUnassigned());
            req.setAttribute("notif",           notificationService.getCoordinatorCounts());

            req.getRequestDispatcher("/views/coordinator/dashboard.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Failed to load coordinator dashboard", e);
        }
    }
}
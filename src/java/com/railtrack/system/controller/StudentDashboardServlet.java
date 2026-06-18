package com.railtrack.system.controller;

import com.railtrack.system.dao.FeedbackDAO;
import com.railtrack.system.dao.MenuItemDAO;
import com.railtrack.system.dao.MilestoneDAO;
import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.model.Project;
import com.railtrack.system.service.AuthService;
import com.railtrack.system.service.NotificationService;
import com.railtrack.system.service.ProjectService;
 
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/student/dashboard")
public class StudentDashboardServlet extends HttpServlet {
 
    private final ProjectDAO         projectDAO         = new ProjectDAO();
    private final MenuItemDAO        menuItemDAO        = new MenuItemDAO();
    private final NotificationService notificationService = new NotificationService();
    private final ProjectService     projectService     = new ProjectService();
 
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        int studentId = AuthService.getSessionUserId(req);
 
        try {
            List<Project> projects = projectDAO.findByStudent(studentId);
 
            // Stats
            long activeCount    = projects.stream()
                    .filter(p -> p.getStatus() == Project.Status.ACTIVE).count();
            long pendingCount   = projects.stream()
                    .filter(p -> p.getStatus() == Project.Status.PENDING).count();
            long completedCount = projects.stream()
                    .filter(p -> p.getStatus() == Project.Status.COMPLETED).count();
 
            req.setAttribute("projects",       projects);
            req.setAttribute("activeCount",    activeCount);
            req.setAttribute("pendingCount",   pendingCount);
            req.setAttribute("completedCount", completedCount);
            req.setAttribute("menuItems",      menuItemDAO.findEnabled());
            req.setAttribute("notif", notificationService.getStudentCounts(studentId));

            // -- New Analytics Data --
            
            // 1. Logbooks
            com.railtrack.system.dao.LogbookDAO logbookDAO = new com.railtrack.system.dao.LogbookDAO();
            java.util.List<com.railtrack.system.model.LogbookEntry> allLogbooks = logbookDAO.findByStudent(studentId);
            int totalLogbookCount = allLogbooks.size();
            int verifiedLogbookCount = (int) allLogbooks.stream()
                .filter(com.railtrack.system.model.LogbookEntry::isVerified)
                .count();
            req.setAttribute("logbookCount", verifiedLogbookCount); // For eligibility logic
            req.setAttribute("totalLogbookCount", totalLogbookCount);
            
            // 2. Report Submission
            com.railtrack.system.dao.DocumentDAO docDAO = new com.railtrack.system.dao.DocumentDAO();
            com.railtrack.system.model.DocumentType type = docDAO.findDocumentTypeByKeyCode("THESIS_PDF");
            boolean reportSubmitted = false;
            if (type != null) {
                reportSubmitted = docDAO.findDocumentByStudentAndType(studentId, type.getId()) != null;
            }
            req.setAttribute("reportSubmitted", reportSubmitted);

            // 3. Observation Mark & Progress
            double observationMark = 0.0;
            double continuousMark = 0.0;
            double devProgress = 0.0;
            double execProgress = 0.0;
            double overallProgress = 0.0;
            boolean presentationEligible = false;
            int[] chapterProgress = new int[]{0, 0, 0, 0, 0, 0, 0, 0}; // Abstract + 7 chapters

            if (!projects.isEmpty()) {
                Project activeProject = projects.get(0);
                
                if (activeProject.getObservationMark() != null) {
                    observationMark = activeProject.getObservationMark();
                }
                if (activeProject.getContinuousMark() != null) {
                    continuousMark = activeProject.getContinuousMark();
                }

                // Infer progress percentages from milestones for the donut charts
                List<com.railtrack.system.model.Milestone> milestones = new com.railtrack.system.dao.MilestoneDAO().findByProject(activeProject.getId());
                int totalMilestones = milestones.size();
                int completedMilestones = 0;
                
                for (com.railtrack.system.model.Milestone m : milestones) {
                    if ("APPROVED".equals(m.getStatus().name()) || "COMPLETED".equals(m.getStatus().name())) {
                        completedMilestones++;
                    }
                }

                if (totalMilestones > 0) {
                    overallProgress = ((double) completedMilestones / totalMilestones) * 100.0;
                    devProgress = Math.min(100.0, overallProgress * 1.2); 
                    execProgress = Math.min(100.0, overallProgress * 1.1);
                } else if (activeProject.getStatus() == Project.Status.ACTIVE) {
                    overallProgress = 10.0;
                    devProgress = 15.0;
                    execProgress = 5.0;
                }

                // Chapter progress now reads from live database
                chapterProgress = activeProject.getChapterProgressArray();

                // Flowchart logic:
                // MF (Logbook Count) >= 5 AND OM (Observation Mark) >= 50% -> Presentation Eligibility
                presentationEligible = (verifiedLogbookCount >= 5) && (observationMark >= 50.0);
                
                // CM (Continuous Mark) >= 45% -> Thesis Eligibility
                boolean thesisEligible = presentationEligible && (continuousMark >= 45.0); 
                
                // Final Pass (LULUS) = Thesis Eligibility AND Thesis Submitted
                boolean isPass = thesisEligible && reportSubmitted;
                req.setAttribute("isPass", isPass);
            }

            req.setAttribute("observationMark", String.format("%.2f", observationMark));
            req.setAttribute("continuousMark", String.format("%.2f", continuousMark));
            req.setAttribute("devProgress", String.format("%.1f", devProgress));
            req.setAttribute("execProgress", String.format("%.1f", execProgress));
            req.setAttribute("overallProgress", String.format("%.1f", overallProgress));
            req.setAttribute("presentationEligible", presentationEligible);
            req.setAttribute("thesisEligible", presentationEligible && (continuousMark >= 45.0));
            req.setAttribute("chapterProgress", chapterProgress);
 
            req.getRequestDispatcher("/views/student/dashboard.jsp").forward(req, resp);
 
        } catch (SQLException e) {
            throw new ServletException("Failed to load student dashboard", e);
        }
    }
 
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        int    studentId   = AuthService.getSessionUserId(req);
        String title       = req.getParameter("title");
        String description = req.getParameter("description");
        String repoUrl     = req.getParameter("repoUrl");
        String branch      = req.getParameter("branch");
        String semester    = req.getParameter("semester");
 
        try {
            projectService.submitProject(studentId, title, description, repoUrl, branch, semester);
            resp.sendRedirect(req.getContextPath() + "/student/dashboard?success=submitted");
 
        } catch (IllegalArgumentException e) {
            req.setAttribute("formError", e.getMessage());
            doGet(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Failed to submit project", e);
        }
    }
}

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
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/supervisor/students", "/supervisor/students/note"})
public class SupervisorStudentsServlet extends HttpServlet {

    private final ProjectDAO          projectDAO          = new ProjectDAO();
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || !"SUPERVISOR".equals(session.getAttribute("userRole"))) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            Integer supervisorId = AuthService.getSessionUserId(req);
            if (supervisorId == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

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

            Map<String, Long> notif = notificationService.getSupervisorCounts(supervisorId);

            java.util.Map<Integer, Boolean> notifEnabledMap = new java.util.HashMap<>();
            for (com.railtrack.system.model.User s : students) {
                notifEnabledMap.put(s.getId(), s.isEmailNotifEnabled());
            }
            req.setAttribute("notifEnabledMap", notifEnabledMap);

            req.setAttribute("projects", projects);
            req.setAttribute("notif",    notif);
            req.setAttribute("pageTitle", "My Students");

            req.getRequestDispatcher("/views/supervisor/students.jsp")
               .forward(req, resp);

        } catch (Exception e) {
            throw new ServletException("Failed to load students page", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || !"SUPERVISOR".equals(session.getAttribute("userRole"))) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if ("toggleEmailNotif".equals(action)) {
            try {
                int supervisorId = AuthService.getSessionUserId(req).intValue();
                int studentId = Integer.parseInt(req.getParameter("studentId"));
                com.railtrack.system.dao.UserDAO uDAO = new com.railtrack.system.dao.UserDAO();
                com.railtrack.system.model.User student = uDAO.findById(studentId);

                if (student != null && student.getRole() == com.railtrack.system.model.User.Role.STUDENT) {
                    if (student.getSupervisorId() != null && student.getSupervisorId().equals(supervisorId)) {
                        student.setEmailNotifEnabled(!student.isEmailNotifEnabled());
                        uDAO.update(student);
                        resp.sendRedirect(req.getContextPath() + "/supervisor/students?success=notif_toggled");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/supervisor/students?error=unauthorized");
                    }
                } else {
                    resp.sendRedirect(req.getContextPath() + "/supervisor/students?error=invalid_student");
                }
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/supervisor/students?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            }
            return;
        }

        String studentIdStr = req.getParameter("studentId");
        String noteText     = req.getParameter("note");
        String visibility   = req.getParameter("visibility"); // "private" | "student"

        try {
            int supervisorId = AuthService.getSessionUserId(req).intValue();
            int studentId    = Integer.parseInt(studentIdStr);

            // TODO: call note-saving DAO/service if needed here
            // e.g. noteDAO.save(supervisorId, studentId, noteText, visibility);

            resp.sendRedirect(req.getContextPath() + "/supervisor/students?success=noted");

        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath()
                    + "/supervisor/students?error="
                    + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
}

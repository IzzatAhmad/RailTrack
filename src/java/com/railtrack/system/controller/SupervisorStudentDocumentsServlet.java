package com.railtrack.system.controller;

import com.railtrack.system.dao.DocumentDAO;
import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.dao.UserDAO;
import com.railtrack.system.model.DocumentType;
import com.railtrack.system.model.Project;
import com.railtrack.system.model.StudentDocument;
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

@WebServlet("/supervisor/student/documents")
public class SupervisorStudentDocumentsServlet extends HttpServlet {

    private final DocumentDAO documentDAO = new DocumentDAO();
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

            // Authorization check: Make sure this student belongs to this supervisor's projects
            List<Project> supervisorProjects = projectDAO.findBySupervisor(supervisorId);
            boolean isAssigned = supervisorProjects.stream()
                    .anyMatch(p -> p.getStudentId() == studentId);

            if (!isAssigned) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not authorized to view this student's documents.");
                return;
            }

            List<DocumentType> types = documentDAO.findAllDocumentTypes();
            List<StudentDocument> docs = documentDAO.findDocumentsByStudent(studentId);

            Map<Integer, StudentDocument> docMap = new HashMap<>();
            for (StudentDocument doc : docs) {
                docMap.put(doc.getDocumentTypeId(), doc);
            }

            Project activeProject = supervisorProjects.stream()
                    .filter(p -> p.getStudentId() == studentId && p.getStatus() != Project.Status.REJECTED)
                    .findFirst().orElse(null);
            
            if (activeProject != null) {
                req.setAttribute("activeProject", activeProject);
                req.setAttribute("chapterProgress", activeProject.getChapterProgressArray());
            }

            req.setAttribute("student", student);
            req.setAttribute("documentTypes", types);
            req.setAttribute("studentDocs", docMap);
            req.setAttribute("notif", notificationService.getSupervisorCounts(supervisorId));

            req.getRequestDispatcher("/views/supervisor/student_documents.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Student ID.");
        } catch (SQLException e) {
            throw new ServletException("Database error loading student documents", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer supervisorId = AuthService.getSessionUserId(req);
        if (supervisorId == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
            return;
        }

        String action = req.getParameter("action");
        if ("updateChapterProgress".equals(action)) {
            try {
                int projectId = Integer.parseInt(req.getParameter("projectId"));
                int studentId = Integer.parseInt(req.getParameter("studentId"));
                
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < 8; i++) {
                    String val = req.getParameter("ch" + i);
                    sb.append(val != null && !val.isEmpty() ? val : "0");
                    if (i < 7) sb.append(",");
                }
                
                projectDAO.updateChapterProgress(projectId, sb.toString());
                
                resp.sendRedirect(req.getContextPath() + "/supervisor/student/documents?studentId=" + studentId);
            } catch (Exception e) {
                throw new ServletException("Failed to update chapter progress", e);
            }
        }
    }
}

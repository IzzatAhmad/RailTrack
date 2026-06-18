package com.railtrack.system.controller;

import com.railtrack.system.dao.DocumentDAO;
import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.model.DocumentType;
import com.railtrack.system.model.Project;
import com.railtrack.system.model.StudentDocument;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.*;

@WebServlet("/thesis/status")
public class ThesisStatusServlet extends HttpServlet {

    private final ProjectDAO projectDAO = new ProjectDAO();
    private final DocumentDAO documentDAO = new DocumentDAO();

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
                
                // Group by supervisor — LinkedHashMap preserves insertion order
                Map<String, List<Project>> grouped = new LinkedHashMap<>();
                for (Project p : projects) {
                    String supName = p.getSupervisorName() != null && !p.getSupervisorName().isEmpty()
                            ? p.getSupervisorName() : "(Unassigned)";
                    grouped.computeIfAbsent(supName, k -> new ArrayList<>()).add(p);
                }
                req.setAttribute("grouped", grouped);
                req.setAttribute("totalCount", projects.size());
                
                // Fetch all documents and types
                List<DocumentType> allTypes = documentDAO.findAllDocumentTypes();
                Map<Integer, String> typeIdToKeyCode = new HashMap<>();
                for (DocumentType dt : allTypes) {
                    typeIdToKeyCode.put(dt.getId(), dt.getKeyCode());
                }

                List<StudentDocument> allDocs = documentDAO.findAllStudentDocuments();
                
                // studentId -> set of uploaded keyCodes
                Map<Integer, Set<String>> studentUploads = new HashMap<>();
                for (StudentDocument doc : allDocs) {
                    studentUploads.putIfAbsent(doc.getStudentId(), new HashSet<>());
                    String keyCode = typeIdToKeyCode.get(doc.getDocumentTypeId());
                    if (keyCode != null) {
                        studentUploads.get(doc.getStudentId()).add(keyCode);
                    }
                }

                req.setAttribute("studentUploads", studentUploads);
            }

        } catch (Exception e) {
            req.setAttribute("error", "Failed to load thesis status list.");
        }

        req.getRequestDispatcher("/views/coordinator/thesis_status_list.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String semester = req.getParameter("semester");
        String redirect = req.getContextPath() + "/thesis/status";
        if (semester != null && !semester.trim().isEmpty()) {
            redirect += "?semester=" + java.net.URLEncoder.encode(semester.trim(), "UTF-8");
        }
        resp.sendRedirect(redirect);
    }
}

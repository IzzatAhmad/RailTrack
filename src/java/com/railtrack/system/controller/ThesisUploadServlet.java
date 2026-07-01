package com.railtrack.system.controller;

import com.railtrack.system.dao.DocumentDAO;
import com.railtrack.system.dao.UserDAO;
import com.railtrack.system.model.DocumentType;
import com.railtrack.system.model.StudentDocument;
import com.railtrack.system.model.User;
import com.railtrack.system.service.AuthService;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.io.File;

@WebServlet("/thesis/upload")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize       = 50L * 1024 * 1024,   // 50 MB
        maxRequestSize    = 60L * 1024 * 1024    // 60 MB total
)
public class ThesisUploadServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final DocumentDAO documentDAO = new DocumentDAO();

    // The persistent storage location
    private static final String UPLOAD_DIR = System.getProperty("user.home") + "/RailTrack_Storage/thesis_uploads";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer userId = AuthService.getSessionUserId(req);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String role = AuthService.getSessionUserRole(req);
        com.railtrack.system.dao.SystemSettingsDAO settingsDAO = new com.railtrack.system.dao.SystemSettingsDAO();

        try {
            String instructions = settingsDAO.getSetting("thesis_upload_instructions", "Please fill out the details and upload your project files. Fields marked with <span class=\"text-danger\">*</span> are required. Uploading a file again will overwrite the existing one.");
            req.setAttribute("instructions", instructions);

            if ("COORDINATOR".equals(role)) {
                req.getRequestDispatcher("/views/coordinator/thesis_upload_settings.jsp").forward(req, resp);
                return;
            }

            User student = userDAO.findById(userId);
            req.setAttribute("student", student);

            List<StudentDocument> allDocs = documentDAO.findDocumentsByStudent(userId);
            Map<String, StudentDocument> uploadedDocs = new HashMap<>();
            
            for (StudentDocument doc : allDocs) {
                DocumentType dt = documentDAO.findDocumentTypeById(doc.getDocumentTypeId());
                if (dt != null) {
                    uploadedDocs.put(dt.getKeyCode(), doc);
                }
            }
            req.setAttribute("uploadedDocs", uploadedDocs);

        } catch (Exception e) {
            req.setAttribute("student", null);
        }

        req.getRequestDispatcher("/views/student/thesis_upload.jsp").forward(req, resp);
    }

    private DocumentType getOrCreateDocType(String keyCode, String name) throws SQLException {
        DocumentType dt = documentDAO.findDocumentTypeByKeyCode(keyCode);
        if (dt == null) {
            dt = new DocumentType();
            dt.setKeyCode(keyCode);
            dt.setName(name);
            dt.setDescription(name + " upload");
            documentDAO.saveDocumentType(dt);
        }
        return dt;
    }

    private void handleUpload(Part part, int studentId, String keyCode, String typeName) throws Exception {
        if (part == null || part.getSize() == 0) return;

        DocumentType type = getOrCreateDocType(keyCode, typeName);
        
        String mime = part.getContentType();
        if (mime == null || mime.isEmpty()) {
            mime = "application/octet-stream";
        }

        String submittedName = java.nio.file.Paths
                .get(part.getSubmittedFileName())
                .getFileName().toString();

        StudentDocument doc = new StudentDocument();
        doc.setStudentId(studentId);
        doc.setDocumentTypeId(type.getId());
        doc.setFileName(submittedName);
        doc.setContentType(mime);
        doc.setFileSize((int) part.getSize());

        // Stream the file directly to persistent storage
        File uploadDir = new File(UPLOAD_DIR);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String uniqueFileName = studentId + "_" + type.getId() + "_" + submittedName;
        Path targetPath = Paths.get(UPLOAD_DIR, uniqueFileName);

        try (InputStream in = part.getInputStream()) {
            Files.copy(in, targetPath, StandardCopyOption.REPLACE_EXISTING);
        }

        // Save metadata only
        documentDAO.saveStudentDocumentMeta(doc);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer userId = AuthService.getSessionUserId(req);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String role = AuthService.getSessionUserRole(req);
        
        if ("COORDINATOR".equals(role)) {
            String newInstructions = req.getParameter("instructions");
            if (newInstructions != null && !newInstructions.trim().isEmpty()) {
                com.railtrack.system.dao.SystemSettingsDAO settingsDAO = new com.railtrack.system.dao.SystemSettingsDAO();
                try {
                    settingsDAO.setSetting("thesis_upload_instructions", newInstructions.trim());
                    resp.sendRedirect(req.getContextPath() + "/thesis/upload?success=settings");
                } catch (SQLException e) {
                    req.setAttribute("formError", "Database error updating instructions.");
                    doGet(req, resp);
                }
            } else {
                req.setAttribute("formError", "Instructions cannot be empty.");
                doGet(req, resp);
            }
            return;
        }

        try {
            Part thesisPart = req.getPart("thesis");
            Part latexPart = req.getPart("latex_zip");
            Part projectPart = req.getPart("project_zip");

            handleUpload(thesisPart, userId, "THESIS_PDF", "Thesis");
            handleUpload(latexPart, userId, "THESIS_LATEX_ZIP", "Thesis Latex Zip");
            handleUpload(projectPart, userId, "PROJECT_ZIP", "Project Zip");

            resp.sendRedirect(req.getContextPath() + "/thesis/upload?success=true");
            
        } catch (Exception e) {
            req.setAttribute("formError", "Failed to upload files: " + e.getMessage());
            doGet(req, resp);
        }
    }
}

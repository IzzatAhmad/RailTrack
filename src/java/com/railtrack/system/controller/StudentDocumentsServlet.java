package com.railtrack.system.controller;

import com.railtrack.system.dao.DocumentDAO;
import com.railtrack.system.model.DocumentType;
import com.railtrack.system.model.StudentDocument;
import com.railtrack.system.service.AuthService;
import com.railtrack.system.service.NotificationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/student/documents")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize       = 20 * 1024 * 1024,   // 20 MB per document
        maxRequestSize    = 25 * 1024 * 1024     // 25 MB total
)
public class StudentDocumentsServlet extends HttpServlet {

    private final DocumentDAO         documentDAO         = new DocumentDAO();
    private final NotificationService notificationService = new NotificationService();

    // ── GET ───────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int studentId = AuthService.getSessionUserId(req);

        try {
            List<DocumentType>    types  = documentDAO.findAllDocumentTypes();
            List<StudentDocument> docs   = documentDAO.findDocumentsByStudent(studentId);

            // Build lookup map: typeId → document
            Map<Integer, StudentDocument> docMap = new HashMap<>();
            for (StudentDocument doc : docs) {
                docMap.put(doc.getDocumentTypeId(), doc);
            }

            req.setAttribute("documentTypes", types);
            req.setAttribute("studentDocs",   docMap);
            req.setAttribute("notif", notificationService.getStudentCounts(studentId));

            req.getRequestDispatcher("/views/student/documents.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Failed to load documents page", e);
        }
    }

    // ── POST ──────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int    studentId = AuthService.getSessionUserId(req);
        String action    = req.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action parameter is missing.");
            return;
        }

        try {
            if ("upload".equalsIgnoreCase(action)) {

                String typeIdStr = req.getParameter("documentTypeId");
                if (typeIdStr == null || typeIdStr.trim().isEmpty()) {
                    throw new IllegalArgumentException("Document type is required.");
                }
                int typeId = Integer.parseInt(typeIdStr);

                DocumentType type = documentDAO.findDocumentTypeById(typeId);
                if (type == null) {
                    throw new IllegalArgumentException("Invalid document type.");
                }

                Part part = req.getPart("documentFile");
                if (part == null || part.getSize() == 0) {
                    throw new IllegalArgumentException("No file selected or file is empty.");
                }
                if (part.getSize() > 20 * 1024 * 1024) {
                    throw new IllegalArgumentException("File size cannot exceed 20MB.");
                }

                // Detect content type
                String mime = part.getContentType();
                if (mime == null || mime.isEmpty()) {
                    mime = "application/octet-stream";
                }

                // Original filename
                String submittedName = java.nio.file.Paths
                        .get(part.getSubmittedFileName())
                        .getFileName().toString();

                byte[] data;
                try (InputStream in = part.getInputStream()) {
                    java.io.ByteArrayOutputStream bos = new java.io.ByteArrayOutputStream();
                    byte[] buffer = new byte[8192];
                    int len;
                    while ((len = in.read(buffer)) != -1) {
                        bos.write(buffer, 0, len);
                    }
                    data = bos.toByteArray();
                }

                StudentDocument doc = new StudentDocument();
                doc.setStudentId(studentId);
                doc.setDocumentTypeId(typeId);
                doc.setFileName(submittedName);
                doc.setContentType(mime);
                doc.setFileSize(data.length);

                documentDAO.saveStudentDocument(doc, data);
                resp.sendRedirect(req.getContextPath() + "/student/documents?success=uploaded");

            } else if ("delete".equalsIgnoreCase(action)) {

                String typeIdStr = req.getParameter("documentTypeId");
                if (typeIdStr == null || typeIdStr.trim().isEmpty()) {
                    throw new IllegalArgumentException("Document type is required.");
                }
                int typeId = Integer.parseInt(typeIdStr);

                documentDAO.deleteStudentDocument(studentId, typeId);
                resp.sendRedirect(req.getContextPath() + "/student/documents?success=deleted");

            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action: " + action);
            }

        } catch (IllegalArgumentException e) {
            req.setAttribute("formError", e.getMessage());
            doGet(req, resp);
        } catch (Exception e) {
            req.setAttribute("formError", "Failed to process document operation: " + e.getMessage());
            doGet(req, resp);
        }
    }
}

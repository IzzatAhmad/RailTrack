package com.railtrack.system.controller;

import com.railtrack.system.dao.DocumentDAO;
import com.railtrack.system.model.DocumentType;
import com.railtrack.system.model.StudentDocument;
import com.railtrack.system.service.AuthService;
import com.railtrack.system.service.NotificationService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/coordinator/documents")
public class CoordinatorDocumentsServlet extends HttpServlet {

    private final DocumentDAO         documentDAO         = new DocumentDAO();
    private final NotificationService notificationService = new NotificationService();

    // ── GET ───────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer coordinatorId = AuthService.getSessionUserId(req);
        if (coordinatorId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            List<DocumentType>    types   = documentDAO.findAllDocumentTypes();
            List<StudentDocument> uploads = documentDAO.findAllStudentDocuments();

            req.setAttribute("documentTypes",  types);
            req.setAttribute("studentUploads", uploads);
            req.setAttribute("notif", notificationService.getCoordinatorCounts());

            req.getRequestDispatcher("/views/coordinator/documents.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error loading coordinator documents portal", e);
        }
    }

    // ── POST ──────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer coordinatorId = AuthService.getSessionUserId(req);
        if (coordinatorId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action parameter is required.");
            return;
        }

        try {
            switch (action.toLowerCase()) {

                case "add_type": {
                    String name        = req.getParameter("name");
                    String keyCode     = req.getParameter("keyCode");
                    String description = req.getParameter("description");

                    if (name == null || name.trim().isEmpty() ||
                        keyCode == null || keyCode.trim().isEmpty()) {
                        throw new IllegalArgumentException("Name and Key Code are required fields.");
                    }

                    DocumentType existing = documentDAO.findDocumentTypeByKeyCode(
                            keyCode.trim().toLowerCase());
                    if (existing != null) {
                        throw new IllegalArgumentException("Document Key Code must be unique.");
                    }

                    DocumentType type = new DocumentType();
                    type.setName(name.trim());
                    type.setKeyCode(keyCode.trim().toLowerCase());
                    type.setDescription(description != null ? description.trim() : null);

                    documentDAO.saveDocumentType(type);
                    resp.sendRedirect(req.getContextPath() +
                            "/coordinator/documents?success=type_added");
                    break;
                }

                case "edit_type": {
                    String idStr       = req.getParameter("id");
                    String name        = req.getParameter("name");
                    String keyCode     = req.getParameter("keyCode");
                    String description = req.getParameter("description");

                    if (idStr == null || name == null || name.trim().isEmpty() ||
                        keyCode == null || keyCode.trim().isEmpty()) {
                        throw new IllegalArgumentException("Invalid ID, Name or Key Code.");
                    }

                    int typeId = Integer.parseInt(idStr);
                    DocumentType type = documentDAO.findDocumentTypeById(typeId);
                    if (type == null) {
                        throw new IllegalArgumentException("Document template not found.");
                    }

                    String cleanedCode = keyCode.trim().toLowerCase();
                    if (!type.getKeyCode().equals(cleanedCode)) {
                        DocumentType existing =
                                documentDAO.findDocumentTypeByKeyCode(cleanedCode);
                        if (existing != null) {
                            throw new IllegalArgumentException(
                                    "Document Key Code must be unique.");
                        }
                    }

                    type.setName(name.trim());
                    type.setKeyCode(cleanedCode);
                    type.setDescription(description != null ? description.trim() : null);

                    documentDAO.saveDocumentType(type);
                    resp.sendRedirect(req.getContextPath() +
                            "/coordinator/documents?success=type_updated");
                    break;
                }

                case "delete_type": {
                    String idStr = req.getParameter("id");
                    if (idStr == null) {
                        throw new IllegalArgumentException("ID is required.");
                    }
                    int typeId = Integer.parseInt(idStr);
                    // Cascade in DB deletes associated student_documents automatically
                    documentDAO.deleteDocumentType(typeId);
                    resp.sendRedirect(req.getContextPath() +
                            "/coordinator/documents?success=type_deleted");
                    break;
                }

                case "delete_upload": {
                    String idStr = req.getParameter("id");
                    if (idStr == null) {
                        throw new IllegalArgumentException("Upload ID is required.");
                    }
                    int uploadId = Integer.parseInt(idStr);
                    // Simply delete the row — BLOB is deleted with it
                    documentDAO.deleteStudentDocumentById(uploadId);
                    resp.sendRedirect(req.getContextPath() +
                            "/coordinator/documents?success=upload_deleted");
                    break;
                }

                default:
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                            "Unknown action: " + action);
            }

        } catch (IllegalArgumentException e) {
            req.setAttribute("formError", e.getMessage());
            doGet(req, resp);
        } catch (Exception e) {
            req.setAttribute("formError", "Failed to process operation: " + e.getMessage());
            doGet(req, resp);
        }
    }
}

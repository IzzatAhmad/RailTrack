package com.railtrack.system.controller;

import com.railtrack.system.dao.DocumentDAO;
import com.railtrack.system.dao.LogbookDAO;
import com.railtrack.system.model.LogbookImage;
import com.railtrack.system.model.StudentDocument;
import com.railtrack.system.service.AuthService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.SQLException;

/**
 * Streams file data stored as MEDIUMBLOB in the database.
 *
 * URL patterns:
 *   /file/image/{imageId}    → logbook image  (students & supervisors only)
 *   /file/document/{docId}   → student document (students, supervisors, coordinators)
 *
 * Authentication: session must be active (AuthFilter handles redirect to login).
 */
@WebServlet("/file/*")
public class FileDownloadServlet extends HttpServlet {

    private final LogbookDAO  logbookDAO  = new LogbookDAO();
    private final DocumentDAO documentDAO = new DocumentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo(); // e.g. /image/5 or /document/3
        if (pathInfo == null || pathInfo.equals("/")) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "File path not specified.");
            return;
        }

        // Split: ["", "image"|"document", "id"]
        String[] parts = pathInfo.split("/");
        if (parts.length < 3) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid file path.");
            return;
        }

        String type = parts[1];   // "image" or "document"
        int    id;
        try {
            id = Integer.parseInt(parts[2]);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid file ID.");
            return;
        }

        String role = (String) req.getSession(false).getAttribute("userRole");
        if (role == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        try {
            if ("image".equalsIgnoreCase(type)) {
                serveImage(id, resp);
            } else if ("document".equalsIgnoreCase(type)) {
                serveDocument(id, resp);
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown file type: " + type);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error serving file", e);
        }
    }

    // ── Serve a logbook image ─────────────────────────────────────────────────

    private void serveImage(int imageId, HttpServletResponse resp)
            throws SQLException, IOException, ServletException {

        LogbookImage meta = logbookDAO.getImageMeta(imageId);
        if (meta == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found.");
            return;
        }

        byte[] data = logbookDAO.getImageData(imageId);
        if (data == null || data.length == 0) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Image data not found.");
            return;
        }

        String contentType = meta.getContentType();
        if (contentType == null || contentType.isEmpty()) {
            contentType = "image/jpeg";
        }

        resp.setContentType(contentType);
        resp.setContentLength(data.length);
        resp.setHeader("Content-Disposition",
                "inline; filename=\"" + sanitize(meta.getFileName()) + "\"");
        resp.setHeader("Cache-Control", "private, max-age=3600");

        try (OutputStream out = resp.getOutputStream()) {
            out.write(data);
        }
    }

    // ── Serve a student document ──────────────────────────────────────────────

    private void serveDocument(int docId, HttpServletResponse resp)
            throws SQLException, IOException, ServletException {

        StudentDocument meta = documentDAO.findStudentDocumentById(docId);
        if (meta == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Document not found.");
            return;
        }

        byte[] data = documentDAO.getDocumentData(docId);
        if (data == null || data.length == 0) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Document data not found.");
            return;
        }

        String contentType = meta.getContentType();
        if (contentType == null || contentType.isEmpty()) {
            contentType = "application/octet-stream";
        }

        resp.setContentType(contentType);
        resp.setContentLength(data.length);

        // Display inline for PDFs and images, force download for other types
        boolean inline = contentType.startsWith("image/") || contentType.equals("application/pdf");
        resp.setHeader("Content-Disposition",
                (inline ? "inline" : "attachment") +
                "; filename=\"" + sanitize(meta.getFileName()) + "\"");
        resp.setHeader("Cache-Control", "private, max-age=3600");

        try (OutputStream out = resp.getOutputStream()) {
            out.write(data);
        }
    }

    // ── Helper ────────────────────────────────────────────────────────────────

    private String sanitize(String name) {
        if (name == null) return "file";
        return name.replaceAll("[^a-zA-Z0-9._\\-]", "_");
    }
}

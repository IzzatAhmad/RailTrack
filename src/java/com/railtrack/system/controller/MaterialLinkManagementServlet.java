package com.railtrack.system.controller;

import com.railtrack.system.dao.MaterialLinkDAO;
import com.railtrack.system.model.MaterialLink;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.annotation.MultipartConfig;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.SQLException;

@WebServlet("/coordinator/material-links")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 10 * 1024 * 1024,
        maxRequestSize = 12 * 1024 * 1024
)
public class MaterialLinkManagementServlet extends HttpServlet {

    private final MaterialLinkDAO dao = new MaterialLinkDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("materialLinks", dao.findAll());
            req.setAttribute("pageTitle", "Material Links");
            req.getRequestDispatcher("/views/coordinator/material_links.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Failed to load material links", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            if ("add".equals(action)) {
                MaterialLink link = readLink(req);
                dao.insert(link);
            } else if ("edit".equals(action)) {
                int id = parseInt(req.getParameter("id"), 0);
                MaterialLink link = dao.findById(id);
                if (link != null) {
                    MaterialLink edited = readLink(req);
                    edited.setId(id);
                    dao.update(edited);
                }
            } else if ("toggle".equals(action)) {
                int id = parseInt(req.getParameter("id"), 0);
                dao.toggleEnabled(id, "1".equals(req.getParameter("enabled")));
            } else if ("delete".equals(action)) {
                int id = parseInt(req.getParameter("id"), 0);
                dao.delete(id);
            }
        } catch (SQLException e) {
            throw new ServletException("Failed to manage material link", e);
        }

        resp.sendRedirect(req.getContextPath() + "/materials?success=1");
    }

    private MaterialLink readLink(HttpServletRequest req) throws IOException, ServletException {
        MaterialLink link = new MaterialLink();
        link.setSection(sanitize(req.getParameter("section")));
        link.setTitle(sanitize(req.getParameter("title")));
        link.setUrl(resolveMaterialUrl(req));
        link.setSortOrder(parseInt(req.getParameter("sort_order"), 99));
        link.setEnabled("1".equals(req.getParameter("is_enabled")));
        return link;
    }

    private String resolveMaterialUrl(HttpServletRequest req) throws IOException, ServletException {
        Part pdf = req.getPart("pdf_file");
        if (pdf != null && pdf.getSize() > 0) {
            return savePdf(pdf);
        }
        String url = sanitize(req.getParameter("url"));
        if (url.isEmpty()) {
            throw new ServletException("Please enter a URL or upload a PDF.");
        }
        return url;
    }

    private String savePdf(Part pdf) throws IOException, ServletException {
        String submittedName = Paths.get(pdf.getSubmittedFileName()).getFileName().toString();
        if (!submittedName.toLowerCase().endsWith(".pdf")) {
            throw new ServletException("Only PDF files can be uploaded for material links.");
        }

        String baseName = submittedName.substring(0, submittedName.length() - 4)
                .replaceAll("[^A-Za-z0-9_-]+", "-")
                .replaceAll("^-+|-+$", "");
        if (baseName.isEmpty()) {
            baseName = "material";
        }

        String fileName = baseName + "-" + System.currentTimeMillis() + ".pdf";
        String uploadPath = getServletContext().getRealPath("/uploads/materials");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists() && !uploadDir.mkdirs()) {
            throw new IOException("Unable to create upload directory: " + uploadPath);
        }

        pdf.write(new File(uploadDir, fileName).getAbsolutePath());
        return "/uploads/materials/" + fileName;
    }

    private String sanitize(String value) {
        return value == null ? "" : value.trim();
    }

    private int parseInt(String value, int fallback) {
        try { return Integer.parseInt(value); }
        catch (NumberFormatException e) { return fallback; }
    }
}

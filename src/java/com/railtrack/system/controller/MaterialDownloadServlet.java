package com.railtrack.system.controller;

import com.railtrack.system.dao.MaterialLinkDAO;
import com.railtrack.system.model.MaterialLink;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.SQLException;

@WebServlet("/material-download")
public class MaterialDownloadServlet extends HttpServlet {

    private final MaterialLinkDAO dao = new MaterialLinkDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing material ID");
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            MaterialLink link = dao.getFileData(id);

            if (link == null || link.getFileData() == null || link.getFileData().length == 0) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found in database");
                return;
            }

            resp.setContentType(link.getFileType() != null ? link.getFileType() : "application/pdf");
            resp.setHeader("Content-Disposition", "inline; filename=\"" + (link.getFileName() != null ? link.getFileName() : "material.pdf") + "\"");
            resp.setContentLength(link.getFileData().length);

            try (OutputStream out = resp.getOutputStream()) {
                out.write(link.getFileData());
            }
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid material ID");
        } catch (SQLException e) {
            throw new ServletException("Database error retrieving file", e);
        }
    }
}

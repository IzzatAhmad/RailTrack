package com.railtrack.system.controller;

import com.railtrack.system.dao.MaterialLinkDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/materials")
public class MaterialsServlet extends HttpServlet {

    private final MaterialLinkDAO dao = new MaterialLinkDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String role = session == null ? null : (String) session.getAttribute("userRole");
        boolean canManageMaterials = "COORDINATOR".equals(role);

        if (session == null || (!"STUDENT".equals(role) && !canManageMaterials)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            req.setAttribute("materialLinks", canManageMaterials ? dao.findAll() : dao.findEnabled());
            req.setAttribute("canManageMaterials", canManageMaterials);
            req.setAttribute("pageTitle", "FYP Materials");
            req.getRequestDispatcher("/views/student/materials.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Failed to load material links", e);
        }
    }
}

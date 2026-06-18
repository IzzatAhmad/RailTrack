/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.railtrack.system.controller;

import com.railtrack.system.dao.MenuItemDAO;
import com.railtrack.system.model.MenuItem;
 
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
/**
 *
 * @author izzat
 */
@WebServlet("/coordinator/menu")
public class MenuManagementServlet extends HttpServlet {
 
    private final MenuItemDAO dao = new MenuItemDAO();
 
    // ── Auth guard ───────────────────────────────────────────────────────
    private boolean isCoordinator(HttpSession s) {
        return "COORDINATOR".equals(s.getAttribute("userRole"));
    }
 
    // ── GET ──────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        HttpSession session = req.getSession(false);
        if (session == null || !isCoordinator(session)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
 
        try {
            List<MenuItem> items = dao.findAll();
            req.setAttribute("menuItems", items);
            req.setAttribute("pageTitle", "Student Menu Management");
            req.getRequestDispatcher("/views/coordinator/menu_management.jsp")
               .forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("DB error loading menu items", e);
        }
    }
 
    // ── POST ─────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        HttpSession session = req.getSession(false);
        if (session == null || !isCoordinator(session)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
 
        String action = req.getParameter("action");
        String ctx    = req.getContextPath();
 
        try {
            switch (action == null ? "" : action) {
 
                case "add": {
                    MenuItem m = new MenuItem();
                    m.setItemKey  (sanitize(req.getParameter("item_key")));
                    m.setLabel    (sanitize(req.getParameter("label")));
                    m.setIcon     (sanitize(req.getParameter("icon")));
                    m.setIconColor(sanitize(req.getParameter("icon_color")));
                    m.setUrl      (sanitize(req.getParameter("url")));
                    m.setSortOrder(parseInt(req.getParameter("sort_order"), 99));
                    m.setEnabled  ("1".equals(req.getParameter("is_enabled")));
                    dao.insert(m);
                    break;
                }
 
                case "edit": {
                    int id = parseInt(req.getParameter("id"), 0);
                    MenuItem m = dao.findById(id);
                    if (m != null) {
                        m.setLabel    (sanitize(req.getParameter("label")));
                        m.setIcon     (sanitize(req.getParameter("icon")));
                        m.setIconColor(sanitize(req.getParameter("icon_color")));
                        m.setUrl      (sanitize(req.getParameter("url")));
                        m.setSortOrder(parseInt(req.getParameter("sort_order"), m.getSortOrder()));
                        m.setEnabled  ("1".equals(req.getParameter("is_enabled")));
                        dao.update(m);
                    }
                    break;
                }
 
                case "toggle": {
                    int    id      = parseInt(req.getParameter("id"), 0);
                    boolean enable = "1".equals(req.getParameter("enabled"));
                    dao.toggleEnabled(id, enable);
                    break;
                }
 
                case "delete": {
                    int id = parseInt(req.getParameter("id"), 0);
                    dao.delete(id);
                    break;
                }
            }
        } catch (SQLException e) {
            throw new ServletException("DB error on menu action: " + action, e);
        }
 
        resp.sendRedirect(ctx + "/coordinator/menu?success=1");
    }
 
    // ── Helpers ──────────────────────────────────────────────────────────
    private String sanitize(String v) {
        return v == null ? "" : v.trim();
    }
 
    private int parseInt(String v, int fallback) {
        try { return Integer.parseInt(v); }
        catch (NumberFormatException e) { return fallback; }
    }
}

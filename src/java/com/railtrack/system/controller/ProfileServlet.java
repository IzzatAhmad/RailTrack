/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.controller;

import com.railtrack.system.dao.UserDAO;
import com.railtrack.system.model.User;
import com.railtrack.system.service.AuthService;
 
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

/**
 *
 * @author izzat
 */
@WebServlet(urlPatterns = {
        "/student/profile",
        "/supervisor/profile",
        "/coordinator/profile"
})
public class ProfileServlet extends HttpServlet {
 
    private final UserDAO     userDAO     = new UserDAO();
    private final AuthService authService = new AuthService();
 
    // ── GET ───────────────────────────────────────────────────────────────────
 
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        int userId = AuthService.getSessionUserId(req);
 
        try {
            User user = userDAO.findById(userId);
            req.setAttribute("user", user);
            req.getRequestDispatcher("/views/common/profile.jsp").forward(req, resp);
 
        } catch (SQLException e) {
            throw new ServletException("Failed to load profile", e);
        }
    }
 
    // ── POST ──────────────────────────────────────────────────────────────────
 
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        int    userId = AuthService.getSessionUserId(req);
        String action = req.getParameter("action");
        String rolePath = rolePath(AuthService.getSessionUserRole(req));
 
        try {
            if ("password".equals(action)) {
                String current = req.getParameter("currentPassword");
                String newPw   = req.getParameter("newPassword");
                String confirm = req.getParameter("confirmPassword");
 
                if (!newPw.equals(confirm)) {
                    req.setAttribute("formError", "New passwords do not match.");
                    doGet(req, resp);
                    return;
                }
 
                authService.changePassword(userId, current, newPw);
                resp.sendRedirect(req.getContextPath() + rolePath + "/profile?success=password");
 
            } else {
                // Update basic info
                User user = userDAO.findById(userId);
                if (!user.isStudent()) {
                    user.setFullName(req.getParameter("fullName"));
                    user.setEmail(req.getParameter("email"));
                    user.setPhone(req.getParameter("phone"));
                    user.setDepartment(req.getParameter("department"));
                }
                
                // Read notification settings
                user.setEmailNotifEnabled(req.getParameter("emailNotifEnabled") != null);
                
                userDAO.update(user);
 
                // Refresh display name in session
                req.getSession().setAttribute("userName", user.getDisplayName());
 
                resp.sendRedirect(req.getContextPath() + rolePath + "/profile?success=updated");
            }
 
        } catch (IllegalArgumentException e) {
            req.setAttribute("formError", e.getMessage());
            doGet(req, resp);
 
        } catch (SQLException e) {
            throw new ServletException("Failed to update profile", e);
        }
    }
 
    private String rolePath(String role) {
        if (role == null) return "/student";
        switch (role) {
            case "SUPERVISOR":  return "/supervisor";
            case "COORDINATOR": return "/coordinator";
            default:            return "/student";
        }
    }
}
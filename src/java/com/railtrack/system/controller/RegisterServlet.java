package com.railtrack.system.controller;

import com.railtrack.system.model.User;
import com.railtrack.system.service.AuthService;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * Handles self-registration for new users (STUDENT or SUPERVISOR only).
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    // ── GET ─────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // If already logged in → redirect home/dashboard
        if (AuthService.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        // Redirect to landing page (modal-based UI)
        resp.sendRedirect(req.getContextPath() + "/");
    }

    // ── POST ────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String ctx = req.getContextPath();

        String username   = req.getParameter("username");
        String password   = req.getParameter("password");
        String confirm    = req.getParameter("confirmPassword");
        String fullName   = req.getParameter("fullName");
        String email      = req.getParameter("email");
        String department = req.getParameter("department");
        String roleStr    = req.getParameter("role");

        try {
            // ── Password check ──
            if (password == null || !password.equals(confirm)) {
                redirectError(resp, ctx, "Passwords do not match");
                return;
            }

            // ── Role validation ──
            User.Role role;
            try {
                role = User.Role.valueOf(roleStr);
                if (role == User.Role.COORDINATOR) {
                    redirectError(resp, ctx,
                            "Coordinator accounts must be created by admin");
                    return;
                }
            } catch (Exception e) {
                role = User.Role.STUDENT;
            }

            // ── Register user ──
            authService.register(username, password, fullName, email, department, role);

            // ── SUCCESS ──
            resp.sendRedirect(ctx + "/?msg=registered");

        } catch (IllegalArgumentException e) {
            redirectError(resp, ctx, e.getMessage());

        } catch (SQLException e) {
            getServletContext().log("Registration error", e);
            redirectError(resp, ctx, "Database error. Please try again.");
        }
    }

    // ── Helper: Redirect with encoded message ────────────
    private void redirectError(HttpServletResponse resp, String ctx, String message)
            throws IOException {

        String encoded = URLEncoder.encode(message, StandardCharsets.UTF_8.toString());
        resp.sendRedirect(ctx + "/?error=reg_error&msg=" + encoded);
    }
}
package com.railtrack.system.controller;

import com.railtrack.system.dao.UserDAO;
import com.railtrack.system.service.AuthService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Lightweight endpoint called by the frontend every 2 minutes via AJAX.
 * Updates last_activity = NOW() for the logged-in user so that
 * isOnline() (last_activity > NOW() - 5 min) stays true while the
 * browser tab is open and naturally expires when it closes.
 *
 * URL: POST /heartbeat
 */
@WebServlet("/heartbeat")
public class HeartbeatServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer userId = AuthService.getSessionUserId(req);
        if (userId == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        userDAO.updateLastActivity(userId);
        resp.setStatus(HttpServletResponse.SC_NO_CONTENT); // 204 – success, no body
    }

    // Also handle GET so browser preflight or tab-restore doesn't break
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doPost(req, resp);
    }
}

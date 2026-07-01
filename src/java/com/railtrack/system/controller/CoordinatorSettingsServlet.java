package com.railtrack.system.controller;

import com.railtrack.system.dao.SystemSettingsDAO;
import com.railtrack.system.service.AuthService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/coordinator/settings")
public class CoordinatorSettingsServlet extends HttpServlet {

    private final SystemSettingsDAO settingsDAO = new SystemSettingsDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer coordinatorId = AuthService.getSessionUserId(req);
        if (coordinatorId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            String semesterStart = settingsDAO.getSetting("semester_start_date", "");
            String semesterEnd = settingsDAO.getSetting("semester_end_date", "");

            req.setAttribute("semester_start_date", semesterStart);
            req.setAttribute("semester_end_date", semesterEnd);

            req.getRequestDispatcher("/views/coordinator/system_settings.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error loading system settings", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer coordinatorId = AuthService.getSessionUserId(req);
        if (coordinatorId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String semesterStart = req.getParameter("semester_start_date");
        String semesterEnd = req.getParameter("semester_end_date");

        try {
            if (semesterStart != null) {
                settingsDAO.setSetting("semester_start_date", semesterStart.trim());
            }
            if (semesterEnd != null) {
                settingsDAO.setSetting("semester_end_date", semesterEnd.trim());
            }

            resp.sendRedirect(req.getContextPath() + "/coordinator/settings?success=updated");

        } catch (SQLException e) {
            req.setAttribute("formError", "Failed to update system settings.");
            doGet(req, resp);
        }
    }
}

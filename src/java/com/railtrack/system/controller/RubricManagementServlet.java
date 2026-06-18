package com.railtrack.system.controller;

import com.railtrack.system.dao.RubricDAO;
import com.railtrack.system.model.Rubric;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/coordinator/rubrics-manage")
public class RubricManagementServlet extends HttpServlet {

    private RubricDAO rubricDAO;

    @Override
    public void init() throws ServletException {
        rubricDAO = new RubricDAO();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"COORDINATOR".equals(session.getAttribute("userRole"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        String action = req.getParameter("action");
        try {
            if ("add".equals(action)) {
                Rubric rubric = new Rubric();
                rubric.setSection(req.getParameter("section"));
                rubric.setTitle(req.getParameter("title"));
                rubric.setContent(req.getParameter("content"));
                rubric.setSortOrder(Integer.parseInt(req.getParameter("sort_order")));
                rubric.setEnabled("1".equals(req.getParameter("is_enabled")));
                rubricDAO.insert(rubric);
            } else if ("edit".equals(action)) {
                Rubric rubric = new Rubric();
                rubric.setId(Integer.parseInt(req.getParameter("id")));
                rubric.setSection(req.getParameter("section"));
                rubric.setTitle(req.getParameter("title"));
                rubric.setContent(req.getParameter("content"));
                rubric.setSortOrder(Integer.parseInt(req.getParameter("sort_order")));
                rubric.setEnabled("1".equals(req.getParameter("is_enabled")));
                rubricDAO.update(rubric);
            } else if ("toggle".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean enabled = "1".equals(req.getParameter("enabled"));
                rubricDAO.toggleEnabled(id, enabled);
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                rubricDAO.delete(id);
            }
            resp.sendRedirect(req.getContextPath() + "/rubrics?success=1");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error processing rubric action");
        }
    }
}

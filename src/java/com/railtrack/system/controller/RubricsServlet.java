package com.railtrack.system.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import com.railtrack.system.dao.RubricDAO;
import com.railtrack.system.model.Rubric;

@WebServlet("/rubrics")
public class RubricsServlet extends HttpServlet {

    private RubricDAO rubricDAO;

    @Override
    public void init() throws ServletException {
        rubricDAO = new RubricDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String role = session == null ? null : (String) session.getAttribute("userRole");

        if (session == null || (!"STUDENT".equals(role) && !"COORDINATOR".equals(role))) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            List<Rubric> rubrics = rubricDAO.findAll();
            if (!rubrics.isEmpty()) {
                req.setAttribute("rubric", rubrics.get(0));
            }
            req.setAttribute("canManageRubrics", "COORDINATOR".equals(role));
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load rubrics.");
        }

        req.setAttribute("pageTitle", "Rubrics");
        req.getRequestDispatcher("/views/student/rubrics.jsp").forward(req, resp);
    }
}

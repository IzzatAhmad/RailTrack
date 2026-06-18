/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.controller;

import com.railtrack.system.service.AuthService;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 *
 * @author izzat
 */
@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        authService.logout(req);
        resp.sendRedirect(req.getContextPath() + "/?msg=logged_out");
    }
}
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.controller;

import com.railtrack.system.service.AuthService;
 
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;
 

/**
 *
 * @author izzat
 */
@WebFilter(urlPatterns = {"/student/*", "/supervisor/*", "/coordinator/*", "/materials", "/rubrics", "/students/list"})
public class AuthFilter implements Filter {
 
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
 
        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;
 
        // Set Cache-Control headers to prevent browser caching of protected pages
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        response.setHeader("Pragma", "no-cache"); // HTTP 1.0
        response.setDateHeader("Expires", 0); // Proxies
 
        String ctx  = request.getContextPath();
        String path = request.getServletPath();
 
        // Not logged in → login page
        if (!AuthService.isLoggedIn(request)) {
            response.sendRedirect(ctx + "/login");
            return;
        }
 
        String role = AuthService.getSessionUserRole(request);
 
        // Wrong role → redirect to own dashboard
        if (path.startsWith("/student/")     && !"STUDENT".equals(role)) {
            response.sendRedirect(ctx + dashboardFor(role));
            return;
        }
        if (path.startsWith("/supervisor/")  && !"SUPERVISOR".equals(role)) {
            response.sendRedirect(ctx + dashboardFor(role));
            return;
        }
        if (path.startsWith("/coordinator/") && !"COORDINATOR".equals(role)) {
            response.sendRedirect(ctx + dashboardFor(role));
            return;
        }
        chain.doFilter(req, res);
    }
 
    private String dashboardFor(String role) {
        if (role == null) return "/login";
        switch (role) {
            case "STUDENT":     return "/student/dashboard";
            case "SUPERVISOR":  return "/supervisor/dashboard";
            case "COORDINATOR": return "/coordinator/dashboard";
            default:            return "/login";
        }
    }
 
    @Override public void init(FilterConfig fc) {}
    @Override public void destroy() {}
}

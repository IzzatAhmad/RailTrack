/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.controller;

import com.railtrack.system.model.User;
import com.railtrack.system.service.AuthService;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 *
 * @author izzat
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
 
    private final AuthService authService = new AuthService();
 
    // ── GET ───────────────────────────────────────────────────────────────────
 
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        // Already logged in → redirect to dashboard
        if (AuthService.isLoggedIn(req)) {
            resp.sendRedirect(dashboardUrl(req));
            return;
        }
 
        resp.sendRedirect(req.getContextPath() + "/?action=login");
    }
 
    // ── POST ──────────────────────────────────────────────────────────────────
 
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {
 
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String recaptchaResponse = req.getParameter("g-recaptcha-response");

        // Google reCAPTCHA Validation
        if (recaptchaResponse == null || recaptchaResponse.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/?error=captcha");
            return;
        }

        try {
            String secret = "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe";
            java.net.URL url = new java.net.URL("https://www.google.com/recaptcha/api/siteverify");
            java.net.HttpURLConnection con = (java.net.HttpURLConnection) url.openConnection();
            con.setRequestMethod("POST");
            con.setDoOutput(true);

            String postParams = "secret=" + secret + "&response=" + recaptchaResponse;
            java.io.OutputStream os = con.getOutputStream();
            os.write(postParams.getBytes());
            os.flush();
            os.close();

            java.io.BufferedReader in = new java.io.BufferedReader(new java.io.InputStreamReader(con.getInputStream()));
            String inputLine;
            StringBuilder responseStr = new StringBuilder();
            while ((inputLine = in.readLine()) != null) {
                responseStr.append(inputLine);
            }
            in.close();

            if (!responseStr.toString().contains("\"success\": true")) {
                resp.sendRedirect(req.getContextPath() + "/?error=captcha");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/?error=system");
            return;
        }

        try {
            User user = authService.login(req, username, password);
 
            if (user == null) {
                resp.sendRedirect(req.getContextPath() + "/?error=invalid");
                return;
            }
 
            resp.sendRedirect(dashboardUrl(req));
 
        } catch (IllegalArgumentException e) {
            String encoded = java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8.toString());
            resp.sendRedirect(req.getContextPath() + "/?error=" + encoded);
 
        } catch (Exception e) {
            e.printStackTrace();
            getServletContext().log("Login error", e);
            resp.sendRedirect(req.getContextPath() + "/?error=system");
        }
    }
 
    // ── Helper ────────────────────────────────────────────────────────────────
 
    private String dashboardUrl(HttpServletRequest req) {
        String ctx  = req.getContextPath();
        String role = AuthService.getSessionUserRole(req);
        if (role == null) return ctx + "/login";
        switch (role) {
            case "STUDENT":     return ctx + "/student/dashboard";
            case "SUPERVISOR":  return ctx + "/supervisor/dashboard";
            case "COORDINATOR": return ctx + "/coordinator/dashboard";
            default:            return ctx + "/login";
        }
    }
}
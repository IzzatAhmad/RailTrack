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

        if (!verifyRecaptcha(recaptchaResponse)) {
            resp.sendRedirect(req.getContextPath() + "/?error=recaptcha");
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
 
    private boolean verifyRecaptcha(String recaptchaResponse) {
        if (recaptchaResponse == null || recaptchaResponse.isEmpty()) {
            return false;
        }
        try {
            // Read from environment variable, fallback to test key if not set
            String secret = System.getenv("RECAPTCHA_SECRET");
            if (secret == null || secret.isEmpty()) {
                secret = "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"; // Public test key
            }
            java.net.URL url = new java.net.URL("https://www.google.com/recaptcha/api/siteverify");
            java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            String postParams = "secret=" + secret + "&response=" + recaptchaResponse;
            try (java.io.OutputStream os = conn.getOutputStream()) {
                os.write(postParams.getBytes());
                os.flush();
            }
            if (conn.getResponseCode() == java.net.HttpURLConnection.HTTP_OK) {
                try (java.io.BufferedReader in = new java.io.BufferedReader(new java.io.InputStreamReader(conn.getInputStream()))) {
                    String inputLine;
                    StringBuilder response = new StringBuilder();
                    while ((inputLine = in.readLine()) != null) {
                        response.append(inputLine);
                    }
                    return response.toString().contains("\"success\": true");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
 
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
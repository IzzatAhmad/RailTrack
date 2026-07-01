package com.railtrack.system.controller;

import com.railtrack.system.service.AuthService;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * Handles two sub-actions for password reset:
 *
 * <ul>
 *   <li>POST action=request_reset : user submits their email → generates a token,
 *       sends email, and redirects back with ?msg=reset_sent</li>
 *   <li>POST action=do_reset      : user submits token + new password → resets
 *       the password and redirects to login with ?msg=password_reset</li>
 *   <li>GET  (with ?token=…)      : shows the "set new password" form</li>
 * </ul>
 */
@WebServlet("/reset-password")
public class PasswordResetServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    // ── GET ───────────────────────────────────────────────────────────────────

    /**
     * Renders the "Set New Password" form if a valid token is present,
     * otherwise redirects to the login page.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String token = req.getParameter("token");
        if (token == null || token.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/?error=invalid_reset_link");
            return;
        }
        // Pass token through to the JSP (rendered inline in index.jsp via ?action=reset_form)
        resp.sendRedirect(req.getContextPath() + "/?action=reset_form&token=" +
                java.net.URLEncoder.encode(token, "UTF-8"));
    }

    // ── POST ──────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("request_reset".equals(action)) {
            handleRequestReset(req, resp);
        } else if ("do_reset".equals(action)) {
            handleDoReset(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/");
        }
    }

    // ── Request reset (email submission) ─────────────────────────────────────

    private void handleRequestReset(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String email = req.getParameter("email");
        String ctx   = req.getContextPath();
        String recaptchaResponse = req.getParameter("g-recaptcha-response");

        if (!verifyRecaptcha(recaptchaResponse)) {
            resp.sendRedirect(ctx + "/?error=recaptcha");
            return;
        }

        // Derive the app base URL from the request
        String appBase = req.getScheme() + "://" + req.getServerName()
                + (req.getServerPort() == 80 || req.getServerPort() == 443
                    ? "" : ":" + req.getServerPort())
                + ctx;

        try {
            authService.generatePasswordResetToken(email, appBase);
        } catch (Exception e) {
            // Log for server-side debugging, but always show the same message
            // to the user — prevents email enumeration attacks.
            getServletContext().log("Password reset request (non-fatal): " + e.getMessage(), e);
        }

        // Always redirect to "sent" — never reveal whether the email exists
        resp.sendRedirect(ctx + "/?msg=reset_sent&action=login");
    }

    private boolean verifyRecaptcha(String recaptchaResponse) {
        if (recaptchaResponse == null || recaptchaResponse.isEmpty()) {
            return false;
        }
        try {
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


    // ── Do reset (token + new password) ──────────────────────────────────────

    private void handleDoReset(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String token       = req.getParameter("token");
        String newPassword = req.getParameter("newPassword");
        String ctx         = req.getContextPath();

        try {
            authService.resetPasswordByToken(token, newPassword);
            resp.sendRedirect(ctx + "/?msg=password_reset&action=login");

        } catch (IllegalArgumentException e) {
            String encoded = java.net.URLEncoder.encode(e.getMessage(),
                    java.nio.charset.StandardCharsets.UTF_8.toString());
            resp.sendRedirect(ctx + "/?action=reset_form&token="
                    + java.net.URLEncoder.encode(token != null ? token : "", "UTF-8")
                    + "&error=" + encoded);

        } catch (Exception e) {
            e.printStackTrace();
            getServletContext().log("Password reset error", e);
            resp.sendRedirect(ctx + "/?error=system&action=login");
        }
    }
}

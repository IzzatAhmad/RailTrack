/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.service;
 
import com.railtrack.system.dao.UserDAO;
import com.railtrack.system.model.User;
import com.railtrack.system.util.PasswordUtil;
import com.railtrack.system.util.ValidationUtil;
 
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 *
 * @author izzat
 */
public class AuthService {
 
    private static final String SESSION_USER_ID      = "userId";
    private static final String SESSION_USER_NAME    = "userName";
    private static final String SESSION_USER_ROLE    = "userRole";
    private static final String SESSION_FAIL_COUNT   = "loginFailCount";
    /** Number of consecutive failed attempts before showing the reset-password offer. */
    public  static final int    MAX_FAILED_ATTEMPTS  = 3;
    /** Token validity window in minutes. */
    private static final int    RESET_TOKEN_MINUTES  = 30;
 
    private final UserDAO userDAO = new UserDAO();
 
    // ── Login / Logout ────────────────────────────────────────────────────────
 
    /**
     * Validates credentials, creates session, returns the authenticated User.
     * Returns null if credentials are invalid or account is inactive.
     * On failure, increments the session-based failed-attempt counter.
     */
    public User login(HttpServletRequest request, String username, String rawPassword)
            throws SQLException, IllegalArgumentException {
 
        if (ValidationUtil.isBlank(username) || ValidationUtil.isBlank(rawPassword))
            throw new IllegalArgumentException("Username and password are required.");
 
        User user = userDAO.authenticate(username.trim(), rawPassword);
        if (user == null) {
            // Track consecutive failures in the current session
            HttpSession failSession = request.getSession(true);
            int attempts = getFailedLoginAttempts(request) + 1;
            failSession.setAttribute(SESSION_FAIL_COUNT, attempts);
            return null;
        }
 
        // Successful login – clear failure counter, then rotate session
        HttpSession old = request.getSession(false);
        if (old != null) old.invalidate();
 
        HttpSession session = request.getSession(true);
        session.setAttribute(SESSION_USER_ID,   user.getId());
        session.setAttribute(SESSION_USER_NAME, user.getDisplayName());
        session.setAttribute(SESSION_USER_ROLE, user.getRole().name());
        session.setMaxInactiveInterval(60 * 60); // 1 hour
 
        return user;
    }
 
    /** Returns the number of consecutive failed login attempts in this session. */
    public static int getFailedLoginAttempts(HttpServletRequest request) {
        HttpSession s = request.getSession(false);
        if (s == null) return 0;
        Object v = s.getAttribute(SESSION_FAIL_COUNT);
        return v instanceof Integer ? (Integer) v : 0;
    }
 
    /** Resets the failed-attempt counter (called after a successful login). */
    public static void clearFailedLoginAttempts(HttpServletRequest request) {
        HttpSession s = request.getSession(false);
        if (s != null) s.removeAttribute(SESSION_FAIL_COUNT);
    }
 
    /**
     * Sets active = 0 for the user in DB, then invalidates the session.
     */
    public void logout(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Integer userId = (Integer) session.getAttribute(SESSION_USER_ID);
            if (userId != null) {
                try {
                    userDAO.updateActiveTurn(userId, 0); // mark user as inactive/offline on logout
                } catch (java.sql.SQLException e) {
                    // Log and continue — session must still be invalidated
                    e.printStackTrace();
                }
            }
            session.invalidate();
        }
    }
 
    // ── Session helpers ───────────────────────────────────────────────────────
 
    public static Integer getSessionUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (Integer) session.getAttribute(SESSION_USER_ID);
    }
 
    public static String getSessionUserRole(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (String) session.getAttribute(SESSION_USER_ROLE);
    }
 
    public static boolean isLoggedIn(HttpServletRequest request) {
        return getSessionUserId(request) != null;
    }
 
    public static boolean hasRole(HttpServletRequest request, String role) {
        return role.equalsIgnoreCase(getSessionUserRole(request));
    }

    public static boolean isStudent(HttpServletRequest request) {
        return "STUDENT".equalsIgnoreCase(getSessionUserRole(request));
    }

    public static boolean isSupervisor(HttpServletRequest request) {
        return "SUPERVISOR".equalsIgnoreCase(getSessionUserRole(request));
    }

    public static boolean isCoordinator(HttpServletRequest request) {
        return "COORDINATOR".equalsIgnoreCase(getSessionUserRole(request));
    }
 
    // ── Registration ──────────────────────────────────────────────────────────
 
    /**
     * Registers a new user after validating all fields.
     *
     * @throws IllegalArgumentException with a user-facing message on failure
     */
    public User register(String username, String rawPassword, String fullName,
                         String email, String department, User.Role role)
            throws SQLException, IllegalArgumentException {
        return register(username, rawPassword, fullName, email, department, role, null);
    }

    public User register(String username, String rawPassword, String fullName,
                         String email, String department, User.Role role, Double cgpa)
            throws SQLException, IllegalArgumentException {

        if (!ValidationUtil.isValidUsername(username))
            throw new IllegalArgumentException(
                    "Username must be 3–30 characters (letters, digits, underscore).");

        if (!ValidationUtil.isStrongPassword(rawPassword))
            throw new IllegalArgumentException(
                    "Password must be at least 8 characters with uppercase, lowercase, and digit.");

        if (!ValidationUtil.isValidEmail(email))
            throw new IllegalArgumentException("Invalid email address.");

        if (ValidationUtil.isBlank(fullName))
            throw new IllegalArgumentException("Full name is required.");

        if (userDAO.usernameExists(username))
            throw new IllegalArgumentException("Username '" + username + "' is already taken.");

        if (userDAO.emailExists(email))
            throw new IllegalArgumentException("Email is already registered.");

        if (role == User.Role.STUDENT && cgpa != null) {
            if (cgpa < 0.0 || cgpa > 4.0) {
                throw new IllegalArgumentException("CGPA must be between 0.00 and 4.00.");
            }
        }

        User user = new User();
        user.setUsername(username.trim());
        user.setPasswordHash(PasswordUtil.hash(rawPassword));
        user.setFullName(ValidationUtil.sanitise(fullName));
        user.setEmail(email.trim().toLowerCase());
        user.setDepartment(ValidationUtil.sanitise(department));
        user.setCgpa(role == User.Role.STUDENT ? cgpa : null);
        user.setRole(role);
        user.setActive(true);

        userDAO.insert(user);
        return user;
    }
 
    // ── Password change ───────────────────────────────────────────────────────
 
    /**
     * Changes a user's password after verifying the current one.
     */
    public void changePassword(int userId, String currentPassword, String newPassword)
            throws SQLException, IllegalArgumentException {
 
        User user = userDAO.findById(userId);
        if (user == null)
            throw new IllegalArgumentException("User not found.");
 
        if (!PasswordUtil.verify(currentPassword, user.getPasswordHash()))
            throw new IllegalArgumentException("Current password is incorrect.");
 
        if (!ValidationUtil.isStrongPassword(newPassword))
            throw new IllegalArgumentException(
                    "New password must be at least 8 characters with uppercase, lowercase, and digit.");
 
        userDAO.updatePassword(userId, PasswordUtil.hash(newPassword));
    }
 
    // ── Password Reset (token-based) ──────────────────────────────────────────
 
    /**
     * Generates a secure UUID token for a user identified by email,
     * stores it with a 30-minute expiry, and returns the token.
     * Sends a reset email asynchronously.
     *
     * @param email       the user's registered email
     * @param appBaseUrl  the base URL of the application (for building the reset link)
     * @return the generated token (for on-screen display in dev / no-email scenarios)
     * @throws IllegalArgumentException if no account is found for that email
     */
    public String generatePasswordResetToken(String email, String appBaseUrl)
            throws SQLException, IllegalArgumentException {
 
        if (ValidationUtil.isBlank(email))
            throw new IllegalArgumentException("Email address is required.");
 
        User user = userDAO.findByEmail(email.trim().toLowerCase());
        if (user == null)
            throw new IllegalArgumentException("No account found for that email address.");
 
        String token = UUID.randomUUID().toString();
        LocalDateTime expiry = LocalDateTime.now().plusMinutes(RESET_TOKEN_MINUTES);
        userDAO.savePasswordResetToken(user.getId(), token, expiry);
 
        // Build reset URL and send email asynchronously
        String resetUrl = appBaseUrl + "/reset-password?token=" + token;
        String body = "Hello " + user.getFullName() + ",\n\n"
                + "A password reset was requested for your RailTrack account.\n"
                + "Click the link below (valid for " + RESET_TOKEN_MINUTES + " minutes):\n\n"
                + resetUrl + "\n\n"
                + "If you did not request this, please ignore this email.\n\n"
                + "– RailTrack Platform";
        EmailService.sendEmailAsync(user.getEmail(), "Reset your RailTrack password", body);
 
        return token;
    }
 
    /**
     * Validates a reset token and, if valid, updates the user's password.
     * Clears the token afterwards to prevent re-use.
     *
     * @throws IllegalArgumentException if the token is invalid, expired, or the new password is weak
     */
    public void resetPasswordByToken(String token, String newPassword)
            throws SQLException, IllegalArgumentException {
 
        if (ValidationUtil.isBlank(token))
            throw new IllegalArgumentException("Reset token is missing.");
 
        User user = userDAO.findByValidResetToken(token.trim());
        if (user == null)
            throw new IllegalArgumentException("This reset link is invalid or has expired. Please request a new one.");
 
        if (!ValidationUtil.isStrongPassword(newPassword))
            throw new IllegalArgumentException(
                    "Password must be at least 8 characters with uppercase, lowercase, and digit.");
 
        userDAO.updatePassword(user.getId(), PasswordUtil.hash(newPassword));
        userDAO.clearResetToken(user.getId());
    }
}
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

/**
 *
 * @author izzat
 */
public class AuthService {
 
    private static final String SESSION_USER_ID   = "userId";
    private static final String SESSION_USER_NAME = "userName";
    private static final String SESSION_USER_ROLE = "userRole";
 
    private final UserDAO userDAO = new UserDAO();
 
    // ── Login / Logout ────────────────────────────────────────────────────────
 
    /**
     * Validates credentials, creates session, returns the authenticated User.
     * Returns null if credentials are invalid or account is inactive.
     */
    public User login(HttpServletRequest request, String username, String rawPassword)
            throws SQLException, IllegalArgumentException {
 
        if (ValidationUtil.isBlank(username) || ValidationUtil.isBlank(rawPassword))
            throw new IllegalArgumentException("Username and password are required.");
 
        User user = userDAO.authenticate(username.trim(), rawPassword);
        if (user == null) return null;
 
        // Invalidate old session before creating new one (session fixation protection)
        HttpSession old = request.getSession(false);
        if (old != null) old.invalidate();
 
        HttpSession session = request.getSession(true);
        session.setAttribute(SESSION_USER_ID,   user.getId());
        session.setAttribute(SESSION_USER_NAME, user.getDisplayName());
        session.setAttribute(SESSION_USER_ROLE, user.getRole().name());
        session.setMaxInactiveInterval(60 * 60); // 1 hour
 
        return user;
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
}
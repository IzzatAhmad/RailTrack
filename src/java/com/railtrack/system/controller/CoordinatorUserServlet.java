/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.railtrack.system.controller;

import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.dao.UserDAO;
import com.railtrack.system.model.User;
import com.railtrack.system.service.AuthService;
import com.railtrack.system.service.NotificationService;
import com.railtrack.system.util.PasswordUtil;
import com.railtrack.system.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author izzat
 */
@WebServlet("/coordinator/users")
public class CoordinatorUserServlet extends HttpServlet {
 
    private final UserDAO             userDAO     = new UserDAO();
    private final ProjectDAO          projectDAO  = new ProjectDAO();
    private final AuthService         authService = new AuthService();
    private final NotificationService notifService = new NotificationService();
 
    // ── GET ───────────────────────────────────────────────────────────────────
 
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        try {
            req.setAttribute("users",       userDAO.findAll());
            req.setAttribute("supervisors", userDAO.findAllSupervisors());
            req.setAttribute("students",    userDAO.findAllStudents());
            req.setAttribute("notif",       notifService.getCoordinatorCounts());
 
            req.getRequestDispatcher("/views/coordinator/users.jsp").forward(req, resp);
 
        } catch (SQLException e) {
            throw new ServletException("Failed to load users", e);
        }
    }
 
    // ── POST ──────────────────────────────────────────────────────────────────
 
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        int selfId    = AuthService.getSessionUserId(req);

        try {
            // ── Auto Assign Supervisors ───────────────────────────────────────
            if ("autoAssignSupervisors".equals(action)) {
                com.railtrack.system.service.ProjectService projectService = new com.railtrack.system.service.ProjectService();
                int assignedCount = projectService.autoAssignStudentSupervisors();
                resp.sendRedirect(req.getContextPath() + "/coordinator/users?success=auto_assigned&count=" + assignedCount);
                return;
            }

            // ── Reassign Supervisor ───────────────────────────────────────────
            if ("reassignSupervisor".equals(action)) {
                int studentId = Integer.parseInt(req.getParameter("studentId"));
                String supIdStr = req.getParameter("supervisorId");
                Integer supervisorId = (supIdStr == null || supIdStr.trim().isEmpty()) ? null : Integer.parseInt(supIdStr.trim());

                com.railtrack.system.service.ProjectService projectService = new com.railtrack.system.service.ProjectService();
                projectService.reassignStudentSupervisor(studentId, supervisorId);

                resp.sendRedirect(req.getContextPath() + "/coordinator/users?success=reassigned");
                return;
            }

            // ── Toggle Email Notifications ────────────────────────────────────
            if ("toggleEmailNotif".equals(action)) {
                int studentId = Integer.parseInt(req.getParameter("studentId"));
                User student = userDAO.findById(studentId);
                if (student != null && student.getRole() == User.Role.STUDENT) {
                    student.setEmailNotifEnabled(!student.isEmailNotifEnabled());
                    userDAO.update(student);
                    resp.sendRedirect(req.getContextPath() + "/coordinator/users?success=notif_toggled");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/coordinator/users?error=invalid_student");
                }
                return;
            }
            // ── Check conflicts (AJAX) ────────────────────────────────────────
            if ("checkConflicts".equals(action)) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                String[] usernames = req.getParameterValues("usernames");
                String[] emails = req.getParameterValues("emails");
                
                List<String> takenUsernames = new ArrayList<>();
                List<String> takenEmails = new ArrayList<>();
                
                if (usernames != null) {
                    for (String u : usernames) {
                        if (userDAO.usernameExists(u.trim())) {
                            takenUsernames.add(u.trim());
                        }
                    }
                }
                if (emails != null) {
                    for (String e : emails) {
                        if (userDAO.emailExists(e.trim().toLowerCase())) {
                            takenEmails.add(e.trim().toLowerCase());
                        }
                    }
                }
                
                StringBuilder sb = new StringBuilder();
                sb.append("{");
                sb.append("\"takenUsernames\":[");
                for (int i = 0; i < takenUsernames.size(); i++) {
                    sb.append("\"").append(takenUsernames.get(i).replace("\"", "\\\"")).append("\"");
                    if (i < takenUsernames.size() - 1) sb.append(",");
                }
                sb.append("],");
                sb.append("\"takenEmails\":[");
                for (int i = 0; i < takenEmails.size(); i++) {
                    sb.append("\"").append(takenEmails.get(i).replace("\"", "\\\"")).append("\"");
                    if (i < takenEmails.size() - 1) sb.append(",");
                }
                sb.append("]");
                sb.append("}");
                
                resp.getWriter().write(sb.toString());
                return;
            }

            // ── Single deactivate ─────────────────────────────────────────────
            if ("deactivate".equals(action)) {
                int userId = Integer.parseInt(req.getParameter("id"));
                if (userId == selfId) {
                    req.setAttribute("formError", "You cannot deactivate your own account.");
                    doGet(req, resp);
                    return;
                }
                userDAO.deactivate(userId);
                resp.sendRedirect(req.getContextPath() + "/coordinator/users?success=deactivated");
                return;
            }

            // ── Single delete ─────────────────────────────────────────────────
            if ("delete".equals(action)) {
                int userId = Integer.parseInt(req.getParameter("id"));
                if (userId == selfId) {
                    req.setAttribute("formError", "You cannot delete your own account.");
                    doGet(req, resp);
                    return;
                }
                userDAO.delete(userId);
                resp.sendRedirect(req.getContextPath() + "/coordinator/users?success=deleted");
                return;
            }

            // ── Bulk deactivate ───────────────────────────────────────────────
            if ("bulkDeactivate".equals(action)) {
                String[] rawIds = req.getParameterValues("ids");
                List<Integer> ids = parseIds(rawIds, selfId);
                if (!ids.isEmpty()) {
                    userDAO.deactivateMultiple(ids);
                }
                resp.sendRedirect(req.getContextPath() + "/coordinator/users?success=bulk_deactivated");
                return;
            }

            // ── Bulk delete ───────────────────────────────────────────────────
            if ("bulkDelete".equals(action)) {
                String[] rawIds = req.getParameterValues("ids");
                List<Integer> ids = parseIds(rawIds, selfId);
                if (!ids.isEmpty()) {
                    userDAO.deleteMultiple(ids);
                }
                resp.sendRedirect(req.getContextPath() + "/coordinator/users?success=bulk_deleted");
                return;
            }

            // ── Import multiple users ─────────────────────────────────────────
            if ("importUsers".equals(action)) {
                List<User> importList = new ArrayList<>();
                int idx = 0;
                List<String> errors = new ArrayList<>();
                java.util.Set<String> seenUsernames = new java.util.HashSet<>();
                java.util.Set<String> seenEmails = new java.util.HashSet<>();
                while (true) {
                    String uName = req.getParameter("users[" + idx + "].username");
                    if (uName == null) {
                        break;
                    }
                    String pwd = req.getParameter("users[" + idx + "].password");
                    String pwdHash = req.getParameter("users[" + idx + "].password_hash");
                    String fName = req.getParameter("users[" + idx + "].fullName");
                    String mail = req.getParameter("users[" + idx + "].email");
                    String phone = req.getParameter("users[" + idx + "].phone");
                    String dept = req.getParameter("users[" + idx + "].department");
                    String rStr = req.getParameter("users[" + idx + "].role");
                    String actStr = req.getParameter("users[" + idx + "].active");
                    String cgpaStr = req.getParameter("users[" + idx + "].cgpa");

                    try {
                        if (ValidationUtil.isBlank(uName) ||
                            (ValidationUtil.isBlank(pwd) && ValidationUtil.isBlank(pwdHash)) ||
                            ValidationUtil.isBlank(fName) ||
                            ValidationUtil.isBlank(mail) ||
                            ValidationUtil.isBlank(rStr)) {
                            throw new IllegalArgumentException("Missing required fields.");
                        }

                        User.Role role;
                        try {
                            role = User.Role.valueOf(rStr.trim().toUpperCase());
                        } catch (Exception e) {
                            throw new IllegalArgumentException("Invalid role '" + rStr + "'.");
                        }

                        Double cgpa = null;
                        if (role == User.Role.STUDENT && ValidationUtil.notBlank(cgpaStr)) {
                            try {
                                cgpa = Double.parseDouble(cgpaStr.trim());
                                if (cgpa < 0.0 || cgpa > 4.0) {
                                    throw new IllegalArgumentException("CGPA must be between 0.00 and 4.00.");
                                }
                            } catch (NumberFormatException e) {
                                throw new IllegalArgumentException("Invalid CGPA format.");
                            }
                        }

                        if (!ValidationUtil.isValidUsername(uName)) {
                            throw new IllegalArgumentException("Username must be 3–30 characters (letters, digits, underscore).");
                        }

                        if (ValidationUtil.notBlank(pwd)) {
                            if (!ValidationUtil.isStrongPassword(pwd)) {
                                throw new IllegalArgumentException("Password must be at least 8 characters with uppercase, lowercase, and digit.");
                            }
                        }

                        if (!ValidationUtil.isValidEmail(mail)) {
                            throw new IllegalArgumentException("Invalid email address.");
                        }

                        if (seenUsernames.contains(uName.trim().toLowerCase())) {
                            throw new IllegalArgumentException("Duplicate username in JSON file.");
                        }
                        if (seenEmails.contains(mail.trim().toLowerCase())) {
                            throw new IllegalArgumentException("Duplicate email in JSON file.");
                        }

                        if (userDAO.usernameExists(uName.trim())) {
                            throw new IllegalArgumentException("Username '" + uName.trim() + "' is already taken.");
                        }

                        if (userDAO.emailExists(mail.trim().toLowerCase())) {
                            throw new IllegalArgumentException("Email '" + mail.trim().toLowerCase() + "' is already registered.");
                        }

                        seenUsernames.add(uName.trim().toLowerCase());
                        seenEmails.add(mail.trim().toLowerCase());

                        User user = new User();
                        user.setUsername(uName.trim());
                        if (ValidationUtil.notBlank(pwd)) {
                            user.setPasswordHash(PasswordUtil.hash(pwd));
                        } else {
                            user.setPasswordHash(pwdHash.trim());
                        }
                        user.setFullName(ValidationUtil.sanitise(fName));
                        user.setEmail(mail.trim().toLowerCase());
                        user.setPhone(ValidationUtil.sanitise(phone));
                        user.setDepartment(ValidationUtil.sanitise(dept));
                        user.setCgpa(role == User.Role.STUDENT ? cgpa : null);
                        user.setRole(role);
                        boolean active = !"false".equalsIgnoreCase(actStr);
                        user.setActive(active);

                        importList.add(user);
                    } catch (IllegalArgumentException e) {
                        errors.add("Row " + (idx + 1) + " (" + (uName != null && !uName.isEmpty() ? uName : "unnamed") + "): " + e.getMessage());
                    } catch (SQLException e) {
                        errors.add("Row " + (idx + 1) + ": Database check failed.");
                    }
                    idx++;
                }

                if (!errors.isEmpty()) {
                    StringBuilder errorMsg = new StringBuilder("Import failed due to the following errors:<br/>");
                    for (String err : errors) {
                        errorMsg.append("• ").append(err).append("<br/>");
                    }
                    req.setAttribute("formError", errorMsg.toString());
                    doGet(req, resp);
                    return;
                }

                // If no errors, perform all inserts!
                for (User user : importList) {
                    userDAO.insert(user);
                }

                resp.sendRedirect(req.getContextPath() + "/coordinator/users?success=imported");
                return;
            }

            // ── Create new user ───────────────────────────────────────────────
            String username   = req.getParameter("username");
            String password   = req.getParameter("password");
            String fullName   = req.getParameter("fullName");
            String email      = req.getParameter("email");
            String department = req.getParameter("department");
            String roleStr    = req.getParameter("role");
            String cgpaStr    = req.getParameter("cgpa");

            User.Role role;
            try { role = User.Role.valueOf(roleStr); }
            catch (Exception e) { role = User.Role.STUDENT; }

            Double cgpa = null;
            if (role == User.Role.STUDENT && ValidationUtil.notBlank(cgpaStr)) {
                try {
                    cgpa = Double.parseDouble(cgpaStr.trim());
                    if (cgpa < 0.0 || cgpa > 4.0) {
                        throw new IllegalArgumentException("CGPA must be between 0.00 and 4.00.");
                    }
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Invalid CGPA format.");
                }
            }

            authService.register(username, password, fullName, email, department, role, cgpa);
            resp.sendRedirect(req.getContextPath() + "/coordinator/users?success=created");

        } catch (IllegalArgumentException e) {
            req.setAttribute("formError", e.getMessage());
            doGet(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Failed to manage user", e);
        }
    }

    /** Parse an array of id strings, skipping the current session user. */
    private List<Integer> parseIds(String[] rawIds, int selfId) {
        List<Integer> ids = new ArrayList<>();
        if (rawIds == null) return ids;
        for (String raw : rawIds) {
            try {
                int id = Integer.parseInt(raw.trim());
                if (id != selfId) ids.add(id);
            } catch (NumberFormatException ignored) { }
        }
        return ids;
    }
}

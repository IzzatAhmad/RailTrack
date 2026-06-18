<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.User" %>
<%
    request.setAttribute("pageTitle", "My Profile");
    User   user       = (User)   request.getAttribute("user");
    String formError  = (String) request.getAttribute("formError");
    String success    = request.getParameter("success");
    String role       = (String) session.getAttribute("userRole");
    String ctx        = request.getContextPath();
    String dashUrl    = "/login";
    if ("STUDENT".equals(role))          dashUrl = ctx + "/student/dashboard";
    else if ("SUPERVISOR".equals(role))  dashUrl = ctx + "/supervisor/dashboard";
    else if ("COORDINATOR".equals(role)) dashUrl = ctx + "/coordinator/dashboard";
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= dashUrl %>" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">My Profile</span>
</nav>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h4 class="fw-bold mb-0">My Profile</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">Update your account information</p>
    </div>
</div>

<% if (formError != null) { %>
<div class="rt-alert rt-alert-error rt-flash mb-3">
    <i class="bi bi-exclamation-circle-fill"></i> <%= formError %>
</div>
<% } %>
<% if (success != null) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i>
    <% if ("updated".equals(success))  { %>Profile updated.
    <% } else if ("password".equals(success)) { %>Password changed successfully.
    <% } else { %>Done.<% } %>
</div>
<% } %>

<div class="row g-3">
    <!-- Profile info -->
    <div class="col-lg-6">
        <div class="rt-card">
            <div class="rt-card-header">
                <i class="bi bi-person text-primary"></i> Personal Information
            </div>
            <div class="p-3">
                <form method="post">
                    <input type="hidden" name="action" value="update"/>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Full Name</label>
                        <input type="text" name="fullName" class="form-control <%= user.isStudent() ? "bg-light" : "" %>"
                               value="<%= user.getFullName() != null ? user.getFullName() : "" %>"
                               <%= user.isStudent() ? "readonly" : "" %> required/>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Email</label>
                        <input type="email" name="email" class="form-control <%= user.isStudent() ? "bg-light" : "" %>"
                               value="<%= user.getEmail() != null ? user.getEmail() : "" %>"
                               <%= user.isStudent() ? "readonly" : "" %> required/>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Phone</label>
                        <input type="text" name="phone" class="form-control <%= user.isStudent() ? "bg-light" : "" %>"
                               value="<%= user.getPhone() != null ? user.getPhone() : "" %>"
                               <%= user.isStudent() ? "readonly" : "" %>/>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Department</label>
                        <input type="text" name="department" class="form-control <%= user.isStudent() ? "bg-light" : "" %>"
                               value="<%= user.getDepartment() != null ? user.getDepartment() : "" %>"
                               <%= user.isStudent() ? "readonly" : "" %>/>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Username</label>
                        <input type="text" class="form-control bg-light"
                               value="<%= user.getUsername() %>" disabled/>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Role</label>
                        <input type="text" class="form-control bg-light"
                               value="<%= user.getRole() %>" disabled/>
                    </div>
                    <% if (user.isStudent()) { %>
                    <hr class="my-4"/>
                    <h6 class="fw-semibold mb-3 text-muted" style="font-size:.78rem;letter-spacing:.05em;text-transform:uppercase;">
                        Notification Preferences
                    </h6>
                    <div class="form-check form-switch mb-3">
                        <input class="form-check-input" type="checkbox" name="emailNotifEnabled" id="emailNotif" value="true"
                               <%= user.isEmailNotifEnabled() ? "checked" : "" %>>
                        <label class="form-check-label fw-semibold" for="emailNotif" style="font-size:.83rem;">
                            Email Notifications (Gmail)
                        </label>
                    </div>
                    <% } %>
                    <button type="submit" class="btn btn-primary btn-sm">
                        <i class="bi bi-save me-1"></i>Save Changes
                    </button>
                </form>
            </div>
        </div>
    </div>

    <!-- Change password -->
    <div class="col-lg-6">
        <div class="rt-card">
            <div class="rt-card-header">
                <i class="bi bi-lock text-warning"></i> Change Password
            </div>
            <div class="p-3">
                <form method="post">
                    <input type="hidden" name="action" value="password"/>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">
                            Current Password
                        </label>
                        <input type="password" name="currentPassword" class="form-control" required/>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">
                            New Password
                        </label>
                        <input type="password" name="newPassword" class="form-control" required/>
                        <div style="font-size:.75rem;color:var(--rt-muted);margin-top:.3rem;">
                            Min 8 chars, uppercase, lowercase and digit required.
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">
                            Confirm New Password
                        </label>
                        <input type="password" name="confirmPassword" class="form-control" required/>
                    </div>
                    <button type="submit" class="btn btn-warning btn-sm text-dark">
                        <i class="bi bi-key me-1"></i>Change Password
                    </button>
                </form>
            </div>
        </div>

        <!-- Account info card -->
        <div class="rt-card mt-3 p-3">
            <div style="font-size:.83rem;color:var(--rt-muted);">
                <div class="d-flex justify-content-between mb-2">
                    <span>Member since</span>
                    <strong class="text-dark">
                        <%= user.getCreatedAt() != null
                            ? user.getCreatedAt().toLocalDate().toString() : "—" %>
                    </strong>
                </div>
                <div class="d-flex justify-content-between mb-2">
                    <span>Last login</span>
                    <strong class="text-dark">
                        <%= user.getLastLogin() != null
                            ? user.getLastLogin().toLocalDate().toString() : "—" %>
                    </strong>
                </div>
                <div class="d-flex justify-content-between">
                    <span>Account status</span>
                    <span style="color:var(--rt-success);font-weight:600;">
                        <i class="bi bi-circle-fill me-1" style="font-size:7px;"></i>Active
                    </span>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp"/>

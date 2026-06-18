<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.*,java.util.List,java.util.HashMap,java.util.Map,java.time.format.DateTimeFormatter" %>
<%
    request.setAttribute("pageTitle", "User Management");
    List<User> users  = (List<User>) request.getAttribute("users");
    List<User> supervisors = (List<User>) request.getAttribute("supervisors");
    String formError  = (String) request.getAttribute("formError");
    String success    = request.getParameter("success");
    String ctx        = request.getContextPath();

    // Build supervisor → assigned-student count map from the loaded users list
    Map<Integer,Integer> supStudentCount = new HashMap<Integer,Integer>();
    if (users != null) {
        for (User _u : users) {
            if (_u.getRole() == User.Role.STUDENT && _u.getSupervisorId() != null && _u.getSupervisorId() > 0) {
                Integer _existing = supStudentCount.get(_u.getSupervisorId());
                supStudentCount.put(_u.getSupervisorId(), _existing == null ? 1 : _existing + 1);
            }
        }
    }
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/coordinator/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">User Management</span>
</nav>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h4 class="fw-bold mb-0">User Management</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">Create and manage platform accounts</p>
    </div>
    <div class="d-flex gap-2">
        <form method="post" action="<%= ctx %>/coordinator/users" class="d-inline mb-0">
            <input type="hidden" name="action" value="autoAssignSupervisors"/>
            <button type="submit" class="btn btn-outline-success btn-sm" onclick="return confirm('Automatically assign all unassigned students to supervisors using CGPA load balancing?')">
                <i class="bi bi-magic me-1"></i>Auto-Assign
            </button>
        </form>
        <button class="btn btn-outline-primary btn-sm" data-bs-toggle="modal" data-bs-target="#importUsersModal">
            <i class="bi bi-file-earmark-arrow-up me-1"></i>Import Users
        </button>
        <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#createUserModal">
            <i class="bi bi-person-plus me-1"></i>Create User
        </button>
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
    <% if ("created".equals(success))                { %>User created successfully.
    <% } else if ("deactivated".equals(success))       { %>User deactivated.
    <% } else if ("bulk_deactivated".equals(success))  { %>Selected users deactivated.
    <% } else if ("deleted".equals(success))           { %>User deleted.
    <% } else if ("bulk_deleted".equals(success))      { %>Selected users deleted.
    <% } else if ("imported".equals(success))          { %>Users imported successfully.
    <% } else if ("auto_assigned".equals(success))     { %>Successfully auto-assigned <%= request.getParameter("count") %> students to supervisors.
    <% } else if ("reassigned".equals(success))        { %>Student supervisor assignment updated successfully.
    <% } else if ("notif_toggled".equals(success))     { %>Student email notification preference updated.
    <% } else { %>Done.<% } %>
</div>
<% } %>

<div class="rt-card">
    <div class="rt-card-header border-bottom-0 pb-0">
        <ul class="nav nav-tabs border-bottom-0 w-100" id="userTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active fw-bold text-primary" id="all-users-tab" data-bs-toggle="tab" data-bs-target="#all-users" type="button" role="tab" aria-controls="all-users" aria-selected="true">
                    <i class="bi bi-people-fill me-1"></i>All Users
                    <span class="badge bg-secondary ms-1" id="visibleCount" style="font-size:.65rem;">
                        <%= users != null ? users.size() : 0 %>
                    </span>
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link fw-bold text-secondary" id="sup-groups-tab" data-bs-toggle="tab" data-bs-target="#sup-groups" type="button" role="tab" aria-controls="sup-groups" aria-selected="false">
                    <i class="bi bi-grid-fill me-1"></i>Supervisor Groups
                </button>
            </li>
        </ul>
    </div>

    <div class="tab-content" id="userTabsContent">
        <!-- Tab 1: All Users -->
        <div class="tab-pane fade show active" id="all-users" role="tabpanel" aria-labelledby="all-users-tab">

    <!-- Search + Filter toolbar -->
    <div class="px-3 pt-3 pb-2 border-bottom d-flex flex-wrap gap-2 align-items-center">
        <div class="input-group input-group-sm" style="max-width:260px;">
            <span class="input-group-text bg-white border-end-0">
                <i class="bi bi-search text-muted" style="font-size:.8rem;"></i>
            </span>
            <input type="text" id="searchInput" class="form-control border-start-0 ps-0"
                   placeholder="Search name, email, username…" style="font-size:.83rem;">
        </div>

        <select id="filterRole" class="form-select form-select-sm" style="max-width:140px;font-size:.83rem;">
            <option value="">All Roles</option>
            <option value="STUDENT">Student</option>
            <option value="SUPERVISOR">Supervisor</option>
            <option value="COORDINATOR">Coordinator</option>
        </select>

        <select id="filterStatus" class="form-select form-select-sm" style="max-width:130px;font-size:.83rem;">
            <option value="">All Status</option>
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
        </select>

        <!-- Bulk action bar — shown only when ≥1 row checked -->
        <div id="bulkBar" class="d-none ms-auto d-flex align-items-center gap-2">
            <span id="selCount" class="text-muted" style="font-size:.82rem;">0 selected</span>
            <button type="button" class="btn btn-sm btn-outline-warning" onclick="bulkDeactivate()">
                <i class="bi bi-person-slash me-1"></i>Deactivate
            </button>
            <button type="button" class="btn btn-sm btn-outline-danger" onclick="bulkDelete()">
                <i class="bi bi-trash me-1"></i>Delete
            </button>
        </div>
    </div>

    <!-- Hidden bulk forms -->
    <form id="bulkDeactivateForm" method="post" action="<%= ctx %>/coordinator/users">
        <input type="hidden" name="action" value="bulkDeactivate"/>
        <div id="bulkDeactivateIds"></div>
    </form>
    <form id="bulkDeleteForm" method="post" action="<%= ctx %>/coordinator/users">
        <input type="hidden" name="action" value="bulkDelete"/>
        <div id="bulkDeleteIds"></div>
    </form>

    <% if (users == null || users.isEmpty()) { %>
    <div class="p-4 text-center text-muted">No users found.</div>
    <% } else { %>
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0" id="usersTable">
            <thead class="table-light">
                <tr>
                    <th style="width:36px;">
                        <input class="form-check-input" type="checkbox" id="selectAll"
                               title="Select all visible" style="cursor:pointer;">
                    </th>
                    <th style="min-width:140px;">Name</th>
                    <th style="min-width:160px;">Email</th>
                    <th>Role</th>
                    <th>Department</th>
                    <th title="CGPA for students · Student load for supervisors">CGPA / Load</th>
                    <th>Status</th>
                    <th>Last Login</th>
                    <th></th>
                </tr>
            </thead>
            <tbody id="usersBody">
            <% for (User u : users) { %>
            <tr data-name="<%= u.getFullName().toLowerCase() %>"
                data-username="<%= u.getUsername().toLowerCase() %>"
                data-email="<%= u.getEmail().toLowerCase() %>"
                data-role="<%= u.getRole().name() %>"
                data-status="<%= u.isActive() ? "active" : "inactive" %>">

                <td>
                    <input class="form-check-input row-check" type="checkbox"
                           value="<%= u.getId() %>" style="cursor:pointer;">
                </td>
                <td>
                    <div class="fw-semibold"><%= u.getFullName() %></div>
                    <div style="font-size:.75rem;color:var(--rt-muted);">@<%= u.getUsername() %></div>
                </td>
                <td style="font-size:.83rem;">
                    <%= u.getEmail() %>
                    <% if (u.getRole() == User.Role.STUDENT) { %>
                    <div class="mt-1">
                        <form method="POST" action="<%= ctx %>/coordinator/users" class="d-inline m-0">
                            <input type="hidden" name="action" value="toggleEmailNotif"/>
                            <input type="hidden" name="studentId" value="<%= u.getId() %>"/>
                            <div class="form-check form-switch d-inline-block m-0 p-0" style="min-height: auto;">
                                <input class="form-check-input ms-0" type="checkbox" role="switch" 
                                       style="width: 1.8em; height: 0.9em; cursor: pointer; float: none; vertical-align: middle;" 
                                       <%= u.isEmailNotifEnabled() ? "checked" : "" %> 
                                       onchange="this.form.submit()"
                                       title="Toggle Email Notifications for this student"/>
                                <span style="font-size: .72rem; vertical-align: middle;" class="<%= u.isEmailNotifEnabled() ? "text-success fw-semibold" : "text-muted" %>">
                                    <i class="bi bi-envelope<%= u.isEmailNotifEnabled() ? "-fill" : "" %>"></i> Gmail
                                </span>
                            </div>
                        </form>
                    </div>
                    <% } %>
                </td>
                <td>
                    <span class="badge
                        <% if (u.getRole()==User.Role.COORDINATOR) { %>bg-warning text-dark
                        <% } else if (u.getRole()==User.Role.SUPERVISOR) { %>bg-success
                        <% } else { %>bg-primary<% } %>"
                        style="font-size:.68rem;">
                        <%= u.getRole() %>
                    </span>
                </td>
                <td style="font-size:.82rem;color:var(--rt-muted);">
                    <% if (u.getRole() == User.Role.COORDINATOR) { %>
                        <span class="text-muted fst-italic" style="font-size:.78rem;">—</span>
                    <% } else { %>
                        <%= u.getDepartment() != null ? u.getDepartment() : "—" %>
                        <% if (u.getRole() == User.Role.STUDENT && u.getSupervisorName() != null && !u.getSupervisorName().isEmpty()) { %>
                        <div style="font-size:.73rem;color:var(--bs-success);" class="mt-1">
                            <i class="bi bi-person-badge me-1"></i>Sup: <%= u.getSupervisorName() %>
                        </div>
                        <% } %>
                    <% } %>
                </td>
                <td>
                    <% if (u.getRole() == User.Role.STUDENT) {
                           Double _cgpa = u.getCgpa();
                           if (_cgpa != null) {
                               String _cgpaStr = String.format("%.2f", _cgpa);
                               String _cgpaColor = _cgpa >= 3.5 ? "#16a34a" : _cgpa >= 3.0 ? "#2563eb" : _cgpa >= 2.5 ? "#d97706" : "#dc2626";
                    %>
                        <span style="font-size:.82rem;font-weight:600;color:<%= _cgpaColor %>;"
                              title="CGPA: <%= _cgpaStr %>">
                            <%= _cgpaStr %>
                        </span>
                    <%     } else { %>
                        <span class="text-muted" style="font-size:.8rem;">—</span>
                    <%     }
                       } else if (u.getRole() == User.Role.SUPERVISOR) {
                           int _sc = supStudentCount.getOrDefault(u.getId(), 0);
                           String _badgeCls = _sc == 0 ? "bg-secondary" : (_sc >= 10 ? "bg-danger" : "bg-success");
                    %>
                        <span class="badge <%= _badgeCls %>"
                              style="font-size:.68rem;" title="<%= _sc %> student(s) assigned">
                            <i class="bi bi-people-fill me-1"></i><%= _sc %> Students
                        </span>
                    <%  } else { %>
                        <span class="text-muted" style="font-size:.78rem;">—</span>
                    <%  } %>
                </td>
                <td>
                    <% if (u.isActive()) { %>
                    <span style="color:var(--rt-success);font-size:.82rem;">
                        <i class="bi bi-circle-fill me-1" style="font-size:7px;"></i>Active
                    </span>
                    <% } else { %>
                    <span style="color:var(--rt-muted);font-size:.82rem;">
                        <i class="bi bi-circle me-1" style="font-size:7px;"></i>Inactive
                    </span>
                    <% } %>
                </td>
                <td style="font-size:.75rem;color:var(--rt-muted);">
                    <%= u.getLastLogin() != null ? u.getLastLogin().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "Never" %>
                </td>
                <td class="text-end pe-3">
                    <div class="d-flex gap-1 justify-content-end">
                        <% if (u.isActive()) { %>
                        <form method="post" action="<%= ctx %>/coordinator/users" class="d-inline">
                            <input type="hidden" name="action" value="deactivate"/>
                            <input type="hidden" name="id" value="<%= u.getId() %>"/>
                            <button type="submit" class="btn btn-sm btn-outline-warning"
                                    title="Deactivate"
                                    onclick="return confirm('Deactivate <%= u.getUsername() %>?')">
                                <i class="bi bi-person-slash"></i>
                            </button>
                        </form>
                        <% } %>
                        <form method="post" action="<%= ctx %>/coordinator/users" class="d-inline">
                            <input type="hidden" name="action" value="delete"/>
                            <input type="hidden" name="id" value="<%= u.getId() %>"/>
                            <button type="submit" class="btn btn-sm btn-outline-danger"
                                    title="Delete permanently"
                                    onclick="return confirm('Permanently delete <%= u.getUsername() %>? This cannot be undone.')">
                                <i class="bi bi-trash"></i>
                            </button>
                        </form>
                    </div>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <div id="noResults" class="p-4 text-center text-muted d-none">No users match your filters.</div>
    </div>
    <% } %>
        </div> <!-- End Tab 1: All Users -->
        
        <!-- Tab 2: Supervisor Groups -->
        <div class="tab-pane fade" id="sup-groups" role="tabpanel" aria-labelledby="sup-groups-tab">
            <div class="p-3">
                <div class="row g-3">
                    <!-- Unassigned Students Cohort -->
                    <div class="col-12 col-lg-6">
                        <div class="card border shadow-sm">
                            <div class="card-header bg-danger-subtle text-danger fw-bold d-flex align-items-center py-2 px-3" style="font-size: .88rem; border-top-left-radius: 8px; border-top-right-radius: 8px;">
                                <i class="bi bi-exclamation-triangle-fill me-2"></i>Unassigned Students
                                <%
                                    int unassignedCount = 0;
                                    if (users != null) {
                                        for (User u : users) {
                                            if (u.getRole() == User.Role.STUDENT && (u.getSupervisorId() == null || u.getSupervisorId() <= 0)) {
                                                unassignedCount++;
                                            }
                                        }
                                    }
                                %>
                                <span class="badge bg-danger ms-auto" style="font-size: .7rem;"><%= unassignedCount %></span>
                            </div>
                            <div class="list-group list-group-flush" style="max-height: 350px; overflow-y: auto;">
                                <%
                                    boolean hasUnassigned = false;
                                    if (users != null) {
                                        for (User u : users) {
                                            if (u.getRole() == User.Role.STUDENT && (u.getSupervisorId() == null || u.getSupervisorId() <= 0)) {
                                                hasUnassigned = true;
                                %>
                                <div class="list-group-item d-flex justify-content-between align-items-center py-2 px-3">
                                    <div>
                                        <div class="fw-semibold" style="font-size: .83rem;"><%= u.getFullName() %></div>
                                        <div class="text-muted" style="font-size: .73rem;">
                                            @<%= u.getUsername() %> • CGPA: <%= u.getCgpa() != null ? String.format("%.2f", u.getCgpa()) : "—" %>
                                            &nbsp;•&nbsp;
                                            <form method="post" action="<%= ctx %>/coordinator/users" class="d-inline m-0">
                                                <input type="hidden" name="action" value="toggleEmailNotif"/>
                                                <input type="hidden" name="studentId" value="<%= u.getId() %>"/>
                                                <div class="form-check form-switch d-inline-block m-0 p-0" style="min-height: auto;">
                                                    <input class="form-check-input ms-0" type="checkbox" role="switch" 
                                                           style="width: 1.8em; height: 0.9em; cursor: pointer; float: none; vertical-align: middle;" 
                                                           <%= u.isEmailNotifEnabled() ? "checked" : "" %> 
                                                           onchange="this.form.submit()"
                                                           title="Toggle Email Notifications for this student"/>
                                                    <span style="font-size: .72rem; vertical-align: middle;" class="<%= u.isEmailNotifEnabled() ? "text-success fw-semibold" : "text-muted" %>">
                                                        <i class="bi bi-envelope<%= u.isEmailNotifEnabled() ? "-fill" : "" %>"></i> Gmail
                                                    </span>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                    <div>
                                        <form method="post" action="<%= ctx %>/coordinator/users" class="d-inline mb-0">
                                            <input type="hidden" name="action" value="reassignSupervisor"/>
                                            <input type="hidden" name="studentId" value="<%= u.getId() %>"/>
                                            <select name="supervisorId" onchange="this.form.submit()" class="form-select form-select-sm" style="font-size: .75rem; width: 140px; padding: 0.15rem 1.5rem 0.15rem 0.5rem;">
                                                <option value="" selected>— Assign —</option>
                                                <% if (supervisors != null) { for (User sv : supervisors) { %>
                                                <option value="<%= sv.getId() %>"><%= sv.getFullName() %></option>
                                                <% } } %>
                                            </select>
                                        </form>
                                    </div>
                                </div>
                                <%
                                            }
                                        }
                                    }
                                    if (!hasUnassigned) {
                                %>
                                <div class="p-3 text-center text-muted" style="font-size: .8rem;">All students are assigned to a supervisor.</div>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <!-- Assigned Supervisors Cohorts -->
                    <%
                        if (supervisors != null) {
                            for (User sv : supervisors) {
                                int count = 0;
                                if (users != null) {
                                    for (User u : users) {
                                        if (u.getRole() == User.Role.STUDENT && u.getSupervisorId() != null && u.getSupervisorId().equals(sv.getId())) {
                                            count++;
                                        }
                                    }
                                }
                    %>
                    <div class="col-12 col-lg-6">
                        <div class="card border shadow-sm">
                            <div class="card-header bg-light fw-bold d-flex justify-content-between align-items-center py-2 px-3" style="font-size: .88rem; border-top-left-radius: 8px; border-top-right-radius: 8px;">
                                <span><i class="bi bi-person-badge text-primary me-2"></i><%= sv.getFullName() %></span>
                                <span class="badge bg-secondary" style="font-size: .7rem;"><%= count %> Students</span>
                            </div>
                            <div class="list-group list-group-flush" style="max-height: 350px; overflow-y: auto;">
                                <%
                                    boolean hasStudents = false;
                                    if (users != null) {
                                        for (User u : users) {
                                            if (u.getRole() == User.Role.STUDENT && u.getSupervisorId() != null && u.getSupervisorId().equals(sv.getId())) {
                                                hasStudents = true;
                                %>
                                <div class="list-group-item d-flex justify-content-between align-items-center py-2 px-3">
                                    <div>
                                        <div class="fw-semibold" style="font-size: .83rem;"><%= u.getFullName() %></div>
                                        <div class="text-muted" style="font-size: .73rem;">
                                            @<%= u.getUsername() %> • CGPA: <%= u.getCgpa() != null ? String.format("%.2f", u.getCgpa()) : "—" %>
                                            &nbsp;•&nbsp;
                                            <form method="post" action="<%= ctx %>/coordinator/users" class="d-inline m-0">
                                                <input type="hidden" name="action" value="toggleEmailNotif"/>
                                                <input type="hidden" name="studentId" value="<%= u.getId() %>"/>
                                                <div class="form-check form-switch d-inline-block m-0 p-0" style="min-height: auto;">
                                                    <input class="form-check-input ms-0" type="checkbox" role="switch" 
                                                           style="width: 1.8em; height: 0.9em; cursor: pointer; float: none; vertical-align: middle;" 
                                                           <%= u.isEmailNotifEnabled() ? "checked" : "" %> 
                                                           onchange="this.form.submit()"
                                                           title="Toggle Email Notifications for this student"/>
                                                    <span style="font-size: .72rem; vertical-align: middle;" class="<%= u.isEmailNotifEnabled() ? "text-success fw-semibold" : "text-muted" %>">
                                                        <i class="bi bi-envelope<%= u.isEmailNotifEnabled() ? "-fill" : "" %>"></i> Gmail
                                                    </span>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                    <div>
                                        <form method="post" action="<%= ctx %>/coordinator/users" class="d-inline mb-0">
                                            <input type="hidden" name="action" value="reassignSupervisor"/>
                                            <input type="hidden" name="studentId" value="<%= u.getId() %>"/>
                                            <select name="supervisorId" onchange="this.form.submit()" class="form-select form-select-sm" style="font-size: .75rem; width: 140px; padding: 0.15rem 1.5rem 0.15rem 0.5rem;">
                                                <option value="">— Unassign —</option>
                                                <% if (supervisors != null) { for (User svOpt : supervisors) { %>
                                                <option value="<%= svOpt.getId() %>" <%= svOpt.getId() == sv.getId() ? "selected" : "" %>><%= svOpt.getFullName() %></option>
                                                <% } } %>
                                            </select>
                                        </form>
                                    </div>
                                </div>
                                <%
                                            }
                                        }
                                    }
                                    if (!hasStudents) {
                                %>
                                <div class="p-3 text-center text-muted" style="font-size: .8rem;">No students assigned to this supervisor.</div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                        }
                    %>
                </div>
            </div>
        </div> <!-- End Tab 2: Supervisor Groups -->
    </div> <!-- End Tab Content -->
</div>

<!-- Create User Modal -->
<div class="modal fade" id="createUserModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px;">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold">Create New User</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= ctx %>/coordinator/users">
                <div class="modal-body pt-0">
                    <div class="row g-2">
                        <div class="col-6">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Username *</label>
                            <input type="text" name="username" class="form-control form-control-sm" required/>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Password *</label>
                            <input type="password" name="password" class="form-control form-control-sm" required/>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Full Name *</label>
                            <input type="text" name="fullName" class="form-control form-control-sm" required/>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Email *</label>
                            <input type="email" name="email" class="form-control form-control-sm" required/>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Role *</label>
                            <select name="role" id="manualRoleSelect" class="form-select form-select-sm" required>
                                <option value="STUDENT">Student</option>
                                <option value="SUPERVISOR">Supervisor</option>
                                <option value="COORDINATOR">Coordinator</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Department</label>
                            <input type="text" name="department" class="form-control form-control-sm"
                                   placeholder="e.g. Computer Science"/>
                        </div>
                        <div class="col-6" id="manualCgpaField">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">CGPA (Optional)</label>
                            <input type="number" step="0.01" min="0.00" max="4.00" name="cgpa" class="form-control form-control-sm"
                                   placeholder="e.g. 3.50"/>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm">
                        <i class="bi bi-person-plus me-1"></i>Create User
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<style>
    .table-success-light {
        background-color: rgba(25, 135, 84, 0.08) !important;
    }
    .table-danger-light {
        background-color: rgba(220, 53, 69, 0.08) !important;
    }
    #dropZone:hover {
        background: rgba(var(--bs-primary-rgb), 0.05) !important;
        border-color: var(--bs-primary) !important;
    }
</style>

<!-- Import Users Modal -->
<div class="modal fade" id="importUsersModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content" style="border-radius:12px; backdrop-filter: blur(8px); background: rgba(255, 255, 255, 0.95);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold"><i class="bi bi-file-earmark-arrow-up text-primary me-2"></i>Import Users via JSON</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <!-- Description and template download -->
                <div class="d-flex flex-wrap justify-content-between align-items-center mb-3 gap-2 bg-light p-3 rounded" style="border: 1px solid rgba(0,0,0,0.05);">
                    <div>
                        <p class="mb-0 fw-semibold" style="font-size:.85rem;">Need the correct format?</p>
                        <p class="text-muted mb-0" style="font-size:.78rem;">Download our starter JSON file template containing sample configurations.</p>
                    </div>
                    <a href="<%= ctx %>/templates/users_template.json" download="users_template.json" class="btn btn-outline-primary btn-sm">
                        <i class="bi bi-download me-1"></i>Download JSON Template
                    </a>
                </div>

                <!-- Drag & Drop Zone -->
                <div id="dropZone" class="text-center p-4 border border-2 border-dashed rounded-3 mb-3 cursor-pointer" 
                     style="border-color: rgba(var(--bs-primary-rgb), 0.4) !important; background: rgba(var(--bs-primary-rgb), 0.02); transition: all 0.2s ease;">
                    <i class="bi bi-cloud-upload text-primary" style="font-size: 2.2rem;"></i>
                    <h6 class="mt-2 fw-semibold mb-1" style="font-size:.9rem;">Drag and drop your JSON file here</h6>
                    <p class="text-muted mb-3" style="font-size:.8rem;">or click to browse local files</p>
                    <input type="file" id="importFileInput" accept=".json" style="display:none;"/>
                    <button type="button" class="btn btn-primary btn-sm px-3" onclick="document.getElementById('importFileInput').click()">Browse Files</button>
                </div>

                <!-- Preview area -->
                <div id="importPreviewContainer" class="d-none">
                    <h6 class="fw-bold mb-2 d-flex justify-content-between align-items-center" style="font-size:.85rem;">
                        <span>Parsed User Accounts (<span id="parsedCount">0</span>)</span>
                        <span id="importStatusBadge" class="badge">Ready to import</span>
                    </h6>
                    
                    <!-- Error Banner -->
                    <div id="importErrorAlert" class="rt-alert rt-alert-error mb-3 d-none">
                        <i class="bi bi-exclamation-circle-fill"></i> Please fix validation errors before submitting.
                    </div>

                    <div class="table-responsive rounded border" style="max-height: 250px; overflow-y: auto;">
                        <table class="table table-sm table-hover align-middle mb-0" style="font-size:.8rem;">
                            <thead class="table-light sticky-top">
                                <tr>
                                    <th>Name</th>
                                    <th>Username</th>
                                    <th>Email</th>
                                    <th>Role</th>
                                    <th>Dept</th>
                                    <th>CGPA</th>
                                    <th>Validation Status</th>
                                </tr>
                            </thead>
                            <tbody id="importPreviewBody">
                                <!-- Dynamic rows will go here -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <div class="modal-footer border-0 pt-0">
                <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" id="btnConfirmImport" class="btn btn-primary btn-sm px-3" disabled onclick="submitImport()">
                    <i class="bi bi-check-circle me-1"></i>Confirm Import
                </button>
            </div>

            <!-- Hidden submission form -->
            <form id="importUsersForm" method="post" action="<%= ctx %>/coordinator/users">
                <input type="hidden" name="action" value="importUsers"/>
                <div id="importHiddenInputs"></div>
            </form>
        </div>
    </div>
</div>

<script>
(function () {
    var searchInput  = document.getElementById('searchInput');
    var filterRole   = document.getElementById('filterRole');
    var filterStatus = document.getElementById('filterStatus');
    var tbody        = document.getElementById('usersBody');
    var selectAll    = document.getElementById('selectAll');
    var bulkBar      = document.getElementById('bulkBar');
    var selCount     = document.getElementById('selCount');
    var visibleCount = document.getElementById('visibleCount');
    var noResults    = document.getElementById('noResults');

    function applyFilters() {
        var q      = searchInput  ? searchInput.value.trim().toLowerCase()  : '';
        var role   = filterRole   ? filterRole.value                        : '';
        var status = filterStatus ? filterStatus.value                      : '';

        if (!tbody) return;
        var rows    = tbody.querySelectorAll('tr');
        var visible = 0;

        rows.forEach(function (row) {
            var name     = row.dataset.name     || '';
            var username = row.dataset.username || '';
            var email    = row.dataset.email    || '';
            var rowRole  = row.dataset.role     || '';
            var rowStat  = row.dataset.status   || '';

            var matchQ      = !q      || name.includes(q) || username.includes(q) || email.includes(q);
            var matchRole   = !role   || rowRole === role;
            var matchStatus = !status || rowStat === status;

            if (matchQ && matchRole && matchStatus) {
                row.style.display = '';
                visible++;
            } else {
                row.style.display = 'none';
                var cb = row.querySelector('.row-check');
                if (cb) cb.checked = false;
            }
        });

        if (visibleCount) visibleCount.textContent = visible;
        if (noResults) noResults.classList.toggle('d-none', visible > 0);
        updateBulkBar();
        updateSelectAllState();
    }

    function getChecked() {
        if (!tbody) return [];
        return Array.from(tbody.querySelectorAll('.row-check:checked'));
    }

    function updateBulkBar() {
        var checked = getChecked();
        if (!bulkBar) return;
        if (checked.length > 0) {
            bulkBar.classList.remove('d-none');
            selCount.textContent = checked.length + ' selected';
        } else {
            bulkBar.classList.add('d-none');
        }
    }

    function updateSelectAllState() {
        if (!tbody || !selectAll) return;
        var visibleChecks = Array.from(tbody.querySelectorAll('tr'))
            .filter(function(r){ return r.style.display !== 'none'; })
            .map(function(r){ return r.querySelector('.row-check'); })
            .filter(Boolean);

        var allChecked  = visibleChecks.length > 0 && visibleChecks.every(function(c){ return c.checked; });
        var someChecked = visibleChecks.some(function(c){ return c.checked; });
        selectAll.checked       = allChecked;
        selectAll.indeterminate = !allChecked && someChecked;
    }

    if (selectAll) {
        selectAll.addEventListener('change', function () {
            if (!tbody) return;
            tbody.querySelectorAll('tr').forEach(function (row) {
                if (row.style.display === 'none') return;
                var cb = row.querySelector('.row-check');
                if (cb) cb.checked = selectAll.checked;
            });
            updateBulkBar();
        });
    }

    if (tbody) {
        tbody.addEventListener('change', function (e) {
            if (e.target.classList.contains('row-check')) {
                updateBulkBar();
                updateSelectAllState();
            }
        });
    }

    if (searchInput)  searchInput.addEventListener('input',  applyFilters);
    if (filterRole)   filterRole.addEventListener('change',  applyFilters);
    if (filterStatus) filterStatus.addEventListener('change', applyFilters);

    window.bulkDeactivate = function () {
        var checked = getChecked();
        if (checked.length === 0) return;
        if (!confirm('Deactivate ' + checked.length + ' selected user(s)?')) return;
        var container = document.getElementById('bulkDeactivateIds');
        container.innerHTML = '';
        checked.forEach(function (cb) {
            var inp = document.createElement('input');
            inp.type  = 'hidden';
            inp.name  = 'ids';
            inp.value = cb.value;
            container.appendChild(inp);
        });
        document.getElementById('bulkDeactivateForm').submit();
    };

    window.bulkDelete = function () {
        var checked = getChecked();
        if (checked.length === 0) return;
        if (!confirm('Permanently DELETE ' + checked.length + ' selected user(s)? This cannot be undone.')) return;
        var container = document.getElementById('bulkDeleteIds');
        container.innerHTML = '';
        checked.forEach(function (cb) {
            var inp = document.createElement('input');
            inp.type  = 'hidden';
            inp.name  = 'ids';
            inp.value = cb.value;
            container.appendChild(inp);
        });
        document.getElementById('bulkDeleteForm').submit();
    };

    // ── Bulk JSON Import Logic ────────────────────────────────────────────────
    var dropZone = document.getElementById('dropZone');
    var fileInput = document.getElementById('importFileInput');
    var parsedUsers = [];

    if (dropZone && fileInput) {
        dropZone.addEventListener('dragover', function (e) {
            e.preventDefault();
            dropZone.style.backgroundColor = 'rgba(var(--bs-primary-rgb), 0.08)';
            dropZone.style.borderColor = 'var(--bs-primary)';
        });
        
        dropZone.addEventListener('dragleave', function () {
            dropZone.style.backgroundColor = 'rgba(var(--bs-primary-rgb), 0.02)';
            dropZone.style.borderColor = 'rgba(var(--bs-primary-rgb), 0.4)';
        });
        
        dropZone.addEventListener('drop', function (e) {
            e.preventDefault();
            dropZone.style.backgroundColor = 'rgba(var(--bs-primary-rgb), 0.02)';
            dropZone.style.borderColor = 'rgba(var(--bs-primary-rgb), 0.4)';
            if (e.dataTransfer.files.length > 0) {
                fileInput.files = e.dataTransfer.files;
                handleFile(e.dataTransfer.files[0]);
            }
        });
        
        fileInput.addEventListener('change', function () {
            if (fileInput.files.length > 0) {
                handleFile(fileInput.files[0]);
            }
        });
    }

    function handleFile(file) {
        if (!file) return;
        var reader = new FileReader();
        reader.onload = function (e) {
            var content = e.target.result;
            try {
                var data = JSON.parse(content);
                if (!Array.isArray(data)) {
                    showFileError("JSON must be a list of user objects (i.e. enclosed in square brackets [ ]).");
                    return;
                }
                processParsedData(data);
            } catch (err) {
                showFileError("Failed to parse JSON file. Please ensure it is valid JSON.");
            }
        };
        reader.readAsText(file);
    }

    function showFileError(msg) {
        alert(msg);
        document.getElementById('importPreviewContainer').classList.add('d-none');
        document.getElementById('btnConfirmImport').disabled = true;
    }

    function processParsedData(data) {
        parsedUsers = [];
        var usernames = [];
        var emails = [];

        data.forEach(function (item) {
            var username = (item.username || '').toString().trim();
            var email = (item.email || '').toString().trim();
            if (username) usernames.push(username);
            if (email) emails.push(email);
        });

        // Show loading state in preview
        var tbody = document.getElementById('importPreviewBody');
        tbody.innerHTML = '<tr><td colspan="6" class="text-center py-4"><span class="spinner-border spinner-border-sm text-primary me-2"></span>Checking database conflicts...</td></tr>';
        document.getElementById('importPreviewContainer').classList.remove('d-none');
        document.getElementById('btnConfirmImport').disabled = true;

        var params = new URLSearchParams();
        params.append('action', 'checkConflicts');
        usernames.forEach(function(u) { params.append('usernames', u); });
        emails.forEach(function(e) { params.append('emails', e); });
        
        fetch('<%= ctx %>/coordinator/users', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: params.toString()
        })
        .then(function(res) { return res.json(); })
        .then(function(conflicts) {
            renderPreview(data, conflicts);
        })
        .catch(function(err) {
            console.error("Conflict check failed:", err);
            renderPreview(data, { takenUsernames: [], takenEmails: [] });
        });
    }

    function renderPreview(data, conflicts) {
        var tbody = document.getElementById('importPreviewBody');
        tbody.innerHTML = '';
        
        var hasError = false;
        var usernameRegex = /^[A-Za-z0-9_]{3,30}$/;
        var emailRegex = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
        
        var takenUsernames = conflicts.takenUsernames || [];
        var takenEmails = conflicts.takenEmails || [];
        
        var seenUsernames = {};
        var seenEmails = {};

        data.forEach(function (item, index) {
            var username = (item.username || '').toString().trim();
            var password = (item.password || '').toString().trim();
            var passwordHash = (item.password_hash || '').toString().trim();
            var fullName = (item.fullName || item.full_name || '').toString().trim();
            var email = (item.email || '').toString().trim();
            var phone = (item.phone || '').toString().trim();
            var department = (item.department || '').toString().trim();
            var role = (item.role || '').toString().trim().toUpperCase();
            var active = item.active !== undefined ? (item.active === true || item.active === 1 || item.active === '1' || item.active === 'true' || item.active === 'ACTIVE') : true;
            var cgpa = item.cgpa !== undefined ? (item.cgpa || '').toString().trim() : '';

            var errors = [];
            
            if (!username) {
                errors.push("Username is required");
            } else {
                if (!usernameRegex.test(username)) {
                    errors.push("Username must be 3-30 chars (letters, numbers, underscore)");
                }
                if (takenUsernames.indexOf(username) !== -1) {
                    errors.push("Username already exists in database");
                }
                if (seenUsernames[username.toLowerCase()]) {
                    errors.push("Duplicate username in JSON");
                }
                seenUsernames[username.toLowerCase()] = true;
            }

            if (!password && !passwordHash) {
                errors.push("Password or password_hash is required");
            } else if (password) {
                if (password.length < 8) errors.push("Password must be >= 8 chars");
                if (!/[0-9]/.test(password)) errors.push("Password must contain a digit");
                if (!/[a-z]/.test(password)) errors.push("Password must contain a lowercase letter");
                if (!/[A-Z]/.test(password)) errors.push("Password must contain an uppercase letter");
            }

            if (!fullName) errors.push("Full name is required");

            if (!email) {
                errors.push("Email is required");
            } else {
                if (!emailRegex.test(email)) {
                    errors.push("Invalid email format");
                }
                if (takenEmails.indexOf(email.toLowerCase()) !== -1) {
                    errors.push("Email already registered in database");
                }
                if (seenEmails[email.toLowerCase()]) {
                    errors.push("Duplicate email in JSON");
                }
                seenEmails[email.toLowerCase()] = true;
            }

            if (!role) {
                errors.push("Role is required");
            } else if (role !== 'STUDENT' && role !== 'SUPERVISOR' && role !== 'COORDINATOR') {
                errors.push("Role must be STUDENT, SUPERVISOR, or COORDINATOR");
            }

            if (role === 'STUDENT' && cgpa) {
                var parsedCgpa = parseFloat(cgpa);
                if (isNaN(parsedCgpa) || parsedCgpa < 0 || parsedCgpa > 4.0) {
                    errors.push("CGPA must be a number between 0.00 and 4.00");
                }
            }

            var isValid = errors.length === 0;
            if (!isValid) {
                hasError = true;
            }

            parsedUsers.push({
                username: username,
                password: password,
                passwordHash: passwordHash,
                fullName: fullName,
                email: email,
                phone: phone,
                department: department,
                role: role,
                active: active,
                cgpa: role === 'STUDENT' ? cgpa : '',
                isValid: isValid
            });

            var tr = document.createElement('tr');
            tr.className = isValid ? 'table-success-light' : 'table-danger-light';
            
            tr.innerHTML = '<td><div class="fw-semibold">' + escapeHtml(fullName || '—') + '</div></td>' +
                '<td><code>' + escapeHtml(username || '—') + '</code></td>' +
                '<td>' + escapeHtml(email || '—') + '</td>' +
                '<td><span class="badge ' + (role === 'COORDINATOR' ? 'bg-warning text-dark' : role === 'SUPERVISOR' ? 'bg-success' : 'bg-primary') + '">' + escapeHtml(role || '—') + '</span></td>' +
                '<td class="text-muted">' + escapeHtml(department || '—') + '</td>' +
                '<td>' + escapeHtml(role === 'STUDENT' && cgpa ? cgpa : '—') + '</td>' +
                '<td>' + (isValid 
                    ? '<span class="text-success fw-semibold"><i class="bi bi-check-circle-fill me-1"></i>Ready</span>'
                    : '<span class="text-danger fw-semibold" title="' + escapeHtml(errors.join(', ')) + '"><i class="bi bi-x-circle-fill me-1"></i>' + escapeHtml(errors.join('; ')) + '</span>'
                ) + '</td>';
            tbody.appendChild(tr);
        });

        document.getElementById('parsedCount').textContent = data.length;
        document.getElementById('importPreviewContainer').classList.remove('d-none');
        
        var confirmBtn = document.getElementById('btnConfirmImport');
        var errBanner = document.getElementById('importErrorAlert');
        var statusBadge = document.getElementById('importStatusBadge');

        if (hasError) {
            confirmBtn.disabled = true;
            errBanner.classList.remove('d-none');
            statusBadge.className = 'badge bg-danger';
            statusBadge.textContent = 'Has Errors';
        } else {
            confirmBtn.disabled = false;
            errBanner.classList.add('d-none');
            statusBadge.className = 'badge bg-success';
            statusBadge.textContent = 'All Valid';
        }
    }

    function escapeHtml(text) {
        if (!text) return '';
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    window.submitImport = function () {
        if (parsedUsers.length === 0) return;
        var container = document.getElementById('importHiddenInputs');
        container.innerHTML = '';
        
        parsedUsers.forEach(function (user, idx) {
            appendHidden(container, 'users[' + idx + '].username', user.username);
            appendHidden(container, 'users[' + idx + '].password', user.password);
            appendHidden(container, 'users[' + idx + '].password_hash', user.passwordHash);
            appendHidden(container, 'users[' + idx + '].fullName', user.fullName);
            appendHidden(container, 'users[' + idx + '].email', user.email);
            appendHidden(container, 'users[' + idx + '].phone', user.phone);
            appendHidden(container, 'users[' + idx + '].department', user.department);
            appendHidden(container, 'users[' + idx + '].role', user.role);
            appendHidden(container, 'users[' + idx + '].active', user.active ? 'true' : 'false');
            appendHidden(container, 'users[' + idx + '].cgpa', user.cgpa || '');
        });
        
        document.getElementById('importUsersForm').submit();
    };

    function appendHidden(parent, name, value) {
        var inp = document.createElement('input');
        inp.type = 'hidden';
        inp.name = name;
        inp.value = value;
        parent.appendChild(inp);
    }

    // Toggle manual CGPA field visibility in manual user creation form based on selected role
    var roleSelect = document.getElementById('manualRoleSelect');
    var cgpaField = document.getElementById('manualCgpaField');
    if (roleSelect && cgpaField) {
        function toggleManualCgpa() {
            if (roleSelect.value === 'STUDENT') {
                cgpaField.style.display = 'block';
            } else {
                cgpaField.style.display = 'none';
                var inp = cgpaField.querySelector('input');
                if (inp) inp.value = '';
            }
        }
        roleSelect.addEventListener('change', toggleManualCgpa);
        toggleManualCgpa(); // run once initially
    }

    applyFilters();
})();
</script>

<jsp:include page="/views/common/footer.jsp"/>

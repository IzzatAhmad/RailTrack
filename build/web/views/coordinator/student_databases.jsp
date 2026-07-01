<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.railtrack.system.controller.CoordinatorDatabaseServlet.StudentDatabase" %>
<%
    String ctx = request.getContextPath();
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
    
    List<StudentDatabase> studentDatabases = (List<StudentDatabase>) request.getAttribute("studentDatabases");
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/coordinator/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">Student Databases</span>
</nav>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h4 class="fw-bold mb-0">Student Databases</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">Manage dedicated database instances for student projects</p>
    </div>
</div>

<% if (errorMessage != null) { %>
<div class="rt-alert rt-alert-error rt-flash mb-3">
    <i class="bi bi-exclamation-circle-fill"></i> <%= errorMessage %>
</div>
<% } %>
<% if (successMessage != null) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i> <%= successMessage %>
</div>
<% } %>

<div class="rt-card">
    <div class="table-responsive">
        <table class="table table-hover mb-0 align-middle">
            <thead class="table-light">
                <tr>
                    <th class="ps-4">Database Name</th>
                    <th>Project ID</th>
                    <th>Student Name (Matric)</th>
                    <th>Size (MB)</th>
                    <th>Tables</th>
                    <th class="text-end pe-4">Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (studentDatabases == null || studentDatabases.isEmpty()) { %>
                    <tr>
                        <td colspan="6" class="text-center py-4 text-muted">
                            <i class="bi bi-database-slash fs-4 d-block mb-2"></i>
                            No student databases found.
                        </td>
                    </tr>
                <% } else {
                    for (StudentDatabase db : studentDatabases) { %>
                    <tr>
                        <td class="ps-4">
                            <i class="bi bi-database-fill text-primary me-2"></i>
                            <span class="fw-medium"><%= db.dbName %></span>
                        </td>
                        <td>
                            <% if (db.projectId > 0) { %>
                                <span class="badge bg-light text-dark border">#<%= db.projectId %></span>
                            <% } else { %>
                                <span class="text-muted">-</span>
                            <% } %>
                        </td>
                        <td>
                            <% if (db.studentName != null) { %>
                                <%= db.studentName %> 
                                <span class="text-muted" style="font-size:.8rem;">(<%= db.matricNumber %>)</span>
                            <% } else { %>
                                <span class="text-muted fst-italic">Unknown / Deleted</span>
                            <% } %>
                        </td>
                        <td>
                            <span class="rt-mono"><%= db.sizeMb %> MB</span>
                        </td>
                        <td>
                            <span class="badge rounded-pill bg-secondary"><%= db.tableCount %></span>
                        </td>
                        <td class="text-end pe-4">
                            <form method="post" action="<%= ctx %>/coordinator/databases" class="d-inline" onsubmit="return confirm('Are you ABSOLUTELY sure you want to drop database <%= db.dbName %>? All data inside it will be permanently lost.');">
                                <input type="hidden" name="action" value="drop">
                                <input type="hidden" name="dbName" value="<%= db.dbName %>">
                                <button type="submit" class="btn btn-sm btn-outline-danger" title="Drop Database">
                                    <i class="bi bi-trash3"></i> Drop
                                </button>
                            </form>
                        </td>
                    </tr>
                <%  }
                } %>
            </tbody>
        </table>
    </div>
</div>

<script>
    // Fade out flash messages automatically
    setTimeout(() => {
        document.querySelectorAll('.rt-flash').forEach(el => {
            el.style.transition = 'opacity 0.5s';
            el.style.opacity = '0';
            setTimeout(() => el.remove(), 500);
        });
    }, 4000);
</script>

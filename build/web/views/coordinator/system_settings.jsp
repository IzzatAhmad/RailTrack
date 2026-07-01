<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String semesterStart = (String) request.getAttribute("semester_start_date");
    String semesterEnd = (String) request.getAttribute("semester_end_date");
%>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="System Settings" />
</jsp:include>

<div class="container py-4" style="max-width: 800px; margin: 0 auto;">
    
    <!-- Breadcrumb -->
    <nav style="font-size:.82rem;margin-bottom:1.25rem;">
        <a href="<%= ctx %>/coordinator/dashboard" style="color:var(--rt-primary);text-decoration:none;">
            <i class="bi bi-house me-1"></i>Dashboard
        </a>
        <span class="mx-1" style="color:var(--rt-muted);">/</span>
        <span style="color:var(--rt-muted);">System Settings</span>
    </nav>

    <div class="d-flex align-items-center mb-4">
        <h2 class="fw-bold mb-0">System Settings</h2>
    </div>

    <% if ("updated".equals(request.getParameter("success"))) { %>
        <div class="alert alert-success d-flex align-items-center" role="alert" style="border-radius: 12px;">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i> 
            <div>System settings updated successfully.</div>
        </div>
    <% } %>
    <% if (request.getAttribute("formError") != null) { %>
        <div class="alert alert-danger d-flex align-items-center" role="alert" style="border-radius: 12px;">
            <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i> 
            <div><%= request.getAttribute("formError") %></div>
        </div>
    <% } %>

    <div class="card shadow-sm border-0" style="border-radius: 12px;">
        <div class="card-header bg-white border-bottom-0 pt-4 pb-0 px-4">
            <p class="text-muted mb-0">Configure global settings like the active semester bounds. These dates will be used to limit features such as Logbook entries.</p>
        </div>
        <div class="card-body p-4">
            <form action="<%= ctx %>/coordinator/settings" method="post">
                
                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-secondary">Semester Start Date</label>
                        <input type="date" class="form-control" name="semester_start_date" required 
                               value="<%= semesterStart != null ? semesterStart : "" %>" />
                        <div class="form-text">The first day of the current semester.</div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-secondary">Semester End Date</label>
                        <input type="date" class="form-control" name="semester_end_date" required 
                               value="<%= semesterEnd != null ? semesterEnd : "" %>" />
                        <div class="form-text">The last day of the current semester.</div>
                    </div>
                </div>

                <div class="d-flex justify-content-end mt-4 pt-3 border-top">
                    <a href="<%= ctx %>/coordinator/dashboard" class="btn btn-light me-2 fw-semibold px-4">Cancel</a>
                    <button type="submit" class="btn btn-primary fw-semibold px-4">
                        <i class="bi bi-save me-2"></i>Save Settings
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp"/>

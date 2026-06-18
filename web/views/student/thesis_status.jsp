<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.railtrack.system.model.User" %>
<%@ page import="com.railtrack.system.model.Project" %>
<%@ page import="com.railtrack.system.model.StudentDocument" %>
<%@ page import="java.util.Map" %>
<%
    String ctx = request.getContextPath();
    User student = (User) request.getAttribute("student");
    Project project = (Project) request.getAttribute("project");
    Map<String, StudentDocument> uploadedDocs = (Map<String, StudentDocument>) request.getAttribute("uploadedDocs");
%>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Thesis Status" />
    <jsp:param name="activeMenu" value="thesis" />
</jsp:include>

<div class="container py-4" style="max-width: 800px; margin: 0 auto;">
    
    <!-- Breadcrumb -->
    <nav style="font-size:.82rem;margin-bottom:1.25rem;">
        <a href="<%= ctx %>/student/dashboard" style="color:var(--rt-primary);text-decoration:none;">
            <i class="bi bi-house me-1"></i>Dashboard
        </a>
        <span class="mx-1" style="color:var(--rt-muted);">/</span>
        <span style="color:var(--rt-muted);">Thesis Status</span>
    </nav>

    <div class="d-flex align-items-center mb-4">
        <h2 class="fw-bold mb-0">Thesis Status</h2>
    </div>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger" role="alert" style="border-radius: 12px;">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= request.getAttribute("error") %>
        </div>
    <% } %>

    <div class="card shadow-sm border-0 mb-4" style="border-radius: 12px;">
        <div class="card-header bg-white border-bottom-0 pt-4 pb-0 px-4">
            <h5 class="fw-bold mb-0">Project Information</h5>
        </div>
        <div class="card-body p-4">
            <% if (project != null) { %>
                <div class="row mb-3">
                    <div class="col-sm-4 text-muted fw-semibold">Title</div>
                    <div class="col-sm-8"><%= project.getTitle() %></div>
                </div>
                <div class="row mb-3">
                    <div class="col-sm-4 text-muted fw-semibold">Status</div>
                    <div class="col-sm-8">
                        <% if (project.getStatus() == Project.Status.COMPLETED) { %>
                            <span class="badge bg-success">COMPLETED</span>
                        <% } else if (project.getStatus() == Project.Status.ACTIVE) { %>
                            <span class="badge bg-primary">ACTIVE</span>
                        <% } else if (project.getStatus() == Project.Status.PENDING) { %>
                            <span class="badge bg-warning text-dark">PENDING</span>
                        <% } else { %>
                            <span class="badge bg-secondary"><%= project.getStatus() %></span>
                        <% } %>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-sm-4 text-muted fw-semibold">Supervisor</div>
                    <div class="col-sm-8"><%= project.hasSupervisor() ? project.getSupervisorName() : "Not Assigned" %></div>
                </div>
                <div class="row">
                    <div class="col-sm-4 text-muted fw-semibold">Current Milestone</div>
                    <div class="col-sm-8"><%= project.getCurrentMilestoneNo() %></div>
                </div>
            <% } else { %>
                <div class="text-muted"><i class="bi bi-info-circle me-2"></i>You have not registered a project yet.</div>
                <a href="<%= ctx %>/student/dashboard" class="btn btn-outline-primary mt-3 btn-sm">Go to Dashboard</a>
            <% } %>
        </div>
    </div>

    <div class="card shadow-sm border-0" style="border-radius: 12px;">
        <div class="card-header bg-white border-bottom-0 pt-4 pb-0 px-4 d-flex justify-content-between align-items-center">
            <h5 class="fw-bold mb-0">Uploaded Documents</h5>
            <a href="<%= ctx %>/thesis/upload" class="btn btn-sm btn-primary"><i class="bi bi-upload me-1"></i> Upload / Update Files</a>
        </div>
        <div class="card-body p-4">
            <ul class="list-group list-group-flush">
                <!-- Thesis PDF -->
                <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                    <div>
                        <div class="fw-semibold">Thesis PDF</div>
                        <small class="text-muted">Final thesis document</small>
                    </div>
                    <% if (uploadedDocs != null && uploadedDocs.containsKey("THESIS_PDF")) { %>
                        <span class="badge bg-success rounded-pill px-3 py-2"><i class="bi bi-check-circle me-1"></i> Uploaded</span>
                    <% } else { %>
                        <span class="badge bg-secondary rounded-pill px-3 py-2"><i class="bi bi-x-circle me-1"></i> Pending</span>
                    <% } %>
                </li>

                <!-- Thesis Latex Zip -->
                <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                    <div>
                        <div class="fw-semibold">Thesis Latex Zip</div>
                        <small class="text-muted">Source files for the thesis</small>
                    </div>
                    <% if (uploadedDocs != null && uploadedDocs.containsKey("THESIS_LATEX_ZIP")) { %>
                        <span class="badge bg-success rounded-pill px-3 py-2"><i class="bi bi-check-circle me-1"></i> Uploaded</span>
                    <% } else { %>
                        <span class="badge bg-secondary rounded-pill px-3 py-2"><i class="bi bi-x-circle me-1"></i> Pending</span>
                    <% } %>
                </li>

                <!-- Project Zip -->
                <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                    <div>
                        <div class="fw-semibold">Project Zip</div>
                        <small class="text-muted">Source code and application files</small>
                    </div>
                    <% if (uploadedDocs != null && uploadedDocs.containsKey("PROJECT_ZIP")) { %>
                        <span class="badge bg-success rounded-pill px-3 py-2"><i class="bi bi-check-circle me-1"></i> Uploaded</span>
                    <% } else { %>
                        <span class="badge bg-secondary rounded-pill px-3 py-2"><i class="bi bi-x-circle me-1"></i> Pending</span>
                    <% } %>
                </li>
            </ul>
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp"/>

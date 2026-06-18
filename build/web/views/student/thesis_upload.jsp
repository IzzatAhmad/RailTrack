<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.railtrack.system.model.User" %>
<%@ page import="com.railtrack.system.model.StudentDocument" %>
<%@ page import="java.util.Map" %>
<%
    String ctx = request.getContextPath();
    User student = (User) request.getAttribute("student");
    String matricNo = student != null && student.getUsername() != null ? student.getUsername() : "";
    String name = student != null && student.getFullName() != null ? student.getFullName() : "";
    
    Map<String, StudentDocument> uploadedDocs = (Map<String, StudentDocument>) request.getAttribute("uploadedDocs");
%>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Thesis Upload" />
    <jsp:param name="activeMenu" value="thesis" />
</jsp:include>

<div class="container py-4" style="max-width: 800px; margin: 0 auto;">
    
    <!-- Breadcrumb -->
    <nav style="font-size:.82rem;margin-bottom:1.25rem;">
        <a href="<%= ctx %>/student/dashboard" style="color:var(--rt-primary);text-decoration:none;">
            <i class="bi bi-house me-1"></i>Dashboard
        </a>
        <span class="mx-1" style="color:var(--rt-muted);">/</span>
        <span style="color:var(--rt-muted);">Thesis Upload</span>
    </nav>

    <div class="d-flex align-items-center mb-4">
        <h2 class="fw-bold mb-0">Thesis Upload</h2>
    </div>

    <% if ("true".equals(request.getParameter("success"))) { %>
        <div class="alert alert-success d-flex align-items-center" role="alert" style="border-radius: 12px;">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i> 
            <div>Your files have been successfully uploaded.</div>
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
            <p class="text-muted mb-0"><%= request.getAttribute("instructions") != null ? request.getAttribute("instructions") : "Please fill out the details and upload your project files. Fields marked with <span class=\"text-danger\">*</span> are required. Uploading a file again will overwrite the existing one." %></p>
        </div>
        <div class="card-body p-4">
            <form action="<%= ctx %>/thesis/upload" method="post" enctype="multipart/form-data">
                
                <div class="row mb-4">
                    <div class="col-md-6 mb-3 mb-md-0">
                        <label class="form-label fw-semibold text-secondary">Matric No <span class="text-danger">*</span></label>
                        <input type="text" class="form-control bg-light" value="<%= matricNo %>" readonly>
                        <input type="hidden" name="matricNo" value="<%= matricNo %>">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-secondary">Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control bg-light" value="<%= name %>" readonly>
                        <input type="hidden" name="name" value="<%= name %>">
                    </div>
                </div>

                <hr class="text-muted mb-4">

                <div class="mb-4">
                    <div class="d-flex justify-content-between align-items-end mb-2">
                        <label class="form-label fw-semibold mb-0">Thesis PDF <span class="text-danger">*</span></label>
                        <% if (uploadedDocs != null && uploadedDocs.containsKey("THESIS_PDF")) { %>
                            <span class="badge bg-success"><i class="bi bi-check-circle me-1"></i> Uploaded: <%= uploadedDocs.get("THESIS_PDF").getFileName() %></span>
                        <% } else { %>
                            <span class="badge bg-secondary"><i class="bi bi-x-circle me-1"></i> Not Uploaded</span>
                        <% } %>
                    </div>
                    <input class="form-control" type="file" name="thesis" accept=".pdf" <%= uploadedDocs != null && uploadedDocs.containsKey("THESIS_PDF") ? "" : "required" %>>
                    <div class="form-text">Upload 1 supported file: PDF. Max 100 MB.</div>
                </div>

                <div class="mb-4">
                    <div class="d-flex justify-content-between align-items-end mb-2">
                        <label class="form-label fw-semibold mb-0">Thesis Latex Zip <span class="text-danger">*</span></label>
                        <% if (uploadedDocs != null && uploadedDocs.containsKey("THESIS_LATEX_ZIP")) { %>
                            <span class="badge bg-success"><i class="bi bi-check-circle me-1"></i> Uploaded: <%= uploadedDocs.get("THESIS_LATEX_ZIP").getFileName() %></span>
                        <% } else { %>
                            <span class="badge bg-secondary"><i class="bi bi-x-circle me-1"></i> Not Uploaded</span>
                        <% } %>
                    </div>
                    <input class="form-control" type="file" name="latex_zip" accept=".zip" <%= uploadedDocs != null && uploadedDocs.containsKey("THESIS_LATEX_ZIP") ? "" : "required" %>>
                    <div class="form-text">Upload 1 supported file. Max 100 MB.</div>
                </div>

                <div class="mb-4">
                    <div class="d-flex justify-content-between align-items-end mb-2">
                        <label class="form-label fw-semibold mb-0">Project Zip</label>
                        <% if (uploadedDocs != null && uploadedDocs.containsKey("PROJECT_ZIP")) { %>
                            <span class="badge bg-success"><i class="bi bi-check-circle me-1"></i> Uploaded: <%= uploadedDocs.get("PROJECT_ZIP").getFileName() %></span>
                        <% } else { %>
                            <span class="badge bg-secondary"><i class="bi bi-x-circle me-1"></i> Not Uploaded</span>
                        <% } %>
                    </div>
                    <input class="form-control" type="file" name="project_zip" accept=".zip">
                    <div class="form-text">Upload 1 supported file. Max 10 GB.</div>
                </div>

                <div class="d-flex justify-content-end mt-4">
                    <a href="<%= ctx %>/student/dashboard" class="btn btn-light me-2 fw-semibold px-4">Cancel</a>
                    <button type="submit" class="btn btn-primary fw-semibold px-4">
                        <i class="bi bi-cloud-arrow-up me-2"></i>Upload Files
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp"/>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String instructions = (String) request.getAttribute("instructions");
%>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Thesis Upload Settings" />
</jsp:include>

<div class="container py-4" style="max-width: 800px; margin: 0 auto;">
    
    <!-- Breadcrumb -->
    <nav style="font-size:.82rem;margin-bottom:1.25rem;">
        <a href="<%= ctx %>/coordinator/dashboard" style="color:var(--rt-primary);text-decoration:none;">
            <i class="bi bi-house me-1"></i>Dashboard
        </a>
        <span class="mx-1" style="color:var(--rt-muted);">/</span>
        <a href="<%= ctx %>/coordinator/menu" style="color:var(--rt-primary);text-decoration:none;">Student Menu Management</a>
        <span class="mx-1" style="color:var(--rt-muted);">/</span>
        <span style="color:var(--rt-muted);">Thesis Upload Settings</span>
    </nav>

    <div class="d-flex align-items-center mb-4">
        <h2 class="fw-bold mb-0">Thesis Upload Instructions</h2>
    </div>

    <% if ("settings".equals(request.getParameter("success"))) { %>
        <div class="alert alert-success d-flex align-items-center" role="alert" style="border-radius: 12px;">
            <i class="bi bi-check-circle-fill me-2 fs-5"></i> 
            <div>Instructions updated successfully.</div>
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
            <p class="text-muted mb-0">Update the instructions shown to students on the Thesis Upload page.</p>
        </div>
        <div class="card-body p-4">
            <form action="<%= ctx %>/thesis/upload" method="post">
                
                <div class="mb-4">
                    <label class="form-label fw-semibold text-secondary">Instructions Content</label>
                    <textarea class="form-control" name="instructions" rows="5" required><%= instructions != null ? instructions : "" %></textarea>
                    <div class="form-text">You may use basic HTML tags like &lt;b&gt;, &lt;i&gt;, or &lt;span class="text-danger"&gt;...&lt;/span&gt;.</div>
                </div>

                <div class="d-flex justify-content-end mt-4">
                    <a href="<%= ctx %>/coordinator/menu" class="btn btn-light me-2 fw-semibold px-4">Cancel</a>
                    <button type="submit" class="btn btn-primary fw-semibold px-4">
                        <i class="bi bi-save me-2"></i>Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp"/>

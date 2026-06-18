<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.Rubric" %>
<%
    request.setAttribute("pageTitle", "Rubrics");
    String ctx = request.getContextPath();
    boolean canManageRubrics = Boolean.TRUE.equals(request.getAttribute("canManageRubrics"));
    Rubric rubric = (Rubric) request.getAttribute("rubric");
%>
<jsp:include page="/views/common/header.jsp"/>

<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/student/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Quick Access
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">Rubrics</span>
</nav>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h4 class="fw-bold mb-0">Rubrics</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">Assessment rubric for KP/IM FYP</p>
    </div>
    <% if (canManageRubrics && rubric != null) { %>
        <button class="btn btn-primary shadow-sm" data-bs-toggle="modal" data-bs-target="#editRubricModal">
            <i class="bi bi-pencil me-2"></i>Edit Content
        </button>
    <% } %>
</div>

<div class="rt-card mb-4">
    <div class="card-body p-0">
        <% if (rubric != null) { %>
            <%= rubric.getContent() %>
        <% } else { %>
            <div class="p-4 text-center text-muted">
                <i class="bi bi-journal-x" style="font-size: 2rem;"></i>
                <p class="mt-2">No rubric content found.</p>
            </div>
        <% } %>
    </div>
</div>

<% if (canManageRubrics && rubric != null) { %>
<!-- Edit Modal -->
<div class="modal fade" id="editRubricModal" tabindex="-1">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <form class="modal-content" action="<%= ctx %>/coordinator/rubrics-manage" method="post">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Edit Rubric Content</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="id" value="<%= rubric.getId() %>">
                <input type="hidden" name="section" value="<%= rubric.getSection().replace("\"", "&quot;") %>">
                <input type="hidden" name="title" value="<%= rubric.getTitle().replace("\"", "&quot;") %>">
                <input type="hidden" name="sort_order" value="<%= rubric.getSortOrder() %>">
                <input type="hidden" name="is_enabled" value="1">
                
                <div class="alert alert-info py-2" style="font-size: 0.85rem;">
                    <i class="bi bi-info-circle me-1"></i> Edit the raw HTML content of the rubric below. Be careful not to break the Bootstrap collapse logic!
                </div>
                <div class="mb-3">
                    <label class="form-label fw-bold">Raw HTML Content</label>
                    <textarea class="form-control font-monospace" name="content" rows="25" style="font-size: 0.85rem;" required><%= rubric.getContent().replace("<", "&lt;").replace(">", "&gt;") %></textarea>
                </div>
            </div>
            <div class="modal-footer bg-light">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn btn-primary px-4">Save Changes</button>
            </div>
        </form>
    </div>
</div>
<% } %>

<jsp:include page="/views/common/footer.jsp"/>

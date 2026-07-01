<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.DocumentType, com.railtrack.system.model.StudentDocument, java.util.List, java.time.format.DateTimeFormatter" %>
<%
    request.setAttribute("pageTitle", "Document Requirements Management");
    List<DocumentType> documentTypes = (List<DocumentType>) request.getAttribute("documentTypes");
    List<StudentDocument> studentUploads = (List<StudentDocument>) request.getAttribute("studentUploads");
    String success = request.getParameter("success");
    String formError = (String) request.getAttribute("formError");
    String ctx = request.getContextPath();
    
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- Flash Alerts -->
<% if ("type_added".equals(success)) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i> Document requirement added successfully.
</div>
<% } else if ("type_updated".equals(success)) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i> Document requirement updated successfully.
</div>
<% } else if ("type_deleted".equals(success)) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i> Document requirement deleted successfully.
</div>
<% } else if ("upload_deleted".equals(success)) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i> Student document upload removed successfully.
</div>
<% } %>

<% if (formError != null) { %>
<div class="rt-alert rt-alert-error mb-3">
    <i class="bi bi-exclamation-circle-fill"></i> <%= formError %>
</div>
<% } %>

<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/coordinator/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <a href="<%= ctx %>/coordinator/menu" style="color:var(--rt-primary);text-decoration:none;">Student Menu Management</a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">Documents & Requirements Management</span>
</nav>

<!-- Page Header -->
<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h4 class="fw-bold mb-0">Documents & Requirements Management</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">
            Configure dynamic file requirements for students and manage active student uploads.
        </p>
    </div>
    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addTypeModal">
        <i class="bi bi-plus-lg me-1"></i>Add Requirement Type
    </button>
</div>

<!-- Tab Navigation -->
<ul class="nav nav-tabs mb-4" id="documentsTab" role="tablist">
    <li class="nav-item" role="presentation">
        <button class="nav-link active fw-semibold" id="uploads-tab" data-bs-toggle="tab" data-bs-target="#uploads" type="button" role="tab">
            <i class="bi bi-file-earmark-arrow-up me-1"></i>Student Uploads
        </button>
    </li>
    <li class="nav-item" role="presentation">
        <button class="nav-link fw-semibold" id="requirements-tab" data-bs-toggle="tab" data-bs-target="#requirements" type="button" role="tab">
            <i class="bi bi-gear-fill me-1"></i>Requirement Templates
        </button>
    </li>
</ul>

<div class="tab-content" id="documentsTabContent">
    <!-- Tab 1: Student Uploads List -->
    <div class="tab-pane fade show active" id="uploads" role="tabpanel">
        <div class="rt-card p-0">
            <div class="rt-card-header">
                <i class="bi bi-file-earmark-text me-1"></i> Active Student Document Uploads
                <span class="badge bg-secondary ms-auto"><%= studentUploads != null ? studentUploads.size() : 0 %></span>
            </div>
            <div class="table-responsive">
                <table class="table mb-0 align-middle">
                    <thead>
                        <tr>
                            <th>Student</th>
                            <th>Project Title</th>
                            <th>Requirement</th>
                            <th>File Name</th>
                            <th>Uploaded At</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (studentUploads == null || studentUploads.isEmpty()) { %>
                            <tr>
                                <td colspan="6" class="text-center text-muted py-4">No student uploads found.</td>
                            </tr>
                        <% } else {
                            for (StudentDocument doc : studentUploads) { %>
                                <tr>
                                    <td class="fw-semibold"><%= doc.getStudentName() %></td>
                                    <td><%= doc.getProjectTitle() != null ? doc.getProjectTitle() : "<span class='text-muted' style='font-size:0.8rem;'>No Project</span>" %></td>
                                    <td>
                                        <span class="badge bg-primary px-2 py-1" style="font-size:0.75rem;"><%= doc.getDocumentTypeName() %></span>
                                    </td>
                                    <td>
                                        <a href="<%= ctx %>/file/document/<%= doc.getId() %>" target="_blank" class="text-decoration-none">
                                            <i class="bi bi-file-earmark-pdf text-danger me-1"></i><%= doc.getFileName() %>
                                        </a>
                                    </td>
                                    <td class="text-muted" style="font-size:0.8rem;"><%= doc.getUploadedAt().format(dtf) %></td>
                                    <td>
                                        <!-- Wipe Upload Button -->
                                        <form method="post" action="<%= ctx %>/coordinator/documents" class="d-inline" onsubmit="return confirm('Wipe upload file \'<%= doc.getFileName() %>\'?')">
                                            <input type="hidden" name="action" value="delete_upload" />
                                            <input type="hidden" name="id" value="<%= doc.getId() %>" />
                                            <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete/Wipe upload file">
                                                <i class="bi bi-trash-fill"></i> Wipe
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <% }
                        } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Tab 2: Requirement Templates CRUD -->
    <div class="tab-pane fade" id="requirements" role="tabpanel">
        <div class="rt-card p-0">
            <div class="rt-card-header">
                <i class="bi bi-gear me-1"></i> Document Type Requirements
                <span class="badge bg-secondary ms-auto"><%= documentTypes != null ? documentTypes.size() : 0 %></span>
            </div>
            <div class="table-responsive">
                <table class="table mb-0 align-middle">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Requirement Name</th>
                            <th>Key Code</th>
                            <th>Description</th>
                            <th>Created At</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (documentTypes == null || documentTypes.isEmpty()) { %>
                            <tr>
                                <td colspan="6" class="text-center text-muted py-4">No requirement types found.</td>
                            </tr>
                        <% } else {
                            for (DocumentType type : documentTypes) { %>
                                <tr>
                                    <td class="text-muted" style="font-size:.8rem;"><%= type.getId() %></td>
                                    <td class="fw-semibold"><%= type.getName() %></td>
                                    <td><code style="font-size:.78rem;"><%= type.getKeyCode() %></code></td>
                                    <td class="text-muted" style="font-size:.8rem; max-width:250px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                                        <%= type.getDescription() != null ? type.getDescription() : "-" %>
                                    </td>
                                    <td class="text-muted" style="font-size:0.8rem;"><%= type.getCreatedAt().format(dtf) %></td>
                                    <td>
                                        <!-- Edit -->
                                        <button class="btn btn-sm btn-outline-primary me-1" 
                                                onclick="openEditTypeModal(<%= type.getId() %>, '<%= escapeJs(type.getName()) %>', '<%= escapeJs(type.getKeyCode()) %>', '<%= escapeJs(type.getDescription()) %>')"
                                                title="Edit Requirement">
                                            <i class="bi bi-pencil"></i>
                                        </button>
                                        
                                        <!-- Delete -->
                                        <form method="post" action="<%= ctx %>/coordinator/documents" class="d-inline" onsubmit="return confirm('Wipe requirement type \'<%= type.getName() %>\'? Wiping this will automatically purge all active student document uploads associated with it.')">
                                            <input type="hidden" name="action" value="delete_type" />
                                            <input type="hidden" name="id" value="<%= type.getId() %>" />
                                            <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete requirement type">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <% }
                        } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Add Type -->
<div class="modal fade" id="addTypeModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px; border:1px solid var(--rt-border);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold"><i class="bi bi-plus-lg me-2 text-primary"></i>Add Requirement Type</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= ctx %>/coordinator/documents">
                <input type="hidden" name="action" value="add_type" />
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Requirement Name *</label>
                        <input type="text" name="name" class="form-control" placeholder="e.g. SPMP" required />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Key Code * <small class="text-muted">(Unique label key, e.g. spmp)</small></label>
                        <input type="text" name="keyCode" class="form-control" placeholder="e.g. spmp" required />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Description</label>
                        <textarea name="description" class="form-control" placeholder="Descriptive explanation..." rows="3"></textarea>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm">
                        <i class="bi bi-plus-lg me-1"></i>Add Requirement
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Edit Type -->
<div class="modal fade" id="editTypeModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px; border:1px solid var(--rt-border);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold"><i class="bi bi-pencil me-2 text-primary"></i>Edit Requirement Type</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= ctx %>/coordinator/documents" id="editTypeForm">
                <input type="hidden" name="action" value="edit_type" />
                <input type="hidden" name="id" id="editTypeId" />
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Requirement Name *</label>
                        <input type="text" name="name" id="editTypeName" class="form-control" required />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Key Code *</label>
                        <input type="text" name="keyCode" id="editTypeKeyCode" class="form-control" required />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Description</label>
                        <textarea name="description" id="editTypeDescription" class="form-control" rows="3"></textarea>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm">
                        <i class="bi bi-save me-1"></i>Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function openEditTypeModal(id, name, keyCode, description) {
        document.getElementById('editTypeId').value = id;
        document.getElementById('editTypeName').value = name;
        document.getElementById('editTypeKeyCode').value = keyCode;
        document.getElementById('editTypeDescription').value = description;
        new bootstrap.Modal(document.getElementById('editTypeModal')).show();
    }
</script>

<%!
private String escapeJs(String s) {
    if (s == null) return "";
    return s.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n");
}
%>

<jsp:include page="/views/common/footer.jsp"/>

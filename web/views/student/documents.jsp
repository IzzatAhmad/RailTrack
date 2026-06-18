<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.DocumentType, com.railtrack.system.model.StudentDocument, java.util.List, java.util.Map" %>
<%
    request.setAttribute("pageTitle", "My Documents");
    List<DocumentType> documentTypes = (List<DocumentType>) request.getAttribute("documentTypes");
    Map<Integer, StudentDocument> studentDocs = (Map<Integer, StudentDocument>) request.getAttribute("studentDocs");
    String success = request.getParameter("success");
    String formError = (String) request.getAttribute("formError");
    String ctx = request.getContextPath();
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- Navigation / Breadcrumbs -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/student/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-speedometer2 me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">My Documents</span>
</nav>

<!-- Alert Banners -->
<% if ("uploaded".equals(success)) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i> Document uploaded successfully.
</div>
<% } else if ("deleted".equals(success)) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i> Document deleted.
</div>
<% } %>

<% if (formError != null) { %>
<div class="rt-alert rt-alert-error mb-3" id="docAlertError">
    <i class="bi bi-exclamation-circle-fill"></i> <%= formError %>
</div>
<% } %>

<!-- Upload Header Bar -->
<div class="rt-card p-4 mb-4" style="background-color: #fafbfc;">
    <div class="d-flex align-items-center gap-3 text-secondary" style="cursor: pointer;" onclick="openUploadModal(0)">
        <i class="bi bi-cloud-arrow-up-fill text-muted" style="font-size: 1.8rem;"></i>
        <span class="fw-semibold" style="font-size: 1rem; color: #5c6f84;">Click Button to upload your file</span>
    </div>
</div>

<!-- Documents Grid Card Layout -->
<div class="rt-card p-4">
    <div class="row g-3">
        <% if (documentTypes == null || documentTypes.isEmpty()) { %>
            <div class="col-12 text-center text-muted py-5">
                <i class="bi bi-folder-x" style="font-size: 2.5rem;"></i>
                <p class="mt-2 fw-semibold">No document requirements defined by Coordinator.</p>
            </div>
        <% } else {
            for (DocumentType type : documentTypes) {
                StudentDocument doc = studentDocs != null ? studentDocs.get(type.getId()) : null;
                boolean isUploaded = doc != null;
        %>
            <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
                <div class="rt-card text-center p-3 h-100 d-flex flex-column align-items-center justify-content-between" 
                     style="border: 1px solid #f1f3f7; border-radius: 12px; min-height: 180px; background-color: #fafbfc; transition: transform 0.15s, box-shadow 0.15s;">
                    
                    <!-- Pill Button Trigger -->
                    <button type="button" 
                            class="w-100 py-2 btn-doc-pill fw-bold"
                            onclick="openUploadModal(<%= type.getId() %>)">
                        <%= type.getName() %>
                    </button>

                    <!-- Icon Slot (PDF or Dash) -->
                    <div class="mt-3 d-flex flex-column align-items-center justify-content-center flex-grow-1">
                        <% if (isUploaded) { %>
                            <a href="<%= ctx %>/file/document/<%= doc.getId() %>" 
                               target="_blank" 
                               title="Open <%= doc.getFileName() %>" 
                               class="d-flex align-items-center justify-content-center text-decoration-none">
                                <i class="bi bi-file-earmark-pdf-fill text-danger" style="font-size: 2.2rem; cursor: pointer; transition: transform 0.1s;"></i>
                            </a>
                            <div class="text-muted text-truncate mt-1 px-2" style="font-size: 0.68rem; max-width: 130px;" title="<%= doc.getFileName() %>">
                                <%= doc.getFileName() %>
                            </div>
                            
                            <!-- Delete Button -->
                            <form method="post" action="<%= ctx %>/student/documents" class="mt-2" onsubmit="return confirm('Are you sure you want to delete this file?')">
                                <input type="hidden" name="action" value="delete" />
                                <input type="hidden" name="documentTypeId" value="<%= type.getId() %>" />
                                <button type="submit" class="btn btn-sm btn-outline-danger py-0 px-2" style="font-size: 0.68rem; border-radius: 12px;">
                                    <i class="bi bi-trash"></i> Delete
                                </button>
                            </form>
                        <% } else { %>
                            <span class="text-muted fw-bold" style="font-size: 1.5rem;">-</span>
                        <% } %>
                    </div>
                </div>
            </div>
        <% } } %>
    </div>
</div>

<!-- Upload Modal -->
<div class="modal fade" id="uploadModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px; border:1px solid var(--rt-border);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">
                    <i class="bi bi-cloud-arrow-up me-2 text-primary"></i>Upload Document
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= ctx %>/student/documents" enctype="multipart/form-data">
                <input type="hidden" name="action" value="upload" />
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Document Type *</label>
                        <select name="documentTypeId" id="uploadDocTypeSelect" class="form-select" required>
                            <option value="">-- Select Type --</option>
                            <% if (documentTypes != null) {
                                for (DocumentType type : documentTypes) { %>
                                    <option value="<%= type.getId() %>"><%= type.getName() %></option>
                            <% } } %>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Select File * <span class="text-muted">(Max 20MB)</span></label>
                        <input type="file" name="documentFile" id="documentFileField" class="form-control" onchange="validateDocumentSize(this)" required />
                    </div>

                    <!-- Client-side size error container -->
                    <div class="rt-alert rt-alert-error d-none mt-2" id="clientFileError" style="font-size: 0.8rem;">
                        <i class="bi bi-exclamation-circle-fill"></i> File size exceeds the 20MB limit. Please select a smaller file.
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm" id="uploadSubmitBtn">
                        <i class="bi bi-upload me-1"></i>Upload File
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<style>
/* Custom Pill Button Styles Matching Image */
.btn-doc-pill {
    border: 2.2px solid #2563eb;
    border-radius: 22px;
    color: #2563eb;
    background: transparent;
    font-weight: 700;
    font-size: 0.76rem;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    transition: all 0.15s ease-in-out;
    outline: none;
    box-shadow: none;
}
.btn-doc-pill:hover {
    background-color: #2563eb;
    color: #ffffff;
    box-shadow: 0 4px 10px rgba(37,99,235,0.15);
    transform: translateY(-1px);
}
.bi-file-earmark-pdf-fill:hover {
    transform: scale(1.1);
}
</style>

<script>
    function openUploadModal(typeId) {
        // Clear previous state
        document.getElementById('documentFileField').value = '';
        document.getElementById('clientFileError').classList.add('d-none');
        document.getElementById('uploadSubmitBtn').disabled = false;
        
        var select = document.getElementById('uploadDocTypeSelect');
        if (typeId > 0) {
            select.value = typeId;
            // Optionally lock the select choice if opened from card
        } else {
            select.value = "";
        }
        
        new bootstrap.Modal(document.getElementById('uploadModal')).show();
    }

    function validateDocumentSize(input) {
        var errorDiv = document.getElementById('clientFileError');
        var submitBtn = document.getElementById('uploadSubmitBtn');
        if (input.files && input.files[0]) {
            var size = input.files[0].size;
            var maxLimit = 20 * 1024 * 1024; // 20MB
            if (size > maxLimit) {
                errorDiv.classList.remove('d-none');
                submitBtn.disabled = true;
            } else {
                errorDiv.classList.add('d-none');
                submitBtn.disabled = false;
            }
        }
    }

    // Reset error banners on modal close
    var uploadModalEl = document.getElementById('uploadModal');
    if (uploadModalEl) {
        uploadModalEl.addEventListener('hidden.bs.modal', function () {
            document.getElementById('clientFileError').classList.add('d-none');
            document.getElementById('uploadSubmitBtn').disabled = false;
            var docAlertError = document.getElementById('docAlertError');
            if (docAlertError) {
                docAlertError.style.display = 'none';
            }
        });
    }
</script>

<jsp:include page="/views/common/footer.jsp"/>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.MaterialLink, java.util.List, java.util.Map, java.util.LinkedHashMap, java.util.ArrayList, java.util.Set, java.util.LinkedHashSet, java.io.File" %>
<%
    request.setAttribute("pageTitle", "FYP Materials");
    String ctx = request.getContextPath();
    String role = (String) session.getAttribute("userRole");
    boolean canManageMaterials = Boolean.TRUE.equals(request.getAttribute("canManageMaterials"));
    String success = request.getParameter("success");
    List<MaterialLink> materialLinks = (List<MaterialLink>) request.getAttribute("materialLinks");
    Map<String, List<MaterialLink>> sections = new LinkedHashMap<String, List<MaterialLink>>();
    Set<String> urlOptions = new LinkedHashSet<String>();

    if (materialLinks != null) {
        for (MaterialLink link : materialLinks) {
            String section = link.getSection() == null || link.getSection().trim().isEmpty()
                    ? "Materials"
                    : link.getSection().trim();
            if (!sections.containsKey(section)) {
                sections.put(section, new ArrayList<MaterialLink>());
            }
            sections.get(section).add(link);
            if (link.getUrl() != null && !link.getUrl().trim().isEmpty()) {
                urlOptions.add(link.getUrl().trim());
            }
        }
    }

    String uploadDirPath = application.getRealPath("/uploads/materials");
    if (uploadDirPath != null) {
        File uploadDir = new File(uploadDirPath);
        File[] uploadedFiles = uploadDir.listFiles();
        if (uploadedFiles != null) {
            for (File uploadedFile : uploadedFiles) {
                if (uploadedFile.isFile() && uploadedFile.getName().toLowerCase().endsWith(".pdf")) {
                    urlOptions.add("/uploads/materials/" + uploadedFile.getName());
                }
            }
        }
    }

    String dashboardUrl = "COORDINATOR".equals(role) ? ctx + "/coordinator/dashboard" : ctx + "/student/dashboard";
%>
<jsp:include page="/views/common/header.jsp"/>

<% if ("1".equals(success)) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i> Material links updated successfully.
</div>
<% } %>

<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= dashboardUrl %>" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">Materials</span>
</nav>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h4 class="fw-bold mb-0">FYP Materials</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">Materials for KP/IM FYP</p>
    </div>
    <% if (canManageMaterials) { %>
    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addMaterialModal">
        <i class="bi bi-plus-lg me-1"></i>Add Link
    </button>
    <% } %>
</div>

<div class="row g-3">
    <% if (sections.isEmpty()) { %>
    <div class="col-12">
        <div class="rt-card p-4 text-center text-muted">No material links found.</div>
    </div>
    <% } else {
        for (Map.Entry<String, List<MaterialLink>> entry : sections.entrySet()) { %>
    <div class="col-12 col-lg-6">
        <div class="rt-card h-100">
            <div class="rt-card-header">
                <i class="bi bi-journal-bookmark me-1"></i><%= entry.getKey() %>
                <% if (canManageMaterials) { %>
                <span class="badge bg-secondary ms-auto"><%= entry.getValue().size() %></span>
                <% } %>
            </div>
            <div class="list-group list-group-flush">
                <% for (MaterialLink link : entry.getValue()) {
                    String materialUrl = link.getUrl();
                    if (materialUrl != null && materialUrl.startsWith("/")) {
                        materialUrl = ctx + materialUrl;
                    }
                %>
                <div class="list-group-item d-flex align-items-center gap-2 <%= link.isEnabled() ? "" : "text-muted" %>">
                    <a class="flex-grow-1 text-decoration-none <%= link.isEnabled() ? "" : "text-muted" %>"
                       target="_blank" href="<%= materialUrl %>">
                        <%= link.getTitle() %>
                    </a>
                    <% if (!link.isEnabled()) { %>
                    <span class="badge bg-light text-secondary border">Disabled</span>
                    <% } %>
                    <% if (canManageMaterials) { %>
                    <button class="btn btn-sm btn-outline-primary"
                            onclick="openEditMaterial(<%= link.getId() %>,
                                     '<%= escapeJs(link.getSection()) %>',
                                     '<%= escapeJs(link.getTitle()) %>',
                                     '<%= escapeJs(link.getUrl()) %>',
                                     <%= link.getSortOrder() %>,
                                     <%= link.isEnabled() %>)"
                            title="Edit">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <form method="post" action="<%= ctx %>/coordinator/material-links" class="d-inline">
                        <input type="hidden" name="action" value="toggle">
                        <input type="hidden" name="id" value="<%= link.getId() %>">
                        <input type="hidden" name="enabled" value="<%= link.isEnabled() ? "0" : "1" %>">
                        <button type="submit" class="btn btn-sm <%= link.isEnabled() ? "btn-outline-secondary" : "btn-outline-success" %>" title="Toggle">
                            <i class="bi bi-<%= link.isEnabled() ? "toggle-on" : "toggle-off" %>"></i>
                        </button>
                    </form>
                    <form method="post" action="<%= ctx %>/coordinator/material-links" class="d-inline"
                          onsubmit="return confirm('Delete this material link?')">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" value="<%= link.getId() %>">
                        <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete">
                            <i class="bi bi-trash"></i>
                        </button>
                    </form>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>
    </div>
    <% } } %>
</div>

<% if (canManageMaterials) { %>
<div class="modal fade" id="addMaterialModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px;border:1px solid var(--rt-border);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold"><i class="bi bi-plus-lg me-2"></i>Add Material Link</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= ctx %>/coordinator/material-links" enctype="multipart/form-data">
                <input type="hidden" name="action" value="add">
                <div class="modal-body pt-2"><%= materialLinkFormFields("", "", "", "99", "1") %></div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-plus-lg me-1"></i>Add Link</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editMaterialModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px;border:1px solid var(--rt-border);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold"><i class="bi bi-pencil me-2"></i>Edit Material Link</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= ctx %>/coordinator/material-links" enctype="multipart/form-data">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="id" id="editMaterialId">
                <div class="modal-body pt-2"><%= materialLinkFormFields("editMaterialSection", "editMaterialTitle", "editMaterialUrl", "editMaterialSortOrder", "editMaterialEnabled") %></div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-save me-1"></i>Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<datalist id="materialUrlOptions">
    <% for (String optionUrl : urlOptions) { %>
    <option value="<%= escapeHtml(optionUrl) %>"></option>
    <% } %>
</datalist>

<script>
function openEditMaterial(id, section, title, url, sortOrder, enabled) {
    document.getElementById('editMaterialId').value = id;
    document.getElementById('editMaterialSection').value = section;
    document.getElementById('editMaterialTitle').value = title;
    document.getElementById('editMaterialUrl').value = url;
    document.getElementById('editMaterialSortOrder').value = sortOrder;
    document.getElementById('editMaterialEnabled').value = enabled ? '1' : '0';
    new bootstrap.Modal(document.getElementById('editMaterialModal')).show();
}
</script>
<% } %>

<jsp:include page="/views/common/footer.jsp"/>

<%!
private String escapeJs(String s) {
    if (s == null) return "";
    return s.replace("\\", "\\\\").replace("'", "\\'").replace("\r", "").replace("\n", "\\n");
}

private String escapeHtml(String s) {
    if (s == null) return "";
    return s.replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
}

private String materialLinkFormFields(String sectionId, String titleId, String urlId, String sortOrderId, String enabledId) {
    String sectionAttr = sectionId == null || sectionId.isEmpty() ? "" : " id=\"" + sectionId + "\"";
    String titleAttr = titleId == null || titleId.isEmpty() ? "" : " id=\"" + titleId + "\"";
    String urlAttr = urlId == null || urlId.isEmpty() ? "" : " id=\"" + urlId + "\"";
    String sortOrderAttr = sortOrderId == null || sortOrderId.isEmpty() || "99".equals(sortOrderId) ? "" : " id=\"" + sortOrderId + "\"";
    String enabledAttr = enabledId == null || enabledId.isEmpty() || "1".equals(enabledId) ? "" : " id=\"" + enabledId + "\"";
    String sortValue = "99".equals(sortOrderId) ? " value=\"99\"" : "";

    return "<div class=\"mb-3\">"
         + "<label class=\"form-label fw-semibold\" style=\"font-size:.83rem;\">Section *</label>"
         + "<input type=\"text\" name=\"section\" class=\"form-control\"" + sectionAttr + " required placeholder=\"Templates\">"
         + "</div>"
         + "<div class=\"mb-3\">"
         + "<label class=\"form-label fw-semibold\" style=\"font-size:.83rem;\">Title *</label>"
         + "<input type=\"text\" name=\"title\" class=\"form-control\"" + titleAttr + " required placeholder=\"FYP Handbook\">"
         + "</div>"
         + "<div class=\"mb-3\">"
         + "<label class=\"form-label fw-semibold\" style=\"font-size:.83rem;\">URL</label>"
         + "<input type=\"text\" name=\"url\" class=\"form-control\"" + urlAttr + " list=\"materialUrlOptions\" placeholder=\"https://... or /uploads/materials/file.pdf\">"
         + "<div class=\"form-text\">Choose a saved link from the list, paste a new link, or upload a PDF below.</div>"
         + "</div>"
         + "<div class=\"mb-3\">"
         + "<label class=\"form-label fw-semibold\" style=\"font-size:.83rem;\">Upload PDF</label>"
         + "<input type=\"file\" name=\"pdf_file\" class=\"form-control\" accept=\"application/pdf,.pdf\">"
         + "</div>"
         + "<div class=\"row g-2 mb-3\">"
         + "<div class=\"col-6\">"
         + "<label class=\"form-label fw-semibold\" style=\"font-size:.83rem;\">Sort Order</label>"
         + "<input type=\"number\" name=\"sort_order\" class=\"form-control\"" + sortOrderAttr + sortValue + " min=\"0\">"
         + "</div>"
         + "<div class=\"col-6\">"
         + "<label class=\"form-label fw-semibold\" style=\"font-size:.83rem;\">Status</label>"
         + "<select name=\"is_enabled\" class=\"form-select\"" + enabledAttr + ">"
         + "<option value=\"1\" selected>Enabled</option>"
         + "<option value=\"0\">Disabled</option>"
         + "</select>"
         + "</div>"
         + "</div>";
}
%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.MenuItem, java.util.List" %>
<%
    request.setAttribute("pageTitle", "Student Menu Management");
    List<MenuItem> menuItems = (List<MenuItem>) request.getAttribute("menuItems");
    String ctx     = request.getContextPath();
    String success = request.getParameter("success");
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- Flash -->
<% if ("1".equals(success)) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i> Menu updated successfully.
</div>
<% } %>

<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/coordinator/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">Student Menu Management</span>
</nav>

<!-- Page header -->
<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h4 class="fw-bold mb-0">Student Menu Management</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">
            Control which tiles appear on the student dashboard
        </p>
    </div>
    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addModal">
        <i class="bi bi-plus-lg me-1"></i>Add Menu Item
    </button>
</div>

<!-- Menu items table -->
<div class="rt-card p-0">
    <div class="rt-card-header">
        <i class="bi bi-grid me-1"></i> Menu Items
        <span class="badge bg-secondary ms-auto"><%= menuItems != null ? menuItems.size() : 0 %></span>
    </div>
    <div class="table-responsive">
        <table class="table mb-0 align-middle">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Icon</th>
                    <th>Label</th>
                    <th>Key</th>
                    <th>URL</th>
                    <th>Order</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <% if (menuItems == null || menuItems.isEmpty()) { %>
            <tr>
                <td colspan="8" class="text-center text-muted py-4">No menu items found.</td>
            </tr>
            <% } else {
                for (MenuItem m : menuItems) { %>
            <tr>
                <td class="text-muted" style="font-size:.8rem;"><%= m.getId() %></td>
                <td>
                    <i class="<%= m.getIcon() %>" style="font-size:1.3rem;color:<%= m.getIconColor() %>;"></i>
                </td>
                <td class="fw-semibold"><%= m.getLabel() %></td>
                <td><code style="font-size:.78rem;"><%= m.getItemKey() %></code></td>
                <td style="font-size:.8rem;max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                    <%= m.getUrl() %>
                </td>
                <td><%= m.getSortOrder() %></td>
                <td>
                    <!-- Toggle switch -->
                    <form method="post" action="<%= ctx %>/coordinator/menu" class="d-inline">
                        <input type="hidden" name="action"  value="toggle">
                        <input type="hidden" name="id"      value="<%= m.getId() %>">
                        <input type="hidden" name="enabled" value="<%= m.isEnabled() ? "0" : "1" %>">
                        <button type="submit" class="btn btn-sm <%= m.isEnabled() ? "btn-success" : "btn-outline-secondary" %>"
                                title="<%= m.isEnabled() ? "Click to disable" : "Click to enable" %>">
                            <i class="bi bi-<%= m.isEnabled() ? "toggle-on" : "toggle-off" %>"></i>
                            <%= m.isEnabled() ? "Enabled" : "Disabled" %>
                        </button>
                    </form>
                </td>
                <td>
                    <!-- Edit -->
                    <button class="btn btn-sm btn-outline-primary me-1"
                            onclick="openEditModal(<%= m.getId() %>,
                                     '<%= escapeJs(m.getLabel()) %>',
                                     '<%= escapeJs(m.getIcon()) %>',
                                     '<%= m.getIconColor() %>',
                                     '<%= escapeJs(m.getUrl()) %>',
                                     <%= m.getSortOrder() %>,
                                     <%= m.isEnabled() %>)"
                            title="Edit">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <!-- Delete -->
                    <form method="post" action="<%= ctx %>/coordinator/menu" class="d-inline"
                          onsubmit="return confirm('Delete \'<%= m.getLabel() %>\'?')">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id"     value="<%= m.getId() %>">
                        <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete">
                            <i class="bi bi-trash"></i>
                        </button>
                    </form>
                </td>
            </tr>
            <% } } %>
            </tbody>
        </table>
    </div>
</div>

<!-- Live preview -->
<div class="mt-4">
    <h6 class="fw-semibold mb-3"><i class="bi bi-eye me-1"></i>Student Menu Preview</h6>
    <div class="rt-card p-3">
        <div class="row g-3">
            <% if (menuItems != null) {
                for (MenuItem m : menuItems) {
                    if (!m.isEnabled()) continue;
                    String previewUrl = m.getUrl();
                    if (previewUrl == null || previewUrl.trim().isEmpty()) {
                        previewUrl = "#";
                    } else if (previewUrl.startsWith("/student/")) {
                        previewUrl = ctx + previewUrl.replaceFirst("^/student/", "/coordinator/");
                    } else if (previewUrl.startsWith("/")) {
                        previewUrl = ctx + previewUrl;
                    }
            %>
            <div class="col-6 col-sm-4 col-md-3 col-lg-2">
                <a href="<%= previewUrl %>"
                   class="rt-card text-center py-3 px-2 h-100 d-flex flex-column justify-content-center text-decoration-none"
                   style="cursor:pointer;transition:transform .15s, box-shadow .15s;">
                    <i class="<%= m.getIcon() %>"
                       style="font-size:1.8rem;color:<%= m.getIconColor() %>;"></i>
                    <div class="mt-2" style="font-size:.78rem;font-weight:600;color:var(--rt-primary);">
                        <%= m.getLabel() %>
                    </div>
                </a>
            </div>
            <% } } %>
        </div>
    </div>
</div>

<!-- ── Add Modal ─────────────────────────────────────────────────────── -->
<div class="modal fade" id="addModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px;border:1px solid var(--rt-border);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold"><i class="bi bi-plus-lg me-2"></i>Add Menu Item</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= ctx %>/coordinator/menu">
                <input type="hidden" name="action" value="add">
                <div class="modal-body pt-2">
                    <%= menuItemFormFields(null) %>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm">
                        <i class="bi bi-plus-lg me-1"></i>Add Item
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ── Edit Modal ────────────────────────────────────────────────────── -->
<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px;border:1px solid var(--rt-border);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold"><i class="bi bi-pencil me-2"></i>Edit Menu Item</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= ctx %>/coordinator/menu" id="editForm">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="id"     id="editId">
                <div class="modal-body pt-2">
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Label *</label>
                        <input type="text" name="label" id="editLabel" class="form-control" required>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-8">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">
                                Icon class <small class="text-muted">(Bootstrap Icons)</small>
                            </label>
                            <input type="text" name="icon" id="editIcon" class="form-control"
                                   placeholder="bi-grid-fill" required>
                        </div>
                        <div class="col-4">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Color</label>
                            <input type="color" name="icon_color" id="editIconColor"
                                   class="form-control form-control-color w-100">
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">URL *</label>
                        <input type="text" name="url" id="editUrl" class="form-control" required>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Sort Order</label>
                            <input type="number" name="sort_order" id="editSortOrder"
                                   class="form-control" min="0">
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Status</label>
                            <select name="is_enabled" id="editEnabled" class="form-select">
                                <option value="1">Enabled</option>
                                <option value="0">Disabled</option>
                            </select>
                        </div>
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

<jsp:include page="/views/common/footer.jsp"/>

<script>
function openEditModal(id, label, icon, iconColor, url, sortOrder, enabled) {
    document.getElementById('editId').value        = id;
    document.getElementById('editLabel').value     = label;
    document.getElementById('editIcon').value      = icon;
    document.getElementById('editIconColor').value = iconColor;
    document.getElementById('editUrl').value       = url;
    document.getElementById('editSortOrder').value = sortOrder;
    document.getElementById('editEnabled').value   = enabled ? '1' : '0';
    new bootstrap.Modal(document.getElementById('editModal')).show();
}
</script>

<%!
// ── JSP declaration helpers ──────────────────────────────────────────────

/** Escape string for use inside JS single-quoted string */
private String escapeJs(String s) {
    if (s == null) return "";
    return s.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n");
}

/** Render shared form fields for the Add modal */
private String menuItemFormFields(Object unused) {
    return "<div class=\"mb-3\">"
         + "  <label class=\"form-label fw-semibold\" style=\"font-size:.83rem;\">Item Key *"
         + "    <small class=\"text-muted\">(unique, no spaces)</small></label>"
         + "  <input type=\"text\" name=\"item_key\" class=\"form-control\" required"
         + "         placeholder=\"thesis_upload\">"
         + "</div>"
         + "<div class=\"mb-3\">"
         + "  <label class=\"form-label fw-semibold\" style=\"font-size:.83rem;\">Label *</label>"
         + "  <input type=\"text\" name=\"label\" class=\"form-control\" required placeholder=\"Thesis Upload\">"
         + "</div>"
         + "<div class=\"row g-2 mb-3\">"
         + "  <div class=\"col-8\">"
         + "    <label class=\"form-label fw-semibold\" style=\"font-size:.83rem;\">Icon class</label>"
         + "    <input type=\"text\" name=\"icon\" class=\"form-control\" placeholder=\"bi-upload\" required>"
         + "  </div>"
         + "  <div class=\"col-4\">"
         + "    <label class=\"form-label fw-semibold\" style=\"font-size:.83rem;\">Color</label>"
         + "    <input type=\"color\" name=\"icon_color\" class=\"form-control form-control-color w-100\" value=\"#2563eb\">"
         + "  </div>"
         + "</div>"
         + "<div class=\"mb-3\">"
         + "  <label class=\"form-label fw-semibold\" style=\"font-size:.83rem;\">URL *</label>"
         + "  <input type=\"text\" name=\"url\" class=\"form-control\" required placeholder=\"/thesis/upload\">"
         + "</div>"
         + "<div class=\"row g-2 mb-3\">"
         + "  <div class=\"col-6\">"
         + "    <label class=\"form-label fw-semibold\" style=\"font-size:.83rem;\">Sort Order</label>"
         + "    <input type=\"number\" name=\"sort_order\" class=\"form-control\" value=\"99\" min=\"0\">"
         + "  </div>"
         + "  <div class=\"col-6\">"
         + "    <label class=\"form-label fw-semibold\" style=\"font-size:.83rem;\">Status</label>"
         + "    <select name=\"is_enabled\" class=\"form-select\">"
         + "      <option value=\"1\" selected>Enabled</option>"
         + "      <option value=\"0\">Disabled</option>"
         + "    </select>"
         + "  </div>"
         + "</div>";
}
%>

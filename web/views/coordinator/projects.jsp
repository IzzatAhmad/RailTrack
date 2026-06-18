<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.*,java.util.List" %>
<%
    request.setAttribute("pageTitle", "Project Management");
    List<Project> projects   = (List<Project>) request.getAttribute("projects");
    List<User> supervisors   = (List<User>) request.getAttribute("supervisors");
    String formError         = (String) request.getAttribute("formError");
    String success           = request.getParameter("success");
    String ctx               = request.getContextPath();
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/coordinator/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">Project Management</span>
</nav>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h4 class="fw-bold mb-0">Project Management</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">Monitor and manage student FYP projects</p>
    </div>
    <div class="d-flex gap-2">
        <form method="post" action="<%= ctx %>/coordinator/project" class="d-inline mb-0">
            <input type="hidden" name="action" value="autoAssign"/>
            <button type="submit" class="btn btn-success btn-sm" onclick="return confirm('Automatically assign all unassigned projects to supervisors using CGPA load balancing?')">
                <i class="bi bi-magic me-1"></i>Auto-Assign Supervisors
            </button>
        </form>
    </div>
</div>

<% if (formError != null) { %>
<div class="rt-alert rt-alert-error rt-flash mb-3">
    <i class="bi bi-exclamation-circle-fill"></i> <%= formError %>
</div>
<% } %>
<% if (success != null) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i>
    <% if ("assigned".equals(success))   { %>Supervisor assigned successfully.
    <% } else if ("auto_assigned".equals(success)) { %>Successfully auto-assigned <%= request.getParameter("count") %> projects to supervisors.
    <% } else if ("rejected".equals(success))   { %>Project rejected.
    <% } else if ("completed".equals(success))  { %>Project marked as completed.
    <% } else if ("deleted".equals(success))    { %>Project deleted successfully.
    <% } else if ("bulk_deleted".equals(success)) { %>Selected projects deleted successfully.
    <% } else { %>Done.<% } %>
</div>
<% } %>

<div class="rt-card">
    <!-- Card header -->
    <div class="rt-card-header">
        <i class="bi bi-kanban text-primary"></i> All Projects
        <span class="badge bg-secondary ms-auto" id="visibleCount" style="font-size:.7rem;">
            <%= projects != null ? projects.size() : 0 %>
        </span>
    </div>

    <!-- Search + Filter toolbar -->
    <div class="px-3 pt-3 pb-2 border-bottom d-flex flex-wrap gap-2 align-items-center">
        <!-- Search bar -->
        <div class="input-group input-group-sm" style="max-width:280px;">
            <span class="input-group-text bg-white border-end-0">
                <i class="bi bi-search text-muted" style="font-size:.8rem;"></i>
            </span>
            <input type="text" id="searchInput" class="form-control border-start-0 ps-0"
                   placeholder="Search project title, student, supervisor…" style="font-size:.83rem;">
        </div>

        <!-- Filter Status -->
        <select id="filterStatus" class="form-select form-select-sm" style="max-width:150px;font-size:.83rem;">
            <option value="">All Statuses</option>
            <option value="PENDING">Pending</option>
            <option value="ACTIVE">Active</option>
            <option value="UNDER_REVIEW">Under Review</option>
            <option value="COMPLETED">Completed</option>
            <option value="REJECTED">Rejected</option>
        </select>

        <!-- Filter Assignment -->
        <select id="filterAssignment" class="form-select form-select-sm" style="max-width:170px;font-size:.83rem;">
            <option value="">All Assignments</option>
            <option value="assigned">Assigned</option>
            <option value="unassigned">Unassigned</option>
        </select>

        <!-- Bulk action bar — shown only when ≥1 row checked -->
        <div id="bulkBar" class="d-none ms-auto d-flex align-items-center gap-2">
            <span id="selCount" class="text-muted" style="font-size:.82rem;">0 selected</span>
            <button type="button" class="btn btn-sm btn-outline-danger" onclick="bulkDelete()">
                <i class="bi bi-trash me-1"></i>Delete
            </button>
        </div>
    </div>

    <!-- Hidden bulk forms -->
    <form id="bulkDeleteForm" method="post" action="<%= ctx %>/coordinator/project">
        <input type="hidden" name="action" value="bulkDelete"/>
        <div id="bulkDeleteIds"></div>
    </form>

    <% if (projects == null || projects.isEmpty()) { %>
    <div class="p-5 text-center text-muted">
        <i class="bi bi-folder2-open" style="font-size:2rem;"></i>
        <p class="mt-2">No projects found in the system.</p>
    </div>
    <% } else { %>
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0" id="projectsTable">
            <thead class="table-light">
                <tr>
                    <th style="width:36px;">
                        <input class="form-check-input" type="checkbox" id="selectAll"
                               title="Select all visible" style="cursor:pointer;">
                    </th>
                    <th style="min-width:200px;">Project Info</th>
                    <th style="min-width:130px;">Student</th>
                    <th style="min-width:160px;">Supervisor</th>
                    <th style="min-width:110px;">Status</th>
                    <th style="min-width:110px;">Container</th>
                    <th style="min-width:90px;"></th>
                </tr>
            </thead>
            <tbody id="projectsBody">
            <% for (Project p : projects) {
                String ds = p.getDockerStatus() != null ? p.getDockerStatus() : "none";
                boolean isAssigned = p.getSupervisorName() != null && !p.getSupervisorName().isEmpty();
            %>
            <tr data-title="<%= p.getTitle().toLowerCase() %>"
                data-repo="<%= p.getRepoUrl().toLowerCase() %>"
                data-student="<%= p.getStudentName().toLowerCase() %>"
                data-supervisor="<%= isAssigned ? p.getSupervisorName().toLowerCase() : "" %>"
                data-status="<%= p.getStatus().name() %>"
                data-assigned="<%= isAssigned ? "assigned" : "unassigned" %>">
                
                <td>
                    <input class="form-check-input row-check" type="checkbox"
                           value="<%= p.getId() %>" style="cursor:pointer;">
                </td>
                <td>
                    <div class="fw-semibold text-truncate" style="max-width:280px;"><%= p.getTitle() %></div>
                    <div class="text-truncate" style="font-size:.75rem;color:var(--rt-muted);max-width:280px;">
                        <a href="<%= p.getRepoUrl() %>" target="_blank" class="text-decoration-none text-muted">
                            <i class="bi bi-github me-1"></i><%= p.getRepoUrl() %>
                        </a>
                    </div>
                </td>
                <td>
                    <div class="fw-medium"><%= p.getStudentName() %></div>
                    <div style="font-size:.75rem;color:var(--rt-muted);">ID: <%= p.getStudentId() %></div>
                </td>
                <td>
                    <% if (isAssigned) { %>
                        <div class="fw-medium"><%= p.getSupervisorName() %></div>
                        <div class="small text-muted" style="font-size:.72rem;">Assigned</div>
                    <% } else { %>
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle" style="font-size:.68rem;">Unassigned</span>
                            <button type="button" class="btn btn-xs btn-outline-success py-0 px-1" style="font-size:.7rem;"
                                    data-bs-toggle="modal" data-bs-target="#assignSupervisorModal"
                                    data-project-id="<%= p.getId() %>" data-project-title="<%= p.getTitle() %>">
                                <i class="bi bi-person-plus-fill"></i> Assign
                            </button>
                        </div>
                    <% } %>
                </td>
                <td>
                    <span class="badge rt-status-<%= p.getStatus().name().toLowerCase() %>">
                        <%= p.getStatus() %>
                    </span>
                </td>
                <td>
                    <span class="small text-nowrap rt-docker-<%= ds %>">
                        <i class="bi bi-circle-fill me-1" style="font-size:7px;"></i><%= ds %>
                    </span>
                </td>
                <td class="text-end pe-3">
                    <div class="d-inline-flex gap-1">
                        <a href="<%= ctx %>/coordinator/project/<%= p.getId() %>"
                           class="btn btn-sm btn-outline-primary text-nowrap py-1">
                            <i class="bi bi-gear me-1"></i>Manage
                        </a>
                        <form method="post" action="<%= ctx %>/coordinator/project/<%= p.getId() %>" class="d-inline mb-0">
                            <input type="hidden" name="action" value="delete"/>
                            <button type="submit" class="btn btn-sm btn-outline-danger py-1"
                                    title="Delete permanently"
                                    onclick="return confirm('WARNING: Permanently delete project \'<%= p.getTitle() %>\'? All associated milestones, feedbacks, and evaluator assignments will be deleted. This cannot be undone.')">
                                <i class="bi bi-trash"></i>
                            </button>
                        </form>
                    </div>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <div id="noResults" class="p-5 text-center text-muted d-none">
            <i class="bi bi-search" style="font-size:1.5rem;"></i>
            <p class="mt-2">No projects match your filter criteria.</p>
        </div>
    </div>
    <% } %>
</div>

<!-- Assign Supervisor Modal -->
<div class="modal fade" id="assignSupervisorModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px;">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Assign Supervisor</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="">
                <input type="hidden" name="action" value="assign"/>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Select Supervisor *</label>
                        <select name="supervisorId" class="form-select form-select-sm" required>
                            <option value="">— Select Supervisor —</option>
                            <% if (supervisors != null) { for (User sv : supervisors) { %>
                            <option value="<%= sv.getId() %>">
                                <%= sv.getFullName() %> (<%= sv.getEmail() %>)
                            </option>
                            <% } } %>
                        </select>
                    </div>
                    <div class="mb-2">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Optional Note</label>
                        <input type="text" name="note" class="form-control form-control-sm"
                               placeholder="e.g. Assigned as per panel review..."/>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-success btn-sm">
                        <i class="bi bi-person-check me-1"></i>Assign Supervisor
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<style>
    .btn-xs {
        padding: 0.125rem 0.25rem;
        font-size: 0.75rem;
        border-radius: 0.2rem;
    }
    .bg-danger-subtle {
        background-color: rgba(220, 53, 69, 0.1) !important;
    }
</style>

<script>
(function () {
    var searchInput      = document.getElementById('searchInput');
    var filterStatus     = document.getElementById('filterStatus');
    var filterAssignment = document.getElementById('filterAssignment');
    var tbody            = document.getElementById('projectsBody');
    var selectAll        = document.getElementById('selectAll');
    var visibleCount     = document.getElementById('visibleCount');
    var noResults        = document.getElementById('noResults');
    var bulkBar          = document.getElementById('bulkBar');
    var selCount         = document.getElementById('selCount');

    function applyFilters() {
        var q       = searchInput      ? searchInput.value.trim().toLowerCase() : '';
        var status  = filterStatus     ? filterStatus.value                     : '';
        var assign  = filterAssignment ? filterAssignment.value                 : '';

        if (!tbody) return;
        var rows    = tbody.querySelectorAll('tr');
        var visible = 0;

        rows.forEach(function (row) {
            var title      = row.dataset.title      || '';
            var repo       = row.dataset.repo       || '';
            var student    = row.dataset.student    || '';
            var supervisor = row.dataset.supervisor || '';
            var rowStatus  = row.dataset.status     || '';
            var rowAssign  = row.dataset.assigned   || '';

            var matchQ      = !q      || title.includes(q) || repo.includes(q) || student.includes(q) || supervisor.includes(q);
            var matchStatus = !status || rowStatus === status;
            var matchAssign = !assign || rowAssign === assign;

            if (matchQ && matchStatus && matchAssign) {
                row.style.display = '';
                visible++;
            } else {
                row.style.display = 'none';
                var cb = row.querySelector('.row-check');
                if (cb) cb.checked = false;
            }
        });

        if (visibleCount) visibleCount.textContent = visible;
        if (noResults) noResults.classList.toggle('d-none', visible > 0);
        updateBulkBar();
        updateSelectAllState();
    }

    function getChecked() {
        if (!tbody) return [];
        return Array.from(tbody.querySelectorAll('.row-check:checked'));
    }

    function updateBulkBar() {
        var checked = getChecked();
        if (!bulkBar) return;
        if (checked.length > 0) {
            bulkBar.classList.remove('d-none');
            selCount.textContent = checked.length + ' selected';
        } else {
            bulkBar.classList.add('d-none');
        }
    }

    function updateSelectAllState() {
        if (!tbody || !selectAll) return;
        var visibleChecks = Array.from(tbody.querySelectorAll('tr'))
            .filter(function(r){ return r.style.display !== 'none'; })
            .map(function(r){ return r.querySelector('.row-check'); })
            .filter(Boolean);

        var allChecked  = visibleChecks.length > 0 && visibleChecks.every(function(c){ return c.checked; });
        var someChecked = visibleChecks.some(function(c){ return c.checked; });
        selectAll.checked       = allChecked;
        selectAll.indeterminate = !allChecked && someChecked;
    }

    if (selectAll) {
        selectAll.addEventListener('change', function () {
            if (!tbody) return;
            tbody.querySelectorAll('tr').forEach(function (row) {
                if (row.style.display === 'none') return;
                var cb = row.querySelector('.row-check');
                if (cb) cb.checked = selectAll.checked;
            });
            updateBulkBar();
        });
    }

    if (tbody) {
        tbody.addEventListener('change', function (e) {
            if (e.target.classList.contains('row-check')) {
                updateBulkBar();
                updateSelectAllState();
            }
        });
    }

    if (searchInput)      searchInput.addEventListener('input',      applyFilters);
    if (filterStatus)     filterStatus.addEventListener('change',    applyFilters);
    if (filterAssignment) filterAssignment.addEventListener('change', applyFilters);

    window.bulkDelete = function () {
        var checked = getChecked();
        if (checked.length === 0) return;
        if (!confirm('WARNING: Permanently DELETE ' + checked.length + ' selected project(s)? All associated milestones, feedbacks, and evaluator assignments will be deleted. This action cannot be undone.')) return;
        var container = document.getElementById('bulkDeleteIds');
        container.innerHTML = '';
        checked.forEach(function (cb) {
            var inp = document.createElement('input');
            inp.type  = 'hidden';
            inp.name  = 'ids';
            inp.value = cb.value;
            container.appendChild(inp);
        });
        document.getElementById('bulkDeleteForm').submit();
    };

    // Modal Dynamic Setup
    var assignModal = document.getElementById('assignSupervisorModal');
    if (assignModal) {
        assignModal.addEventListener('show.bs.modal', function (event) {
            var button = event.relatedTarget;
            var projectId = button.getAttribute('data-project-id');
            var projectTitle = button.getAttribute('data-project-title');
            
            var modalTitle = assignModal.querySelector('.modal-title');
            var form = assignModal.querySelector('form');
            
            modalTitle.innerHTML = 'Assign Supervisor to <span class="text-primary">' + escapeHtml(projectTitle) + '</span>';
            form.action = '<%= ctx %>/coordinator/project/' + projectId;
        });
    }

    function escapeHtml(text) {
        if (!text) return '';
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    applyFilters();
})();
</script>

<jsp:include page="/views/common/footer.jsp"/>

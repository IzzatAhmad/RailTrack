<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.*, com.railtrack.system.dao.MenuItemDAO, java.util.List" %>
<%
    request.setAttribute("pageTitle", "My Projects");
    List<Project>  projects       = (List<Project>)  request.getAttribute("projects");
    List<MenuItem> menuItems      = (List<MenuItem>) request.getAttribute("menuItems");
    long activeCount    = (Long) request.getAttribute("activeCount");
    long pendingCount   = (Long) request.getAttribute("pendingCount");
    long completedCount = (Long) request.getAttribute("completedCount");
    String formError    = (String) request.getAttribute("formError");
    String ctx          = request.getContextPath();
    String success      = request.getParameter("success");
%>
<jsp:include page="/views/common/header.jsp"/>
<div id="dashboard-sse-target" data-ctx="<%= ctx %>"></div>

<!-- Flash -->
<% if ("submitted".equals(success)) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i> Project submitted successfully! Awaiting supervisor assignment.
</div>
<% } %>
<% if (formError != null) { %>
<div class="rt-alert rt-alert-error mb-3">
    <i class="bi bi-exclamation-circle-fill"></i> <%= formError %>
</div>
<% } %>

<!-- ── Dynamic Menu Tiles ──────────────────────────────────────────────── -->
<% if (menuItems != null && !menuItems.isEmpty()) { %>
<div class="mb-4">
    <h6 class="fw-semibold mb-3 text-muted" style="font-size:.78rem;letter-spacing:.05em;text-transform:uppercase;">
        Quick Access
    </h6>
    <div class="row g-2">
        <% for (MenuItem mi : menuItems) { %>
        <div class="col-6 col-sm-4 col-md-3 col-lg-2">
            <a href="<%= ctx %><%= mi.getUrl() %>"
               class="rt-card text-center py-3 px-2 d-block text-decoration-none h-100
                      rt-menu-tile"
               style="transition:box-shadow .15s,transform .15s;">
                <i class="<%= mi.getIcon() %>"
                   style="font-size:1.8rem;color:<%= mi.getIconColor() %>;"></i>
                <div class="mt-2"
                     style="font-size:.78rem;font-weight:600;color:var(--rt-primary);line-height:1.2;">
                    <%= mi.getLabel() %>
                </div>
            </a>
        </div>
        <% } %>
    </div>
</div>
<% } %>

<!-- Page header -->
<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h4 class="fw-bold mb-0">My Projects</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">Track and manage your FYP submissions</p>
    </div>
    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#submitModal">
        <i class="bi bi-plus-lg me-1"></i>Submit New Project
    </button>
</div>

<!-- Stats -->
<div class="row g-3 mb-4">
    <div class="col-6 col-sm-3">
        <div class="rt-card text-center py-3 px-2">
            <div class="fs-3 fw-bold text-secondary"><%= projects != null ? projects.size() : 0 %></div>
            <div style="font-size:.78rem;color:var(--rt-muted);">Total</div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="rt-card text-center py-3 px-2">
            <div class="fs-3 fw-bold" style="color:var(--rt-warning);"><%= pendingCount %></div>
            <div style="font-size:.78rem;color:var(--rt-muted);">Pending</div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="rt-card text-center py-3 px-2">
            <div class="fs-3 fw-bold" style="color:var(--rt-success);"><%= activeCount %></div>
            <div style="font-size:.78rem;color:var(--rt-muted);">Active</div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="rt-card text-center py-3 px-2">
            <div class="fs-3 fw-bold" style="color:var(--rt-primary);"><%= completedCount %></div>
            <div style="font-size:.78rem;color:var(--rt-muted);">Completed</div>
        </div>
    </div>
</div>

<!-- Project list -->
<% if (projects == null || projects.isEmpty()) { %>
<div class="rt-card text-center py-5" style="color:var(--rt-muted);">
    <i class="bi bi-folder2-open" style="font-size:2.5rem;"></i>
    <p class="mt-2 mb-3">You haven't submitted any projects yet.</p>
    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#submitModal">
        <i class="bi bi-plus-lg me-1"></i>Submit Your First Project
    </button>
</div>
<% } else { %>
<div class="row g-3">
    <% for (Project p : projects) { %>
    <div class="col-12 col-md-6 col-xl-4">
        <div class="rt-card h-100 p-3">
            <div class="d-flex justify-content-between align-items-start mb-2">
                <span class="badge rt-status-<%= p.getStatus().name().toLowerCase() %>
                      px-2 py-1" style="font-size:.72rem;">
                    <%= p.getStatus() %>
                </span>
                <span class="small rt-docker-<%= p.getDockerStatus() != null ? p.getDockerStatus() : "none" %>">
                    <i class="bi bi-circle-fill me-1" style="font-size:7px;"></i>
                    <%= p.getDockerStatus() != null ? p.getDockerStatus() : "none" %>
                </span>
            </div>
            <h6 class="fw-bold mb-1"><%= p.getTitle() %></h6>
            <div class="text-truncate mb-2"
                 style="font-size:.78rem;color:var(--rt-muted);max-width:100%;">
                <i class="bi bi-github me-1"></i><%= p.getRepoUrl() %>
            </div>
            <% if (p.getSupervisorName() != null) { %>
            <div style="font-size:.8rem;color:var(--rt-muted);">
                <i class="bi bi-person-check me-1"></i>Supervisor: <strong><%= p.getSupervisorName() %></strong>
            </div>
            <% } else { %>
            <div style="font-size:.8rem;" class="text-danger">
                <i class="bi bi-person-x me-1"></i>Awaiting supervisor assignment
            </div>
            <% } %>
            <% if (p.getSemester() != null) { %>
            <div style="font-size:.78rem;color:var(--rt-muted);" class="mt-1">
                <i class="bi bi-calendar3 me-1"></i><%= p.getSemester() %>
            </div>
            <% } %>
            <div class="mt-3">
                <a href="<%= ctx %>/student/project/<%= p.getId() %>"
                   class="btn btn-sm btn-outline-primary w-100">
                    <i class="bi bi-eye me-1"></i>View Project
                </a>
            </div>
        </div>
    </div>
    <% } %>
</div>
<% } %>

<!-- Submit Modal -->
<div class="modal fade" id="submitModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px;border:1px solid var(--rt-border);">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Submit New Project</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= ctx %>/student/dashboard">
                <div class="modal-body pt-2">
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Repository URL *</label>
                        <div class="position-relative">
                            <input type="url" name="repoUrl" id="repoUrl" class="form-control" required
                                   placeholder="https://github.com/username/repo"
                                   style="padding-right:2.4rem;"/>
                            <span id="repoFetchSpinner"
                                  style="display:none;position:absolute;right:.75rem;top:50%;
                                  transform:translateY(-50%);font-size:.85rem;color:var(--rt-muted);">
                                <span class="spinner-border spinner-border-sm"></span>
                            </span>
                            <span id="repoFetchOk"
                                  style="display:none;position:absolute;right:.75rem;top:50%;
                                  transform:translateY(-50%);font-size:.95rem;color:var(--rt-success);">
                                <i class="bi bi-check-circle-fill"></i>
                            </span>
                        </div>
                        <div id="repoFetchError" class="text-danger mt-1" style="font-size:.78rem;display:none;"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Project Title *</label>
                        <input type="text" name="title" id="projTitle" class="form-control bg-light"
                               placeholder="Smart Attendance System" readonly>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Description</label>
                        <textarea name="description" id="projDesc" class="form-control" rows="3"
                                  placeholder="Brief description of your project..."></textarea>
                    </div>
                    <div class="row g-2">
                        <div class="col-6">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Branch</label>
                            <input type="text" name="branch" id="projBranch" class="form-control bg-light"
                                   placeholder="main" readonly>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Semester</label>
                            <input type="text" readonly name="semester" id="projSemester" class="form-control bg-light"
                                   value="${not empty currentUser.semester ? currentUser.semester : ''}"
                                   placeholder="e.g. 2025/2026-2">
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm">
                        <i class="bi bi-send me-1"></i>Submit Project
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp"/>

<style>
.rt-menu-tile:hover {
    box-shadow: 0 4px 16px rgba(37,99,235,.15) !important;
    transform: translateY(-2px);
}
</style>

<script>
(function () {
    /* ── Semester auto-detect ── */
    function calcSemester() {
        var now = new Date();
        var year = now.getFullYear();
        var month = now.getMonth() + 1;
        var sem, acadYear;
        if (month >= 3 && month <= 8) {
            acadYear = (year - 1) + '/' + year; sem = 2;
        } else if (month >= 9) {
            acadYear = (year - 1) + '/' + year; sem = 1;
        } else {
            acadYear = (year - 1) + '/' + year; sem = 1;
        }
        return acadYear + '-' + sem;
    }

    var submitModal = document.getElementById('submitModal');
    if (submitModal) {
        submitModal.addEventListener('show.bs.modal', function () {
            var semField = document.getElementById('projSemester');
            if (semField && !semField.value) semField.value = calcSemester();
        });
    }

    /* ── GitHub repo auto-fill ── */
    var repoInput   = document.getElementById('repoUrl');
    var titleInput  = document.getElementById('projTitle');
    var descInput   = document.getElementById('projDesc');
    var branchInput = document.getElementById('projBranch');
    var spinner     = document.getElementById('repoFetchSpinner');
    var okIcon      = document.getElementById('repoFetchOk');
    var errDiv      = document.getElementById('repoFetchError');

    function parseGitHubRepo(url) {
        var m = url.trim().match(/github\.com[\/:]([^\/]+)\/([^\/\s#?]+?)(?:\.git)?$/i);
        return m ? {owner: m[1], repo: m[2]} : null;
    }
    function toTitleCase(str) {
        return str.replace(/[-_]/g, ' ').replace(/\b\w/g, function (c) { return c.toUpperCase(); });
    }

    var fetchTimer = null;
    if (repoInput) {
        repoInput.addEventListener('input', function () {
            clearTimeout(fetchTimer);
            okIcon.style.display = 'none';
            errDiv.style.display = 'none';
            fetchTimer = setTimeout(function () {
                var parsed = parseGitHubRepo(repoInput.value);
                if (!parsed) return;
                spinner.style.display = 'inline-block';
                fetch('https://api.github.com/repos/' + parsed.owner + '/' + parsed.repo)
                    .then(function (r) {
                        if (!r.ok) throw new Error('Repo not found or private (' + r.status + ')');
                        return r.json();
                    })
                    .then(function (data) {
                        spinner.style.display = 'none';
                        okIcon.style.display  = 'inline-block';
                        if (!titleInput.value)  titleInput.value  = data.name        ? toTitleCase(data.name) : '';
                        if (!descInput.value)   descInput.value   = data.description || '';
                        if (!branchInput.value) branchInput.value = data.default_branch || 'main';
                    })
                    .catch(function (err) {
                        spinner.style.display = 'none';
                        errDiv.textContent    = err.message;
                        errDiv.style.display  = 'block';
                    });
            }, 600);
        });
    }
})();
</script>

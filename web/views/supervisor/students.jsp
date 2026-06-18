<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.*,java.util.List,java.util.Map,java.util.LinkedHashMap" %>
<%
    request.setAttribute("pageTitle", "My Students");
    List<Project> projects = (List<Project>) request.getAttribute("projects");
    Map<String,Long> notif = (Map<String,Long>) request.getAttribute("notif");
    Map<Integer, Boolean> notifEnabledMap = (Map<Integer, Boolean>) request.getAttribute("notifEnabledMap");
    String ctx = request.getContextPath();
    String success = request.getParameter("success");
    String error   = request.getParameter("error");

    // ── Aggregate per-student stats ──────────────────────────────────────────
    // Each Project already carries studentName, studentId (via getter).
    // We build a quick map: studentId -> student summary info from project list.
    // Since we only have compiled .class files (no source), we work with what
    // the Project model exposes: getId, getTitle, getStatus, getStudentName,
    // getStudentId (assumed), getDockerStatus, getRepoUrl, getBranch,
    // getContainerPort, getPreviewUrl, isRunning.

    int totalStudents = 0;
    int activeStudents = 0;
    int pendingStudents = 0;
    int completedStudents = 0;

    // group projects by studentId so we can list one row per student
    Map<Integer,java.util.List<Project>> byStudent = new java.util.LinkedHashMap<>();
    if (projects != null) {
        for (Project p : projects) {
            int sid = p.getStudentId();
            if (!byStudent.containsKey(sid)) {
                byStudent.put(sid, new java.util.ArrayList<Project>());
            }
            byStudent.get(sid).add(p);
        }
        totalStudents = byStudent.size();
        for (Map.Entry<Integer,java.util.List<Project>> e : byStudent.entrySet()) {
            boolean hasActive    = false;
            boolean hasPending   = false;
            boolean hasCompleted = false;
            for (Project p : e.getValue()) {
                if (p.getStatus() == Project.Status.ACTIVE)     hasActive    = true;
                if (p.getStatus() == Project.Status.PENDING)    hasPending   = true;
                if (p.getStatus() == Project.Status.COMPLETED)  hasCompleted = true;
            }
            if (hasActive)    activeStudents++;
            else if (hasPending)   pendingStudents++;
            else if (hasCompleted) completedStudents++;
        }
    }
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- ── Flash messages ──────────────────────────────────────────────────────── -->
<% if (success != null) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i>
    <% if ("emailed".equals(success))   { %>Email sent to student.<% }
       else if ("noted".equals(success)){ %>Note saved.<% }
       else if ("notif_toggled".equals(success)){ %>Student email notification preference toggled.<% }
       else                              { %>Action completed.<% } %>
</div>
<% } %>
<% if (error != null) { %>
<div class="rt-alert rt-alert-error rt-flash mb-3">
    <i class="bi bi-exclamation-circle-fill"></i> <%= error %>
</div>
<% } %>

<!-- ── Page header ─────────────────────────────────────────────────────────── -->
<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/supervisor/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">My Students</span>
</nav>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h4 class="fw-bold mb-0">My Students</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">
            Bound students &amp; their FYP projects — <%= totalStudents %> student<%= totalStudents != 1 ? "s" : "" %>
        </p>
    </div>
    <div class="d-flex gap-2">
        <input type="search" id="studentSearch" class="form-control form-control-sm"
               placeholder="&#128269; Search student or project…" style="min-width:220px;">
        <select id="statusFilter" class="form-select form-select-sm" style="max-width:160px;">
            <option value="all">All statuses</option>
            <option value="active">Active</option>
            <option value="pending">Pending</option>
            <option value="under_review">Under Review</option>
            <option value="completed">Completed</option>
            <option value="rejected">Rejected</option>
        </select>
    </div>
</div>

<!-- ── Summary stat cards ──────────────────────────────────────────────────── -->
<div class="row g-3 mb-4">
    <div class="col-6 col-sm-3">
        <div class="rt-card text-center py-3 px-2">
            <div class="fs-3 fw-bold" style="color:var(--rt-primary);"><%= totalStudents %></div>
            <div style="font-size:.75rem;color:var(--rt-muted);">Total Students</div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="rt-card text-center py-3 px-2">
            <div class="fs-3 fw-bold" style="color:var(--rt-success);"><%= activeStudents %></div>
            <div style="font-size:.75rem;color:var(--rt-muted);">Active Projects</div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="rt-card text-center py-3 px-2">
            <div class="fs-3 fw-bold" style="color:var(--rt-warning);"><%= pendingStudents %></div>
            <div style="font-size:.75rem;color:var(--rt-muted);">Pending</div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="rt-card text-center py-3 px-2">
            <div class="fs-3 fw-bold" style="color:#6366f1;"><%= completedStudents %></div>
            <div style="font-size:.75rem;color:var(--rt-muted);">Completed</div>
        </div>
    </div>
</div>

<!-- ── Students table / cards ──────────────────────────────────────────────── -->
<% if (byStudent.isEmpty()) { %>
<div class="rt-card p-5 text-center text-muted">
    <i class="bi bi-people" style="font-size:2.5rem;"></i>
    <p class="mt-3 mb-0">No students assigned to you yet.</p>
    <p style="font-size:.85rem;">The coordinator will bind students to your supervision.</p>
</div>
<% } else { %>

<!-- Desktop table (hidden on mobile) -->
<div class="rt-card d-none d-md-block mb-4">
    <div class="rt-card-header">
        <i class="bi bi-people-fill text-primary"></i> Bound Students
        <span class="badge bg-primary ms-auto" style="font-size:.7rem;"><%= totalStudents %></span>
    </div>
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0" id="studentsTable">
            <thead class="table-light">
                <tr>
                    <th style="width:36px;"></th>
                    <th style="min-width:160px;">Student</th>
                    <th style="min-width:180px;">Project</th>
                    <th style="min-width:90px;">Status</th>
                    <th style="min-width:110px;">Container</th>
                    <th style="min-width:80px;">Progress</th>
                    <th style="min-width:130px;"></th>
                </tr>
            </thead>
            <tbody>
            <% for (Map.Entry<Integer,java.util.List<Project>> entry : byStudent.entrySet()) {
                   java.util.List<Project> sProjects = entry.getValue();
                   Project first = sProjects.get(0);
                   String sName  = first.getStudentName();
                   String initials = "";
                   if (sName != null && !sName.isEmpty()) {
                       String[] parts = sName.trim().split("\\s+");
                       initials += Character.toUpperCase(parts[0].charAt(0));
                       if (parts.length > 1) initials += Character.toUpperCase(parts[parts.length-1].charAt(0));
                   }
                   // count project statuses for this student
                   int sDone=0, sActive=0, sPend=0, sUR=0, sRej=0, sTotal=sProjects.size();
                   for (Project p : sProjects) {
                       switch(p.getStatus()){
                           case ACTIVE: sActive++; break;
                           case PENDING: sPend++; break;
                           case COMPLETED: sDone++; break;
                           case UNDER_REVIEW: sUR++; break;
                           case REJECTED: sRej++; break;
                       }
                   }
                   int progressPct = sTotal > 0 ? (int)Math.round(sDone * 100.0 / sTotal) : 0;
                   // dominant status for filtering
                   String domStatus = sActive>0?"active": sPend>0?"pending": sUR>0?"under_review": sDone==sTotal?"completed":"rejected";
                   // docker
                   String ds = first.getDockerStatus() != null ? first.getDockerStatus() : "none";
                   String safeName = sName != null ? sName.toLowerCase() : "";
                   String safeTitle = first.getTitle() != null ? first.getTitle().toLowerCase() : "";
            %>
            <tr class="student-row" data-status="<%= domStatus %>"
                data-name="<%= safeName %>"
                data-project="<%= safeTitle %>">
                <!-- Avatar -->
                <td>
                    <div style="width:32px;height:32px;border-radius:50%;
                                background:var(--rt-primary);color:#fff;
                                display:flex;align-items:center;justify-content:center;
                                font-size:.72rem;font-weight:600;">
                        <%= initials %>
                    </div>
                </td>
                <!-- Student name -->
                <td>
                    <div class="fw-semibold" style="font-size:.875rem;"><%= sName %></div>
                    <% boolean isNotifEnabled = notifEnabledMap != null && notifEnabledMap.getOrDefault(entry.getKey(), false); %>
                    <div class="d-flex align-items-center gap-2 mt-1">
                        <span style="font-size:.75rem;color:var(--rt-muted);"><%= sTotal %> project<%= sTotal!=1?"s":"" %></span>
                        <span class="text-muted" style="font-size:.75rem;">·</span>
                        <form method="POST" action="<%= ctx %>/supervisor/students" class="d-inline m-0">
                            <input type="hidden" name="action" value="toggleEmailNotif"/>
                            <input type="hidden" name="studentId" value="<%= entry.getKey() %>"/>
                            <div class="form-check form-switch d-inline-block m-0 p-0" style="min-height: auto;">
                                <input class="form-check-input ms-0" type="checkbox" role="switch" 
                                       style="width: 1.8em; height: 0.9em; cursor: pointer; float: none; vertical-align: middle;" 
                                       <%= isNotifEnabled ? "checked" : "" %> 
                                       onchange="this.form.submit()"
                                       title="Toggle Email Notifications for this student"/>
                                <span style="font-size: .72rem; vertical-align: middle;" class="<%= isNotifEnabled ? "text-success fw-semibold" : "text-muted" %>">
                                    <i class="bi bi-envelope<%= isNotifEnabled ? "-fill" : "" %>"></i> Gmail
                                </span>
                            </div>
                        </form>
                    </div>
                </td>
                <!-- Primary project -->
                <td>
                    <div class="fw-medium text-truncate" style="max-width:200px;font-size:.85rem;">
                        <%= first.getTitle() %>
                    </div>
                    <% if (sTotal > 1) { %>
                    <div style="font-size:.72rem;color:var(--rt-muted);">+<%= sTotal-1 %> more</div>
                    <% } %>
                </td>
                <!-- Status badge -->
                <td>
                    <span class="badge rt-status-<%= first.getStatus().name().toLowerCase() %>">
                        <%= first.getStatus() %>
                    </span>
                </td>
                <!-- Docker -->
                <td>
                    <span class="small rt-docker-<%= ds %>">
                        <i class="bi bi-circle-fill me-1" style="font-size:7px;"></i><%= ds %>
                    </span>
                </td>
                <!-- Progress -->
                <td>
                    <div style="font-size:.72rem;color:var(--rt-muted);margin-bottom:3px;">
                        <%= sDone %>/<%= sTotal %> done
                    </div>
                    <div class="progress" style="height:6px;border-radius:3px;min-width:60px;">
                        <div class="progress-bar bg-primary" style="width:<%= progressPct %>%"></div>
                    </div>
                </td>
                <!-- Actions -->
                <td class="text-end text-nowrap">
                    <% if (sTotal == 1) { %>
                        <% if (first.getId() == -1) { %>
                        <button class="btn btn-sm btn-outline-secondary me-1" disabled title="No project registered yet">
                            <i class="bi bi-gear me-1"></i>Manage
                        </button>
                        <% } else { %>
                        <a href="<%= ctx %>/supervisor/project/<%= first.getId() %>"
                           class="btn btn-sm btn-outline-primary me-1" title="Manage project">
                            <i class="bi bi-gear me-1"></i>Manage
                        </a>
                        <% } %>
                    <% } else { %>
                    <button class="btn btn-sm btn-outline-secondary me-1"
                            data-bs-toggle="collapse"
                            data-bs-target="#projects-<%= entry.getKey() %>"
                            title="View all projects">
                        <i class="bi bi-list-ul me-1"></i>Projects
                    </button>
                    <% } %>
                    <a href="<%= ctx %>/supervisor/student/logbook?studentId=<%= entry.getKey() %>"
                       class="btn btn-sm btn-outline-success me-1" title="View Logbook">
                        <i class="bi bi-journal-bookmark me-1"></i>Logbook
                    </a>
                    <a href="<%= ctx %>/supervisor/student/documents?studentId=<%= entry.getKey() %>"
                       class="btn btn-sm btn-outline-primary me-1" title="View Documents">
                        <i class="bi bi-file-earmark-text me-1"></i>Documents
                    </a>
                    <button class="btn btn-sm btn-outline-warning"
                            data-bs-toggle="modal"
                            data-bs-target="#noteModal"
                            data-student="<%= sName %>"
                            data-student-id="<%= entry.getKey() %>"
                            title="Add note / reminder">
                        <i class="bi bi-sticky me-1"></i>Note
                    </button>
                </td>
            </tr>
            <!-- Collapsed multi-project rows -->
            <% if (sTotal > 1) { %>
            <tr class="student-row sub-row" data-status="<%= domStatus %>"
                data-name="<%= safeName %>"
                data-project="">
                <td colspan="7" class="p-0">
                    <div class="collapse" id="projects-<%= entry.getKey() %>">
                        <div class="bg-light border-top px-4 py-2">
                        <% for (Project p : sProjects) {
                               String pds = p.getDockerStatus() != null ? p.getDockerStatus() : "none";
                        %>
                        <div class="d-flex align-items-center justify-content-between py-2 border-bottom">
                            <div>
                                <span class="fw-medium" style="font-size:.85rem;"><%= p.getTitle() %></span>
                                <span class="badge rt-status-<%= p.getStatus().name().toLowerCase() %> ms-2"><%= p.getStatus() %></span>
                                <span class="small rt-docker-<%= pds %> ms-2">
                                    <i class="bi bi-circle-fill" style="font-size:6px;"></i> <%= pds %>
                                </span>
                            </div>
                            <a href="<%= ctx %>/supervisor/project/<%= p.getId() %>"
                               class="btn btn-sm btn-outline-primary">
                                <i class="bi bi-gear me-1"></i>Manage
                            </a>
                        </div>
                        <% } %>
                        </div>
                    </div>
                </td>
            </tr>
            <% } %>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<!-- Mobile card list (hidden on desktop) -->
<div class="d-md-none" id="mobileCards">
<% for (Map.Entry<Integer,java.util.List<Project>> entry : byStudent.entrySet()) {
       java.util.List<Project> sProjects = entry.getValue();
       Project first = sProjects.get(0);
       String sName  = first.getStudentName();
       String initials = "";
       if (sName != null && !sName.isEmpty()) {
           String[] parts = sName.trim().split("\\s+");
           initials += Character.toUpperCase(parts[0].charAt(0));
           if (parts.length > 1) initials += Character.toUpperCase(parts[parts.length-1].charAt(0));
       }
       int sDone=0, mActive=0, mPend=0, mUR=0, sTotal=sProjects.size();
       for(Project p:sProjects) {
           if(p.getStatus()==Project.Status.COMPLETED) sDone++;
           if(p.getStatus()==Project.Status.ACTIVE)    mActive++;
           if(p.getStatus()==Project.Status.PENDING)   mPend++;
           if(p.getStatus()==Project.Status.UNDER_REVIEW) mUR++;
       }
       int progressPct = sTotal>0?(int)Math.round(sDone*100.0/sTotal):0;
       String ds = first.getDockerStatus()!=null?first.getDockerStatus():"none";
       String domStatus = mActive>0?"active": mPend>0?"pending": mUR>0?"under_review": sDone==sTotal?"completed":"rejected";
       String safeName = sName!=null?sName.toLowerCase():"";
       String safeTitle = first.getTitle()!=null?first.getTitle().toLowerCase():"";
%>
<div class="rt-card mb-3 mobile-student-card"
     data-name="<%= safeName %>"
     data-project="<%= safeTitle %>"
     data-status="<%= domStatus %>">
    <div class="p-3">
        <div class="d-flex align-items-center gap-3 mb-3">
            <div style="width:40px;height:40px;border-radius:50%;
                        background:var(--rt-primary);color:#fff;flex-shrink:0;
                        display:flex;align-items:center;justify-content:center;
                        font-size:.8rem;font-weight:600;">
                <%= initials %>
            </div>
            <div class="flex-grow-1 min-width-0">
                <div class="fw-semibold" style="font-size:.9rem;"><%= sName %></div>
                <% boolean misNotifEnabled = notifEnabledMap != null && notifEnabledMap.getOrDefault(entry.getKey(), false); %>
                <div class="d-flex align-items-center gap-2 mt-1">
                    <span style="font-size:.75rem;color:var(--rt-muted);">
                        <%= sTotal %> project<%= sTotal!=1?"s":"" %>
                        &nbsp;·&nbsp;
                        <span class="rt-docker-<%= ds %>">
                            <i class="bi bi-circle-fill" style="font-size:6px;"></i> <%= ds %>
                        </span>
                    </span>
                    &nbsp;·&nbsp;
                    <form method="POST" action="<%= ctx %>/supervisor/students" class="d-inline m-0">
                        <input type="hidden" name="action" value="toggleEmailNotif"/>
                        <input type="hidden" name="studentId" value="<%= entry.getKey() %>"/>
                        <div class="form-check form-switch d-inline-block m-0 p-0" style="min-height: auto;">
                            <input class="form-check-input ms-0" type="checkbox" role="switch" 
                                   style="width: 1.8em; height: 0.9em; cursor: pointer; float: none; vertical-align: middle;" 
                                   <%= misNotifEnabled ? "checked" : "" %> 
                                   onchange="this.form.submit()"
                                   title="Toggle Email Notifications for this student"/>
                            <span style="font-size: .72rem; vertical-align: middle;" class="<%= misNotifEnabled ? "text-success fw-semibold" : "text-muted" %>">
                                <i class="bi bi-envelope<%= misNotifEnabled ? "-fill" : "" %>"></i> Gmail
                            </span>
                        </div>
                    </form>
                </div>
            </div>
            <span class="badge rt-status-<%= first.getStatus().name().toLowerCase() %>">
                <%= first.getStatus() %>
            </span>
        </div>

        <div class="mb-3">
            <div style="font-size:.8rem;color:var(--rt-muted);margin-bottom:4px;">
                <i class="bi bi-folder2 me-1"></i><%= first.getTitle() %>
                <% if (sTotal>1) { %><span class="ms-1 text-muted">(+<%= sTotal-1 %> more)</span><% } %>
            </div>
            <div class="d-flex align-items-center gap-2">
                <div class="progress flex-grow-1" style="height:6px;border-radius:3px;">
                    <div class="progress-bar bg-primary" style="width:<%= progressPct %>%"></div>
                </div>
                <span style="font-size:.72rem;color:var(--rt-muted);white-space:nowrap;">
                    <%= sDone %>/<%= sTotal %>
                </span>
            </div>
        </div>

        <div class="d-flex gap-2">
            <% if (sTotal==1) { %>
                <% if (first.getId() == -1) { %>
                <button class="btn btn-sm btn-outline-secondary flex-grow-1" disabled title="No project registered yet">
                    <i class="bi bi-gear me-1"></i>Manage
                </button>
                <% } else { %>
                <a href="<%= ctx %>/supervisor/project/<%= first.getId() %>"
                   class="btn btn-sm btn-outline-primary flex-grow-1">
                    <i class="bi bi-gear me-1"></i>Manage
                </a>
                <% } %>
            <% } else { %>
            <button class="btn btn-sm btn-outline-secondary flex-grow-1"
                    data-bs-toggle="collapse"
                    data-bs-target="#mprojects-<%= entry.getKey() %>">
                <i class="bi bi-list-ul me-1"></i>View Projects
            </button>
            <% } %>
            <a href="<%= ctx %>/supervisor/student/logbook?studentId=<%= entry.getKey() %>"
               class="btn btn-sm btn-outline-success" title="Logbook">
                <i class="bi bi-journal-bookmark"></i>
            </a>
            <a href="<%= ctx %>/supervisor/student/documents?studentId=<%= entry.getKey() %>"
               class="btn btn-sm btn-outline-primary" title="Documents">
                <i class="bi bi-file-earmark-text"></i>
            </a>
            <button class="btn btn-sm btn-outline-warning"
                    data-bs-toggle="modal"
                    data-bs-target="#noteModal"
                    data-student="<%= sName %>"
                    data-student-id="<%= entry.getKey() %>">
                <i class="bi bi-sticky"></i>
            </button>
        </div>

        <% if (sTotal>1) { %>
        <div class="collapse mt-3" id="mprojects-<%= entry.getKey() %>">
            <% for (Project p : sProjects) {
                   String pds = p.getDockerStatus()!=null?p.getDockerStatus():"none";
            %>
            <div class="d-flex align-items-center justify-content-between py-2 border-top">
                <div>
                    <div style="font-size:.82rem;font-weight:500;"><%= p.getTitle() %></div>
                    <span class="badge rt-status-<%= p.getStatus().name().toLowerCase() %>"><%= p.getStatus() %></span>
                </div>
                <a href="<%= ctx %>/supervisor/project/<%= p.getId() %>"
                   class="btn btn-sm btn-outline-primary ms-2">
                    <i class="bi bi-gear"></i>
                </a>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>
</div>
<% } %>
</div>

<!-- No results message -->
<div id="noResults" class="rt-card p-4 text-center text-muted d-none">
    <i class="bi bi-search" style="font-size:1.8rem;"></i>
    <p class="mt-2 mb-0">No students match your search.</p>
</div>

<% } %>

<!-- ── Note / Reminder Modal ────────────────────────────────────────────────── -->
<div class="modal fade" id="noteModal" tabindex="-1" aria-labelledby="noteModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--rt-radius);">
            <form method="POST" action="<%= ctx %>/supervisor/students/note">
                <div class="modal-header border-0 pb-0">
                    <h6 class="modal-title fw-bold" id="noteModalLabel">
                        <i class="bi bi-sticky-fill text-warning me-2"></i>
                        Add Note for <span id="noteStudentName">Student</span>
                    </h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="studentId" id="noteStudentId">
                    <div class="mb-3">
                        <label class="form-label" style="font-size:.85rem;">Note / Reminder</label>
                        <textarea name="note" rows="4" class="form-control"
                                  placeholder="Write a note, feedback, or reminder for this student…"
                                  style="font-size:.875rem;" required></textarea>
                    </div>
                    <div class="mb-2">
                        <label class="form-label" style="font-size:.85rem;">Visibility</label>
                        <select name="visibility" class="form-select form-select-sm">
                            <option value="private">Private (supervisor only)</option>
                            <option value="student">Visible to student</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-sm btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-sm btn-warning text-dark fw-semibold">
                        <i class="bi bi-sticky-fill me-1"></i>Save Note
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ── JS: search, filter, modal wiring ────────────────────────────────────── -->
<script>
(function () {
    var searchEl  = document.getElementById('studentSearch');
    var filterEl  = document.getElementById('statusFilter');
    var noResults = document.getElementById('noResults');

    function applyFilters() {
        var q      = searchEl ? searchEl.value.toLowerCase().trim() : '';
        var status = filterEl ? filterEl.value : 'all';
        var rows   = document.querySelectorAll('.student-row:not(.sub-row)');
        var cards  = document.querySelectorAll('.mobile-student-card');
        var anyVisible = false;

        rows.forEach(function(row) {
            var nameMatch    = row.dataset.name.includes(q);
            var projMatch    = row.dataset.project.includes(q);
            var statusMatch  = (status === 'all' || row.dataset.status === status);
            var show = (nameMatch || projMatch) && statusMatch;
            row.style.display = show ? '' : 'none';
            // also hide the following sub-row if parent hidden
            var next = row.nextElementSibling;
            if (next && next.classList.contains('sub-row')) {
                next.style.display = show ? '' : 'none';
            }
            if (show) anyVisible = true;
        });

        cards.forEach(function(card) {
            var nameMatch   = card.dataset.name.includes(q);
            var projMatch   = card.dataset.project.includes(q);
            var statusMatch = (status === 'all' || card.dataset.status === status);
            card.style.display = (nameMatch || projMatch) && statusMatch ? '' : 'none';
        });

        if (noResults) noResults.classList.toggle('d-none', anyVisible || rows.length === 0);
    }

    if (searchEl) searchEl.addEventListener('input', applyFilters);
    if (filterEl) filterEl.addEventListener('change', applyFilters);

    // ── Note modal: populate student name/id ─────────────────────────────────
    var noteModal = document.getElementById('noteModal');
    if (noteModal) {
        noteModal.addEventListener('show.bs.modal', function(e) {
            var trigger = e.relatedTarget;
            var name = trigger.getAttribute('data-student') || 'Student';
            var sid  = trigger.getAttribute('data-student-id') || '';
            document.getElementById('noteStudentName').textContent = name;
            document.getElementById('noteStudentId').value = sid;
        });
    }
})();
</script>

<jsp:include page="/views/common/footer.jsp"/>

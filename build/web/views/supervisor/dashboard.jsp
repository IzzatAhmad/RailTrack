<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.*,java.util.List,java.util.Map" %>
<%
    request.setAttribute("pageTitle", "Supervisor Dashboard");
    List<Project>   projects          = (List<Project>)   request.getAttribute("projects");
    List<Milestone> pendingMilestones = (List<Milestone>) request.getAttribute("pendingMilestones");
    List<PitaAssignment> pitaAssignments = (List<PitaAssignment>) request.getAttribute("pitaAssignments");
    Map<String,Long> notif            = (Map<String,Long>) request.getAttribute("notif");
    String ctx = request.getContextPath();

    // ── Compute stats from project list ──────────────────────────────────────
    int total = projects != null ? projects.size() : 0;
    int runningCount = 0, stoppedCount = 0, noneCount = 0, errorCount = 0;
    int statActive = 0, statPending = 0, statCompleted = 0, statUnderReview = 0, statRejected = 0;

    if (projects != null) {
        for (Project p : projects) {
            String ds = p.getDockerStatus() != null ? p.getDockerStatus() : "none";
            if ("running".equalsIgnoreCase(ds))      runningCount++;
            else if ("stopped".equalsIgnoreCase(ds)) stoppedCount++;
            else if ("error".equalsIgnoreCase(ds))   errorCount++;
            else                                     noneCount++;

            switch (p.getStatus()) {
                case ACTIVE:       statActive++;       break;
                case PENDING:      statPending++;      break;
                case COMPLETED:    statCompleted++;    break;
                case UNDER_REVIEW: statUnderReview++;  break;
                case REJECTED:     statRejected++;     break;
            }
        }
    }

    // ── Milestone breakdown from pendingMilestones list ───────────────────────
    int msSubmitted = 0, msOverdue = 0;
    if (pendingMilestones != null) {
        for (Milestone m : pendingMilestones) {
            msSubmitted++;
            if (m.isOverdue()) msOverdue++;
        }
    }
    int msOnTrack = msSubmitted - msOverdue;
%>
<jsp:include page="/views/common/header.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<div id="dashboard-sse-target" data-ctx="<%= ctx %>"></div>

<!-- ── Page header ───────────────────────────────────────────────────────── -->
<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h4 class="fw-bold mb-0">Supervisor Dashboard</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">
            Welcome, <%= session.getAttribute("userName") %>
        </p>
    </div>
    <a href="<%= ctx %>/supervisor/students" class="btn btn-primary btn-sm">
        <i class="bi bi-people-fill me-1"></i>My Students
    </a>
</div>

<!-- Success Alert -->
<% String success = request.getParameter("success"); %>
<% if (success != null) { %>
<div class="rt-alert rt-alert-success rt-flash mb-4">
    <i class="bi bi-check-circle-fill"></i>
    <% if ("pita_evaluated".equals(success)) { %>
        PITA evaluation submitted successfully.
    <% } else { %>
        Action completed.
    <% } %>
</div>
<% } %>

<%

    java.util.Set<Integer> studentIdSet = new java.util.HashSet<>();
    if (projects != null) for (com.railtrack.system.model.Project p : projects) studentIdSet.add(p.getStudentId());
    int totalStudentCount = studentIdSet.size();
%>
<div class="row g-3 mb-4">
    <div class="col-6 col-sm-3">
        <a href="<%= ctx %>/supervisor/students" class="text-decoration-none">
            <div class="rt-card text-center py-3 h-100" style="border:1.5px solid #bfdbfe;transition:box-shadow .15s;">
                <div class="fs-3 fw-bold" style="color:var(--rt-primary);"><%= totalStudentCount %></div>
                <div style="font-size:.78rem;color:var(--rt-muted);">My Students</div>
                <div style="font-size:.7rem;color:var(--rt-primary);margin-top:2px;">
                    <i class="bi bi-arrow-right-circle me-1"></i>View all
                </div>
            </div>
        </a>
    </div>
    <div class="col-6 col-sm-3">
        <div class="rt-card text-center py-3">
            <div class="fs-3 fw-bold" style="color:var(--rt-primary);"><%= total %></div>
            <div style="font-size:.78rem;color:var(--rt-muted);">Assigned Projects</div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="rt-card text-center py-3">
            <div class="fs-3 fw-bold" style="color:var(--rt-warning);"><%= msSubmitted %></div>
            <div style="font-size:.78rem;color:var(--rt-muted);">Pending Reviews</div>
        </div>
    </div>
    <div class="col-6 col-sm-3">
        <div class="rt-card text-center py-3">
            <div class="fs-3 fw-bold" style="color:var(--rt-success);"><%= runningCount %></div>
            <div style="font-size:.78rem;color:var(--rt-muted);">Running Containers</div>
        </div>
    </div>
</div>

<!-- ── Tabs Header ────────────────────────────────────────────────────────── -->
<ul class="nav nav-tabs mb-4" id="dashboardTabs" role="tablist">
  <li class="nav-item" role="presentation">
    <button class="nav-link active fw-bold text-dark" id="overview-tab" data-bs-toggle="tab" data-bs-target="#overview" type="button" role="tab" style="border-radius: 8px 8px 0 0;">
      <i class="bi bi-graph-up me-1 text-primary"></i> Overview & Analytics
    </button>
  </li>
  <li class="nav-item" role="presentation">
    <button class="nav-link fw-bold text-dark" id="actions-tab" data-bs-toggle="tab" data-bs-target="#actions" type="button" role="tab" style="border-radius: 8px 8px 0 0;">
      <i class="bi bi-lightning-charge-fill me-1 text-warning"></i> Action Items
      <% int actionCount = (pendingMilestones != null ? pendingMilestones.size() : 0) + (pitaAssignments != null ? pitaAssignments.size() : 0);
         if (actionCount > 0) { %>
        <span class="badge bg-danger rounded-pill ms-1"><%= actionCount %></span>
      <% } %>
    </button>
  </li>
  <li class="nav-item" role="presentation">
    <button class="nav-link fw-bold text-dark" id="projects-tab" data-bs-toggle="tab" data-bs-target="#projects" type="button" role="tab" style="border-radius: 8px 8px 0 0;">
      <i class="bi bi-folder-fill me-1 text-info"></i> Project Directory
    </button>
  </li>
  <li class="nav-item" role="presentation">
    <button class="nav-link fw-bold text-dark" id="report-tab" data-bs-toggle="tab" data-bs-target="#sup-report" type="button" role="tab" style="border-radius: 8px 8px 0 0;">
      <i class="bi bi-printer-fill me-1 text-secondary"></i> Data Analysis Report
    </button>
  </li>
</ul>

<div class="tab-content" id="dashboardTabsContent">

<!-- ── TAB 1: OVERVIEW ────────────────────────────────────────────────────── -->
<div class="tab-pane fade show active" id="overview" role="tabpanel">

<!-- ── Analytics row ──────────────────────────────────────────────────────── -->
<div class="row g-3 mb-4">

    <!-- Project Status – Doughnut -->
    <div class="col-12 col-md-4">
        <div class="rt-card h-100 p-3">
            <div class="fw-semibold mb-3" style="font-size:.85rem;">
                <i class="bi bi-pie-chart-fill text-primary me-1"></i>Project Status
            </div>
            <div style="position:relative;height:190px;">
                <canvas id="statusDoughnut"></canvas>
            </div>
        </div>
    </div>

    <!-- Milestone Reviews – Horizontal Bar -->
    <div class="col-12 col-md-4">
        <div class="rt-card h-100 p-3">
            <div class="fw-semibold mb-3" style="font-size:.85rem;">
                <i class="bi bi-flag-fill text-warning me-1"></i>Milestone Review Queue
            </div>
            <div style="position:relative;height:190px;">
                <canvas id="milestoneBar"></canvas>
            </div>
        </div>
    </div>

    <!-- Container + Progress stacked mini charts -->
    <div class="col-12 col-md-4">
        <div class="rt-card h-100 p-3 d-flex flex-column gap-3">

            <!-- Container status mini doughnut -->
            <div>
                <div class="fw-semibold mb-2" style="font-size:.82rem;">
                    <i class="bi bi-hdd-stack-fill text-info me-1"></i>Container Status
                </div>
                <div style="position:relative;height:100px;">
                    <canvas id="containerDonut"></canvas>
                </div>
                <div class="d-flex flex-wrap justify-content-center gap-2 mt-1">
                    <span style="font-size:.72rem;"><span style="color:#10b981;">●</span> Running (<%= runningCount %>)</span>
                    <span style="font-size:.72rem;"><span style="color:#f59e0b;">●</span> Stopped (<%= stoppedCount %>)</span>
                    <span style="font-size:.72rem;"><span style="color:#9ca3af;">●</span> None (<%= noneCount %>)</span>
                    <% if (errorCount > 0) { %><span style="font-size:.72rem;"><span style="color:#ef4444;">●</span> Error (<%= errorCount %>)</span><% } %>
                </div>
            </div>

            <hr class="my-0"/>

            <!-- Completion progress bar -->
            <div>
                <div class="fw-semibold mb-2" style="font-size:.82rem;">
                    <i class="bi bi-trophy-fill text-success me-1"></i>Project Completion
                </div>
                <%
                    int completionPct = total > 0 ? (int) Math.round((statCompleted * 100.0) / total) : 0;
                    int activePct     = total > 0 ? (int) Math.round((statActive    * 100.0) / total) : 0;
                    int pendingPct    = total > 0 ? (int) Math.round((statPending   * 100.0) / total) : 0;
                %>
                <div class="mb-2">
                    <div class="d-flex justify-content-between mb-1" style="font-size:.75rem;">
                        <span>Completed</span><span class="fw-semibold"><%= statCompleted %> / <%= total %></span>
                    </div>
                    <div class="progress" style="height:8px;border-radius:4px;">
                        <div class="progress-bar bg-primary" style="width:<%= completionPct %>%"></div>
                    </div>
                </div>
                <div class="mb-2">
                    <div class="d-flex justify-content-between mb-1" style="font-size:.75rem;">
                        <span>Active</span><span class="fw-semibold"><%= statActive %> / <%= total %></span>
                    </div>
                    <div class="progress" style="height:8px;border-radius:4px;">
                        <div class="progress-bar bg-success" style="width:<%= activePct %>%"></div>
                    </div>
                </div>
                <div>
                    <div class="d-flex justify-content-between mb-1" style="font-size:.75rem;">
                        <span>Pending</span><span class="fw-semibold"><%= statPending %> / <%= total %></span>
                    </div>
                    <div class="progress" style="height:8px;border-radius:4px;">
                        <div class="progress-bar bg-warning" style="width:<%= pendingPct %>%"></div>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- ── Student Performance ─────────────────────────────────────────────────── -->
<div class="row g-3 mb-4">
    <div class="col-12">
        <div class="rt-card p-4">
            <div class="fw-semibold mb-3 fs-5 text-dark d-flex align-items-center">
                <i class="bi bi-bar-chart-line-fill text-primary me-2"></i>Student Performance Overview
            </div>
            <div style="position:relative;height:300px;width:100%;">
                <canvas id="performanceBar"></canvas>
            </div>
        </div>
    </div>
</div>

<!-- ── Cohort Insights (4 New Charts) ──────────────────────────────────────── -->
<div class="row g-3 mb-4">
    <!-- Logbook Line Chart -->
    <div class="col-12 col-md-6">
        <div class="rt-card h-100 p-4">
            <div class="fw-semibold mb-3 fs-6 text-dark d-flex align-items-center">
                <i class="bi bi-graph-up text-primary me-2"></i>Logbook Engagement Activity
            </div>
            <div style="position:relative;height:220px;width:100%;">
                <canvas id="logbookLine"></canvas>
            </div>
        </div>
    </div>
    <!-- Milestone Bar Chart -->
    <div class="col-12 col-md-6">
        <div class="rt-card h-100 p-4">
            <div class="fw-semibold mb-3 fs-6 text-dark d-flex align-items-center">
                <i class="bi bi-bar-chart-steps text-info me-2"></i>Milestone Distribution
            </div>
            <div style="position:relative;height:220px;width:100%;">
                <canvas id="milestoneDistBar"></canvas>
            </div>
        </div>
    </div>
    <!-- PITA Donut -->
    <div class="col-12 col-md-6">
        <div class="rt-card h-100 p-4">
            <div class="fw-semibold mb-3 fs-6 text-dark d-flex align-items-center">
                <i class="bi bi-file-earmark-check-fill text-warning me-2"></i>PITA Grading Workload
            </div>
            <div style="position:relative;height:220px;width:100%;">
                <canvas id="pitaDonut"></canvas>
            </div>
        </div>
    </div>
    <!-- Grade Pie -->
    <div class="col-12 col-md-6">
        <div class="rt-card h-100 p-4">
            <div class="fw-semibold mb-3 fs-6 text-dark d-flex align-items-center">
                <i class="bi bi-award-fill text-success me-2"></i>Overall Grade Distribution (Completed)
            </div>
            <div style="position:relative;height:220px;width:100%;">
                <canvas id="gradePie"></canvas>
            </div>
        </div>
    </div>
</div>

</div> <!-- End Tab 1 -->

<!-- ── TAB 2: ACTION ITEMS ────────────────────────────────────────────────── -->
<div class="tab-pane fade" id="actions" role="tabpanel">

<!-- ── Pending milestone reviews ─────────────────────────────────────────── -->
<% if (pendingMilestones != null && !pendingMilestones.isEmpty()) { %>
<div class="rt-card mb-4" style="border-left:4px solid var(--rt-warning);">
    <div class="rt-card-header">
        <i class="bi bi-clock-history text-warning"></i> Pending Milestone Reviews
        <span class="badge bg-warning text-dark ms-auto" style="font-size:.7rem;">
            <%= pendingMilestones.size() %>
        </span>
    </div>
    <div class="list-group list-group-flush">
    <% for (Milestone m : pendingMilestones) { %>
        <div class="list-group-item d-flex flex-wrap justify-content-between align-items-center gap-2 py-3">
            <div>
                <div class="fw-semibold" style="font-size:.875rem;"><%= m.getTitle() %></div>
                <div style="font-size:.78rem;color:var(--rt-muted);">
                    <i class="bi bi-folder2 me-1"></i><%= m.getProjectTitle() %>
                    &nbsp;&middot;&nbsp;
                    <i class="bi bi-calendar3 me-1"></i>
                    Due: <%= m.getDueDate() != null ? m.getDueDate() : "—" %>
                    <% if (m.isOverdue()) { %><span class="badge bg-danger ms-1" style="font-size:.62rem;">OVERDUE</span><% } %>
                </div>
                <% if (m.getSubmissionNote() != null && !m.getSubmissionNote().isEmpty()) { %>
                <div style="font-size:.78rem;color:var(--rt-muted);font-style:italic;">
                    "<%= m.getSubmissionNote() %>"
                </div>
                <% } %>
            </div>
            <a href="<%= ctx %>/supervisor/project/<%= m.getProjectId() %>"
               class="btn btn-sm btn-warning text-nowrap">
                <i class="bi bi-eye me-1"></i>Review
            </a>
        </div>
    <% } %>
    </div>
</div>
<% } %>

<!-- ── PITA Evaluation Assignments ─────────────────────────────────────────── -->
<% if (pitaAssignments != null && !pitaAssignments.isEmpty()) { %>
<div class="rt-card mb-4" style="border-left:4px solid var(--rt-info);">
    <div class="rt-card-header">
        <i class="bi bi-file-earmark-check text-info"></i> PITA Evaluation Assignments
        <span class="badge bg-info text-white ms-auto" style="font-size:.7rem;">
            <%= pitaAssignments.size() %>
        </span>
    </div>
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
                <tr>
                    <th style="min-width:160px;">Project</th>
                    <th style="min-width:110px;">Student</th>
                    <th style="min-width:80px;">PITA Stage</th>
                    <th style="min-width:100px;">Status</th>
                    <th style="min-width:80px;"></th>
                </tr>
            </thead>
            <tbody>
            <% for (PitaAssignment pa : pitaAssignments) { %>
            <tr>
                <td>
                    <div class="fw-semibold text-truncate" style="max-width:220px;"><%= pa.getProjectTitle() %></div>
                </td>
                <td class="text-nowrap"><%= pa.getStudentName() %></td>
                <td>
                    <span class="badge bg-light text-dark border"><%= "PITA1".equals(pa.getStage()) ? "PITA-01" : "PITA-02" %></span>
                </td>
                <td>
                    <% if (pa.getGrade() != null) { %>
                        <span class="badge bg-success"><i class="bi bi-check-circle me-1"></i><%= pa.getGrade() %> / 100</span>
                    <% } else if (pa.getFeedback() != null && !pa.getFeedback().isEmpty()) { %>
                        <span class="badge bg-info text-white"><i class="bi bi-chat-left-text me-1"></i>Commented</span>
                    <% } else { %>
                        <span class="badge bg-warning text-dark"><i class="bi bi-clock me-1"></i>Pending</span>
                    <% } %>
                </td>
                <td>
                    <a href="<%= ctx %>/supervisor/pita-evaluate?projectId=<%= pa.getProjectId() %>&stage=<%= pa.getStage() %>"
                       class="btn btn-sm <%= pa.getGrade() == null && (pa.getFeedback() == null || pa.getFeedback().isEmpty()) ? "btn-info text-white" : "btn-outline-secondary" %> text-nowrap">
                        <i class="bi <%= pa.getGrade() == null && (pa.getFeedback() == null || pa.getFeedback().isEmpty()) ? "bi-pencil-square" : "bi-eye" %> me-1"></i><%= pa.getGrade() == null && (pa.getFeedback() == null || pa.getFeedback().isEmpty()) ? "Evaluate" : "View / Edit" %>
                    </a>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>
<% } %>

</div> <!-- End Tab 2 -->

<!-- ── TAB 3: PROJECT DIRECTORY ───────────────────────────────────────────── -->
<div class="tab-pane fade" id="projects" role="tabpanel">

<!-- ── Projects table ─────────────────────────────────────────────────────── -->
<div class="rt-card">
    <div class="rt-card-header">
        <i class="bi bi-folder2 text-primary"></i> My Projects
    </div>
    <% if (projects == null || projects.isEmpty()) { %>
    <div class="p-5 text-center text-muted">
        <i class="bi bi-folder2-open" style="font-size:2rem;"></i>
        <p class="mt-2">No projects assigned yet.</p>
    </div>
    <% } else { %>
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
                <tr>
                    <th style="min-width:160px;">Project</th>
                    <th style="min-width:110px;">Student</th>
                    <th style="min-width:100px;">Status</th>
                    <th style="min-width:120px;">Container</th>
                    <th style="min-width:80px;"></th>
                </tr>
            </thead>
            <tbody>
            <% for (Project p : projects) {
                String ds = p.getDockerStatus() != null ? p.getDockerStatus() : "none"; %>
            <tr>
                <td>
                    <div class="fw-semibold text-truncate" style="max-width:220px;"><%= p.getTitle() %></div>
                    <div class="text-truncate" style="font-size:.75rem;color:var(--rt-muted);max-width:220px;">
                        <%= p.getRepoUrl() %>
                    </div>
                </td>
                <td class="text-nowrap"><%= p.getStudentName() %></td>
                <td>
                    <span class="badge rt-status-<%= p.getStatus().name().toLowerCase() %>">
                        <%= p.getStatus() %>
                    </span>
                </td>
                <td>
                    <span id="status-badge-<%= p.getId() %>"
                          class="small text-nowrap rt-docker-<%= ds %>">
                        <i class="bi bi-circle-fill me-1" style="font-size:7px;"></i><%= ds %>
                    </span>
                </td>
                <td>
                    <a href="<%= ctx %>/supervisor/project/<%= p.getId() %>"
                       class="btn btn-sm btn-outline-primary text-nowrap">
                        <i class="bi bi-gear me-1"></i>Manage
                    </a>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
    <% } %>
</div>

</div> <!-- End Tab 3 -->

<!-- ── TAB 4: DATA ANALYSIS REPORT ────────────────────────────────────────── -->
<div class="tab-pane fade" id="sup-report" role="tabpanel">

    <!-- Toolbar -->
    <div class="d-flex justify-content-between align-items-center mb-4 gap-2 flex-wrap no-print">
        <div>
            <h5 class="fw-bold mb-0"><i class="bi bi-file-earmark-bar-graph-fill text-primary me-2"></i>Supervisor Data Analysis Report</h5>
            <p class="text-muted mb-0 small">Supervisor: <strong><%= session.getAttribute("userName") %></strong> &nbsp;&middot;&nbsp; Generated: <%= new java.text.SimpleDateFormat("dd MMMM yyyy, hh:mm a").format(new java.util.Date()) %></p>
        </div>
        <button onclick="window.print()" class="btn btn-primary">
            <i class="bi bi-printer me-2"></i>Print / Save as PDF
        </button>
    </div>

    <!-- Print-only header -->
    <div class="print-only" style="display:none; margin-bottom:1.5rem; border-bottom:2px solid #0075db; padding-bottom:1rem;">
        <div style="display:flex; justify-content:space-between; align-items:flex-start;">
            <div>
                <h2 style="margin:0; color:#0075db;">RailTrack FYP System</h2>
                <h3 style="margin:0.25rem 0 0;">Supervisor Data Analysis Report</h3>
                <p style="margin:0.25rem 0 0; font-size:0.85rem; color:#555;">Supervisor: <%= session.getAttribute("userName") %></p>
            </div>
            <div style="text-align:right; font-size:0.82rem; color:#666;">
                <div>Generated: <%= new java.text.SimpleDateFormat("dd MMMM yyyy").format(new java.util.Date()) %></div>
            </div>
        </div>
    </div>

    <!-- Section 1: Executive Summary -->
    <div class="report-section mb-5">
        <h6 class="report-section-title"><span class="report-num">1</span> Executive Summary</h6>
        <div class="row g-3">
            <div class="col-6 col-md-2">
                <div class="report-kpi-card">
                    <div class="report-kpi-value"><%= total %></div>
                    <div class="report-kpi-label">Total Projects</div>
                </div>
            </div>
            <div class="col-6 col-md-2">
                <div class="report-kpi-card" style="border-top-color:#10b981;">
                    <div class="report-kpi-value" style="color:#10b981;"><%= statActive %></div>
                    <div class="report-kpi-label">Active</div>
                </div>
            </div>
            <div class="col-6 col-md-2">
                <div class="report-kpi-card" style="border-top-color:#3b82f6;">
                    <div class="report-kpi-value" style="color:#3b82f6;"><%= statCompleted %></div>
                    <div class="report-kpi-label">Completed</div>
                </div>
            </div>
            <div class="col-6 col-md-2">
                <div class="report-kpi-card" style="border-top-color:#f59e0b;">
                    <div class="report-kpi-value" style="color:#f59e0b;"><%= statPending %></div>
                    <div class="report-kpi-label">Pending</div>
                </div>
            </div>
            <div class="col-6 col-md-2">
                <div class="report-kpi-card" style="border-top-color:#8b5cf6;">
                    <div class="report-kpi-value" style="color:#8b5cf6;"><%= statUnderReview %></div>
                    <div class="report-kpi-label">Under Review</div>
                </div>
            </div>
            <div class="col-6 col-md-2">
                <div class="report-kpi-card" style="border-top-color:#ef4444;">
                    <div class="report-kpi-value" style="color:#ef4444;"><%= statRejected %></div>
                    <div class="report-kpi-label">Rejected</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Section 2: Milestone Review Status -->
    <div class="report-section mb-5">
        <h6 class="report-section-title"><span class="report-num">2</span> Milestone Review Status</h6>
        <table class="report-table">
            <thead>
                <tr><th>Category</th><th>Count</th><th>% of Total</th></tr>
            </thead>
            <tbody>
                <tr><td><span style="color:#f59e0b;">&#9679;</span> Submitted (Pending Review)</td><td><%= msSubmitted %></td><td><%= msSubmitted > 0 ? String.format("%.0f%%", (msSubmitted * 100.0 / (msSubmitted > 0 ? msSubmitted : 1))) : "0%" %></td></tr>
                <tr><td><span style="color:#10b981;">&#9679;</span> On Track</td><td><%= msOnTrack %></td><td><%= msSubmitted > 0 ? String.format("%.1f%%", (msOnTrack * 100.0 / msSubmitted)) : "—" %></td></tr>
                <tr><td><span style="color:#ef4444;">&#9679;</span> Overdue</td><td><%= msOverdue %></td><td><%= msSubmitted > 0 ? String.format("%.1f%%", (msOverdue * 100.0 / msSubmitted)) : "—" %></td></tr>
            </tbody>
        </table>
    </div>

    <!-- Section 3: PITA Evaluation Status -->
    <div class="report-section mb-5">
        <h6 class="report-section-title"><span class="report-num">3</span> PITA Evaluation Status</h6>
        <%
            int pitaEvalCount = 0, pitaCommentCount = 0, pitaPendCount = 0;
            if (pitaAssignments != null) {
                for (PitaAssignment pa : pitaAssignments) {
                    if (pa.getGrade() != null) pitaEvalCount++;
                    else if (pa.getFeedback() != null && !pa.getFeedback().isEmpty()) pitaCommentCount++;
                    else pitaPendCount++;
                }
            }
            int pitaTotal = pitaEvalCount + pitaCommentCount + pitaPendCount;
        %>
        <table class="report-table">
            <thead>
                <tr><th>Status</th><th>Count</th><th>% of Assignments</th></tr>
            </thead>
            <tbody>
                <tr><td><span style="color:#10b981;">&#9679;</span> Graded</td><td><%= pitaEvalCount %></td><td><%= pitaTotal > 0 ? String.format("%.1f%%", (pitaEvalCount * 100.0 / pitaTotal)) : "—" %></td></tr>
                <tr><td><span style="color:#0dcaf0;">&#9679;</span> Commented Only</td><td><%= pitaCommentCount %></td><td><%= pitaTotal > 0 ? String.format("%.1f%%", (pitaCommentCount * 100.0 / pitaTotal)) : "—" %></td></tr>
                <tr><td><span style="color:#f59e0b;">&#9679;</span> Pending</td><td><%= pitaPendCount %></td><td><%= pitaTotal > 0 ? String.format("%.1f%%", (pitaPendCount * 100.0 / pitaTotal)) : "—" %></td></tr>
                <tr style="font-weight:600; background:#f8fafc;"><td>Total Assignments</td><td><%= pitaTotal %></td><td>100%</td></tr>
            </tbody>
        </table>
    </div>

    <!-- Section 4: Docker / Container Status -->
    <div class="report-section mb-5">
        <h6 class="report-section-title"><span class="report-num">4</span> Container Deployment Status</h6>
        <table class="report-table">
            <thead>
                <tr><th>Status</th><th>Count</th><th>% of Projects</th></tr>
            </thead>
            <tbody>
                <tr><td><span style="color:#10b981;">&#9679;</span> Running</td><td><%= runningCount %></td><td><%= total > 0 ? String.format("%.1f%%", (runningCount * 100.0 / total)) : "—" %></td></tr>
                <tr><td><span style="color:#f59e0b;">&#9679;</span> Stopped</td><td><%= stoppedCount %></td><td><%= total > 0 ? String.format("%.1f%%", (stoppedCount * 100.0 / total)) : "—" %></td></tr>
                <tr><td><span style="color:#ef4444;">&#9679;</span> Error</td><td><%= errorCount %></td><td><%= total > 0 ? String.format("%.1f%%", (errorCount * 100.0 / total)) : "—" %></td></tr>
                <tr><td><span style="color:#9ca3af;">&#9679;</span> Not Deployed</td><td><%= noneCount %></td><td><%= total > 0 ? String.format("%.1f%%", (noneCount * 100.0 / total)) : "—" %></td></tr>
            </tbody>
        </table>
    </div>

    <!-- Section 5: Full Student / Project Listing -->
    <div class="report-section">
        <h6 class="report-section-title"><span class="report-num">5</span> Full Student &amp; Project Listing</h6>
        <table class="report-table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Project Title</th>
                    <th>Student</th>
                    <th>Status</th>
                    <th>Milestone</th>
                    <th>Observation</th>
                    <th>Continuous</th>
                    <th>Overall Grade</th>
                    <th>Docker</th>
                </tr>
            </thead>
            <tbody>
                <% if (projects != null) {
                       int rowIdx = 0;
                       for (Project rp : projects) {
                           rowIdx++;
                           String rds = rp.getDockerStatus() != null ? rp.getDockerStatus() : "none";
                           String dsColor = "running".equalsIgnoreCase(rds) ? "#10b981" : "stopped".equalsIgnoreCase(rds) ? "#f59e0b" : "error".equalsIgnoreCase(rds) ? "#ef4444" : "#9ca3af"; %>
                <tr>
                    <td><%= rowIdx %></td>
                    <td style="max-width:200px; word-wrap:break-word;"><%= rp.getTitle() %></td>
                    <td><%= rp.getStudentName() != null ? rp.getStudentName() : "—" %></td>
                    <td><%= rp.getStatus() %></td>
                    <td>M<%= rp.getCurrentMilestoneNo() %></td>
                    <td><%= rp.getObservationMark() != null ? String.format("%.1f", rp.getObservationMark()) : "—" %></td>
                    <td><%= rp.getContinuousMark() != null ? String.format("%.1f", rp.getContinuousMark()) : "—" %></td>
                    <td><%= rp.getOverallGrade() != null ? String.format("%.1f", rp.getOverallGrade()) : "—" %></td>
                    <td><span style="color:<%= dsColor %>;font-weight:600;"><%= rds.toUpperCase() %></span></td>
                </tr>
                <% } } %>
            </tbody>
        </table>
        <div class="mt-4 pt-3 border-top text-muted small print-only" style="display:none;">
            <em>This report was generated automatically by RailTrack FYP Management System. For internal use only.</em>
        </div>
    </div>

</div> <!-- End Tab 4 -->
</div> <!-- End Tab Content -->

<!-- ── Charts init ────────────────────────────────────────────────────────── -->
<script>
(function () {
    Chart.defaults.font.family = "'Inter','Segoe UI',sans-serif";
    Chart.defaults.font.size   = 11;

    var total       = <%= total %>;
    var statActive  = <%= statActive %>;
    var statPending = <%= statPending %>;
    var statUR      = <%= statUnderReview %>;
    var statDone    = <%= statCompleted %>;
    var statRej     = <%= statRejected %>;

    var msSubmitted = <%= msSubmitted %>;
    var msOverdue   = <%= msOverdue %>;
    var msOnTrack   = <%= msOnTrack %>;

    var dockerRunning = <%= runningCount %>;
    var dockerStopped = <%= stoppedCount %>;
    var dockerNone    = <%= noneCount %>;
    var dockerError   = <%= errorCount %>;

    var studentNames = [];
    var obsMarks = [];
    var contMarks = [];
    
    var msDist = [0,0,0,0,0,0,0]; 
    var gradeA = 0, gradeB = 0, gradeC = 0, gradeF = 0;
    
    <% for (Project p : projects) {
         if (p.getStatus() != Project.Status.REJECTED && p.getStatus() != Project.Status.PENDING) { %>
            studentNames.push("<%= p.getStudentName() != null ? p.getStudentName().replace("\"", "\\\"") : "" %>");
            obsMarks.push(<%= p.getObservationMark() != null ? p.getObservationMark() : 0 %>);
            contMarks.push(<%= p.getContinuousMark() != null ? p.getContinuousMark() : 0 %>);
            
            <% int m = p.getCurrentMilestoneNo(); if (m > 0 && m <= 7) { %> msDist[<%= m-1 %>]++; <% } %>
    <%   }
         
         if (p.getStatus() == Project.Status.COMPLETED && p.getOverallGrade() != null) {
            double g = p.getOverallGrade();
            if (g >= 80) { %> gradeA++; <% }
            else if (g >= 65) { %> gradeB++; <% }
            else if (g >= 50) { %> gradeC++; <% }
            else { %> gradeF++; <% }
         }
       } %>

    var logbookData = <%= request.getAttribute("logbookCountsJson") != null ? request.getAttribute("logbookCountsJson") : "[]" %>;

    var pitaEvaluated = 0, pitaCommented = 0, pitaPending = 0;
    <% if (request.getAttribute("pitaAssignments") != null) {
        List<PitaAssignment> pitas = (List<PitaAssignment>) request.getAttribute("pitaAssignments");
        for (PitaAssignment pa : pitas) {
            if (pa.getGrade() != null) { %> pitaEvaluated++; <% }
            else if (pa.getFeedback() != null && !pa.getFeedback().isEmpty()) { %> pitaCommented++; <% }
            else { %> pitaPending++; <% }
        }
    } %>

    // ── 1. Project Status Doughnut ───────────────────────────────────────────
    new Chart(document.getElementById('statusDoughnut'), {
        type: 'doughnut',
        data: {
            labels: ['Active','Pending','Under Review','Completed','Rejected'],
            datasets: [{
                data: [statActive, statPending, statUR, statDone, statRej],
                backgroundColor: ['#10b981','#f59e0b','#3b82f6','#6366f1','#ef4444'],
                borderWidth: 2,
                borderColor: '#fff',
                hoverOffset: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '65%',
            plugins: {
                legend: { position: 'bottom', labels: { boxWidth: 10, padding: 8 } },
                tooltip: {
                    callbacks: {
                        label: function(ctx) {
                            var pct = total > 0 ? ((ctx.parsed / total) * 100).toFixed(1) : 0;
                            return ' ' + ctx.label + ': ' + ctx.parsed + ' (' + pct + '%)';
                        }
                    }
                }
            }
        }
    });

    // ── 2. Milestone Review Queue Bar ────────────────────────────────────────
    new Chart(document.getElementById('milestoneBar'), {
        type: 'bar',
        data: {
            labels: ['Pending Reviews', 'On Track', 'Overdue'],
            datasets: [{
                label: 'Milestones',
                data: [msSubmitted, msOnTrack, msOverdue],
                backgroundColor: ['#fde68a', '#6ee7b7', '#fca5a5'],
                borderColor:     ['#f59e0b', '#10b981', '#ef4444'],
                borderWidth: 1.5,
                borderRadius: 5
            }]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: { callbacks: { label: function(ctx) { return ' ' + ctx.parsed.x + ' milestones'; } } }
            },
            scales: {
                x: { beginAtZero: true, ticks: { stepSize: 1, precision: 0 }, grid: { color: 'rgba(0,0,0,.05)' } },
                y: { grid: { display: false } }
            }
        }
    });

    // ── 3. Container Status mini-doughnut ────────────────────────────────────
    new Chart(document.getElementById('containerDonut'), {
        type: 'doughnut',
        data: {
            labels: ['Running','Stopped','None','Error'],
            datasets: [{
                data: [dockerRunning, dockerStopped, dockerNone, dockerError],
                backgroundColor: ['#10b981','#f59e0b','#9ca3af','#ef4444'],
                borderWidth: 2,
                borderColor: '#fff'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '70%',
            plugins: {
                legend: { display: false },
                tooltip: { callbacks: { label: function(ctx) { return ' ' + ctx.label + ': ' + ctx.parsed; } } }
            }
        }
    });
    // ── 4. Student Performance Bar Chart ──────────────────────────────────────
    if (studentNames.length > 0) {
        new Chart(document.getElementById('performanceBar'), {
            type: 'bar',
            data: {
                labels: studentNames,
                datasets: [
                    {
                        label: 'Observation Mark (%)',
                        data: obsMarks,
                        backgroundColor: '#3b82f6',
                        borderRadius: 3
                    },
                    {
                        label: 'Continuous Mark (%)',
                        data: contMarks,
                        backgroundColor: '#10b981',
                        borderRadius: 3
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'top' },
                    tooltip: { mode: 'index', intersect: false }
                },
                scales: {
                    y: { beginAtZero: true, max: 100, grid: { color: 'rgba(0,0,0,.05)' } },
                    x: { grid: { display: false } }
                }
            }
        });
    } else {
        document.getElementById('performanceBar').parentElement.innerHTML = 
            '<div class="d-flex justify-content-center align-items-center h-100 text-muted">No active students to display.</div>';
    }

    // ── 5. Logbook Engagement Line Chart ──────────────────────────────────────
    new Chart(document.getElementById('logbookLine'), {
        type: 'line',
        data: {
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
            datasets: [{
                label: 'Logbook Submissions',
                data: logbookData,
                borderColor: '#3b82f6',
                backgroundColor: 'rgba(59, 130, 246, 0.1)',
                borderWidth: 2,
                fill: true,
                tension: 0.3
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
        }
    });

    // ── 6. Milestone Distribution Bar Chart ───────────────────────────────────
    new Chart(document.getElementById('milestoneDistBar'), {
        type: 'bar',
        data: {
            labels: ['M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7'],
            datasets: [{
                label: 'Students at Milestone',
                data: msDist,
                backgroundColor: '#0dcaf0',
                borderRadius: 4
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { beginAtZero: true, ticks: { stepSize: 1 } },
                x: { grid: { display: false } }
            }
        }
    });

    // ── 7. PITA Workload Doughnut ─────────────────────────────────────────────
    new Chart(document.getElementById('pitaDonut'), {
        type: 'doughnut',
        data: {
            labels: ['Evaluated', 'Commented', 'Pending'],
            datasets: [{
                data: [pitaEvaluated, pitaCommented, pitaPending],
                backgroundColor: ['#10b981', '#0dcaf0', '#f59e0b'],
                borderWidth: 2, borderColor: '#fff'
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false, cutout: '65%',
            plugins: { legend: { position: 'bottom' } }
        }
    });

    // ── 8. Overall Grade Distribution Pie Chart ───────────────────────────────
    var totalGrades = gradeA + gradeB + gradeC + gradeF;
    if (totalGrades > 0) {
        new Chart(document.getElementById('gradePie'), {
            type: 'pie',
            data: {
                labels: ['A (80-100)', 'B (65-79)', 'C (50-64)', 'Fail (<50)'],
                datasets: [{
                    data: [gradeA, gradeB, gradeC, gradeF],
                    backgroundColor: ['#198754', '#0d6efd', '#ffc107', '#dc3545'],
                    borderWidth: 2, borderColor: '#fff'
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                plugins: { legend: { position: 'right' } }
            }
        });
    } else {
        document.getElementById('gradePie').parentElement.innerHTML = 
            '<div class="d-flex justify-content-center align-items-center h-100 text-muted" style="font-size:0.8rem;">No completed projects with grades yet.</div>';
    }

})();
</script>

<jsp:include page="/views/common/footer.jsp"/>

<style>
/* ── Supervisor Report Styles ─────────────────────────────────────────── */
.report-section-title {
    font-size: 0.95rem; font-weight: 700; color: #1e293b;
    margin-bottom: 1rem; display: flex; align-items: center; gap: 0.6rem;
    border-bottom: 2px solid #e2e8f0; padding-bottom: 0.5rem;
}
.report-num {
    display: inline-flex; align-items: center; justify-content: center;
    width: 24px; height: 24px; border-radius: 50%;
    background: #0075db; color: #fff; font-size: 0.75rem; font-weight: 700; flex-shrink: 0;
}
.report-kpi-card {
    background: #fff; border: 1px solid #e2e8f0; border-top: 3px solid #0075db;
    border-radius: 8px; padding: 1rem; text-align: center;
    box-shadow: 0 1px 4px rgba(0,0,0,.06);
}
.report-kpi-value { font-size: 1.8rem; font-weight: 800; color: #0075db; line-height: 1; }
.report-kpi-label {
    font-size: 0.72rem; color: #64748b; font-weight: 600;
    margin-top: 0.35rem; text-transform: uppercase; letter-spacing: 0.04em;
}
.report-table { width: 100%; border-collapse: collapse; font-size: 0.855rem; }
.report-table th {
    background: #f1f5f9; color: #475569; font-weight: 600; font-size: 0.75rem;
    text-transform: uppercase; letter-spacing: 0.04em;
    padding: 0.55rem 0.75rem; border-bottom: 2px solid #e2e8f0; text-align: left;
}
.report-table td { padding: 0.5rem 0.75rem; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
.report-table tbody tr:hover { background: #f8fafc; }

/* ── Print Styles ─────────────────────────────────────────────── */
@media print {
    body * { visibility: hidden; }
    #sup-report, #sup-report * { visibility: visible; }
    #sup-report { position: absolute; left: 0; top: 0; width: 100%; }
    .print-only { display: block !important; }
    .no-print { display: none !important; }
    @page { margin: 1.5cm 1.8cm; size: A4 portrait; }
    .report-table th { background: #e2e8f0 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    .report-table tbody tr:nth-child(even) td { background: #f8fafc !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    .report-kpi-card { border: 1px solid #ccc !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    .report-section { page-break-inside: avoid; }
}
</style>

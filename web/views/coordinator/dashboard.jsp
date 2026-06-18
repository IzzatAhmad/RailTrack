<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="com.railtrack.system.model.*,java.util.List" %>
        <% request.setAttribute("pageTitle", "Coordinator Dashboard" ); List<Project> allProjects = (List<Project>)
                request.getAttribute("allProjects");
                long statPending = (Long) request.getAttribute("statPending");
                long statActive = (Long) request.getAttribute("statActive");
                long statCompleted = (Long) request.getAttribute("statCompleted");
                long statRejected = (Long) request.getAttribute("statRejected");
                long statUnderReview = (Long) request.getAttribute("statUnderReview");
                long totalProjects = allProjects != null ? allProjects.size() : 0;
                String ctx = request.getContextPath();

                // Compute container stats from project list
                long dockerRunning = 0, dockerStopped = 0, dockerNone = 0, dockerError = 0;
                long unassignedCount = 0;
                if (allProjects != null) {
                for (Project p : allProjects) {
                String ds = p.getDockerStatus() != null ? p.getDockerStatus() : "none";
                if ("running".equalsIgnoreCase(ds)) dockerRunning++;
                else if ("stopped".equalsIgnoreCase(ds)) dockerStopped++;
                else if ("error".equalsIgnoreCase(ds)) dockerError++;
                else dockerNone++;
                if (p.getSupervisorName() == null || p.getSupervisorName().isEmpty()) unassignedCount++;
                }
                }
                long assignedCount = totalProjects - unassignedCount;
                %>
                <jsp:include page="/views/common/header.jsp" />

                <!-- Chart.js CDN -->
                <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

                <div id="dashboard-sse-target" data-ctx="<%= ctx %>"></div>

                <!-- ── Page header ───────────────────────────────────────────────────────── -->
                <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
                    <div>
                        <h4 class="fw-bold mb-0">Coordinator Dashboard</h4>
                        <p class="text-muted mb-0" style="font-size:.875rem;">Overview of all FYP projects</p>
                    </div>
                    <a href="<%= ctx %>/coordinator/users" class="btn btn-outline-primary btn-sm">
                        <i class="bi bi-people me-1"></i>Manage Users
                    </a>
                </div>

                <!-- ── Stat cards ─────────────────────────────────────────────────────────── -->
                <div class="row g-3 mb-4">
                    <div class="col-6 col-sm-4 col-md-2">
                        <div class="rt-card text-center py-3">
                            <div class="fs-3 fw-bold text-secondary">
                                <%= totalProjects %>
                            </div>
                            <div style="font-size:.75rem;color:var(--rt-muted);">Total</div>
                        </div>
                    </div>
                    <div class="col-6 col-sm-4 col-md-2">
                        <div class="rt-card text-center py-3">
                            <div class="fs-3 fw-bold" style="color:var(--rt-warning);">
                                <%= statPending %>
                            </div>
                            <div style="font-size:.75rem;color:var(--rt-muted);">Pending</div>
                        </div>
                    </div>
                    <div class="col-6 col-sm-4 col-md-2">
                        <div class="rt-card text-center py-3">
                            <div class="fs-3 fw-bold" style="color:var(--rt-success);">
                                <%= statActive %>
                            </div>
                            <div style="font-size:.75rem;color:var(--rt-muted);">Active</div>
                        </div>
                    </div>
                    <div class="col-6 col-sm-4 col-md-2">
                        <div class="rt-card text-center py-3">
                            <div class="fs-3 fw-bold" style="color:var(--rt-info);">
                                <%= statUnderReview %>
                            </div>
                            <div style="font-size:.75rem;color:var(--rt-muted);">Under Review</div>
                        </div>
                    </div>
                    <div class="col-6 col-sm-4 col-md-2">
                        <div class="rt-card text-center py-3">
                            <div class="fs-3 fw-bold" style="color:var(--rt-primary);">
                                <%= statCompleted %>
                            </div>
                            <div style="font-size:.75rem;color:var(--rt-muted);">Completed</div>
                        </div>
                    </div>
                    <div class="col-6 col-sm-4 col-md-2">
                        <div class="rt-card text-center py-3">
                            <div class="fs-3 fw-bold" style="color:var(--rt-danger);">
                                <%= statRejected %>
                            </div>
                            <div style="font-size:.75rem;color:var(--rt-muted);">Rejected</div>
                        </div>
                    </div>
                </div>


<%
    // ── 1. Analytics Aggregation ────────────────────────────────────────────────
    com.railtrack.system.dao.LogbookDAO __logDao = new com.railtrack.system.dao.LogbookDAO();
    int _eligibleCount = 0;
    int _ineligibleCount = 0;
    
    int[] _msDist = new int[4]; // M1, M2, M3, M4
    int _gradeA = 0, _gradeB = 0, _gradeC = 0, _gradeF = 0;
    
    java.util.Map<String, Integer> _supWorkloads = new java.util.LinkedHashMap<>();
    java.util.Map<String, Integer> _deptCounts = new java.util.LinkedHashMap<>();
    java.util.Map<String, Double> _deptGrades = new java.util.LinkedHashMap<>();
    
    java.util.Map<String, Integer> _logbookCounts = new java.util.LinkedHashMap<>();
    String[] _months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
    for (String m : _months) _logbookCounts.put(m, 0);

    if (allProjects != null) {
        for (com.railtrack.system.model.Project p : allProjects) {
            
            // Supervisor workloads
            if (p.getSupervisorName() != null && !p.getSupervisorName().isEmpty()) {
                _supWorkloads.put(p.getSupervisorName(), _supWorkloads.getOrDefault(p.getSupervisorName(), 0) + 1);
            }
            
            // Department insights
            String dept = p.getStudentDepartment() != null && !p.getStudentDepartment().isEmpty() ? p.getStudentDepartment() : "General";
            _deptCounts.put(dept, _deptCounts.getOrDefault(dept, 0) + 1);
            if (p.getOverallGrade() != null) {
                _deptGrades.put(dept, _deptGrades.getOrDefault(dept, 0.0) + p.getOverallGrade());
            }

            // Grades
            if (p.getOverallGrade() != null) {
                double g = p.getOverallGrade();
                if (g >= 80) _gradeA++;
                else if (g >= 65) _gradeB++;
                else if (g >= 50) _gradeC++;
                else _gradeF++;
            }
            
            // Milestones
            if (p.getCurrentMilestoneNo() >= 1 && p.getCurrentMilestoneNo() <= 4) {
                _msDist[p.getCurrentMilestoneNo() - 1]++;
            }

            // Logbooks and Eligibility
            int verCount = 0;
            java.util.List<com.railtrack.system.model.LogbookEntry> entries = null;
            try {
                entries = __logDao.findByStudent(p.getStudentId());
            } catch (java.sql.SQLException e) {
                // ignore or log
            }
            if (entries != null) {
                for (com.railtrack.system.model.LogbookEntry le : entries) {
                    if (le.isVerified()) verCount++;
                    if (le.getActivityDate() != null) {
                        String mName = _months[le.getActivityDate().getMonthValue() - 1];
                        _logbookCounts.put(mName, _logbookCounts.get(mName) + 1);
                    }
                }
            }

            if (p.getStatus() == com.railtrack.system.model.Project.Status.ACTIVE) {
                double obs = p.getObservationMark() != null ? p.getObservationMark() : 0.0;
                if (verCount >= 5 && obs >= 50.0) {
                    _eligibleCount++;
                } else {
                    _ineligibleCount++;
                }
            }
        }
    }
    
    // Average grades per department
    java.util.Map<String, Double> _deptAvgGrades = new java.util.LinkedHashMap<>();
    for (String d : _deptCounts.keySet()) {
        double total = _deptGrades.getOrDefault(d, 0.0);
        int count = _deptCounts.get(d);
        _deptAvgGrades.put(d, count > 0 ? (Math.round((total / count) * 10.0) / 10.0) : 0.0);
    }
    
    // Convert to JSON strings for JS
    com.google.gson.Gson _gson = new com.google.gson.Gson();
    String _supNamesJson = _gson.toJson(_supWorkloads.keySet());
    String _supCountsJson = _gson.toJson(_supWorkloads.values());
    String _deptNamesJson = _gson.toJson(_deptCounts.keySet());
    String _deptProjectCountsJson = _gson.toJson(_deptCounts.values());
    String _deptAvgGradesJson = _gson.toJson(_deptAvgGrades.values());
    String _msDistJson = _gson.toJson(_msDist);
    String _logbookMonthsJson = _gson.toJson(_logbookCounts.keySet());
    String _logbookDataJson = _gson.toJson(_logbookCounts.values());
    
    // ── 2. PITA Workload ───────────────────────────────────────────────────────
    List<com.railtrack.system.model.PitaAssignment> pitaAssignments = (List<com.railtrack.system.model.PitaAssignment>) request.getAttribute("pitaAssignments");
    int _pitaEvaluated = 0, _pitaPending = 0;
    if (pitaAssignments != null) {
        for (com.railtrack.system.model.PitaAssignment pa : pitaAssignments) {
            if (pa.getGrade() != null) _pitaEvaluated++;
            else _pitaPending++;
        }
    }
%>


                <!-- ── Dashboard Tabs ─────────────────────────────────────────────────────── -->
                <ul class="nav nav-pills mb-4 gap-2 border-bottom pb-3" id="dashboardTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active rounded-pill px-4" id="tab-overview" data-bs-toggle="tab" data-bs-target="#overview" type="button" role="tab"><i class="bi bi-grid-1x2-fill me-2"></i>System Overview</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link rounded-pill px-4" id="tab-academic" data-bs-toggle="tab" data-bs-target="#academic" type="button" role="tab"><i class="bi bi-mortarboard-fill me-2"></i>Academic & Evaluation</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link rounded-pill px-4" id="tab-engagement" data-bs-toggle="tab" data-bs-target="#engagement" type="button" role="tab"><i class="bi bi-activity me-2"></i>Engagement & Workloads</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link rounded-pill px-4" id="tab-report" data-bs-toggle="tab" data-bs-target="#report" type="button" role="tab"><i class="bi bi-printer-fill me-2"></i>Data Analysis Report</button>
                    </li>
                </ul>

                <div class="tab-content" id="dashboardTabsContent">
                    <!-- ── TAB: Overview ──────────────────────────────────────────────────────── -->
                    <div class="tab-pane fade show active" id="overview" role="tabpanel">
                        <!-- Quick Actions -->
                        <div class="d-flex flex-wrap gap-2 mb-4">

                            <a href="<%= ctx %>/coordinator/project" class="btn btn-sm btn-light border shadow-sm"><i class="bi bi-kanban text-primary me-1"></i> Projects</a>
                            <a href="<%= ctx %>/coordinator/menu" class="btn btn-sm btn-light border shadow-sm"><i class="bi bi-list-task text-primary me-1"></i> Student Menu</a>
                            <a href="<%= ctx %>/coordinator/logbook" class="btn btn-sm btn-light border shadow-sm"><i class="bi bi-book text-primary me-1"></i> Logbooks</a>
                            <a href="<%= ctx %>/coordinator/docker" id="dockerMonitorBtn"
                               class="btn btn-sm btn-light border shadow-sm"
                               onclick="showDockerLoadingOverlay()">
                                <i class="bi bi-hdd-stack text-primary me-1"></i> Docker Monitor
                            </a>
                            <a href="<%= ctx %>/coordinator/documents" class="btn btn-sm btn-light border shadow-sm"><i class="bi bi-file-earmark-text text-primary me-1"></i> Requirements</a>
                            <a href="<%= ctx %>/coordinator/progress_overview" class="btn btn-sm btn-light border shadow-sm"><i class="bi bi-list-ol text-primary me-1"></i> Progress Overview</a>
                            <a href="<%= ctx %>/presentation" class="btn btn-sm btn-light border shadow-sm"><i class="bi bi-award text-primary me-1"></i> Presentation</a>
                            <a href="<%= ctx %>/rubrics" class="btn btn-sm btn-light border shadow-sm"><i class="bi bi-check2-square text-primary me-1"></i> Rubrics</a>
                        </div>

                        <div class="row g-3 mb-4">
                            <div class="col-12 col-xl-4">
                                <div class="rt-card h-100 p-3">
                                    <div class="fw-semibold mb-3 fs-6"><i class="bi bi-pie-chart-fill text-primary me-2"></i>Project Status</div>
                                    <div style="position:relative;height:200px;"><canvas id="statusDoughnut"></canvas></div>
                                </div>
                            </div>
                            <div class="col-12 col-xl-5">
                                <div class="rt-card h-100 p-3">
                                    <div class="fw-semibold mb-3 fs-6"><i class="bi bi-bar-chart-fill text-success me-2"></i>Project Pipeline</div>
                                    <div style="position:relative;height:200px;"><canvas id="pipelineBar"></canvas></div>
                                </div>
                            </div>
                            <div class="col-12 col-xl-3">
                                <div class="rt-card h-100 p-3 d-flex flex-column gap-3">
                                    <div class="flex-grow-1">
                                        <div class="fw-semibold mb-2" style="font-size:.85rem;"><i class="bi bi-person-check-fill text-warning me-2"></i>Supervisor Assignment</div>
                                        <div style="position:relative;height:80px;"><canvas id="assignmentDonut"></canvas></div>
                                        <div class="d-flex justify-content-center gap-3 mt-2 text-muted" style="font-size:.75rem;">
                                            <span><span style="color:#f59e0b;">●</span> Assigned (<%= assignedCount %>)</span>
                                            <span><span style="color:#e5e7eb;">●</span> Unassigned (<%= unassignedCount %>)</span>
                                        </div>
                                    </div>
                                    <hr class="my-0" />
                                    <div class="flex-grow-1 pt-2">
                                        <div class="fw-semibold mb-2" style="font-size:.85rem;"><i class="bi bi-hdd-stack-fill text-info me-2"></i>Container Status</div>
                                        <div style="position:relative;height:80px;"><canvas id="containerDonut"></canvas></div>
                                        <div class="d-flex flex-wrap justify-content-center gap-2 mt-2 text-muted" style="font-size:.75rem;">
                                            <span><span style="color:#10b981;">●</span> Running (<%= dockerRunning %>)</span>
                                            <span><span style="color:#f59e0b;">●</span> Stopped (<%= dockerStopped %>)</span>
                                            <span><span style="color:#9ca3af;">●</span> None (<%= dockerNone %>)</span>
                                            <% if (dockerError > 0) { %>
                                            <span><span style="color:#ef4444;">●</span> Error (<%= dockerError %>)</span>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row g-3 mb-4">
                            <div class="col-12 col-md-6">
                                <div class="rt-card h-100 p-4">
                                    <div class="fw-semibold mb-3 fs-6"><i class="bi bi-building text-primary me-2"></i>Projects by Department</div>
                                    <div style="position:relative;height:220px;"><canvas id="deptProjectPie"></canvas></div>
                                </div>
                            </div>
                            <div class="col-12 col-md-6">
                                <div class="rt-card h-100 p-4">
                                    <div class="fw-semibold mb-3 fs-6"><i class="bi bi-person-video3 text-warning me-2"></i>Presentation Eligibility (Active Projects)</div>
                                    <div style="position:relative;height:220px;"><canvas id="eligibilityPie"></canvas></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ── TAB: Academic & Evaluation ────────────────────────────────────────── -->
                    <div class="tab-pane fade" id="academic" role="tabpanel">
                        <div class="row g-3 mb-4">
                            <div class="col-12 col-md-5">
                                <div class="rt-card h-100 p-4">
                                    <div class="fw-semibold mb-3 fs-6"><i class="bi bi-award-fill text-success me-2"></i>Overall Grade Distribution</div>
                                    <div style="position:relative;height:220px;"><canvas id="gradePie"></canvas></div>
                                </div>
                            </div>
                            <div class="col-12 col-md-7">
                                <div class="rt-card h-100 p-4">
                                    <div class="fw-semibold mb-3 fs-6"><i class="bi bi-mortarboard-fill text-success me-2"></i>Average Grades by Department</div>
                                    <div style="position:relative;height:220px;"><canvas id="deptGradeBar"></canvas></div>
                                </div>
                            </div>
                        </div>
                        <div class="row g-3 mb-4">
                            <div class="col-12 col-md-6">
                                <div class="rt-card h-100 p-4">
                                    <div class="fw-semibold mb-3 fs-6"><i class="bi bi-clipboard2-check-fill text-info me-2"></i>PITA Workload (System-Wide)</div>
                                    <div style="position:relative;height:220px;"><canvas id="pitaDonut"></canvas></div>
                                </div>
                            </div>
                            <div class="col-12 col-md-6">
                                <div class="rt-card h-100 p-4">
                                    <div class="fw-semibold mb-3 fs-6"><i class="bi bi-flag-fill text-warning me-2"></i>Milestone Distribution</div>
                                    <div style="position:relative;height:220px;"><canvas id="milestoneDistBar"></canvas></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ── TAB: Engagement & Workloads ───────────────────────────────────────── -->
                    <div class="tab-pane fade" id="engagement" role="tabpanel">
                        <div class="row g-3 mb-4">
                            <div class="col-12">
                                <div class="rt-card p-4">
                                    <div class="fw-semibold mb-3 fs-5"><i class="bi bi-people-fill text-primary me-2"></i>Supervisor Workloads Overview</div>
                                    <div style="position:relative;height:300px;"><canvas id="workloadBar"></canvas></div>
                                </div>
                            </div>
                        </div>
                        <div class="row g-3 mb-4">
                            <div class="col-12">
                                <div class="rt-card p-4">
                                    <div class="fw-semibold mb-3 fs-5"><i class="bi bi-graph-up text-primary me-2"></i>Logbook Engagement Activity</div>
                                    <div style="position:relative;height:300px;"><canvas id="logbookLine"></canvas></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ── Filter ─────────────────────────────────────────────────────────────── -->
                <div class="rt-card mb-4">
                    <div class="card-body py-2 px-3">
                        <div class="d-flex flex-wrap gap-2 align-items-center">
                            <span style="font-size:.78rem;font-weight:600;color:var(--rt-muted);">Filter:</span>
                            <button class="btn btn-sm btn-outline-secondary rt-filter-btn active"
                                data-filter="all">All</button>
                            <button class="btn btn-sm btn-outline-warning  rt-filter-btn"
                                data-filter="PENDING">Pending</button>
                            <button class="btn btn-sm btn-outline-success  rt-filter-btn"
                                data-filter="ACTIVE">Active</button>
                            <button class="btn btn-sm btn-outline-info     rt-filter-btn"
                                data-filter="UNDER_REVIEW">Under Review</button>
                            <button class="btn btn-sm btn-outline-primary  rt-filter-btn"
                                data-filter="COMPLETED">Completed</button>
                            <button class="btn btn-sm btn-outline-danger   rt-filter-btn"
                                data-filter="REJECTED">Rejected</button>
                        </div>
                    </div>
                </div>

                <!-- ── Projects table ─────────────────────────────────────────────────────── -->
                <div class="rt-card">
                    <div class="rt-card-header">
                        <i class="bi bi-table text-primary"></i> All Projects
                    </div>
                    <% if (allProjects==null || allProjects.isEmpty()) { %>
                        <div class="p-5 text-center text-muted">
                            <i class="bi bi-folder2-open" style="font-size:2rem;"></i>
                            <p class="mt-2">No projects in the system.</p>
                        </div>
                        <% } else { %>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0" id="projectsTable">
                                    <thead class="table-light">
                                        <tr>
                                            <th style="min-width:160px;">Project</th>
                                            <th style="min-width:110px;">Student</th>
                                            <th style="min-width:110px;">Supervisor</th>
                                            <th style="min-width:100px;">Status</th>
                                            <th style="min-width:110px;">Container</th>
                                            <th style="min-width:80px;"></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Project p : allProjects) { String ds=p.getDockerStatus() !=null ?
                                            p.getDockerStatus() : "none" ; %>
                                            <tr data-status="<%= p.getStatus() %>">
                                                <td>
                                                    <div class="fw-semibold text-truncate" style="max-width:220px;">
                                                        <%= p.getTitle() %>
                                                    </div>
                                                    <div class="text-truncate"
                                                        style="font-size:.75rem;color:var(--rt-muted);max-width:220px;">
                                                        <%= p.getRepoUrl() %>
                                                    </div>
                                                </td>
                                                <td class="text-nowrap">
                                                    <%= p.getStudentName() %>
                                                </td>
                                                <td class="text-nowrap">
                                                    <% if (p.getSupervisorName() !=null &&
                                                        !p.getSupervisorName().isEmpty()) { %>
                                                        <%= p.getSupervisorName() %>
                                                            <% } else { %>
                                                                <span class="text-danger small">Unassigned</span>
                                                                <% } %>
                                                </td>
                                                <td>
                                                    <span
                                                        class="badge rt-status-<%= p.getStatus().name().toLowerCase() %>">
                                                        <%= p.getStatus() %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="small text-nowrap rt-docker-<%= ds %>">
                                                        <i class="bi bi-circle-fill me-1" style="font-size:7px;"></i>
                                                        <%= ds %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <a href="<%= ctx %>/coordinator/project/<%= p.getId() %>"
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

                <!-- ── TAB: Data Analysis Report ─────────────────────────────────────────── -->
                <div class="tab-pane fade" id="report" role="tabpanel">

                    <!-- Report Toolbar -->
                    <div class="d-flex justify-content-between align-items-center mb-4 gap-2 flex-wrap no-print">
                        <div>
                            <h5 class="fw-bold mb-0"><i class="bi bi-file-earmark-bar-graph-fill text-primary me-2"></i>FYP Data Analysis Report</h5>
                            <p class="text-muted mb-0 small">Generated on: <%= new java.text.SimpleDateFormat("dd MMMM yyyy, hh:mm a").format(new java.util.Date()) %></p>
                        </div>
                        <button onclick="window.print()" class="btn btn-primary">
                            <i class="bi bi-printer me-2"></i>Print / Save as PDF
                        </button>
                    </div>

                    <!-- PRINT HEADER (visible only in print) -->
                    <div class="print-only" style="display:none; margin-bottom:1.5rem; border-bottom:2px solid #0075db; padding-bottom:1rem;">
                        <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                            <div>
                                <h2 style="margin:0; color:#0075db;">RailTrack FYP System</h2>
                                <h3 style="margin:0.25rem 0 0;">Data Analysis Report</h3>
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
                                    <div class="report-kpi-value"><%= totalProjects %></div>
                                    <div class="report-kpi-label">Total Projects</div>
                                </div>
                            </div>
                            <div class="col-6 col-md-2">
                                <div class="report-kpi-card" style="border-top-color:#f59e0b;">
                                    <div class="report-kpi-value" style="color:#f59e0b;"><%= statPending %></div>
                                    <div class="report-kpi-label">Pending</div>
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

                    <!-- Section 2: Grade Distribution -->
                    <div class="report-section mb-5">
                        <h6 class="report-section-title"><span class="report-num">2</span> Grade Distribution</h6>
                        <% long totalGraded = _gradeA + _gradeB + _gradeC + _gradeF; %>
                        <table class="report-table">
                            <thead>
                                <tr><th>Grade Band</th><th>Range</th><th>Count</th><th>% of Graded</th></tr>
                            </thead>
                            <tbody>
                                <% long[] _gradeCounts = {_gradeA, _gradeB, _gradeC, _gradeF};
                                   String[] _gradeNames = {"A (Distinction)", "B (Credit)", "C (Pass)", "F (Fail)"};
                                   String[] _gradeRanges = {"≥ 80", "65–79", "50–64", "< 50"};
                                   String[] _gradeColors = {"#10b981","#3b82f6","#f59e0b","#ef4444"};
                                   for (int gi = 0; gi < 4; gi++) { %>
                                <tr>
                                    <td><span style="display:inline-block;width:10px;height:10px;border-radius:50%;background:<%= _gradeColors[gi] %>;margin-right:6px;"></span><%= _gradeNames[gi] %></td>
                                    <td><%= _gradeRanges[gi] %></td>
                                    <td><%= _gradeCounts[gi] %></td>
                                    <td><%= totalGraded > 0 ? String.format("%.1f%%", (_gradeCounts[gi] * 100.0 / totalGraded)) : "—" %></td>
                                </tr>
                                <% } %>
                                <tr style="font-weight:600; background:#f8fafc;">
                                    <td colspan="2">Total Graded</td>
                                    <td><%= totalGraded %></td>
                                    <td>100%</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Section 3: Department Breakdown -->
                    <div class="report-section mb-5">
                        <h6 class="report-section-title"><span class="report-num">3</span> Department Breakdown</h6>
                        <table class="report-table">
                            <thead>
                                <tr><th>Department</th><th>Projects</th><th>% Share</th><th>Avg Grade</th></tr>
                            </thead>
                            <tbody>
                                <% for (String dept : _deptCounts.keySet()) {
                                       int dc = _deptCounts.get(dept);
                                       double davg = _deptAvgGrades.getOrDefault(dept, 0.0); %>
                                <tr>
                                    <td><%= dept %></td>
                                    <td><%= dc %></td>
                                    <td><%= totalProjects > 0 ? String.format("%.1f%%", (dc * 100.0 / totalProjects)) : "—" %></td>
                                    <td><%= davg > 0 ? String.format("%.1f", davg) : "—" %></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>

                    <!-- Section 4: Supervisor Workload -->
                    <div class="report-section mb-5">
                        <h6 class="report-section-title"><span class="report-num">4</span> Supervisor Workload</h6>
                        <table class="report-table">
                            <thead>
                                <tr><th>Supervisor</th><th>Projects Supervised</th><th>% Share</th></tr>
                            </thead>
                            <tbody>
                                <% for (String sup : _supWorkloads.keySet()) {
                                       int sc = _supWorkloads.get(sup); %>
                                <tr>
                                    <td><%= sup %></td>
                                    <td><%= sc %></td>
                                    <td><%= totalProjects > 0 ? String.format("%.1f%%", (sc * 100.0 / totalProjects)) : "—" %></td>
                                </tr>
                                <% } %>
                                <% if (_supWorkloads.isEmpty()) { %>
                                <tr><td colspan="3" class="text-center text-muted">No supervisor assignments recorded.</td></tr>
                                <% } %>
                                <tr style="font-weight:600; background:#f8fafc;">
                                    <td>Unassigned Projects</td>
                                    <td><%= unassignedCount %></td>
                                    <td><%= totalProjects > 0 ? String.format("%.1f%%", (unassignedCount * 100.0 / totalProjects)) : "—" %></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Section 5: Docker / Deployment Status -->
                    <div class="report-section mb-5">
                        <h6 class="report-section-title"><span class="report-num">5</span> Deployment (Docker) Overview</h6>
                        <table class="report-table">
                            <thead>
                                <tr><th>Status</th><th>Count</th><th>% of Total</th></tr>
                            </thead>
                            <tbody>
                                <tr><td><span style="color:#10b981;">● Running</span></td><td><%= dockerRunning %></td><td><%= totalProjects > 0 ? String.format("%.1f%%", (dockerRunning * 100.0 / totalProjects)) : "—" %></td></tr>
                                <tr><td><span style="color:#f59e0b;">● Stopped</span></td><td><%= dockerStopped %></td><td><%= totalProjects > 0 ? String.format("%.1f%%", (dockerStopped * 100.0 / totalProjects)) : "—" %></td></tr>
                                <tr><td><span style="color:#ef4444;">● Error</span></td><td><%= dockerError %></td><td><%= totalProjects > 0 ? String.format("%.1f%%", (dockerError * 100.0 / totalProjects)) : "—" %></td></tr>
                                <tr><td><span style="color:#9ca3af;">● Not Deployed</span></td><td><%= dockerNone %></td><td><%= totalProjects > 0 ? String.format("%.1f%%", (dockerNone * 100.0 / totalProjects)) : "—" %></td></tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Section 6: Full Project Table -->
                    <div class="report-section">
                        <h6 class="report-section-title"><span class="report-num">6</span> Full Project Listing</h6>
                        <table class="report-table">
                            <thead>
                                <tr>
                                    <th>#</th><th>Project Title</th><th>Student</th><th>Supervisor</th>
                                    <th>Status</th><th>Milestone</th><th>Grade</th><th>Docker</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (allProjects != null) {
                                       int rowNum = 0;
                                       for (Project rp : allProjects) {
                                           rowNum++;
                                           String rds = rp.getDockerStatus() != null ? rp.getDockerStatus() : "none"; %>
                                <tr>
                                    <td><%= rowNum %></td>
                                    <td style="max-width:220px; word-wrap:break-word;"><%= rp.getTitle() %></td>
                                    <td><%= rp.getStudentName() != null ? rp.getStudentName() : "—" %></td>
                                    <td><%= rp.getSupervisorName() != null && !rp.getSupervisorName().isEmpty() ? rp.getSupervisorName() : "Unassigned" %></td>
                                    <td><%= rp.getStatus() %></td>
                                    <td>M<%= rp.getCurrentMilestoneNo() %></td>
                                    <td><%= rp.getOverallGrade() != null ? String.format("%.1f", rp.getOverallGrade()) : "—" %></td>
                                    <td><%= rds.toUpperCase() %></td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                        <div class="mt-4 pt-3 border-top text-muted small print-only" style="display:none;">
                            <em>This report was generated automatically by RailTrack FYP Management System. For internal use only.</em>
                        </div>
                    </div>

                </div><!-- /tab-pane#report -->

                <!-- ── Chart.js init ──────────────────────────────────────────────────────── -->
                <script>
                    (function () {
                        Chart.defaults.font.family = "'Inter', 'Segoe UI', sans-serif";
                        Chart.defaults.font.size = 11;

                        var pending = <%= statPending %>;
                        var active = <%= statActive %>;
                        var underReview = <%= statUnderReview %>;
                        var completed = <%= statCompleted %>;
                        var rejected = <%= statRejected %>;
                        var total = <%= totalProjects %>;

                        var assigned = <%= assignedCount %>;
                        var unassigned = <%= unassignedCount %>;

                        var dockerRunning = <%= dockerRunning %>;
                        var dockerStopped = <%= dockerStopped %>;
                        var dockerNone = <%= dockerNone %>;
                        var dockerError = <%= dockerError %>;

                        // ── 1. Status Doughnut ───────────────────────────────────────────────────
                        new Chart(document.getElementById('statusDoughnut'), {
                            type: 'doughnut',
                            data: {
                                labels: ['Pending', 'Active', 'Under Review', 'Completed', 'Rejected'],
                                datasets: [{
                                    data: [pending, active, underReview, completed, rejected],
                                    backgroundColor: ['#f59e0b', '#10b981', '#3b82f6', '#6366f1', '#ef4444'],
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
                                    legend: { position: 'bottom', labels: { boxWidth: 10, padding: 10 } },
                                    tooltip: {
                                        callbacks: {
                                            label: function (ctx) {
                                                var pct = total > 0 ? ((ctx.parsed / total) * 100).toFixed(1) : 0;
                                                return ' ' + ctx.label + ': ' + ctx.parsed + ' (' + pct + '%)';
                                            }
                                        }
                                    }
                                },
                                onClick: function(evt, elements) {
                                    if (elements.length > 0) {
                                        var index = elements[0].index;
                                        var label = this.data.labels[index];
                                        var filterVal = label.toUpperCase().replace(' ', '_');
                                        var btn = document.querySelector('.rt-filter-btn[data-filter="' + filterVal + '"]');
                                        if (btn) {
                                            btn.click();
                                            document.getElementById('projectsTable').scrollIntoView({ behavior: 'smooth', block: 'start' });
                                        }
                                    }
                                },
                                onHover: function(evt, elements) {
                                    evt.native.target.style.cursor = elements.length ? 'pointer' : 'default';
                                }
                            }
                        });

                        // ── 2. Pipeline Horizontal Bar ───────────────────────────────────────────
                        new Chart(document.getElementById('pipelineBar'), {
                            type: 'bar',
                            data: {
                                labels: ['Pending', 'Active', 'Under Review', 'Completed', 'Rejected'],
                                datasets: [{
                                    label: 'Projects',
                                    data: [pending, active, underReview, completed, rejected],
                                    backgroundColor: ['#fde68a', '#6ee7b7', '#93c5fd', '#a5b4fc', '#fca5a5'],
                                    borderColor: ['#f59e0b', '#10b981', '#3b82f6', '#6366f1', '#ef4444'],
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
                                    tooltip: {
                                        callbacks: {
                                            label: function (ctx) {
                                                var pct = total > 0 ? ((ctx.parsed.x / total) * 100).toFixed(1) : 0;
                                                return ' ' + ctx.parsed.x + ' projects (' + pct + '%)';
                                            }
                                        }
                                    }
                                },
                                scales: {
                                    x: {
                                        beginAtZero: true,
                                        ticks: { stepSize: 1, precision: 0 },
                                        grid: { color: 'rgba(0,0,0,.05)' }
                                    },
                                    y: { grid: { display: false } }
                                },
                                onClick: function(evt, elements) {
                                    if (elements.length > 0) {
                                        var index = elements[0].index;
                                        var label = this.data.labels[index];
                                        var filterVal = label.toUpperCase().replace(' ', '_');
                                        var btn = document.querySelector('.rt-filter-btn[data-filter="' + filterVal + '"]');
                                        if (btn) {
                                            btn.click();
                                            document.getElementById('projectsTable').scrollIntoView({ behavior: 'smooth', block: 'start' });
                                        }
                                    }
                                },
                                onHover: function(evt, elements) {
                                    evt.native.target.style.cursor = elements.length ? 'pointer' : 'default';
                                }
                            }
                        });

                        // ── 3. Assignment mini-doughnut ──────────────────────────────────────────
                        new Chart(document.getElementById('assignmentDonut'), {
                            type: 'doughnut',
                            data: {
                                labels: ['Assigned', 'Unassigned'],
                                datasets: [{
                                    data: [assigned, unassigned],
                                    backgroundColor: ['#f59e0b', '#e5e7eb'],
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
                                    tooltip: {
                                        callbacks: {
                                            label: function (ctx) {
                                                return ' ' + ctx.label + ': ' + ctx.parsed;
                                            }
                                        }
                                    }
                                }
                            }
                        });

                        // ── 4. Container status mini-doughnut ────────────────────────────────────
                        new Chart(document.getElementById('containerDonut'), {
                            type: 'doughnut',
                            data: {
                                labels: ['Running', 'Stopped', 'None', 'Error'],
                                datasets: [{
                                    data: [dockerRunning, dockerStopped, dockerNone, dockerError],
                                    backgroundColor: ['#10b981', '#f59e0b', '#9ca3af', '#ef4444'],
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
                                    tooltip: {
                                        callbacks: {
                                            label: function (ctx) {
                                                return ' ' + ctx.label + ': ' + ctx.parsed;
                                            }
                                        }
                                    }
                                }
                            }
                        });

// Logbook Line Chart
var months = <%= _logbookMonthsJson %>;
var submissions = <%= _logbookDataJson %>;

new Chart(document.getElementById('logbookLine'), {
    type: 'line',
    data: {
        labels: months,
        datasets: [{
            label: 'Submissions',
            data: submissions,
            borderColor: '#3b82f6',
            backgroundColor: 'rgba(59, 130, 246, 0.1)',
            fill: true,
            tension: 0.4
        }]
    },
    options: { responsive: true, maintainAspectRatio: false }
});

// Presentation Eligibility
var eligibleCount = <%= _eligibleCount %>;
var ineligibleCount = <%= _ineligibleCount %>;
new Chart(document.getElementById('eligibilityPie'), {
    type: 'doughnut',
    data: {
        labels: ['Eligible', 'Not Eligible'],
        datasets: [{
            data: [eligibleCount, ineligibleCount],
            backgroundColor: ['#10b981', '#ef4444']
        }]
    },
    options: { responsive: true, maintainAspectRatio: false }
});

// Actual Data for the other charts injected by backend logic
var sNames = <%= _supNamesJson %>;
var sWorkloads = <%= _supCountsJson %>;

new Chart(document.getElementById('workloadBar'), {
    type: 'bar',
    data: {
        labels: sNames,
        datasets: [{
            label: 'Projects Assigned',
            data: sWorkloads,
            backgroundColor: '#3b82f6',
            borderRadius: 5
        }]
    },
    options: { responsive: true, maintainAspectRatio: false }
});

var msDist = <%= _msDistJson %>;
new Chart(document.getElementById('milestoneDistBar'), {
    type: 'bar',
    data: {
        labels: ['M1', 'M2', 'M3', 'M4'],
        datasets: [{
            label: 'Submissions',
            data: msDist,
            backgroundColor: '#f59e0b',
            borderRadius: 5
        }]
    },
    options: { responsive: true, maintainAspectRatio: false }
});

var pitaEvaluated = <%= _pitaEvaluated %>;
var pitaPending = <%= _pitaPending %>;
new Chart(document.getElementById('pitaDonut'), {
    type: 'doughnut',
    data: {
        labels: ['Evaluated', 'Pending'],
        datasets: [{
            data: [pitaEvaluated, pitaPending],
            backgroundColor: ['#10b981', '#f59e0b']
        }]
    },
    options: { responsive: true, maintainAspectRatio: false }
});

var gradeA = <%= _gradeA %>;
var gradeB = <%= _gradeB %>;
var gradeC = <%= _gradeC %>;
var gradeF = <%= _gradeF %>;
new Chart(document.getElementById('gradePie'), {
    type: 'pie',
    data: {
        labels: ['A', 'B', 'C', 'F'],
        datasets: [{
            data: [gradeA, gradeB, gradeC, gradeF],
            backgroundColor: ['#10b981', '#3b82f6', '#f59e0b', '#ef4444']
        }]
    },
    options: { responsive: true, maintainAspectRatio: false }
});

var deptNames = <%= _deptNamesJson %>;
var deptProjects = <%= _deptProjectCountsJson %>;
new Chart(document.getElementById('deptProjectPie'), {
    type: 'pie',
    data: {
        labels: deptNames,
        datasets: [{
            data: deptProjects,
            backgroundColor: ['#6366f1', '#ec4899', '#14b8a6', '#f59e0b', '#8b5cf6']
        }]
    },
    options: { responsive: true, maintainAspectRatio: false }
});

var deptAvgGrades = <%= _deptAvgGradesJson %>;
new Chart(document.getElementById('deptGradeBar'), {
    type: 'bar',
    data: {
        labels: deptNames,
        datasets: [{
            label: 'Average Grade',
            data: deptAvgGrades,
            backgroundColor: '#10b981',
            borderRadius: 5
        }]
    },
    options: { responsive: true, maintainAspectRatio: false }
});

                        // ── Filter buttons ───────────────────────────────────────────────────────
                        document.querySelectorAll('.rt-filter-btn').forEach(function (btn) {
                            btn.addEventListener('click', function () {
                                document.querySelectorAll('.rt-filter-btn').forEach(function (b) { b.classList.remove('active'); });
                                btn.classList.add('active');
                                var filter = btn.dataset.filter;
                                var rows = document.querySelectorAll('#projectsTable tbody tr');
                                rows.forEach(function (row) {
                                    row.style.display = (filter === 'all' || row.dataset.status === filter) ? '' : 'none';
                                });
                            });
                        });
                    })();
                </script>

                <jsp:include page="/views/common/footer.jsp" />

<!-- Docker Monitor Loading Overlay -->
<div id="dockerLoadOverlay" style="
    display: none;
    position: fixed;
    inset: 0;
    z-index: 9999;
    background: rgba(10, 12, 18, 0.85);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 1.5rem;">

    <div style="text-align: center;">
        <!-- Animated Docker stack icon -->
        <div style="font-size: 3rem; color: #0075db; margin-bottom: 0.75rem;
                    animation: dockerStackPulse 1.4s ease-in-out infinite;">
            <i class="bi bi-hdd-stack-fill"></i>
        </div>
        <div style="color: #e2e8f0; font-size: 1.15rem; font-weight: 700; letter-spacing: 0.01em;">
            Loading Docker Monitor
        </div>
        <div style="color: #718096; font-size: 0.82rem; margin-top: 0.3rem;">
            Querying containers &amp; live stats&hellip;
        </div>
    </div>

    <!-- Animated progress bar -->
    <div style="width: min(340px, 88vw);">
        <div style="background: #2d3748; border-radius: 999px; height: 5px; overflow: hidden;">
            <div id="dockerLoadBar"
                 style="height: 100%; width: 0%; border-radius: 999px;
                        background: linear-gradient(90deg, #0075db, #38bdf8, #0075db);
                        background-size: 200% 100%;
                        animation: dockerShimmer 1.6s linear infinite;
                        transition: width 0.5s ease;"></div>
        </div>
        <div style="display: flex; justify-content: space-between;
                    margin-top: 0.4rem; font-size: 0.7rem; color: #4a5568;">
            <span id="dockerLoadStep">Connecting to Docker daemon...</span>
            <span id="dockerLoadPct">0%</span>
        </div>
    </div>
</div>

<style>
@keyframes dockerStackPulse {
    0%, 100% { opacity: 1;  transform: translateY(0);    }
    50%       { opacity: .7; transform: translateY(-4px); }
}
@keyframes dockerShimmer {
    0%   { background-position: 200% 0; }
    100% { background-position: -200% 0; }
}
</style>

<script>
function showDockerLoadingOverlay() {
    var overlay = document.getElementById('dockerLoadOverlay');
    var bar     = document.getElementById('dockerLoadBar');
    var step    = document.getElementById('dockerLoadStep');
    var pct     = document.getElementById('dockerLoadPct');

    overlay.style.display = 'flex';

    var steps = [
        { delay: 300,  width: 20, label: 'Connecting to Docker daemon...' },
        { delay: 900,  width: 45, label: 'Fetching container list...' },
        { delay: 1600, width: 68, label: 'Reading live CPU & memory stats...' },
        { delay: 2400, width: 88, label: 'Preparing dashboard...' }
    ];

    steps.forEach(function(s) {
        setTimeout(function() {
            bar.style.width    = s.width + '%';
            step.textContent   = s.label;
            pct.textContent    = s.width + '%';
        }, s.delay);
    });
}
</script>

<style>
/* ── Report Component Styles ─────────────────────────────────────────────── */
.report-section-title {
    font-size: 0.95rem;
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 1rem;
    display: flex;
    align-items: center;
    gap: 0.6rem;
    border-bottom: 2px solid #e2e8f0;
    padding-bottom: 0.5rem;
}
.report-num {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 24px; height: 24px;
    border-radius: 50%;
    background: #0075db;
    color: #fff;
    font-size: 0.75rem;
    font-weight: 700;
    flex-shrink: 0;
}
.report-kpi-card {
    background: #fff;
    border: 1px solid #e2e8f0;
    border-top: 3px solid #0075db;
    border-radius: 8px;
    padding: 1rem;
    text-align: center;
    box-shadow: 0 1px 4px rgba(0,0,0,.06);
}
.report-kpi-value {
    font-size: 1.8rem;
    font-weight: 800;
    color: #0075db;
    line-height: 1;
}
.report-kpi-label {
    font-size: 0.72rem;
    color: #64748b;
    font-weight: 600;
    margin-top: 0.35rem;
    text-transform: uppercase;
    letter-spacing: 0.04em;
}
.report-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 0.855rem;
}
.report-table th {
    background: #f1f5f9;
    color: #475569;
    font-weight: 600;
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    padding: 0.55rem 0.75rem;
    border-bottom: 2px solid #e2e8f0;
    text-align: left;
}
.report-table td {
    padding: 0.5rem 0.75rem;
    border-bottom: 1px solid #f1f5f9;
    vertical-align: middle;
}
.report-table tbody tr:hover {
    background: #f8fafc;
}

/* ── Print Styles ─────────────────────────────────────────────────────────── */
@media print {
    /* Hide everything except the report tab content */
    body * { visibility: hidden; }
    #report, #report * { visibility: visible; }
    #report { position: absolute; left: 0; top: 0; width: 100%; }

    /* Show print-only elements */
    .print-only { display: block !important; }

    /* Hide screen-only elements */
    .no-print { display: none !important; }

    /* Page setup */
    @page { margin: 1.5cm 1.8cm; size: A4 portrait; }

    /* Clean print table */
    .report-table th { background: #e2e8f0 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    .report-table tbody tr:nth-child(even) td { background: #f8fafc !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }

    /* KPI cards in a row for print */
    .report-kpi-card { border: 1px solid #ccc !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }

    /* Force page breaks between sections */
    .report-section { page-break-inside: avoid; }
}
</style>

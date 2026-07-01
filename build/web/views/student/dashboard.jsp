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

    boolean canSubmit = true;
    if (projects != null) {
        for (Project p : projects) {
            if (p.getStatus() != Project.Status.REJECTED) {
                canSubmit = false;
                break;
            }
        }
    }
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

<!-- ── Analytics Section ─────────────────────────────────────────────────── -->
<%
    Integer logbookCount = (Integer) request.getAttribute("logbookCount");
    if (logbookCount == null) logbookCount = 0;
    
    Integer totalLogbookCount = (Integer) request.getAttribute("totalLogbookCount");
    if (totalLogbookCount == null) totalLogbookCount = 0;
    
    Boolean reportSubmitted = (Boolean) request.getAttribute("reportSubmitted");
    if (reportSubmitted == null) reportSubmitted = false;
    
    String observationMark = (String) request.getAttribute("observationMark");
    if (observationMark == null) observationMark = "0.00";
    
    Boolean presentationEligible = (Boolean) request.getAttribute("presentationEligible");
    if (presentationEligible == null) presentationEligible = false;
    
    String devProgressStr = (String) request.getAttribute("devProgress");
    if (devProgressStr == null) devProgressStr = "0.0";
    String execProgressStr = (String) request.getAttribute("execProgress");
    if (execProgressStr == null) execProgressStr = "0.0";
    String overallProgressStr = (String) request.getAttribute("overallProgress");
    if (overallProgressStr == null) overallProgressStr = "0.0";
    
    int[] chapterProgress = (int[]) request.getAttribute("chapterProgress");
    if (chapterProgress == null) chapterProgress = new int[]{0,0,0,0,0,0,0,0};
%>

<div class="mb-5 mt-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-3 gap-2">
        <div>
            <h4 class="fw-bold mb-0">Progress Overview</h4>
            <p class="text-muted mb-0" style="font-size:.875rem;">Track your academic requirements and project completion metrics.</p>
        </div>
    </div>
    <div class="row g-3 mb-4">
        <!-- Logbook Card -->
        <div class="col-6 col-md-3">
            <div class="card bg-white h-100 border" style="border-radius: 12px; border-color: #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.02);">
                <div class="card-body py-3">
                    <div class="text-muted fw-semibold mb-1" style="font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.5px;">Logbook</div>
                    <div class="fs-4 fw-bold text-dark">
                        <span class="text-primary"><%= logbookCount %></span><span class="text-muted fs-6">/<%= totalLogbookCount %></span>
                    </div>
                </div>
            </div>
        </div>
        <!-- Observation Mark Card -->
        <div class="col-6 col-md-3">
            <div class="card bg-white h-100 border" style="border-radius: 12px; border-color: #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.02);">
                <div class="card-body py-3">
                    <div class="text-muted fw-semibold mb-1" style="font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.5px;">Observation Mark</div>
                    <%
                        double parsedOm = 0.0;
                        try { parsedOm = Double.parseDouble(observationMark); } catch(Exception e){}
                    %>
                    <div class="fs-4 fw-bold <%= parsedOm >= 50.0 ? "text-success" : "text-dark" %>">
                        <%= observationMark %>
                    </div>
                </div>
            </div>
        </div>
        <!-- Presentation Eligibility Card -->
        <div class="col-6 col-md-3">
            <div class="card bg-white h-100 border" style="border-radius: 12px; border-color: #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.02);">
                <div class="card-body py-3">
                    <div class="text-muted fw-semibold mb-1" style="font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.5px;">Presentation</div>
                    <div class="fs-4 fw-bold d-flex align-items-center">
                        <% if (presentationEligible) { %>
                            <i class="bi bi-check2-circle text-success me-2"></i> <span class="fs-6 text-muted fw-medium">Eligible</span>
                        <% } else { %>
                            <i class="bi bi-dash-circle text-muted me-2" style="opacity: 0.5;"></i> <span class="fs-6 text-muted fw-medium">Pending</span>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
        <!-- Report Submission Card -->
        <div class="col-6 col-md-3">
            <div class="card bg-white h-100 border" style="border-radius: 12px; border-color: #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.02);">
                <div class="card-body py-3">
                    <div class="text-muted fw-semibold mb-1" style="font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.5px;">Report Submission</div>
                    <div class="fs-4 fw-bold d-flex align-items-center">
                        <% if (reportSubmitted) { %>
                            <i class="bi bi-check2-circle text-success me-2"></i> <span class="fs-6 text-muted fw-medium">Submitted</span>
                        <% } else { %>
                            <i class="bi bi-dash-circle text-muted me-2" style="opacity: 0.5;"></i> <span class="fs-6 text-muted fw-medium">Pending</span>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Charts Row -->
    <div class="row g-4">
        <!-- Donut Charts -->
        <div class="col-12 col-xl-7">
            <div class="card shadow-sm border-0 h-100" style="border-radius: 12px;">
                <div class="card-header bg-white border-0 pt-4 pb-0 px-4">
                    <h5 class="fw-bold mb-0 text-dark" style="font-size: 1.1rem;">Overall Progress</h5>
                </div>
                <div class="card-body d-flex justify-content-around align-items-center flex-wrap pb-0">
                    <div class="text-center mb-3">
                        <div id="devProgressChart" style="width: 150px; height: 150px;"></div>
                        <div class="small fw-semibold mt-1">Development Progress (<%= devProgressStr %>%)</div>
                    </div>
                    <div class="text-center mb-3">
                        <div id="execProgressChart" style="width: 150px; height: 150px;"></div>
                        <div class="small fw-semibold mt-1">Execution Progress (<%= execProgressStr %>%)</div>
                    </div>
                    <div class="text-center mb-3">
                        <div id="overallProgressChart" style="width: 150px; height: 150px;"></div>
                        <div class="small fw-semibold mt-1">Overall Completion (<%= overallProgressStr %>%)</div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Bar Chart -->
        <div class="col-12 col-xl-5">
            <div class="card shadow-sm border-0 h-100" style="border-radius: 12px;">
                <div class="card-header bg-white border-0 pt-4 pb-0 px-4">
                    <h5 class="fw-bold mb-0 text-dark" style="font-size: 1.1rem;">Chapter Breakdown</h5>
                </div>
                <div class="card-body pb-0">
                    <div id="chapterProgressChart" style="width: 100%; height: 200px;"></div>
                    <div class="text-center small fw-semibold mt-1 pb-3">Thesis Progress By Chapter</div>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script type="text/javascript">
    google.charts.load('current', {'packages':['corechart']});
    google.charts.setOnLoadCallback(drawCharts);

    function drawCharts() {
        var donutOptions = {
            pieHole: 0.75,
            legend: 'none',
            pieSliceText: 'none',
            tooltip: { trigger: 'none' },
            chartArea: { width: '90%', height: '90%' },
            slices: {
                0: { color: '#dc3545' }, // Red
                1: { color: '#f8f9fa' }
            }
        };

        var devVal = parseFloat("<%= devProgressStr %>");
        var devData = google.visualization.arrayToDataTable([
            ['Task', 'Percentage'],
            ['Done', devVal],
            ['Remaining', 100 - devVal]
        ]);
        var devChart = new google.visualization.PieChart(document.getElementById('devProgressChart'));
        devChart.draw(devData, donutOptions);

        var execOptions = Object.assign({}, donutOptions);
        execOptions.slices = {
            0: { color: '#0d6efd' }, // Blue
            1: { color: '#f8f9fa' }
        };
        var execVal = parseFloat("<%= execProgressStr %>");
        var execData = google.visualization.arrayToDataTable([
            ['Task', 'Percentage'],
            ['Done', execVal],
            ['Remaining', 100 - execVal]
        ]);
        var execChart = new google.visualization.PieChart(document.getElementById('execProgressChart'));
        execChart.draw(execData, execOptions);

        var overallOptions = Object.assign({}, donutOptions);
        overallOptions.slices = {
            0: { color: '#198754' }, // Green
            1: { color: '#f8f9fa' }
        };
        var overallVal = parseFloat("<%= overallProgressStr %>");
        var overallData = google.visualization.arrayToDataTable([
            ['Task', 'Percentage'],
            ['Done', overallVal],
            ['Remaining', 100 - overallVal]
        ]);
        var overallChart = new google.visualization.PieChart(document.getElementById('overallProgressChart'));
        overallChart.draw(overallData, overallOptions);

        // Bar Chart
        var barData = google.visualization.arrayToDataTable([
            ['Chapter', 'Value', { role: 'style' }],
            ['Abstract', <%= chapterProgress[0] %>, 'color: #8fb8d5'],
            ['Ch1', <%= chapterProgress[1] %>, 'color: #8fb8d5'],
            ['Ch2', <%= chapterProgress[2] %>, 'color: #8fb8d5'],
            ['Ch3', <%= chapterProgress[3] %>, 'color: #8fb8d5'],
            ['Ch4', <%= chapterProgress[4] %>, 'color: #8fb8d5'],
            ['Ch5', <%= chapterProgress[5] %>, 'color: #8fb8d5'],
            ['Ch6', <%= chapterProgress[6] %>, 'color: #8fb8d5'],
            ['Ch7', <%= chapterProgress[7] %>, 'color: #8fb8d5']
        ]);

        var barOptions = {
            legend: { position: 'none' },
            bar: { groupWidth: '70%' },
            chartArea: { width: '85%', height: '70%' },
            vAxis: { minValue: 0, maxValue: 5, ticks: [0,1,2,3,4,5] },
            hAxis: { 
                slantedText: true, 
                slantedTextAngle: 30,
                textStyle: { fontSize: 9 }
            }
        };

        var barChart = new google.visualization.ColumnChart(document.getElementById('chapterProgressChart'));
        barChart.draw(barData, barOptions);
    }
    
    window.addEventListener('resize', drawCharts);
</script>

<!-- FYP Evaluation Roadmap -->
<%
    int rmMF = logbookCount != null ? logbookCount : 0;
    double rmOM = 0.0;
    try { rmOM = Double.parseDouble(observationMark); } catch(Exception e){}
    double rmCM = 0.0;
    String cmStr = (String) request.getAttribute("continuousMark");
    try { if (cmStr != null) rmCM = Double.parseDouble(cmStr); } catch(Exception e){}
    
    boolean rmLP = presentationEligible;
    boolean rmLHT = request.getAttribute("thesisEligible") != null && (Boolean) request.getAttribute("thesisEligible");
    boolean rmHT = reportSubmitted;

    // Determine states (done, active, locked)
    String cMULA = "done";
    String cMF = (rmMF >= 5) ? "done" : "active";
    String cOM = (rmMF >= 5) ? ((rmOM >= 50.0) ? "done" : "active") : "locked";
    // LP requires both MF and OM
    String cLP = rmLP ? "done" : ((rmMF >= 5 && rmOM >= 50.0) ? "active" : "locked");
    String cCM = rmLP ? ((rmCM >= 45.0) ? "done" : "active") : "locked";
    String cLHT = rmLHT ? "done" : (rmLP && rmCM >= 45.0 ? "active" : "locked");
    String cHT = rmLHT ? (rmHT ? "done" : "active") : "locked";
    String cPASS = rmHT ? "done" : "locked";
    String cEND = rmHT ? "done" : "locked";
%>
<div class="mb-5 mt-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-3 gap-2">
        <div>
            <h4 class="fw-bold mb-0">FYP Roadmap</h4>
            <p class="text-muted mb-0" style="font-size:.875rem;">Evaluation flow and criteria to pass FYP.</p>
        </div>
    </div>
    <div class="card shadow-sm border-0 mb-4" style="border-radius: 12px;">
        <div class="card-body p-4 position-relative" style="overflow-x: auto;">
            
            <div class="mermaid text-center" style="font-family: 'Inter', sans-serif;">
                %%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#ffffff', 'edgeLabelBackground':'#ffffff', 'fontFamily': 'inherit', 'lineColor': '#e2e8f0'}}}%%
                flowchart LR
                    START((("START")))
                    MF{"MF >= 5?"}
                    OM{"OM >= 50%?"}
                    LP["Eligible for<br/>Final Presentation"]
                    CM{"CM >= 45%?"}
                    LHT["Eligible to<br/>Submit Thesis"]
                    HT{"Submit<br/>Thesis?"}
                    PASS(["PASS"])
                    FAIL(["FAIL"])
                    END((("END")))

                    START --> MF
                    MF -- Yes --> OM
                    MF -. No .-> FAIL
                    OM -- Yes --> LP
                    OM -. No .-> FAIL
                    LP --> CM
                    CM -- Yes --> LHT
                    CM -. No .-> FAIL
                    LHT --> HT
                    HT -- Yes --> PASS
                    HT -. No .-> FAIL
                    PASS --> END
                    FAIL -.-> END

                    %% Minimalist Art Style
                    classDef done fill:#f0fdf4,stroke:#22c55e,stroke-width:1px,color:#166534;
                    classDef active fill:#eff6ff,stroke:#3b82f6,stroke-width:1.5px,color:#1e40af;
                    classDef locked fill:#ffffff,stroke:#cbd5e1,stroke-width:1px,color:#94a3b8,stroke-dasharray:5,5;
                    classDef fail fill:#fef2f2,stroke:#ef4444,stroke-width:1px,color:#991b1b,stroke-dasharray:5,5;

                    class START <%= cMULA %>;
                    class MF <%= cMF %>;
                    class OM <%= cOM %>;
                    class LP <%= cLP %>;
                    class CM <%= cCM %>;
                    class LHT <%= cLHT %>;
                    class HT <%= cHT %>;
                    class PASS <%= cPASS %>;
                    class END <%= cEND %>;
                    class FAIL fail;
            </div>
            
            <div class="mt-4 border-top pt-3 d-flex flex-wrap justify-content-between align-items-center" style="font-size: 0.8rem;">
                <div class="d-flex flex-wrap gap-4 text-muted">
                    <span class="d-flex align-items-center"><span class="badge me-2" style="background-color: #f0fdf4; border: 1px solid #22c55e; color: #166534;">&nbsp;</span> Completed</span>
                    <span class="d-flex align-items-center"><span class="badge me-2" style="background-color: #eff6ff; border: 1.5px solid #3b82f6; color: #1e40af;">&nbsp;</span> Current Stage</span>
                    <span class="d-flex align-items-center"><span class="badge me-2" style="background-color: #ffffff; border: 1px dashed #cbd5e1; color: #94a3b8;">&nbsp;</span> Locked</span>
                </div>
                <div class="mt-2 mt-md-0 text-muted">
                    <strong>MF:</strong> Meeting Frequency &nbsp;&middot;&nbsp; 
                    <strong>OM:</strong> Observation Mark &nbsp;&middot;&nbsp; 
                    <strong>CM:</strong> Continuous Assessment
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Add Mermaid JS -->
<script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10.6.1/dist/mermaid.esm.min.mjs';
    
    mermaid.initialize({ 
        startOnLoad: false, 
        theme: 'base', 
        securityLevel: 'loose',
        themeVariables: { fontFamily: 'Inter, sans-serif' } 
    });

    try {
        await mermaid.run({
            querySelector: '.mermaid'
        });
    } catch (e) {
        console.error('Mermaid render error:', e);
    }
</script>

<!-- Page header -->
<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h4 class="fw-bold mb-0">My Projects</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">Track and manage your FYP submissions</p>
    </div>
    <% if (canSubmit) { %>
    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#submitModal">
        <i class="bi bi-plus-lg me-1"></i>Submit New Project
    </button>
    <% } else { %>
    <button class="btn btn-secondary btn-sm" disabled title="You have already submitted a project.">
        <i class="bi bi-lock-fill me-1"></i>Limit: 1 Project
    </button>
    <% } %>
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
            <% if (p.getDescription() != null && !p.getDescription().trim().isEmpty()) { %>
            <p class="text-secondary mb-1 text-truncate" style="font-size:.78rem; max-width:100%;" title="<%= p.getDescription() %>">
                <%= p.getDescription() %>
            </p>
            <% } %>
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

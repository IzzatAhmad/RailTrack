<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.*,com.railtrack.system.service.DockerService,java.util.List,java.util.Map,java.time.format.DateTimeFormatter" %>
<%
    request.setAttribute("pageTitle", "Docker Monitoring");
    List<Project> projects = (List<Project>) request.getAttribute("projects");
    List<DeploymentLog> recentLogs = (List<DeploymentLog>) request.getAttribute("recentLogs");
    String ctx = request.getContextPath();

    DockerService dockerService = new DockerService();

    // Compute stats
    long runningCount = 0;
    long stoppedCount = 0;
    long errorCount = 0;
    long builtCount = 0;
    long noneCount = 0;

    if (projects != null) {
        for (Project p : projects) {
            String ds = p.getDockerStatus() != null ? p.getDockerStatus() : "none";
            if ("running".equalsIgnoreCase(ds)) {
                runningCount++;
            } else if ("stopped".equalsIgnoreCase(ds) || "exited".equalsIgnoreCase(ds)) {
                stoppedCount++;
            } else if ("error".equalsIgnoreCase(ds)) {
                errorCount++;
            } else if ("built".equalsIgnoreCase(ds)) {
                builtCount++;
            } else {
                noneCount++;
            }
        }
    }

    long totalDeployed = runningCount + stoppedCount + errorCount + builtCount;
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
%>
<jsp:include page="/views/common/header.jsp"/>

<style>
    /* Premium visual overrides and dashboard-specific styles */
    .rt-docker-card {
        transition: transform 0.2s ease, box-shadow 0.2s ease;
        border-radius: 12px;
    }
    .rt-docker-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(30, 39, 64, 0.12);
    }
    .pulse-green {
        display: inline-block;
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background-color: var(--rt-success);
        box-shadow: 0 0 0 0 rgba(22, 163, 74, 0.7);
        animation: pulse-green-anim 2s infinite;
    }
    @keyframes pulse-green-anim {
        0% {
            transform: scale(0.95);
            box-shadow: 0 0 0 0 rgba(22, 163, 74, 0.7);
        }
        70% {
            transform: scale(1);
            box-shadow: 0 0 0 6px rgba(22, 163, 74, 0);
        }
        100% {
            transform: scale(0.95);
            box-shadow: 0 0 0 0 rgba(22, 163, 74, 0);
        }
    }
    .log-scroll-panel {
        max-height: 480px;
        overflow-y: auto;
        padding-right: 4px;
    }
    .log-scroll-panel::-webkit-scrollbar {
        width: 6px;
    }
    .log-scroll-panel::-webkit-scrollbar-track {
        background: transparent;
    }
    .log-scroll-panel::-webkit-scrollbar-thumb {
        background-color: var(--rt-border);
        border-radius: 3px;
    }
    .log-item {
        border-left: 3px solid var(--rt-border);
        padding-left: 1rem;
        position: relative;
        margin-bottom: 1rem;
    }
    .log-item.success {
        border-left-color: var(--rt-success);
    }
    .log-item.failed {
        border-left-color: var(--rt-danger);
    }
    .log-dot {
        position: absolute;
        left: -6px;
        top: 4px;
        width: 9px;
        height: 9px;
        border-radius: 50%;
        background: var(--rt-border);
        border: 2px solid white;
    }
    .log-item.success .log-dot {
        background: var(--rt-success);
    }
    .log-item.failed .log-dot {
        background: var(--rt-danger);
    }
</style>

<!-- ── Flash Notifications ────────────────────────────────────────────────── -->
<% if (request.getAttribute("flashSuccess") != null) { %>
    <div class="rt-alert rt-alert-success mb-4" id="flash-success">
        <i class="bi bi-check-circle-fill"></i>
        <span><%= request.getAttribute("flashSuccess") %></span>
    </div>
<% } %>
<% if (request.getAttribute("flashError") != null) { %>
    <div class="rt-alert rt-alert-error mb-4" id="flash-error">
        <i class="bi bi-exclamation-triangle-fill"></i>
        <span><%= request.getAttribute("flashError") %></span>
    </div>
<% } %>

<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/coordinator/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">Docker Monitor</span>
</nav>

<!-- ── Header ─────────────────────────────────────────────────────────────── -->
<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h4 class="fw-bold mb-0">Docker Monitor</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">Global container status, controls, and deployment activity logs</p>
    </div>
    <div class="d-flex gap-2">
        <button onclick="window.location.reload()" class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-arrow-clockwise me-1"></i>Refresh Status
        </button>
    </div>
</div>

<!-- ── Stats Overview ───────────────────────────────────────────────────────── -->
<div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
        <div class="rt-card rt-docker-card p-3 text-center">
            <div class="fs-3 fw-bold text-secondary"><%= totalDeployed %></div>
            <div style="font-size:.75rem;color:var(--rt-muted);font-weight:600;">TOTAL DEPLOYED</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="rt-card rt-docker-card p-3 text-center">
            <div class="fs-3 fw-bold text-success">
                <span class="pulse-green me-1"></span><%= runningCount %>
            </div>
            <div style="font-size:.75rem;color:var(--rt-muted);font-weight:600;">RUNNING</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="rt-card rt-docker-card p-3 text-center">
            <div class="fs-3 fw-bold text-warning"><%= stoppedCount %></div>
            <div style="font-size:.75rem;color:var(--rt-muted);font-weight:600;">STOPPED</div>
        </div>
    </div>
    <div class="col-6 col-md-3">
        <div class="rt-card rt-docker-card p-3 text-center">
            <div class="fs-3 fw-bold text-danger"><%= errorCount %></div>
            <div style="font-size:.75rem;color:var(--rt-muted);font-weight:600;">ERRORS / FAILURES</div>
        </div>
    </div>
</div>

<!-- ── Docker Desktop-style Summary Bar ───────────────────────────────────── -->
<%
    DockerService.SystemInfo sysInfo = (DockerService.SystemInfo) request.getAttribute("systemInfo");
    String totalCpuPerc  = (sysInfo != null && sysInfo.totalCpuPerc  != null) ? sysInfo.totalCpuPerc  : "0.00%";
    String totalMemUsage = (sysInfo != null && sysInfo.totalMemUsage != null) ? sysInfo.totalMemUsage : "0MB / 0GB";
    int    cpuCount      = (sysInfo != null) ? sysInfo.cpuCount : 0;
    double totalCpuPct   = 0;
    double memPct        = (sysInfo != null) ? sysInfo.totalMemPercent : 0;
    try { totalCpuPct = Double.parseDouble(totalCpuPerc.replace("%","").trim()); } catch(Exception ignored) {}
    double cpuCapacity   = cpuCount * 100.0;
    double cpuBarWidth   = cpuCapacity > 0 ? Math.min((totalCpuPct / cpuCapacity) * 100, 100) : 0;
    double memBarWidth   = Math.min(memPct, 100);
%>
<div class="row g-3 mb-4">
    <div class="col-12 col-md-6">
        <div class="rt-card p-3">
            <div class="d-flex justify-content-between align-items-center mb-1">
                <span class="small text-muted fw-semibold">Container CPU usage <i class="bi bi-info-circle"></i></span>
            </div>
            <div class="fw-bold" style="color: #0075db; font-size: 1.1rem;">
                <%= totalCpuPerc %> / <%= String.format("%.0f", cpuCapacity) %>%
                <span class="text-muted fw-normal" style="font-size: 0.78rem;">(<%= cpuCount %> CPUs available)</span>
            </div>
            <div class="mt-2 rounded" style="height: 6px; background: #e9ecef;">
                <div style="height:6px; width:<%= String.format("%.2f", cpuBarWidth) %>%; background:#0075db; border-radius:3px; transition: width 0.6s;"></div>
            </div>
        </div>
    </div>
    <div class="col-12 col-md-6">
        <div class="rt-card p-3">
            <div class="d-flex justify-content-between align-items-center mb-1">
                <span class="small text-muted fw-semibold">Container memory usage <i class="bi bi-info-circle"></i></span>
            </div>
            <div class="fw-bold" style="color: #0075db; font-size: 1.1rem;">
                <%= totalMemUsage %>
            </div>
            <div class="mt-2 rounded" style="height: 6px; background: #e9ecef;">
                <div style="height:6px; width:<%= String.format("%.2f", memBarWidth) %>%; background:#0075db; border-radius:3px; transition: width 0.6s;"></div>
            </div>
        </div>
    </div>
</div>

<!-- ── Main Dashboard Layout ───────────────────────────────────────────────── -->
<div class="row g-4">

    <!-- Containers Grid (Full Width) -->
    <div class="col-12">
        <div class="rt-card">
            <div class="rt-card-header justify-content-between">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-hdd-stack text-primary"></i>
                    <span>Active Containers</span>
                </div>
                <span class="badge bg-light text-secondary rounded-pill"><%= projects != null ? projects.size() : 0 %> Projects</span>
            </div>

            <% if (projects == null || projects.isEmpty()) { %>
                <div class="p-5 text-center text-muted">
                    <i class="bi bi-box" style="font-size: 2.5rem;"></i>
                    <p class="mt-2 mb-0">No student projects found in the system.</p>
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th style="min-width: 250px;">Project Details</th>
                                <th style="min-width: 150px;">Container Info</th>
                                <th style="min-width: 120px;">Status</th>
                                <th style="min-width: 100px;">CPU (%)</th>
                                <th style="min-width: 150px;">Memory</th>
                                <th class="text-end" style="min-width: 150px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                for (Project p : projects) {
                                    String ds = p.getDockerStatus() != null ? p.getDockerStatus() : "none";
                                    String dsClass = "exited".equalsIgnoreCase(ds) ? "stopped" : ds;
                                    
                                    Map<Integer, String[]> containerStatsMap = (Map<Integer, String[]>) request.getAttribute("containerStatsMap");
                                    String[] statsArray = null;
                                    if ("running".equalsIgnoreCase(ds) && containerStatsMap != null) {
                                        statsArray = containerStatsMap.get(p.getId());
                                    }
                            %>
                            <tr>
                                <td>
                                    <div class="fw-semibold" style="max-width: 350px;" title="<%= p.getTitle() %>">
                                        <%= p.getTitle() %>
                                    </div>
                                    <div class="small text-muted mt-1">
                                        <i class="bi bi-person me-1"></i><%= p.getStudentName() %>
                                    </div>
                                    <div class="small text-muted mt-1">
                                        <i class="bi bi-person-badge me-1"></i><%= p.getSupervisorName() != null && !p.getSupervisorName().isEmpty() ? p.getSupervisorName() : "Unassigned" %>
                                    </div>
                                    <div class="d-flex align-items-center gap-2 mt-2">
                                        <% if (p.getRepoUrl() != null && !p.getRepoUrl().isEmpty()) { %>
                                            <a href="<%= p.getRepoUrl() %>" target="_blank" class="badge bg-light text-primary text-decoration-none font-monospace" style="font-size: 10px;">
                                                <i class="bi bi-github me-1"></i>Repo
                                            </a>
                                        <% } %>
                                        <% if (p.getBranch() != null) { %>
                                            <span class="badge bg-light text-muted font-monospace" style="font-size: 10px;">
                                                <i class="bi bi-git me-1"></i><%= p.getBranch() %>
                                            </span>
                                        <% } %>
                                    </div>
                                </td>
                                <td>
                                    <% if ("running".equalsIgnoreCase(ds) || "stopped".equalsIgnoreCase(ds)) { %>
                                        <div class="font-monospace small text-dark"><i class="bi bi-box me-1"></i><%= p.getContainerId() != null ? p.getContainerId() : "N/A" %></div>
                                        <div class="small text-muted mt-1">
                                            Port: <span class="badge bg-light text-dark font-monospace"><%= p.getContainerPort() %></span>
                                        </div>
                                        <div class="small text-muted mt-1" style="font-size: 10px;" title="<%= p.getImageTag() %>">
                                            Image: <span class="font-monospace text-truncate d-inline-block" style="max-width: 150px; vertical-align: bottom;"><%= p.getImageTag() != null ? p.getImageTag() : "N/A" %></span>
                                        </div>
                                    <% } else { %>
                                        <span class="text-muted small">-</span>
                                    <% } %>
                                </td>
                                <td>
                                    <span class="small text-nowrap rt-docker-<%= dsClass %> d-flex align-items-center gap-1">
                                        <% if ("running".equalsIgnoreCase(ds)) { %>
                                            <span class="pulse-green"></span>
                                        <% } else { %>
                                            <i class="bi bi-circle-fill" style="font-size: 7px;"></i>
                                        <% } %>
                                        <%= ds.toUpperCase() %>
                                    </span>
                                </td>
                                <td>
                                    <% if ("running".equalsIgnoreCase(ds)) { %>
                                        <% if (statsArray != null) { %>
                                            <div class="font-monospace small text-dark"><%= statsArray[0] %></div>
                                        <% } else { %>
                                            <span class="text-muted small">-</span>
                                        <% } %>
                                    <% } else if ("error".equalsIgnoreCase(ds)) { %>
                                        <span class="text-danger small"><i class="bi bi-exclamation-circle"></i> Error</span>
                                    <% } else { %>
                                        <span class="text-muted small">-</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if ("running".equalsIgnoreCase(ds)) { %>
                                        <% if (statsArray != null) { %>
                                            <div class="font-monospace small text-dark"><%= statsArray[1] %></div>
                                        <% } else { %>
                                            <span class="text-muted small">-</span>
                                        <% } %>
                                    <% } else if ("error".equalsIgnoreCase(ds)) { %>
                                        <% if (p.getErrorMessage() != null && !p.getErrorMessage().isEmpty()) { %>
                                            <div class="small text-muted text-truncate" style="max-width: 250px;" title="<%= p.getErrorMessage().replace("\"", "&quot;") %>">
                                                <%= p.getErrorMessage() %>
                                            </div>
                                        <% } else { %>
                                            <span class="text-muted small">-</span>
                                        <% } %>
                                    <% } else { %>
                                        <span class="text-muted small">-</span>
                                    <% } %>
                                </td>
                                <td class="text-end">
                                    <div class="d-flex justify-content-end gap-1">
                                        <% if ("running".equalsIgnoreCase(ds)) { %>
                                            <form action="<%= ctx %>/coordinator/docker" method="post" style="display:inline;"
                                                  class="docker-action-form" data-action="stop"
                                                  data-label="Stopping container..." data-icon="bi-stop-circle">
                                                <input type="hidden" name="projectId" value="<%= p.getId() %>"/>
                                                <input type="hidden" name="action" value="stop"/>
                                                <button type="submit" class="btn btn-sm btn-outline-warning" title="Stop Container">
                                                    <i class="bi bi-stop-fill"></i> Stop
                                                </button>
                                            </form>
                                        <% } else if ("stopped".equalsIgnoreCase(ds) || "exited".equalsIgnoreCase(ds) || "built".equalsIgnoreCase(ds) || "error".equalsIgnoreCase(ds)) { %>
                                            <form action="<%= ctx %>/coordinator/docker" method="post" style="display:inline;"
                                                  class="docker-action-form" data-action="start"
                                                  data-label="Starting container..." data-icon="bi-play-fill">
                                                <input type="hidden" name="projectId" value="<%= p.getId() %>"/>
                                                <input type="hidden" name="action" value="start"/>
                                                <button type="submit" class="btn btn-sm btn-outline-success" title="Start Container">
                                                    <i class="bi bi-play-fill"></i> Start
                                                </button>
                                            </form>
                                        <% } else { %>
                                            <button class="btn btn-sm btn-outline-secondary" disabled title="Not Built Yet">
                                                <i class="bi bi-play-fill"></i> Start
                                            </button>
                                        <% } %>

                                        <form id="rebuildForm_<%= p.getId() %>" action="<%= ctx %>/coordinator/docker" method="post" style="display:inline;"
                                              class="docker-action-form" data-action="rebuild"
                                              data-label="Rebuilding container..." data-icon="bi-arrow-clockwise">
                                            <input type="hidden" name="projectId" value="<%= p.getId() %>"/>
                                            <input type="hidden" name="action" value="rebuild"/>
                                            <button type="submit" class="btn btn-sm btn-outline-info" title="Rebuild Container">
                                                <i class="bi bi-arrow-clockwise"></i> Rebuild
                                            </button>
                                        </form>

                                        <button type="button" class="btn btn-sm btn-outline-danger" title="Remove Container" onclick="confirmRemove(<%= p.getId() %>, '<%= p.getTitle().replace("'", "\\'") %>')">
                                            <i class="bi bi-trash3"></i> Remove
                                        </button>

                                        <a href="<%= ctx %>/coordinator/project/<%= p.getId() %>" class="btn btn-sm btn-outline-secondary" title="Configure Project">
                                            <i class="bi bi-gear"></i>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </div>

    <!-- Live deployment log activity (Full Width below table) -->
    <div class="col-12">
        <div class="rt-card h-100">
            <div class="rt-card-header justify-content-between">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-activity text-success"></i>
                    <span>Recent System Activity</span>
                </div>
                <span class="badge bg-light text-secondary rounded-pill" id="log-count-badge">
                    <%= recentLogs != null ? recentLogs.size() : 0 %> entries
                </span>
            </div>

            <!-- Filter Bar -->
            <div class="px-3 pt-3 pb-2 border-bottom d-flex flex-wrap gap-2 align-items-center">
                <div class="input-group input-group-sm" style="max-width: 220px;">
                    <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                    <input type="text" id="log-search" class="form-control border-start-0 ps-0"
                           placeholder="Search project or user..." oninput="filterLogs()">
                </div>
                <select id="log-action-filter" class="form-select form-select-sm" style="max-width: 160px;" onchange="filterLogs()">
                    <option value="">All Actions</option>
                    <option value="BUILD">BUILD</option>
                    <option value="DEPLOY">DEPLOY</option>
                    <option value="STOP">STOP</option>
                    <option value="START">START</option>
                    <option value="REMOVE">REMOVE</option>
                    <option value="REBUILD">REBUILD</option>
                </select>
                <select id="log-status-filter" class="form-select form-select-sm" style="max-width: 130px;" onchange="filterLogs()">
                    <option value="">All Status</option>
                    <option value="success">Success</option>
                    <option value="failed">Failed</option>
                </select>
                <button class="btn btn-sm btn-light ms-auto" onclick="clearLogFilters()">
                    <i class="bi bi-x-circle me-1"></i>Clear
                </button>
            </div>

            <div class="card-body p-3">
                <% if (recentLogs == null || recentLogs.isEmpty()) { %>
                    <div class="p-5 text-center text-muted">
                        <i class="bi bi-list-task" style="font-size: 2rem;"></i>
                        <p class="mt-2 mb-0">No deployment actions recorded yet.</p>
                    </div>
                <% } else { %>
                    <div class="log-scroll-panel" id="log-scroll-panel">
                        <%
                            for (DeploymentLog log : recentLogs) {
                                String isSuccessClass = log.isSuccess() ? "success" : "failed";
                                String projectLabel = log.getProjectTitle() != null ? log.getProjectTitle() : "Project #" + log.getProjectId();
                                String triggeredBy = log.getPerformedByName() != null ? log.getPerformedByName() : "";
                        %>
                        <div class="log-item <%= isSuccessClass %>"
                             data-action="<%= log.getAction() != null ? log.getAction().name() : "" %>"
                             data-status="<%= isSuccessClass %>"
                             data-project="<%= projectLabel.toLowerCase() %>"
                             data-user="<%= triggeredBy.toLowerCase() %>">
                            <span class="log-dot"></span>
                            <div class="d-flex justify-content-between align-items-start">
                                <span class="badge bg-light text-dark font-monospace small"><%= log.getAction() %></span>
                                <span class="text-muted small" style="font-size: 11px;">
                                    <%= log.getPerformedAt().format(timeFormatter) %>
                                </span>
                            </div>
                            <div class="mt-1" style="font-size: 13px; font-weight: 500;">
                                <%= projectLabel %>
                            </div>
                            <div class="text-muted mt-1" style="font-size: 12px;">
                                Triggered by: <span class="fw-semibold text-dark"><%= triggeredBy %></span>
                            </div>
                            <% if (log.getDetail() != null && !log.getDetail().trim().isEmpty()) { %>
                                <div class="mt-2">
                                    <a class="text-decoration-none small d-inline-flex align-items-center gap-1"
                                       href="javascript:void(0)"
                                       onclick="toggleDetail(this)"
                                       style="font-size: 11px;">
                                        <i class="bi bi-caret-right-fill"></i> View Details
                                    </a>
                                    <pre class="rt-mono bg-light text-dark p-2 rounded mt-1 border overflow-x-auto d-none"
                                         style="font-size: 10px; max-height: 150px; line-height: 1.2;"><%= log.getDetail() %></pre>
                                </div>
                            <% } %>
                        </div>
                        <% } %>
                    </div>
                    <div id="log-no-results" class="p-4 text-center text-muted d-none">
                        <i class="bi bi-funnel" style="font-size: 1.5rem;"></i>
                        <p class="mt-2 mb-0 small">No entries match your filters.</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Raw Engine View: Containers -->
    <div class="col-12 mt-4">
        <div class="rt-card border-0 shadow-sm">
            <div class="rt-card-header bg-dark text-white rounded-top d-flex align-items-center">
                <i class="bi bi-terminal me-2"></i> <span class="fw-semibold">All Docker Containers (Raw Engine State)</span>
            </div>
            <div class="table-responsive">
                <table class="table table-sm table-hover align-middle mb-0" style="font-size: 0.8rem;">
                    <thead class="table-light">
                        <tr>
                            <th>Container ID</th>
                            <th>Image</th>
                            <th>Command</th>
                            <th>Created</th>
                            <th>Status</th>
                            <th>Ports</th>
                            <th>Names</th>
                        </tr>
                    </thead>
                    <tbody class="font-monospace">
                        <% 
                            List<DockerService.RawContainer> rawContainers = (List<DockerService.RawContainer>) request.getAttribute("rawContainers");
                            if (rawContainers == null || rawContainers.isEmpty()) { 
                        %>
                            <tr><td colspan="7" class="text-center text-muted p-4">No containers found on host.</td></tr>
                        <% } else { for (DockerService.RawContainer rc : rawContainers) { %>
                            <tr>
                                <td class="text-primary"><%= rc.id %></td>
                                <td><%= rc.image %></td>
                                <td class="text-truncate text-muted" style="max-width: 150px;" title="<%= rc.command.replace("\"", "&quot;") %>"><%= rc.command %></td>
                                <td class="text-muted"><%= rc.created %></td>
                                <td>
                                    <% if (rc.status.toLowerCase().contains("up")) { %>
                                        <span class="text-success"><i class="bi bi-circle-fill" style="font-size: 6px; vertical-align: middle;"></i> <%= rc.status %></span>
                                    <% } else if (rc.status.toLowerCase().contains("exited")) { %>
                                        <span class="text-warning"><i class="bi bi-circle-fill" style="font-size: 6px; vertical-align: middle;"></i> <%= rc.status %></span>
                                    <% } else { %>
                                        <span class="text-secondary"><%= rc.status %></span>
                                    <% } %>
                                </td>
                                <td><%= rc.ports %></td>
                                <td class="fw-bold"><%= rc.names %></td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Raw Engine View: Images -->
    <div class="col-12 mt-4">
        <div class="rt-card border-0 shadow-sm">
            <div class="rt-card-header bg-dark text-white rounded-top d-flex align-items-center">
                <i class="bi bi-disc me-2"></i> <span class="fw-semibold">All Docker Images (Raw Engine State)</span>
            </div>
            <div class="table-responsive">
                <table class="table table-sm table-hover align-middle mb-0" style="font-size: 0.8rem;">
                    <thead class="table-light">
                        <tr>
                            <th>Image ID</th>
                            <th>Repository</th>
                            <th>Tag</th>
                            <th>Created At</th>
                            <th>Size</th>
                        </tr>
                    </thead>
                    <tbody class="font-monospace">
                        <% 
                            List<DockerService.RawImage> rawImages = (List<DockerService.RawImage>) request.getAttribute("rawImages");
                            if (rawImages == null || rawImages.isEmpty()) { 
                        %>
                            <tr><td colspan="5" class="text-center text-muted p-4">No images found on host.</td></tr>
                        <% } else { for (DockerService.RawImage ri : rawImages) { %>
                            <tr>
                                <td class="text-primary"><%= ri.id %></td>
                                <td class="fw-bold"><%= ri.repo %></td>
                                <td><%= ri.tag %></td>
                                <td class="text-muted"><%= ri.created %></td>
                                <td><span class="badge bg-light text-dark border"><%= ri.size %></span></td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</div>

<!-- Remove Confirmation Modal -->
<div class="modal fade" id="removeConfirmModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title text-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i>Remove Project Container?</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to stop and remove the Docker container for project <strong id="removeProjectTitle"></strong>?</p>
                <p class="text-danger small mb-0"><i class="bi bi-info-circle me-1"></i> This will also remove the underlying Docker image. The student will have to rebuild the project to deploy it again.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light border btn-sm" data-bs-dismiss="modal">Cancel</button>
                <form id="removeProjectForm" action="<%= ctx %>/coordinator/docker" method="post" style="display:inline;"
                                                      class="docker-action-form" data-action="remove"
                                                      data-label="Removing container &amp; image..." data-icon="bi-trash">
                    <input type="hidden" name="projectId" id="removeProjectId" value=""/>
                    <input type="hidden" name="action" value="remove"/>
                    <button type="submit" class="btn btn-danger btn-sm">Confirm Removal</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    function toggleDetail(btn) {
        const pre = btn.nextElementSibling;
        const icon = btn.querySelector('i');
        if (pre.classList.contains('d-none')) {
            pre.classList.remove('d-none');
            icon.className = 'bi bi-caret-down-fill';
        } else {
            pre.classList.add('d-none');
            icon.className = 'bi bi-caret-right-fill';
        }
    }

    function filterLogs() {
        const search = (document.getElementById('log-search').value || '').toLowerCase().trim();
        const action = (document.getElementById('log-action-filter').value || '').toUpperCase();
        const status = (document.getElementById('log-status-filter').value || '');

        const items = document.querySelectorAll('#log-scroll-panel .log-item');
        let visible = 0;
        items.forEach(function(item) {
            const itemAction  = (item.dataset.action  || '').toUpperCase();
            const itemStatus  = (item.dataset.status  || '');
            const itemProject = (item.dataset.project || '');
            const itemUser    = (item.dataset.user    || '');

            const matchSearch = !search || itemProject.includes(search) || itemUser.includes(search);
            const matchAction = !action || itemAction === action;
            const matchStatus = !status || itemStatus === status;

            if (matchSearch && matchAction && matchStatus) {
                item.style.display = '';
                visible++;
            } else {
                item.style.display = 'none';
            }
        });

        const badge = document.getElementById('log-count-badge');
        if (badge) badge.textContent = visible + ' entries';

        const noResults = document.getElementById('log-no-results');
        if (noResults) noResults.classList.toggle('d-none', visible > 0);
    }

    function clearLogFilters() {
        document.getElementById('log-search').value = '';
        document.getElementById('log-action-filter').value = '';
        document.getElementById('log-status-filter').value = '';
        filterLogs();
    }

    let removeModalInstance = null;
    function confirmRemove(projectId, projectTitle) {
        document.getElementById('removeProjectId').value = projectId;
        document.getElementById('removeProjectTitle').innerText = projectTitle;
        if (!removeModalInstance) {
            removeModalInstance = new bootstrap.Modal(document.getElementById('removeConfirmModal'));
        }
        removeModalInstance.show();
    }
</script>

<!-- Docker Action Loading Overlay -->
<div id="dockerOverlay" style="
    display:none;position:fixed;inset:0;z-index:9999;
    background:rgba(10,12,18,.82);backdrop-filter:blur(4px);
    align-items:center;justify-content:center;flex-direction:column;gap:1.25rem;">

    <div style="text-align:center;">
        <div id="dockerOverlayIcon"
             style="font-size:2.6rem;color:#63b3ed;margin-bottom:.6rem;
                    animation:dockerSpin 1.1s linear infinite;display:inline-block;">
            <i class="bi bi-arrow-repeat"></i>
        </div>
        <div id="dockerOverlayLabel"
             style="color:#e2e8f0;font-size:1.05rem;font-weight:600;
                    letter-spacing:.01em;margin-bottom:.25rem;">
            Processing...
        </div>
        <div style="color:#718096;font-size:.82rem;">Please wait, do not close this page.</div>
    </div>

    <!-- Progress bar -->
    <div style="width:min(360px,88vw);">
        <div style="background:#2d3748;border-radius:999px;height:6px;overflow:hidden;">
            <div id="dockerProgressBar"
                 style="height:100%;width:0%;border-radius:999px;
                        background:linear-gradient(90deg,#4299e1,#63b3ed,#90cdf4);
                        transition:width .35s ease;"></div>
        </div>
        <div style="display:flex;justify-content:space-between;
                    margin-top:.4rem;font-size:.72rem;color:#4a5568;">
            <span id="dockerProgressPct">0%</span>
            <span id="dockerProgressStep">Initializing...</span>
        </div>
    </div>
</div>

<style>
@keyframes dockerSpin {
    from { transform: rotate(0deg); }
    to   { transform: rotate(360deg); }
}
/* Stop action uses a fade pulse instead of spin */
.docker-pulse { animation: dockerPulse 1s ease-in-out infinite !important; }
@keyframes dockerPulse {
    0%,100% { opacity:1; transform:scale(1); }
    50%      { opacity:.55; transform:scale(.92); }
}
</style>

<script>
(function () {
    /* ── Progress sequences per action ── */
    var sequences = {
        start:    [
            { pct: 20, step: 'Locating image...' },
            { pct: 55, step: 'Allocating port...' },
            { pct: 88, step: 'Starting container...' }
        ],
        stop:    [
            { pct: 20, step: 'Sending SIGTERM...' },
            { pct: 55, step: 'Draining connections...' },
            { pct: 88, step: 'Stopping container...' }
        ],
        remove:  [
            { pct: 25, step: 'Stopping container...' },
            { pct: 60, step: 'Removing container...' },
            { pct: 88, step: 'Removing image...' }
        ],
        rebuild: [
            { pct: 15, step: 'Stopping old container...' },
            { pct: 35, step: 'Removing old image...' },
            { pct: 65, step: 'Building new image...' },
            { pct: 88, step: 'Starting new container...' }
        ]
    };

    var overlay   = document.getElementById('dockerOverlay');
    var bar       = document.getElementById('dockerProgressBar');
    var pctLabel  = document.getElementById('dockerProgressPct');
    var stepLabel = document.getElementById('dockerProgressStep');
    var iconEl    = document.getElementById('dockerOverlayIcon');
    var mainLabel = document.getElementById('dockerOverlayLabel');

    function showOverlay(action, label, iconClass) {
        /* Icon */
        iconEl.innerHTML = '<i class="bi ' + iconClass + '"></i>';
        iconEl.classList.remove('docker-pulse');
        if (action === 'stop') iconEl.classList.add('docker-pulse');

        mainLabel.textContent = label;
        bar.style.width       = '0%';
        pctLabel.textContent  = '0%';
        stepLabel.textContent = 'Initializing...';

        overlay.style.display = 'flex';

        /* Animate progress steps */
        var steps = sequences[action] || [];
        var delay = 0;
        steps.forEach(function (s) {
            delay += (action === 'stop' ? 420 : action === 'remove' ? 500 : 600);
            (function (d, pct, text) {
                setTimeout(function () {
                    bar.style.width      = pct + '%';
                    pctLabel.textContent = pct + '%';
                    stepLabel.textContent = text;
                }, d);
            })(delay, s.pct, s.step);
        });
    }

    /* ── Wire up each action form ── */
    document.querySelectorAll('.docker-action-form').forEach(function (form) {
        form.addEventListener('submit', function (e) {
            var action = form.dataset.action;

            if (action === 'remove' && removeModalInstance) {
                removeModalInstance.hide();
            }

            showOverlay(action, form.dataset.label, form.dataset.icon);
        });
    });

})();
</script>

<jsp:include page="/views/common/footer.jsp"/>

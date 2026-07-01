<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.*,java.util.List" %>
<%!
    public String formatDuration(long seconds) {
        long hours = seconds / 3600;
        long minutes = (seconds % 3600) / 60;
        return hours + "h " + minutes + "m";
    }
%>
<%
    request.setAttribute("pageTitle", "Project Detail");
    Project project = (Project) request.getAttribute("project");
    List<Milestone> milestones = (List<Milestone>) request.getAttribute("milestones");
    List<Feedback> feedbacks = (List<Feedback>) request.getAttribute("feedbacks");
    List<PitaAssignment> pitaAssignments = (List<PitaAssignment>) request.getAttribute("pitaAssignments");
    List<DeploymentLog> logs = (List<DeploymentLog>) request.getAttribute("deployLogs");
    String stats = (String) request.getAttribute("stats");
    Object durationObj = request.getAttribute("durationToday");
    long durationToday = (durationObj instanceof Long) ? (Long) durationObj : 0L;
    String ctx = request.getContextPath();
    String formError = (String) request.getAttribute("formError");
    String success = request.getParameter("success");
    String ds = project.getDockerStatus() != null ? project.getDockerStatus() : "none";
    boolean running = project.isRunning();
%>
                        <jsp:include page="/views/common/header.jsp" />

                        <!-- Breadcrumb -->
                        <nav style="font-size:.82rem;margin-bottom:1.25rem;">
                            <a href="<%= ctx %>/student/dashboard"
                                style="color:var(--rt-primary);text-decoration:none;">
                                <i class="bi bi-house me-1"></i>Dashboard
                            </a>
                            <span class="mx-1" style="color:var(--rt-muted);">/</span>
                            <span style="color:var(--rt-muted);">
                                <%= project.getTitle() %>
                            </span>
                        </nav>

                        <!-- Flash -->
                        <% if (formError !=null) { %>
                            <div class="rt-alert rt-alert-error rt-flash mb-3">
                                <i class="bi bi-exclamation-circle-fill"></i>
                                <%= formError %>
                            </div>
                            <% } %>
                                <% if (success != null) { %>
                                    <div class="rt-alert rt-alert-success rt-flash mb-3">
                                        <i class="bi bi-check-circle-fill"></i>
                                        <% if ("submitted".equals(success)) { %>Milestone submitted for review.
                                        <% } else if ("started".equals(success)) { %>Action completed (Milestone/Container started).
                                        <% } else if ("built".equals(success)) { %>Project built successfully.
                                        <% } else if ("deployed".equals(success)) { %>&#x1F680; Project deployed and running! Your app is now live.
                                        <% } else if ("stopped".equals(success)) { %>Container stopped.
                                        <% } else if ("rebuilt".equals(success)) { %>Project rebuilt and started.
                                        <% } else if ("removed".equals(success)) { %>Container removed.
                                        <% } else { %>Action completed.<% } %>
                                    </div>
                                    <% } %>

                                        <!-- Project header -->
                                        <div class="rt-card p-3 mb-3">
                                            <div class="d-flex flex-wrap gap-2 align-items-center mb-2">
                                                <h5 class="fw-bold mb-0">
                                                    <%= project.getTitle() %>
                                                </h5>
                                                <span
                                                    class="badge rt-status-<%= project.getStatus().name().toLowerCase() %>">
                                                    <%= project.getStatus() %>
                                                </span>
                                                <span class="small rt-docker-<%= ds %>">
                                                    <i class="bi bi-circle-fill me-1" style="font-size:7px;"></i>
                                                    <%= ds %>
                                                </span>
                                                <% if (project.isRunning() && project.getPreviewUrl() !=null) { %>
                                                    <div class="d-flex flex-column align-items-end ms-auto gap-2">
                                                        <a href="http://<%= request.getServerName() %>:<%= project.getContainerPort() %>" target="_blank"
                                                            class="btn btn-sm btn-outline-success w-100">
                                                            <i class="bi bi-box-arrow-up-right me-1"></i>Open App
                                                        </a>
                                                        <div class="dropdown w-100">
                                                            <button class="btn btn-sm btn-light border w-100 dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                                <i class="bi bi-share me-1"></i>Share
                                                            </button>
                                                            <div class="dropdown-menu dropdown-menu-end p-3 text-center shadow-sm" style="min-width: 200px;">
                                                                <h6 class="dropdown-header px-0 text-dark fw-bold">Scan to open on mobile</h6>
                                                                <img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=http://<%= request.getServerName() %>:<%= project.getContainerPort() %>" alt="QR Code" class="img-fluid border rounded mb-3" width="150" height="150">
                                                                <button class="btn btn-sm btn-primary w-100 mb-2" onclick="navigator.clipboard.writeText('http://<%= request.getServerName() %>:<%= project.getContainerPort() %>'); alert('Link copied to clipboard!');">
                                                                    <i class="bi bi-link-45deg me-1"></i>Copy Link
                                                                </button>
                                                                <button class="btn btn-sm btn-outline-primary w-100" onclick="shareQRCode('http://<%= request.getServerName() %>:<%= project.getContainerPort() %>')">
                                                                    <i class="bi bi-share me-1"></i>Share QR Code
                                                                </button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <script>
                                            async function shareQRCode(url) {
                                                try {
                                                    const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=\${encodeURIComponent(url)}`;
                                                    const response = await fetch(qrUrl);
                                                    const blob = await response.blob();
                                                    const file = new File([blob], 'qrcode.png', { type: blob.type });
                                                    
                                                    if (navigator.canShare && navigator.canShare({ files: [file] })) {
                                                        await navigator.share({
                                                            files: [file],
                                                            title: 'Project QR Code',
                                                            text: 'Scan this QR code to open the project.'
                                                        });
                                                    } else {
                                                        const a = document.createElement('a');
                                                        a.href = URL.createObjectURL(blob);
                                                        a.download = 'qrcode.png';
                                                        a.click();
                                                        URL.revokeObjectURL(a.href);
                                                    }
                                                } catch (err) {
                                                    console.error('Error sharing:', err);
                                                    alert('Sharing failed. Your browser might not support this feature.');
                                                }
                                            }
                                            </script>
                                            <% if (project.getDescription() != null && !project.getDescription().trim().isEmpty()) { 
                                                String descHtml = project.getDescription().trim()
                                                    .replace("\n", "<br/>")
                                                    .replaceAll("\\*\\*(.*?)\\*\\*", "<strong>$1</strong>");
                                            %>
                                                <div class="p-3 mb-4" style="background-color: var(--rt-bg); border-left: 4px solid var(--rt-primary); border-radius: 6px; max-width: 1000px;">
                                                    <div class="fw-semibold mb-2 text-uppercase text-muted" style="font-size: .7rem; letter-spacing: .05em;">Project Description</div>
                                                    <div class="text-secondary" style="font-size: .83rem; line-height: 1.55; color: #334155 !important;">
                                                        <%= descHtml %>
                                                    </div>
                                                </div>
                                            <% } %>
                                            <div class="row g-3" style="font-size:.83rem;color:var(--rt-muted);">
                                                <div class="col-sm-6 col-md-3">
                                                    <div class="fw-semibold text-dark mb-0">Repository</div>
                                                    <a href="<%= project.getRepoUrl() %>" target="_blank"
                                                        class="text-truncate d-block" style="max-width:220px;">
                                                        <i class="bi bi-github me-1"></i>
                                                        <%= project.getRepoUrl() %>
                                                    </a>
                                                </div>
                                                <div class="col-sm-6 col-md-3">
                                                    <div class="fw-semibold text-dark">Supervisor</div>
                                                    <% if (project.getSupervisorName() !=null) { %>
                                                        <i class="bi bi-person-check me-1"></i>
                                                        <%= project.getSupervisorName() %>
                                                            <% } else { %>
                                                                <span class="text-danger">Unassigned</span>
                                                                <% } %>
                                                </div>
                                                <div class="col-sm-6 col-md-3">
                                                    <div class="fw-semibold text-dark">Branch</div>
                                                    <span class="badge bg-light text-dark border"
                                                        style="font-family:'DM Mono',monospace;font-size:.75rem;">
                                                        <%= project.getBranch() %>
                                                    </span>
                                                </div>
                                                <div class="col-sm-6 col-md-3">
                                                    <div class="fw-semibold text-dark">Overall Grade</div>
                                                    <% if (project.getOverallGrade() !=null) { %>
                                                        <strong style="color:var(--rt-primary);">
                                                            <%= String.format("%.1f", project.getOverallGrade()) %>%
                                                        </strong>
                                                        <% } else { %>
                                                            <span class="text-muted">—</span>
                                                            <% } %>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="row g-3">
                                            <!-- Left: Docker & Milestones -->
                                            <div class="col-lg-7">
                                                <!-- Container Control -->
                                                <div class="rt-card mb-3" style="border-color:#2d3748;background:#1a202c;">
                                                    <div class="rt-card-header" style="color:#e2e8f0;border-color:#2d3748;">
                                                        <i class="bi bi-box-seam text-info"></i>
                                                        <span style="color:#e2e8f0;">Container Control</span>
                                                        <span class="ms-2 small rt-docker-<%= ds %>" style="font-weight:600;"><%= ds %></span>
                                                    </div>
                                                    <div class="p-3">
                                                        <div class="d-flex flex-wrap align-items-center justify-content-between mb-3">
                                                            <div style="color:#a0aec0;font-size:.82rem;">
                                                                Daily Usage: 
                                                                <strong id="liveDailyUsage" style="color:#e2e8f0;"><%= formatDuration(durationToday) %> / <%= formatDuration(project.getRunningLimitSeconds()) %></strong>
                                                            </div>
                                                            <% if (durationToday >= project.getRunningLimitSeconds()) { %>
                                                                <span class="badge bg-danger text-white" style="font-size:.7rem;">Limit Reached</span>
                                                            <% } %>
                                                        </div>

                                                        <% if (stats != null) { %>
                                                        <div class="rounded-2 px-3 py-2 mb-3 rt-mono"
                                                             style="background:#2d3748;color:#68d391;font-size:.8rem;">
                                                            <i class="bi bi-graph-up me-1"></i><%= stats %>
                                                        </div>
                                                        <% } %>

                                                        <!-- Action buttons -->
                                                        <div class="d-flex flex-wrap gap-2" id="dockerActionForms">
                                                            <form method="post" action="<%= ctx %>/student/project/<%= project.getId() %>"
                                                                  class="docker-action-form" data-action="deploy"
                                                                  data-label="Deploying container..." data-icon="bi-play-circle">
                                                                <input type="hidden" name="action" value="deploy"/>
                                                                <button type="submit" class="btn btn-success btn-sm" <%= running ? "disabled" : "" %> <%= durationToday >= project.getRunningLimitSeconds() ? "disabled" : "" %>>
                                                                    <i class="bi bi-rocket-takeoff me-1"></i>Deploy &amp; Start
                                                                </button>
                                                            </form>
                                                            <form method="post" action="<%= ctx %>/student/project/<%= project.getId() %>"
                                                                  class="docker-action-form" data-action="start"
                                                                  data-label="Starting container..." data-icon="bi-play-fill">
                                                                <input type="hidden" name="action" value="start"/>
                                                                <button type="submit" class="btn btn-primary btn-sm" <%= (running || "none".equals(ds)) ? "disabled" : "" %> <%= durationToday >= project.getRunningLimitSeconds() ? "disabled" : "" %>>
                                                                    <i class="bi bi-play-fill me-1"></i>Start
                                                                </button>
                                                            </form>
                                                            <form method="post" action="<%= ctx %>/student/project/<%= project.getId() %>"
                                                                  class="docker-action-form" data-action="stop"
                                                                  data-label="Stopping container..." data-icon="bi-stop-circle">
                                                                <input type="hidden" name="action" value="stop"/>
                                                                <button type="submit" class="btn btn-warning btn-sm" <%= !running ? "disabled" : "" %>>
                                                                    <i class="bi bi-stop-circle me-1"></i>Stop
                                                                </button>
                                                            </form>
                                                            <form method="post" action="<%= ctx %>/student/project/<%= project.getId() %>"
                                                                  class="docker-action-form" data-action="rebuild"
                                                                  data-label="Rebuilding &amp; restarting..." data-icon="bi-arrow-repeat">
                                                                <input type="hidden" name="action" value="rebuild"/>
                                                                <button type="submit" class="btn btn-info btn-sm text-white" <%= durationToday >= project.getRunningLimitSeconds() ? "disabled" : "" %>>
                                                                    <i class="bi bi-arrow-repeat me-1"></i>Rebuild
                                                                </button>
                                                            </form>
                                                            <form method="post" action="<%= ctx %>/student/project/<%= project.getId() %>"
                                                                  class="docker-action-form" data-action="remove"
                                                                  data-label="Removing container &amp; image..." data-icon="bi-trash">
                                                                <input type="hidden" name="action" value="remove"/>
                                                                <button type="submit" class="btn btn-danger btn-sm">
                                                                    <i class="bi bi-trash me-1"></i>Remove
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Deployment Logs -->
                                                <div class="rt-card mb-3">
                                                    <div class="rt-card-header">
                                                        <i class="bi bi-terminal text-secondary"></i> Deployment Logs
                                                        <span class="badge bg-secondary ms-auto" style="font-size:.65rem;">Live</span>
                                                    </div>
                                                    <% if (logs == null || logs.isEmpty()) { %>
                                                    <div class="p-3 text-muted" style="font-size:.83rem;">No deployment logs yet.</div>
                                                    <% } else { %>
                                                    <div class="p-3">
                                                    <% for (DeploymentLog log : logs) { %>
                                                    <div class="d-flex align-items-center gap-2 mb-1" style="font-size:.8rem;">
                                                        <span class="badge
                                                            <%= "success".equals(log.getOutcome()) ? "bg-success" : "bg-danger" %>"
                                                            style="font-size:.65rem;font-family:'DM Mono',monospace;min-width:58px;">
                                                            <%= log.getAction() %>
                                                        </span>
                                                        <span style="color:var(--rt-muted);">by <%= log.getPerformedByName() %></span>
                                                        <span class="ms-auto text-muted rt-mono">
                                                            <%= log.getPerformedAt() != null
                                                                ? log.getPerformedAt().toString().replace("T"," ") : "" %>
                                                        </span>
                                                    </div>
                                                    <% } %>
                                                    </div>
                                                    <% } %>
                                                </div>
                                                <div class="rt-card">
                                                    <div class="rt-card-header">
                                                        <i class="bi bi-flag text-primary"></i> Milestones
                                                    </div>
                                                    <% if (milestones==null || milestones.isEmpty()) { %>
                                                        <div class="p-4 text-center text-muted">No milestones defined
                                                            yet.</div>
                                                        <% } else { %>
                                                            <div class="p-3 d-flex flex-column gap-3">
                                                                <% for (Milestone m : milestones) { String
                                                                    mStatus=m.getStatus().name().toLowerCase(); String
                                                                    mColor="secondary" ; if
                                                                    (m.getStatus()==Milestone.MilestoneStatus.APPROVED)
                                                                    mColor="success" ; else if
                                                                    (m.getStatus()==Milestone.MilestoneStatus.SUBMITTED)
                                                                    mColor="primary" ; else if
                                                                    (m.getStatus()==Milestone.MilestoneStatus.REJECTED)
                                                                    mColor="danger" ; else if
                                                                    (m.getStatus()==Milestone.MilestoneStatus.IN_PROGRESS)
                                                                    mColor="warning" ; %>
                                                                    <div class="border rounded-3 p-3 <%= m.isOverdue() ? "border-danger" : "" %>">
                                                                        <div
                                                                            class="d-flex flex-wrap justify-content-between align-items-start gap-2 mb-2">
                                                                            <div>
                                                                                <span class="fw-semibold">M<%=
                                                                                        m.getMilestoneNo() %>: <%=
                                                                                            m.getTitle() %></span>
                                                                                <% if (m.isOverdue()) { %>
                                                                                    <span class="badge bg-danger ms-2"
                                                                                        style="font-size:.65rem;">OVERDUE</span>
                                                                                    <% } %>
                                                                            </div>
                                                                            <span class="badge bg-<%= mColor %> bg-opacity-10
                                 text-<%= mColor %> border border-<%= mColor %>" style="font-size:.7rem;">
                                                                                <%= m.getStatus() %>
                                                                            </span>
                                                                        </div>
                                                                        <div class="d-flex flex-wrap gap-3 mb-2"
                                                                            style="font-size:.8rem;color:var(--rt-muted);">
                                                                            <span><i class="bi bi-calendar3 me-1"></i>
                                                                                Due: <%= m.getDueDate() !=null ?
                                                                                    m.getDueDate().toString() : "—" %>
                                                                            </span>
                                                                            <span><i
                                                                                    class="bi bi-percent me-1"></i>Weight:
                                                                                <%= m.getWeight() %>%</span>
                                                                            <% if (m.getGrade() !=null) { %>
                                                                                <span class="text-success fw-semibold">
                                                                                    <i
                                                                                        class="bi bi-star-fill me-1"></i>Grade:
                                                                                    <%= String.format("%.1f",
                                                                                        m.getGrade()) %>
                                                                                </span>
                                                                                <% } %>
                                                                        </div>

                                                                        <% if (m.getSupervisorNote() !=null &&
                                                                            !m.getSupervisorNote().isEmpty()) { %>
                                                                            <div class="rounded-2 p-2 mb-2"
                                                                                style="background:#f8faff;font-size:.8rem;border:1px solid #dbeafe;">
                                                                                <i
                                                                                    class="bi bi-chat-left-text me-1 text-primary"></i>
                                                                                <strong>Supervisor:</strong>
                                                                                <%= m.getSupervisorNote() %>
                                                                            </div>
                                                                            <% } %>

                                                                                <!-- Actions -->
                                                                                <% if
                                                                                    (m.getStatus()==Milestone.MilestoneStatus.NOT_STARTED)
                                                                                    { %>
                                                                                    <form method="post"
                                                                                        action="<%= ctx %>/student/project/<%= project.getId() %>"
                                                                                        class="d-inline">
                                                                                        <input type="hidden"
                                                                                            name="action"
                                                                                            value="start-milestone" />
                                                                                        <input type="hidden"
                                                                                            name="milestoneId"
                                                                                            value="<%= m.getId() %>" />
                                                                                        <button type="submit"
                                                                                            class="btn btn-sm btn-outline-warning">
                                                                                            <i
                                                                                                class="bi bi-play me-1"></i>Start
                                                                                            Working
                                                                                        </button>
                                                                                    </form>
                                                                                    <% } else if
                                                                                        (m.getStatus()==Milestone.MilestoneStatus.IN_PROGRESS
                                                                                        ||
                                                                                        m.getStatus()==Milestone.MilestoneStatus.REJECTED)
                                                                                        { %>
                                                                                        <button
                                                                                            class="btn btn-sm btn-outline-primary"
                                                                                            data-bs-toggle="modal"
                                                                                            data-bs-target="#submitMilestoneModal"
                                                                                            data-milestone-id="<%= m.getId() %>"
                                                                                            data-milestone-title="<%= m.getTitle() %>">
                                                                                            <i
                                                                                                class="bi bi-send me-1"></i>Submit
                                                                                            for Review
                                                                                        </button>
                                                                                        <% } %>
                                                                    </div>
                                                                    <% } %>
                                                            </div>
                                                            <% } %>
                                                </div>
                                            </div>

                                            <!-- Right: Feedback -->
                                            <div class="col-lg-5">
                                                 <!-- PITA Evaluations -->
                                                 <div class="rt-card mb-3">
                                                     <div class="rt-card-header">
                                                         <i class="bi bi-calculator text-info"></i> PITA Evaluations
                                                         <% if (pitaAssignments != null && !pitaAssignments.isEmpty()) { %>
                                                             <span class="badge bg-info text-dark ms-auto" style="font-size:.68rem;">
                                                                 <%= pitaAssignments.size() %>
                                                             </span>
                                                         <% } %>
                                                     </div>
                                                     <% if (pitaAssignments == null || pitaAssignments.isEmpty()) { %>
                                                         <div class="p-4 text-center text-muted" style="font-size:.85rem;">
                                                             No PITA evaluations submitted yet.
                                                         </div>
                                                     <% } else { %>
                                                         <div class="p-3 d-flex flex-column gap-3" style="max-height:420px;overflow-y:auto;">
                                                             <% for (PitaAssignment pa : pitaAssignments) { %>
                                                                 <div class="rounded-3 p-3 border" style="background:#f8fafc; border-color:var(--rt-border) !important;">
                                                                     <div class="d-flex justify-content-between align-items-center mb-2">
                                                                         <span class="badge bg-primary bg-opacity-10 text-primary border border-primary px-2 py-1" style="font-size:.72rem;">
                                                                             <%= "PITA1".equals(pa.getStage()) ? "PITA-01 Technical Assessment" : "PITA-02 Staging Checklist" %>
                                                                         </span>
                                                                         <% if (pa.getGrade() != null) { %>
                                                                             <strong style="color:var(--rt-success); font-size: .95rem;">
                                                                                 Score: <%= String.format("%.1f", pa.getGrade()) %>/20
                                                                             </strong>
                                                                         <% } else { %>
                                                                             <span class="text-warning small"><i class="bi bi-clock me-1"></i>Pending Evaluation</span>
                                                                         <% } %>
                                                                     </div>
                                                                     <div class="mb-2" style="font-size:.8rem;color:var(--rt-muted);">
                                                                         <i class="bi bi-person-fill text-muted me-1"></i>Evaluator: <strong><%= pa.getEvaluatorName() %></strong>
                                                                     </div>
                                                                     <% if (pa.getFeedback() != null && !pa.getFeedback().trim().isEmpty()) { %>
                                                                         <div class="p-2 rounded mt-2 border-start border-3" style="background:var(--rt-bg); font-size:.83rem; border-left-color: var(--rt-primary) !important;">
                                                                             <div class="fw-semibold text-muted mb-1" style="font-size:.7rem; text-transform:uppercase;">Feedback</div>
                                                                             <div class="text-secondary"><%= pa.getFeedback().replace("\n", "<br/>") %></div>
                                                                         </div>
                                                                     <% } %>
                                                                     <% if (pa.getEvaluatedAt() != null) { %>
                                                                         <div class="text-muted mt-2 text-end" style="font-size:.7rem;">
                                                                             Evaluated on: <%= pa.getEvaluatedAt().toLocalDate() %>
                                                                         </div>
                                                                     <% } %>
                                                                 </div>
                                                             <% } %>
                                                         </div>
                                                     <% } %>
                                                 </div>

                                                <div class="rt-card">
                                                    <div class="rt-card-header">
                                                        <i class="bi bi-chat-dots text-warning"></i> Feedback
                                                        <% if (feedbacks !=null && !feedbacks.isEmpty()) { %>
                                                            <span class="badge bg-warning text-dark ms-auto"
                                                                style="font-size:.68rem;">
                                                                <%= feedbacks.size() %>
                                                            </span>
                                                            <% } %>
                                                    </div>
                                                    <% if (feedbacks==null || feedbacks.isEmpty()) { %>
                                                        <div class="p-4 text-center text-muted"
                                                            style="font-size:.85rem;">
                                                            No feedback yet.
                                                        </div>
                                                        <% } else { %>
                                                            <div class="p-3 d-flex flex-column gap-2"
                                                                style="max-height:420px;overflow-y:auto;">
                                                                <% for (Feedback f : feedbacks) { %>
                                                                    <div class="rounded-3 p-2 border"
                                                                        style="background:<%= f.isUnread() ? " #fffbeb"
                                                                        : "#f9fafb" %>;
                                                                        border-color:<%= f.isUnread() ? "#fde68a"
                                                                            : "var(--rt-border)" %> !important;">
                                                                            <div
                                                                                class="d-flex justify-content-between align-items-center mb-1">
                                                                                <span class="fw-semibold"
                                                                                    style="font-size:.8rem;">
                                                                                    <i
                                                                                        class="bi bi-person-fill me-1 text-muted"></i>
                                                                                    <%= f.getAuthorName() %>
                                                                                </span>
                                                                                <span
                                                                                    style="font-size:.7rem;color:var(--rt-muted);">
                                                                                    <%= f.getType().name().replace("_"," ") %>
                            <% if (f.isUnread()) { %>
                            <span class=" badge bg-warning text-dark ms-1" style="font-size:.6rem;">NEW
                                                                                </span>
                                                                                <% } %>
                                                                                    </span>
                                                                            </div>
                                                                            <p class="mb-1" style="font-size:.83rem;">
                                                                                <%= f.getContent() %>
                                                                            </p>
                                                                            <div
                                                                                style="font-size:.72rem;color:var(--rt-muted);">
                                                                                <%= f.getCreatedAt() !=null ?
                                                                                    f.getCreatedAt().toLocalDate().toString()
                                                                                    : "" %>
                                                                            </div>
                                                                    </div>
                                                                    <% } %>
                                                            </div>
                                                            <% } %>
                                                </div>

                                                <!-- Live log stream -->
                                                <% if (running) { %>
                                                <div class="rt-card mt-3">
                                                    <div class="rt-card-header">
                                                        <i class="bi bi-terminal-fill text-success"></i> Live Container Output
                                                        <span class="badge bg-success ms-auto" style="font-size:.62rem;">streaming</span>
                                                    </div>
                                                    <div class="p-2">
                                                        <div id="liveLog" class="rt-mono rounded-2 p-2"
                                                             style="background:#1a202c;color:#68d391;height:220px;
                                                                    overflow-y:auto;font-size:.75rem;white-space:pre-wrap;"></div>
                                                    </div>
                                                </div>
                                                <script>
                                                (function () {
                                                    const log  = document.getElementById('liveLog');
                                                    const es   = new EventSource('<%= ctx %>/api/logs/stream/<%= project.getId() %>');
                                                    es.onmessage = e => {
                                                        log.textContent += e.data + '\n';
                                                        log.scrollTop = log.scrollHeight;
                                                    };
                                                    es.onerror = () => {
                                                        log.textContent += '\n[stream closed]\n';
                                                        es.close();
                                                    };
                                                })();
                                                </script>
                                                <% } %>
                                            </div>
                                        </div>

                                        <!-- Submit Milestone Modal -->
                                        <div class="modal fade" id="submitMilestoneModal" tabindex="-1">
                                            <div class="modal-dialog">
                                                <div class="modal-content" style="border-radius:12px;">
                                                    <div class="modal-header border-0">
                                                        <h5 class="modal-title fw-bold">Submit Milestone</h5>
                                                        <button type="button" class="btn-close"
                                                            data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <form method="post"
                                                        action="<%= ctx %>/student/project/<%= project.getId() %>">
                                                        <input type="hidden" name="action" value="submit" />
                                                        <input type="hidden" name="milestoneId"
                                                            id="submitMilestoneId" />
                                                        <div class="modal-body pt-0">
                                                            <p class="text-muted mb-3" id="submitMilestoneTitle"
                                                                style="font-size:.875rem;"></p>
                                                            <div class="mb-3">
                                                                <label class="form-label fw-semibold"
                                                                    style="font-size:.83rem;">
                                                                    Submission Note (optional)
                                                                </label>
                                                                <textarea name="submissionNote" class="form-control"
                                                                    rows="4"
                                                                    placeholder="Describe what you've completed, any limitations, links to demo etc."></textarea>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer border-0 pt-0">
                                                            <button type="button" class="btn btn-light btn-sm"
                                                                data-bs-dismiss="modal">Cancel</button>
                                                            <button type="submit" class="btn btn-primary btn-sm">
                                                                <i class="bi bi-send me-1"></i>Submit for Review
                                                            </button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>

                                        <script>
                                            // Pass milestone id/title into the modal
                                            document.getElementById('submitMilestoneModal').addEventListener('show.bs.modal', function (e) {
                                                const btn = e.relatedTarget;
                                                document.getElementById('submitMilestoneId').value = btn.dataset.milestoneId;
                                                document.getElementById('submitMilestoneTitle').textContent =
                                                    'Submitting: ' + btn.dataset.milestoneTitle;
                                            });
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
                                                deploy:  [
                                                    { pct: 12, step: 'Pulling image...' },
                                                    { pct: 30, step: 'Building layers...' },
                                                    { pct: 55, step: 'Starting container...' },
                                                    { pct: 80, step: 'Waiting for health check...' },
                                                    { pct: 95, step: 'Almost there...' }
                                                ],
                                                start:   [
                                                    { pct: 25, step: 'Creating container instance...' },
                                                    { pct: 60, step: 'Allocating network ports...' },
                                                    { pct: 90, step: 'Starting service daemon...' }
                                                ],
                                                stop:    [
                                                    { pct: 20, step: 'Sending SIGTERM...' },
                                                    { pct: 55, step: 'Draining connections...' },
                                                    { pct: 88, step: 'Stopping container...' }
                                                ],
                                                rebuild: [
                                                    { pct: 10, step: 'Stopping old container...' },
                                                    { pct: 28, step: 'Pulling latest image...' },
                                                    { pct: 50, step: 'Rebuilding layers...' },
                                                    { pct: 70, step: 'Starting new container...' },
                                                    { pct: 90, step: 'Verifying startup...' }
                                                ],
                                                remove:  [
                                                    { pct: 25, step: 'Stopping container...' },
                                                    { pct: 60, step: 'Removing container...' },
                                                    { pct: 88, step: 'Removing image...' }
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

                                                    /* Confirm for remove */
                                                    if (action === 'remove') {
                                                        if (!confirm('Remove container and image for this project?')) {
                                                            e.preventDefault();
                                                            return;
                                                        }
                                                    }

                                                    showOverlay(action, form.dataset.label, form.dataset.icon || 'bi-arrow-repeat');
                                                });
                                            });

                                        })();
                                        </script>
                                        
                                        <!-- Live Daily Usage Updater -->
                                        <script>
                                            (function() {
                                                var isRunning = <%= running %>;
                                                var durationSecs = <%= durationToday %>;
                                                var limitSecs = <%= project.getRunningLimitSeconds() %>;
                                                var usageEl = document.getElementById('liveDailyUsage');
                                                
                                                function formatDur(sec) {
                                                    var h = Math.floor(sec / 3600);
                                                    var m = Math.floor((sec % 3600) / 60);
                                                    return h + "h " + m + "m";
                                                }
                                                
                                                if (isRunning && usageEl) {
                                                    setInterval(function() {
                                                        durationSecs += 1;
                                                        usageEl.innerText = formatDur(durationSecs) + " / " + formatDur(limitSecs);
                                                        
                                                        // Automatically reload if limit is reached to enforce backend restrictions
                                                        if (durationSecs >= limitSecs) {
                                                            location.reload();
                                                        }
                                                    }, 1000);
                                                }
                                            })();
                                        </script>

                                        <jsp:include page="/views/common/footer.jsp" />
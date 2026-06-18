<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.*,java.util.List" %>
<%
    request.setAttribute("pageTitle", "Manage Project");
    Project         project    = (Project)         request.getAttribute("project");
    List<Milestone> milestones = (List<Milestone>) request.getAttribute("milestones");
    List<Feedback>  feedbacks  = (List<Feedback>)  request.getAttribute("feedbacks");
    List<DeploymentLog> logs   = (List<DeploymentLog>) request.getAttribute("deployLogs");
    String          stats      = (String)           request.getAttribute("stats");
    String          ctx        = request.getContextPath();
    String          formError  = (String)            request.getAttribute("formError");
    String          success    = request.getParameter("success");
    String          ds         = project.getDockerStatus() != null ? project.getDockerStatus() : "none";
    boolean         running    = project.isRunning();
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/supervisor/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);"><%= project.getTitle() %></span>
</nav>

<!-- Flash -->
<% if (formError != null) { %>
<div class="rt-alert rt-alert-error rt-flash mb-3">
    <i class="bi bi-exclamation-circle-fill"></i> <%= formError %>
</div>
<% } %>
<% if (success != null) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i>
    <% if ("approved".equals(success))  { %>Milestone approved and grade recorded.
    <% } else if ("rejected".equals(success))  { %>Milestone rejected.
    <% } else if ("feedback".equals(success))  { %>Feedback posted.
    <% } else if ("built".equals(success))     { %>Project built successfully.
    <% } else if ("started".equals(success))   { %>Container started.
    <% } else if ("stopped".equals(success))   { %>Container stopped.
    <% } else if ("rebuilt".equals(success))   { %>Project rebuilt and started.
    <% } else if ("removed".equals(success))   { %>Container removed.
    <% } else { %>Action completed.<% } %>
</div>
<% } %>

<!-- Header -->
<div class="rt-card p-3 mb-3">
    <div class="d-flex flex-wrap align-items-center gap-2 mb-1">
        <h5 class="fw-bold mb-0"><%= project.getTitle() %></h5>
        <span class="badge rt-status-<%= project.getStatus().name().toLowerCase() %>">
            <%= project.getStatus() %>
        </span>
        <span class="small rt-docker-<%= ds %> ms-1">
            <i class="bi bi-circle-fill me-1" style="font-size:7px;"></i><%= ds %>
        </span>
        <% if (running) { %>
            Student: <strong style="font-size:.875rem;"><%= project.getStudentName() %></strong>
        <% } %>
        <% if (running && project.getPreviewUrl() != null) { %>
        <a href="<%= project.getPreviewUrl() %>" target="_blank"
           class="btn btn-sm btn-outline-success ms-auto">
            <i class="bi bi-box-arrow-up-right me-1"></i>Open :<%= project.getContainerPort() %>
        </a>
        <% } %>
    </div>
    <div style="font-size:.8rem;color:var(--rt-muted);">
        Student: <strong class="text-dark"><%= project.getStudentName() %></strong>
        &nbsp;&middot;&nbsp;
        <i class="bi bi-github me-1"></i>
        <a href="<%= project.getRepoUrl() %>" target="_blank" style="color:inherit;">
            <%= project.getRepoUrl() %>
        </a>
        &nbsp;&middot;&nbsp; Branch: <code><%= project.getBranch() %></code>
    </div>
</div>

<div class="row g-3">

    <!-- LEFT COLUMN -->
    <div class="col-lg-7">

        <!-- Container Control -->
        <div class="rt-card mb-3" style="border-color:#2d3748;background:#1a202c;">
            <div class="rt-card-header" style="color:#e2e8f0;border-color:#2d3748;">
                <i class="bi bi-box-seam text-info"></i>
                <span style="color:#e2e8f0;">Container Control</span>
                <span class="ms-2 small rt-docker-<%= ds %>" style="font-weight:600;"><%= ds %></span>
            </div>
            <div class="p-3">
                <% if (stats != null) { %>
                <div class="rounded-2 px-3 py-2 mb-3 rt-mono"
                     style="background:#2d3748;color:#68d391;font-size:.8rem;">
                    <i class="bi bi-graph-up me-1"></i><%= stats %>
                </div>
                <% } %>

                <!-- Resource Profile radio -->
                <div class="mb-3">
                    <div style="font-size:.8rem;font-weight:600;color:#a0aec0;margin-bottom:.5rem;">
                        Resource Profile
                    </div>
                    <div class="d-flex flex-wrap gap-3" style="font-size:.82rem;color:#e2e8f0;">
                        <label class="d-flex align-items-center gap-1">
                            <input type="radio" name="resProfile" value="small"/>
                            Small (0.5 CPU / 256m / 30min)
                        </label>
                        <label class="d-flex align-items-center gap-1">
                            <input type="radio" name="resProfile" value="standard" checked/>
                            <strong>Standard</strong> (1.0 CPU / 512m / 120min)
                        </label>
                        <label class="d-flex align-items-center gap-1">
                            <input type="radio" name="resProfile" value="large"/>
                            Large (1.5 CPU / 1g / 240min)
                        </label>
                        <label class="d-flex align-items-center gap-1">
                            <input type="radio" name="resProfile" value="demo"/>
                            Demo (Manual) (1.0 CPU / 512m / Manual)
                        </label>
                    </div>
                </div>

                <!-- Action buttons -->
                <div class="d-flex flex-wrap gap-2" id="dockerActionForms">
                    <form method="post" action="<%= ctx %>/supervisor/project/<%= project.getId() %>"
                          class="docker-action-form" data-action="deploy"
                          data-label="Deploying container..." data-icon="bi-play-circle">
                        <input type="hidden" name="action" value="deploy"/>
                        <input type="hidden" name="resProfile" value="standard" class="res-profile-mirror"/>
                        <button class="btn btn-success btn-sm" <%= running ? "disabled" : "" %>>
                            <i class="bi bi-play-circle me-1"></i>Deploy
                        </button>
                    </form>
                    <form method="post" action="<%= ctx %>/supervisor/project/<%= project.getId() %>"
                          class="docker-action-form" data-action="start"
                          data-label="Starting container..." data-icon="bi-play-fill">
                        <input type="hidden" name="action" value="start"/>
                        <button class="btn btn-primary btn-sm" <%= (running || "none".equals(ds)) ? "disabled" : "" %>>
                            <i class="bi bi-play-fill me-1"></i>Start
                        </button>
                    </form>
                    <form method="post" action="<%= ctx %>/supervisor/project/<%= project.getId() %>"
                          class="docker-action-form" data-action="stop"
                          data-label="Stopping container..." data-icon="bi-stop-circle">
                        <input type="hidden" name="action" value="stop"/>
                        <button class="btn btn-warning btn-sm" <%= !running ? "disabled" : "" %>>
                            <i class="bi bi-stop-circle me-1"></i>Stop
                        </button>
                    </form>
                    <form method="post" action="<%= ctx %>/supervisor/project/<%= project.getId() %>"
                          class="docker-action-form" data-action="rebuild"
                          data-label="Rebuilding &amp; restarting..." data-icon="bi-arrow-repeat">
                        <input type="hidden" name="action" value="rebuild"/>
                        <input type="hidden" name="resProfile" value="standard" class="res-profile-mirror"/>
                        <button class="btn btn-info btn-sm text-white">
                            <i class="bi bi-arrow-repeat me-1"></i>Rebuild
                        </button>
                    </form>
                    <form method="post" action="<%= ctx %>/supervisor/project/<%= project.getId() %>"
                          class="docker-action-form" data-action="remove"
                          data-label="Removing container &amp; image..." data-icon="bi-trash">
                        <input type="hidden" name="action" value="remove"/>
                        <button class="btn btn-danger btn-sm">
                            <i class="bi bi-trash me-1"></i>Remove
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Milestones -->
        <div class="rt-card mb-3">
            <div class="rt-card-header">
                <i class="bi bi-flag text-primary"></i> Milestones
            </div>
            <% if (milestones == null || milestones.isEmpty()) { %>
            <div class="p-4 text-center text-muted">No milestones defined.</div>
            <% } else { %>
            <div class="p-3 d-flex flex-column gap-3">
            <% for (Milestone m : milestones) { %>
            <div class="border rounded-3 p-3">
                <div class="d-flex flex-wrap justify-content-between align-items-start gap-2 mb-2">
                    <div>
                        <span class="fw-semibold">M<%= m.getMilestoneNo() %>: <%= m.getTitle() %></span>
                        <% if (m.isOverdue()) { %>
                        <span class="badge bg-danger ms-2" style="font-size:.62rem;">OVERDUE</span>
                        <% } %>
                    </div>
                    <span class="badge
                        <% if (m.getStatus()==Milestone.MilestoneStatus.APPROVED)    { %>bg-success
                        <% } else if (m.getStatus()==Milestone.MilestoneStatus.SUBMITTED)  { %>bg-primary
                        <% } else if (m.getStatus()==Milestone.MilestoneStatus.REJECTED)   { %>bg-danger
                        <% } else if (m.getStatus()==Milestone.MilestoneStatus.IN_PROGRESS){ %>bg-warning text-dark
                        <% } else { %>bg-secondary<% } %>"
                        style="font-size:.68rem;"><%= m.getStatus() %></span>
                </div>

                <div class="d-flex flex-wrap gap-3 mb-2" style="font-size:.79rem;color:var(--rt-muted);">
                    <span>Due: <%= m.getDueDate() != null ? m.getDueDate() : "—" %></span>
                    <span>Weight: <%= m.getWeight() %>%</span>
                    <% if (m.getGrade() != null) { %>
                    <span class="text-success fw-semibold">Grade: <%= String.format("%.1f",m.getGrade()) %></span>
                    <% } %>
                </div>

                <% if (m.getSubmissionNote() != null && !m.getSubmissionNote().isEmpty()) { %>
                <div class="rounded-2 p-2 mb-2" style="background:#f8faff;font-size:.8rem;border:1px solid #dbeafe;">
                    <strong>Student note:</strong> <%= m.getSubmissionNote() %>
                </div>
                <% } %>

                <!-- Review form for SUBMITTED milestones -->
                <% if (m.getStatus() == Milestone.MilestoneStatus.SUBMITTED) { %>
                <div class="d-flex gap-2 mt-2">
                    <button class="btn btn-sm btn-success"
                            data-bs-toggle="modal" data-bs-target="#approveModal"
                            data-mid="<%= m.getId() %>" data-title="<%= m.getTitle() %>">
                        <i class="bi bi-check-lg me-1"></i>Approve
                    </button>
                    <button class="btn btn-sm btn-outline-danger"
                            data-bs-toggle="modal" data-bs-target="#rejectModal"
                            data-mid="<%= m.getId() %>" data-title="<%= m.getTitle() %>">
                        <i class="bi bi-x-lg me-1"></i>Reject
                    </button>
                </div>
                <% } %>
                <% if (m.getSupervisorNote() != null && !m.getSupervisorNote().isEmpty()) { %>
                <div class="rounded-2 p-2 mt-2" style="background:#f0fdf4;font-size:.8rem;border:1px solid #bbf7d0;">
                    <strong>Your note:</strong> <%= m.getSupervisorNote() %>
                </div>
                <% } %>
            </div>
            <% } %>
            </div>
            <% } %>
        </div>

        <!-- Deployment Logs -->
        <div class="rt-card">
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

    </div><!-- /left -->

    <!-- RIGHT COLUMN -->
    <div class="col-lg-5">

        <!-- Assessment Marks -->
        <div class="rt-card mb-3">
            <div class="rt-card-header">
                <i class="bi bi-award text-success"></i> Thesis Assessment Marks
            </div>
            <div class="p-3">
                <form method="post" action="<%= ctx %>/supervisor/project/<%= project.getId() %>">
                    <input type="hidden" name="action" value="update_marks"/>
                    
                    <div class="mb-2">
                        <label class="form-label" style="font-size: .83rem; font-weight: 600;">Observation Mark (OM)</label>
                        <input type="number" name="observationMark" class="form-control form-control-sm" step="0.01" min="0" max="100" value="<%= project.getObservationMark() != null ? project.getObservationMark() : 0.0 %>" required>
                        <div class="form-text" style="font-size:.7rem;">Required for Final Presentation Eligibility (>= 50)</div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label" style="font-size: .83rem; font-weight: 600;">Continuous Assessment Mark (CM)</label>
                        <input type="number" name="continuousMark" class="form-control form-control-sm" step="0.01" min="0" max="100" value="<%= project.getContinuousMark() != null ? project.getContinuousMark() : 0.0 %>" required>
                        <div class="form-text" style="font-size:.7rem;">Required for Thesis Submission Eligibility (>= 45)</div>
                    </div>

                    <button type="submit" class="btn btn-success btn-sm w-100">
                        <i class="bi bi-save me-1"></i>Save Marks
                    </button>
                </form>
            </div>
        </div>

        <!-- Feedback -->
        <div class="rt-card mb-3">
            <div class="rt-card-header">
                <i class="bi bi-chat-dots text-warning"></i> Feedback
            </div>
            <div class="p-3">
                <form method="post" action="<%= ctx %>/supervisor/project/<%= project.getId() %>">
                    <input type="hidden" name="action" value="feedback"/>
                    <select name="type" class="form-select form-select-sm mb-2">
                        <option value="GENERAL">General</option>
                        <option value="MILESTONE">Milestone</option>
                        <option value="CODE_REVIEW">Code Review</option>
                        <option value="FINAL_EVAL">Final Evaluation</option>
                    </select>
                    <textarea name="content" class="form-control form-control-sm mb-2" rows="4"
                              placeholder="Write feedback for the student..." required></textarea>
                    <button type="submit" class="btn btn-primary btn-sm w-100">
                        <i class="bi bi-send me-1"></i>Send Feedback
                    </button>
                </form>
            </div>

            <% if (feedbacks != null && !feedbacks.isEmpty()) { %>
            <div class="border-top p-3 d-flex flex-column gap-2"
                 style="max-height:320px;overflow-y:auto;">
            <% for (Feedback f : feedbacks) { %>
                <div class="rounded-3 p-2 border" style="background:#f9fafb;font-size:.82rem;">
                    <div class="d-flex justify-content-between mb-1">
                        <span class="fw-semibold"><%= f.getAuthorName() %></span>
                        <span style="font-size:.7rem;color:var(--rt-muted);">
                            <%= f.getType().name().replace("_"," ") %>
                        </span>
                    </div>
                    <p class="mb-1"><%= f.getContent() %></p>
                    <div style="font-size:.7rem;color:var(--rt-muted);">
                        <%= f.getCreatedAt() != null ? f.getCreatedAt().toLocalDate() : "" %>
                        &nbsp;&middot;&nbsp;
                        <%= f.isReadByStudent() ? "✓ Read" : "Unread" %>
                    </div>
                </div>
            <% } %>
            </div>
            <% } else { %>
            <div class="p-3 text-center text-muted" style="font-size:.83rem;">No feedback yet.</div>
            <% } %>
        </div>

        <!-- Live log stream -->
        <% if (running) { %>
        <div class="rt-card">
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
    </div><!-- /right -->
</div>

<!-- Approve Modal -->
<div class="modal fade" id="approveModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px;">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold text-success">
                    <i class="bi bi-check-circle me-1"></i>Approve Milestone
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= ctx %>/supervisor/project/<%= project.getId() %>">
                <input type="hidden" name="action" value="approve"/>
                <input type="hidden" name="milestoneId" id="approveMilestoneId"/>
                <div class="modal-body pt-0">
                    <p class="text-muted mb-3" id="approveMilestoneTitle" style="font-size:.875rem;"></p>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">
                            Grade (0 – 100) *
                        </label>
                        <input type="number" name="grade" class="form-control"
                               min="0" max="100" step="0.5" required placeholder="e.g. 85"/>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Note</label>
                        <textarea name="supervisorNote" class="form-control" rows="3"
                                  placeholder="Optional feedback for the student..."></textarea>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-success btn-sm">
                        <i class="bi bi-check-lg me-1"></i>Approve & Grade
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Reject Modal -->
<div class="modal fade" id="rejectModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px;">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold text-danger">
                    <i class="bi bi-x-circle me-1"></i>Reject Milestone
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= ctx %>/supervisor/project/<%= project.getId() %>">
                <input type="hidden" name="action" value="reject"/>
                <input type="hidden" name="milestoneId" id="rejectMilestoneId"/>
                <div class="modal-body pt-0">
                    <p class="text-muted mb-3" id="rejectMilestoneTitle" style="font-size:.875rem;"></p>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">
                            Reason for rejection *
                        </label>
                        <textarea name="supervisorNote" class="form-control" rows="3" required
                                  placeholder="Explain what needs to be improved..."></textarea>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger btn-sm">
                        <i class="bi bi-x-lg me-1"></i>Reject
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
document.getElementById('approveModal').addEventListener('show.bs.modal', e => {
    const btn = e.relatedTarget;
    document.getElementById('approveMilestoneId').value = btn.dataset.mid;
    document.getElementById('approveMilestoneTitle').textContent = 'Milestone: ' + btn.dataset.title;
});
document.getElementById('rejectModal').addEventListener('show.bs.modal', e => {
    const btn = e.relatedTarget;
    document.getElementById('rejectMilestoneId').value = btn.dataset.mid;
    document.getElementById('rejectMilestoneTitle').textContent = 'Milestone: ' + btn.dataset.title;
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

    /* ── Mirror selected resource profile to each deploy/rebuild form ── */
    function syncResProfile() {
        var selected = document.querySelector('input[name="resProfile"]:checked');
        if (!selected) return;
        document.querySelectorAll('.res-profile-mirror').forEach(function (h) {
            h.value = selected.value;
        });
    }
    document.querySelectorAll('input[name="resProfile"]').forEach(function (r) {
        r.addEventListener('change', syncResProfile);
    });

    /* ── Progress sequences per action ── */
    var sequences = {
        deploy:  [
            { pct: 12, step: 'Pulling image...' },
            { pct: 30, step: 'Building layers...' },
            { pct: 55, step: 'Starting container...' },
            { pct: 80, step: 'Waiting for health check...' },
            { pct: 95, step: 'Almost there...' }
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

            syncResProfile();
            showOverlay(action, form.dataset.label, form.dataset.icon);
        });
    });

})();
</script>

<jsp:include page="/views/common/footer.jsp"/>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.*,java.util.List" %>
<%
    request.setAttribute("pageTitle", "Manage Project");
    Project                    project         = (Project)                    request.getAttribute("project");
    List<Milestone>            milestones      = (List<Milestone>)            request.getAttribute("milestones");
    List<Feedback>             feedbacks       = (List<Feedback>)             request.getAttribute("feedbacks");
    List<DeploymentLog>        logs            = (List<DeploymentLog>)        request.getAttribute("deployLogs");
    List<User>                 supervisors     = (List<User>)                 request.getAttribute("supervisors");
    List<SupervisorAssignment> history         = (List<SupervisorAssignment>) request.getAttribute("assignHistory");
    List<User>                 pita1Evaluators = (List<User>)                 request.getAttribute("pita1Evaluators");
    List<User>                 pita2Evaluators = (List<User>)                 request.getAttribute("pita2Evaluators");
    String ctx        = request.getContextPath();
    String formError  = (String) request.getAttribute("formError");
    String success    = request.getParameter("success");
    String ds         = project.getDockerStatus() != null ? project.getDockerStatus() : "none";
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/coordinator/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1 text-muted">/</span>
    <span class="text-muted"><%= project.getTitle() %></span>
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
    <% if ("assigned".equals(success))   { %>Supervisor assigned successfully.
    <% } else if ("rejected".equals(success))   { %>Project rejected.
    <% } else if ("feedback".equals(success))   { %>Feedback posted.
    <% } else if ("completed".equals(success))  { %>Project marked as completed.
    <% } else if ("evaluator_added".equals(success)) { %>Evaluator assigned successfully.
    <% } else if ("evaluator_removed".equals(success)) { %>Evaluator removed.
    <% } else if ("limit_updated".equals(success)) { %>Docker daily usage limit updated successfully.
    <% } else if ("milestone_created".equals(success)) { %>Milestone created successfully.
    <% } else if ("milestone_updated".equals(success)) { %>Milestone updated successfully.
    <% } else if ("milestone_deleted".equals(success)) { %>Milestone deleted successfully.
    <% } else { %>Action completed.<% } %>
</div>
<% } %>

<!-- Project header -->
<div class="rt-card p-3 mb-3">
    <div class="d-flex flex-wrap align-items-center gap-2 mb-1">
        <h5 class="fw-bold mb-0"><%= project.getTitle() %></h5>
        <span class="badge rt-status-<%= project.getStatus().name().toLowerCase() %>">
            <%= project.getStatus() %>
        </span>
        <span class="small rt-docker-<%= ds %>">
            <i class="bi bi-circle-fill me-1" style="font-size:7px;"></i><%= ds %>
        </span>
    </div>
    <div style="font-size:.8rem;color:var(--rt-muted);">
        Student: <strong class="text-dark"><%= project.getStudentName() %></strong>
        &nbsp;&middot;&nbsp;
        Supervisor:
        <strong class="text-dark">
            <%= project.getSupervisorName() != null ? project.getSupervisorName() : "Unassigned" %>
        </strong>
        &nbsp;&middot;&nbsp;
        <a href="<%= project.getRepoUrl() %>" target="_blank" style="color:inherit;">
            <i class="bi bi-github me-1"></i><%= project.getRepoUrl() %>
        </a>
        <% if (project.getOverallGrade() != null) { %>
        &nbsp;&middot;&nbsp;
        Grade: <strong style="color:var(--rt-primary);">
            <%= String.format("%.1f", project.getOverallGrade()) %>%
        </strong>
        <% } %>
    </div>
</div>

<div class="row g-3">
    <!-- LEFT -->
    <div class="col-lg-7">

        <!-- Assign Supervisor -->
        <div class="rt-card mb-3">
            <div class="rt-card-header">
                <i class="bi bi-person-check text-success"></i> Supervisor Assignment
            </div>
            <div class="p-3">
                <form method="post" action="<%= ctx %>/coordinator/project/<%= project.getId() %>">
                    <input type="hidden" name="action" value="assign"/>
                    <div class="row g-2">
                        <div class="col-sm-6">
                            <select name="supervisorId" class="form-select form-select-sm" required>
                                <option value="">— Select Supervisor —</option>
                                <% if (supervisors != null) { for (User sv : supervisors) { %>
                                <option value="<%= sv.getId() %>"
                                    <%= project.getSupervisorId() == sv.getId() ? "selected" : "" %>>
                                    <%= sv.getFullName() %> (<%= sv.getEmail() %>)
                                </option>
                                <% } } %>
                            </select>
                        </div>
                        <div class="col-sm-6">
                            <input type="text" name="note" class="form-control form-control-sm"
                                   placeholder="Optional note..."/>
                        </div>
                        <div class="col-12">
                            <button type="submit" class="btn btn-success btn-sm">
                                <i class="bi bi-person-check me-1"></i>Assign Supervisor
                            </button>
                        </div>
                    </div>
                </form>

                <!-- Assignment history -->
                <% if (history != null && !history.isEmpty()) { %>
                <div class="mt-3 border-top pt-3">
                    <div style="font-size:.78rem;font-weight:600;color:var(--rt-muted);margin-bottom:.5rem;">
                        Assignment History
                    </div>
                    <% for (SupervisorAssignment sa : history) { %>
                    <div class="d-flex gap-2 mb-1 align-items-start" style="font-size:.78rem;">
                        <i class="bi bi-clock-history text-muted mt-1"></i>
                        <div>
                            <strong><%= sa.getSupervisorName() %></strong>
                            assigned by <%= sa.getAssignedByName() %>
                            <span class="text-muted">
                                &middot; <%= sa.getAssignedAt() != null
                                    ? sa.getAssignedAt().toLocalDate() : "" %>
                            </span>
                            <% if (sa.getNote() != null && !sa.getNote().isEmpty()) { %>
                            <div class="text-muted">"<%= sa.getNote() %>"</div>
                            <% } %>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>

        <!-- Milestones overview -->
        <div class="rt-card mb-3">
            <div class="rt-card-header">
                <i class="bi bi-flag text-primary"></i> Milestones
                <% if (project.getStatus() != Project.Status.COMPLETED) { %>
                <button class="btn btn-outline-primary btn-sm ms-auto py-1 px-2" style="font-size:.75rem;"
                        data-bs-toggle="modal" data-bs-target="#createMilestoneModal">
                    <i class="bi bi-plus-lg me-1"></i>Add
                </button>
                <% } %>
            </div>
            <% if (milestones == null || milestones.isEmpty()) { %>
            <div class="p-3 text-muted" style="font-size:.83rem;">No milestones.</div>
            <% } else { %>
            <div class="table-responsive">
                <table class="table table-sm align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>#</th><th>Title</th><th>Due</th>
                            <th>Status</th><th>Grade</th><th>Weight</th>
                            <% if (project.getStatus() != Project.Status.COMPLETED) { %>
                            <th style="width: 80px;"></th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (Milestone m : milestones) { %>
                    <tr>
                        <td class="text-muted"><%= m.getMilestoneNo() %></td>
                        <td>
                            <div class="d-flex align-items-center gap-2 flex-wrap">
                                <span class="fw-semibold" style="font-size:.85rem;"><%= m.getTitle() %></span>
                                <% if ("PITA1".equals(m.getPitaStage())) { %>
                                <span class="badge bg-info text-white" style="font-size:.62rem;">PITA-01</span>
                                <% } else if ("PITA2".equals(m.getPitaStage())) { %>
                                <span class="badge bg-purple text-white" style="font-size:.62rem; background-color: #8b5cf6 !important;">PITA-02</span>
                                <% } %>
                            </div>
                            <% if (m.getDescription() != null && !m.getDescription().trim().isEmpty()) { %>
                            <div class="text-muted" style="font-size:.75rem;"><%= m.getDescription() %></div>
                            <% } %>
                        </td>
                        <td class="text-nowrap text-muted" style="font-size:.78rem;">
                            <%= m.getDueDate() != null ? m.getDueDate() : "—" %>
                            <% if (m.isOverdue()) { %>
                            <span class="badge bg-danger" style="font-size:.58rem;">OVERDUE</span>
                            <% } %>
                        </td>
                        <td>
                            <span class="badge
                                <% if (m.getStatus()==Milestone.MilestoneStatus.APPROVED)    { %>bg-success
                                <% } else if (m.getStatus()==Milestone.MilestoneStatus.SUBMITTED)  { %>bg-primary
                                <% } else if (m.getStatus()==Milestone.MilestoneStatus.REJECTED)   { %>bg-danger
                                <% } else { %>bg-secondary<% } %>"
                                style="font-size:.65rem;"><%= m.getStatus() %></span>
                        </td>
                        <td>
                            <% if (m.getGrade() != null) { %>
                            <strong style="color:var(--rt-success);">
                                <%= String.format("%.1f",m.getGrade()) %>
                            </strong>
                            <% } else { %>—<% } %>
                        </td>
                        <td><%= m.getWeight() %>%</td>
                        <% if (project.getStatus() != Project.Status.COMPLETED) { %>
                        <td class="text-end">
                            <div class="d-flex gap-1 justify-content-end">
                                <button class="btn btn-sm btn-outline-secondary border-0 p-1"
                                        title="Edit Milestone"
                                        data-bs-toggle="modal"
                                        data-bs-target="#editMilestoneModal"
                                        data-id="<%= m.getId() %>"
                                        data-no="<%= m.getMilestoneNo() %>"
                                        data-title="<%= m.getTitle().replace("\"", "&quot;") %>"
                                        data-description="<%= m.getDescription() != null ? m.getDescription().replace("\"", "&quot;") : "" %>"
                                        data-due="<%= m.getDueDate() != null ? m.getDueDate().toString() : "" %>"
                                        data-weight="<%= m.getWeight() %>"
                                        data-pita="<%= m.getPitaStage() != null ? m.getPitaStage() : "" %>">
                                    <i class="bi bi-pencil" style="font-size:.85rem;"></i>
                                </button>
                                <form method="post" action="<%= ctx %>/coordinator/project/<%= project.getId() %>" class="d-inline mb-0">
                                    <input type="hidden" name="action" value="deleteMilestone"/>
                                    <input type="hidden" name="milestoneId" value="<%= m.getId() %>"/>
                                    <button type="submit" class="btn btn-sm btn-outline-danger border-0 p-1"
                                            title="Delete Milestone"
                                            onclick="return confirm('Are you sure you want to delete this milestone?');">
                                        <i class="bi bi-trash" style="font-size:.85rem;"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                        <% } %>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>

        <!-- Deployment logs -->
        <div class="rt-card">
            <div class="rt-card-header">
                <i class="bi bi-terminal text-secondary"></i> Deployment Logs
            </div>
            <% if (logs == null || logs.isEmpty()) { %>
            <div class="p-3 text-muted" style="font-size:.83rem;">No logs yet.</div>
            <% } else { %>
            <div class="p-3">
            <% for (DeploymentLog log : logs) { %>
            <div class="d-flex align-items-center gap-2 mb-1" style="font-size:.79rem;">
                <span class="badge <%= "success".equals(log.getOutcome()) ? "bg-success" : "bg-danger" %>"
                      style="font-size:.62rem;font-family:'DM Mono',monospace;min-width:58px;">
                    <%= log.getAction() %>
                </span>
                <span class="text-muted">by <%= log.getPerformedByName() %></span>
                <span class="ms-auto text-muted rt-mono" style="font-size:.72rem;">
                    <%= log.getPerformedAt() != null
                        ? log.getPerformedAt().toString().replace("T"," ") : "" %>
                </span>
            </div>
            <% } %>
            </div>
            <% } %>
        </div>
    </div>

    <!-- RIGHT -->
    <div class="col-lg-5">

        <!-- Coordinator actions -->
        <div class="rt-card mb-3">
            <div class="rt-card-header">
                <i class="bi bi-shield-check text-primary"></i> Coordinator Actions
            </div>
            <div class="p-3 d-flex flex-column gap-2">
                <form method="post" action="<%= ctx %>/coordinator/project/<%= project.getId() %>">
                    <input type="hidden" name="action" value="complete"/>
                    <button type="submit" class="btn btn-primary btn-sm w-100"
                            onclick="return confirm('Mark this project as completed?')"
                            <%= project.getStatus() == Project.Status.COMPLETED ? "disabled" : "" %>>
                        <i class="bi bi-check2-all me-1"></i>Mark as Completed
                    </button>
                </form>
                <button class="btn btn-outline-danger btn-sm w-100"
                        data-bs-toggle="modal" data-bs-target="#rejectProjectModal"
                        <%= project.getStatus() == Project.Status.REJECTED ? "disabled" : "" %>>
                    <i class="bi bi-x-circle me-1"></i>Reject Project
                </button>
                <form method="post" action="<%= ctx %>/coordinator/project/<%= project.getId() %>" class="mt-1 border-top pt-2">
                    <input type="hidden" name="action" value="delete"/>
                    <button type="submit" class="btn btn-danger btn-sm w-100"
                            onclick="return confirm('WARNING: Permanently delete this project? All associated milestones, feedbacks, and evaluator assignments will be deleted. This action cannot be undone.')">
                        <i class="bi bi-trash me-1"></i>Delete Project
                    </button>
                </form>
            </div>
        </div>

        <!-- Docker Usage Limit -->
        <div class="rt-card mb-3">
            <div class="rt-card-header">
                <i class="bi bi-cpu text-info"></i> Docker Daily Usage Limit
            </div>
            <div class="p-3">
                <form method="post" action="<%= ctx %>/coordinator/project/<%= project.getId() %>">
                    <input type="hidden" name="action" value="updateLimit"/>
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.82rem;">Daily Limit (Hours)</label>
                        <div class="input-group input-group-sm">
                            <input type="number" name="limitHours" step="0.5" min="0.5" max="24" 
                                   value="<%= String.format(java.util.Locale.US, "%.1f", (double) project.getRunningLimitSeconds() / 3600.0) %>" 
                                   class="form-control" required/>
                            <span class="input-group-text">hours</span>
                        </div>
                        <div class="form-text text-muted" style="font-size:.72rem;">
                            Current limit: <%= (project.getRunningLimitSeconds() / 3600) %>h <%= ((project.getRunningLimitSeconds() % 3600) / 60) %>m
                        </div>
                    </div>
                    <button type="submit" class="btn btn-info btn-sm w-100 text-white">
                        <i class="bi bi-save me-1"></i>Update Limit
                    </button>
                </form>
            </div>
        </div>

        <!-- PITA Evaluation Assignment -->
        <div class="rt-card mb-3">
            <div class="rt-card-header">
                <i class="bi bi-people-fill text-info"></i> PITA Evaluation Assignment
            </div>
            <div class="p-3">
                <!-- PITA 1 -->
                <div class="mb-4">
                    <h6 class="fw-bold mb-2" style="font-size:.85rem;"><i class="bi bi-file-earmark-pdf me-1"></i>PITA-01 Evaluation (Max 3)</h6>
                    <% if (pita1Evaluators != null && !pita1Evaluators.isEmpty()) { %>
                        <div class="d-flex flex-column gap-2 mb-2">
                        <% for (User u : pita1Evaluators) { %>
                            <div class="d-flex align-items-center justify-content-between p-2 rounded border bg-light" style="font-size:.8rem;">
                                <div>
                                    <strong><%= u.getFullName() %></strong>
                                    <div class="text-muted" style="font-size:.72rem;"><%= u.getEmail() %></div>
                                </div>
                                <% if (project.getStatus() != Project.Status.COMPLETED) { %>
                                <form method="post" action="<%= ctx %>/coordinator/project/<%= project.getId() %>" class="d-inline mb-0">
                                    <input type="hidden" name="action" value="removeEvaluator"/>
                                    <input type="hidden" name="stage" value="PITA1"/>
                                    <input type="hidden" name="evaluatorId" value="<%= u.getId() %>"/>
                                    <button type="submit" class="btn btn-sm btn-outline-danger border-0 p-1" title="Remove" onclick="return confirm('Remove supervisor <%= u.getFullName() %> from PITA-01 evaluation?')">
                                        <i class="bi bi-x-circle" style="font-size:.9rem;"></i>
                                    </button>
                                </form>
                                <% } %>
                            </div>
                        <% } %>
                        </div>
                    <% } else { %>
                        <p class="text-muted small mb-2">No supervisors assigned for PITA-01 evaluation.</p>
                    <% } %>

                    <% if (project.getStatus() != Project.Status.COMPLETED && (pita1Evaluators == null || pita1Evaluators.size() < 3)) { %>
                        <form method="post" action="<%= ctx %>/coordinator/project/<%= project.getId() %>" class="row g-2">
                            <input type="hidden" name="action" value="addEvaluator"/>
                            <input type="hidden" name="stage" value="PITA1"/>
                            <div class="col-8">
                                <select name="evaluatorId" class="form-select form-select-sm" required>
                                    <option value="">— Select Evaluator —</option>
                                    <% if (supervisors != null) { for (User sv : supervisors) {
                                        boolean alreadyAssigned = false;
                                        if (pita1Evaluators != null) {
                                            for (User ae : pita1Evaluators) {
                                                if (ae.getId() == sv.getId()) { alreadyAssigned = true; break; }
                                            }
                                        }
                                        if (!alreadyAssigned) {
                                    %>
                                    <option value="<%= sv.getId() %>"><%= sv.getFullName() %></option>
                                    <% } } } %>
                                </select>
                            </div>
                            <div class="col-4">
                                <button type="submit" class="btn btn-success btn-sm w-100 py-1" style="font-size:.78rem;">
                                    <i class="bi bi-plus-circle me-1"></i>Add
                                </button>
                            </div>
                        </form>
                    <% } %>
                </div>

                <hr class="my-3"/>

                <!-- PITA 2 -->
                <div>
                    <h6 class="fw-bold mb-2" style="font-size:.85rem;"><i class="bi bi-file-earmark-pdf-fill me-1"></i>PITA-02 Evaluation (Max 3)</h6>
                    <% if (pita2Evaluators != null && !pita2Evaluators.isEmpty()) { %>
                        <div class="d-flex flex-column gap-2 mb-2">
                        <% for (User u : pita2Evaluators) { %>
                            <div class="d-flex align-items-center justify-content-between p-2 rounded border bg-light" style="font-size:.8rem;">
                                <div>
                                    <strong><%= u.getFullName() %></strong>
                                    <div class="text-muted" style="font-size:.72rem;"><%= u.getEmail() %></div>
                                </div>
                                <% if (project.getStatus() != Project.Status.COMPLETED) { %>
                                <form method="post" action="<%= ctx %>/coordinator/project/<%= project.getId() %>" class="d-inline mb-0">
                                    <input type="hidden" name="action" value="removeEvaluator"/>
                                    <input type="hidden" name="stage" value="PITA2"/>
                                    <input type="hidden" name="evaluatorId" value="<%= u.getId() %>"/>
                                    <button type="submit" class="btn btn-sm btn-outline-danger border-0 p-1" title="Remove" onclick="return confirm('Remove supervisor <%= u.getFullName() %> from PITA-02 evaluation?')">
                                        <i class="bi bi-x-circle" style="font-size:.9rem;"></i>
                                    </button>
                                </form>
                                <% } %>
                            </div>
                        <% } %>
                        </div>
                    <% } else { %>
                        <p class="text-muted small mb-2">No supervisors assigned for PITA-02 evaluation.</p>
                    <% } %>

                    <% if (project.getStatus() != Project.Status.COMPLETED && (pita2Evaluators == null || pita2Evaluators.size() < 3)) { %>
                        <form method="post" action="<%= ctx %>/coordinator/project/<%= project.getId() %>" class="row g-2">
                            <input type="hidden" name="action" value="addEvaluator"/>
                            <input type="hidden" name="stage" value="PITA2"/>
                            <div class="col-8">
                                <select name="evaluatorId" class="form-select form-select-sm" required>
                                    <option value="">— Select Evaluator —</option>
                                    <% if (supervisors != null) { for (User sv : supervisors) {
                                        boolean alreadyAssigned = false;
                                        if (pita2Evaluators != null) {
                                            for (User ae : pita2Evaluators) {
                                                if (ae.getId() == sv.getId()) { alreadyAssigned = true; break; }
                                            }
                                        }
                                        if (!alreadyAssigned) {
                                    %>
                                    <option value="<%= sv.getId() %>"><%= sv.getFullName() %></option>
                                    <% } } } %>
                                </select>
                            </div>
                            <div class="col-4">
                                <button type="submit" class="btn btn-success btn-sm w-100 py-1" style="font-size:.78rem;">
                                    <i class="bi bi-plus-circle me-1"></i>Add
                                </button>
                            </div>
                        </form>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Feedback -->
        <div class="rt-card">
            <div class="rt-card-header">
                <i class="bi bi-chat-dots text-warning"></i> Feedback
            </div>
            <div class="p-3">
                <form method="post" action="<%= ctx %>/coordinator/project/<%= project.getId() %>">
                    <input type="hidden" name="action" value="feedback"/>
                    <select name="type" class="form-select form-select-sm mb-2">
                        <option value="GENERAL">General</option>
                        <option value="FINAL_EVAL">Final Evaluation</option>
                    </select>
                    <textarea name="content" class="form-control form-control-sm mb-2" rows="3"
                              placeholder="Post feedback..." required></textarea>
                    <button type="submit" class="btn btn-primary btn-sm w-100">
                        <i class="bi bi-send me-1"></i>Post Feedback
                    </button>
                </form>
            </div>
            <% if (feedbacks != null && !feedbacks.isEmpty()) { %>
            <div class="border-top p-3 d-flex flex-column gap-2"
                 style="max-height:280px;overflow-y:auto;">
            <% for (Feedback f : feedbacks) { %>
                <div class="rounded-2 p-2 border" style="background:#f9fafb;font-size:.81rem;">
                    <div class="d-flex justify-content-between mb-1">
                        <span class="fw-semibold"><%= f.getAuthorName() %></span>
                        <span style="font-size:.7rem;color:var(--rt-muted);">
                            <%= f.getType().name().replace("_"," ") %>
                        </span>
                    </div>
                    <p class="mb-1"><%= f.getContent() %></p>
                    <div style="font-size:.7rem;color:var(--rt-muted);">
                        <%= f.getCreatedAt() != null ? f.getCreatedAt().toLocalDate() : "" %>
                    </div>
                </div>
            <% } %>
            </div>
            <% } %>
        </div>
    </div>
</div>

<!-- Reject Project Modal -->
<div class="modal fade" id="rejectProjectModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px;">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold text-danger">Reject Project</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= ctx %>/coordinator/project/<%= project.getId() %>">
                <input type="hidden" name="action" value="reject"/>
                <div class="modal-body pt-0">
                    <p class="text-muted" style="font-size:.875rem;">
                        Rejecting <strong><%= project.getTitle() %></strong>.
                        The student will be notified via feedback.
                    </p>
                    <textarea name="reason" class="form-control" rows="3"
                              placeholder="Reason for rejection..."></textarea>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger btn-sm">
                        <i class="bi bi-x-circle me-1"></i>Reject Project
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Create Milestone Modal -->
<div class="modal fade" id="createMilestoneModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px;">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold">Add Milestone</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= ctx %>/coordinator/project/<%= project.getId() %>">
                <input type="hidden" name="action" value="createMilestone"/>
                <div class="modal-body pt-0">
                    <div class="row g-2">
                        <div class="col-4">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">No. *</label>
                            <input type="number" name="milestoneNo" class="form-control form-control-sm" required min="1" 
                                   value="<%= (milestones != null ? milestones.size() + 1 : 1) %>"/>
                        </div>
                        <div class="col-8">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Weight (%) *</label>
                            <input type="number" step="0.1" name="weight" class="form-control form-control-sm" required min="0" max="100"/>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Title *</label>
                            <input type="text" name="title" class="form-control form-control-sm" required placeholder="e.g. System Implementation"/>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Due Date *</label>
                            <input type="date" name="dueDate" class="form-control form-control-sm" required/>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">PITA Evaluation Stage</label>
                            <select name="pitaStage" class="form-select form-select-sm">
                                <option value="">None / Standard Milestone</option>
                                <option value="PITA1">PITA-01 Evaluation</option>
                                <option value="PITA2">PITA-02 Evaluation</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Description</label>
                            <textarea name="description" class="form-control form-control-sm" rows="3" placeholder="Milestone description/requirements..."></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm">Create Milestone</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Milestone Modal -->
<div class="modal fade" id="editMilestoneModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px;">
            <div class="modal-header border-0">
                <h5 class="modal-title fw-bold">Edit Milestone</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="<%= ctx %>/coordinator/project/<%= project.getId() %>">
                <input type="hidden" name="action" value="updateMilestone"/>
                <input type="hidden" name="milestoneId" id="editMilestoneId"/>
                <div class="modal-body pt-0">
                    <div class="row g-2">
                        <div class="col-12">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Title *</label>
                            <input type="text" name="title" id="editMilestoneTitle" class="form-control form-control-sm" required/>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Weight (%) *</label>
                            <input type="number" step="0.1" name="weight" id="editMilestoneWeight" class="form-control form-control-sm" required min="0" max="100"/>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Due Date *</label>
                            <input type="date" name="dueDate" id="editMilestoneDue" class="form-control form-control-sm" required/>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">PITA Evaluation Stage</label>
                            <select name="pitaStage" id="editMilestonePita" class="form-select form-select-sm">
                                <option value="">None / Standard Milestone</option>
                                <option value="PITA1">PITA-01 Evaluation</option>
                                <option value="PITA2">PITA-02 Evaluation</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold" style="font-size:.83rem;">Description</label>
                            <textarea name="description" id="editMilestoneDesc" class="form-control form-control-sm" rows="3"></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
(function() {
    var editModal = document.getElementById('editMilestoneModal');
    if (editModal) {
        editModal.addEventListener('show.bs.modal', function(e) {
            var trigger = e.relatedTarget;
            document.getElementById('editMilestoneId').value = trigger.getAttribute('data-id');
            document.getElementById('editMilestoneTitle').value = trigger.getAttribute('data-title');
            document.getElementById('editMilestoneWeight').value = trigger.getAttribute('data-weight');
            document.getElementById('editMilestoneDue').value = trigger.getAttribute('data-due');
            document.getElementById('editMilestonePita').value = trigger.getAttribute('data-pita') || "";
            document.getElementById('editMilestoneDesc').value = trigger.getAttribute('data-description');
        });
    }
})();
</script>

<jsp:include page="/views/common/footer.jsp"/>

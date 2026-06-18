<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.*" %>
<%
    request.setAttribute("pageTitle", "PITA Evaluation");
    Project project = (Project) request.getAttribute("project");
    PitaAssignment assignment = (PitaAssignment) request.getAttribute("pitaAssignment");
    String formError = (String) request.getAttribute("formError");
    String ctx = request.getContextPath();
    String stageName = "PITA1".equals(assignment.getStage()) ? "PITA-01 (Interim I)" : "PITA-02 (Interim II)";
    boolean isGraded = assignment.getGrade() != null;
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/supervisor/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">PITA Evaluation</span>
</nav>

<!-- Error Flash -->
<% if (formError != null) { %>
<div class="rt-alert rt-alert-error rt-flash mb-3">
    <i class="bi bi-exclamation-circle-fill"></i> <%= formError %>
</div>
<% } %>

<!-- Header Card -->
<div class="rt-card p-3 mb-4">
    <div class="d-flex flex-wrap align-items-center gap-2 mb-1">
        <a href="<%= ctx %>/supervisor/dashboard" class="btn btn-sm btn-light border me-1">
            <i class="bi bi-arrow-left"></i>
        </a>
        <h5 class="fw-bold mb-0">PITA Evaluation: <%= project.getTitle() %></h5>
        <span class="badge bg-info text-white ms-2"><%= stageName %></span>
        <% if (isGraded) { %>
            <span class="badge bg-success ms-2"><i class="bi bi-check-circle me-1"></i>Graded</span>
        <% } else { %>
            <span class="badge bg-warning text-dark ms-2"><i class="bi bi-clock me-1"></i>Pending</span>
        <% } %>
    </div>
    <div style="font-size:.8rem;color:var(--rt-muted);">
        Student: <strong class="text-dark"><%= project.getStudentName() %></strong>
        &nbsp;&middot;&nbsp;
        <i class="bi bi-github me-1"></i>
        <a href="<%= project.getRepoUrl() %>" target="_blank" style="color:inherit;"><%= project.getRepoUrl() %></a>
        &nbsp;&middot;&nbsp; Branch: <code><%= project.getBranch() %></code>
    </div>
</div>

<div class="row g-3">
    <!-- LEFT COLUMN: Evaluation Form -->
    <div class="col-lg-7">
        <div class="rt-card p-4">
            <h6 class="fw-bold mb-3"><i class="bi bi-pencil-square text-primary me-2"></i>Grading &amp; Assessment</h6>
            
            <form method="post" action="<%= ctx %>/supervisor/pita-evaluate" class="needs-validation">
                <input type="hidden" name="projectId" value="<%= project.getId() %>"/>
                <input type="hidden" name="stage" value="<%= assignment.getStage() %>"/>

                <!-- Grade input -->
                <div class="mb-4">
                    <label for="grade" class="form-label fw-semibold" style="font-size:.85rem;">Evaluation Grade (Max 100)</label>
                    <div class="input-group" style="max-width:200px;">
                        <input type="number" 
                               class="form-control rt-mono" 
                               id="grade" 
                               name="grade" 
                               min="0.00" 
                               max="100.00" 
                               step="0.01" 
                               placeholder="e.g. 85.50 (optional)" 
                               value="<%= isGraded ? String.format("%.2f", assignment.getGrade()) : "" %>" />
                        <span class="input-group-text rt-mono">/ 100</span>
                    </div>
                    <div class="form-text" style="font-size:.75rem;">Optional: Enter a score between 0.00 and 100.00. You may save comments without a grade.</div>
                </div>

                <!-- Feedback Comments -->
                <div class="mb-4">
                    <label for="feedback" class="form-label fw-semibold" style="font-size:.85rem;">Feedback &amp; Comments</label>
                    <textarea class="form-control" 
                              id="feedback" 
                              name="feedback" 
                              rows="6" 
                              placeholder="Provide constructuve feedback for the student's PITA milestones..." 
                              required><%= assignment.getFeedback() != null ? assignment.getFeedback() : "" %></textarea>
                    <div class="form-text" style="font-size:.75rem;">Write summary comments on strength, areas for improvement, or execution notes.</div>
                </div>

                <!-- Action Button -->
                <div class="d-flex align-items-center gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-save me-1"></i><%= isGraded ? "Update Evaluation" : "Submit Evaluation" %>
                    </button>
                    <a href="<%= ctx %>/supervisor/dashboard" class="btn btn-outline-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <!-- RIGHT COLUMN: Evaluation Rubrics Accordion Guide -->
    <div class="col-lg-5">
        <div class="rt-card p-3 h-100">
            <h6 class="fw-bold mb-3"><i class="bi bi-book text-info me-2"></i>Grading Criteria Guide</h6>
            
            <% if ("PITA1".equals(assignment.getStage())) { %>
                <!-- PITA-01 Rubrics -->
                <div class="accordion" id="rubricAccordion">
                    <!-- PLO2 -->
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="headingPlo2">
                            <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapsePlo2" aria-expanded="true" aria-controls="collapsePlo2" style="font-size:.8rem;font-weight:600;">
                                PLO2: Technical Development (10%)
                            </button>
                        </h2>
                        <div id="collapsePlo2" class="accordion-collapse collapse show" aria-labelledby="headingPlo2" data-bs-parent="#rubricAccordion">
                            <div class="accordion-body" style="font-size:.78rem;">
                                <div class="mb-2"><strong>Front End (UI):</strong> Appealing, consistent styles/format across multiple screens. (80-100 score).</div>
                                <div class="mb-2"><strong>Back End:</strong> Robust business logic, proper algorithm &amp; data structure design. (80-100 score).</div>
                                <div><strong>Database/API:</strong> Established CRUD &amp; front-back end integration. (80-100 score).</div>
                            </div>
                        </div>
                    </div>
                    <!-- PLO3 -->
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="headingPlo3">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapsePlo3" aria-expanded="false" aria-controls="collapsePlo3" style="font-size:.8rem;font-weight:600;">
                                PLO3: Thesis Progress (5%)
                            </button>
                        </h2>
                        <div id="collapsePlo3" class="accordion-collapse collapse" aria-labelledby="headingPlo3" data-bs-parent="#rubricAccordion">
                            <div class="accordion-body" style="font-size:.78rem;">
                                Evaluating the progress of thesis preparation and writing skills at approximately 50% completion.
                            </div>
                        </div>
                    </div>
                    <!-- PLO6 -->
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="headingPlo6">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapsePlo6" aria-expanded="false" aria-controls="collapsePlo6" style="font-size:.8rem;font-weight:600;">
                                PLO6: Meeting Frequency (2.5%)
                            </button>
                        </h2>
                        <div id="collapsePlo6" class="accordion-collapse collapse" aria-labelledby="headingPlo6" data-bs-parent="#rubricAccordion">
                            <div class="accordion-body" style="font-size:.78rem;">
                                <ul>
                                    <li>&gt;= 5 meetings: Excellent (2.5 pts)</li>
                                    <li>4 meetings: Good (2.0 pts)</li>
                                    <li>3 meetings: Satisfactory (1.5 pts)</li>
                                    <li>&lt; 3 meetings: Needs Improvement</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <!-- PLO8 -->
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="headingPlo8">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapsePlo8" aria-expanded="false" aria-controls="collapsePlo8" style="font-size:.8rem;font-weight:600;">
                                PLO8: Execution &amp; Monitoring (2.5%)
                            </button>
                        </h2>
                        <div id="collapsePlo8" class="accordion-collapse collapse" aria-labelledby="headingPlo8" data-bs-parent="#rubricAccordion">
                            <div class="accordion-body" style="font-size:.78rem;">
                                <strong>Project Execution:</strong> Completed > 50% of functions (80-100 score).<br/>
                                <strong>Project Monitoring:</strong> Successfully identified and corrected deployment/build issues.
                            </div>
                        </div>
                    </div>
                </div>
            <% } else { %>
                <!-- PITA-02 Rubrics -->
                <div class="accordion" id="rubricAccordion">
                    <!-- PLO2 -->
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="headingPlo2">
                            <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapsePlo2" aria-expanded="true" aria-controls="collapsePlo2" style="font-size:.8rem;font-weight:600;">
                                PLO2: Technical Development (10%)
                            </button>
                        </h2>
                        <div id="collapsePlo2" class="accordion-collapse collapse show" aria-labelledby="headingPlo2" data-bs-parent="#rubricAccordion">
                            <div class="accordion-body" style="font-size:.78rem;">
                                <strong>Front End:</strong> Complete consistency across modules. (80-100 score).<br/>
                                <strong>Back End:</strong> Fully functional business process flow. (80-100 score).<br/>
                                <strong>Database/API:</strong> CRUD communication fully established. (80-100 score).
                            </div>
                        </div>
                    </div>
                    <!-- PLO6 -->
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="headingPlo6">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapsePlo6" aria-expanded="false" aria-controls="collapsePlo6" style="font-size:.8rem;font-weight:600;">
                                PLO6: Meeting Frequency (2.5%)
                            </button>
                        </h2>
                        <div id="collapsePlo6" class="accordion-collapse collapse" aria-labelledby="headingPlo6" data-bs-parent="#rubricAccordion">
                            <div class="accordion-body" style="font-size:.78rem;">
                                <ul>
                                    <li>&gt;= 8 meetings: Excellent (2.5 pts)</li>
                                    <li>7 meetings: Good (2.18 pts)</li>
                                    <li>6 meetings: Satisfactory (1.87 pts)</li>
                                    <li>5 meetings: Fair (1.56 pts)</li>
                                    <li>&lt; 5 meetings: Fail (0 pts)</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <!-- PLO8 -->
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="headingPlo8">
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapsePlo8" aria-expanded="false" aria-controls="collapsePlo8" style="font-size:.8rem;font-weight:600;">
                                PLO8: Execution &amp; Monitoring (2.5%)
                            </button>
                        </h2>
                        <div id="collapsePlo8" class="accordion-collapse collapse" aria-labelledby="headingPlo8" data-bs-parent="#rubricAccordion">
                            <div class="accordion-body" style="font-size:.78rem;">
                                <strong>Project Execution:</strong> 100% finished code and modules (80-100 score).<br/>
                                <strong>Project Monitoring:</strong> Successfully deployed on container platform without error.
                            </div>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp"/>

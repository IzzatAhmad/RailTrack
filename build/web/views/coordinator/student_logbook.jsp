<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.*, java.util.List, java.time.format.DateTimeFormatter" %>
<%
    request.setAttribute("pageTitle", "Student Logbook");
    User student = (User) request.getAttribute("student");
    List<LogbookEntry> entries = (List<LogbookEntry>) request.getAttribute("entries");
    String success = request.getParameter("success");
    String ctx = request.getContextPath();

    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy");
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
    DateTimeFormatter timestampFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/coordinator/logbook" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-book me-1"></i>Student Logbooks
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">Student Logbook</span>
</nav>

<!-- Success Flash -->
<% if ("updated".equals(success)) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i> Log book entry verification status updated.
</div>
<% } %>

<!-- Logbook Header Card -->
<div class="rt-card p-4 mb-4">
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div>
            <h4 class="fw-bold mb-3 d-flex align-items-center">
                <i class="bi bi-journal-bookmark-fill text-success me-2"></i> 
                Logbook - <%= student.getUsername() %>
            </h4>
            
            <div class="row g-3" style="font-size: .88rem;">
                <div class="col-auto">
                    <span class="text-muted">Name:</span> 
                    <strong class="text-dark ms-1"><%= student.getFullName() %></strong>
                </div>
                <% if (student.getPhone() != null && !student.getPhone().isEmpty()) { %>
                <div class="col-auto ms-sm-4">
                    <span class="text-muted">Phone:</span> 
                    <span class="badge bg-light text-dark border ms-1"><%= student.getPhone() %></span>
                </div>
                <% } %>
                <div class="col-auto ms-sm-4">
                    <span class="text-muted">Email:</span> 
                    <span class="text-dark ms-1"><%= student.getEmail() %></span>
                </div>
            </div>
        </div>
        <a href="<%= ctx %>/coordinator/logbook" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left me-1"></i>Back to List
        </a>
    </div>
</div>

<!-- Log Entries Timeline -->
<div class="timeline-container">
    <% if (entries == null || entries.isEmpty()) { %>
    <div class="rt-card text-center py-5 text-muted">
        <i class="bi bi-journal-x" style="font-size: 3rem;"></i>
        <h5 class="mt-3 fw-bold">Student Logbook is empty</h5>
        <p class="small text-muted mb-0">The student has not submitted any logbook entries yet.</p>
    </div>
    <% } else { %>
    <div class="position-relative ps-4" style="border-left: 2px solid var(--rt-border); margin-left: 10px;">
        <% 
            java.time.LocalDate lastDate = null;
            for (LogbookEntry entry : entries) {
                boolean isNewDay = lastDate == null || !lastDate.equals(entry.getActivityDate());
                lastDate = entry.getActivityDate();
        %>
            
            <% if (isNewDay) { %>
                <!-- Timeline Date Node -->
                <div class="position-absolute translate-middle-x" style="left: -1px; margin-top: 10px;">
                    <span class="badge bg-primary px-3 py-2 fw-semibold" style="font-size: .8rem; border-radius: 20px;">
                        <%= entry.getActivityDate().format(dateFormatter) %>
                    </span>
                </div>
                <div style="height: 38px;"></div> <!-- Spacer for date node -->
            <% } %>

            <!-- Log Card Entry -->
            <div class="rt-card p-3 mb-3 position-relative" style="border-left: 4px solid <%= entry.isVerified() ? "var(--rt-success)" : "var(--rt-warning)" %>;">
                <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-2">
                    <div class="d-flex align-items-center gap-2">
                        <span class="badge bg-light text-dark border">
                            <i class="bi bi-people me-1"></i> <%= entry.getActivityType() %>
                        </span>
                        <span class="text-muted small">
                            <i class="bi bi-clock me-1"></i> <%= entry.getActivityTime().format(timeFormatter) %>
                        </span>
                    </div>

                    <div class="d-flex align-items-center gap-2">
                        <!-- Verification Form -->
                        <form method="post" action="<%= ctx %>/coordinator/logbook" class="d-inline">
                            <input type="hidden" name="entryId" value="<%= entry.getId() %>"/>
                            <% if (entry.isVerified()) { %>
                                <input type="hidden" name="action" value="unverify"/>
                                <button type="submit" class="btn btn-sm btn-outline-danger d-flex align-items-center gap-1 py-1 px-2" style="font-size: .75rem;">
                                    <i class="bi bi-x-circle-fill"></i> Unverify
                                </button>
                            <% } else { %>
                                <input type="hidden" name="action" value="verify"/>
                                <button type="submit" class="btn btn-sm btn-success d-flex align-items-center gap-1 py-1 px-2 text-white" style="font-size: .75rem; background-color: #4caf50; border-color: #4caf50;">
                                    <i class="bi bi-check-circle-fill"></i> Verify Entry
                                </button>
                            <% } %>
                        </form>
                    </div>
                </div>

                <div class="mb-3">
                    <h6 class="fw-semibold text-dark mb-1" style="font-size: .83rem;">Project Activity</h6>
                    <div class="text-secondary" style="font-size: .83rem; line-height: 1.45; white-space: pre-wrap;"><%= entry.getActivityDetails() %></div>
                </div>

                <% if (entry.getProblems() != null && !entry.getProblems().trim().isEmpty()) { %>
                <div class="mb-3 p-2 rounded" style="background-color: #fff5f5; border-left: 3px solid var(--rt-danger);">
                    <div class="fw-semibold text-danger mb-1" style="font-size: .78rem;">
                        <i class="bi bi-exclamation-octagon-fill me-1"></i> Issue(s)
                    </div>
                    <div class="text-dark small" style="white-space: pre-wrap;"><%= entry.getProblems() %></div>
                </div>
                <% } %>

                <% if (entry.getSuggestions() != null && !entry.getSuggestions().trim().isEmpty()) { %>
                <div class="mb-2 p-2 rounded" style="background-color: #f0fdf4; border-left: 3px solid var(--rt-success);">
                    <div class="fw-semibold text-success mb-1" style="font-size: .78rem;">
                        <i class="bi bi-check-circle-fill me-1"></i> Solution/Suggestion
                    </div>
                    <div class="text-dark small" style="white-space: pre-wrap;"><%= entry.getSuggestions() %></div>
                </div>
                <% } %>

                <% if (entry.getImages() != null && !entry.getImages().isEmpty()) { %>
                <div class="row g-2 mt-3 mb-2">
                    <% for (LogbookImage img : entry.getImages()) { %>
                    <div class="col-6 col-sm-4 col-md-3">
                        <a href="<%= ctx %>/file/image/<%= img.getId() %>" target="_blank" title="<%= img.getFileName() %>">
                            <img src="<%= ctx %>/file/image/<%= img.getId() %>"
                                 class="img-fluid rounded border shadow-sm"
                                 style="max-height: 120px; object-fit: cover; width: 100%; cursor: pointer;"
                                 alt="<%= img.getFileName() %>" />
                        </a>
                    </div>
                    <% } %>
                </div>
                <% } %>

                <div class="text-muted small mt-2 pt-2 border-top" style="font-size: .72rem;">
                    Created on: <%= entry.getCreatedAt().format(timestampFormatter) %>
                </div>
            </div>

        <% } %>
    </div>
    <% } %>
</div>

<jsp:include page="/views/common/footer.jsp"/>

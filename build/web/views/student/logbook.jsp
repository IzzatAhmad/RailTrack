<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.*, java.util.List, java.time.LocalDate, java.time.LocalTime, java.time.format.DateTimeFormatter" %>
<%
    request.setAttribute("pageTitle", "Logbook");
    User student = (User) request.getAttribute("student");
    int projectId = (Integer) request.getAttribute("projectId");
    List<LogbookEntry> entries = (List<LogbookEntry>) request.getAttribute("entries");
    String formError = (String) request.getAttribute("formError");
    String success = request.getParameter("success");
    String ctx = request.getContextPath();

    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy");
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
    DateTimeFormatter timestampFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/student/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">Logbook</span>
</nav>

<!-- Success / Error Flash -->
<% if (formError != null) { %>
<div class="rt-alert rt-alert-error rt-flash mb-3">
    <i class="bi bi-exclamation-circle-fill"></i> <%= formError %>
</div>
<% } %>
<% if ("saved".equals(success)) { %>
<div class="rt-alert rt-alert-success rt-flash mb-3">
    <i class="bi bi-check-circle-fill"></i> Log book entry saved successfully!
</div>
<% } %>

<!-- Logbook Header Card -->
<div class="rt-card p-4 mb-4">
    <div class="d-flex justify-content-between align-items-start flex-wrap gap-3">
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
        
        <% if (projectId > 0) { %>
        <button class="btn btn-success d-flex align-items-center gap-1 shadow-sm" 
                data-bs-toggle="modal" data-bs-target="#newLogModal"
                style="background-color: #4caf50; border-color: #4caf50;">
            <i class="bi bi-plus-lg"></i> Add Log
        </button>
        <% } else { %>
        <button class="btn btn-secondary" disabled>
            <i class="bi bi-lock-fill me-1"></i>No Project Submitted
        </button>
        <% } %>
    </div>
</div>

<!-- Log Entries Timeline -->
<div class="timeline-container">
    <% if (entries == null || entries.isEmpty()) { %>
    <div class="rt-card text-center py-5 text-muted">
        <i class="bi bi-journal-x" style="font-size: 3rem;"></i>
        <h5 class="mt-3 fw-bold">Your Logbook is empty</h5>
        <p class="small text-muted mb-0">Record your regular project meetings and activities here.</p>
    </div>
    <% } else { %>
    <div class="position-relative ps-4" style="border-left: 2px solid var(--rt-border); margin-left: 10px;">
        <% 
            LocalDate lastDate = null;
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
            <div class="rt-card p-3 mb-3 position-relative" style="transition: transform .15s; border-left: 4px solid <%= entry.isVerified() ? "var(--rt-success)" : "var(--rt-warning)" %>;">
                <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-2">
                    <div class="d-flex align-items-center gap-2">
                        <span class="badge bg-light text-dark border">
                            <i class="bi bi-people me-1"></i> <%= entry.getActivityType() %>
                        </span>
                        <span class="text-muted small">
                            <i class="bi bi-clock me-1"></i> <%= entry.getActivityTime().format(timeFormatter) %>
                        </span>
                    </div>

                    <div>
                        <% if (entry.isVerified()) { %>
                            <span class="badge bg-success text-white px-2 py-1" style="font-size: .75rem;">
                                <i class="bi bi-check-circle-fill me-1"></i> Verified
                            </span>
                        <% } else { %>
                            <span class="badge bg-danger text-white px-2 py-1" style="font-size: .75rem;">
                                <i class="bi bi-exclamation-triangle-fill me-1"></i> Unverified
                            </span>
                        <% } %>
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

<!-- Modal: New Log Entry -->
<% if (projectId > 0) { %>
<div class="modal fade" id="newLogModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content" style="border-radius: 12px; overflow: hidden; border: none;">
            <div class="modal-header text-white" style="background-color: #5cb85c; padding: 1rem 1.5rem;">
                <h5 class="modal-title fw-bold d-flex align-items-center gap-2">
                    <i class="bi bi-pencil-square"></i> New Log Book Entry
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="<%= ctx %>/student/logbook" enctype="multipart/form-data" class="needs-validation" onsubmit="return validateDateTime(event)">
                <input type="hidden" name="projectId" value="<%= projectId %>"/>
                
                <div class="modal-body p-4">
                    <div id="futureAlertMsg" class="alert alert-danger p-2 mb-3 small d-none">
                        <i class="bi bi-exclamation-triangle-fill me-1"></i> Date and time of activity cannot be in the future.
                    </div>
                    <div class="row g-3 mb-4">
                        <div class="col-md-4">
                            <label class="form-label fw-bold text-dark" style="font-size: .85rem;">
                                <i class="bi bi-calendar-event me-1 text-muted"></i> Date of Activity
                            </label>
                            <input type="date" name="activityDate" id="activityDateInput" class="form-control" required 
                                   value="<%= LocalDate.now().toString() %>" 
                                   max="<%= LocalDate.now().toString() %>" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold text-dark" style="font-size: .85rem;">
                                <i class="bi bi-clock me-1 text-muted"></i> Time of Activity
                            </label>
                            <input type="time" name="activityTime" id="activityTimeInput" class="form-control" required
                                   value="<%= java.time.LocalTime.now().toString().substring(0, 5) %>" />
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold text-dark" style="font-size: .85rem;">
                                <i class="bi bi-people me-1 text-muted"></i> Type of Activity
                            </label>
                            <select name="activityType" class="form-select" required>
                                <option value="Face To Face" selected>Face To Face</option>
                                <option value="Online Meeting">Online Meeting</option>
                                <option value="Email/Chat">Email/Chat</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                    </div>

                    <!-- Project Activity Details -->
                    <div class="mb-4">
                        <label class="form-label fw-bold text-primary" style="font-size: .88rem;">
                            Project Activity
                        </label>
                        <textarea class="form-control" name="activityDetails" rows="4" required
                                  placeholder="Write all activities that you reported to your supervisor during your meeting..."></textarea>
                    </div>

                    <!-- Problems / Issues -->
                    <div class="mb-4">
                        <label class="form-label fw-bold text-danger" style="font-size: .88rem;">
                            Problem / Issue
                        </label>
                        <textarea class="form-control" name="problems" rows="3"
                                  placeholder="Write problems/issues that occur while doing your activities..."></textarea>
                    </div>

                    <!-- Suggestions -->
                    <div class="mb-4">
                        <label class="form-label fw-bold text-success" style="font-size: .88rem;">
                            Solving Suggestion
                        </label>
                        <textarea class="form-control" name="suggestions" rows="3"
                                  placeholder="Write the solution suggested by yourself or supervisor..."></textarea>
                    </div>

                    <!-- Attachments -->
                    <div class="mb-3">
                        <label class="form-label fw-bold text-secondary d-flex align-items-center gap-1" style="font-size: .88rem;">
                            <i class="bi bi-images"></i> Attachments (Optional, max 3 images, 10MB per image)
                        </label>
                        <div class="row g-2">
                            <div class="col-md-4">
                                <input type="file" name="image1" id="imageInput1" class="form-control form-control-sm" accept="image/*" onchange="validateImageFile(this)"/>
                            </div>
                            <div class="col-md-4">
                                <input type="file" name="image2" id="imageInput2" class="form-control form-control-sm" accept="image/*" onchange="validateImageFile(this)"/>
                            </div>
                            <div class="col-md-4">
                                <input type="file" name="image3" id="imageInput3" class="form-control form-control-sm" accept="image/*" onchange="validateImageFile(this)"/>
                            </div>
                        </div>
                        <div id="imageAlertMsg" class="text-danger mt-1 small d-none" style="font-size: .75rem;">
                            <i class="bi bi-exclamation-circle-fill"></i> One or more selected files exceed the 10MB size limit.
                        </div>
                    </div>
                </div>

                <div class="modal-footer bg-light border-0 px-4 py-3">
                    <button type="button" class="btn btn-secondary px-4" data-bs-target="#newLogModal" data-bs-dismiss="modal" style="border-radius: 4px;">Cancel</button>
                    <button type="submit" class="btn btn-primary px-4 d-flex align-items-center gap-1" style="border-radius: 4px; background-color: #0d6efd; border-color: #0d6efd;">
                        <i class="bi bi-save"></i> Save Entry
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
<% } %>

<script>
function validateDateTime(event) {
    var dateVal = document.getElementById("activityDateInput").value;
    var timeVal = document.getElementById("activityTimeInput").value;
    var alertMsg = document.getElementById("futureAlertMsg");
    if (!dateVal || !timeVal) return true;

    // selected date time
    var selectedDateTime = new Date(dateVal + 'T' + timeVal);
    var now = new Date();

    if (selectedDateTime > now) {
        if (alertMsg) {
            alertMsg.classList.remove("d-none");
        }
        event.preventDefault();
        return false;
    }
    if (alertMsg) {
        alertMsg.classList.add("d-none");
    }
    return true;
}

function validateImageFile(input) {
    var file = input.files[0];
    var alertMsg = document.getElementById("imageAlertMsg");
    if (file) {
        if (file.size > 10 * 1024 * 1024) {
            if (alertMsg) {
                alertMsg.classList.remove("d-none");
            }
            input.value = ""; // clear selected file
        } else {
            // Check all to hide alert if all clean
            var f1 = document.getElementById("imageInput1").files[0];
            var f2 = document.getElementById("imageInput2").files[0];
            var f3 = document.getElementById("imageInput3").files[0];
            var s1 = f1 ? f1.size : 0;
            var s2 = f2 ? f2.size : 0;
            var s3 = f3 ? f3.size : 0;
            if (s1 <= 10*1024*1024 && s2 <= 10*1024*1024 && s3 <= 10*1024*1024) {
                if (alertMsg) {
                    alertMsg.classList.add("d-none");
                }
            }
        }
    }
}

// Reset modal fields on close
document.addEventListener("DOMContentLoaded", function() {
    var modalEl = document.getElementById("newLogModal");
    if (modalEl) {
        modalEl.addEventListener("hidden.bs.modal", function() {
            var alertMsg = document.getElementById("futureAlertMsg");
            if (alertMsg) {
                alertMsg.classList.add("d-none");
            }
            var imgAlert = document.getElementById("imageAlertMsg");
            if (imgAlert) {
                imgAlert.classList.add("d-none");
            }
            var i1 = document.getElementById("imageInput1");
            var i2 = document.getElementById("imageInput2");
            var i3 = document.getElementById("imageInput3");
            if (i1) i1.value = "";
            if (i2) i2.value = "";
            if (i3) i3.value = "";
        });
    }
});
</script>

<jsp:include page="/views/common/footer.jsp"/>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.Project, java.util.*" %>
<%
    request.setAttribute("pageTitle", "Progress Overview");
    List<String> semesters = (List<String>) request.getAttribute("semesters");
    String selectedSemester = (String) request.getAttribute("selectedSemester");
    List<Project> projects = (List<Project>) request.getAttribute("projects");
    Map<Integer, Integer> verifiedLogbooksCount = (Map<Integer, Integer>) request.getAttribute("verifiedLogbooksCount");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    String ctx = request.getContextPath();
%>
<jsp:include page="/views/common/header.jsp"/>

<style>
    .sl-card { background: var(--rt-surface); border: 1px solid var(--rt-border); border-radius: var(--rt-radius); box-shadow: var(--rt-shadow); }
    .sl-selector { display: flex; align-items: center; gap: 1rem; padding: 1.1rem 1.4rem; flex-wrap: wrap; }
    .sl-selector label { font-weight: 600; font-size: .88rem; color: var(--rt-text); white-space: nowrap; }
    .sl-selector select { min-width: 200px; font-size: .875rem; border: 1px solid var(--rt-border); border-radius: 8px; padding: .45rem .9rem; outline: none; }
    .sl-submit-btn { background: var(--rt-primary); color: #fff; border: none; border-radius: 8px; padding: .48rem 1.25rem; font-size: .875rem; font-weight: 600; cursor: pointer; }
    .sl-table { width: 100%; border-collapse: collapse; font-size: .855rem; }
    .sl-table thead tr { background: #f7f8fc; border-top: 1px solid var(--rt-border); border-bottom: 1px solid var(--rt-border); }
    .sl-table th { padding: .55rem 1.1rem; font-size: .74rem; text-transform: uppercase; color: var(--rt-muted); font-weight: 600; text-align: left; }
    .sl-table td { padding: .72rem 1.1rem; vertical-align: middle; border-bottom: 1px solid #f0f2f8; color: var(--rt-text); }
    .sl-table tbody tr:hover td { background: #f7f9ff; }
    .sl-empty { padding: 3.5rem 1rem; text-align: center; color: var(--rt-muted); font-size: .9rem; }
    .progress-bar-custom { height: 8px; border-radius: 4px; background: #e5e7eb; overflow: hidden; position: relative; margin-top: 4px; }
    .progress-bar-fill { height: 100%; background: var(--rt-success); }
    .sl-total-badge { background: #eff6ff; color: var(--rt-primary); border: 1px solid #bfdbfe; border-radius: 20px; padding: .18rem .75rem; font-size: .75rem; font-weight: 600; margin-left: auto; }
</style>

<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/coordinator/dashboard" style="color:var(--rt-primary);text-decoration:none;"><i class="bi bi-house me-1"></i>Dashboard</a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">Progress Overview</span>
</nav>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-3 gap-2">
    <div>
        <h4 class="fw-bold mb-0">Student Progress Overview</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">Monitor milestones, logbooks, and marks per semester</p>
    </div>
</div>

<div class="sl-card mb-4">
    <form method="post" action="<%= ctx %>/coordinator/progress_overview" class="sl-selector">
        <label for="semesterSelect">Select Session/Semester</label>
        <select id="semesterSelect" name="semester">
            <% if (semesters != null && !semesters.isEmpty()) { for (String s : semesters) { %>
            <option value="<%= s %>" <%= s.equals(selectedSemester) ? "selected" : "" %>><%= s %></option>
            <% } } else { %>
            <option value="">(No semesters found)</option>
            <% } %>
        </select>
        <button type="submit" class="sl-submit-btn"><i class="bi bi-check-lg me-1"></i>Submit</button>
        <% if (totalCount != null) { %>
        <span class="sl-total-badge"><i class="bi bi-bar-chart-fill me-1"></i><%= totalCount %> student<%= totalCount != 1 ? "s" : "" %></span>
        <% } %>
    </form>

    <% if (projects == null || projects.isEmpty()) { %>
    <div class="sl-empty">
        <i class="bi bi-search" style="font-size:2.4rem;display:block;margin-bottom:.65rem;opacity:.4;"></i>
        No students found<% if (selectedSemester != null) { %> for semester <strong><%= selectedSemester %></strong><% } %>.
    </div>
    <% } else { %>
    <div class="table-responsive">
        <table class="sl-table">
            <thead>
                <tr>
                    <th>No.</th>
                    <th>Student Details</th>
                    <th>Supervisor</th>
                    <th>Status / Milestone</th>
                    <th>Logbooks</th>
                    <th>Chap. Progress</th>
                    <th>Marks (Obs/Cont/Overall)</th>
                </tr>
            </thead>
            <tbody>
            <% 
                int row = 1;
                for (Project p : projects) { 
                    boolean hasProject = p.getId() > 0;
                    int logbooks = hasProject && verifiedLogbooksCount != null && verifiedLogbooksCount.containsKey(p.getId()) ? verifiedLogbooksCount.get(p.getId()) : 0;
                    
                    int chaptersDone = 0;
                    int[] chArr = p.getChapterProgressArray();
                    for(int c : chArr) { if(c == 100) chaptersDone++; }
                    double chapterPct = (chaptersDone / 8.0) * 100;
                    
                    String statusColor = "secondary";
                    if (p.getStatus() == Project.Status.ACTIVE) statusColor = "success";
                    else if (p.getStatus() == Project.Status.COMPLETED) statusColor = "primary";
                    else if (p.getStatus() == Project.Status.UNDER_REVIEW) statusColor = "info";
            %>
                <tr>
                    <td class="text-muted"><%= row++ %></td>
                    <td>
                        <div class="fw-bold">
                            <% if (hasProject) { %>
                                <a href="<%= ctx %>/coordinator/project?id=<%= p.getId() %>" style="text-decoration:none;"><%= p.getStudentName() != null ? p.getStudentName() : "—" %></a>
                            <% } else { %>
                                <%= p.getStudentName() != null ? p.getStudentName() : "—" %>
                            <% } %>
                        </div>
                        <div style="font-size:.75rem;color:var(--rt-muted);"><%= p.getStudentUsername() != null ? p.getStudentUsername() : "—" %> • <%= p.getStudentDepartment() != null ? p.getStudentDepartment() : "" %></div>
                    </td>
                    <td><%= p.getSupervisorName() != null && !p.getSupervisorName().isEmpty() ? p.getSupervisorName() : "<span class='text-danger small'>Unassigned</span>" %></td>
                    <td>
                        <span class="badge bg-<%= statusColor %> mb-1"><%= p.getStatus() %></span><br>
                        <span style="font-size:.75rem;color:var(--rt-muted);">Milestone: <strong>M<%= p.getCurrentMilestoneNo() %></strong></span>
                    </td>
                    <td>
                        <span class="badge <%= logbooks >= 5 ? "bg-success" : "bg-warning text-dark" %>"><%= logbooks %> Verified</span>
                    </td>
                    <td style="min-width: 120px;">
                        <div style="font-size:.75rem;"><%= chaptersDone %>/8 Chapters</div>
                        <div class="progress-bar-custom">
                            <div class="progress-bar-fill" style="width: <%= chapterPct %>%;"></div>
                        </div>
                    </td>
                    <td style="font-size:.8rem;">
                        <div class="text-muted">Obs: <strong class="text-dark"><%= p.getObservationMark() != null ? p.getObservationMark() : "-" %></strong></div>
                        <div class="text-muted">Cont: <strong class="text-dark"><%= p.getContinuousMark() != null ? p.getContinuousMark() : "-" %></strong></div>
                        <div class="text-primary mt-1">Overall: <strong><%= p.getOverallGrade() != null ? p.getOverallGrade() : "-" %></strong></div>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </div>
    <% } %>
</div>

<jsp:include page="/views/common/footer.jsp"/>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.Project, java.util.*, java.util.Map.Entry" %>
<%
    request.setAttribute("pageTitle", "Presentation Eligibility List");
    List<String> semesters = (List<String>) request.getAttribute("semesters");
    String selectedSemester = (String) request.getAttribute("selectedSemester");
    Map<String, List<Project>> grouped = (Map<String, List<Project>>) request.getAttribute("grouped");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    
    Map<Integer, Boolean> eligibilityMap = (Map<Integer, Boolean>) request.getAttribute("eligibilityMap");
    if (eligibilityMap == null) eligibilityMap = new HashMap<>();
    
    String ctx = request.getContextPath();
%>
<jsp:include page="/views/common/header.jsp"/>

<style>
    /* Minimal custom CSS as we rely on Bootstrap 5 utility classes */
    .table-custom th {
        font-weight: 600;
        letter-spacing: 0.5px;
    }
    .status-icon {
        font-size: 1.25rem;
    }
</style>

<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/coordinator/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <a href="<%= ctx %>/coordinator/menu" style="color:var(--rt-primary);text-decoration:none;">Student Menu Management</a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">Presentation Eligibility List</span>
</nav>

<div class="container py-4" style="max-width: 1100px; margin: 0 auto;">

    <!-- Semester selector card -->
    <div class="card shadow-sm border-0 mb-4 rounded-3">
        <div class="card-body">
            <form method="post" action="<%= ctx %>/presentation" class="d-flex align-items-center flex-wrap gap-4 m-0 px-2 py-1">
                <label for="semesterSelect" class="fw-bold mb-0 text-dark fs-5">Select Session/Semester</label>
                <select id="semesterSelect" name="semester" class="form-select shadow-none border-secondary-subtle" style="width: auto; min-width: 250px;">
                    <% if (semesters != null && !semesters.isEmpty()) {
                        for (String s : semesters) { %>
                    <option value="<%= s %>" <%= s.equals(selectedSemester) ? "selected" : "" %>><%= s %></option>
                    <% } } else { %>
                    <option value="">(No semesters found)</option>
                    <% } %>
                </select>
                <button type="submit" class="btn btn-primary px-4 fw-semibold shadow-sm">
                    Submit
                </button>
            </form>
        </div>
    </div>

    <!-- Results -->
    <%
        if (grouped == null || grouped.isEmpty()) {
    %>
    <div class="card shadow-sm border-0 rounded-3">
        <div class="card-body text-center py-5 text-muted">
            <i class="bi bi-person-x" style="font-size: 3rem; opacity: 0.5;"></i>
            <p class="mt-3 mb-0 fs-5">No students found<% if (selectedSemester != null) { %> for semester <strong><%= selectedSemester %></strong><% } %>.</p>
        </div>
    </div>
    <%
        } else {
    %>
    <div class="card shadow-sm border-0 rounded-3 overflow-hidden">
        <%
            int globalRow = 1;
            int supIdx    = 1;
            for (Entry<String, List<Project>> entry : grouped.entrySet()) {
                String          supName  = entry.getKey();
                List<Project>   projects = entry.getValue();
        %>
        
        <!-- Group Header -->
        <div class="d-flex align-items-stretch bg-primary text-white <%= supIdx > 1 ? "mt-4 border-top" : "" %>">
            <div class="p-3 fw-bold fs-5 text-uppercase d-flex align-items-center" style="min-width: 160px; letter-spacing: 1px;">
                GROUP: <%= supIdx %>
            </div>
            <div class="d-flex align-items-center flex-grow-1 bg-white text-primary fw-bold px-3 py-2 m-2 rounded shadow-sm">
                Evaluator: <%= supName %>
            </div>
        </div>

        <!-- Group Table -->
        <div class="table-responsive">
            <table class="table table-hover align-middle table-custom mb-0">
                <thead class="table-light text-secondary text-uppercase border-bottom border-2" style="font-size: 0.85rem;">
                    <tr>
                        <th style="width: 80px;" class="ps-4">No.</th>
                        <th style="width: 140px;">Matric No.</th>
                        <th style="min-width: 250px;">Student Name</th>
                        <th>Project Title</th>
                        <th class="text-center pe-4" style="width: 140px;">Presentation</th>
                    </tr>
                </thead>
                <tbody class="border-top-0">
                <%
                    int localRow = 1;
                    for (Project p : projects) {
                        boolean isEligible = eligibilityMap.getOrDefault(p.getId(), false);
                %>
                    <tr>
                        <td class="text-muted ps-4"><%= localRow %> / <%= globalRow %></td>
                        <td>
                            <span class="badge bg-secondary shadow-sm px-2 py-1"><%= p.getStudentUsername() != null ? p.getStudentUsername() : "—" %></span>
                        </td>
                        <td>
                            <div class="fw-bold text-dark text-uppercase"><%= p.getStudentName() != null ? p.getStudentName() : "—" %></div>
                        </td>
                        <td>
                            <div class="text-secondary"><%= p.getTitle() != null && !p.getTitle().isEmpty() ? p.getTitle() : "—" %></div>
                        </td>
                        <td class="text-center pe-4">
                            <% if (isEligible) { %>
                                <i class="bi bi-check-circle-fill status-icon text-success"></i>
                            <% } else { %>
                                <i class="bi bi-x-circle-fill status-icon text-danger"></i>
                            <% } %>
                        </td>
                    </tr>
                <%
                        localRow++;
                        globalRow++;
                    }
                %>
                </tbody>
            </table>
        </div>
        <%
                supIdx++;
            }
        %>
    </div>
    <%
        }
    %>
</div>

<jsp:include page="/views/common/footer.jsp"/>

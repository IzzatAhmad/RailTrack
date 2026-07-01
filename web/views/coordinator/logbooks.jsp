<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.*,java.util.List,java.util.Map" %>
<%
    request.setAttribute("pageTitle", "Student Logbooks");
    List<User> students = (List<User>) request.getAttribute("students");
    Map<Integer, Integer> totalEntriesMap = (Map<Integer, Integer>) request.getAttribute("totalEntriesMap");
    Map<Integer, Integer> verifiedEntriesMap = (Map<Integer, Integer>) request.getAttribute("verifiedEntriesMap");
    String success = request.getParameter("success");
    String ctx = request.getContextPath();
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- Breadcrumb -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/coordinator/dashboard" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-house me-1"></i>Dashboard
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <a href="<%= ctx %>/coordinator/menu" style="color:var(--rt-primary);text-decoration:none;">Student Menu Management</a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">Student Logbooks</span>
</nav>

<div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
    <div>
        <h4 class="fw-bold mb-0">Student Logbooks</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">Monitor student logbook engagement and verify entries system-wide.</p>
    </div>
</div>

<div class="rt-card">
    <div class="rt-card-header">
        <i class="bi bi-book text-primary"></i> All Student Logbooks
        <span class="badge bg-secondary ms-auto" id="visibleCount" style="font-size:.7rem;">
            <%= students != null ? students.size() : 0 %>
        </span>
    </div>

    <!-- Search toolbar -->
    <div class="px-3 pt-3 pb-2 border-bottom d-flex flex-wrap gap-2 align-items-center">
        <!-- Search bar -->
        <div class="input-group input-group-sm" style="max-width:280px;">
            <span class="input-group-text bg-white border-end-0">
                <i class="bi bi-search text-muted" style="font-size:.8rem;"></i>
            </span>
            <input type="text" id="searchInput" class="form-control border-start-0 ps-0"
                   placeholder="Search student name, email..." style="font-size:.83rem;">
        </div>
    </div>

    <% if (students == null || students.isEmpty()) { %>
    <div class="p-5 text-center text-muted">
        <i class="bi bi-person-x" style="font-size:2rem;"></i>
        <p class="mt-2">No students found in the system.</p>
    </div>
    <% } else { %>
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0" id="studentsTable">
            <thead class="table-light">
                <tr>
                    <th style="min-width:200px;">Student Info</th>
                    <th style="min-width:160px;">Department</th>
                    <th class="text-center" style="min-width:110px;">Total Entries</th>
                    <th class="text-center" style="min-width:110px;">Verified</th>
                    <th style="min-width:90px;"></th>
                </tr>
            </thead>
            <tbody id="studentsBody">
            <% for (User s : students) { 
                int total = totalEntriesMap.getOrDefault(s.getId(), 0);
                int verified = verifiedEntriesMap.getOrDefault(s.getId(), 0);
            %>
            <tr data-student="<%= s.getFullName().toLowerCase() %>" data-email="<%= s.getEmail().toLowerCase() %>">
                <td>
                    <div class="fw-medium"><%= s.getFullName() %></div>
                    <div style="font-size:.75rem;color:var(--rt-muted);"><%= s.getEmail() %></div>
                </td>
                <td>
                    <div class="small text-muted"><%= s.getDepartment() != null ? s.getDepartment() : "General" %></div>
                </td>
                <td class="text-center">
                    <span class="badge bg-light text-dark border"><%= total %></span>
                </td>
                <td class="text-center">
                    <% if (verified > 0) { %>
                        <span class="badge bg-success-subtle text-success border border-success-subtle"><%= verified %> verified</span>
                    <% } else { %>
                        <span class="badge bg-light text-muted border">0</span>
                    <% } %>
                </td>
                <td class="text-end pe-3">
                    <a href="<%= ctx %>/coordinator/logbook?studentId=<%= s.getId() %>"
                       class="btn btn-sm btn-outline-primary py-1 px-2">
                        <i class="bi bi-eye me-1"></i>View
                    </a>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <div id="noResults" class="p-5 text-center text-muted d-none">
            <i class="bi bi-search" style="font-size:1.5rem;"></i>
            <p class="mt-2">No students match your search.</p>
        </div>
    </div>
    <% } %>
</div>

<style>
    .bg-success-subtle {
        background-color: rgba(25, 135, 84, 0.1) !important;
    }
</style>

<script>
(function () {
    var searchInput = document.getElementById('searchInput');
    var tbody       = document.getElementById('studentsBody');
    var visibleCount= document.getElementById('visibleCount');
    var noResults   = document.getElementById('noResults');

    function applyFilters() {
        var q = searchInput ? searchInput.value.trim().toLowerCase() : '';
        if (!tbody) return;
        var rows = tbody.querySelectorAll('tr');
        var visible = 0;

        rows.forEach(function (row) {
            var student = row.dataset.student || '';
            var email   = row.dataset.email   || '';

            var matchQ = !q || student.includes(q) || email.includes(q);

            if (matchQ) {
                row.style.display = '';
                visible++;
            } else {
                row.style.display = 'none';
            }
        });

        if (visibleCount) visibleCount.textContent = visible;
        if (noResults) noResults.classList.toggle('d-none', visible > 0);
    }

    if (searchInput) searchInput.addEventListener('input', applyFilters);

    applyFilters();
})();
</script>

<jsp:include page="/views/common/footer.jsp"/>


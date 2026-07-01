<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.Project, java.util.*, java.util.Map.Entry" %>
<%
    request.setAttribute("pageTitle", "Student List");
    List<String>               semesters        = (List<String>)               request.getAttribute("semesters");
    String                     selectedSemester = (String)                      request.getAttribute("selectedSemester");
    Map<String, List<Project>> grouped          = (Map<String, List<Project>>) request.getAttribute("grouped");
    Integer                    totalCount       = (Integer)                     request.getAttribute("totalCount");
    String                     ctx              = request.getContextPath();
%>
<jsp:include page="/views/common/header.jsp"/>

<style>
    /* ── Page-level overrides ── */
    .sl-card {
        background: var(--rt-surface);
        border: 1px solid var(--rt-border);
        border-radius: var(--rt-radius);
        box-shadow: var(--rt-shadow);
    }

    /* Semester selector bar */
    .sl-selector {
        display: flex;
        align-items: center;
        gap: 1rem;
        padding: 1.1rem 1.4rem;
        flex-wrap: wrap;
    }
    .sl-selector label {
        font-weight: 600;
        font-size: .88rem;
        color: var(--rt-text);
        white-space: nowrap;
    }
    .sl-selector select {
        min-width: 200px;
        font-size: .875rem;
        border: 1px solid var(--rt-border);
        border-radius: 8px;
        padding: .45rem .9rem;
        color: var(--rt-text);
        background: #fff;
        cursor: pointer;
        transition: border-color .15s, box-shadow .15s;
        outline: none;
    }
    .sl-selector select:focus {
        border-color: var(--rt-primary);
        box-shadow: 0 0 0 3px rgba(37,99,235,.12);
    }
    .sl-submit-btn {
        background: var(--rt-primary);
        color: #fff;
        border: none;
        border-radius: 8px;
        padding: .48rem 1.25rem;
        font-size: .875rem;
        font-weight: 600;
        cursor: pointer;
        transition: background .15s, transform .1s;
    }
    .sl-submit-btn:hover {
        background: var(--rt-primary-dk);
        transform: translateY(-1px);
    }
    .sl-submit-btn:active {
        transform: translateY(0);
    }

    /* ── Supervisor section heading ── */
    .sl-sup-heading {
        padding: .85rem 1.4rem .5rem;
        font-size: .96rem;
        font-weight: 700;
        color: var(--rt-primary);
        display: flex;
        align-items: center;
        gap: .45rem;
    }
    .sl-sup-heading .sl-sup-num {
        color: var(--rt-text);
    }

    /* ── Table ── */
    .sl-table {
        width: 100%;
        border-collapse: collapse;
        font-size: .855rem;
    }
    .sl-table thead tr {
        background: #f7f8fc;
        border-top: 1px solid var(--rt-border);
        border-bottom: 1px solid var(--rt-border);
    }
    .sl-table th {
        padding: .55rem 1.1rem;
        font-size: .74rem;
        text-transform: uppercase;
        letter-spacing: .06em;
        color: var(--rt-muted);
        font-weight: 600;
        text-align: left;
        white-space: nowrap;
    }
    .sl-table td {
        padding: .72rem 1.1rem;
        vertical-align: middle;
        border-bottom: 1px solid #f0f2f8;
        color: var(--rt-text);
    }
    .sl-table tbody tr:last-child td {
        border-bottom: none;
    }
    .sl-table tbody tr:hover td {
        background: #f7f9ff;
    }

    /* row number cell */
    .sl-td-no {
        color: var(--rt-muted);
        font-size: .82rem;
        white-space: nowrap;
        width: 54px;
    }
    /* matrik */
    .sl-td-matrik a {
        color: var(--rt-primary);
        font-weight: 500;
        text-decoration: none;
        font-size: .82rem;
    }
    .sl-td-matrik a:hover {
        text-decoration: underline;
    }
    /* student name */
    .sl-td-name {
        font-weight: 700;
        font-size: .855rem;
        min-width: 180px;
    }
    /* course */
    .sl-td-course {
        color: var(--rt-muted);
        font-size: .82rem;
        white-space: nowrap;
    }
    /* project title */
    .sl-td-title a {
        color: #d97706;
        text-decoration: none;
        font-size: .82rem;
    }
    .sl-td-title a:hover {
        text-decoration: underline;
    }
    .sl-td-title .sl-no-proj {
        color: var(--rt-muted);
        font-style: italic;
        font-size: .82rem;
    }

    /* section divider */
    .sl-sup-divider {
        border: none;
        border-top: 2px solid var(--rt-border);
        margin: 0;
    }

    /* empty state */
    .sl-empty {
        padding: 3.5rem 1rem;
        text-align: center;
        color: var(--rt-muted);
        font-size: .9rem;
    }
    .sl-empty i {
        font-size: 2.4rem;
        display: block;
        margin-bottom: .65rem;
        opacity: .4;
    }

    /* total badge */
    .sl-total-badge {
        background: #eff6ff;
        color: var(--rt-primary);
        border: 1px solid #bfdbfe;
        border-radius: 20px;
        padding: .18rem .75rem;
        font-size: .75rem;
        font-weight: 600;
        margin-left: auto;
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
    <span style="color:var(--rt-muted);">Student List</span>
</nav>

<!-- Page header -->
<div class="d-flex flex-wrap justify-content-between align-items-center mb-3 gap-2">
    <div>
        <h4 class="fw-bold mb-0">Student List</h4>
        <p class="text-muted mb-0" style="font-size:.875rem;">Students grouped by supervisor per session/semester</p>
    </div>
</div>

<div class="sl-card mb-4">
    <!-- Semester selector -->
    <form method="post" action="<%= ctx %>/students/list" class="sl-selector">
        <label for="semesterSelect">Select Session/Semester</label>
        <select id="semesterSelect" name="semester">
            <% if (semesters != null && !semesters.isEmpty()) {
                for (String s : semesters) { %>
            <option value="<%= s %>" <%= s.equals(selectedSemester) ? "selected" : "" %>><%= s %></option>
            <% } } else { %>
            <option value="">(No semesters found)</option>
            <% } %>
        </select>
        <button type="submit" class="sl-submit-btn">
            <i class="bi bi-check-lg me-1"></i>Submit
        </button>
        <% if (totalCount != null) { %>
        <span class="sl-total-badge"><i class="bi bi-people-fill me-1"></i><%= totalCount %> student<%= totalCount != 1 ? "s" : "" %></span>
        <% } %>
    </form>

    <!-- Results -->
    <%
        if (grouped == null || grouped.isEmpty()) {
    %>
    <hr class="sl-sup-divider">
    <div class="sl-empty">
        <i class="bi bi-people"></i>
        No students found<% if (selectedSemester != null) { %> for semester <strong><%= selectedSemester %></strong><% } %>.
    </div>
    <%
        } else {
            int globalRow = 1;
            int supIdx    = 1;
            for (Entry<String, List<Project>> entry : grouped.entrySet()) {
                String          supName  = entry.getKey();
                List<Project>   projects = entry.getValue();
    %>
    <hr class="sl-sup-divider">
    <!-- Supervisor heading -->
    <div class="sl-sup-heading">
        <span class="sl-sup-num"><%= supIdx %>.</span>
        <i class="bi bi-person-badge text-primary" style="font-size:.9rem;"></i>
        <%= supName %>
        <span class="badge bg-secondary ms-1" style="font-size:.65rem;font-weight:600;"><%= projects.size() %></span>
    </div>

    <!-- Students table for this supervisor -->
    <div class="table-responsive">
        <table class="sl-table">
            <thead>
                <tr>
                    <th style="width:54px;">No.</th>
                    <th style="width:100px;">Matrik</th>
                    <th>Nama Pelajar</th>
                    <th style="width:130px;">Department</th>
                    <th>Tajuk Projek</th>
                </tr>
            </thead>
            <tbody>
            <%
                int localRow = 1;
                for (Project p : projects) {
                    boolean hasProject = p.getId() > 0 && p.getTitle() != null && !p.getTitle().isEmpty()
                                         && !p.getTitle().startsWith("(No project");
            %>
                <tr>
                    <td class="sl-td-no"><%= localRow %>/<%= globalRow %></td>
                    <td class="sl-td-matrik">
                        <% if (hasProject) { %>
                        <a href="<%= ctx %>/coordinator/project?id=<%= p.getId() %>"
                           title="View project"><%= p.getStudentUsername() != null ? p.getStudentUsername() : "—" %></a>
                        <% } else { %>
                        <span style="color:var(--rt-muted);font-size:.82rem;"><%= p.getStudentUsername() != null ? p.getStudentUsername() : "—" %></span>
                        <% } %>
                    </td>
                    <td class="sl-td-name"><%= p.getStudentName() != null ? p.getStudentName() : "—" %></td>
                    <td class="sl-td-course">
                        <%= p.getStudentDepartment() != null && !p.getStudentDepartment().isEmpty()
                            ? p.getStudentDepartment() : "—" %>
                    </td>
                    <td class="sl-td-title">
                        <% if (hasProject) { %>
                        <a href="<%= ctx %>/coordinator/project?id=<%= p.getId() %>"
                           title="<%= p.getTitle() %>"><%= p.getTitle() %></a>
                        <% } else { %>
                        <span class="sl-no-proj">Not added yet</span>
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
        }
    %>
</div>

<jsp:include page="/views/common/footer.jsp"/>

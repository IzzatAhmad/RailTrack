<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.model.DocumentType, com.railtrack.system.model.StudentDocument, com.railtrack.system.model.User, java.util.List, java.util.Map" %>
<%
    request.setAttribute("pageTitle", "Student Documents");
    User student = (User) request.getAttribute("student");
    List<DocumentType> documentTypes = (List<DocumentType>) request.getAttribute("documentTypes");
    Map<Integer, StudentDocument> studentDocs = (Map<Integer, StudentDocument>) request.getAttribute("studentDocs");
    String ctx = request.getContextPath();
%>
<jsp:include page="/views/common/header.jsp"/>

<!-- Navigation / Breadcrumbs -->
<nav style="font-size:.82rem;margin-bottom:1.25rem;">
    <a href="<%= ctx %>/supervisor/students" style="color:var(--rt-primary);text-decoration:none;">
        <i class="bi bi-people me-1"></i>My Students
    </a>
    <span class="mx-1" style="color:var(--rt-muted);">/</span>
    <span style="color:var(--rt-muted);">Student Documents</span>
</nav>

<!-- Header Card -->
<div class="rt-card p-4 mb-4">
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div>
            <h4 class="fw-bold mb-3 d-flex align-items-center">
                <i class="bi bi-folder2-open text-primary me-2"></i> 
                Documents - <%= student.getUsername() %>
            </h4>
            
            <div class="row g-3" style="font-size: .88rem;">
                <div class="col-auto">
                    <span class="text-muted">Name:</span> 
                    <strong class="text-dark ms-1"><%= student.getFullName() %></strong>
                </div>
                <div class="col-auto ms-sm-4">
                    <span class="text-muted">Email:</span> 
                    <span class="text-dark ms-1"><%= student.getEmail() %></span>
                </div>
            </div>
        </div>
        <a href="<%= ctx %>/supervisor/students" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left me-1"></i>Back to List
        </a>
    </div>
</div>

<!-- Documents Grid Card Layout (Read Only) -->
<div class="rt-card p-4">
    <div class="row g-3">
        <% if (documentTypes == null || documentTypes.isEmpty()) { %>
            <div class="col-12 text-center text-muted py-5">
                <i class="bi bi-folder-x" style="font-size: 2.5rem;"></i>
                <p class="mt-2 fw-semibold">No document requirements defined.</p>
            </div>
        <% } else {
            for (DocumentType type : documentTypes) {
                StudentDocument doc = studentDocs != null ? studentDocs.get(type.getId()) : null;
                boolean isUploaded = doc != null;
        %>
            <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
                <div class="rt-card text-center p-3 h-100 d-flex flex-column align-items-center justify-content-between" 
                     style="border: 1px solid #f1f3f7; border-radius: 12px; min-height: 150px; background-color: #fafbfc;">
                    
                    <!-- Static Pill Button Header -->
                    <div class="w-100 py-2 static-doc-pill fw-bold text-center">
                        <%= type.getName() %>
                    </div>

                    <!-- Icon Slot (PDF or Dash) -->
                    <div class="mt-3 d-flex flex-column align-items-center justify-content-center flex-grow-1">
                        <% if (isUploaded) { %>
                            <a href="<%= ctx %>/file/document/<%= doc.getId() %>" 
                               target="_blank" 
                               title="Download <%= doc.getFileName() %>" 
                               class="d-flex align-items-center justify-content-center text-decoration-none">
                                <i class="bi bi-file-earmark-pdf-fill text-danger" style="font-size: 2.2rem; cursor: pointer; transition: transform 0.1s;"></i>
                            </a>
                            <div class="text-muted text-truncate mt-1 px-2" style="font-size: 0.68rem; max-width: 130px;" title="<%= doc.getFileName() %>">
                                <%= doc.getFileName() %>
                            </div>
                            <div class="text-muted mt-1" style="font-size: 0.6rem;">
                                Uploaded: <%= doc.getUploadedAt().format(java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy")) %>
                            </div>
                        <% } else { %>
                            <span class="text-muted fw-bold" style="font-size: 1.5rem;">-</span>
                        <% } %>
                    </div>
                </div>
            </div>
        <% } } %>
    </div>
</div>

<% 
    int[] chapterProgress = (int[]) request.getAttribute("chapterProgress"); 
    com.railtrack.system.model.Project activeProject = (com.railtrack.system.model.Project) request.getAttribute("activeProject");
%>

<% if (activeProject != null && chapterProgress != null) { %>
<!-- Chapter Progress Editor -->
<div class="row g-4 mt-2">
    <!-- Chart Preview -->
    <div class="col-12 col-xl-7">
        <div class="rt-card h-100 p-4">
            <h5 class="fw-bold mb-3 text-dark">Chapter Breakdown Preview</h5>
            <div id="chapterProgressChart" style="width: 100%; height: 250px;"></div>
            <div class="text-center small fw-semibold mt-1 text-muted">Thesis Progress By Chapter</div>
        </div>
    </div>
    
    <!-- Sliders Editor -->
    <div class="col-12 col-xl-5">
        <div class="rt-card h-100 p-4">
            <h5 class="fw-bold mb-4 text-dark d-flex align-items-center">
                <i class="bi bi-sliders me-2 text-primary"></i> Edit Progress
            </h5>
            <form action="<%= ctx %>/supervisor/student/documents" method="POST" id="progressForm">
                <input type="hidden" name="action" value="updateChapterProgress">
                <input type="hidden" name="projectId" value="<%= activeProject.getId() %>">
                <input type="hidden" name="studentId" value="<%= student.getId() %>">
                
                <div class="d-flex flex-column gap-3">
                    <% String[] labels = {"Abstract", "Ch1", "Ch2", "Ch3", "Ch4", "Ch5", "Ch6", "Ch7"};
                       for (int i = 0; i < 8; i++) { %>
                    <div class="row align-items-center">
                        <div class="col-3 text-end fw-semibold text-muted" style="font-size: 0.85rem;"><%= labels[i] %></div>
                        <div class="col-7">
                            <input type="range" class="form-range custom-slider" min="0" max="5" step="1" 
                                   name="ch<%= i %>" id="slider_<%= i %>" value="<%= chapterProgress[i] %>"
                                   oninput="updatePreview()">
                        </div>
                        <div class="col-2 text-start fw-bold" id="val_<%= i %>"><%= chapterProgress[i] %></div>
                    </div>
                    <% } %>
                </div>
                
                <hr class="my-4">
                <button type="submit" class="btn btn-primary w-100 fw-bold shadow-sm" style="border-radius: 8px; padding: 0.6rem;">
                    <i class="bi bi-save2 me-1"></i> Save Changes
                </button>
            </form>
        </div>
    </div>
</div>

<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script type="text/javascript">
    google.charts.load('current', {'packages':['corechart']});
    google.charts.setOnLoadCallback(drawChart);

    var chart;
    var barOptions = {
        legend: { position: 'none' },
        bar: { groupWidth: '70%' },
        chartArea: { width: '85%', height: '70%' },
        vAxis: { minValue: 0, maxValue: 5, ticks: [0,1,2,3,4,5] },
        hAxis: { slantedText: true, slantedTextAngle: 30, textStyle: { fontSize: 10 } }
    };

    function drawChart() {
        chart = new google.visualization.ColumnChart(document.getElementById('chapterProgressChart'));
        updatePreview(); // initial draw
    }

    function updatePreview() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Chapter');
        data.addColumn('number', 'Value');
        data.addColumn({type: 'string', role: 'style'});

        var labels = ["Abstract", "Ch1", "Ch2", "Ch3", "Ch4", "Ch5", "Ch6", "Ch7"];
        for(var i=0; i<8; i++) {
            var val = parseInt(document.getElementById('slider_' + i).value);
            document.getElementById('val_' + i).innerText = val;
            data.addRow([labels[i], val, 'color: #8fb8d5']);
        }
        
        if (chart) {
            chart.draw(data, barOptions);
        }
    }
    window.addEventListener('resize', updatePreview);
</script>
<% } %>

<style>
/* Static Pill Header matching student style but disabled hover effects */
.static-doc-pill {
    border: 2.2px solid #6b7a99;
    border-radius: 22px;
    color: #6b7a99;
    background: transparent;
    font-weight: 700;
    font-size: 0.76rem;
    letter-spacing: 0.04em;
    text-transform: uppercase;
}
.bi-file-earmark-pdf-fill:hover {
    transform: scale(1.1);
}
.custom-slider::-webkit-slider-thumb {
    background: var(--rt-primary);
}
</style>

<jsp:include page="/views/common/footer.jsp"/>

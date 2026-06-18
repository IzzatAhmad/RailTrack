// RailTrack Application Logic & View Templates
const RT_APP = {
    // Current application state
    state: {
        currentRole: 'GUEST', // GUEST, STUDENT, SUPERVISOR, COORDINATOR
        currentUser: null,
        activeProjectId: 1,
        activeStudentId: 1,
        dockerLogsTimer: null,
        dockerMetricsTimer: null,
        notifications: [
            { text: "Dr. Sarah Smith approved Milestone 2", time: "2 hours ago" },
            { text: "Container smart-attendance-postgre exceeded memory threshold", time: "1 day ago" }
        ]
    },

    // Initialize application
    init: function () {
        // Bind URL router
        window.addEventListener('hashchange', () => this.router());
        
        // Auto select role from hash if present or default GUEST
        this.parseInitialRole();
        
        // Render sitemap tree once
        this.renderHierarchyMenu();
        
        // Initial route
        this.router();
    },

    parseInitialRole: function() {
        const hash = window.location.hash;
        if (hash.includes('/student/')) {
            this.setRole('STUDENT', false);
        } else if (hash.includes('/supervisor/')) {
            this.setRole('SUPERVISOR', false);
        } else if (hash.includes('/coordinator/')) {
            this.setRole('COORDINATOR', false);
        } else {
            this.setRole('GUEST', false);
        }
    },

    // Sitemap definition dataset for System Hierarchical Menu
    sitemap: [
        {
            folderName: "Guest Portal",
            folderId: "folder-guest",
            pages: [
                { label: "Landing Home Page", url: "#/home", role: "GUEST" }
            ]
        },
        {
            folderName: "Student Space",
            folderId: "folder-student",
            pages: [
                { label: "Dashboard", url: "#/student/dashboard", role: "STUDENT" },
                { label: "Project Details (Alice)", url: "#/student/project/1", role: "STUDENT" },
                { label: "Weekly Logbooks", url: "#/student/logbook", role: "STUDENT" },
                { label: "Deliverables Upload", url: "#/student/documents", role: "STUDENT" },
                { label: "Resource Manuals", url: "#/student/materials", role: "STUDENT" },
                { label: "Assessment Rubrics", url: "#/student/rubrics", role: "STUDENT" }
            ]
        },
        {
            folderName: "Supervisor Space",
            folderId: "folder-supervisor",
            pages: [
                { label: "Supervisor Dashboard", url: "#/supervisor/dashboard", role: "SUPERVISOR" },
                { label: "Cohort Directory List", url: "#/supervisor/students", role: "SUPERVISOR" },
                { label: "Assess Project Work", url: "#/supervisor/project/1", role: "SUPERVISOR" },
                { label: "Logbook Review", url: "#/supervisor/logbook/2022-8374", role: "SUPERVISOR" },
                { label: "Deliverables Review", url: "#/supervisor/documents/2022-8374", role: "SUPERVISOR" },
                { label: "PITA Scorecard Form", url: "#/supervisor/pita/1", role: "SUPERVISOR" }
            ]
        },
        {
            folderName: "Coordinator Panel",
            folderId: "folder-coordinator",
            pages: [
                { label: "Dashboard Hub", url: "#/coordinator/dashboard", role: "COORDINATOR" },
                { label: "Account Directory", url: "#/coordinator/users", role: "COORDINATOR" },
                { label: "Allocations Matrix", url: "#/coordinator/projects", role: "COORDINATOR" },
                { label: "Supervisor Allocation", url: "#/coordinator/project/1", role: "COORDINATOR" },
                { label: "Dashboard Tiles Editor", url: "#/coordinator/menu", role: "COORDINATOR" },
                { label: "Docker Logs Monitor", url: "#/coordinator/docker", role: "COORDINATOR" },
                { label: "Deadline Rules Setup", url: "#/coordinator/documents", role: "COORDINATOR" }
            ]
        },
        {
            folderName: "Common Workspace",
            folderId: "folder-common",
            pages: [
                { label: "Profile Account Info", url: "#/profile", role: "STUDENT" }
            ]
        }
    ],

    renderHierarchyMenu: function() {
        const tree = document.getElementById('sb-hierarchy-tree');
        if (!tree) return;

        let html = '';
        this.sitemap.forEach(folder => {
            html += `
                <div class="tree-folder">
                    <div class="tree-folder-title" onclick="RT_APP.toggleFolder('${folder.folderId}')">
                        <i class="bi bi-chevron-down folder-arrow" id="arrow-${folder.folderId}"></i>
                        <i class="bi bi-folder-fill folder-icon" id="icon-${folder.folderId}"></i>
                        <span>${folder.folderName}</span>
                    </div>
                    <div class="tree-folder-content" id="${folder.folderId}">
                        ${folder.pages.map(p => `
                            <div class="tree-file">
                                <a href="javascript:void(0)" class="tree-file-link" onclick="RT_APP.hierarchyNavigate('${p.role}', '${p.url}')" id="tree-link-${p.url.replace(/\//g,'-').replace('#','')}" data-url="${p.url}">
                                    <i class="bi bi-file-earmark-text"></i>
                                    <span>${p.label}</span>
                                </a>
                            </div>
                        `).join('')}
                    </div>
                </div>
            `;
        });
        tree.innerHTML = html;
    },

    toggleHierarchyMenu: function() {
        const tree = document.getElementById('sb-hierarchy-tree');
        const arrow = document.getElementById('hierarchy-toggle-arrow');
        if (!tree) return;
        if (tree.classList.contains('collapsed')) {
            tree.classList.remove('collapsed');
            if (arrow) arrow.innerHTML = '<i class="bi bi-chevron-down"></i>';
        } else {
            tree.classList.add('collapsed');
            if (arrow) arrow.innerHTML = '<i class="bi bi-chevron-right"></i>';
        }
    },

    toggleFolder: function(folderId, forceExpand) {
        const content = document.getElementById(folderId);
        if (!content) return;
        const arrow = document.getElementById(`arrow-${folderId}`);
        const icon = document.getElementById(`icon-${folderId}`);
        
        const shouldExpand = (forceExpand !== undefined) ? forceExpand : content.classList.contains('collapsed');
        
        if (shouldExpand) {
            content.classList.remove('collapsed');
            if (arrow) arrow.className = 'bi bi-chevron-down folder-arrow';
            if (icon) icon.className = 'bi bi-folder-open-fill folder-icon';
        } else {
            content.classList.add('collapsed');
            if (arrow) arrow.className = 'bi bi-chevron-right folder-arrow';
            if (icon) icon.className = 'bi bi-folder-fill folder-icon';
        }
    },

    hierarchyNavigate: function(role, url) {
        this.setRole(role, false);
        window.location.hash = url;
    },

    highlightHierarchyActiveNode: function() {
        const hash = window.location.hash || '#/home';
        document.querySelectorAll('.tree-file-link').forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('data-url') === hash) {
                link.classList.add('active');
                
                // Make sure parent is expanded
                const parentFolder = link.closest('.tree-folder-content');
                if (parentFolder && parentFolder.classList.contains('collapsed')) {
                    this.toggleFolder(parentFolder.id, true);
                }
            }
        });
    },

    // Switch Role Simulation
    setRole: function (role, redirect = true) {
        this.state.currentRole = role;
        
        // Set user simulation based on role
        if (role === 'GUEST') {
            this.state.currentUser = null;
            if (redirect) window.location.hash = '#/home';
        } else {
            this.state.currentUser = RT_MOCK_DATA.users.find(u => u.role === role);
            if (redirect) {
                window.location.hash = `#/${role.toLowerCase()}/dashboard`;
            }
        }

        // Update sidebar user details
        this.updateSidebarUser();

        // Toggle active state in swapper toolbar
        document.querySelectorAll('.swapper-btn').forEach(btn => btn.classList.remove('active'));
        const activeBtn = document.getElementById(`btn-${role.toLowerCase()}`);
        if (activeBtn) activeBtn.classList.add('active');

        // Update badge
        const badge = document.getElementById('current-role-badge');
        if (badge) {
            badge.className = `role-badge-indicator role-${role.toLowerCase()}`;
            badge.innerText = role;
        }

        this.clearTimers();
    },

    clearTimers: function() {
        if (this.state.dockerLogsTimer) clearInterval(this.state.dockerLogsTimer);
        if (this.state.dockerMetricsTimer) clearInterval(this.state.dockerMetricsTimer);
    },

    updateSidebarUser: function () {
        const avatarEl = document.getElementById('sb-user-avatar');
        const nameEl = document.getElementById('sb-user-name');
        const roleEl = document.getElementById('sb-user-role');
        
        if (!avatarEl || !nameEl || !roleEl) return;
        
        // Reset role styles
        avatarEl.className = 'sidebar-user-avatar';
        
        if (!this.state.currentUser) {
            avatarEl.innerText = '?';
            avatarEl.classList.add('role-guest');
            nameEl.innerText = 'Guest User';
            roleEl.innerText = 'Guest';
        } else {
            avatarEl.innerText = this.state.currentUser.avatar;
            avatarEl.classList.add(`role-${this.state.currentUser.role.toLowerCase()}`);
            nameEl.innerText = this.state.currentUser.fullName;
            roleEl.innerText = this.state.currentUser.role;
        }
    },

    logout: function () {
        this.setRole('GUEST');
    },

    loginAs: function (userId) {
        const user = RT_MOCK_DATA.users.find(u => u.id === userId);
        if (user) {
            this.closeModal('login-modal');
            this.setRole(user.role);
        }
    },

    // Sidebar Navigation methods deprecated
    renderSidebarNavigation: function () {
        // Replaced by sitemap hierarchy tree menu
    },

    updateSidebarActiveItem: function (routeId) {
        // Replaced by highlightHierarchyActiveNode
    },

    // Client Side Hash Router
    router: function () {
        const hash = window.location.hash || '#/home';
        const container = document.getElementById('view-container');
        this.clearTimers();

        // Highlight tree map active node
        this.highlightHierarchyActiveNode();

        // Guest Landing
        if (hash === '#/home' || hash === '#/') {
            this.setRole('GUEST', false);
            container.innerHTML = this.templates.landing();
            document.getElementById('page-title-display').innerText = 'RailTrack';
            return;
        }

        // Auth Gate: If GUEST but trying to access member area, show home
        if (this.state.currentRole === 'GUEST' && hash !== '#/home') {
            window.location.hash = '#/home';
            return;
        }

        // Profile Detail
        if (hash === '#/profile') {
            container.innerHTML = this.templates.profile();
            this.updateSidebarActiveItem('profile');
            document.getElementById('page-title-display').innerText = 'User Settings';
            return;
        }

        // STUDENT PATHS
        if (hash === '#/student/dashboard') {
            container.innerHTML = this.templates.studentDashboard();
            this.updateSidebarActiveItem('student-dashboard');
            document.getElementById('page-title-display').innerText = 'Student Dashboard';
        } else if (hash.startsWith('#/student/project/')) {
            const id = parseInt(hash.split('/').pop());
            this.state.activeProjectId = id;
            container.innerHTML = this.templates.studentProjectDetail(id);
            this.updateSidebarActiveItem('student-project');
            document.getElementById('page-title-display').innerText = 'Project Workspace';
        } else if (hash === '#/student/logbook') {
            container.innerHTML = this.templates.studentLogbook();
            this.updateSidebarActiveItem('student-logbook');
            document.getElementById('page-title-display').innerText = 'Logbook Journal';
        } else if (hash === '#/student/documents') {
            container.innerHTML = this.templates.studentDocuments();
            this.updateSidebarActiveItem('student-documents');
            document.getElementById('page-title-display').innerText = 'Deliverable Uploads';
        } else if (hash === '#/student/materials') {
            container.innerHTML = this.templates.studentMaterials();
            this.updateSidebarActiveItem('student-materials');
            document.getElementById('page-title-display').innerText = 'Resources & Templates';
        } else if (hash === '#/student/rubrics') {
            container.innerHTML = this.templates.studentRubrics();
            this.updateSidebarActiveItem('student-rubrics');
            document.getElementById('page-title-display').innerText = 'Grading Rubrics';
        }

        // SUPERVISOR PATHS
        else if (hash === '#/supervisor/dashboard') {
            container.innerHTML = this.templates.supervisorDashboard();
            this.updateSidebarActiveItem('supervisor-dashboard');
            document.getElementById('page-title-display').innerText = 'Supervisor Workspace';
        } else if (hash === '#/supervisor/students') {
            container.innerHTML = this.templates.supervisorStudents();
            this.updateSidebarActiveItem('supervisor-students');
            document.getElementById('page-title-display').innerText = 'Supervised Students';
        } else if (hash.startsWith('#/supervisor/project/')) {
            const id = parseInt(hash.split('/').pop());
            this.state.activeProjectId = id;
            container.innerHTML = this.templates.supervisorProjectDetail(id);
            this.updateSidebarActiveItem('supervisor-project');
            document.getElementById('page-title-display').innerText = 'Assess Project Work';
        } else if (hash.startsWith('#/supervisor/logbook/')) {
            const studentId = hash.split('/').pop();
            container.innerHTML = this.templates.supervisorLogbookReview(studentId);
            this.updateSidebarActiveItem('supervisor-students');
            document.getElementById('page-title-display').innerText = 'Logbook Evaluation';
        } else if (hash.startsWith('#/supervisor/documents/')) {
            const studentId = hash.split('/').pop();
            container.innerHTML = this.templates.supervisorDocumentReview(studentId);
            this.updateSidebarActiveItem('supervisor-students');
            document.getElementById('page-title-display').innerText = 'Deliverable Assessment';
        } else if (hash.startsWith('#/supervisor/pita/')) {
            const id = parseInt(hash.split('/').pop());
            container.innerHTML = this.templates.supervisorPitaForm(id);
            this.updateSidebarActiveItem('supervisor-students');
            document.getElementById('page-title-display').innerText = 'PITA Assessment Grading Form';
        }

        // COORDINATOR PATHS
        else if (hash === '#/coordinator/dashboard') {
            container.innerHTML = this.templates.coordinatorDashboard();
            this.updateSidebarActiveItem('coordinator-dashboard');
            document.getElementById('page-title-display').innerText = 'Coordinator Command Center';
            this.startDockerMetricsSimulation();
        } else if (hash === '#/coordinator/users') {
            container.innerHTML = this.templates.coordinatorUsers();
            this.updateSidebarActiveItem('coordinator-users');
            document.getElementById('page-title-display').innerText = 'Cohort Users Management';
        } else if (hash === '#/coordinator/projects') {
            container.innerHTML = this.templates.coordinatorProjects();
            this.updateSidebarActiveItem('coordinator-projects');
            document.getElementById('page-title-display').innerText = 'Projects Index Allocation';
        } else if (hash.startsWith('#/coordinator/project/')) {
            const id = parseInt(hash.split('/').pop());
            container.innerHTML = this.templates.coordinatorProjectDetail(id);
            this.updateSidebarActiveItem('coordinator-projects');
            document.getElementById('page-title-display').innerText = 'Allocate Supervisor';
        } else if (hash === '#/coordinator/menu') {
            container.innerHTML = this.templates.coordinatorMenu();
            this.updateSidebarActiveItem('coordinator-menu');
            document.getElementById('page-title-display').innerText = 'Student Dashboard Tiles Editor';
        } else if (hash === '#/coordinator/docker') {
            container.innerHTML = this.templates.coordinatorDocker();
            this.updateSidebarActiveItem('coordinator-docker');
            document.getElementById('page-title-display').innerText = 'Docker Container Registry Monitor';
            this.startDockerTerminalSimulation();
        } else if (hash === '#/coordinator/documents') {
            container.innerHTML = this.templates.coordinatorDocuments();
            this.updateSidebarActiveItem('coordinator-documents');
            document.getElementById('page-title-display').innerText = 'Deadline Submission Rules';
        }
        
    },

    // Global Modal Utilities
    openModal: function (id) {
        document.getElementById(id).classList.add('open');
    },

    closeModal: function (id) {
        document.getElementById(id).classList.remove('open');
    },

    // Interactive Actions & Form Submissions Simulator
    mockRepoAutofill: function(val) {
        const loader = document.getElementById('repo-loader');
        const feedback = document.getElementById('repo-feedback');
        
        if (!val || val.length < 10) {
            feedback.style.display = 'none';
            return;
        }

        loader.style.display = 'block';
        feedback.style.display = 'none';

        setTimeout(() => {
            loader.style.display = 'none';
            feedback.style.display = 'block';
            feedback.className = "text-success";
            feedback.innerHTML = `<i class="bi bi-check-circle-fill"></i> Repository connected: Default branch "main".`;
            
            // Auto fill title and description mockup
            const repoParts = val.split('/');
            const repoName = repoParts[repoParts.length - 1] || 'My Project';
            document.getElementById('new-proj-title').value = repoName.replace(/[-_]/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
            document.getElementById('new-proj-desc').value = `Docker container layout configured for ${repoName} integration. Ready for staging allocation.`;
        }, 1200);
    },

    submitProjectAction: function(e) {
        e.preventDefault();
        const title = document.getElementById('new-proj-title').value;
        const desc = document.getElementById('new-proj-desc').value;
        const repo = document.getElementById('new-proj-repo').value;
        
        const newProj = {
            id: RT_MOCK_DATA.projects.length + 1,
            title: title,
            description: desc,
            repoUrl: repo,
            branch: document.getElementById('new-proj-branch').value,
            status: 'PENDING',
            dockerStatus: 'none',
            runningLimitSeconds: 7200,
            overallGrade: null,
            semester: '2026/2027-1',
            studentId: '2022-8374',
            studentName: 'Alice Johnson',
            supervisorId: null,
            supervisorName: null,
            pita1Evaluators: [],
            pita2Evaluators: []
        };

        RT_MOCK_DATA.projects.push(newProj);
        this.closeModal('submit-project-modal');
        this.showFlash('Project Submitted Successfully! Awaiting Coordinator allocations.', 'success');
        
        // Refresh views
        this.router();
    },

    openAssignSupervisor: function(projId) {
        const proj = RT_MOCK_DATA.projects.find(p => p.id === projId);
        if (!proj) return;
        
        document.getElementById('assign-proj-id').value = projId;
        document.getElementById('assign-proj-title').innerHTML = `Project: <strong>${proj.title}</strong>`;
        
        // Load supervisors select options
        const select = document.getElementById('assign-sv-select');
        const supervisors = RT_MOCK_DATA.users.filter(u => u.role === 'SUPERVISOR');
        select.innerHTML = '<option value="">— Select Supervisor —</option>' + 
            supervisors.map(sv => `<option value="${sv.id}">${sv.fullName} (${sv.email})</option>`).join('');

        this.openModal('assign-supervisor-modal');
    },

    assignSupervisorAction: function(e) {
        e.preventDefault();
        const projId = parseInt(document.getElementById('assign-proj-id').value);
        const svId = parseInt(document.getElementById('assign-sv-select').value);
        const note = document.getElementById('assign-sv-note').value;

        const proj = RT_MOCK_DATA.projects.find(p => p.id === projId);
        const sv = RT_MOCK_DATA.users.find(u => u.id === svId);

        if (proj && sv) {
            proj.supervisorId = sv.id;
            proj.supervisorName = sv.fullName;
            proj.status = 'ACTIVE';
            
            this.closeModal('assign-supervisor-modal');
            this.showFlash(`Assigned ${sv.fullName} to project ${proj.title}.`, 'success');
            
            this.router();
        }
    },

    autoAssignCohortAction: function() {
        if (!confirm('Automatically assign Dr. Sarah Smith and Dr. James Anderson using CGPA Load Balancing?')) return;
        
        let count = 0;
        RT_MOCK_DATA.projects.forEach(p => {
            if (!p.supervisorId) {
                p.supervisorId = 3;
                p.supervisorName = 'Dr. Sarah Smith';
                p.status = 'ACTIVE';
                count++;
            }
        });

        this.showFlash(`Auto-assigned ${count} project(s) load balanced successfully.`, 'success');
        this.router();
    },

    importUsersAction: function(e) {
        e.preventDefault();
        
        // Mock add an extra student
        const count = 3;
        const newUsers = [
            { id: 6, role: 'STUDENT', username: 'student3', fullName: 'Charlie Davis', email: 'charlie.d@university.edu', avatar: 'C', studentId: '2022-8390' },
            { id: 7, role: 'STUDENT', username: 'student4', fullName: 'Diana Evans', email: 'diana.e@university.edu', avatar: 'D', studentId: '2022-8411' }
        ];

        newUsers.forEach(u => {
            if (!RT_MOCK_DATA.users.some(ex => ex.username === u.username)) {
                RT_MOCK_DATA.users.push(u);
            }
        });

        this.closeModal('import-users-modal');
        this.showFlash(`Successfully uploaded list. Registered 2 new students into current semester.`, 'success');
        this.router();
    },

    addNewTileAction: function(e) {
        e.preventDefault();
        const label = document.getElementById('tile-lbl').value;
        const url = document.getElementById('tile-url').value;
        const icon = document.getElementById('tile-icon').value;
        const color = document.getElementById('tile-color').value;

        RT_MOCK_DATA.menuItems.push({
            id: RT_MOCK_DATA.menuItems.length + 1,
            label: label,
            url: url,
            icon: icon,
            iconColor: color
        });

        this.showFlash(`Quick access tile "${label}" created. Active on student dashboard.`, 'success');
        this.router();
    },

    addEvaluatorAction: function(e, stage, projId) {
        e.preventDefault();
        const select = e.target.querySelector('select');
        const evId = parseInt(select.value);
        if (!evId) return;

        const proj = RT_MOCK_DATA.projects.find(p => p.id === projId);
        if (proj) {
            const targetArray = stage === 'PITA1' ? proj.pita1Evaluators : proj.pita2Evaluators;
            if (!targetArray.includes(evId)) {
                targetArray.push(evId);
                this.showFlash('Evaluator assigned successfully.', 'success');
                this.router();
            }
        }
    },

    removeEvaluatorAction: function(stage, projId, evId) {
        const proj = RT_MOCK_DATA.projects.find(p => p.id === projId);
        if (proj) {
            if (stage === 'PITA1') {
                proj.pita1Evaluators = proj.pita1Evaluators.filter(id => id !== evId);
            } else {
                proj.pita2Evaluators = proj.pita2Evaluators.filter(id => id !== evId);
            }
            this.showFlash('Evaluator assignment removed.', 'warning');
            this.router();
        }
    },

    toggleDockerAction: function(projId) {
        const proj = RT_MOCK_DATA.projects.find(p => p.id === projId);
        if (!proj) return;

        if (proj.dockerStatus === 'running') {
            proj.dockerStatus = 'stopped';
            this.showFlash(`Staged container stopped successfully.`, 'info');
        } else {
            proj.dockerStatus = 'running';
            this.showFlash(`Docker container launched. Initializing node cluster...`, 'success');
        }
        
        // Log log history
        RT_MOCK_DATA.deployLogs.unshift({
            projectId: projId,
            action: proj.dockerStatus === 'running' ? 'START' : 'STOP',
            outcome: 'success',
            performedByName: this.state.currentUser ? this.state.currentUser.fullName : 'System',
            performedAt: new Date().toISOString().replace('Z','')
        });

        this.router();
    },

    submitFeedbackAction: function(e, projId) {
        e.preventDefault();
        const content = e.target.querySelector('textarea').value;
        const type = e.target.querySelector('select').value;
        
        RT_MOCK_DATA.feedbacks.unshift({
            projectId: projId,
            authorName: this.state.currentUser.fullName,
            type: type,
            content: content,
            createdAt: new Date().toISOString().split('T')[0]
        });

        this.showFlash('Feedback posted successfully.', 'success');
        this.router();
    },

    gradeMilestoneAction: function(projId, milestoneNo, status, score) {
        const m = RT_MOCK_DATA.milestones.find(ms => ms.projectId === projId && ms.milestoneNo === milestoneNo);
        if (m) {
            m.status = status;
            if (score) m.grade = parseFloat(score);
            
            // Re-calculate project grade
            const proj = RT_MOCK_DATA.projects.find(p => p.id === projId);
            if (proj) {
                const completedMs = RT_MOCK_DATA.milestones.filter(ms => ms.projectId === projId && ms.status === 'APPROVED');
                let totalScore = 0;
                let totalWeight = 0;
                completedMs.forEach(ms => {
                    if (ms.grade) {
                        totalScore += ms.grade * (ms.weight / 100);
                        totalWeight += ms.weight;
                    }
                });
                if (totalWeight > 0) {
                    proj.overallGrade = (totalScore / totalWeight) * 100;
                }
            }

            this.showFlash(`Milestone ${milestoneNo} evaluated: ${status}.`, 'success');
            this.router();
        }
    },

    submitLogbookEntryAction: function(e) {
        e.preventDefault();
        const desc = document.getElementById('log-desc').value;
        const hours = parseInt(document.getElementById('log-hours').value);
        const week = RT_MOCK_DATA.logbooks.length + 1;

        RT_MOCK_DATA.logbooks.push({
            projectId: 1,
            week: week,
            hours: hours,
            description: desc,
            status: 'SUBMITTED',
            feedback: ''
        });

        this.showFlash(`Week ${week} log entry submitted for evaluation.`, 'success');
        this.router();
    },

    approveLogbookEntryAction: function(week) {
        const log = RT_MOCK_DATA.logbooks.find(l => l.projectId === 1 && l.week === week);
        if (log) {
            log.status = 'APPROVED';
            this.showFlash(`Week ${week} log approved.`, 'success');
            this.router();
        }
    },

    gradeDocumentAction: function(e, docType) {
        e.preventDefault();
        const grade = parseInt(e.target.querySelector('input').value);
        const doc = RT_MOCK_DATA.documents.find(d => d.projectId === 1 && d.docType === docType);
        if (doc) {
            doc.grade = grade;
            doc.status = 'APPROVED';
            this.showFlash(`${docType} deliverable grade recorded.`, 'success');
            this.router();
        }
    },

    // PITA Rubrics score calculator
    calculatePitaScore: function() {
        const criteria1 = parseInt(document.querySelector('input[name="crit-1"]:checked')?.value || 0);
        const criteria2 = parseInt(document.querySelector('input[name="crit-2"]:checked')?.value || 0);
        const criteria3 = parseInt(document.querySelector('input[name="crit-3"]:checked')?.value || 0);
        const criteria4 = parseInt(document.querySelector('input[name="crit-4"]:checked')?.value || 0);
        
        const sum = criteria1 + criteria2 + criteria3 + criteria4;
        const totalPercentage = (sum / 20) * 100; // Assuming max 5 points per 4 criteria

        document.getElementById('pita-score-sum').innerText = `${sum}/20`;
        document.getElementById('pita-score-percent').innerText = `${totalPercentage.toFixed(1)}%`;
        
        return totalPercentage;
    },

    submitPitaAction: function(e, projId) {
        e.preventDefault();
        const pct = this.calculatePitaScore();
        
        // Update document PITA status
        const doc = RT_MOCK_DATA.documents.find(d => d.projectId === projId && d.docType === 'PITA-01');
        if (doc) {
            doc.grade = pct;
            doc.status = 'APPROVED';
        }

        // Auto approve milestone PITA
        const m = RT_MOCK_DATA.milestones.find(ms => ms.projectId === projId && ms.milestoneNo === 3);
        if (m) {
            m.status = 'APPROVED';
            m.grade = pct;
        }

        this.showFlash(`PITA Evaluation Form Submitted. Grade recorded: ${pct.toFixed(1)}%`, 'success');
        window.location.hash = '#/supervisor/students';
    },

    // Live terminal simulator for Docker
    startDockerTerminalSimulation: function () {
        const term = document.getElementById('term-log-stream');
        if (!term) return;

        const logs = [
            "2026-06-10T09:12:43 [INFO] Initializing RailTrack deployment system...",
            "2026-06-10T09:12:44 [INFO] Pulling postgres:15-alpine image from registry...",
            "2026-06-10T09:12:48 [SUCCESS] postgres image download complete. Hash: sha256:8bfa...",
            "2026-06-10T09:12:49 [INFO] Creating staging network bridge rt-net-1...",
            "2026-06-10T09:12:50 [INFO] Running postgres container smart-attendance-postgre on port 5432...",
            "2026-06-10T09:12:52 [INFO] Compiling student Spring Boot JAR package...",
            "2026-06-10T09:12:59 [SUCCESS] Build completed in 7s. Target file: app-root.jar",
            "2026-06-10T09:13:00 [INFO] Launching student container smart-attendance-web on port 8080...",
            "2026-06-10T09:13:02 [INFO] Connection established to postgres DB database: 'railtrack_db'",
            "2026-06-10T09:13:04 [INFO] Server started: running on http://10.0.12.84:8080",
            "2026-06-10T09:13:10 [INFO] FaceNet engine models loaded in memory. Cache set.",
            "2026-06-10T09:15:30 [WARN] Heap memory consumption at 82%. Triggering garbage collector..."
        ];

        let idx = 0;
        term.innerHTML = '';
        
        const printLine = () => {
            if (idx >= logs.length) idx = 0;
            const text = logs[idx++];
            const line = document.createElement('div');
            line.className = 'terminal-line';
            
            if (text.includes('[INFO]')) {
                line.innerHTML = `<span class="terminal-line info">${text}</span>`;
            } else if (text.includes('[SUCCESS]')) {
                line.innerHTML = `<span class="terminal-line" style="color: var(--success);">${text}</span>`;
            } else if (text.includes('[WARN]')) {
                line.innerHTML = `<span class="terminal-line" style="color: var(--warning);">${text}</span>`;
            } else {
                line.innerHTML = `<span>${text}</span>`;
            }
            term.appendChild(line);
            term.scrollTop = term.scrollHeight;
        };

        // Render first 5 lines immediately
        for (let i = 0; i < 6; i++) {
            printLine();
        }

        // Stream next lines
        this.state.dockerLogsTimer = setInterval(printLine, 1500);
    },

    // CPU / Memory active meter simulation
    startDockerMetricsSimulation: function() {
        const elements = [
            { id: 'cpu-bar', labelId: 'cpu-lbl', limit: 80 },
            { id: 'ram-bar', labelId: 'ram-lbl', limit: 95 },
            { id: 'disk-bar', labelId: 'disk-lbl', limit: 40 }
        ];

        const updateMetrics = () => {
            elements.forEach(el => {
                const dom = document.getElementById(el.id);
                const lbl = document.getElementById(el.labelId);
                if (!dom || !lbl) return;

                const val = Math.floor(Math.random() * (el.limit - 20) + 20);
                dom.style.width = `${val}%`;
                lbl.innerText = `${val}%`;
                
                // Color thresholds
                dom.className = 'chart-bar-fill';
                if (val > 80) dom.classList.add('danger');
                else if (val > 55) dom.classList.add('warning');
                else dom.classList.add('success');
            });
        };

        updateMetrics();
        this.state.dockerMetricsTimer = setInterval(updateMetrics, 3000);
    },

    // Table search filters
    filterProjectsTable: function(query, status, assign) {
        const rows = document.querySelectorAll('#projectsTable tbody tr');
        let visible = 0;
        
        rows.forEach(row => {
            const title = row.getAttribute('data-title') || '';
            const repo = row.getAttribute('data-repo') || '';
            const student = row.getAttribute('data-student') || '';
            const sv = row.getAttribute('data-supervisor') || '';
            const rstatus = row.getAttribute('data-status') || '';
            const rassign = row.getAttribute('data-assigned') || '';

            const mQuery = !query || title.includes(query) || repo.includes(query) || student.includes(query) || sv.includes(query);
            const mStatus = !status || rstatus === status;
            const mAssign = !assign || rassign === assign;

            if (mQuery && mStatus && mAssign) {
                row.style.display = '';
                visible++;
            } else {
                row.style.display = 'none';
            }
        });

        const counter = document.getElementById('visibleCount');
        if (counter) counter.innerText = visible;
        
        const noRes = document.getElementById('noResults');
        if (noRes) noRes.style.display = visible === 0 ? 'block' : 'none';
    },

    // Flash notifications alerts
    showFlash: function (msg, type = 'info') {
        // Create alert box
        const div = document.createElement('div');
        div.className = `rt-alert rt-alert-${type}`;
        div.style.position = 'fixed';
        div.style.bottom = '20px';
        div.style.right = '20px';
        div.style.zIndex = '3000';
        div.style.boxShadow = 'var(--shadow-lg)';
        div.style.animation = 'modalIn 0.3s ease';
        
        const icons = {
            success: 'bi-check-circle-fill',
            error: 'bi-exclamation-circle-fill',
            warning: 'bi-exclamation-triangle-fill',
            info: 'bi-info-circle-fill'
        };

        div.innerHTML = `<i class="bi ${icons[type] || 'bi-info-circle-fill'}"></i> <span>${msg}</span>`;
        document.body.appendChild(div);

        setTimeout(() => {
            div.style.opacity = '0';
            div.style.transition = 'opacity 0.5s ease';
            setTimeout(() => div.remove(), 500);
        }, 3000);
    },

    showNotifications: function() {
        this.showFlash("No new notifications.", "info");
    }
};

// Link templates
RT_APP.templates = RT_TEMPLATES;

// Start APP
window.addEventListener('DOMContentLoaded', () => {
    RT_APP.init();
});

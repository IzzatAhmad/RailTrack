// RailTrack Grayscale Wireframe View Templates
const RT_TEMPLATES = {
    
    // ── GUEST / LANDING PAGE ──
    landing: function() {
        return `
            <div class="landing-shell">
                <div class="landing-hero" style="border-bottom: 3px solid var(--border-color); padding: 5rem 2rem;">
                    <div class="badge" style="background: var(--primary-light); color: var(--text-main); border: 1px solid var(--border-color); margin-bottom: 1.5rem; text-transform: uppercase;">
                        <i class="bi bi-train-front-fill me-1"></i> Cohort System Wireframe
                    </div>
                    <h1 style="font-size: 3rem; font-weight: 800; margin-bottom: 1.5rem; letter-spacing: -0.03em; line-height: 1.2;">
                        Manage Your <span style="text-decoration: underline; text-underline-offset: 4px;">Final Year Projects</span><br>Staging Registry Portal
                    </h1>
                    <p style="font-size: 1.1rem; color: var(--text-muted); max-width: 600px; margin: 0 auto 2.5rem; line-height: 1.6;">
                        A structural mockup outlining student workspaces, supervisor grading scorecards, and coordinator Docker registry controls. Fully interactive walkthrough.
                    </p>
                    <div style="display: flex; gap: 0.75rem; justify-content: center;">
                        <button class="btn btn-primary" style="padding: 0.75rem 2rem; font-size: 1rem;" onclick="RT_APP.openModal('login-modal')">
                            <i class="bi bi-box-arrow-in-right"></i> Sign In to Demo Roles
                        </button>
                        <a href="#/student/materials" class="btn btn-secondary" style="padding: 0.75rem 2rem; font-size: 1rem; border-color: var(--border-color);">
                            <i class="bi bi-file-earmark-text"></i> View Deliverables
                        </a>
                    </div>
                </div>

                <div class="landing-section" style="background: white; border-bottom: 2px solid var(--border-color);">
                    <div style="text-align: center; margin-bottom: 3.5rem;">
                        <h2 style="font-size: 1.75rem; font-weight: 800; margin-bottom: 0.5rem; text-transform: uppercase; letter-spacing: 0.05em;">Core System Modules</h2>
                        <p style="color: var(--text-muted); max-width: 500px; margin: 0 auto; font-size: 0.88rem;">Key functional workflows mapped for staging and presentation review.</p>
                    </div>

                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 2rem; max-width: 1200px; margin: 0 auto;">
                        <div class="rt-card" style="margin-bottom: 0;">
                            <div class="rt-card-body">
                                <div style="width: 36px; height: 36px; border: 1px solid var(--border-color); background: var(--primary-light); color: var(--text-main); display: flex; align-items: center; justify-content: center; font-size: 1.1rem; margin-bottom: 1rem;">
                                    <i class="bi bi-chat-left-dots"></i>
                                </div>
                                <h4 style="font-weight: 700; margin-bottom: 0.5rem; font-size: 1.1rem;">Milestone Reviews</h4>
                                <p style="font-size: 0.82rem; color: var(--text-muted); line-height: 1.5;">Supervisors assign specific grades and write comments. System aggregates scores and recalculates overall status grades dynamically.</p>
                            </div>
                        </div>

                        <div class="rt-card" style="margin-bottom: 0;">
                            <div class="rt-card-body">
                                <div style="width: 36px; height: 36px; border: 1px solid var(--border-color); background: var(--primary-light); color: var(--text-main); display: flex; align-items: center; justify-content: center; font-size: 1.1rem; margin-bottom: 1rem;">
                                    <i class="bi bi-box-seam"></i>
                                </div>
                                <h4 style="font-weight: 700; margin-bottom: 0.5rem; font-size: 1.1rem;">Container Staging</h4>
                                <p style="font-size: 0.82rem; color: var(--text-muted); line-height: 1.5;">Staged Docker containers can be toggled to verify live builds. Log streaming emulates container execution output directly.</p>
                            </div>
                        </div>

                        <div class="rt-card" style="margin-bottom: 0;">
                            <div class="rt-card-body">
                                <div style="width: 36px; height: 36px; border: 1px solid var(--border-color); background: var(--primary-light); color: var(--text-main); display: flex; align-items: center; justify-content: center; font-size: 1.1rem; margin-bottom: 1rem;">
                                    <i class="bi bi-calculator"></i>
                                </div>
                                <h4 style="font-weight: 700; margin-bottom: 0.5rem; font-size: 1.1rem;">PITA Grading Matrix</h4>
                                <p style="font-size: 0.82rem; color: var(--text-muted); line-height: 1.5;">Evaluator scorecard calculates scores based on code standard criteria, Docker parameters, and oral presentation ratings.</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="landing-section" style="background: var(--bg-main);">
                    <div style="text-align: center; margin-bottom: 3rem;">
                        <h2 style="font-size: 1.75rem; font-weight: 800; margin-bottom: 0.5rem; text-transform: uppercase; letter-spacing: 0.05em;">Interactive Flow Walkthrough</h2>
                        <p style="color: var(--text-muted); max-width: 500px; margin: 0 auto; font-size: 0.88rem;">Select any profile in the top simulator bar or below to evaluate the system views.</p>
                    </div>

                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; max-width: 1000px; margin: 0 auto;">
                        <div class="rt-card text-center" style="margin-bottom: 0;">
                            <div class="rt-card-body" style="padding: 2rem 1.5rem;">
                                <div class="role-badge-indicator role-student" style="margin-bottom: 1rem;">Student View</div>
                                <h4 style="font-weight: 700; margin-bottom: 0.5rem; font-size: 1rem;">Submit & Track</h4>
                                <p style="font-size: 0.8rem; color: var(--text-muted); line-height: 1.5; margin-bottom: 1.25rem;">Submit github repos, selector branches, input logbook time records, and verify milestones status.</p>
                                <button class="btn btn-primary btn-sm w-100" onclick="RT_APP.setRole('STUDENT')">Load Student</button>
                            </div>
                        </div>
                        <div class="rt-card text-center" style="margin-bottom: 0;">
                            <div class="rt-card-body" style="padding: 2rem 1.5rem;">
                                <div class="role-badge-indicator role-supervisor" style="margin-bottom: 1rem;">Supervisor View</div>
                                <h4 style="font-weight: 700; margin-bottom: 0.5rem; font-size: 1rem;">Assess & Comment</h4>
                                <p style="font-size: 0.8rem; color: var(--text-muted); line-height: 1.5; margin-bottom: 1.25rem;">Audit weekly logbooks, review staged PDF deliverable reports, run container testbench, enter grades.</p>
                                <button class="btn btn-primary btn-sm w-100" onclick="RT_APP.setRole('SUPERVISOR')">Load Supervisor</button>
                            </div>
                        </div>
                        <div class="rt-card text-center" style="margin-bottom: 0;">
                            <div class="rt-card-body" style="padding: 2rem 1.5rem;">
                                <div class="role-badge-indicator role-coordinator" style="margin-bottom: 1rem;">Coordinator View</div>
                                <h4 style="font-weight: 700; margin-bottom: 0.5rem; font-size: 1rem;">Registry Admin</h4>
                                <p style="font-size: 0.8rem; color: var(--text-muted); line-height: 1.5; margin-bottom: 1.25rem;">Automate supervisor assign load, edit navigation tiles, monitor VM logs stream, configure rules.</p>
                                <button class="btn btn-primary btn-sm w-100" onclick="RT_APP.setRole('COORDINATOR')">Load Coordinator</button>
                            </div>
                        </div>
                    </div>
                </div>

                <footer style="background: #ffffff; color: var(--text-muted); text-align: center; padding: 2rem; font-size: 0.8rem; border-top: 2px solid var(--border-color);">
                    <span>RailTrack Wireframe Staging Guide. Grayscale Schematic Flow &copy; 2026.</span>
                </footer>
            </div>
        `;
    },

    // ── COMMON PROFILE PAGE ──
    profile: function() {
        const user = RT_APP.state.currentUser;
        return `
            <div class="rt-card">
                <div class="rt-card-header">
                    <span><i class="bi bi-person-gear"></i> Account Settings Wireframe</span>
                </div>
                <div class="rt-card-body">
                    <div style="display: flex; align-items: center; gap: 1.5rem; margin-bottom: 2rem; background: var(--primary-light); padding: 1.25rem; border: 1px solid var(--border-color);">
                        <div class="sidebar-user-avatar" style="width: 56px; height: 56px; font-size: 1.5rem; font-weight: 700;">
                            ${user ? user.avatar : '?'}
                        </div>
                        <div>
                            <h3 style="font-weight: 800; font-size: 1.3rem;">${user ? user.fullName : 'Guest User'}</h3>
                            <span class="badge badge-active" style="margin-top: 0.25rem;">${user ? user.role : 'GUEST'}</span>
                            <span style="color: var(--text-muted); font-size: 0.8rem; margin-left: 0.5rem;">ID Code: ${user?.studentId || 'N/A'}</span>
                        </div>
                    </div>

                    <form onsubmit="event.preventDefault(); RT_APP.showFlash('Profile information updated.', 'success');">
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                            <div class="form-group">
                                <label class="form-label">Full Name</label>
                                <input type="text" value="${user ? user.fullName : ''}" required class="form-control">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Email Address</label>
                                <input type="email" value="${user ? user.email : ''}" required class="form-control">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Username String</label>
                                <input type="text" value="${user ? user.username : ''}" required class="form-control">
                            </div>
                            <div class="form-group">
                                <label class="form-label">Staged Semester Year</label>
                                <input type="text" value="2026/2027-1" readonly class="form-control" style="background: var(--primary-light);">
                            </div>
                        </div>

                        <div class="form-group" style="margin-top: 1rem;">
                            <label class="form-label">Account Notes / Affiliations</label>
                            <textarea rows="3" class="form-control" placeholder="Type text metadata..."></textarea>
                        </div>

                        <div style="display: flex; justify-content: flex-end; gap: 0.5rem; margin-top: 1rem; border-top: 2px solid var(--border-color); padding-top: 1rem;">
                            <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Save Profile Data</button>
                        </div>
                    </form>
                </div>
            </div>
        `;
    },

    // ── STUDENT DASHBOARD ──
    studentDashboard: function() {
        const student = RT_APP.state.currentUser;
        const projects = RT_MOCK_DATA.projects.filter(p => p.studentId === student.studentId);
        const activeCount = projects.filter(p => p.status === 'ACTIVE').length;
        const pendingCount = projects.filter(p => p.status === 'PENDING').length;
        const completedCount = projects.filter(p => p.status === 'COMPLETED').length;

        let projectsHtml = '';
        if (projects.length === 0) {
            projectsHtml = `
                <div class="rt-card text-center" style="padding: 3rem 1.5rem; border-style: dashed;">
                    <i class="bi bi-folder" style="font-size: 2rem; color: var(--text-muted); display: block; margin-bottom: 0.75rem;"></i>
                    <p style="margin-bottom: 1rem; font-size: 0.85rem; color: var(--text-muted);">No staged project submissions found in the database directory.</p>
                    <button class="btn btn-primary" onclick="RT_APP.openModal('submit-project-modal')">
                        <i class="bi bi-plus-lg"></i> Submit Staged Repository
                    </button>
                </div>
            `;
        } else {
            projectsHtml = `<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 1rem;">`;
            projects.forEach(p => {
                const badgeClass = p.status === 'ACTIVE' ? 'badge-active' : (p.status === 'PENDING' ? 'badge-pending' : (p.status === 'COMPLETED' ? 'badge-completed' : 'badge-rejected'));
                projectsHtml += `
                    <div class="rt-card">
                        <div class="rt-card-body" style="padding: 1rem;">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.75rem;">
                                <span class="badge ${badgeClass}">${p.status}</span>
                                <span style="font-size: 0.72rem; font-weight: 700;">
                                    <i class="bi bi-circle-fill" style="font-size: 6px; vertical-align: middle;"></i> Docker: ${p.dockerStatus}
                                </span>
                            </div>
                            <h4 style="font-weight: 800; font-size: 1rem; margin-bottom: 0.5rem;">${p.title}</h4>
                            <p style="font-size: 0.78rem; color: var(--text-muted); margin-bottom: 0.75rem; line-height: 1.4;">
                                ${p.description}
                            </p>
                            <div style="font-size: 0.75rem; color: var(--text-muted); margin-bottom: 0.35rem; font-family: var(--font-mono);">
                                <i class="bi bi-github"></i> ${p.repoUrl.replace('https://github.com/', '')}
                            </div>
                            <div style="font-size: 0.75rem; color: var(--text-muted); margin-bottom: 1rem;">
                                <i class="bi bi-person"></i> Supervisor: ${p.supervisorName ? p.supervisorName : 'Unallocated'}
                            </div>
                            
                            <div style="display: flex; gap: 0.35rem;">
                                <a href="#/student/project/${p.id}" class="btn btn-outline-primary btn-sm" style="flex: 1; text-decoration: none;">
                                    <i class="bi bi-eye"></i> Open Workspace
                                </a>
                                ${p.dockerStatus !== 'none' ? `
                                    <button class="btn btn-secondary btn-sm" onclick="RT_APP.toggleDockerAction(${p.id})">
                                        <i class="bi bi-power"></i> Toggle Container
                                    </button>
                                ` : ''}
                            </div>
                        </div>
                    </div>
                `;
            });
            projectsHtml += `</div>`;
        }

        return `
            <!-- Menu Tiles -->
            <div style="margin-bottom: 1.5rem;">
                <h5 style="font-weight: 700; margin-bottom: 0.75rem; color: var(--text-main); font-size: 0.8rem; letter-spacing: 0.05em; text-transform: uppercase;">
                    Menu Navigation Blocks
                </h5>
                <div class="tiles-grid">
                    ${RT_MOCK_DATA.menuItems.map(item => `
                        <a href="${item.url}" class="tile-item">
                            <i class="${item.icon}"></i>
                            <div class="tile-label">${item.label}</div>
                        </a>
                    `).join('')}
                </div>
            </div>

            <!-- Page header -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; border-bottom: 2px solid var(--border-color); padding-bottom: 0.75rem;">
                <div>
                    <h2 style="font-weight: 800; font-size: 1.5rem; letter-spacing: -0.02em;">Student Projects Dashboard</h2>
                    <p style="color: var(--text-muted); font-size: 0.8rem;">Grayscale wireframe schematic overviewing student tasks status.</p>
                </div>
                <button class="btn btn-primary" onclick="RT_APP.openModal('submit-project-modal')">
                    <i class="bi bi-plus-lg"></i> Submit Repository
                </button>
            </div>

            <!-- Stats -->
            <div class="grid-stats">
                <div class="card-stat">
                    <div class="stat-icon"><i class="bi bi-folder"></i></div>
                    <div class="stat-info">
                        <div class="stat-value">${projects.length}</div>
                        <div class="stat-label">Total Submissions</div>
                    </div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon"><i class="bi bi-clock"></i></div>
                    <div class="stat-info">
                        <div class="stat-value">${pendingCount}</div>
                        <div class="stat-label">Pending Reviews</div>
                    </div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon"><i class="bi bi-gear-wide-connected"></i></div>
                    <div class="stat-info">
                        <div class="stat-value">${activeCount}</div>
                        <div class="stat-label">Active Coding</div>
                    </div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon"><i class="bi bi-award"></i></div>
                    <div class="stat-info">
                        <div class="stat-value">${completedCount}</div>
                        <div class="stat-label">Completed Graded</div>
                    </div>
                </div>
            </div>

            <!-- List section -->
            ${projectsHtml}
        `;
    },

    // ── STUDENT PROJECT WORKSPACE DETAIL ──
    studentProjectDetail: function(id) {
        const proj = RT_MOCK_DATA.projects.find(p => p.id === id);
        if (!proj) return `<div class="rt-alert rt-alert-error">Project metadata not found.</div>`;

        const milestones = RT_MOCK_DATA.milestones.filter(m => m.projectId === id);
        const feedback = RT_MOCK_DATA.feedbacks.filter(f => f.projectId === id);

        return `
            <div style="margin-bottom: 1rem;">
                <a href="#/student/dashboard" class="btn btn-secondary btn-sm" style="text-decoration:none;">
                    <i class="bi bi-arrow-left"></i> Back to Dashboard
                </a>
            </div>

            <div class="rt-card" style="margin-bottom: 1.5rem;">
                <div class="rt-card-body" style="padding: 1rem; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
                    <div>
                        <div style="display: flex; gap: 0.5rem; align-items: center; margin-bottom: 0.25rem;">
                            <h2 style="font-weight: 800; font-size: 1.35rem; letter-spacing: -0.02em;">${proj.title}</h2>
                            <span class="badge ${proj.status === 'ACTIVE' ? 'badge-active' : 'badge-pending'}">${proj.status}</span>
                        </div>
                        <p style="color: var(--text-muted); font-size: 0.8rem; max-width: 700px; line-height: 1.4;">${proj.description}</p>
                    </div>
                    
                    <div style="background: var(--primary-light); padding: 0.75rem 1rem; border: 2px solid var(--border-color); text-align: center;">
                        <span style="font-size: 0.65rem; text-transform: uppercase; color: var(--text-muted); display: block; font-weight: 700;">Progress Grade</span>
                        <strong style="font-size: 1.35rem; color: var(--text-main);">${proj.overallGrade ? proj.overallGrade.toFixed(1) + '%' : 'N/A'}</strong>
                    </div>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 1.25rem;">
                
                <!-- Left: Milestones Timeline -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-flag-fill"></i> Assignment Deliverable Milestones</span>
                        </div>
                        <div class="rt-card-body" style="padding: 0;">
                            <div class="table-responsive">
                                <table class="rt-table">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Milestone Task Title</th>
                                            <th>Deadline</th>
                                            <th>Audit Status</th>
                                            <th>Grade</th>
                                            <th>Weight</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${milestones.map(m => {
                                            let statusBadge = '';
                                            if (m.status === 'APPROVED') statusBadge = '<span class="badge badge-active">Approved</span>';
                                            else if (m.status === 'SUBMITTED') statusBadge = '<span class="badge badge-review">Staged</span>';
                                            else if (m.status === 'PENDING') statusBadge = '<span class="badge badge-pending">Draft</span>';
                                            else statusBadge = `<span class="badge badge-rejected">${m.status}</span>`;
                                            
                                            return `
                                                <tr>
                                                    <td style="color: var(--text-muted); font-weight: 700;">${m.milestoneNo}</td>
                                                    <td>
                                                        <strong style="display: block; font-size: 0.82rem;">${m.title}</strong>
                                                        <span style="font-size: 0.72rem; color: var(--text-muted); line-height: 1.3; display: block;">${m.description}</span>
                                                        ${m.status === 'PENDING' ? `
                                                            <button class="btn btn-secondary btn-sm" style="font-size: 0.65rem; padding: 0.15rem 0.4rem; margin-top: 0.35rem;" onclick="RT_APP.gradeMilestoneAction(${id}, ${m.milestoneNo}, 'SUBMITTED')">
                                                                <i class="bi bi-cloud-upload"></i> Submit for Grading
                                                            </button>
                                                        ` : ''}
                                                    </td>
                                                    <td style="font-size: 0.75rem; color: var(--text-muted); white-space: nowrap;">${m.dueDate}</td>
                                                    <td>${statusBadge}</td>
                                                    <td><strong style="color: var(--text-main);">${m.grade ? m.grade.toFixed(1) + '%' : '—'}</strong></td>
                                                    <td style="font-size: 0.75rem; color: var(--text-muted); font-weight: 700;">${m.weight}%</td>
                                                </tr>
                                            `;
                                        }).join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right: Container actions -->
                <div>
                    <!-- Docker Control -->
                    <div class="rt-card" style="border-style: solid;">
                        <div class="rt-card-header">
                            <span><i class="bi bi-box-seam me-1"></i> Container Sandbox Staging</span>
                            <span class="badge badge-pending">${proj.dockerStatus}</span>
                        </div>
                        <div class="rt-card-body">
                            <div style="font-size: 0.75rem; color: var(--text-muted); margin-bottom: 0.75rem;">
                                Verify compile state in local environment staging simulator.
                            </div>
                            
                            <div style="display: flex; gap: 0.5rem; margin-bottom: 1rem;">
                                <button class="btn btn-primary w-100 btn-sm" onclick="RT_APP.toggleDockerAction(${proj.id})">
                                    <i class="bi bi-power"></i> 
                                    ${proj.dockerStatus === 'running' ? 'Stop Sandbox' : 'Start Sandbox'}
                                </button>
                            </div>

                            <div style="font-size: 0.72rem; background: var(--primary-light); border: 1px solid var(--border-color); padding: 0.6rem;">
                                <div style="display: flex; justify-content: space-between; margin-bottom: 0.25rem;">
                                    <span>Repo Branch:</span>
                                    <span style="font-family: var(--font-mono); font-weight: 700;">${proj.branch}</span>
                                </div>
                                <div style="display: flex; justify-content: space-between; margin-bottom: 0.25rem;">
                                    <span>Time Limit Hours:</span>
                                    <span>${proj.runningLimitSeconds / 3600} hours</span>
                                </div>
                                <div style="display: flex; justify-content: space-between;">
                                    <span>Staging Address:</span>
                                    <span style="font-family: var(--font-mono); font-size: 0.7rem; text-decoration: underline;">
                                        ${proj.dockerStatus === 'running' ? 'localhost:8080' : 'offline'}
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Feedback logs -->
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-chat-left-text"></i> Supervisor Notes Log</span>
                        </div>
                        <div class="rt-card-body" style="padding: 0.75rem; max-height: 200px; overflow-y: auto; display: flex; flex-direction: column; gap: 0.5rem;">
                            ${feedback.length === 0 ? `
                                <div style="font-size: 0.75rem; color: var(--text-muted); text-align: center; padding: 1rem 0;">No comments logged yet.</div>
                            ` : feedback.map(f => `
                                <div style="background: #ffffff; border: 1px solid var(--border-light); padding: 0.5rem; font-size: 0.75rem;">
                                    <div style="display: flex; justify-content: space-between; margin-bottom: 0.25rem; border-bottom: 1px dashed var(--border-light); padding-bottom: 0.15rem;">
                                        <strong>${f.authorName}</strong>
                                        <span style="font-size: 0.65rem; color: var(--text-muted);">${f.createdAt}</span>
                                    </div>
                                    <p style="color: var(--text-main); line-height: 1.3;">${f.content}</p>
                                </div>
                            `).join('')}
                        </div>
                    </div>

                </div>

            </div>
        `;
    },

    // ── STUDENT LOGBOOK JOURNAL ──
    studentLogbook: function() {
        const logs = RT_MOCK_DATA.logbooks;
        return `
            <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 1.25rem;">
                
                <!-- Create Entry Form -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-journal-plus"></i> Submit Log Entry</span>
                        </div>
                        <div class="rt-card-body">
                            <form onsubmit="RT_APP.submitLogbookEntryAction(event)">
                                <div class="form-group">
                                    <label class="form-label">Staged Week</label>
                                    <input type="text" value="Week ${logs.length + 1}" class="form-control" readonly style="background: var(--primary-light);">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Weekly Hours Logged</label>
                                    <input type="number" id="log-hours" min="1" max="40" required placeholder="e.g. 8" class="form-control">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Summary of Coding Tasks Completed *</label>
                                    <textarea id="log-desc" rows="5" required placeholder="Describe weekly repository commits, test suite compilations, or staging configurations..." class="form-control"></textarea>
                                </div>
                                <button type="submit" class="btn btn-primary w-100">
                                    <i class="bi bi-save"></i> Submit Weekly Log
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Log History -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-clock-history"></i> Weekly Log Entries Audit</span>
                        </div>
                        <div class="rt-card-body" style="padding: 0;">
                            <div class="table-responsive">
                                <table class="rt-table">
                                    <thead>
                                        <tr>
                                            <th>Week</th>
                                            <th>Hours</th>
                                            <th>Work Summary Description</th>
                                            <th>Status</th>
                                            <th>Supervisor Audit Note</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${logs.map(l => {
                                            const badge = l.status === 'APPROVED' ? '<span class="badge badge-active">Approved</span>' : '<span class="badge badge-review">staged</span>';
                                            return `
                                                <tr>
                                                    <td style="font-weight: 700;">W${l.week}</td>
                                                    <td><span class="badge badge-pending">${l.hours}h</span></td>
                                                    <td style="font-size: 0.78rem; line-height: 1.4; max-width: 250px;">${l.description}</td>
                                                    <td>${badge}</td>
                                                    <td style="font-size: 0.72rem; color: var(--text-muted); font-style: italic;">
                                                        ${l.feedback ? `"${l.feedback}"` : '—'}
                                                    </td>
                                                </tr>
                                            `;
                                        }).reverse().join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        `;
    },

    // ── STUDENT DELIVERABLES SUBMISSIONS ──
    studentDocuments: function() {
        const docs = RT_MOCK_DATA.documents;
        
        return `
            <div style="display: grid; grid-template-columns: 1fr 1.5fr; gap: 1.25rem;">
                
                <!-- Upload Panel -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-cloud-arrow-up"></i> Upload PDF Deliverable</span>
                        </div>
                        <div class="rt-card-body">
                            <form onsubmit="event.preventDefault(); RT_APP.showFlash('File staged in draft directory.', 'success');">
                                <div class="form-group">
                                    <label class="form-label">Requirement Category *</label>
                                    <select class="form-select" required>
                                        <option value="Proposal">Project Proposal Report</option>
                                        <option value="Midterm">Midterm Staging Presentation</option>
                                        <option value="PITA-01">PITA-01 Technical Assessment</option>
                                        <option value="PITA-02">PITA-02 Staging Checklist</option>
                                        <option value="Thesis">Final Dissertation Thesis</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Select PDF Document File *</label>
                                    <div style="border: 2px dashed var(--border-color); text-align: center; padding: 2rem 1rem; cursor: pointer; background: var(--bg-main);" onclick="this.querySelector('input').click()">
                                        <input type="file" required accept=".pdf" style="display: none;">
                                        <i class="bi bi-file-earmark-pdf" style="font-size: 2rem; color: var(--text-muted); display: block; margin-bottom: 0.5rem;"></i>
                                        <span style="font-size: 0.78rem; font-weight: 700; display: block;">Browse Local Files</span>
                                        <span style="font-size: 0.65rem; color: var(--text-muted);">PDF files only (Max 20MB)</span>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-primary w-100">
                                    <i class="bi bi-upload"></i> Upload Deliverable PDF
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Staged Upload Status -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-folder-check"></i> staged Submissions Registry</span>
                        </div>
                        <div class="rt-card-body" style="padding: 0;">
                            <div class="table-responsive">
                                <table class="rt-table">
                                    <thead>
                                        <tr>
                                            <th>Type</th>
                                            <th>Staged File Name</th>
                                            <th>Upload Date</th>
                                            <th>Audit Status</th>
                                            <th>Recorded Score</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${docs.map(d => {
                                            const statusBadge = d.status === 'APPROVED' ? '<span class="badge badge-active">Approved</span>' : '<span class="badge badge-review">staged</span>';
                                            return `
                                                <tr>
                                                    <td><strong>${d.docType}</strong></td>
                                                    <td style="font-size: 0.75rem; font-family: var(--font-mono); text-decoration: underline;">${d.fileName}</td>
                                                    <td style="font-size: 0.75rem; color: var(--text-muted);">${d.uploadedAt}</td>
                                                    <td>${statusBadge}</td>
                                                    <td><strong style="color: var(--text-main);">${d.grade ? d.grade.toFixed(1) + '%' : '—'}</strong></td>
                                                </tr>
                                            `;
                                        }).join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        `;
    },

    // ── STUDENT MATERIALS RESOURCES ──
    studentMaterials: function() {
        return `
            <div class="rt-card">
                <div class="rt-card-header">
                    <span><i class="bi bi-folder"></i> Official Manuals & System Templates</span>
                </div>
                <div class="rt-card-body" style="padding: 0;">
                    <div class="table-responsive">
                        <table class="rt-table">
                            <thead>
                                <tr>
                                    <th>Resource Document Title</th>
                                    <th>Format</th>
                                    <th>File Size</th>
                                    <th>Author Role</th>
                                    <th>Date Added</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${RT_MOCK_DATA.materials.map(m => `
                                    <tr>
                                        <td>
                                            <strong style="display: block; font-size: 0.82rem;">${m.title}</strong>
                                            <span style="font-size: 0.7rem; color: var(--text-muted);">Guidelines outline grading weights, Docker setup instructions</span>
                                        </td>
                                        <td><span class="badge badge-pending">${m.type}</span></td>
                                        <td style="font-size: 0.75rem; color: var(--text-muted);">${m.size}</td>
                                        <td style="font-size: 0.75rem;">${m.uploadedBy}</td>
                                        <td style="font-size: 0.75rem; color: var(--text-muted);">${m.date}</td>
                                        <td>
                                            <button class="btn btn-secondary btn-sm" onclick="RT_APP.showFlash('Downloading file...', 'info')">
                                                <i class="bi bi-download"></i> Get PDF
                                            </button>
                                        </td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    },

    // ── STUDENT RUBRICS GUIDE ──
    studentRubrics: function() {
        return `
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.25rem;">
                
                <!-- Weights distribution -->
                <div class="rt-card">
                    <div class="rt-card-header">
                        <span><i class="bi bi-pie-chart"></i> Course Grading Weights Structure</span>
                    </div>
                    <div class="rt-card-body">
                        <div style="display: flex; flex-direction: column; gap: 0.75rem;">
                            <div class="rubric-row primary">
                                <strong style="display: block; font-size: 0.85rem;">Milestone 1: Project Proposal (15%)</strong>
                                <span style="font-size: 0.75rem; color: var(--text-muted);">Thesis background, library citations, project timeline schedules.</span>
                            </div>
                            <div class="rubric-row success">
                                <strong style="display: block; font-size: 0.85rem;">Milestone 2: Mid-Term Development (35%)</strong>
                                <span style="font-size: 0.75rem; color: var(--text-muted);">Database entity relationship models, Docker container validation, system logic.</span>
                            </div>
                            <div class="rubric-row warning">
                                <strong style="display: block; font-size: 0.85rem;">Milestone 3: PITA-01 Technical Demonstration (25%)</strong>
                                <span style="font-size: 0.75rem; color: var(--text-muted);">Container deployment logs review, performance testing metrics, oral description.</span>
                            </div>
                            <div class="rubric-row" style="border-left-color: var(--text-main);">
                                <strong style="display: block; font-size: 0.85rem;">Milestone 4: Final Thesis Report (25%)</strong>
                                <span style="font-size: 0.75rem; color: var(--text-muted);">Formatted dissertation report PDF, code registry repository audits.</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Grading descriptors -->
                <div class="rt-card">
                    <div class="rt-card-header">
                        <span><i class="bi bi-journal-text"></i> Evaluation Descriptors Matrix</span>
                    </div>
                    <div class="rt-card-body">
                        <h4 style="font-weight: 700; font-size: 0.9rem; margin-bottom: 0.5rem; text-transform: uppercase;">Technical Assessment Scoring Levels</h4>
                        <div style="display: flex; flex-direction: column; gap: 0.5rem; font-size: 0.78rem; line-height: 1.4;">
                            <div style="background: var(--primary-light); padding: 0.75rem; border: 1px solid var(--border-color);">
                                <strong>Level A (80-100%):</strong> Compiles cleanly. SSE log streaming updates in real time. Model constraints met.
                            </div>
                            <div style="background: var(--primary-light); padding: 0.75rem; border: 1px dashed var(--border-color);">
                                <strong>Level B (60-79%):</strong> System compiles but staging container experiences build warnings. Incomplete test files.
                            </div>
                            <div style="background: #ffffff; padding: 0.75rem; border: 1px double var(--border-color);">
                                <strong>Level C (40-59%):</strong> Staging container fails deployment tests. Errors shown on logs streaming.
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        `;
    },

    // ── SUPERVISOR DASHBOARD ──
    supervisorDashboard: function() {
        const supervisor = RT_APP.state.currentUser;
        const projects = RT_MOCK_DATA.projects.filter(p => p.supervisorId === supervisor.id);
        const runningContainers = projects.filter(p => p.dockerStatus === 'running').length;
        const pendingLogsCount = RT_MOCK_DATA.logbooks.filter(l => l.status === 'SUBMITTED').length;
        const pendingMilestonesCount = RT_MOCK_DATA.milestones.filter(m => m.status === 'SUBMITTED').length;

        return `
            <!-- Header -->
            <div style="margin-bottom: 1.5rem; border-bottom: 2px solid var(--border-color); padding-bottom: 0.75rem;">
                <h2 style="font-weight: 800; font-size: 1.5rem; letter-spacing: -0.02em;">Supervisor Panel Dashboard</h2>
                <p style="color: var(--text-muted); font-size: 0.8rem;">Grayscale wireframe schematic overviewing supervisor tasks.</p>
            </div>

            <!-- Stats -->
            <div class="grid-stats">
                <div class="card-stat">
                    <div class="stat-icon"><i class="bi bi-people"></i></div>
                    <div class="stat-info">
                        <div class="stat-value">${projects.length}</div>
                        <div class="stat-label">Assigned Cohort</div>
                    </div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon"><i class="bi bi-cpu"></i></div>
                    <div class="stat-info">
                        <div class="stat-value">${runningContainers}</div>
                        <div class="stat-label">Running Container Sandbox</div>
                    </div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon"><i class="bi bi-book"></i></div>
                    <div class="stat-info">
                        <div class="stat-value">${pendingLogsCount}</div>
                        <div class="stat-label">Logbook Journals Audit</div>
                    </div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon"><i class="bi bi-flag"></i></div>
                    <div class="stat-info">
                        <div class="stat-value">${pendingMilestonesCount}</div>
                        <div class="stat-label">Staged Milestones Review</div>
                    </div>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 1.25rem;">
                
                <!-- Main projects lists -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-kanban"></i> Supervised Student Submissions Directory</span>
                            <a href="#/supervisor/students" class="btn btn-secondary btn-sm" style="font-size: 0.65rem; padding: 0.15rem 0.4rem; text-decoration:none;">View Directory</a>
                        </div>
                        <div class="rt-card-body" style="padding: 0;">
                            <div class="table-responsive">
                                <table class="rt-table">
                                    <thead>
                                        <tr>
                                            <th>Staged Student</th>
                                            <th>Thesis Topic</th>
                                            <th>Staging Container</th>
                                            <th>Recorded Grade</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${projects.map(p => `
                                            <tr>
                                                <td>
                                                    <strong style="display:block; font-size:0.82rem;">${p.studentName}</strong>
                                                    <span style="font-size: 0.68rem; color: var(--text-muted);">ID: ${p.studentId}</span>
                                                </td>
                                                <td>
                                                    <strong style="display:block; font-size:0.82rem; max-width: 250px;" class="text-truncate" title="${p.title}">${p.title}</strong>
                                                    <span style="font-size:0.7rem; color: var(--text-muted); font-family: var(--font-mono);">${p.repoUrl.replace('https://github.com/', '')}</span>
                                                </td>
                                                <td>
                                                    <span class="badge ${p.dockerStatus === 'running' ? 'badge-active' : 'badge-pending'}">
                                                        <i class="bi bi-circle-fill" style="font-size: 5px; vertical-align: middle;"></i> ${p.dockerStatus}
                                                    </span>
                                                </td>
                                                <td><strong style="color: var(--text-main); font-size:0.85rem;">${p.overallGrade ? p.overallGrade.toFixed(1) + '%' : '—'}</strong></td>
                                                <td>
                                                    <div style="display: flex; gap: 0.25rem;">
                                                        <a href="#/supervisor/project/${p.id}" class="btn btn-secondary btn-sm" style="font-size: 0.72rem; padding: 0.2rem 0.4rem; text-decoration:none;">
                                                            <i class="bi bi-clipboard-check"></i> Assess
                                                        </a>
                                                        <button class="btn btn-secondary btn-sm" style="padding: 0.2rem 0.35rem;" onclick="RT_APP.toggleDockerAction(${p.id})">
                                                            <i class="bi bi-power"></i>
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        `).join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Notifications log -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-bell"></i> System Alert Trails</span>
                        </div>
                        <div class="rt-card-body" style="padding: 0.75rem; display: flex; flex-direction: column; gap: 0.5rem;">
                            ${RT_APP.state.notifications.map(n => `
                                <div style="border-left: 2px solid var(--border-color); padding-left: 0.5rem; font-size: 0.75rem;">
                                    <p style="margin-bottom: 0.15rem; font-weight: 700;">${n.text}</p>
                                    <span style="font-size: 0.65rem; color: var(--text-muted);">${n.time}</span>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                </div>

            </div>
        `;
    },

    // ── SUPERVISOR STUDENTS LIST ──
    supervisorStudents: function() {
        const supervisor = RT_APP.state.currentUser;
        const projects = RT_MOCK_DATA.projects.filter(p => p.supervisorId === supervisor.id);

        return `
            <div style="margin-bottom: 1.5rem; border-bottom: 2px solid var(--border-color); padding-bottom: 0.75rem;">
                <h2 style="font-weight: 800; font-size: 1.5rem; letter-spacing: -0.02em;">Supervised Cohort Index</h2>
                <p style="color: var(--text-muted); font-size: 0.8rem;">List of allocated student projects, logbooks, and scorecards reviews.</p>
            </div>

            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 1rem;">
                ${projects.map(p => {
                    const pitaDoc = RT_MOCK_DATA.documents.find(d => d.projectId === p.id && d.docType === 'PITA-01');
                    const isPitaStaged = pitaDoc && pitaDoc.status === 'SUBMITTED';
                    return `
                        <div class="rt-card">
                            <div class="rt-card-header">
                                <div>
                                    <strong style="display:block; font-size: 0.85rem;">${p.studentName}</strong>
                                    <span style="font-size: 0.68rem; color: var(--text-muted); font-weight: 500;">ID: ${p.studentId} &middot; Sem: ${p.semester}</span>
                                </div>
                                <span class="badge badge-active" style="font-size: 0.6rem;">${p.status}</span>
                            </div>
                            <div class="rt-card-body" style="padding: 1rem;">
                                <h5 style="font-weight: 700; font-size: 0.85rem; margin-bottom: 0.5rem; line-height: 1.3;">${p.title}</h5>
                                
                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; font-size: 0.72rem; margin-bottom: 1rem; background: var(--primary-light); padding: 0.5rem; border: 1px solid var(--border-color);">
                                    <div>
                                        <span style="color: var(--text-muted); display: block;">Staging VM:</span>
                                        <strong>${p.dockerStatus}</strong>
                                    </div>
                                    <div>
                                        <span style="color: var(--text-muted); display: block;">Total Score:</span>
                                        <strong>${p.overallGrade ? p.overallGrade.toFixed(1) + '%' : '—'}</strong>
                                    </div>
                                </div>

                                <div style="display: flex; flex-direction: column; gap: 0.35rem;">
                                    <div style="display: flex; gap: 0.35rem;">
                                        <a href="#/supervisor/project/${p.id}" class="btn btn-secondary btn-sm" style="flex: 1; font-size: 0.72rem; text-decoration:none;">
                                            <i class="bi bi-sliders"></i> Assess Tasks
                                        </a>
                                        <a href="#/supervisor/logbook/${p.studentId}" class="btn btn-secondary btn-sm" style="flex: 1; font-size: 0.72rem; text-decoration:none;">
                                            <i class="bi bi-book"></i> Logbook Audit
                                        </a>
                                    </div>
                                    <div style="display: flex; gap: 0.35rem;">
                                        <a href="#/supervisor/documents/${p.studentId}" class="btn btn-secondary btn-sm" style="flex: 1; font-size: 0.72rem; text-decoration:none;">
                                            <i class="bi bi-cloud-arrow-up"></i> Deliverables
                                        </a>
                                        <a href="#/supervisor/pita/${p.id}" class="btn btn-secondary btn-sm" style="flex: 1; font-size: 0.72rem; text-decoration:none; ${isPitaStaged ? 'border-style: double; font-weight:800;' : ''}">
                                            <i class="bi bi-calculator"></i> PITA Scoring
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;
                }).join('')}
            </div>
        `;
    },

    // ── SUPERVISOR PROJECT ASSESSMENT ──
    supervisorProjectDetail: function(id) {
        const proj = RT_MOCK_DATA.projects.find(p => p.id === id);
        if (!proj) return `<div class="rt-alert rt-alert-error">Project metadata not found.</div>`;

        const milestones = RT_MOCK_DATA.milestones.filter(m => m.projectId === id);
        const feedbacks = RT_MOCK_DATA.feedbacks.filter(f => f.projectId === id);

        return `
            <div style="margin-bottom: 1rem;">
                <a href="#/supervisor/students" class="btn btn-secondary btn-sm" style="text-decoration:none;">
                    <i class="bi bi-arrow-left"></i> Back to Directory
                </a>
            </div>

            <div class="rt-card" style="margin-bottom: 1.5rem;">
                <div class="rt-card-body" style="padding: 1rem; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
                    <div>
                        <span class="badge badge-active" style="margin-bottom: 0.25rem;">Assigned Workspace</span>
                        <h2 style="font-weight: 800; font-size: 1.35rem; letter-spacing: -0.02em;">${proj.title}</h2>
                        <span style="font-size: 0.78rem; color: var(--text-muted);">Staged Student: <strong>${proj.studentName}</strong> (ID: ${proj.studentId}) &middot; Repository: <a href="${proj.repoUrl}" target="_blank" style="font-family:var(--font-mono);">${proj.repoUrl.replace('https://github.com/', '')}</a></span>
                    </div>
                    
                    <div style="background: var(--primary-light); padding: 0.6rem 1rem; border: 2px solid var(--border-color); text-align: center;">
                        <span style="font-size: 0.65rem; text-transform: uppercase; color: var(--text-muted); display: block; font-weight: 700;">Overall Score</span>
                        <strong style="font-size: 1.35rem; color: var(--text-main);">${proj.overallGrade ? proj.overallGrade.toFixed(1) + '%' : 'N/A'}</strong>
                    </div>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 1.25rem;">
                
                <!-- Left: Milestones actions -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-flag"></i> Grade Deliverable Milestones</span>
                        </div>
                        <div class="rt-card-body" style="padding: 0;">
                            <div class="table-responsive">
                                <table class="rt-table">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Milestone Task & Student Submission Note</th>
                                            <th>Deadline</th>
                                            <th>Weight</th>
                                            <th>Review Assessment Grade</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${milestones.map(m => {
                                            let actionHtml = '';
                                            if (m.status === 'APPROVED') {
                                                actionHtml = `<strong style="color:var(--text-main);">Approved (${m.grade}%)</strong>`;
                                            } else if (m.status === 'SUBMITTED') {
                                                actionHtml = `
                                                    <div style="display: flex; flex-direction: column; gap: 0.35rem; max-width: 180px;">
                                                        <input type="number" min="0" max="100" placeholder="Grade %" class="form-control form-control-sm" id="grade-val-${m.milestoneNo}">
                                                        <div style="display: flex; gap: 0.25rem;">
                                                            <button class="btn btn-primary btn-sm" style="flex:1; padding: 0.15rem 0.35rem; font-size: 0.7rem;" onclick="RT_APP.gradeMilestoneAction(${id}, ${m.milestoneNo}, 'APPROVED', document.getElementById('grade-val-${m.milestoneNo}').value)">Approve</button>
                                                            <button class="btn btn-secondary btn-sm" style="flex:1; padding: 0.15rem 0.35rem; font-size: 0.7rem; border-color:var(--border-color);" onclick="RT_APP.gradeMilestoneAction(${id}, ${m.milestoneNo}, 'REJECTED')">Reject</button>
                                                        </div>
                                                    </div>
                                                `;
                                            } else if (m.status === 'REJECTED') {
                                                actionHtml = `<span class="badge badge-rejected">Rejected</span>`;
                                            } else {
                                                actionHtml = `<span style="font-size: 0.75rem; color: var(--text-muted);">Awaiting submission</span>`;
                                            }

                                            return `
                                                <tr>
                                                    <td style="font-weight: 700; color: var(--text-muted);">${m.milestoneNo}</td>
                                                    <td>
                                                        <strong style="display:block; font-size: 0.82rem;">${m.title}</strong>
                                                        <p style="font-size: 0.72rem; color: var(--text-muted); line-height: 1.3; margin-bottom: 0.25rem;">${m.description}</p>
                                                        ${m.studentComment ? `<div style="font-size: 0.72rem; background: var(--primary-light); padding: 0.35rem; border: 1px solid var(--border-color); color: var(--text-main); margin-top: 0.35rem;">"<strong>Student Note:</strong> ${m.studentComment}"</div>` : ''}
                                                    </td>
                                                    <td style="font-size: 0.75rem; color: var(--text-muted); white-space: nowrap;">${m.dueDate}</td>
                                                    <td style="font-size: 0.75rem; font-weight: 700;">${m.weight}%</td>
                                                    <td>${actionHtml}</td>
                                                </tr>
                                            `;
                                        }).join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right: Docker & comments panel -->
                <div>
                    <!-- Docker container deployment control -->
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-cpu"></i> Sandbox Testbench</span>
                        </div>
                        <div class="rt-card-body">
                            <div style="font-size: 0.75rem; color: var(--text-muted); margin-bottom: 0.75rem;">
                                Launch student staging container locally to execute front-end code check.
                            </div>
                            <div style="background: var(--primary-light); border: 1px solid var(--border-color); padding: 0.5rem; font-size: 0.75rem; margin-bottom: 0.75rem;">
                                <div><strong>Container:</strong> smart-attendance-web</div>
                                <div><strong>State:</strong> <span class="badge badge-pending" style="margin-left: 0.25rem;">${proj.dockerStatus}</span></div>
                            </div>
                            <button class="btn btn-primary w-100 btn-sm" onclick="RT_APP.toggleDockerAction(${proj.id})">
                                <i class="bi bi-power"></i>
                                ${proj.dockerStatus === 'running' ? 'Shutdown Container' : 'Launch Container Staging'}
                            </button>
                        </div>
                    </div>

                    <!-- Post comments -->
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-chat-dots"></i> Add Log Note</span>
                        </div>
                        <div class="rt-card-body">
                            <form onsubmit="RT_APP.submitFeedbackAction(event, ${proj.id})">
                                <div class="form-group">
                                    <label class="form-label">Note Category</label>
                                    <select class="form-select form-select-sm">
                                        <option value="GENERAL">General Feedback</option>
                                        <option value="FINAL_EVAL">Final Evaluation Summary</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Review Note *</label>
                                    <textarea rows="3" required placeholder="Type review description..." class="form-control form-control-sm"></textarea>
                                </div>
                                <button type="submit" class="btn btn-primary btn-sm w-100">
                                    <i class="bi bi-save"></i> Log Note
                                </button>
                            </form>
                            
                            <div style="border-top: 1px solid var(--border-light); margin-top: 1rem; padding-top: 1rem; max-height: 200px; overflow-y: auto; display: flex; flex-direction: column; gap: 0.5rem;">
                                ${feedbacks.map(f => `
                                    <div style="font-size: 0.72rem; padding: 0.5rem; background: var(--primary-light); border: 1px solid var(--border-color);">
                                        <div style="display:flex; justify-content:space-between; margin-bottom: 0.25rem; border-bottom: 1px dashed var(--border-light); padding-bottom: 0.15rem;">
                                            <strong>${f.authorName}</strong>
                                            <span style="color:var(--text-muted); font-size: 0.65rem;">${f.createdAt}</span>
                                        </div>
                                        <p style="color:var(--text-main); line-height: 1.3;">${f.content}</p>
                                    </div>
                                `).join('')}
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        `;
    },

    // ── SUPERVISOR LOGBOOK AUDIT ──
    supervisorLogbookReview: function(studentId) {
        const logs = RT_MOCK_DATA.logbooks;
        return `
            <div style="margin-bottom: 1rem;">
                <a href="#/supervisor/students" class="btn btn-secondary btn-sm" style="text-decoration:none;">
                    <i class="bi bi-arrow-left"></i> Back to Directory
                </a>
            </div>

            <div class="rt-card">
                <div class="rt-card-header">
                    <span><i class="bi bi-book"></i> Student Weekly Logbooks Audit Trail</span>
                </div>
                <div class="rt-card-body" style="padding: 0;">
                    <div class="table-responsive">
                        <table class="rt-table">
                            <thead>
                                <tr>
                                    <th>Week</th>
                                    <th>Logged Hours</th>
                                    <th>Work Summary Details</th>
                                    <th>Staged Status</th>
                                    <th>Audit Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${logs.map(l => {
                                    let actionHtml = '';
                                    if (l.status === 'APPROVED') {
                                        actionHtml = `<span style="font-weight:700;"><i class="bi bi-check-circle"></i> Approved</span>`;
                                    } else {
                                        actionHtml = `
                                            <button class="btn btn-primary btn-sm" style="padding: 0.2rem 0.5rem; font-size: 0.7rem;" onclick="RT_APP.approveLogbookEntryAction(${l.week})">
                                                Approve Log
                                            </button>
                                        `;
                                    }
                                    return `
                                        <tr>
                                            <td style="font-weight: 700;">Week ${l.week}</td>
                                            <td><span class="badge badge-pending">${l.hours} hours</span></td>
                                            <td style="font-size: 0.78rem; line-height: 1.4; max-width: 400px;">${l.description}</td>
                                            <td>
                                                <span class="badge ${l.status === 'APPROVED' ? 'badge-active' : 'badge-review'}">${l.status}</span>
                                            </td>
                                            <td>${actionHtml}</td>
                                        </tr>
                                    `;
                                }).reverse().join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    },

    // ── SUPERVISOR DELIVERABLES REVIEW ──
    supervisorDocumentReview: function(studentId) {
        const docs = RT_MOCK_DATA.documents;
        return `
            <div style="margin-bottom: 1rem;">
                <a href="#/supervisor/students" class="btn btn-secondary btn-sm" style="text-decoration:none;">
                    <i class="bi bi-arrow-left"></i> Back to Directory
                </a>
            </div>

            <div class="rt-card">
                <div class="rt-card-header">
                    <span><i class="bi bi-cloud-arrow-up"></i> Deliverables Submissions Review</span>
                </div>
                <div class="rt-card-body" style="padding: 0;">
                    <div class="table-responsive">
                        <table class="rt-table">
                            <thead>
                                <tr>
                                    <th>Deliverable Category</th>
                                    <th>Staged File Name</th>
                                    <th>Staged Date</th>
                                    <th>Audit State</th>
                                    <th>Score Grade</th>
                                    <th>Scoring Evaluation</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${docs.map(d => {
                                    let actionHtml = '';
                                    if (d.status === 'APPROVED') {
                                        actionHtml = `<strong style="font-size: 0.8rem;">Recorded: ${d.grade}%</strong>`;
                                    } else {
                                        actionHtml = `
                                            <form onsubmit="RT_APP.gradeDocumentAction(event, '${d.docType}')" style="display:flex; gap:0.25rem; max-width:180px;">
                                                <input type="number" min="0" max="100" placeholder="Grade" required class="form-control form-control-sm" style="width:60px; padding:0.15rem 0.3rem;">
                                                <button type="submit" class="btn btn-primary btn-sm" style="padding: 0.15rem 0.35rem; font-size:0.7rem;">Submit</button>
                                            </form>
                                        `;
                                    }

                                    return `
                                        <tr>
                                            <td><strong>${d.docType}</strong></td>
                                            <td style="font-family: var(--font-mono); font-size:0.75rem; text-decoration:underline; cursor:pointer;" onclick="RT_APP.showFlash('Auditing file preview...', 'info')">
                                                <i class="bi bi-file-earmark-pdf"></i> ${d.fileName}
                                            </td>
                                            <td style="font-size:0.75rem; color:var(--text-muted);">${d.uploadedAt}</td>
                                            <td><span class="badge ${d.status === 'APPROVED' ? 'badge-active' : 'badge-review'}">${d.status}</span></td>
                                            <td><strong style="color:var(--text-main); font-size: 0.85rem;">${d.grade ? d.grade.toFixed(1) + '%' : '—'}</strong></td>
                                            <td>${actionHtml}</td>
                                        </tr>
                                    `;
                                }).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    },

    // ── SUPERVISOR PITA EVALUATION FORM ──
    supervisorPitaForm: function(id) {
        const proj = RT_MOCK_DATA.projects.find(p => p.id === id);
        if (!proj) return `<div class="rt-alert rt-alert-error">Project metadata not found.</div>`;

        return `
            <div style="margin-bottom: 1rem;">
                <a href="#/supervisor/students" class="btn btn-secondary btn-sm" style="text-decoration:none;">
                    <i class="bi bi-arrow-left"></i> Back to Directory
                </a>
            </div>

            <div class="rt-card">
                <div class="rt-card-header">
                    <span><i class="bi bi-calculator"></i> PITA Technical scorecard Form: ${proj.studentName}</span>
                </div>
                <div class="rt-card-body">
                    <p style="font-size:0.78rem; color:var(--text-muted); margin-bottom: 1.25rem;">
                        Select scores for parameters checking deployment and presentation metrics.
                    </p>

                    <form onsubmit="RT_APP.submitPitaAction(event, ${id})">
                        <!-- Parameter 1 -->
                        <div style="margin-bottom: 1.25rem; background: var(--primary-light); padding: 0.75rem; border: 1px solid var(--border-color);">
                            <h5 style="font-weight:750; font-size:0.85rem; margin-bottom: 0.35rem;">1. Docker Staging Build Success (Weight 5pts)</h5>
                            <p style="font-size:0.7rem; color:var(--text-muted); margin-bottom: 0.5rem;">Dockerfile compiles without errors, maps local ports cleanly.</p>
                            <div style="display:flex; gap:1.25rem; font-size: 0.78rem;">
                                <label><input type="radio" name="crit-1" value="5" onclick="RT_APP.calculatePitaScore()" checked> 5 - Full compile</label>
                                <label><input type="radio" name="crit-1" value="3" onclick="RT_APP.calculatePitaScore()"> 3 - Build warnings</label>
                                <label><input type="radio" name="crit-1" value="1" onclick="RT_APP.calculatePitaScore()"> 1 - Failed compile</label>
                            </div>
                        </div>

                        <!-- Parameter 2 -->
                        <div style="margin-bottom: 1.25rem; background: var(--primary-light); padding: 0.75rem; border: 1px solid var(--border-color);">
                            <h5 style="font-weight:750; font-size:0.85rem; margin-bottom: 0.35rem;">2. Log Streaming Integration (Weight 5pts)</h5>
                            <p style="font-size:0.7rem; color:var(--text-muted); margin-bottom: 0.5rem;">Console emulates SSE streams without package loss or timeouts.</p>
                            <div style="display:flex; gap:1.25rem; font-size: 0.78rem;">
                                <label><input type="radio" name="crit-2" value="5" onclick="RT_APP.calculatePitaScore()" checked> 5 - Solid stream</label>
                                <label><input type="radio" name="crit-2" value="3" onclick="RT_APP.calculatePitaScore()"> 3 - Intermittent log</label>
                                <label><input type="radio" name="crit-2" value="1" onclick="RT_APP.calculatePitaScore()"> 1 - Connection error</label>
                            </div>
                        </div>

                        <!-- Parameter 3 -->
                        <div style="margin-bottom: 1.25rem; background: var(--primary-light); padding: 0.75rem; border: 1px solid var(--border-color);">
                            <h5 style="font-weight:750; font-size:0.85rem; margin-bottom: 0.35rem;">3. Architecture Separation (Weight 5pts)</h5>
                            <p style="font-size:0.7rem; color:var(--text-muted); margin-bottom: 0.5rem;">Correct directory structure, clear entities models schema definition.</p>
                            <div style="display:flex; gap:1.25rem; font-size: 0.78rem;">
                                <label><input type="radio" name="crit-3" value="5" onclick="RT_APP.calculatePitaScore()" checked> 5 - Modular</label>
                                <label><input type="radio" name="crit-3" value="3" onclick="RT_APP.calculatePitaScore()"> 3 - Minor coupling</label>
                                <label><input type="radio" name="crit-3" value="1" onclick="RT_APP.calculatePitaScore()"> 1 - Unstructured</label>
                            </div>
                        </div>

                        <!-- Parameter 4 -->
                        <div style="margin-bottom: 1.25rem; background: var(--primary-light); padding: 0.75rem; border: 1px solid var(--border-color);">
                            <h5 style="font-weight:750; font-size:0.85rem; margin-bottom: 0.35rem;">4. Live oral demonstration (Weight 5pts)</h5>
                            <p style="font-size:0.7rem; color:var(--text-muted); margin-bottom: 0.5rem;">Clear explanation of database interfaces and sandbox execution.</p>
                            <div style="display:flex; gap:1.25rem; font-size: 0.78rem;">
                                <label><input type="radio" name="crit-4" value="5" onclick="RT_APP.calculatePitaScore()" checked> 5 - Professional</label>
                                <label><input type="radio" name="crit-4" value="3" onclick="RT_APP.calculatePitaScore()"> 3 - Moderate explain</label>
                                <label><input type="radio" name="crit-4" value="1" onclick="RT_APP.calculatePitaScore()"> 1 - Failed description</label>
                            </div>
                        </div>

                        <!-- Total calculation widget -->
                        <div style="display:flex; justify-content:space-between; align-items:center; background: var(--primary-light); padding:0.75rem 1rem; border:2px solid var(--border-color); margin-bottom: 1.25rem;">
                            <div>
                                <strong style="display:block; font-size:0.8rem; color:var(--text-main);">Scorecard Total:</strong>
                                <span style="font-size:0.68rem; color:var(--text-muted);">Reactive calculation summary</span>
                            </div>
                            <div style="text-align:right;">
                                <strong id="pita-score-sum" style="font-size:1.25rem; display:block; color:var(--text-main); line-height:1.1;">20/20</strong>
                                <span id="pita-score-percent" style="font-size:0.8rem; font-weight:700;">100.0%</span>
                            </div>
                        </div>

                        <div style="display:flex; justify-content:flex-end;">
                            <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Submit Scorecard Record</button>
                        </div>
                    </form>
                </div>
            </div>
        `;
    },

    // ── COORDINATOR DASHBOARD ──
    coordinatorDashboard: function() {
        const projects = RT_MOCK_DATA.projects;
        const supervisors = RT_MOCK_DATA.users.filter(u => u.role === 'SUPERVISOR');
        const unassigned = projects.filter(p => !p.supervisorId).length;

        return `
            <!-- Header -->
            <div style="margin-bottom: 1.5rem; border-bottom: 2px solid var(--border-color); padding-bottom: 0.75rem;">
                <h2 style="font-weight: 800; font-size: 1.5rem; letter-spacing: -0.02em;">Coordinator Command Workspace</h2>
                <p style="color: var(--text-muted); font-size: 0.8rem;">Grayscale wireframe schematic overviewing coordinator tasks.</p>
            </div>

            <!-- Stats -->
            <div class="grid-stats">
                <div class="card-stat">
                    <div class="stat-icon"><i class="bi bi-people"></i></div>
                    <div class="stat-info">
                        <div class="stat-value">${RT_MOCK_DATA.users.length}</div>
                        <div class="stat-label">Total Accounts</div>
                    </div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon"><i class="bi bi-exclamation-square"></i></div>
                    <div class="stat-info">
                        <div class="stat-value">${unassigned}</div>
                        <div class="stat-label">Unallocated Projects</div>
                    </div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon"><i class="bi bi-box-seam"></i></div>
                    <div class="stat-info">
                        <div class="stat-value">${projects.filter(p => p.dockerStatus === 'running').length}</div>
                        <div class="stat-label">Active Sandboxes</div>
                    </div>
                </div>
                <div class="card-stat">
                    <div class="stat-icon"><i class="bi bi-file-earmark-ruled"></i></div>
                    <div class="stat-info">
                        <div class="stat-value">${RT_MOCK_DATA.globalRequirements.length}</div>
                        <div class="stat-label">Staged Rules</div>
                    </div>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 1.25rem;">
                
                <!-- Supervisor list / workload assessment -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-people"></i> Supervisors Workloads index</span>
                            <a href="#/coordinator/projects" class="btn btn-secondary btn-sm" style="font-size: 0.65rem; padding: 0.15rem 0.4rem; text-decoration:none;">Allocate Tasks</a>
                        </div>
                        <div class="rt-card-body" style="padding: 0;">
                            <div class="table-responsive">
                                <table class="rt-table">
                                    <thead>
                                        <tr>
                                            <th>Supervisor Name</th>
                                            <th>Institutional Email</th>
                                            <th>Supervised Load</th>
                                            <th>PITA Evaluator Roles</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${supervisors.map(sv => {
                                            const load = projects.filter(p => p.supervisorId === sv.id).length;
                                            const eval1 = projects.filter(p => p.pita1Evaluators.includes(sv.id)).length;
                                            const eval2 = projects.filter(p => p.pita2Evaluators.includes(sv.id)).length;
                                            
                                            return `
                                                <tr>
                                                    <td><strong>${sv.fullName}</strong></td>
                                                    <td style="font-size:0.75rem; color:var(--text-muted);">${sv.email}</td>
                                                    <td><span class="badge badge-pending" style="font-size: 0.72rem;">${load} Projects</span></td>
                                                    <td>
                                                        <span class="badge badge-review" style="font-size:0.65rem;">P1: ${eval1}</span>
                                                        <span class="badge badge-completed" style="font-size:0.65rem;">P2: ${eval2}</span>
                                                    </td>
                                                </tr>
                                            `;
                                        }).join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Live staging server stats -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-cpu"></i> VM Resources simulation</span>
                            <a href="#/coordinator/docker" class="btn btn-secondary btn-sm" style="font-size: 0.65rem; padding: 0.15rem 0.4rem; text-decoration:none;">Docker Registry</a>
                        </div>
                        <div class="rt-card-body">
                            <div class="chart-sim-container">
                                <div class="chart-bar-row">
                                    <div class="chart-bar-label">
                                        <span>Staging VM CPU</span>
                                        <span id="cpu-lbl">45%</span>
                                    </div>
                                    <div class="chart-bar-bg">
                                        <div class="chart-bar-fill" id="cpu-bar" style="width: 45%;"></div>
                                    </div>
                                </div>
                                <div class="chart-bar-row">
                                    <div class="chart-bar-label">
                                        <span>Allocated Staged RAM</span>
                                        <span id="ram-lbl">72%</span>
                                    </div>
                                    <div class="chart-bar-bg">
                                        <div class="chart-bar-fill" id="ram-bar" style="width: 72%;"></div>
                                    </div>
                                </div>
                                <div class="chart-bar-row" style="margin-bottom: 0;">
                                    <div class="chart-bar-label">
                                        <span>VM Registry Disk volume</span>
                                        <span id="disk-lbl">38%</span>
                                    </div>
                                    <div class="chart-bar-bg">
                                        <div class="chart-bar-fill" id="disk-bar" style="width: 38%;"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        `;
    },

    // ── COORDINATOR USERS ──
    coordinatorUsers: function() {
        const users = RT_MOCK_DATA.users;
        return `
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; border-bottom: 2px solid var(--border-color); padding-bottom: 0.75rem;">
                <div>
                    <h2 style="font-weight: 800; font-size: 1.5rem; letter-spacing: -0.02em;">Accounts Registry</h2>
                    <p style="color: var(--text-muted); font-size: 0.8rem;">Grayscale directory mapping active cohort profiles.</p>
                </div>
                <div style="display: flex; gap: 0.35rem;">
                    <button class="btn btn-secondary" onclick="RT_APP.openModal('import-users-modal')">
                        <i class="bi bi-upload"></i> Import CSV Sheet
                    </button>
                    <button class="btn btn-primary" onclick="RT_APP.showFlash('Edit user dialog staged.', 'info')">
                        <i class="bi bi-plus-lg"></i> Register Profile
                    </button>
                </div>
            </div>

            <div class="rt-card">
                <div class="rt-card-header">
                    <span><i class="bi bi-people"></i> Active Registered Profiles</span>
                    <span class="badge" style="background:#e5e7eb; color:#111827;">Total: ${users.length}</span>
                </div>
                <div class="rt-card-body" style="padding: 0;">
                    <div class="table-responsive">
                        <table class="rt-table">
                            <thead>
                                <tr>
                                    <th>Profile Display Name</th>
                                    <th>username</th>
                                    <th>institutional Email</th>
                                    <th>System Role</th>
                                    <th>Identifier Code</th>
                                    <th>Audit Settings</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${users.map(u => `
                                    <tr>
                                        <td>
                                            <div style="display:flex; align-items:center; gap:0.5rem;">
                                                <div class="sidebar-user-avatar" style="width:24px; height:24px; font-size:0.7rem; background:var(--primary-light); border:1px solid var(--border-color);">${u.avatar}</div>
                                                <strong>${u.fullName}</strong>
                                            </div>
                                        </td>
                                        <td style="font-family:var(--font-mono); font-size:0.78rem;">${u.username}</td>
                                        <td style="font-size:0.75rem; color:var(--text-muted);">${u.email}</td>
                                        <td><span class="badge ${u.role === 'COORDINATOR' ? 'badge-active' : 'badge-pending'}" style="font-size:0.6rem;">${u.role}</span></td>
                                        <td style="font-size:0.75rem; color:var(--text-muted);">${u.studentId || '—'}</td>
                                        <td>
                                            <div style="display:flex; gap:0.25rem;">
                                                <button class="btn btn-secondary btn-sm" style="padding:0.2rem 0.35rem;" onclick="RT_APP.showFlash('Edit fields staged.', 'info')"><i class="bi bi-pencil-square"></i></button>
                                                <button class="btn btn-danger btn-sm" style="padding:0.2rem 0.35rem;" onclick="if(confirm('Delete user profile?')) { RT_MOCK_DATA.users = RT_MOCK_DATA.users.filter(x=>x.id !== ${u.id}); RT_APP.router(); }"><i class="bi bi-trash"></i></button>
                                            </div>
                                        </td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    },

    // ── COORDINATOR PROJECTS LIST ──
    coordinatorProjects: function() {
        const projects = RT_MOCK_DATA.projects;
        return `
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; border-bottom: 2px solid var(--border-color); padding-bottom: 0.75rem;">
                <div>
                    <h2 style="font-weight: 800; font-size: 1.5rem; letter-spacing: -0.02em;">Allocations Directory</h2>
                    <p style="color: var(--text-muted); font-size: 0.8rem;">Staging index mapping students to supervisors workload balancing.</p>
                </div>
                <button class="btn btn-primary" onclick="RT_APP.autoAssignCohortAction()">
                    <i class="bi bi-magic"></i> Auto-Allocate Cohort
                </button>
            </div>

            <div class="rt-card">
                <div class="rt-card-header" style="background: var(--primary-light); display: flex; gap: 0.5rem; flex-wrap: wrap; padding: 0.5rem 0.75rem;">
                    <input type="text" placeholder="Filter topic, student, or supervisor..." class="form-control" style="max-width: 240px; padding: 0.3rem 0.5rem; font-size: 0.75rem;" oninput="RT_APP.filterProjectsTable(this.value.toLowerCase(), document.getElementById('filter-status').value, document.getElementById('filter-assign').value)" id="search-proj">
                    
                    <select class="form-select" style="max-width: 130px; padding: 0.3rem 0.5rem; font-size: 0.75rem;" id="filter-status" onchange="RT_APP.filterProjectsTable(document.getElementById('search-proj').value.toLowerCase(), this.value, document.getElementById('filter-assign').value)">
                        <option value="">All Statuses</option>
                        <option value="PENDING">Pending</option>
                        <option value="ACTIVE">Active</option>
                        <option value="COMPLETED">Completed</option>
                    </select>

                    <select class="form-select" style="max-width: 150px; padding: 0.3rem 0.5rem; font-size: 0.75rem;" id="filter-assign" onchange="RT_APP.filterProjectsTable(document.getElementById('search-proj').value.toLowerCase(), document.getElementById('filter-status').value, this.value)">
                        <option value="">All Allocations</option>
                        <option value="assigned">Allocated</option>
                        <option value="unassigned">Unallocated</option>
                    </select>

                    <span class="badge" style="background:#111827; color:#ffffff; margin-left:auto; display:flex; align-items:center;" id="visibleCount">${projects.length}</span>
                </div>

                <div class="rt-card-body" style="padding: 0;">
                    <div class="table-responsive">
                        <table class="rt-table" id="projectsTable">
                            <thead>
                                <tr>
                                    <th>Staged Topic & GitHub Repository</th>
                                    <th>Student Credentials</th>
                                    <th>Allocated Supervisor</th>
                                    <th>Staged Status</th>
                                    <th>Staging Container</th>
                                    <th>Audit Config</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${projects.map(p => {
                                    const isAssigned = p.supervisorId !== null;
                                    const badgeClass = p.status === 'ACTIVE' ? 'badge-active' : (p.status === 'PENDING' ? 'badge-pending' : 'badge-completed');
                                    
                                    return `
                                        <tr data-title="${p.title.toLowerCase()}" data-repo="${p.repoUrl.toLowerCase()}" data-student="${p.studentName.toLowerCase()}" data-supervisor="${p.supervisorName ? p.supervisorName.toLowerCase() : ''}" data-status="${p.status}" data-assigned="${isAssigned ? 'assigned' : 'unassigned'}">
                                            <td>
                                                <strong style="display:block; font-size: 0.82rem; max-width: 250px;" class="text-truncate" title="${p.title}">${p.title}</strong>
                                                <span style="font-size:0.7rem; color:var(--text-muted); font-family:var(--font-mono);">${p.repoUrl.replace('https://github.com/', '')}</span>
                                            </td>
                                            <td>
                                                <strong style="display:block; font-size:0.8rem;">${p.studentName}</strong>
                                                <span style="font-size:0.65rem; color:var(--text-muted);">ID: ${p.studentId}</span>
                                            </td>
                                            <td>
                                                ${isAssigned ? `
                                                    <strong style="display:block; font-size:0.8rem;">${p.supervisorName}</strong>
                                                    <span style="font-size: 0.65rem; font-weight:700;">Allocated</span>
                                                ` : `
                                                    <div style="display:flex; gap:0.25rem; align-items:center;">
                                                        <span class="badge badge-pending" style="font-size:0.58rem;">Unallocated</span>
                                                        <button class="btn btn-secondary btn-sm" style="font-size:0.6rem; padding:0.1rem 0.25rem;" onclick="RT_APP.openAssignSupervisor(${p.id})"><i class="bi bi-person-plus"></i></button>
                                                    </div>
                                                `}
                                            </td>
                                            <td><span class="badge ${badgeClass}">${p.status}</span></td>
                                            <td>
                                                <span style="font-size:0.75rem; font-weight:700; color:${p.dockerStatus==='running' ? 'var(--text-main)' : 'var(--text-muted)'};">
                                                    <i class="bi bi-circle-fill" style="font-size:5px; vertical-align:middle;"></i> ${p.dockerStatus}
                                                </span>
                                            </td>
                                            <td>
                                                <div style="display:flex; gap:0.25rem;">
                                                    <a href="#/coordinator/project/${p.id}" class="btn btn-secondary btn-sm" style="font-size:0.7rem; padding: 0.2rem 0.4rem; text-decoration:none;"><i class="bi bi-gear"></i> Manage</a>
                                                    <button class="btn btn-danger btn-sm" style="padding:0.2rem 0.35rem;" onclick="if(confirm('Delete staged project record?')) { RT_MOCK_DATA.projects = RT_MOCK_DATA.projects.filter(x=>x.id !== ${p.id}); RT_APP.router(); }"><i class="bi bi-trash"></i></button>
                                                </div>
                                            </td>
                                        </tr>
                                    `;
                                }).join('')}
                            </tbody>
                        </table>
                        <div id="noResults" style="display:none; padding:2rem; text-align:center; color:var(--text-muted); font-size:0.8rem;">
                            <i class="bi bi-search" style="font-size:1.5rem; display:block; margin-bottom:0.5rem;"></i>
                            <span>No projects match search query.</span>
                        </div>
                    </div>
                </div>
            </div>
        `;
    },

    // ── COORDINATOR PROJECT ALLOCATION DETAIL ──
    coordinatorProjectDetail: function(id) {
        const proj = RT_MOCK_DATA.projects.find(p => p.id === id);
        if (!proj) return `<div class="rt-alert rt-alert-error">Project metadata not found.</div>`;

        const supervisors = RT_MOCK_DATA.users.filter(u => u.role === 'SUPERVISOR');
        const p1Eval = RT_MOCK_DATA.users.filter(u => proj.pita1Evaluators.includes(u.id));
        const p2Eval = RT_MOCK_DATA.users.filter(u => proj.pita2Evaluators.includes(u.id));

        return `
            <div style="margin-bottom: 1rem;">
                <a href="#/coordinator/projects" class="btn btn-secondary btn-sm" style="text-decoration:none;">
                    <i class="bi bi-arrow-left"></i> Back to Directory
                </a>
            </div>

            <div class="rt-card" style="margin-bottom: 1.5rem;">
                <div class="rt-card-body" style="padding: 1rem; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem;">
                    <div>
                        <div style="display:flex; align-items:center; gap:0.5rem; margin-bottom:0.25rem;">
                            <h2 style="font-weight: 800; font-size: 1.35rem; letter-spacing: -0.02em;">${proj.title}</h2>
                            <span class="badge badge-active">${proj.status}</span>
                        </div>
                        <span style="font-size:0.78rem; color:var(--text-muted);">Student ID: <strong>${proj.studentName}</strong> (${proj.studentId}) &middot; Git Spec: <a href="${proj.repoUrl}" target="_blank" style="font-family:var(--font-mono);">${proj.repoUrl}</a></span>
                    </div>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 1.25rem;">
                
                <!-- Left: Supervisor assignment & evaluators -->
                <div>
                    <!-- Manual Assignment form -->
                    <div class="rt-card" style="margin-bottom:1.25rem;">
                        <div class="rt-card-header">
                            <span><i class="bi bi-person-check"></i> Assign Supervisor Profile</span>
                        </div>
                        <div class="rt-card-body">
                            <form onsubmit="event.preventDefault(); const svId=parseInt(document.getElementById('det-sv-select').value); const sv=RT_MOCK_DATA.users.find(u=>u.id===svId); if(sv){proj.supervisorId=sv.id; proj.supervisorName=sv.fullName; RT_APP.router(); }">
                                <div style="display:flex; gap:0.35rem;">
                                    <select id="det-sv-select" required class="form-select form-select-sm">
                                        <option value="">— Select Supervisor Profile —</option>
                                        ${supervisors.map(sv => `<option value="${sv.id}" ${proj.supervisorId === sv.id ? 'selected' : ''}>${sv.fullName} (${sv.email})</option>`).join('')}
                                    </select>
                                    <button type="submit" class="btn btn-primary btn-sm" style="white-space:nowrap;"><i class="bi bi-person-check"></i> Allocate</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- PITA 1 panel -->
                    <div class="rt-card" style="margin-bottom:1.25rem;">
                        <div class="rt-card-header">
                            <span><i class="bi bi-file-earmark-text"></i> PITA-01 Evaluators (Max 3)</span>
                        </div>
                        <div class="rt-card-body">
                            <div style="display:flex; flex-direction:column; gap:0.35rem; margin-bottom:0.75rem;">
                                ${p1Eval.length === 0 ? `<div style="font-size:0.75rem; color:var(--text-muted); font-style:italic;">No evaluators assigned.</div>` : p1Eval.map(ev => `
                                    <div style="display:flex; justify-content:space-between; align-items:center; background:var(--primary-light); padding:0.4rem; border:1px solid var(--border-color); font-size:0.75rem;">
                                        <span><strong>${ev.fullName}</strong> (${ev.email})</span>
                                        <button class="btn btn-secondary btn-sm" style="border:none; padding:0.1rem 0.25rem;" onclick="RT_APP.removeEvaluatorAction('PITA1', ${id}, ${ev.id})"><i class="bi bi-x-circle text-danger"></i></button>
                                    </div>
                                `).join('')}
                            </div>
                            
                            ${proj.pita1Evaluators.length < 3 ? `
                                <form onsubmit="RT_APP.addEvaluatorAction(event, 'PITA1', ${id})" style="display:flex; gap:0.35rem;">
                                    <select required class="form-select form-select-sm">
                                        <option value="">— Add PITA-01 Evaluator —</option>
                                        ${supervisors.filter(sv => !proj.pita1Evaluators.includes(sv.id)).map(sv => `<option value="${sv.id}">${sv.fullName}</option>`).join('')}
                                    </select>
                                    <button type="submit" class="btn btn-secondary btn-sm"><i class="bi bi-plus-lg"></i> Add</button>
                                </form>
                            ` : ''}
                        </div>
                    </div>

                    <!-- PITA 2 panel -->
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-file-earmark-spreadsheet"></i> PITA-02 Panel Evaluators (Max 3)</span>
                        </div>
                        <div class="rt-card-body">
                            <div style="display:flex; flex-direction:column; gap:0.35rem; margin-bottom:0.75rem;">
                                ${p2Eval.length === 0 ? `<div style="font-size:0.75rem; color:var(--text-muted); font-style:italic;">No evaluators assigned.</div>` : p2Eval.map(ev => `
                                    <div style="display:flex; justify-content:space-between; align-items:center; background:var(--primary-light); padding:0.4rem; border:1px solid var(--border-color); font-size:0.75rem;">
                                        <span><strong>${ev.fullName}</strong> (${ev.email})</span>
                                        <button class="btn btn-secondary btn-sm" style="border:none; padding:0.1rem 0.25rem;" onclick="RT_APP.removeEvaluatorAction('PITA2', ${id}, ${ev.id})"><i class="bi bi-x-circle text-danger"></i></button>
                                    </div>
                                `).join('')}
                            </div>
                            
                            ${proj.pita2Evaluators.length < 3 ? `
                                <form onsubmit="RT_APP.addEvaluatorAction(event, 'PITA2', ${id})" style="display:flex; gap:0.35rem;">
                                    <select required class="form-select form-select-sm">
                                        <option value="">— Add PITA-02 Evaluator —</option>
                                        ${supervisors.filter(sv => !proj.pita2Evaluators.includes(sv.id)).map(sv => `<option value="${sv.id}">${sv.fullName}</option>`).join('')}
                                    </select>
                                    <button type="submit" class="btn btn-secondary btn-sm"><i class="bi bi-plus-lg"></i> Add</button>
                                </form>
                            ` : ''}
                        </div>
                    </div>
                </div>

                <!-- Right: Daily limits editor & metadata actions -->
                <div>
                    <!-- Daily docker Cap hours -->
                    <div class="rt-card" style="margin-bottom:1.25rem;">
                        <div class="rt-card-header">
                            <span><i class="bi bi-clock"></i> Staging VM Cap limits</span>
                        </div>
                        <div class="rt-card-body">
                            <form onsubmit="event.preventDefault(); const cap=parseFloat(document.getElementById('det-cap').value); proj.runningLimitSeconds=cap*3600; RT_APP.router();">
                                <div class="form-group">
                                    <label class="form-label">VM Running Cap Hour limit</label>
                                    <input type="number" step="0.5" id="det-cap" min="0.5" max="24" value="${proj.runningLimitSeconds / 3600}" required class="form-control form-control-sm">
                                </div>
                                <button type="submit" class="btn btn-primary btn-sm w-100"><i class="bi bi-save"></i> Save Limits</button>
                            </form>
                        </div>
                    </div>

                    <!-- Global Project Actions -->
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-exclamation-triangle"></i> Administrative Actions</span>
                        </div>
                        <div class="rt-card-body" style="display:flex; flex-direction:column; gap:0.35rem;">
                            <button class="btn btn-outline-primary btn-sm w-100" onclick="if(confirm('Mark project COMPLETED?')){proj.status='COMPLETED'; RT_APP.router(); }"><i class="bi bi-check-circle"></i> Complete Project</button>
                            <button class="btn btn-outline-primary btn-sm w-100" onclick="if(confirm('Reject project submissions?')){proj.status='REJECTED'; RT_APP.router(); }"><i class="bi bi-x-circle text-danger"></i> Reject Project</button>
                            <div style="border-top: 1px solid var(--border-light); margin-top:0.35rem; padding-top:0.35rem;"></div>
                            <button class="btn btn-danger btn-sm w-100" onclick="if(confirm('Permanently delete project records?')){RT_MOCK_DATA.projects=RT_MOCK_DATA.projects.filter(x=>x.id!==${id}); window.location.hash='#/coordinator/projects'; }"><i class="bi bi-trash"></i> Delete Project</button>
                        </div>
                    </div>
                </div>

            </div>
        `;
    },

    // ── COORDINATOR QUICK ACCESS TILES EDITOR ──
    coordinatorMenu: function() {
        const tiles = RT_MOCK_DATA.menuItems;
        return `
            <div style="display: grid; grid-template-columns: 1fr 1.5fr; gap: 1.25rem;">
                
                <!-- Tile Creator Form -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-grid-plus"></i> Add Dashboard Navigation Tile</span>
                        </div>
                        <div class="rt-card-body">
                            <form onsubmit="RT_APP.addNewTileAction(event)">
                                <div class="form-group">
                                    <label class="form-label">Tile Name Label *</label>
                                    <input type="text" id="tile-lbl" required placeholder="e.g. Docker logs" class="form-control">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">View URL Hash Path *</label>
                                    <input type="text" id="tile-url" required value="#/student/project/1" class="form-control">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Bootstrap Icon Class *</label>
                                    <input type="text" id="tile-icon" required value="bi bi-terminal" class="form-control">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Grayscale Accent Value *</label>
                                    <input type="color" id="tile-color" required value="#374151" class="form-control" style="height:35px;">
                                </div>
                                <button type="submit" class="btn btn-primary w-100">
                                    <i class="bi bi-plus-lg"></i> Create Active Tile
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Existing Tiles -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-grid-3x3-gap"></i> Student Dashboard Navigation Blocks</span>
                            <span class="badge" style="background:#e5e7eb; color:#111827;">Active: ${tiles.length}</span>
                        </div>
                        <div class="rt-card-body" style="padding: 0;">
                            <div class="table-responsive">
                                <table class="rt-table">
                                    <thead>
                                        <tr>
                                            <th>Tile Icon</th>
                                            <th>Label</th>
                                            <th>Hash URL</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${tiles.map(t => `
                                            <tr>
                                                <td><i class="${t.icon}" style="font-size:1.25rem;"></i></td>
                                                <td><strong>${t.label}</strong></td>
                                                <td style="font-family:var(--font-mono); font-size:0.75rem; color:var(--text-muted);">${t.url}</td>
                                                <td>
                                                    <button class="btn btn-danger btn-sm" style="padding:0.15rem 0.35rem;" onclick="RT_MOCK_DATA.menuItems=RT_MOCK_DATA.menuItems.filter(x=>x.id!==${t.id}); RT_APP.router();"><i class="bi bi-x"></i> Delete</button>
                                                </td>
                                            </tr>
                                        `).join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        `;
    },

    // ── COORDINATOR DOCKER VM REGISTRY MONITOR ──
    coordinatorDocker: function() {
        return `
            <div style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 1.25rem;">
                
                <!-- Live Output streaming -->
                <div>
                    <div class="rt-card" style="margin-bottom:0;">
                        <div class="rt-card-header">
                            <span><i class="bi bi-terminal"></i> Docker Logging output terminal simulator</span>
                            <span class="badge badge-active">Active logs stream</span>
                        </div>
                        <div class="rt-card-body" style="padding:0;">
                            <div class="docker-terminal" id="term-log-stream">
                                <!-- Populated dynamically by stream simulation in app.js -->
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Container lists -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-hdd-network"></i> staged Sandbox Registry Index</span>
                        </div>
                        <div class="rt-card-body" style="padding:0;">
                            <div class="table-responsive">
                                <table class="rt-table">
                                    <thead>
                                        <tr>
                                            <th>Container Staging ID</th>
                                            <th>Staging status</th>
                                            <th>Hour Limits</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${RT_MOCK_DATA.projects.map(p => `
                                            <tr>
                                                <td>
                                                    <strong style="display:block; font-size: 0.8rem;">${p.dockerStatus === 'none' ? '—' : p.title.toLowerCase().replace(/\\s/g, '-') + '-stg'}</strong>
                                                    <span style="font-size:0.68rem; color:var(--text-muted); font-family:var(--font-mono);">${p.dockerStatus === 'none' ? 'No staging deployed' : 'Target Port: 8080'}</span>
                                                </td>
                                                <td>
                                                    <span class="badge ${p.dockerStatus==='running' ? 'badge-active' : 'badge-pending'}">${p.dockerStatus}</span>
                                                </td>
                                                <td style="font-size:0.75rem; color:var(--text-muted); font-weight:700;">${p.runningLimitSeconds / 3600}h limit</td>
                                            </tr>
                                        `).join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        `;
    },

    // ── COORDINATOR REQUIREMENTS SETUP ──
    coordinatorDocuments: function() {
        const reqs = RT_MOCK_DATA.globalRequirements;
        return `
            <div style="display: grid; grid-template-columns: 1fr 1.5fr; gap: 1.25rem;">
                
                <!-- Setup Requirement -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-calendar-plus"></i> Stage Deliverable Rule</span>
                        </div>
                        <div class="rt-card-body">
                            <form onsubmit="event.preventDefault(); const title=document.getElementById('req-lbl').value; const weight=parseInt(document.getElementById('req-weight').value); const due=document.getElementById('req-due').value; RT_MOCK_DATA.globalRequirements.push({id:RT_MOCK_DATA.globalRequirements.length+1, title, weight, dueDate:due, description:'Official requirements check.'}); RT_APP.router();">
                                <div class="form-group">
                                    <label class="form-label">Deliverable Name Label *</label>
                                    <input type="text" id="req-lbl" required placeholder="e.g. Midterm Report v2" class="form-control">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Grade weight Percentage *</label>
                                    <input type="number" id="req-weight" required min="1" max="100" placeholder="e.g. 20" class="form-control">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Global Submission Deadline *</label>
                                    <input type="date" id="req-due" required class="form-control">
                                </div>
                                <button type="submit" class="btn btn-primary w-100">
                                    <i class="bi bi-save"></i> Stage Deliverable Rule
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Existing Rules -->
                <div>
                    <div class="rt-card">
                        <div class="rt-card-header">
                            <span><i class="bi bi-calendar-check"></i> Staged Deliverable deadlines</span>
                            <span class="badge" style="background:#e5e7eb; color:#111827;">Active: ${reqs.length}</span>
                        </div>
                        <div class="rt-card-body" style="padding: 0;">
                            <div class="table-responsive">
                                <table class="rt-table">
                                    <thead>
                                        <tr>
                                            <th>Deliverable Rule Name</th>
                                            <th>Grade weight</th>
                                            <th>Global Deadline</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${reqs.map(r => `
                                            <tr>
                                                <td>
                                                    <strong style="display:block; font-size:0.82rem;">${r.title}</strong>
                                                    <span style="font-size:0.7rem; color:var(--text-muted);">${r.description}</span>
                                                </td>
                                                <td><span class="badge badge-pending">${r.weight}% Weight</span></td>
                                                <td style="font-size:0.78rem; color:var(--text-muted); font-family:var(--font-mono);">${r.dueDate}</td>
                                                <td>
                                                    <button class="btn btn-danger btn-sm" style="padding:0.15rem 0.35rem;" onclick="RT_MOCK_DATA.globalRequirements=RT_MOCK_DATA.globalRequirements.filter(x=>x.id!==${r.id}); RT_APP.router();"><i class="bi bi-trash"></i> Delete</button>
                                                </td>
                                            </tr>
                                        `).join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        `;
    }
};

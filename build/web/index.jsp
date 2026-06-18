<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // Set Cache-Control headers to prevent browser caching of the landing/login check page
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies

    // Logged-in users go straight to their dashboard
    String role = (String) session.getAttribute("userRole");
    String ctx = request.getContextPath();
    if ("STUDENT".equals(role)) {
        response.sendRedirect(ctx + "/student/dashboard");
        return;
    } else if ("SUPERVISOR".equals(role)) {
        response.sendRedirect(ctx + "/supervisor/dashboard");
        return;
    } else if ("COORDINATOR".equals(role)) {
        response.sendRedirect(ctx + "/coordinator/dashboard");
        return;
    }

    // Read error from redirect parameter
    String errorParam = request.getParameter("error");
    String loginError = null;
    if ("invalid".equals(errorParam)) {
        loginError = "Invalid username or password.";
    } else if ("system".equals(errorParam)) {
        loginError = "A system error occurred. Please try again.";
    } else if ("recaptcha".equals(errorParam)) {
        loginError = "Please verify that you are not a robot.";
    } else if (errorParam != null && !errorParam.isEmpty()) {
        loginError = errorParam; // decoded message from IllegalArgumentException
    }

    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>RailTrack | home</title>
        <!-- Favicon - PNG -->
        <link rel="icon" type="image/png" href="/RailTrack/img/roadway.png" sizes="32x32">
        <!-- Additional sizes for better support -->
        <link rel="icon" type="image/png" href="/RailTrack/img/roadway.png" sizes="16x16">
        <!-- Apple Touch Icon (iOS) -->
        <link rel="apple-touch-icon" href="/RailTrack/img/roadway.png">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"/>
        <script src="https://www.google.com/recaptcha/api.js" async defer></script>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
        <link rel="preconnect" href="https://fonts.googleapis.com"/>
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
        <link href="https://fonts.googleapis.com/css2?family=DM+Sans:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet"/>
        <style>
            :root {
                --rt-primary:    #2563eb;
                --rt-primary-dk: #1d4ed8;
                --rt-surface:    #ffffff;
                --rt-bg:         #f4f6fb;
                --rt-border:     #e5e9f2;
                --rt-text:       #1e2740;
                --rt-muted:      #6b7a99;
                --rt-success:    #16a34a;
                --rt-warning:    #d97706;
                --rt-danger:     #dc2626;
                --rt-radius:     10px;
                --rt-shadow:     0 1px 4px rgba(30,39,64,.08);
                --rt-shadow-lg:  0 8px 32px rgba(30,39,64,.12);
            }
            *, *::before, *::after {
                box-sizing: border-box;
            }
            html {
                scroll-behavior: smooth;
            }
            body {
                font-family: 'DM Sans', sans-serif;
                background: var(--rt-bg);
                color: var(--rt-text);
                margin: 0;
            }

            /* ── Navbar ── */
            .rt-nav {
                height: 64px;
                background: rgba(255,255,255,.92);
                backdrop-filter: blur(12px);
                border-bottom: 1px solid var(--rt-border);
                display: flex;
                align-items: center;
                padding: 0 2rem;
                gap: 1rem;
                position: sticky;
                top: 0;
                z-index: 100;
                box-shadow: var(--rt-shadow);
            }
            .rt-nav-brand {
                display: flex;
                align-items: center;
                gap: .6rem;
                text-decoration: none;
                font-weight: 700;
                font-size: 1.1rem;
                color: var(--rt-text);
                letter-spacing: -.02em;
            }
            .rt-nav-brand small {
                font-weight: 400;
                font-size: .62rem;
                color: var(--rt-muted);
                display: block;
                line-height: 1;
            }
            .rt-nav-links {
                display: flex;
                gap: 1.75rem;
                align-items: center;
            }
            .rt-nav-links a {
                font-size: .875rem;
                color: var(--rt-muted);
                text-decoration: none;
                font-weight: 500;
                transition: color .15s;
            }
            .rt-nav-links a:hover {
                color: var(--rt-primary);
            }
            .rt-nav-spacer {
                flex: 1;
            }

            /* ── Hero ── */
            .hero {
                background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 50%, #1d4ed8 100%);
                color: #fff;
                padding: 5rem 1.5rem 4rem;
                text-align: center;
                position: relative;
                overflow: hidden;
            }
            .hero::before {
                content: '';
                position: absolute;
                inset: 0;
                background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.03'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
            }
            .hero-badge {
                display: inline-flex;
                align-items: center;
                gap: .4rem;
                background: rgba(255,255,255,.12);
                border: 1px solid rgba(255,255,255,.2);
                border-radius: 999px;
                padding: .3rem .9rem;
                font-size: .75rem;
                font-weight: 600;
                letter-spacing: .05em;
                text-transform: uppercase;
                margin-bottom: 1.5rem;
                color: #93c5fd;
            }
            .hero h1 {
                font-size: clamp(2.2rem, 5vw, 3.5rem);
                font-weight: 700;
                letter-spacing: -.03em;
                line-height: 1.15;
                margin-bottom: 1.25rem;
            }
            .hero h1 span {
                color: #60a5fa;
            }
            .hero p {
                font-size: 1.1rem;
                color: #bfdbfe;
                max-width: 560px;
                margin: 0 auto 2.5rem;
                line-height: 1.7;
            }
            .hero-cta {
                display: flex;
                gap: 1rem;
                justify-content: center;
                flex-wrap: wrap;
            }
            .btn-hero-primary {
                background: #fff;
                color: var(--rt-primary);
                font-weight: 600;
                font-size: .95rem;
                padding: .75rem 2rem;
                border-radius: 8px;
                border: none;
                text-decoration: none;
                transition: all .2s;
                display: inline-flex;
                align-items: center;
                gap: .4rem;
                cursor: pointer;
            }
            .btn-hero-primary:hover {
                background: #eff6ff;
                color: var(--rt-primary-dk);
                transform: translateY(-1px);
                box-shadow: 0 4px 16px rgba(0,0,0,.2);
            }
            .btn-hero-outline {
                background: transparent;
                color: #fff;
                font-weight: 500;
                font-size: .95rem;
                padding: .75rem 2rem;
                border-radius: 8px;
                border: 1px solid rgba(255,255,255,.35);
                text-decoration: none;
                transition: all .2s;
                display: inline-flex;
                align-items: center;
                gap: .4rem;
            }
            .btn-hero-outline:hover {
                background: rgba(255,255,255,.1);
                color: #fff;
                border-color: rgba(255,255,255,.6);
            }
            .hero-stats {
                display: flex;
                justify-content: center;
                gap: 3rem;
                margin-top: 3.5rem;
                flex-wrap: wrap;
            }
            .hero-stat {
                text-align: center;
            }
            .hero-stat .num {
                font-size: 2rem;
                font-weight: 700;
                color: #fff;
                line-height: 1;
            }
            .hero-stat .lbl {
                font-size: .75rem;
                color: #93c5fd;
                margin-top: .25rem;
                font-weight: 500;
            }

            /* ── Sections ── */
            .section {
                padding: 5rem 1.5rem;
            }
            .section-alt {
                background: var(--rt-surface);
            }
            .section-label {
                font-size: .72rem;
                font-weight: 700;
                letter-spacing: .1em;
                text-transform: uppercase;
                color: var(--rt-primary);
                margin-bottom: .75rem;
            }
            .section-title {
                font-size: clamp(1.6rem, 3vw, 2.2rem);
                font-weight: 700;
                letter-spacing: -.02em;
                margin-bottom: 1rem;
            }
            .section-sub {
                color: var(--rt-muted);
                font-size: 1rem;
                max-width: 520px;
                line-height: 1.7;
            }

            /* ── Problem cards ── */
            .problem-card {
                background: #fff;
                border: 1px solid var(--rt-border);
                border-radius: 12px;
                padding: 1.5rem;
                height: 100%;
                transition: box-shadow .2s, transform .2s;
            }
            .problem-card:hover {
                box-shadow: var(--rt-shadow-lg);
                transform: translateY(-2px);
            }
            .problem-icon {
                width: 44px;
                height: 44px;
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.3rem;
                margin-bottom: 1rem;
            }

            /* ── Feature grid ── */
            .feature-item {
                display: flex;
                gap: 1rem;
                align-items: flex-start;
                padding: 1.25rem;
                border-radius: 12px;
                transition: background .15s;
            }
            .feature-item:hover {
                background: var(--rt-bg);
            }
            .feature-icon {
                width: 40px;
                height: 40px;
                border-radius: 10px;
                background: #eff6ff;
                color: var(--rt-primary);
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.1rem;
                flex-shrink: 0;
            }
            .feature-icon.green  {
                background: #f0fdf4;
                color: var(--rt-success);
            }
            .feature-icon.orange {
                background: #fffbeb;
                color: var(--rt-warning);
            }
            .feature-icon.red    {
                background: #fef2f2;
                color: var(--rt-danger);
            }
            .feature-icon.cyan   {
                background: #ecfeff;
                color: #0891b2;
            }
            .feature-icon.purple {
                background: #f5f3ff;
                color: #7c3aed;
            }

            /* ── Role cards ── */
            .role-card {
                background: #fff;
                border: 1px solid var(--rt-border);
                border-radius: 16px;
                padding: 2rem 1.5rem;
                height: 100%;
                text-align: center;
                transition: all .2s;
                position: relative;
                overflow: hidden;
            }
            .role-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
            }
            .role-card.student::before    {
                background: var(--rt-primary);
            }
            .role-card.supervisor::before {
                background: var(--rt-success);
            }
            .role-card.coordinator::before{
                background: var(--rt-warning);
            }
            .role-card:hover {
                box-shadow: var(--rt-shadow-lg);
                transform: translateY(-3px);
            }
            .role-avatar {
                width: 64px;
                height: 64px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.6rem;
                margin: 0 auto 1.25rem;
            }
            .role-card.student .role-avatar    {
                background: #eff6ff;
                color: var(--rt-primary);
            }
            .role-card.supervisor .role-avatar {
                background: #f0fdf4;
                color: var(--rt-success);
            }
            .role-card.coordinator .role-avatar{
                background: #fffbeb;
                color: var(--rt-warning);
            }
            .role-badge {
                display: inline-block;
                font-size: .65rem;
                font-weight: 700;
                letter-spacing: .07em;
                text-transform: uppercase;
                padding: .2rem .6rem;
                border-radius: 4px;
                margin-bottom: 1rem;
            }
            .role-card.student .role-badge    {
                background: #eff6ff;
                color: var(--rt-primary);
            }
            .role-card.supervisor .role-badge {
                background: #f0fdf4;
                color: var(--rt-success);
            }
            .role-card.coordinator .role-badge{
                background: #fffbeb;
                color: var(--rt-warning);
            }
            .role-features {
                list-style: none;
                padding: 0;
                margin: 1rem 0 0;
                text-align: left;
            }
            .role-features li {
                display: flex;
                align-items: center;
                gap: .5rem;
                font-size: .875rem;
                color: var(--rt-muted);
                padding: .3rem 0;
            }
            .role-features li i {
                color: var(--rt-success);
                font-size: .8rem;
            }

            /* ── Workflow ── */
            .workflow-step {
                display: flex;
                gap: 1.25rem;
                align-items: flex-start;
                padding: 1.5rem;
                background: #fff;
                border: 1px solid var(--rt-border);
                border-radius: 12px;
                margin-bottom: 1rem;
                transition: box-shadow .2s;
            }
            .workflow-step:hover {
                box-shadow: var(--rt-shadow-lg);
            }
            .step-num {
                width: 36px;
                height: 36px;
                border-radius: 50%;
                background: var(--rt-primary);
                color: #fff;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                font-size: .875rem;
                flex-shrink: 0;
            }

            /* ── CTA ── */
            .cta-section {
                background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%);
                padding: 5rem 1.5rem;
                text-align: center;
                color: #fff;
            }
            .cta-section h2 {
                font-size: clamp(1.8rem, 4vw, 2.5rem);
                font-weight: 700;
                letter-spacing: -.02em;
                margin-bottom: 1rem;
            }
            .cta-section p {
                color: #bfdbfe;
                font-size: 1rem;
                margin-bottom: 2rem;
            }

            /* ── Footer ── */
            .rt-footer {
                background: #0f172a;
                color: #94a3b8;
                padding: 2.5rem 1.5rem;
                text-align: center;
                font-size: .82rem;
            }

            /* ── Login Modal ── */
            .rt-modal-overlay {
                display: none;
                position: fixed;
                inset: 0;
                background: rgba(15,23,42,.6);
                backdrop-filter: blur(4px);
                z-index: 1000;
                align-items: center;
                justify-content: center;
            }
            .rt-modal-overlay.open {
                display: flex;
            }
            .rt-modal {
                background: #fff;
                border-radius: 16px;
                padding: 2.5rem 2rem;
                width: 100%;
                max-width: 400px;
                margin: 1rem;
                box-shadow: 0 24px 64px rgba(0,0,0,.2);
                position: relative;
                animation: modalIn .2s ease;
            }
            @keyframes modalIn {
                from {
                    opacity: 0;
                    transform: translateY(-16px) scale(.97);
                }
                to   {
                    opacity: 1;
                    transform: translateY(0) scale(1);
                }
            }
            .rt-modal-close {
                position: absolute;
                top: 1rem;
                right: 1rem;
                background: none;
                border: none;
                font-size: 1.2rem;
                color: var(--rt-muted);
                cursor: pointer;
                width: 32px;
                height: 32px;
                border-radius: 6px;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .rt-modal-close:hover {
                background: var(--rt-bg);
            }
            .form-control:focus {
                border-color: var(--rt-primary);
                box-shadow: 0 0 0 3px rgba(37,99,235,.15);
            }
            .btn-login {
                background: var(--rt-primary);
                color: #fff;
                border: none;
                width: 100%;
                padding: .75rem;
                border-radius: 8px;
                font-weight: 600;
                font-size: .95rem;
                cursor: pointer;
                transition: background .15s;
            }
            .btn-login:hover {
                background: var(--rt-primary-dk);
            }

            @media (max-width: 576px) {
                .rt-nav {
                    padding: 0 1rem;
                }
                .rt-nav-links {
                    display: none;
                }
                .hero {
                    padding: 3.5rem 1rem 3rem;
                }
                .hero-stats {
                    gap: 2rem;
                }
                .section {
                    padding: 3.5rem 1rem;
                }
            }
        </style>
    </head>
    <body>

        <!-- ── Navbar ── -->
        <nav class="rt-nav">
            <a href="#" class="rt-nav-brand">
                <img src="<%= ctx%>/img/roadway.gif" alt="RailTrack"
                     style="width:30px;height:30px;object-fit:cover;border-radius:50%;">
                <span>RailTrack <small>FYP Management</small></span>
            </a>
            <div class="rt-nav-spacer"></div>
            <div class="rt-nav-links">
                <a href="#problem">Problem</a>
                <a href="#solution">Solution</a>
                <a href="#workflow">Workflow</a>
                <a href="#roles">Roles</a>
            </div>
            <button onclick="openLogin()" class="btn btn-primary btn-sm ms-3"
                    style="border-radius:7px;font-weight:600;padding:.4rem 1.1rem;">
                <i class="bi bi-box-arrow-in-right me-1"></i>Sign In
            </button>
        </nav>

        <!-- ── Hero ── -->
        <section class="hero">
            <div style="position:relative;z-index:1;">
                <div class="hero-badge">
                    <i class="bi bi-train-front-fill"></i> Built for Universities
                </div>
                <h1>Manage Your <span>Final Year Projects</span><br>The Smart Way</h1>
                <p>RailTrack brings students, supervisors, and coordinators onto one platform — with milestone tracking, Docker deployments, and real-time feedback.</p>
                <div class="hero-cta">
                    <button onclick="openLogin()" class="btn-hero-primary">
                        <i class="bi bi-box-arrow-in-right"></i> Get Started
                    </button>
                    <a href="#solution" class="btn-hero-outline">
                        <i class="bi bi-play-circle"></i> Learn More
                    </a>
                </div>
                <div class="hero-stats">
                    <div class="hero-stat"><div class="num">3</div><div class="lbl">User Roles</div></div>
                    <div class="hero-stat"><div class="num">100%</div><div class="lbl">Web-Based</div></div>
                    <div class="hero-stat"><div class="num">Live</div><div class="lbl">Docker Deployments</div></div>
                    <div class="hero-stat"><div class="num">Real-time</div><div class="lbl">Feedback</div></div>
                </div>
            </div>
        </section>

        <!-- ── Problem ── -->
        <section class="section" id="problem">
            <div class="container">
                <div class="text-center mb-5">
                    <div class="section-label">The Problem</div>
                    <h2 class="section-title">FYP Management is Broken</h2>
                    <p class="section-sub mx-auto">Universities rely on scattered emails, spreadsheets, and manual tracking — creating confusion for everyone involved.</p>
                </div>
                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="problem-card">
                            <div class="problem-icon" style="background:#fef2f2;color:#dc2626;">
                                <i class="bi bi-exclamation-triangle"></i>
                            </div>
                            <h6 class="fw-bold mb-2">No Visibility</h6>
                            <p class="text-muted mb-0" style="font-size:.875rem;">Students and supervisors have no clear view of project progress, milestones, or deadlines in one place.</p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="problem-card">
                            <div class="problem-icon" style="background:#fffbeb;color:#d97706;">
                                <i class="bi bi-chat-dots"></i>
                            </div>
                            <h6 class="fw-bold mb-2">Scattered Feedback</h6>
                            <p class="text-muted mb-0" style="font-size:.875rem;">Feedback gets lost in email chains. Students miss critical reviews and supervisors duplicate efforts.</p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="problem-card">
                            <div class="problem-icon" style="background:#f5f3ff;color:#7c3aed;">
                                <i class="bi bi-hdd-stack"></i>
                            </div>
                            <h6 class="fw-bold mb-2">No Deployment</h6>
                            <p class="text-muted mb-0" style="font-size:.875rem;">Demonstrating web projects during evaluation is painful — no standard way to run and show live apps.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ── Solution ── -->
        <section class="section section-alt" id="solution">
            <div class="container">
                <div class="row align-items-center g-5">
                    <div class="col-lg-5">
                        <div class="section-label">The Solution</div>
                        <h2 class="section-title">Everything in One Platform</h2>
                        <p class="section-sub">RailTrack gives every stakeholder the tools they need — from submitting projects to live Docker deployments and structured milestone reviews.</p>
                        <button onclick="openLogin()" class="btn btn-primary mt-3" style="border-radius:8px;font-weight:600;">
                            <i class="bi bi-box-arrow-in-right me-1"></i>Sign In to RailTrack
                        </button>
                    </div>
                    <div class="col-lg-7">
                        <div class="row g-3">
                            <div class="col-sm-6">
                                <div class="feature-item">
                                    <div class="feature-icon"><i class="bi bi-flag"></i></div>
                                    <div>
                                        <div class="fw-semibold" style="font-size:.9rem;">Milestone Tracking</div>
                                        <div class="text-muted" style="font-size:.8rem;">Create, submit, and review milestones with grades and supervisor notes.</div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="feature-item">
                                    <div class="feature-icon green"><i class="bi bi-box-seam"></i></div>
                                    <div>
                                        <div class="fw-semibold" style="font-size:.9rem;">Docker Deployments</div>
                                        <div class="text-muted" style="font-size:.8rem;">Build, start, and stop student project containers directly from the dashboard.</div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="feature-item">
                                    <div class="feature-icon orange"><i class="bi bi-chat-left-text"></i></div>
                                    <div>
                                        <div class="fw-semibold" style="font-size:.9rem;">Structured Feedback</div>
                                        <div class="text-muted" style="font-size:.8rem;">Supervisors post typed feedback by category — students see it instantly.</div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="feature-item">
                                    <div class="feature-icon cyan"><i class="bi bi-people"></i></div>
                                    <div>
                                        <div class="fw-semibold" style="font-size:.9rem;">Supervisor Assignment</div>
                                        <div class="text-muted" style="font-size:.8rem;">Coordinators assign supervisors to projects and manage the full cohort.</div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="feature-item">
                                    <div class="feature-icon purple"><i class="bi bi-terminal"></i></div>
                                    <div>
                                        <div class="fw-semibold" style="font-size:.9rem;">Live Log Streaming</div>
                                        <div class="text-muted" style="font-size:.8rem;">Watch container output in real-time via Server-Sent Events in the browser.</div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="feature-item">
                                    <div class="feature-icon red"><i class="bi bi-shield-lock"></i></div>
                                    <div>
                                        <div class="fw-semibold" style="font-size:.9rem;">Role-Based Access</div>
                                        <div class="text-muted" style="font-size:.8rem;">Students, supervisors, and coordinators each see only what they need.</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ── Roles ── -->
        <section class="section" id="roles">
            <div class="container">
                <div class="text-center mb-5">
                    <div class="section-label">Who It's For</div>
                    <h2 class="section-title">Built for Every Role</h2>
                    <p class="section-sub mx-auto">Each role gets a tailored dashboard with exactly the tools they need.</p>
                </div>
                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="role-card student">
                            <div class="role-avatar"><i class="bi bi-person-raised-hand"></i></div>
                            <div class="role-badge">Student</div>
                            <h5 class="fw-bold mb-1">Students</h5>
                            <p class="text-muted" style="font-size:.875rem;">Submit projects, track milestones, and receive supervisor feedback.</p>
                            <ul class="role-features">
                                <li><i class="bi bi-check-circle-fill"></i> Submit &amp; manage FYP projects</li>
                                <li><i class="bi bi-check-circle-fill"></i> Track milestone progress</li>
                                <li><i class="bi bi-check-circle-fill"></i> View supervisor feedback</li>
                                <li><i class="bi bi-check-circle-fill"></i> See live deployment status</li>
                            </ul>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="role-card supervisor">
                            <div class="role-avatar"><i class="bi bi-person-badge"></i></div>
                            <div class="role-badge">Supervisor</div>
                            <h5 class="fw-bold mb-1">Supervisors</h5>
                            <p class="text-muted" style="font-size:.875rem;">Review milestones, post feedback, and deploy student projects.</p>
                            <ul class="role-features">
                                <li><i class="bi bi-check-circle-fill"></i> Approve or reject milestones</li>
                                <li><i class="bi bi-check-circle-fill"></i> Grade student submissions</li>
                                <li><i class="bi bi-check-circle-fill"></i> Deploy via Docker</li>
                                <li><i class="bi bi-check-circle-fill"></i> Post structured feedback</li>
                            </ul>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="role-card coordinator">
                            <div class="role-avatar"><i class="bi bi-person-gear"></i></div>
                            <div class="role-badge">Coordinator</div>
                            <h5 class="fw-bold mb-1">Coordinators</h5>
                            <p class="text-muted" style="font-size:.875rem;">Oversee all projects, assign supervisors, and manage users.</p>
                            <ul class="role-features">
                                <li><i class="bi bi-check-circle-fill"></i> View all projects</li>
                                <li><i class="bi bi-check-circle-fill"></i> Assign supervisors</li>
                                <li><i class="bi bi-check-circle-fill"></i> Manage user accounts</li>
                                <li><i class="bi bi-check-circle-fill"></i> Monitor system-wide stats</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ── Workflow ── -->
        <section class="section section-alt" id="workflow">
            <div class="container">
                <div class="row g-5 align-items-center">
                    <div class="col-lg-4">
                        <div class="section-label">How It Works</div>
                        <h2 class="section-title">From Submission to Deployment</h2>
                        <p class="section-sub">A clear, structured process that keeps everyone aligned from day one to final evaluation.</p>
                    </div>
                    <div class="col-lg-8">
                        <div class="workflow-step">
                            <div class="step-num">1</div>
                            <div>
                                <div class="fw-semibold mb-1">Student Submits Project</div>
                                <div class="text-muted" style="font-size:.875rem;">Student registers a GitHub repository with branch and semester details.</div>
                            </div>
                        </div>
                        <div class="workflow-step">
                            <div class="step-num">2</div>
                            <div>
                                <div class="fw-semibold mb-1">Coordinator Assigns Supervisor</div>
                                <div class="text-muted" style="font-size:.875rem;">Coordinator reviews pending projects and assigns an appropriate supervisor.</div>
                            </div>
                        </div>
                        <div class="workflow-step">
                            <div class="step-num">3</div>
                            <div>
                                <div class="fw-semibold mb-1">Milestones are Defined &amp; Tracked</div>
                                <div class="text-muted" style="font-size:.875rem;">Students work through milestones, submitting each for supervisor review and grading.</div>
                            </div>
                        </div>
                        <div class="workflow-step">
                            <div class="step-num">4</div>
                            <div>
                                <div class="fw-semibold mb-1">Supervisor Deploys &amp; Evaluates</div>
                                <div class="text-muted" style="font-size:.875rem;">Supervisor builds and runs the student's project in a Docker container for live demo and final evaluation.</div>
                            </div>
                        </div>
                        <div class="workflow-step" style="border-color:#bbf7d0;background:#f0fdf4;">
                            <div class="step-num" style="background:var(--rt-success);">✓</div>
                            <div>
                                <div class="fw-semibold mb-1" style="color:var(--rt-success);">Project Completed</div>
                                <div class="text-muted" style="font-size:.875rem;">All milestones approved, grades recorded, project marked as completed.</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ── CTA ── -->
        <section class="cta-section">
            <div class="container">
                <h2>Ready to Track Your FYP?</h2>
                <p>Sign in now and get your project moving on the right track.</p>
                <button onclick="openLogin()" class="btn-hero-primary">
                    <i class="bi bi-box-arrow-in-right"></i> Sign In to RailTrack
                </button>
            </div>
        </section>

        <!-- ── Footer ── -->
        <footer class="rt-footer">
            <div>© 2026 RailTrack Platform. Built for University Final Year Projects.</div>
            <div class="mt-1" style="color:#475569;">Powered by Docker &amp; Java EE</div>
        </footer>

        <!-- ── Login Modal ── -->
        <div class="rt-modal-overlay" id="loginOverlay">
            <div class="rt-modal" id="loginModal">
                <button class="rt-modal-close" onclick="closeLogin()">
                    <i class="bi bi-x-lg"></i>
                </button>
                <div class="text-center mb-4">
                    <img src="<%= ctx%>/img/roadway.gif" alt="RailTrack"
                         style="width:44px;height:44px;object-fit:cover;border-radius:50%;margin-bottom:.75rem;">
                    <h5 class="fw-bold mb-0">Sign in to RailTrack</h5>
                    <p class="text-muted" style="font-size:.82rem;margin-top:.25rem;">Enter your credentials to keep this journey on Railtrack</p>
                </div>

                <% if ("logged_out".equals(msg)) { %>
                <div class="alert alert-success py-2 px-3 mb-3" style="font-size:.83rem;border-radius:8px;">
                    <i class="bi bi-check-circle-fill me-1"></i> You have been signed out successfully.
                </div>
                <% } %>

                <% if (loginError != null) {%>
                <div class="alert alert-danger py-2 px-3 mb-3" style="font-size:.83rem;border-radius:8px;">
                    <i class="bi bi-exclamation-circle me-1"></i><%= loginError%>
                </div>
                <% }%>

                <form method="post" action="<%= ctx%>/login">
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Username</label>
                        <input type="text" name="username" class="form-control" required
                               placeholder="Enter your username" autocomplete="username"/>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Password</label>
                        <div class="position-relative">
                            <input type="password" name="password" id="passwordInput"
                                   class="form-control" required
                                   placeholder="Enter your password" autocomplete="current-password"/>
                            <button type="button" onclick="togglePassword()"
                                    style="position:absolute;right:.75rem;top:50%;transform:translateY(-50%);
                                    background:none;border:none;color:var(--rt-muted);cursor:pointer;padding:0;">
                                <i class="bi bi-eye" id="eyeIcon"></i>
                            </button>
                        </div>
                    </div>
                    <div class="mb-4 d-flex justify-content-center">
                        <div class="g-recaptcha" data-sitekey="6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"></div>
                    </div>
                    <button type="submit" class="btn-login">
                        <i class="bi bi-box-arrow-in-right me-1"></i>Sign In
                    </button>
                </form>
                <div class="text-center mt-3" style="font-size:.8rem;">
                    New user?
                    <a href="#" onclick="switchToRegister()">Create an account</a>
                </div>
            </div>
        </div>

        <!-- ── Register Modal ── -->
        <div class="rt-modal-overlay" id="registerOverlay">
            <div class="rt-modal" id="registerModal">
                <button class="rt-modal-close" onclick="closeRegister()">
                    <i class="bi bi-x-lg"></i>
                </button>

                <div class="text-center mb-4">
                    <img src="<%= ctx%>/img/roadway.gif" alt="RailTrack"
                         style="width:44px;height:44px;object-fit:cover;border-radius:50%;margin-bottom:.75rem;">
                    <h5 class="fw-bold mb-0">Create Account on RailTrack</h5>
                    <p class="text-muted" style="font-size:.82rem;margin-top:.25rem;">Climb aboard on the RailTrack</p>
                </div>

                <% if ("reg_error".equals(errorParam)) {%>
                <div class="alert alert-danger py-2 px-3 mb-3" style="font-size:.83rem;border-radius:8px;">
                    <%= request.getParameter("msg")%>
                </div>
                <% } %>

                <% if ("registered".equals(msg)) { %>
                <div class="alert alert-success py-2 px-3 mb-3" style="font-size:.83rem;border-radius:8px;">
                    <i class="bi bi-check-circle-fill me-1"></i>
                    Account created. You can sign in now.
                </div>
                <% }%>

                <form method="post" action="<%= ctx%>/register">
                    <div class="mb-2">
                        <input type="text" name="role" class="form-control" value="STUDENT" hidden>
                    </div>
                    <div class="mb-2">
                        <input type="text" name="fullName" class="form-control" placeholder="Full Name" required>
                    </div>

                    <div class="mb-2">
                        <input type="text" name="username" class="form-control bg-light" placeholder="Username" readonly="">
                    </div>

                    <div class="mb-2">
                        <input type="email" name="email" class="form-control" placeholder="Email" required>
                    </div>

                    <div class="mb-2">
                        <label class="form-label">Department</label>
                        <select name="department" class="form-select" required>
                            <option value="SMSK(KP)">SMSK(KP)</option>
                            <option value="SMSKdIM(K)">SMSKdIM(K)</option>
                        </select>
                    </div>

                    <div class="mb-2">
                        <input type="password" name="password" class="form-control" placeholder="Password" required>
                    </div>

                    <div class="mb-3">
                        <input type="password" name="confirmPassword" class="form-control" placeholder="Confirm Password" required>
                    </div>

                    <button type="submit" class="btn-login">
                        <i class="bi bi-person-plus me-1"></i>Create Account
                    </button>
                </form>

                <div class="text-center mt-3" style="font-size:.8rem;">
                    Already have an account?
                    <a href="#" onclick="switchToLogin()">Sign in</a>
                </div>
            </div>
        </div>        

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                        var regOverlay = document.getElementById('registerOverlay');
                        var regModal = document.getElementById('registerModal');

                        function openRegister() {
                            regOverlay.classList.add('open');
                            document.body.style.overflow = 'hidden';
                        }

                        function closeRegister() {
                            regOverlay.classList.remove('open');
                            document.body.style.overflow = '';
                        }

                        function switchToLogin() {
                            closeRegister();
                            openLogin();
                        }
                        function switchToRegister() {
                            openRegister();
                            closeLogin();
                        }

// Close on outside click
                        regOverlay.addEventListener('mousedown', function (e) {
                            if (e.target === regOverlay)
                                closeRegister();
                        });
                        regModal.addEventListener('mousedown', function (e) {
                            e.stopPropagation();
                        });
                        var overlay = document.getElementById('loginOverlay');
                        var modal = document.getElementById('loginModal');

                        function openLogin() {
                            overlay.classList.add('open');
                            document.body.style.overflow = 'hidden'; // prevent scroll
                            setTimeout(() => {
                                var u = document.querySelector('input[name="username"]');
                                if (u)
                                    u.focus();
                            }, 100);
                        }

                        function closeLogin() {
                            overlay.classList.remove('open');
                            document.body.style.overflow = ''; // restore scroll
                        }

                        // Close only when clicking the bare overlay (outside modal)
                        overlay.addEventListener('mousedown', function (e) {
                            if (e.target === overlay) {
                                closeLogin();
                            }
                        });

                        // Stop any click/mousedown inside modal from reaching overlay
                        modal.addEventListener('mousedown', function (e) {
                            e.stopPropagation();
                        });

                        function togglePassword() {
                            var input = document.getElementById('passwordInput');
                            var icon = document.getElementById('eyeIcon');
                            if (input.type === 'password') {
                                input.type = 'text';
                                icon.className = 'bi bi-eye-slash';
                            } else {
                                input.type = 'password';
                                icon.className = 'bi bi-eye';
                            }
                        }

                        document.addEventListener('keydown', function (e) {
                            if (e.key === 'Escape')
                                closeLogin();
                        });

            <% if (loginError != null || "logged_out".equals(msg) || "login".equals(request.getParameter("action"))) { %>
                        if (document.readyState === 'loading') {
                            document.addEventListener('DOMContentLoaded', function () {
                                openLogin();
                                if (window.history && window.history.replaceState) {
                                    window.history.replaceState({}, document.title, window.location.pathname);
                                }
                            });
                        } else {
                            openLogin();
                            if (window.history && window.history.replaceState) {
                                window.history.replaceState({}, document.title, window.location.pathname);
                            }
                        }
            <% }%>
            <% if ("reg_error".equals(errorParam) || "registered".equals(msg) || "register".equals(request.getParameter("action"))) { %>
                        if (document.readyState === 'loading') {
                            document.addEventListener('DOMContentLoaded', function () {
                                openRegister();
                            });
                        } else {
                            openRegister();
                        }
            <% }%>
                        // Auto-fill username from email (register form)
                        document.addEventListener("DOMContentLoaded", function () {
                            const registerForm = document.querySelector('#registerModal');
                            if (!registerForm)
                                return;

                            const emailInput = registerForm.querySelector('input[name="email"]');
                            const usernameInput = registerForm.querySelector('input[name="username"]');

                            let userEdited = false;

                            // Detect if user manually edits username
                            usernameInput.addEventListener("input", function () {
                                userEdited = usernameInput.value.trim().length > 0;
                            });

                            emailInput.addEventListener("input", function () {
                                const email = emailInput.value;

                                if (!userEdited && email.includes("@")) {
                                    const username = email.split("@")[0];
                                    usernameInput.value = username;
                                }
                            });
                        });
        </script>
    </body>
</html>

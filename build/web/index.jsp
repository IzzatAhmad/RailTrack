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

    // Failed-attempt tracking
    boolean offerReset = "true".equals(request.getParameter("offer_reset"));
    String  failsParam  = request.getParameter("fails");
    int     failCount   = 0;
    try { if (failsParam != null) failCount = Integer.parseInt(failsParam); } catch (NumberFormatException ignored) {}

    // Token-based reset form
    String resetToken = request.getParameter("token");
    String resetError = ("reset_form".equals(request.getParameter("action"))) ? loginError : null;

    // Retrieve form data if available
    String regFullName = "";
    String regEmail = "";
    String regDepartment = "";
    String regUsername = "";
    String regRole = "";
    if (session != null && "reg_error".equals(errorParam)) {
        regFullName = session.getAttribute("reg_fullName") != null ? (String) session.getAttribute("reg_fullName") : "";
        regEmail = session.getAttribute("reg_email") != null ? (String) session.getAttribute("reg_email") : "";
        regDepartment = session.getAttribute("reg_department") != null ? (String) session.getAttribute("reg_department") : "";
        regUsername = session.getAttribute("reg_username") != null ? (String) session.getAttribute("reg_username") : "";
        regRole = session.getAttribute("reg_role") != null ? (String) session.getAttribute("reg_role") : "";

        session.removeAttribute("reg_fullName");
        session.removeAttribute("reg_email");
        session.removeAttribute("reg_department");
        session.removeAttribute("reg_username");
        session.removeAttribute("reg_role");
    }

    String valStudentFullName = ("STUDENT".equals(regRole) || regRole.isEmpty()) ? regFullName.replace("\"", "&quot;") : "";
    String valStudentUsername = ("STUDENT".equals(regRole) || regRole.isEmpty()) ? regUsername.replace("\"", "&quot;") : "";
    String valStudentEmail = ("STUDENT".equals(regRole) || regRole.isEmpty()) ? regEmail.replace("\"", "&quot;") : "";
    String valStudentDept = ("STUDENT".equals(regRole) || regRole.isEmpty()) ? regDepartment : "";

    String valSuperFullName = "SUPERVISOR".equals(regRole) ? regFullName.replace("\"", "&quot;") : "";
    String valSuperUsername = "SUPERVISOR".equals(regRole) ? regUsername.replace("\"", "&quot;") : "";
    String valSuperEmail = "SUPERVISOR".equals(regRole) ? regEmail.replace("\"", "&quot;") : "";
    String valSuperDept = "SUPERVISOR".equals(regRole) ? regDepartment : "";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>RailTrack | home</title>
        <!-- Favicon - PNG -->
        <link rel="icon" type="image/png" href="<%= ctx %>/img/roadway.png" sizes="32x32">
        <!-- Additional sizes for better support -->
        <link rel="icon" type="image/png" href="<%= ctx %>/img/roadway.png" sizes="16x16">
        <!-- Apple Touch Icon (iOS) -->
        <link rel="apple-touch-icon" href="<%= ctx %>/img/roadway.png">
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

            /* ── Hero 3D ── */
            .hero {
                position: relative;
                width: 100%;
                height: 100vh;
                min-height: 600px;
                overflow: hidden;
                color: #fff;
            }
            #railtrack-canvas {
                position: absolute;
                inset: 0;
                width: 100% !important;
                height: 100% !important;
                display: block;
            }
            .hero-overlay {
                position: absolute;
                inset: 0;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                text-align: center;
                padding: 2rem 1.5rem;
                pointer-events: none;
                z-index: 2;
            }
            .hero-glass {
                background: rgba(10, 18, 42, 0.55);
                backdrop-filter: blur(18px) saturate(150%);
                -webkit-backdrop-filter: blur(18px) saturate(150%);
                border: 1px solid rgba(255,255,255,0.12);
                border-radius: 24px;
                padding: 2.8rem 3rem;
                max-width: 680px;
                width: 100%;
                box-shadow: 0 32px 80px rgba(0,0,0,0.45), inset 0 1px 0 rgba(255,255,255,0.08);
                pointer-events: all;
            }
            .hero-badge {
                display: inline-flex;
                align-items: center;
                gap: .4rem;
                background: rgba(96,165,250,.18);
                border: 1px solid rgba(96,165,250,.35);
                border-radius: 999px;
                padding: .35rem 1rem;
                font-size: .72rem;
                font-weight: 700;
                letter-spacing: .1em;
                text-transform: uppercase;
                margin-bottom: 1.5rem;
                color: #93c5fd;
                animation: fadeSlideUp .8s ease both;
            }
            .hero h1 {
                font-size: clamp(2rem, 4.5vw, 3.2rem);
                font-weight: 700;
                letter-spacing: -.03em;
                line-height: 1.15;
                margin-bottom: 1.1rem;
                animation: fadeSlideUp .9s .1s ease both;
                color: #fff;
            }
            .hero h1 span {
                background: linear-gradient(90deg, #60a5fa, #a78bfa);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
            }
            .hero p {
                font-size: 1rem;
                color: #bfdbfe;
                max-width: 480px;
                margin: 0 auto 2rem;
                line-height: 1.7;
                animation: fadeSlideUp 1s .2s ease both;
            }
            .hero-cta {
                display: flex;
                gap: 1rem;
                justify-content: center;
                flex-wrap: wrap;
                animation: fadeSlideUp 1s .3s ease both;
            }
            .btn-hero-primary {
                background: linear-gradient(135deg, #2563eb, #7c3aed);
                color: #fff;
                font-weight: 600;
                font-size: .95rem;
                padding: .75rem 2rem;
                border-radius: 10px;
                border: none;
                text-decoration: none;
                transition: all .25s;
                display: inline-flex;
                align-items: center;
                gap: .45rem;
                cursor: pointer;
                box-shadow: 0 4px 24px rgba(37,99,235,.45);
            }
            .btn-hero-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 32px rgba(37,99,235,.6);
                filter: brightness(1.1);
            }
            .btn-hero-outline {
                background: rgba(255,255,255,.08);
                color: #fff;
                font-weight: 500;
                font-size: .95rem;
                padding: .75rem 2rem;
                border-radius: 10px;
                border: 1px solid rgba(255,255,255,.28);
                text-decoration: none;
                transition: all .25s;
                display: inline-flex;
                align-items: center;
                gap: .45rem;
            }
            .btn-hero-outline:hover {
                background: rgba(255,255,255,.16);
                color: #fff;
                border-color: rgba(255,255,255,.5);
                transform: translateY(-2px);
            }
            .hero-stats {
                display: flex;
                justify-content: center;
                gap: 2.5rem;
                margin-top: 2rem;
                flex-wrap: wrap;
                animation: fadeSlideUp 1s .4s ease both;
            }
            .hero-stat {
                text-align: center;
            }
            .hero-stat .num {
                font-size: 1.8rem;
                font-weight: 700;
                color: #fff;
                line-height: 1;
            }
            .hero-stat .lbl {
                font-size: .7rem;
                color: #93c5fd;
                margin-top: .2rem;
                font-weight: 500;
                letter-spacing: .04em;
                text-transform: uppercase;
            }
            /* scroll hint */
            .scroll-hint {
                position: absolute;
                bottom: 2rem;
                left: 50%;
                transform: translateX(-50%);
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: .4rem;
                color: rgba(255,255,255,.5);
                font-size: .7rem;
                font-weight: 600;
                letter-spacing: .12em;
                text-transform: uppercase;
                animation: fadeIn 1.5s 1s ease both;
                pointer-events: none;
                z-index: 3;
            }
            .scroll-hint .wheel {
                width: 22px;
                height: 36px;
                border: 2px solid rgba(255,255,255,.35);
                border-radius: 11px;
                position: relative;
            }
            .scroll-hint .wheel::after {
                content: '';
                position: absolute;
                top: 5px;
                left: 50%;
                transform: translateX(-50%);
                width: 3px;
                height: 7px;
                background: rgba(255,255,255,.6);
                border-radius: 2px;
                animation: scrollDot 1.6s ease infinite;
            }
            @keyframes scrollDot {
                0%   { opacity: 1; top: 5px; }
                100% { opacity: 0; top: 18px; }
            }
            @keyframes fadeSlideUp {
                from { opacity: 0; transform: translateY(24px); }
                to   { opacity: 1; transform: translateY(0); }
            }
            @keyframes fadeIn {
                from { opacity: 0; }
                to   { opacity: 1; }
            }
            @media (max-width: 576px) {
                .hero-glass {
                    padding: 2rem 1.5rem;
                    border-radius: 18px;
                }
                .hero-stats { gap: 1.5rem; }
                .rt-nav {
                    padding: 0 1rem;
                }
                .rt-nav-links {
                    display: none;
                }
                .section {
                    padding: 3.5rem 1rem;
                }
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
            
            <div class="d-none d-md-flex align-items-center">
                <div class="rt-nav-links me-3">
                    <a href="#problem">Problem</a>
                    <a href="#solution">Solution</a>
                    <a href="#workflow">Workflow</a>
                    <a href="#roles">Roles</a>
                </div>
                <button onclick="openLogin()" class="btn btn-primary btn-sm"
                        style="border-radius:7px;font-weight:600;padding:.4rem 1.1rem;">
                    <i class="bi bi-box-arrow-in-right me-1"></i>Sign In
                </button>
            </div>
            
            <button class="btn btn-sm d-md-none border-0 ms-2" type="button" data-bs-toggle="offcanvas" data-bs-target="#indexOffcanvasNav" aria-controls="indexOffcanvasNav">
                <i class="bi bi-list fs-3 text-dark"></i>
            </button>
        </nav>

        <!-- Offcanvas Mobile Menu -->
        <div class="offcanvas offcanvas-end" tabindex="-1" id="indexOffcanvasNav" aria-labelledby="indexOffcanvasNavLabel">
            <div class="offcanvas-header border-bottom">
                <h5 class="offcanvas-title fw-bold" id="indexOffcanvasNavLabel">Menu</h5>
                <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
            </div>
            <div class="offcanvas-body d-flex flex-column gap-3">
                <a href="#problem" class="text-decoration-none text-dark fw-medium" data-bs-dismiss="offcanvas">Problem</a>
                <a href="#solution" class="text-decoration-none text-dark fw-medium" data-bs-dismiss="offcanvas">Solution</a>
                <a href="#workflow" class="text-decoration-none text-dark fw-medium" data-bs-dismiss="offcanvas">Workflow</a>
                <a href="#roles" class="text-decoration-none text-dark fw-medium" data-bs-dismiss="offcanvas">Roles</a>
                <button onclick="openLogin()" class="btn btn-primary w-100 mt-2" data-bs-dismiss="offcanvas">Sign In</button>
            </div>
        </div>

        <!-- ── Hero 3D ── -->
        <section class="hero" id="hero3d">
            <!-- Three.js canvas -->
            <canvas id="railtrack-canvas"></canvas>

            <!-- Glassmorphic overlay -->
            <div class="hero-overlay">
                <div class="hero-glass">
                    <div class="hero-badge">
                        <i class="bi bi-train-front-fill"></i>&nbsp; RailTrack · Built for Universities
                    </div>
                    <h1>Manage Your <span>Final Year Projects</span><br>The Smart Way</h1>
                    <p>RailTrack brings students, supervisors, and coordinators onto one platform — with milestone tracking, Docker deployments, and real-time feedback.</p>
                    <div class="hero-cta">
                        <button onclick="openLogin()" class="btn-hero-primary">
                            <i class="bi bi-box-arrow-in-right"></i> Get Started
                        </button>
                        <a href="#solution" class="btn-hero-outline">
                            <i class="bi bi-chevron-double-down"></i> Learn More
                        </a>
                    </div>
                    <div class="hero-stats">
                        <div class="hero-stat"><div class="num">3</div><div class="lbl">User Roles</div></div>
                        <div class="hero-stat"><div class="num">100%</div><div class="lbl">Web-Based</div></div>
                        <div class="hero-stat"><div class="num">Live</div><div class="lbl">Docker</div></div>
                        <div class="hero-stat"><div class="num">Real-time</div><div class="lbl">Feedback</div></div>
                    </div>
                </div>
            </div>

            <!-- Scroll cue -->
            <div class="scroll-hint">
                <div class="wheel"></div>
                Scroll to drive
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

                <%-- ── Login error + reset hint ── --%>
                <% if ("logged_out".equals(msg)) { %>
                <div class="alert alert-success py-2 px-3 mb-3" style="font-size:.83rem;border-radius:8px;">
                    <i class="bi bi-check-circle-fill me-1"></i> You have been signed out successfully.
                </div>
                <% } %>

                <% if ("reset_sent".equals(msg)) { %>
                <div class="alert alert-info py-2 px-3 mb-3" style="font-size:.83rem;border-radius:8px;">
                    <i class="bi bi-envelope-check me-1"></i>
                    If that email is registered, a reset link has been sent. Check your inbox.
                </div>
                <% } %>

                <% if ("password_reset".equals(msg)) { %>
                <div class="alert alert-success py-2 px-3 mb-3" style="font-size:.83rem;border-radius:8px;">
                    <i class="bi bi-check-circle-fill me-1"></i>
                    Password changed successfully. You can now sign in.
                </div>
                <% } %>

                <% if (loginError != null) {%>
                <div class="alert alert-danger py-2 px-3 mb-3" style="font-size:.83rem;border-radius:8px;">
                    <i class="bi bi-exclamation-circle me-1"></i><%= loginError%>
                    <% if (offerReset) { %>
                    <div class="mt-2" style="font-size:.80rem;">
                        <i class="bi bi-key me-1"></i>Too many failed attempts.
                        <a href="#" onclick="switchToResetRequest(); return false;" style="color:var(--rt-primary);font-weight:600;">
                            Reset your password
                        </a>
                    </div>
                    <% } %>
                </div>
                <% } %>

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
                <div class="text-center mt-2" style="font-size:.80rem;">
                    <a href="#" onclick="switchToResetRequest(); return false;" style="color:var(--rt-muted);">Forgot password?</a>
                </div>
                <div class="text-center mt-2" style="font-size:.8rem;">
                    <a href="#" onclick="switchToAdminAccess()" style="color:var(--rt-muted);text-decoration:none;">
                        <i class="bi bi-shield-lock me-1"></i>Admin Access
                    </a>
                </div>

            </div>
        </div>

        <!-- ── Reset Password Request Modal ── -->
        <div class="rt-modal-overlay" id="resetRequestOverlay">
            <div class="rt-modal" id="resetRequestModal">
                <button class="rt-modal-close" onclick="closeResetRequest()">
                    <i class="bi bi-x-lg"></i>
                </button>
                <div class="text-center mb-4">
                    <img src="<%= ctx%>/img/roadway.gif" alt="RailTrack"
                         style="width:44px;height:44px;object-fit:cover;border-radius:50%;margin-bottom:.75rem;">
                    <h5 class="fw-bold mb-0">Reset Password</h5>
                    <p class="text-muted" style="font-size:.82rem;margin-top:.25rem;">Enter your registered email to receive a reset link</p>
                </div>
                <form method="post" action="<%= ctx%>/reset-password">
                    <input type="hidden" name="action" value="request_reset">
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Email Address</label>
                        <input type="email" name="email" class="form-control" required
                               placeholder="your@email.com" autocomplete="email"/>
                    </div>
                    <div class="mb-4 d-flex justify-content-center">
                        <div class="g-recaptcha" data-sitekey="6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"></div>
                    </div>
                    <button type="submit" class="btn-login">
                        <i class="bi bi-envelope me-1"></i>Send Reset Link
                    </button>
                </form>
                <div class="text-center mt-3" style="font-size:.8rem;">
                    <a href="#" onclick="switchToLogin()">Back to Sign In</a>
                </div>
            </div>
        </div>

        <!-- ── Set New Password Modal (token-based) ── -->
        <div class="rt-modal-overlay" id="resetFormOverlay">
            <div class="rt-modal" id="resetFormModal">
                <button class="rt-modal-close" onclick="closeResetForm()">
                    <i class="bi bi-x-lg"></i>
                </button>
                <div class="text-center mb-4">
                    <img src="<%= ctx%>/img/roadway.gif" alt="RailTrack"
                         style="width:44px;height:44px;object-fit:cover;border-radius:50%;margin-bottom:.75rem;">
                    <h5 class="fw-bold mb-0">Set New Password</h5>
                    <p class="text-muted" style="font-size:.82rem;margin-top:.25rem;">Choose a strong password to protect your account</p>
                </div>
                <% if (resetError != null) { %>
                <div class="alert alert-danger py-2 px-3 mb-3" style="font-size:.83rem;border-radius:8px;">
                    <i class="bi bi-exclamation-circle me-1"></i><%= resetError %>
                </div>
                <% } %>
                <form method="post" action="<%= ctx%>/reset-password" id="resetFormForm">
                    <input type="hidden" name="action" value="do_reset">
                    <input type="hidden" name="token" id="resetTokenInput" value="<%= resetToken != null ? resetToken : ""%>">
                    <div class="mb-3">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">New Password</label>
                        <div class="position-relative">
                            <input type="password" name="newPassword" id="newPasswordInput"
                                   class="form-control" required minlength="8"
                                   placeholder="At least 8 chars, upper + lower + digit"
                                   autocomplete="new-password"/>
                            <button type="button" onclick="toggleNewPassword()"
                                    style="position:absolute;right:.75rem;top:50%;transform:translateY(-50%);
                                    background:none;border:none;color:var(--rt-muted);cursor:pointer;padding:0;">
                                <i class="bi bi-eye" id="newEyeIcon"></i>
                            </button>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-semibold" style="font-size:.83rem;">Confirm Password</label>
                        <input type="password" id="confirmNewPassword" class="form-control" required
                               placeholder="Repeat your new password" autocomplete="new-password"/>
                    </div>
                    <button type="submit" class="btn-login" onclick="return validateNewPasswords()">
                        <i class="bi bi-lock me-1"></i>Change Password
                    </button>
                </form>
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
                        <input type="text" name="fullName" class="form-control" placeholder="Full Name" value="<%= valStudentFullName %>" required>
                    </div>

                    <div class="mb-2">
                        <input type="text" name="username" class="form-control bg-light" placeholder="Username" value="<%= valStudentUsername %>" readonly="">
                    </div>

                    <div class="mb-2">
                        <input type="email" name="email" class="form-control" placeholder="Email" value="<%= valStudentEmail %>" required>
                    </div>

                    <div class="mb-2">
                        <label class="form-label">Department</label>
                        <select name="department" class="form-select" required>
                            <option value="SMSK(KP)" <%= "SMSK(KP)".equals(valStudentDept) ? "selected" : "" %>>SMSK(KP)</option>
                            <option value="SMSKdIM(K)" <%= "SMSKdIM(K)".equals(valStudentDept) ? "selected" : "" %>>SMSKdIM(K)</option>
                        </select>
                    </div>

                    <div class="mb-2 position-relative">
                        <input type="password" name="password" class="form-control" placeholder="Password" required>
                        <button type="button" onclick="toggleRegVisibility(this)"
                                style="position:absolute;right:.75rem;top:50%;transform:translateY(-50%);
                                background:none;border:none;color:var(--rt-muted);cursor:pointer;padding:0;z-index:10;">
                            <i class="bi bi-eye"></i>
                        </button>
                    </div>

                    <div class="mb-3 position-relative">
                        <input type="password" name="confirmPassword" class="form-control" placeholder="Confirm Password" required>
                        <button type="button" onclick="toggleRegVisibility(this)"
                                style="position:absolute;right:.75rem;top:50%;transform:translateY(-50%);
                                background:none;border:none;color:var(--rt-muted);cursor:pointer;padding:0;z-index:10;">
                            <i class="bi bi-eye"></i>
                        </button>
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

        <!-- ── Admin Access Verification Modal ── -->
        <div class="rt-modal-overlay" id="adminAccessOverlay">
            <div class="rt-modal" id="adminAccessModal">
                <button class="rt-modal-close" onclick="closeAdminAccess()">
                    <i class="bi bi-x-lg"></i>
                </button>
                <div class="text-center mb-4">
                    <img src="<%= ctx%>/img/roadway.gif" alt="RailTrack"
                         style="width:44px;height:44px;object-fit:cover;border-radius:50%;margin-bottom:.75rem;">
                    <h5 class="fw-bold mb-0">Admin Access Verification</h5>
                    <p class="text-muted" style="font-size:.82rem;margin-top:.25rem;">Enter the admin code to continue</p>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold" style="font-size:.83rem;">Access Code</label>
                    <input type="password" id="adminCodeInput" class="form-control" required
                           placeholder="Enter admin code"/>
                </div>
                <button type="button" class="btn-login" onclick="verifyAdminCode()">
                    <i class="bi bi-shield-check me-1"></i>Verify Code
                </button>
                <div class="text-center mt-3" style="font-size:.8rem;">
                    <a href="#" onclick="switchToLogin()">Back to Sign In</a>
                </div>
            </div>
        </div>

        <!-- ── Supervisor Register Modal ── -->
        <div class="rt-modal-overlay" id="supervisorRegisterOverlay">
            <div class="rt-modal" id="supervisorRegisterModal">
                <button class="rt-modal-close" onclick="closeSupervisorRegister()">
                    <i class="bi bi-x-lg"></i>
                </button>

                <div class="text-center mb-4">
                    <img src="<%= ctx%>/img/roadway.gif" alt="RailTrack"
                         style="width:44px;height:44px;object-fit:cover;border-radius:50%;margin-bottom:.75rem;">
                    <h5 class="fw-bold mb-0">Supervisor Registration</h5>
                    <p class="text-muted" style="font-size:.82rem;margin-top:.25rem;">Admin access required</p>
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
                        <input type="hidden" name="role" value="SUPERVISOR">
                        <input type="hidden" name="adminCode" id="hiddenAdminCode">
                    </div>

                    <div class="mb-2">
                        <input type="text" name="fullName" class="form-control" placeholder="Full Name" value="<%= valSuperFullName %>" required>
                    </div>

                    <div class="mb-2">
                        <input type="text" name="username" class="form-control bg-light" placeholder="Username" value="<%= valSuperUsername %>" readonly="">
                    </div>

                    <div class="mb-2">
                        <input type="email" name="email" class="form-control" placeholder="Email" value="<%= valSuperEmail %>" required>
                    </div>

                    <div class="mb-2">
                        <label class="form-label">Department</label>
                        <select name="department" class="form-select" required>
                            <option value="SMSK(KP)" <%= "SMSK(KP)".equals(valSuperDept) ? "selected" : "" %>>SMSK(KP)</option>
                            <option value="SMSKdIM(K)" <%= "SMSKdIM(K)".equals(valSuperDept) ? "selected" : "" %>>SMSKdIM(K)</option>
                        </select>
                    </div>

                    <div class="mb-2 position-relative">
                        <input type="password" name="password" class="form-control" placeholder="Password" required>
                        <button type="button" onclick="toggleRegVisibility(this)"
                                style="position:absolute;right:.75rem;top:50%;transform:translateY(-50%);
                                background:none;border:none;color:var(--rt-muted);cursor:pointer;padding:0;z-index:10;">
                            <i class="bi bi-eye"></i>
                        </button>
                    </div>

                    <div class="mb-3 position-relative">
                        <input type="password" name="confirmPassword" class="form-control" placeholder="Confirm Password" required>
                        <button type="button" onclick="toggleRegVisibility(this)"
                                style="position:absolute;right:.75rem;top:50%;transform:translateY(-50%);
                                background:none;border:none;color:var(--rt-muted);cursor:pointer;padding:0;z-index:10;">
                            <i class="bi bi-eye"></i>
                        </button>
                    </div>

                    <button type="submit" class="btn-login">
                        <i class="bi bi-person-plus me-1"></i>Create Supervisor Account
                    </button>
                </form>

                <div class="text-center mt-3" style="font-size:.8rem;">
                    Already have an account?
                    <a href="#" onclick="switchToLogin()">Sign in</a>
                </div>
            </div>
        </div>        

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

        <!-- ══════════════════════════════════════════════════════════════
             Pure WebGL Ray-Marching Railway Scene  (no external libraries)
        ══════════════════════════════════════════════════════════════════ -->
        <script>
        (function () {
            'use strict';

            document.addEventListener('DOMContentLoaded', initWebGL);

            // ─────────────────────────────────────────────────────────────
            //  GLSL shaders
            // ─────────────────────────────────────────────────────────────
            var VS = [
                'attribute vec2 a_pos;',
                'void main(){gl_Position=vec4(a_pos,0.0,1.0);}'
            ].join('\n');

            var FS = [
                'precision highp float;',
                'uniform vec2  u_res;',
                'uniform float u_time;',
                'uniform float u_camZ;',
                'uniform vec2  u_mouse;',

                // ── utility ──────────────────────────────────────────────
                'float hash(vec2 p){',
                '    p=fract(p*vec2(127.1,311.7));',
                '    p+=dot(p,p+19.19);',
                '    return fract(p.x*p.y);',
                '}',
                'float vnoise(vec2 p){',
                '    vec2 i=floor(p),f=fract(p);',
                '    f=f*f*(3.0-2.0*f);',
                '    return mix(',
                '        mix(hash(i),hash(i+vec2(1,0)),f.x),',
                '        mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);',
                '}',

                // ── track path (smooth S-curves along +Z) ─────────────
                'float trkX(float z){return sin(z*0.065)*6.0+sin(z*0.021)*11.0;}',
                'float trkXd(float z){return cos(z*0.065)*0.39+cos(z*0.021)*0.231;}',

                // ── SDF helpers ──────────────────────────────────────────
                'float sdBox2D(vec2 p,vec2 b){',
                '    vec2 q=abs(p)-b;',
                '    return length(max(q,0.0))+min(max(q.x,q.y),0.0);',
                '}',
                'float sdBox(vec3 p,vec3 b){',
                '    vec3 q=abs(p)-b;',
                '    return length(max(q,0.0))+min(max(q.x,max(q.y,q.z)),0.0);',
                '}',

                // ── scene SDF  matID: 0=ground 1=sleeper 2=rail 3=ballast
                'vec2 scene(vec3 p){',
                '    float d=1e6,m=0.0;',
                '    float cx=trkX(p.z);',
                '    float lx=p.x-cx;',
                // ground
                '    float gd=p.y+0.55;',
                '    if(gd<d){d=gd;m=0.0;}',
                // ballast bed (infinite prism, follows curve in X)
                '    float ba=sdBox2D(vec2(lx,p.y+0.40),vec2(1.45,0.16));',
                '    if(ba<d){d=ba;m=3.0;}',
                // sleepers – periodic Z repetition
                '    float SP=1.25;',
                '    float sz=mod(p.z+SP*0.5,SP)-SP*0.5;',
                '    float slCX=trkX(p.z-sz);',
                '    float sl=sdBox(vec3(p.x-slCX,p.y+0.265,sz),vec3(1.22,0.058,0.135));',
                '    if(sl<d){d=sl;m=1.0;}',
                // rails – infinite cylinders along Z, offset ±0.725 in local X
                '    float RO=0.725,RR=0.042;',
                '    float rl=length(vec2(lx+RO,p.y+0.21))-RR;',
                '    float rr=length(vec2(lx-RO,p.y+0.21))-RR;',
                '    float rail=min(rl,rr);',
                '    if(rail<d){d=rail;m=2.0;}',
                '    return vec2(d,m);',
                '}',

                // ── gradient normal ───────────────────────────────────────
                'vec3 calcNorm(vec3 p){',
                '    float E=0.001;',
                '    return normalize(vec3(',
                '        scene(p+vec3(E,0,0)).x-scene(p-vec3(E,0,0)).x,',
                '        scene(p+vec3(0,E,0)).x-scene(p-vec3(0,E,0)).x,',
                '        scene(p+vec3(0,0,E)).x-scene(p-vec3(0,0,E)).x));',
                '}',

                // ── star field ────────────────────────────────────────────
                'float stars(vec3 dir){',
                '    vec2 uv=vec2(atan(dir.z,dir.x)*7.16,dir.y*15.92);',
                '    float h=hash(floor(uv*1.5));',
                '    float h2=fract(h*23.7);',
                '    if(h2>0.975){',
                '        float b=(h2-0.975)/0.025;',
                '        return b*b*(0.65+0.35*sin(u_time*1.8+h*6.283));',
                '    }',
                '    return 0.0;',
                '}',

                // ── sky ───────────────────────────────────────────────────
                'vec3 sky(vec3 dir){',
                '    dir=normalize(dir);',
                '    float t=clamp(dir.y*0.7+0.3,0.0,1.0);',
                '    vec3 c=mix(vec3(0.06,0.12,0.30),vec3(0.004,0.008,0.04),pow(t,0.55));',
                // city glow forward (+Z)
                '    float cg=pow(clamp(dir.z,0.0,1.0),5.0)*clamp(1.0-abs(dir.y)*4.0,0.0,1.0);',
                '    c+=vec3(0.10,0.22,1.0)*cg*3.2;',
                // violet side glow
                '    float vg=pow(clamp(dir.x*0.5+0.5,0.0,1.0),12.0)*clamp(1.0-dir.y*3.0,0.0,1.0);',
                '    c+=vec3(0.28,0.04,0.60)*vg*0.7;',
                // stars (upper hemisphere)
                '    if(dir.y>-0.1) c+=vec3(0.80,0.88,1.0)*stars(dir);',
                '    return c;',
                '}',

                // ── shading ───────────────────────────────────────────────
                'vec3 shade(vec3 pos,vec3 rd,float mat){',
                '    vec3 n=calcNorm(pos);',
                '    vec3 ld=normalize(vec3(0.2,-1.0,0.5));',
                '    float diff=max(dot(n,-ld),0.0);',
                '    float cx=trkX(pos.z);',
                '    float lx=pos.x-cx;',
                '    vec3 col=vec3(0.0);',
                '    if(mat<0.5){',
                // ground
                '        float nv=vnoise(pos.xz*0.4)*0.5+vnoise(pos.xz*1.2)*0.35+vnoise(pos.xz*4.0)*0.15;',
                '        col=mix(vec3(0.022,0.038,0.068),vec3(0.07,0.09,0.14),nv);',
                '        col*=0.2+0.8*diff;',
                // wet ground reflection of rails
                '        float rd2=min(abs(lx-0.725),abs(lx+0.725));',
                '        col+=vec3(0.04,0.18,0.9)*exp(-rd2*1.9)*0.22;',
                '    } else if(mat<1.5){',
                // sleeper
                '        float wg=vnoise(pos.xz*2.5)*0.4+vnoise(pos.xz*6.0)*0.2;',
                '        col=mix(vec3(0.09,0.055,0.03),vec3(0.19,0.115,0.065),wg);',
                '        col*=0.15+0.85*diff;',
                '    } else if(mat<2.5){',
                // rail – polished steel + emissive blue glow
                '        vec3 h2=normalize(-ld+(-rd));',
                '        float spec=pow(max(dot(n,h2),0.0),80.0);',
                '        col=vec3(0.28,0.38,0.58)*(0.3+0.7*diff)+vec3(1.0)*spec*1.5;',
                '        col+=vec3(0.06,0.22,1.00)*1.3;',
                '    } else {',
                // ballast
                '        float gv=vnoise(pos.xz*2.8)*0.35+vnoise(pos.xz*7.0)*0.15;',
                '        col=mix(vec3(0.06,0.07,0.10),vec3(0.12,0.13,0.17),gv);',
                '        col*=0.2+0.8*diff;',
                '    }',
                '    return col;',
                '}',

                // ── ray marcher ───────────────────────────────────────────
                'vec3 raymarch(vec3 ro,vec3 rd){',
                '    float t=0.04,hitMat=-1.0;',
                '    for(int i=0;i<80;i++){',
                '        vec3 p=ro+rd*t;',
                '        vec2 res=scene(p);',
                '        if(res.x<0.0015*t){hitMat=res.y;break;}',
                '        t+=res.x*0.88;',
                '        if(t>115.0) break;',
                '    }',
                '    if(hitMat<0.0) return sky(rd);',
                '    vec3 pos=ro+rd*t;',
                '    vec3 col=shade(pos,rd,hitMat);',
                // volumetric rail glow – march along ray, accumulate proximity to rails
                '    float glow=0.0,gt=0.2;',
                '    for(int j=0;j<28;j++){',
                '        vec3 gp=ro+rd*gt;',
                '        float gcx=trkX(gp.z);',
                '        float glx=gp.x-gcx;',
                '        float nr=min(length(vec2(glx+0.725,gp.y+0.21)),length(vec2(glx-0.725,gp.y+0.21)));',
                '        glow+=1.0/(nr*nr*90.0+1.0);',
                '        gt+=2.0;',
                '        if(gt>t) break;',
                '    }',
                '    col+=vec3(0.04,0.20,1.0)*glow*0.022;',
                // exponential atmosphere fog
                '    float ff=1.0-exp(-t*0.017);',
                '    col=mix(col,sky(rd)*0.6+vec3(0.02,0.04,0.14)*0.4,ff);',
                '    return col;',
                '}',

                // ── main ──────────────────────────────────────────────────
                'void main(){',
                '    vec2 uv=(gl_FragCoord.xy-u_res*0.5)/u_res.y;',
                '    float cz=u_camZ;',
                '    float cx=trkX(cz);',
                '    float cxd=trkXd(cz);',
                // camera – eye position follows track curve, mouse adds lateral tilt
                '    vec3 ro=vec3(cx+u_mouse.x*1.2,1.88,cz);',
                '    vec3 fwd=normalize(vec3(cxd,-0.065+u_mouse.y*0.12,1.0));',
                '    vec3 right=normalize(cross(fwd,vec3(0.0,1.0,0.0)));',
                '    vec3 up=cross(right,fwd);',
                '    vec3 rd=normalize(fwd+right*uv.x*0.82+up*uv.y*0.82);',
                '    vec3 col=raymarch(ro,rd);',
                // ACES tone mapping
                '    col=(col*(2.51*col+0.03))/(col*(2.43*col+0.59)+0.14);',
                // gamma
                '    col=pow(clamp(col,0.0,1.0),vec3(0.4545));',
                // vignette
                '    float vig=dot(uv,uv);',
                '    col*=1.0-vig*0.44;',
                // subtle film grain
                '    float grain=(hash(gl_FragCoord.xy+vec2(u_time*137.0,u_time*89.0))-0.5)*0.028;',
                '    col=clamp(col+grain,0.0,1.0);',
                // speed-streak blur hint at edges
                '    float streak=pow(abs(uv.x)*1.6,3.5)*0.14;',
                '    col=mix(col,col*0.45,streak);',
                '    gl_FragColor=vec4(col,1.0);',
                '}'
            ].join('\n');

            // ─────────────────────────────────────────────────────────────
            //  WebGL bootstrap
            // ─────────────────────────────────────────────────────────────
            function initWebGL() {
                var canvas = document.getElementById('railtrack-canvas');
                if (!canvas) return;

                var gl = canvas.getContext('webgl') ||
                         canvas.getContext('experimental-webgl');
                if (!gl) {
                    console.warn('WebGL unavailable – falling back to gradient.');
                    canvas.style.background = 'linear-gradient(135deg,#050a18 0%,#1e3a8a 60%,#2563eb 100%)';
                    return;
                }

                function makeShader(type, src) {
                    var s = gl.createShader(type);
                    gl.shaderSource(s, src);
                    gl.compileShader(s);
                    if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) {
                        console.error('Shader compile error:', gl.getShaderInfoLog(s));
                        return null;
                    }
                    return s;
                }

                var vs = makeShader(gl.VERTEX_SHADER,   VS);
                var fs = makeShader(gl.FRAGMENT_SHADER, FS);
                if (!vs || !fs) return;

                var prog = gl.createProgram();
                gl.attachShader(prog, vs);
                gl.attachShader(prog, fs);
                gl.linkProgram(prog);
                if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) {
                    console.error('Shader link error:', gl.getProgramInfoLog(prog));
                    return;
                }
                gl.useProgram(prog);

                // Fullscreen triangle-strip quad  (-1,-1) → (1,1)
                var quadBuf = gl.createBuffer();
                gl.bindBuffer(gl.ARRAY_BUFFER, quadBuf);
                gl.bufferData(gl.ARRAY_BUFFER,
                    new Float32Array([-1,-1, 1,-1, -1,1, 1,1]),
                    gl.STATIC_DRAW);
                var aPos = gl.getAttribLocation(prog, 'a_pos');
                gl.enableVertexAttribArray(aPos);
                gl.vertexAttribPointer(aPos, 2, gl.FLOAT, false, 0, 0);

                // Uniform locations
                var uRes   = gl.getUniformLocation(prog, 'u_res');
                var uTime  = gl.getUniformLocation(prog, 'u_time');
                var uCamZ  = gl.getUniformLocation(prog, 'u_camZ');
                var uMouse = gl.getUniformLocation(prog, 'u_mouse');

                // ── State ──────────────────────────────────────────────
                var autoZ    = 0.0;   // continuous auto-advance
                var scrollZ  = 0.0;   // scroll contribution
                var camZ     = 0.0;   // smoothed camera Z
                var mouseX   = 0.0;
                var mouseY   = 0.0;
                var lastMs   = performance.now();
                var startMs  = performance.now();
                var active   = true;
                var rafId    = null;

                // Scroll → additional track progress
                window.addEventListener('scroll', function () {
                    scrollZ = window.scrollY * 0.10;  // 0.1 units per px
                }, { passive: true });

                // Mouse parallax
                window.addEventListener('mousemove', function (e) {
                    mouseX = (e.clientX / window.innerWidth  - 0.5) * 2.0;
                    mouseY = (e.clientY / window.innerHeight - 0.5) * 2.0;
                });
                window.addEventListener('touchmove', function (e) {
                    if (e.touches.length) {
                        mouseX = (e.touches[0].clientX / window.innerWidth  - 0.5) * 2.0;
                        mouseY = (e.touches[0].clientY / window.innerHeight - 0.5) * 2.0;
                    }
                }, { passive: true });

                // Resize – keep canvas pixel size matching CSS size
                function resize() {
                    var w = canvas.offsetWidth  || window.innerWidth;
                    var h = canvas.offsetHeight || window.innerHeight;
                    if (canvas.width !== w || canvas.height !== h) {
                        canvas.width  = w;
                        canvas.height = h;
                        gl.viewport(0, 0, w, h);
                    }
                }
                window.addEventListener('resize', resize);
                resize();

                // ── Render loop ────────────────────────────────────────
                function render() {
                    if (!active) { rafId = null; return; }
                    rafId = requestAnimationFrame(render);

                    var now = performance.now();
                    var dt  = Math.min((now - lastMs) * 0.001, 0.05);
                    lastMs  = now;
                    var elapsed = (now - startMs) * 0.001;

                    // Auto-advance (3 units/sec) + scroll boost
                    autoZ += dt * 3.0;
                    var targetZ = autoZ + scrollZ;
                    // Exponential smooth follow
                    camZ += (targetZ - camZ) * (1.0 - Math.exp(-dt * 4.0));

                    resize();

                    gl.uniform2f(uRes,   canvas.width, canvas.height);
                    gl.uniform1f(uTime,  elapsed);
                    gl.uniform1f(uCamZ,  camZ);
                    gl.uniform2f(uMouse, mouseX * 0.5, -mouseY * 0.5);

                    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
                }

                // Pause when not visible
                var obs = new IntersectionObserver(function (entries) {
                    active = entries[0].isIntersecting;
                    if (active && !rafId) {
                        lastMs = performance.now();
                        render();
                    }
                }, { threshold: 0 });
                obs.observe(canvas);

                render();
            }
        })();
        </script>

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
                            closeResetRequest();
                            closeResetForm();
                            if (typeof closeAdminAccess === 'function') closeAdminAccess();
                            if (typeof closeSupervisorRegister === 'function') closeSupervisorRegister();
                            openLogin();
                        }
                        function switchToRegister() {
                            openRegister();
                            closeLogin();
                        }
                        function switchToResetRequest() {
                            closeLogin();
                            closeRegister();
                            closeResetForm();
                            openResetRequest();
                        }

// Close on outside click
                        regOverlay.addEventListener('mousedown', function (e) {
                            if (e.target === regOverlay)
                                closeRegister();
                        });
                        regModal.addEventListener('mousedown', function (e) {
                            e.stopPropagation();
                        });

                        var supRegOverlay = document.getElementById('supervisorRegisterOverlay');
                        var supRegModal = document.getElementById('supervisorRegisterModal');

                        function openSupervisorRegister() {
                            if(supRegOverlay) {
                                supRegOverlay.classList.add('open');
                                document.body.style.overflow = 'hidden';
                            }
                        }

                        function closeSupervisorRegister() {
                            if(supRegOverlay) {
                                supRegOverlay.classList.remove('open');
                                document.body.style.overflow = '';
                            }
                        }

                        function switchToSupervisorRegister() {
                            closeLogin();
                            closeRegister();
                            closeResetRequest();
                            closeResetForm();
                            if (typeof closeAdminAccess === 'function') closeAdminAccess();
                            openSupervisorRegister();
                        }

                        var adminAccOverlay = document.getElementById('adminAccessOverlay');
                        var adminAccModal = document.getElementById('adminAccessModal');

                        function openAdminAccess() {
                            if(adminAccOverlay) {
                                adminAccOverlay.classList.add('open');
                                document.body.style.overflow = 'hidden';
                                setTimeout(() => {
                                    var u = document.getElementById('adminCodeInput');
                                    if (u) u.focus();
                                }, 100);
                            }
                        }

                        function closeAdminAccess() {
                            if(adminAccOverlay) {
                                adminAccOverlay.classList.remove('open');
                                document.body.style.overflow = '';
                                document.getElementById('adminCodeInput').value = '';
                            }
                        }

                        function switchToAdminAccess() {
                            closeLogin();
                            closeRegister();
                            closeResetRequest();
                            closeResetForm();
                            if (typeof closeSupervisorRegister === 'function') closeSupervisorRegister();
                            openAdminAccess();
                        }
                        
                        function verifyAdminCode() {
                            var code = document.getElementById('adminCodeInput').value;
                            if (code === 'admin123') {
                                document.getElementById('hiddenAdminCode').value = code;
                                switchToSupervisorRegister();
                            } else {
                                alert('Invalid admin access code.');
                            }
                        }
                        
                        if(adminAccOverlay) {
                            adminAccOverlay.addEventListener('mousedown', function (e) {
                                if (e.target === adminAccOverlay) closeAdminAccess();
                            });
                        }
                        if(adminAccModal) {
                            adminAccModal.addEventListener('mousedown', function (e) {
                                e.stopPropagation();
                            });
                        }

                        if(supRegOverlay) {
                            supRegOverlay.addEventListener('mousedown', function (e) {
                                if (e.target === supRegOverlay)
                                    closeSupervisorRegister();
                            });
                        }
                        if(supRegModal) {
                            supRegModal.addEventListener('mousedown', function (e) {
                                e.stopPropagation();
                            });
                        }

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

                        function toggleRegVisibility(btn) {
                            var input = btn.previousElementSibling;
                            var icon = btn.querySelector('i');
                            if (input.type === 'password') {
                                input.type = 'text';
                                icon.className = 'bi bi-eye-slash';
                            } else {
                                input.type = 'password';
                                icon.className = 'bi bi-eye';
                            }
                        }

                        // ── Reset Request Modal ────────────────────────────────
                        var resetReqOverlay = document.getElementById('resetRequestOverlay');
                        var resetReqModal   = document.getElementById('resetRequestModal');
                        function openResetRequest() {
                            resetReqOverlay.classList.add('open');
                            document.body.style.overflow = 'hidden';
                            setTimeout(() => { var e = resetReqModal.querySelector('input[name="email"]'); if(e) e.focus(); }, 100);
                        }
                        function closeResetRequest() {
                            resetReqOverlay.classList.remove('open');
                            document.body.style.overflow = '';
                        }
                        resetReqOverlay.addEventListener('mousedown', function(e) { if (e.target === resetReqOverlay) closeResetRequest(); });
                        resetReqModal.addEventListener('mousedown', function(e) { e.stopPropagation(); });

                        // ── Reset Form Modal (set new password) ────────────────
                        var resetFrmOverlay = document.getElementById('resetFormOverlay');
                        var resetFrmModal   = document.getElementById('resetFormModal');
                        function openResetForm() {
                            resetFrmOverlay.classList.add('open');
                            document.body.style.overflow = 'hidden';
                        }
                        function closeResetForm() {
                            resetFrmOverlay.classList.remove('open');
                            document.body.style.overflow = '';
                        }
                        resetFrmOverlay.addEventListener('mousedown', function(e) { if (e.target === resetFrmOverlay) closeResetForm(); });
                        resetFrmModal.addEventListener('mousedown', function(e) { e.stopPropagation(); });

                        function toggleNewPassword() {
                            var input = document.getElementById('newPasswordInput');
                            var icon  = document.getElementById('newEyeIcon');
                            if (input.type === 'password') {
                                input.type = 'text';
                                icon.className = 'bi bi-eye-slash';
                            } else {
                                input.type = 'password';
                                icon.className = 'bi bi-eye';
                            }
                        }

                        function validateNewPasswords() {
                            var p1 = document.getElementById('newPasswordInput').value;
                            var p2 = document.getElementById('confirmNewPassword').value;
                            if (p1 !== p2) {
                                alert('Passwords do not match. Please try again.');
                                return false;
                            }
                            return true;
                        }

                        document.addEventListener('keydown', function (e) {
                            if (e.key === 'Escape') {
                                closeLogin();
                                closeRegister();
                                closeResetRequest();
                                closeResetForm();
                                if (typeof closeAdminAccess === 'function') closeAdminAccess();
                                if (typeof closeSupervisorRegister === 'function') closeSupervisorRegister();
                            }
                        });

            <% if (loginError != null || "logged_out".equals(msg) || "login".equals(request.getParameter("action"))
                    || "reset_sent".equals(msg) || "password_reset".equals(msg)) { %>
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
            <% if ("reset_form".equals(request.getParameter("action")) && resetToken != null) { %>
                        if (document.readyState === 'loading') {
                            document.addEventListener('DOMContentLoaded', openResetForm);
                        } else {
                            openResetForm();
                        }
            <% } %>
            <% if ("reg_error".equals(errorParam) || "registered".equals(msg) || "register".equals(request.getParameter("action"))) { %>
                        if (document.readyState === 'loading') {
                            document.addEventListener('DOMContentLoaded', function () {
                                openRegister();
                            });
                        } else {
                            openRegister();
                        }
            <% }%>
                        // Auto-fill username from email (register forms)
                        document.addEventListener("DOMContentLoaded", function () {
                            const forms = [document.querySelector('#registerModal'), document.querySelector('#supervisorRegisterModal')];
                            forms.forEach(function(modal) {
                                if (!modal) return;
                                const emailInput = modal.querySelector('input[name="email"]');
                                const usernameInput = modal.querySelector('input[name="username"]');
                                if(!emailInput || !usernameInput) return;

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
                        });
        </script>
    </body>
</html>

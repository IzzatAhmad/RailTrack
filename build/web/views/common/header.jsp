<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="com.railtrack.system.service.AuthService" %>
        <% String role=(String) session.getAttribute("userRole"); String userName=(String)
            session.getAttribute("userName"); String ctx=request.getContextPath(); String pageTitle=(String)
            request.getAttribute("pageTitle"); if (pageTitle==null) { pageTitle="RailTrack" ; } String
            dashboardUrl="/login" ; if ("STUDENT".equals(role)) { dashboardUrl=ctx + "/student/dashboard" ; } else if
            ("SUPERVISOR".equals(role)) { dashboardUrl=ctx + "/supervisor/dashboard" ; } else if
            ("COORDINATOR".equals(role)) { dashboardUrl=ctx + "/coordinator/dashboard" ; } String profileUrl="/login" ;
            if ("STUDENT".equals(role)) { profileUrl=ctx + "/student/profile" ; } else if ("SUPERVISOR".equals(role)) {
            profileUrl=ctx + "/supervisor/profile" ; } else if ("COORDINATOR".equals(role)) { profileUrl=ctx
            + "/coordinator/profile" ; } java.util.Map<String, Long> notif
            = (java.util.Map<String, Long>) request.getAttribute("notif");
                long notifTotal = (notif != null && notif.containsKey("total")) ? notif.get("total") : 0;
                %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1" />
                    <title>RailTrack | <%= pageTitle%>
                    </title>
                    <!-- Favicon - PNG -->
                    <link rel="icon" type="image/png" href="<%= request.getContextPath() %>/img/roadway.png"
                        sizes="32x32">
                    <!-- Additional sizes for better support -->
                    <link rel="icon" type="image/png" href="<%= request.getContextPath()%>/img/roadway.png"
                        sizes="16x16">
                    <!-- Apple Touch Icon (iOS) -->
                    <link rel="apple-touch-icon" href="<%= request.getContextPath()%>/img/roadway.png">

                    <!-- Bootstrap 5 -->
                    <link rel="stylesheet"
                        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" />
                    <!-- Bootstrap Icons -->
                    <link rel="stylesheet"
                        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />
                    <!-- Google Fonts: DM Sans + DM Mono -->
                    <link rel="preconnect" href="https://fonts.googleapis.com" />
                    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
                    <link
                        href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600;700&family=DM+Mono:wght@400;500&display=swap"
                        rel="stylesheet" />

                    <style>
                        :root {
                            --rt-primary: #2563eb;
                            --rt-primary-dk: #1d4ed8;
                            --rt-surface: #ffffff;
                            --rt-bg: #f4f6fb;
                            --rt-border: #e5e9f2;
                            --rt-text: #1e2740;
                            --rt-muted: #6b7a99;
                            --rt-success: #16a34a;
                            --rt-warning: #d97706;
                            --rt-danger: #dc2626;
                            --rt-info: #0891b2;
                            --rt-radius: 10px;
                            --rt-shadow: 0 1px 4px rgba(30, 39, 64, .08);
                            --rt-nav-h: 60px;
                        }

                        *,
                        *::before,
                        *::after {
                            box-sizing: border-box;
                        }

                        body {
                            font-family: 'DM Sans', sans-serif;
                            background: var(--rt-bg);
                            color: var(--rt-text);
                            min-height: 100vh;
                            display: flex;
                            flex-direction: column;
                        }

                        /* ── Navbar ── */
                        .rt-nav {
                            height: var(--rt-nav-h);
                            background: var(--rt-surface);
                            border-bottom: 1px solid var(--rt-border);
                            display: flex;
                            align-items: center;
                            padding: 0 1.5rem;
                            gap: 1rem;
                            position: sticky;
                            top: 0;
                            z-index: 100;
                            box-shadow: var(--rt-shadow);
                        }

                        .rt-nav-brand {
                            display: flex;
                            align-items: center;
                            gap: .55rem;
                            text-decoration: none;
                            font-weight: 700;
                            font-size: 1.05rem;
                            color: var(--rt-text);
                            letter-spacing: -.02em;
                        }

                        .rt-nav-brand .bi {
                            font-size: 1.3rem;
                            color: var(--rt-primary);
                        }

                        .rt-nav-brand small {
                            font-weight: 400;
                            font-size: .65rem;
                            color: var(--rt-muted);
                            display: block;
                            line-height: 1;
                            letter-spacing: 0;
                        }

                        .rt-nav-spacer {
                            flex: 1;
                        }

                        .rt-nav-links {
                            display: flex;
                            align-items: center;
                            gap: .25rem;
                        }

                        .rt-nav-link {
                            display: inline-flex;
                            align-items: center;
                            gap: .35rem;
                            padding: .38rem .55rem;
                            border-radius: 6px;
                            color: var(--rt-muted);
                            font-size: .82rem;
                            font-weight: 600;
                            text-decoration: none;
                            white-space: nowrap;
                            transition: background .15s, color .15s;
                        }

                        .rt-nav-link:hover {
                            background: var(--rt-bg);
                            color: var(--rt-primary);
                        }

                        .rt-role-badge {
                            font-size: .65rem;
                            font-weight: 600;
                            letter-spacing: .07em;
                            padding: .18rem .55rem;
                            border-radius: 4px;
                            border: 1px solid var(--rt-border);
                            color: var(--rt-muted);
                            text-transform: uppercase;
                            background: var(--rt-bg);
                        }

                        .rt-role-badge.STUDENT {
                            color: var(--rt-primary);
                            border-color: #bfdbfe;
                            background: #eff6ff;
                        }

                        .rt-role-badge.SUPERVISOR {
                            color: var(--rt-success);
                            border-color: #bbf7d0;
                            background: #f0fdf4;
                        }

                        .rt-role-badge.COORDINATOR {
                            color: var(--rt-warning);
                            border-color: #fde68a;
                            background: #fffbeb;
                        }

                        .rt-notif-btn {
                            position: relative;
                            background: none;
                            border: none;
                            color: var(--rt-muted);
                            font-size: 1.2rem;
                            cursor: pointer;
                            padding: .25rem;
                        }

                        .rt-notif-dot {
                            position: absolute;
                            top: 1px;
                            right: 1px;
                            width: 8px;
                            height: 8px;
                            background: var(--rt-danger);
                            border-radius: 50%;
                            border: 1.5px solid white;
                        }

                        .rt-user-menu {
                            display: flex;
                            align-items: center;
                            gap: .5rem;
                            cursor: pointer;
                            padding: .3rem .6rem;
                            border-radius: var(--rt-radius);
                            transition: background .15s;
                        }

                        .rt-user-menu:hover {
                            background: var(--rt-bg);
                        }

                        .rt-user-avatar {
                            width: 32px;
                            height: 32px;
                            border-radius: 50%;
                            background: var(--rt-primary);
                            color: #fff;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: .8rem;
                            font-weight: 600;
                        }

                        .rt-logout-btn {
                            font-size: .82rem;
                            padding: .3rem .75rem;
                            border-radius: 6px;
                            border: 1px solid var(--rt-danger);
                            color: var(--rt-danger);
                            background: none;
                            text-decoration: none;
                            transition: all .15s;
                        }

                        .rt-logout-btn:hover {
                            background: var(--rt-danger);
                            color: #fff;
                        }

                        /* ── Main content ── */
                        .rt-main {
                            flex: 1;
                            padding: 1.75rem 1.5rem 2rem;
                            max-width: 1280px;
                            width: 100%;
                            margin: 0 auto;
                        }

                        /* ── Status badges ── */
                        .rt-status-pending {
                            background: #fef3c7;
                            color: #92400e;
                        }

                        .rt-status-active {
                            background: #d1fae5;
                            color: #065f46;
                        }

                        .rt-status-under_review {
                            background: #dbeafe;
                            color: #1e40af;
                        }

                        .rt-status-completed {
                            background: #e0e7ff;
                            color: #3730a3;
                        }

                        .rt-status-rejected {
                            background: #fee2e2;
                            color: #991b1b;
                        }

                        /* ── Docker status colours ── */
                        .rt-docker-running {
                            color: var(--rt-success);
                            font-weight: 500;
                        }

                        .rt-docker-stopped {
                            color: var(--rt-muted);
                        }

                        .rt-docker-error {
                            color: var(--rt-danger);
                        }

                        .rt-docker-built {
                            color: var(--rt-info);
                        }

                        .rt-docker-none {
                            color: var(--rt-muted);
                        }

                        /* ── Cards ── */
                        .rt-card {
                            background: var(--rt-surface);
                            border: 1px solid var(--rt-border);
                            border-radius: var(--rt-radius);
                            box-shadow: var(--rt-shadow);
                        }

                        .rt-card-header {
                            padding: .9rem 1.2rem;
                            border-bottom: 1px solid var(--rt-border);
                            font-weight: 600;
                            font-size: .9rem;
                            display: flex;
                            align-items: center;
                            gap: .5rem;
                        }

                        /* ── Monospace (logs, code) ── */
                        .rt-mono {
                            font-family: 'DM Mono', monospace;
                            font-size: .8rem;
                        }

                        /* ── Filter buttons ── */
                        .rt-filter-btn.active {
                            font-weight: 600;
                        }

                        /* ── Alerts ── */
                        .rt-alert {
                            padding: .7rem 1rem;
                            border-radius: 8px;
                            font-size: .875rem;
                            border: 1px solid transparent;
                            display: flex;
                            align-items: center;
                            gap: .5rem;
                        }

                        .rt-alert-success {
                            background: #f0fdf4;
                            color: #166534;
                            border-color: #bbf7d0;
                        }

                        .rt-alert-error {
                            background: #fef2f2;
                            color: #991b1b;
                            border-color: #fecaca;
                        }

                        .rt-alert-info {
                            background: #eff6ff;
                            color: #1e40af;
                            border-color: #bfdbfe;
                        }

                        /* ── Responsive table ── */
                        .table th {
                            font-size: .75rem;
                            text-transform: uppercase;
                            letter-spacing: .05em;
                            color: var(--rt-muted);
                            font-weight: 600;
                        }

                        .table td {
                            font-size: .875rem;
                            vertical-align: middle;
                        }

                        /* ── Mobile ── */
                        @media (max-width: 576px) {
                            .rt-main {
                                padding: 1rem .75rem;
                            }

                            .rt-nav {
                                padding: 0 .75rem;
                            }

                            .rt-nav-links {
                                display: none;
                            }
                        }
                    </style>
                </head>

                <body>

                    <!-- ── Navbar ─────────────────────────────────────────────────── -->
                    <nav class="rt-nav">
                        <a href="<%= dashboardUrl%>" class="rt-nav-brand">
                            <img src="<%= request.getContextPath()%>/img/roadway.gif" alt="RailTrack"
                                style="width:28px;height:28px;object-fit:cover;border-radius:50%;">
                            <span>RailTrack <small>FYP Management</small></span>
                        </a>

                        <div class="rt-nav-spacer"></div>

                        <div class="d-none d-md-flex align-items-center gap-2">
                            <% if (role==null) { %>
                                <!-- Guest links -->
                                <a href="#problem" class="text-decoration-none"
                                    style="font-size:.875rem;color:var(--rt-muted);">Problem</a>
                                <a href="#solution" class="text-decoration-none"
                                    style="font-size:.875rem;color:var(--rt-muted);">Solution</a>
                                <a href="#workflow" class="text-decoration-none"
                                    style="font-size:.875rem;color:var(--rt-muted);">Workflow</a>
                                <a href="javascript:void(0)" onclick="openLogin()"
                                    class="btn btn-primary btn-sm ms-2">Sign
                                    in</a>

                                <% } else { %>

                                    <% if ("COORDINATOR".equals(role)) { %>
                                        <div class="rt-nav-links d-none d-md-flex">
                                        </div>
                                        <% } %>

                                            <!-- Notification bell -->
                                            <% if (notifTotal> 0) {%>
                                                <button class="rt-notif-btn" title="<%= notifTotal%> notification(s)">
                                                    <span class="rt-notif-dot"></span>
                                                    <img src="<%= request.getContextPath()%>/img/alarm.gif"
                                                        alt="RailTrack"
                                                        style="width:32px;height:32px;object-fit:cover;border-radius:50%;">
                                                </button>
                                                <% }%>

                                                    <!-- Role badge -->
                                                    <span class="rt-role-badge <%= role%>">
                                                        <%= role%>
                                                    </span>

                                                    <!-- User avatar + name -->
                                                    <a href="<%= profileUrl%>"
                                                        class="rt-user-menu text-decoration-none">
                                                        <div class="rt-user-avatar">
                                                            <%= userName !=null && !userName.isEmpty() ?
                                                                String.valueOf(userName.charAt(0)).toUpperCase() : "?"
                                                                %>
                                                        </div>
                                                        <span class="text-dark fw-medium" style="font-size:.875rem;">
                                                            <%= userName%>
                                                        </span>
                                                    </a>
                                                    <div class="vr h-75 my-auto"></div>
                                                    <!-- Logout -->
                                                    <a href="<%= ctx%>/logout" class="rt-logout-btn">
                                                        <i class="bi bi-box-arrow-right me-1"></i>
                                                        <span>Logout</span>
                                                    </a>

                                                    <% }%>
                        </div>

                        <!-- Mobile Toggle Button -->
                        <button class="btn btn-sm d-md-none border-0 ms-2" type="button" data-bs-toggle="offcanvas"
                            data-bs-target="#mobileOffcanvasNav" aria-controls="mobileOffcanvasNav">
                            <i class="bi bi-list fs-3 text-dark"></i>
                        </button>
                    </nav>

                    <!-- Offcanvas Mobile Menu -->
                    <div class="offcanvas offcanvas-end" tabindex="-1" id="mobileOffcanvasNav"
                        aria-labelledby="mobileOffcanvasNavLabel">
                        <div class="offcanvas-header border-bottom">
                            <h5 class="offcanvas-title fw-bold" id="mobileOffcanvasNavLabel">Menu</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="offcanvas"
                                aria-label="Close"></button>
                        </div>
                        <div class="offcanvas-body">
                            <% if (role==null) { %>
                                <div class="d-flex flex-column gap-3">
                                    <a href="#problem" class="text-decoration-none text-dark fw-medium">Problem</a>
                                    <a href="#solution" class="text-decoration-none text-dark fw-medium">Solution</a>
                                    <a href="#workflow" class="text-decoration-none text-dark fw-medium">Workflow</a>
                                    <button onclick="openLogin()" class="btn btn-primary w-100 mt-2"
                                        data-bs-dismiss="offcanvas">Sign in</button>
                                </div>
                                <% } else { %>
                                    <div class="d-flex flex-column gap-3">
                                        <div class="d-flex align-items-center gap-2 mb-2">
                                            <div class="rt-user-avatar"
                                                style="width: 40px; height: 40px; border-radius: 50%; background: var(--rt-primary); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 1rem; font-weight: 600;">
                                                <%= userName !=null && !userName.isEmpty() ?
                                                    String.valueOf(userName.charAt(0)).toUpperCase() : "?" %>
                                            </div>
                                            <div>
                                                <div class="fw-bold text-dark">
                                                    <%= userName%>
                                                </div>
                                                <div class="rt-role-badge <%= role%> mt-1"
                                                    style="display:inline-block;">
                                                    <%= role%>
                                                </div>
                                            </div>
                                        </div>

                                        <hr class="my-1">

                                        <a href="<%= profileUrl%>"
                                            class="text-decoration-none text-dark fw-medium p-2 rounded"
                                            style="transition: background .15s;"
                                            onmouseover="this.style.background='var(--rt-bg)'"
                                            onmouseout="this.style.background='transparent'">
                                            <i class="bi bi-person me-2"></i> Profile
                                        </a>

                                        <a href="<%= ctx%>/logout"
                                            class="text-decoration-none text-danger fw-medium mt-auto pt-3 border-top">
                                            <i class="bi bi-box-arrow-right me-2"></i> Logout
                                        </a>
                                    </div>
                                    <% }%>
                        </div>
                    </div>


                    <!-- ── Page content ───────────────────────────────────────────── -->
                    <main class="rt-main">
<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %> <!doctype html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>railtrack.com - 403</title>
        <!-- Favicon - PNG -->
        <link rel="icon" type="image/png" href="<%= request.getContextPath() %>/img/roadwayicon.png" sizes="32x32">
        <!-- Additional sizes for better support -->
        <link rel="icon" type="image/png" href="<%= request.getContextPath() %>/img/roadwayicon.png" sizes="16x16">
        <!-- Apple Touch Icon (iOS) -->
        <link rel="apple-touch-icon" href="<%= request.getContextPath() %>/img/roadwayicon.png">
        
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet" />
    </head>
    <body class="bg-white">
        <div class="min-vh-100 d-flex align-items-center justify-content-center text-center">
            <div>
                <img src="<%= request.getContextPath()%>/img/forbidden.gif"
                    alt="RailTrack"
                    style="width: 128px; height: 128px; object-fit: cover; border-radius: 50%"/>
                <p class="display-6 fw-bold mt-3">Access denied! This route isn’t open to you.</p>
                <p class="lead text-muted">Restart the page, or switch to a supported setup.</p>
                <button type="button" onclick="refresh()" class="btn btn-primary">Try again</button>
                <button type="button" onclick="home()" class="btn btn-dark">Go Home</button>
            </div>
        </div>
    </body>
</html>
<script>
    function home() {
        window.location = "<%= request.getContextPath()%>";
    }
    function refresh() {
        window.location.reload();
    }
</script>

<%@ page contentType="text/html;charset=UTF-8" %>
</main><!-- /rt-main -->

<!-- Footer -->
<footer class="container-fluid  py-4" style="background-color: white !important;">
    <div class="container">
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-center">

            <div class="d-flex align-items-center mb-3 mb-md-0">
                <div class="me-4">
                    <img src="<%= request.getContextPath() %>/img/roadway.gif" 
                         alt="RailTrack" 
                         style="width: 32px; height: 32px; object-fit: cover; border-radius: 50%;">
                </div>

                <a class="text-success text-decoration-none d-flex small font-monospace">
                    &copy; 2026 RailTrack Platform. Built for University Final Year Projects. 
                </a>
            </div>

            <div class="small font-monospace">
                Powered by Docker & Java EE.
            </div>

        </div>
    </div>
</footer>
<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="<%= request.getContextPath() %>/js/railtrack.js"></script>

<!-- Global JS: filter buttons, flash messages, SSE badge refresh -->
<script>
(function () {
    // ── Heartbeat: ping /heartbeat every 2 minutes to keep online status alive
    (function () {
        var ctxPath = '<%= request.getContextPath() %>';
        function ping() {
            fetch(ctxPath + '/heartbeat', { method: 'POST', credentials: 'same-origin' })
                .catch(function() {}); // silently ignore network errors
        }
        ping(); // immediate ping on page load
        setInterval(ping, 2 * 60 * 1000); // ping every 2 minutes
    })();

    // ── Status filter buttons ─────────────────────────────────────────────────
    document.querySelectorAll('.rt-filter-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.rt-filter-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            const filter = btn.dataset.filter;
            document.querySelectorAll('#projectsTable tbody tr').forEach(row => {
                row.style.display =
                    (filter === 'all' || row.dataset.status === filter) ? '' : 'none';
            });
        });
    });

    // ── Auto-dismiss flash alerts after 4 s ──────────────────────────────────
    document.querySelectorAll('.rt-flash').forEach(el => {
        setTimeout(() => {
            el.style.transition = 'opacity .4s';
            el.style.opacity = '0';
            setTimeout(() => el.remove(), 400);
        }, 4000);
    });

    // ── SSE docker-status badge updates ──────────────────────────────────────
    const sseTarget = document.getElementById('dashboard-sse-target');
    if (sseTarget) {
        const ctx = sseTarget.dataset.ctx || '';
        // connect to a hypothetical status-stream endpoint per project
        // (individual project pages use DockerSSEServlet instead)
    }
})();
</script>
</body>
</html>

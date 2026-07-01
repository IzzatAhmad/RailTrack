<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ page import="com.railtrack.system.model.User" %>
        <% String role=(String) session.getAttribute("userRole"); boolean isCoordinator="COORDINATOR" .equals(role);
            String ctx=request.getContextPath(); %>
            <jsp:include page="/views/common/header.jsp" />

            <!-- FullCalendar Core and DayGrid Plugin -->
            <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.15/index.global.min.js"></script>
            <!-- SweetAlert2 for nice alerts -->
            <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

            <style>
                .calendar-container {
                    max-width: 1100px;
                    margin: 0 auto;
                    background: #fff;
                    padding: 20px;
                    border-radius: 8px;
                    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
                }
                #calendar {
                    width: 100%;
                }

                @media (max-width: 768px) {
                    .calendar-container {
                        padding: 10px;
                    }
                    .fc .fc-toolbar {
                        flex-direction: column;
                        gap: 10px;
                    }
                    .fc-toolbar-title {
                        font-size: 1.1rem !important;
                    }
                    .fc .fc-button {
                        padding: 0.25rem 0.5rem !important;
                        font-size: 0.75rem !important;
                    }
                    .fc-col-header-cell-cushion, .fc-daygrid-day-number {
                        font-size: 0.75rem !important;
                    }
                    .fc-event-title {
                        font-size: 0.65rem !important;
                    }
                }

                .fc-event {
                    cursor: pointer;
                }

                .fc-toolbar-title {
                    font-weight: 600 !important;
                    color: var(--rt-dark) !important;
                }

                .holiday-event {
                    background-color: #10b981 !important;
                    border-color: #059669 !important;
                    color: #fff !important;
                }
            </style>

            <!-- Breadcrumb -->
            <nav style="font-size:.82rem;margin-bottom:1.25rem;">
                <a href="<%= ctx %>/<%= role != null ? role.toLowerCase() : "student" %>/dashboard" style="color:var(--rt-primary);text-decoration:none;">
                    <i class="bi bi-house me-1"></i>Dashboard
                </a>
                <% if ("COORDINATOR".equals(role)) { %>
                <span class="mx-1" style="color:var(--rt-muted);">/</span>
                <a href="<%= ctx %>/coordinator/menu" style="color:var(--rt-primary);text-decoration:none;">Student Menu Management</a>
                <% } %>
                <span class="mx-1" style="color:var(--rt-muted);">/</span>
                <span style="color:var(--rt-muted);">Planning & Calendar</span>
            </nav>

            <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-2">
                <div>
                    <h4 class="fw-bold mb-0">Planning & Calendar</h4>
                    <p class="text-muted mb-0" style="font-size:.875rem;">View important dates and project schedules</p>
                </div>
            </div>

            <div class="calendar-container">
                <div id='calendar'></div>
            </div>

            <hr class="my-5">
<div class="row mb-5">
    <div class="col-12 col-lg-8 mx-auto">
        
        <!-- Upcoming Events (Top) -->
        <h5 class="fw-bold mb-3"><i class="bi bi-calendar-event me-2 text-primary"></i> Upcoming Events</h5>
        <div id="upcomingEventListContainer" class="list-group shadow-sm mb-5">
            <div class="list-group-item text-center text-muted py-4">Loading events...</div>
        </div>

        <!-- Past Events (Below) -->
        <h5 class="fw-bold mb-3"><i class="bi bi-clock-history me-2 text-secondary"></i> Past Events</h5>
        <div id="pastEventListContainer" class="list-group shadow-sm">
            <div class="list-group-item text-center text-muted py-4">Loading events...</div>
        </div>
        
    </div>
</div>

            <!-- Add Event Modal -->
            <div class="modal fade" id="addEventModal" tabindex="-1" aria-labelledby="addEventModalLabel"
                aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <form id="addEventForm">
                            <div class="modal-header">
                                <h5 class="modal-title" id="addEventModalLabel">Add Calendar Event</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <input type="hidden" id="eventId" name="eventId">
                                <input type="hidden" id="eventStartDate" name="startDate">

                                <div class="mb-3">
                                    <label for="eventTitle" class="form-label">Event Title</label>
                                    <input type="text" class="form-control" id="eventTitle" required>
                                </div>

                                <div class="mb-3">
                                    <label for="eventDescription" class="form-label">Description (Optional)</label>
                                    <textarea class="form-control" id="eventDescription" rows="3"></textarea>
                                </div>

                                <div class="mb-3">
                                    <label for="eventColor" class="form-label">Color</label>
                                    <input type="color" class="form-control form-control-color" id="eventColor"
                                        value="#3b82f6" title="Choose your color">
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                <button type="submit" class="btn btn-primary">Save Event</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- View Event Modal -->
            <div class="modal fade" id="viewEventModal" tabindex="-1" aria-labelledby="viewEventModalLabel"
                aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="viewEventModalLabel">Event Details</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <h4 id="viewEventTitle" class="mb-2"></h4>
                            <p class="text-muted mb-3" id="viewEventDate"></p>
                            <p id="viewEventDescription"></p>
                        </div>
                        <div class="modal-footer">
                            <% if (isCoordinator) { %>
                                <button type="button" class="btn btn-warning me-auto" id="btnEditEvent">Edit
                                    Event</button>
                                <button type="button" class="btn btn-danger" id="btnDeleteEvent">Delete Event</button>
                                <% } %>
                                    <a href="#" target="_blank"
                                        class="btn btn-outline-primary <%= isCoordinator ? "" : " me-auto" %>"
                                        id="btnGoogleCalendar"><i class="bi bi-google"></i> Add to Calendar</a>
                                    <button type="button" class="btn btn-secondary"
                                        data-bs-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>

            <script>
                document.addEventListener('DOMContentLoaded', function () {
                    var calendarEl = document.getElementById('calendar');
                    var isCoordinator = <%= isCoordinator %>;
                    var addEventModal = new bootstrap.Modal(document.getElementById('addEventModal'));
                    var viewEventModal = new bootstrap.Modal(document.getElementById('viewEventModal'));
                    var selectedEventId = null;

                    var isMobile = window.innerWidth <= 768;
                    var calendar = new FullCalendar.Calendar(calendarEl, {
                        initialView: 'dayGridMonth',
                        aspectRatio: isMobile ? 0.9 : 1.35,
                        height: 'auto',
                        headerToolbar: {
                            left: 'today prev,next',
                            center: 'title',
                            right: 'dayGridMonth,timeGridWeek,timeGridDay'
                        },
                        themeSystem: 'bootstrap5',
                        selectable: isCoordinator,
                        selectMirror: true,
                        windowResize: function(arg) {
                            calendar.setOption('aspectRatio', window.innerWidth <= 768 ? 0.9 : 1.35);
                        },

                        // Fetch external and internal events
                        events: function (fetchInfo, successCallback, failureCallback) {
                            var eventsArray = [];

                            // 1. Fetch internal events from our backend
                            fetch('<%= ctx %>/planning/api/events')
                                .then(res => res.json())
                                .then(internalEvents => {
                                    internalEvents.forEach(e => {
                                        eventsArray.push({
                                            id: e.id,
                                            title: e.title,
                                            start: e.startDate,
                                            end: e.endDate ? e.endDate : e.startDate,
                                            color: e.color || '#3b82f6',
                                            extendedProps: {
                                                description: e.description,
                                                type: 'internal'
                                            }
                                        });
                                    });

                                    // 2. Fetch Malaysia Holidays using Nager.Date API
                                    var year = new Date(fetchInfo.start).getFullYear();
                                    fetch('https://date.nager.at/api/v3/PublicHolidays/' + year + '/MY')
                                        .then(res => {
                                            if (res.ok) return res.json();
                                            return [];
                                        })
                                        .then(holidays => {
                                            holidays.forEach(h => {
                                                eventsArray.push({
                                                    id: 'hol-' + h.date,
                                                    title: h.name,
                                                    start: h.date,
                                                    allDay: true,
                                                    className: 'holiday-event',
                                                    extendedProps: {
                                                        description: 'Public Holiday in Malaysia',
                                                        type: 'holiday'
                                                    }
                                                });
                                            });
                                            renderEventList(eventsArray);
                                            successCallback(eventsArray);
                                        })
                                        .catch(err => {
                                            console.error('Error fetching holidays', err);
                                            // Provide internal events even if holidays fail
                                            renderEventList(eventsArray);
                                            successCallback(eventsArray);
                                        });
                                })
                                .catch(err => {
                                    console.error('Error fetching internal events', err);
                                    failureCallback(err);
                                });
                        },

                        // Triggered when a coordinator selects a date
                        select: function (info) {
                            try {
                                if (!isCoordinator) return;
                                document.getElementById('eventId').value = '';
                                document.getElementById('eventStartDate').value = info.startStr;
                                document.getElementById('eventTitle').value = '';
                                document.getElementById('eventDescription').value = '';
                                document.getElementById('addEventModalLabel').innerText = 'Add Calendar Event';
                                addEventModal.show();
                                calendar.unselect();
                            } catch (err) {
                                alert('JS Error (select): ' + err.message);
                            }
                        },

                        // Triggered on a fast single click on a date
                        dateClick: function (info) {
                            try {
                                if (!isCoordinator) return;
                                document.getElementById('eventId').value = '';
                                document.getElementById('eventStartDate').value = info.dateStr;
                                document.getElementById('eventTitle').value = '';
                                document.getElementById('eventDescription').value = '';
                                document.getElementById('addEventModalLabel').innerText = 'Add Calendar Event';
                                addEventModal.show();
                            } catch (err) {
                                alert('JS Error (dateClick): ' + err.message);
                            }
                        },

                        // Triggered when an event is clicked
                        eventClick: function (info) {
                            var eventObj = info.event;
                            document.getElementById('viewEventTitle').innerText = eventObj.title;

                            var dateStr = eventObj.start.toLocaleDateString();
                            document.getElementById('viewEventDate').innerText = dateStr;

                            document.getElementById('viewEventDescription').innerText = eventObj.extendedProps.description || 'No description available.';

                            selectedEventId = eventObj.id;

                            // Generate Google Calendar Link
                            var dStart = new Date(eventObj.start);
                            var dsStr = dStart.toISOString().split('T')[0].replace(/-/g, "");
                            var deStr = dsStr;
                            if (eventObj.end) {
                                var dEnd = new Date(eventObj.end);
                                deStr = dEnd.toISOString().split('T')[0].replace(/-/g, "");
                            } else {
                                var nextDay = new Date(dStart);
                                nextDay.setDate(nextDay.getDate() + 1);
                                deStr = nextDay.toISOString().split('T')[0].replace(/-/g, "");
                            }
                            var gcalUrl = 'https://calendar.google.com/calendar/render?action=TEMPLATE&text=' + encodeURIComponent(eventObj.title) + '&dates=' + dsStr + '/' + deStr + '&details=' + encodeURIComponent(eventObj.extendedProps.description || '');
                            var btnGoogleCalendar = document.getElementById('btnGoogleCalendar');
                            if (btnGoogleCalendar) {
                                btnGoogleCalendar.href = gcalUrl;
                                var now = new Date();
                                now.setHours(0,0,0,0);
                                if (dStart >= now) {
                                    btnGoogleCalendar.style.display = 'inline-block';
                                } else {
                                    btnGoogleCalendar.style.display = 'none';
                                }
                            }

                            // Hide edit/delete button for holidays
                            var btnDelete = document.getElementById('btnDeleteEvent');
                            var btnEdit = document.getElementById('btnEditEvent');
                            if (btnDelete) {
                                if (eventObj.extendedProps.type === 'holiday') {
                                    btnDelete.style.display = 'none';
                                    if (btnEdit) btnEdit.style.display = 'none';
                                } else {
                                    btnDelete.style.display = 'block';
                                    if (btnEdit) btnEdit.style.display = 'block';
                                }
                            }

                            viewEventModal.show();
                        }
                    });

                    calendar.render();

                    function renderEventList(events) {
                        var upcomingContainer = document.getElementById('upcomingEventListContainer');
                        var pastContainer = document.getElementById('pastEventListContainer');
                        if (!upcomingContainer || !pastContainer) return;

                        upcomingContainer.innerHTML = '';
                        pastContainer.innerHTML = '';

                        if (!events || events.length === 0) {
                            upcomingContainer.innerHTML = '<div class="list-group-item text-center text-muted py-4">No events found.</div>';
                            pastContainer.innerHTML = '<div class="list-group-item text-center text-muted py-4">No events found.</div>';
                            return;
                        }

                        // Sort events by date ascending
                        events.sort(function (a, b) {
                            var dateA = new Date(a.start);
                            var dateB = new Date(b.start);
                            return dateA - dateB;
                        });

                        var now = new Date();
                        now.setHours(0, 0, 0, 0);

                        var hasUpcoming = false;
                        var hasPast = false;

                        events.forEach(function (e) {
                            var dStart = new Date(e.start);
                            var dateStr = dStart.toLocaleDateString(undefined, { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
                            var isHoliday = e.extendedProps && e.extendedProps.type === 'holiday';

                            var dsStr = dStart.toISOString().split('T')[0].replace(/-/g, "");
                            var deStr = dsStr;
                            if (e.end) {
                                var dEnd = new Date(e.end);
                                deStr = dEnd.toISOString().split('T')[0].replace(/-/g, "");
                            } else {
                                var nextDay = new Date(dStart);
                                nextDay.setDate(nextDay.getDate() + 1);
                                deStr = nextDay.toISOString().split('T')[0].replace(/-/g, "");
                            }
                            var gcalUrl = 'https://calendar.google.com/calendar/render?action=TEMPLATE&text=' + encodeURIComponent(e.title) + '&dates=' + dsStr + '/' + deStr + '&details=' + encodeURIComponent(e.extendedProps ? (e.extendedProps.description || '') : '');

                            var item = document.createElement('div');
                            item.className = 'list-group-item list-group-item-action d-flex align-items-center gap-3 p-3';

                            var colorBadge = '<div style="width: 12px; height: 12px; border-radius: 50%; background-color: ' + (e.color || (isHoliday ? '#10b981' : '#3b82f6')) + '; flex-shrink: 0;"></div>';

                            var titleHtml = '<h6 class="mb-1 fw-bold">' + e.title + (isHoliday ? ' <span class="badge bg-success ms-2" style="font-size:0.7em;">Holiday</span>' : '') + '</h6>';
                            var dateHtml = '<p class="mb-1 small text-muted"><i class="bi bi-calendar-event me-1"></i> ' + dateStr + '</p>';
                            var descHtml = e.extendedProps && e.extendedProps.description ? '<p class="mb-0 small">' + e.extendedProps.description + '</p>' : '';

                            var btnHtml = '';
                            if (dStart >= now) {
                                btnHtml = '<a href="' + gcalUrl + '" target="_blank" class="btn btn-sm btn-outline-primary ms-auto text-nowrap"><i class="bi bi-google"></i> Calendar</a>';
                            }

                            item.innerHTML = colorBadge + '<div style="flex:1; min-width: 0;">' + titleHtml + dateHtml + descHtml + '</div>' + btnHtml;

                            if (dStart >= now) {
                                upcomingContainer.appendChild(item);
                                hasUpcoming = true;
                            } else {
                                pastContainer.appendChild(item);
                                hasPast = true;
                            }
                        });

                        if (!hasUpcoming) {
                            upcomingContainer.innerHTML = '<div class="list-group-item text-center text-muted py-4">No upcoming events.</div>';
                        }
                        if (!hasPast) {
                            pastContainer.innerHTML = '<div class="list-group-item text-center text-muted py-4">No past events.</div>';
                        }
                    }

                    // Handle Event Submission
                    document.getElementById('addEventForm').addEventListener('submit', function (e) {
                        e.preventDefault();
                        var eventId = document.getElementById('eventId').value;
                        var title = document.getElementById('eventTitle').value;
                        var description = document.getElementById('eventDescription').value;
                        var startDate = document.getElementById('eventStartDate').value;
                        var color = document.getElementById('eventColor').value;

                        var newEvent = {
                            title: title,
                            description: description,
                            startDate: startDate,
                            color: color
                        };

                        var method = 'POST';
                        if (eventId) {
                            newEvent.id = parseInt(eventId);
                            method = 'PUT';
                        }

                        fetch('<%= ctx %>/planning/api/events', {
                            method: method,
                            headers: {
                                'Content-Type': 'application/json'
                            },
                            body: JSON.stringify(newEvent)
                        })
                            .then(res => {
                                if (res.ok) {
                                    addEventModal.hide();
                                    Swal.fire({
                                        icon: 'success',
                                        title: method === 'PUT' ? 'Event Updated' : 'Event Added',
                                        toast: true,
                                        position: 'top-end',
                                        showConfirmButton: false,
                                        timer: 3000
                                    });
                                    calendar.refetchEvents();
                                } else {
                                    Swal.fire('Error', method === 'PUT' ? 'Failed to update event' : 'Failed to add event', 'error');
                                }
                            });
                    });

                    // Handle Event Edit
                    var btnEditEvent = document.getElementById('btnEditEvent');
                    if (btnEditEvent) {
                        btnEditEvent.addEventListener('click', function () {
                            if (!selectedEventId || selectedEventId.toString().startsWith('hol-')) return;

                            var eventObj = calendar.getEventById(selectedEventId);

                            document.getElementById('eventId').value = eventObj.id;
                            document.getElementById('eventTitle').value = eventObj.title;
                            document.getElementById('eventDescription').value = eventObj.extendedProps.description || '';

                            var d = eventObj.start;
                            var month = '' + (d.getMonth() + 1), day = '' + d.getDate(), year = d.getFullYear();
                            if (month.length < 2) month = '0' + month;
                            if (day.length < 2) day = '0' + day;
                            document.getElementById('eventStartDate').value = [year, month, day].join('-');

                            document.getElementById('eventColor').value = eventObj.backgroundColor || eventObj.extendedProps.color || '#3b82f6';

                            document.getElementById('addEventModalLabel').innerText = 'Edit Calendar Event';

                            viewEventModal.hide();
                            addEventModal.show();
                        });
                    }

                    // Handle Event Deletion
                    var btnDeleteEvent = document.getElementById('btnDeleteEvent');
                    if (btnDeleteEvent) {
                        btnDeleteEvent.addEventListener('click', function () {
                            if (!selectedEventId || selectedEventId.toString().startsWith('hol-')) return;

                            Swal.fire({
                                title: 'Delete Event?',
                                text: "You won't be able to revert this!",
                                icon: 'warning',
                                showCancelButton: true,
                                confirmButtonColor: '#ef4444',
                                cancelButtonColor: '#6c757d',
                                confirmButtonText: 'Yes, delete it!'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    fetch('<%= ctx %>/planning/api/events?id=' + selectedEventId, {
                                        method: 'DELETE'
                                    })
                                        .then(res => {
                                            if (res.ok) {
                                                viewEventModal.hide();
                                                Swal.fire({
                                                    icon: 'success',
                                                    title: 'Event Deleted',
                                                    toast: true,
                                                    position: 'top-end',
                                                    showConfirmButton: false,
                                                    timer: 3000
                                                });
                                                calendar.refetchEvents();
                                            } else {
                                                Swal.fire('Error', 'Failed to delete event', 'error');
                                            }
                                        });
                                }
                            });
                        });
                    }
                });
            </script>

            <jsp:include page="/views/common/footer.jsp" />
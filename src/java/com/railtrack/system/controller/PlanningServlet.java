package com.railtrack.system.controller;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;
import com.railtrack.system.dao.CalendarEventDAO;
import com.railtrack.system.model.CalendarEvent;
import com.railtrack.system.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet({"/planning", "/planning/api/events"})
public class PlanningServlet extends HttpServlet {

    private final CalendarEventDAO eventDAO = new CalendarEventDAO();
    private final Gson gson;

    public PlanningServlet() {
        this.gson = new GsonBuilder()
            .registerTypeAdapter(LocalDate.class, (JsonSerializer<LocalDate>) (src, typeOfSrc, context) -> new JsonPrimitive(src.format(DateTimeFormatter.ISO_LOCAL_DATE)))
            .registerTypeAdapter(LocalDate.class, (JsonDeserializer<LocalDate>) (json, typeOfT, context) -> LocalDate.parse(json.getAsString(), DateTimeFormatter.ISO_LOCAL_DATE))
            .registerTypeAdapter(LocalDateTime.class, (JsonSerializer<LocalDateTime>) (src, typeOfSrc, context) -> new JsonPrimitive(src.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)))
            .create();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        
        if ("/planning".equals(path)) {
            request.setAttribute("pageTitle", "Planning & Calendar");
            request.getRequestDispatcher("/views/common/planning.jsp").forward(request, response);
            return;
        }

        if ("/planning/api/events".equals(path)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try {
                List<CalendarEvent> events = eventDAO.findAll();
                String json = gson.toJson(events);
                response.getWriter().write(json);
            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Database error\"}");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userRole") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        String role = (String) session.getAttribute("userRole");
        if (!"COORDINATOR".equals(role)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        Integer userId = (Integer) session.getAttribute("userId");

        String path = request.getServletPath();
        if ("/planning/api/events".equals(path)) {
            response.setContentType("application/json");
            try {
                BufferedReader reader = request.getReader();
                CalendarEvent event = gson.fromJson(reader, CalendarEvent.class);
                event.setCreatedById(userId);
                
                eventDAO.insert(event);
                
                response.getWriter().write(gson.toJson(event));
            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Database error\"}");
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Invalid input\"}");
            }
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userRole") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        String role = (String) session.getAttribute("userRole");
        if (!"COORDINATOR".equals(role)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String path = request.getServletPath();
        if ("/planning/api/events".equals(path)) {
            String idParam = request.getParameter("id");
            if (idParam == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            try {
                int id = Integer.parseInt(idParam);
                eventDAO.delete(id);
                response.setStatus(HttpServletResponse.SC_OK);
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        }
    }
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userRole") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        String role = (String) session.getAttribute("userRole");
        if (!"COORDINATOR".equals(role)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String path = request.getServletPath();
        if ("/planning/api/events".equals(path)) {
            response.setContentType("application/json");
            try {
                BufferedReader reader = request.getReader();
                CalendarEvent event = gson.fromJson(reader, CalendarEvent.class);
                
                eventDAO.update(event);
                
                response.getWriter().write(gson.toJson(event));
            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Database error\"}");
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Invalid input\"}");
            }
        }
    }
}

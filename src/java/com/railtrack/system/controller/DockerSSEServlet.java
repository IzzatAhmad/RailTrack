/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.railtrack.system.controller;

import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.model.Project;
import com.railtrack.system.service.AuthService;
import com.railtrack.system.service.DockerService;
 
import javax.servlet.AsyncContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.SQLException;

/**
 *
 * @author izzat
 */
@WebServlet(urlPatterns = "/api/logs/stream/*", asyncSupported = true)
public class DockerSSEServlet extends HttpServlet {
 
    private final ProjectDAO  projectDAO  = new ProjectDAO();
    private final DockerService dockerService = new DockerService();
 
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        // Auth check
        if (!AuthService.isLoggedIn(req)) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
 
        int projectId;
        try {
            projectId = Integer.parseInt(req.getPathInfo().substring(1));
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
 
        // Verify project exists and container is running
        Project project;
        try {
            project = projectDAO.findById(projectId);
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }
 
        if (project == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
 
        // SSE headers
        resp.setContentType("text/event-stream");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Cache-Control", "no-cache");
        resp.setHeader("X-Accel-Buffering", "no"); // disable nginx buffering
        resp.flushBuffer();
 
        AsyncContext async = req.startAsync();
        async.setTimeout(0); // no timeout — keep alive until client disconnects
 
        PrintWriter writer = resp.getWriter();
 
        // Stream docker logs in background thread
        Process logProcess;
        try {
            logProcess = dockerService.streamLogs(projectId, line -> {
                try {
                    writer.write("data: " + escapeSSE(line) + "\n\n");
                    writer.flush();
                } catch (Exception ignored) {}
            });
        } catch (IOException e) {
            writer.write("data: [error] Could not connect to container logs\n\n");
            writer.flush();
            async.complete();
            return;
        }
 
        // Watch for client disconnect
        req.getAsyncContext().addListener(new javax.servlet.AsyncListener() {
            @Override public void onComplete(javax.servlet.AsyncEvent e) { logProcess.destroy(); }
            @Override public void onTimeout(javax.servlet.AsyncEvent e)  { logProcess.destroy(); }
            @Override public void onError(javax.servlet.AsyncEvent e)    { logProcess.destroy(); }
            @Override public void onStartAsync(javax.servlet.AsyncEvent e) {}
        });
 
        // Wait for log process to end (container stopped), then close SSE
        new Thread(() -> {
            try {
                logProcess.waitFor();
                writer.write("data: [container stopped]\n\n");
                writer.flush();
            } catch (InterruptedException ignored) {
                Thread.currentThread().interrupt();
            } finally {
                async.complete();
            }
        }, "sse-watcher-" + projectId).start();
    }
 
    /** Escapes newlines so SSE data field stays on one line. */
    private String escapeSSE(String line) {
        return line.replace("\r", "").replace("\n", " ");
    }
}
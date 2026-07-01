package com.railtrack.system.controller;

import com.railtrack.system.dao.LogbookDAO;
import com.railtrack.system.dao.LogbookDAO.LogbookImageUpload;
import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.dao.UserDAO;
import com.railtrack.system.model.LogbookEntry;
import com.railtrack.system.model.Project;
import com.railtrack.system.model.User;
import com.railtrack.system.service.AuthService;
import com.railtrack.system.service.NotificationService;
import com.railtrack.system.dao.SystemSettingsDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.Iterator;

@WebServlet("/student/logbook")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize       = 10 * 1024 * 1024,   // 10 MB per image
        maxRequestSize    = 35 * 1024 * 1024     // 35 MB total
)
public class StudentLogbookServlet extends HttpServlet {

    private final LogbookDAO          logbookDAO          = new LogbookDAO();
    private final ProjectDAO          projectDAO          = new ProjectDAO();
    private final UserDAO             userDAO             = new UserDAO();
    private final NotificationService notificationService = new NotificationService();
    private final SystemSettingsDAO   systemSettingsDAO   = new SystemSettingsDAO();

    // ── GET ───────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int studentId = AuthService.getSessionUserId(req);

        try {
            User student           = userDAO.findById(studentId);
            List<Project> projects = projectDAO.findByStudent(studentId);
            List<LogbookEntry> entries = logbookDAO.findByStudent(studentId);

            int projectId = 0;
            if (projects != null && !projects.isEmpty()) {
                projectId = projects.get(0).getId();
            }

            req.setAttribute("student",   student);
            req.setAttribute("projectId", projectId);
            req.setAttribute("entries",   entries);
            req.setAttribute("notif",     notificationService.getStudentCounts(studentId));

            String semesterStart = systemSettingsDAO.getSetting("semester_start_date", "");
            String semesterEnd = systemSettingsDAO.getSetting("semester_end_date", "");
            req.setAttribute("semester_start_date", semesterStart);
            req.setAttribute("semester_end_date", semesterEnd);

            req.getRequestDispatcher("/views/student/logbook.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Failed to load logbook page", e);
        }
    }

    // ── POST ──────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int    studentId  = AuthService.getSessionUserId(req);
        int    projectId  = Integer.parseInt(req.getParameter("projectId"));
        String dateStr    = req.getParameter("activityDate");
        String timeStr    = req.getParameter("activityTime");
        String type       = req.getParameter("activityType");
        String details    = req.getParameter("activityDetails");
        String problems   = req.getParameter("problems");
        String suggestions = req.getParameter("suggestions");

        if (dateStr == null || dateStr.trim().isEmpty() ||
            timeStr == null || timeStr.trim().isEmpty() ||
            type    == null || type.trim().isEmpty()    ||
            details == null || details.trim().isEmpty()) {

            req.setAttribute("formError",
                    "Date, Time, Activity Type, and Project Activity details are required.");
            doGet(req, resp);
            return;
        }

        try {
            // ── Validate date/time ───────────────────────────────────────────
            LocalDate activityDate = LocalDate.parse(dateStr);
            LocalTime activityTime = LocalTime.parse(timeStr);

            java.time.LocalDateTime activityDateTime =
                    java.time.LocalDateTime.of(activityDate, activityTime);
            if (activityDateTime.isAfter(java.time.LocalDateTime.now())) {
                throw new IllegalArgumentException(
                        "Activity date and time cannot be in the future.");
            }

            // ── Read uploaded images from request parts ───────────────────────
            List<LogbookImageUpload> imageBlobs = new ArrayList<>();

            String contentType = req.getContentType();
            if (contentType != null && contentType.startsWith("multipart/form-data")) {
                for (Part part : req.getParts()) {
                    if (!part.getName().startsWith("image")) continue;
                    if (part.getSize() == 0)               continue;

                    // Size check (10 MB per image)
                    if (part.getSize() > 10 * 1024 * 1024) {
                        throw new IllegalArgumentException(
                                "Each image size cannot exceed 10MB.");
                    }

                    // MIME type check
                    String mime = part.getContentType();
                    if (mime == null || !mime.startsWith("image/")) {
                        throw new IllegalArgumentException(
                                "Only image files (JPEG, PNG, GIF, etc.) can be uploaded.");
                    }

                    byte[] data;
                    String finalMime = "image/jpeg";
                    String fileName = java.nio.file.Paths
                            .get(part.getSubmittedFileName())
                            .getFileName().toString();
                    
                    if (fileName.lastIndexOf(".") > 0) {
                        fileName = fileName.substring(0, fileName.lastIndexOf(".")) + ".jpg";
                    } else {
                        fileName += ".jpg";
                    }

                    try (InputStream in = part.getInputStream()) {
                        data = compressAndResizeImage(in);
                    }

                    imageBlobs.add(new LogbookImageUpload(fileName, finalMime, data));
                }
            }

            if (imageBlobs.size() > 3) {
                throw new IllegalArgumentException(
                        "You can upload a maximum of 3 images per log entry.");
            }

            // ── Build and save entry ─────────────────────────────────────────
            LogbookEntry entry = new LogbookEntry();
            entry.setStudentId(studentId);
            entry.setProjectId(projectId);
            entry.setActivityDate(activityDate);
            entry.setActivityTime(activityTime);
            entry.setActivityType(type);
            entry.setActivityDetails(details.trim());
            entry.setProblems(problems   != null ? problems.trim()    : null);
            entry.setSuggestions(suggestions != null ? suggestions.trim() : null);
            entry.setVerified(false);
            entry.setImageBlobs(imageBlobs);   // pass blobs to DAO

            logbookDAO.save(entry);

            resp.sendRedirect(req.getContextPath() + "/student/logbook?success=saved");

        } catch (IllegalArgumentException e) {
            req.setAttribute("formError", e.getMessage());
            doGet(req, resp);
        } catch (Exception e) {
            req.setAttribute("formError", "Failed to save logbook entry: " + e.getMessage());
            doGet(req, resp);
        }
    }

    private byte[] compressAndResizeImage(InputStream in) throws IOException {
        BufferedImage originalImage = ImageIO.read(in);
        if (originalImage == null) {
            throw new IllegalArgumentException("Invalid or unsupported image format.");
        }
        
        // Resize image if larger than max dimensions (e.g., 1024x1024)
        int maxWidth = 1024;
        int maxHeight = 1024;
        int width = originalImage.getWidth();
        int height = originalImage.getHeight();
        
        if (width > maxWidth || height > maxHeight) {
            float ratio = Math.min((float) maxWidth / width, (float) maxHeight / height);
            width = Math.round(width * ratio);
            height = Math.round(height * ratio);
        }
        
        // Create new image (always use TYPE_INT_RGB to drop alpha channel for JPEG)
        BufferedImage resizedImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = resizedImage.createGraphics();
        
        // Fill background with white (useful if original was PNG with transparency)
        g.setColor(java.awt.Color.WHITE);
        g.fillRect(0, 0, width, height);
        
        g.setRenderingHint(java.awt.RenderingHints.KEY_INTERPOLATION, java.awt.RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g.drawImage(originalImage, 0, 0, width, height, null);
        g.dispose();
        
        // Compress as JPEG
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName("jpeg");
        if (!writers.hasNext()) throw new IllegalStateException("No JPEG writers found");
        ImageWriter writer = writers.next();
        
        try (ImageOutputStream ios = ImageIO.createImageOutputStream(bos)) {
            writer.setOutput(ios);
            ImageWriteParam param = writer.getDefaultWriteParam();
            if (param.canWriteCompressed()) {
                param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
                param.setCompressionQuality(0.75f); // 75% quality is usually < 200KB for 1024x1024
            }
            writer.write(null, new javax.imageio.IIOImage(resizedImage, null, null), param);
        } finally {
            writer.dispose();
        }
        
        return bos.toByteArray();
    }
}

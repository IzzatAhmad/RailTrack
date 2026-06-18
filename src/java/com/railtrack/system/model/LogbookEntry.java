package com.railtrack.system.model;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.util.List;

import com.railtrack.system.dao.LogbookDAO.LogbookImageUpload;

public class LogbookEntry {

    private int id;
    private int studentId;
    private int projectId;
    private LocalDate activityDate;
    private LocalTime activityTime;
    private String activityType;
    private String activityDetails;
    private String problems;
    private String suggestions;
    private boolean verified;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /** Images attached to this entry (metadata only — no raw bytes). */
    private List<LogbookImage> images;

    /**
     * Transient — only populated during an upload POST, never loaded from DB.
     * Carries raw bytes from the servlet to the DAO's save() method.
     */
    private List<LogbookImageUpload> imageBlobs;

    public LogbookEntry() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getProjectId() { return projectId; }
    public void setProjectId(int projectId) { this.projectId = projectId; }

    public LocalDate getActivityDate() { return activityDate; }
    public void setActivityDate(LocalDate activityDate) { this.activityDate = activityDate; }

    public LocalTime getActivityTime() { return activityTime; }
    public void setActivityTime(LocalTime activityTime) { this.activityTime = activityTime; }

    public String getActivityType() { return activityType; }
    public void setActivityType(String activityType) { this.activityType = activityType; }

    public String getActivityDetails() { return activityDetails; }
    public void setActivityDetails(String activityDetails) { this.activityDetails = activityDetails; }

    public String getProblems() { return problems; }
    public void setProblems(String problems) { this.problems = problems; }

    public String getSuggestions() { return suggestions; }
    public void setSuggestions(String suggestions) { this.suggestions = suggestions; }

    public boolean isVerified() { return verified; }
    public void setVerified(boolean verified) { this.verified = verified; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public List<LogbookImage> getImages() { return images; }
    public void setImages(List<LogbookImage> images) { this.images = images; }

    public List<LogbookImageUpload> getImageBlobs() { return imageBlobs; }
    public void setImageBlobs(List<LogbookImageUpload> imageBlobs) { this.imageBlobs = imageBlobs; }
}


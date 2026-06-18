/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.model;

import java.time.LocalDateTime;

/**
 *
 * @author izzat
 */
public class Project {
 
    public enum Status {
        PENDING,        // submitted, awaiting supervisor assignment
        ACTIVE,         // supervisor assigned, work in progress
        UNDER_REVIEW,   // milestone submitted, awaiting supervisor review
        COMPLETED,      // all milestones graded, project closed
        REJECTED        // rejected by coordinator or supervisor
    }
 
    // ── Identity ──────────────────────────────────────────────────────────────
    private int    id;
    private String title;
    private String description;
 
    // ── Ownership ─────────────────────────────────────────────────────────────
    private int    studentId;
    private String studentName;         // denormalised for display
    private String studentUsername;     // denormalised for matric display
    private String studentDepartment;   // denormalised for department display
    private Double studentCgpa;
    private int    supervisorId;        // 0 = unassigned
    private String supervisorName;      // denormalised for display
 
    // ── Repository & Docker ───────────────────────────────────────────────────
    private String repoUrl;
    private String branch;              // default: "main"
    private String imageTag;            // docker image tag
    private String dockerStatus;        // running / stopped / none / error
    private int    containerPort;       // mapped host port
    private String containerId;         // Docker container ID (short)
    private String buildLog;
    private String errorMessage;
    private int    runningLimitSeconds; // daily container runtime limit in seconds
 
    // ── Academic ──────────────────────────────────────────────────────────────
    private String semester;            // e.g. "2024/2025-1"
    private Status status;
    private int    currentMilestoneNo;  // which milestone is active (1-based)
    private Double overallGrade;        // 0.0 – 100.0, null until finalised
    private Double observationMark;
    private Double continuousMark;
    private String chapterProgress;

    // ── Timestamps ────────────────────────────────────────────────────────────
    private LocalDateTime submittedAt;
    private LocalDateTime updatedAt;
 
    public Project() {
        this.branch             = "main";
        this.status             = Status.PENDING;
        this.dockerStatus       = "none";
        this.currentMilestoneNo = 1;
        this.runningLimitSeconds = 14400; // default to 4 hours
    }
 
    // ── Docker helpers ────────────────────────────────────────────────────────
 
    public boolean isRunning() {
        return "running".equalsIgnoreCase(dockerStatus);
    }
 
    public boolean hasSupervisor() {
        return supervisorId > 0;
    }
 
    /**
     * Returns a URL to open the running container in the browser.
     * Returns null if not running or port not set.
     */
    public String getPreviewUrl() {
        if (!isRunning() || containerPort <= 0) return null;
        return "http://localhost:" + containerPort;
    }
 
    // ── Getters & Setters ─────────────────────────────────────────────────────
 
    public int    getId()          { return id; }
    public void   setId(int id)    { this.id = id; }
 
    public String getTitle()                { return title; }
    public void   setTitle(String title)    { this.title = title; }
 
    public String getDescription()                    { return description; }
    public void   setDescription(String description)  { this.description = description; }
 
    public int    getStudentId()              { return studentId; }
    public void   setStudentId(int studentId) { this.studentId = studentId; }
 
    public String getStudentName()                    { return studentName; }
    public void   setStudentName(String studentName)  { this.studentName = studentName; }

    public String getStudentUsername()                        { return studentUsername; }
    public void   setStudentUsername(String studentUsername)  { this.studentUsername = studentUsername; }

    public String getStudentDepartment()                          { return studentDepartment; }
    public void   setStudentDepartment(String studentDepartment)  { this.studentDepartment = studentDepartment; }

    public Double getStudentCgpa()                    { return studentCgpa; }
    public void   setStudentCgpa(Double studentCgpa)  { this.studentCgpa = studentCgpa; }
 
    public int    getSupervisorId()                   { return supervisorId; }
    public void   setSupervisorId(int supervisorId)   { this.supervisorId = supervisorId; }
 
    public String getSupervisorName()                       { return supervisorName; }
    public void   setSupervisorName(String supervisorName)  { this.supervisorName = supervisorName; }
 
    public String getRepoUrl()                { return repoUrl; }
    public void   setRepoUrl(String repoUrl)  { this.repoUrl = repoUrl; }
 
    public String getBranch()                 { return branch; }
    public void   setBranch(String branch)    { this.branch = branch; }
 
    public String getImageTag()               { return imageTag; }
    public void   setImageTag(String imageTag){ this.imageTag = imageTag; }
 
    public String getDockerStatus()                     { return dockerStatus; }
    public void   setDockerStatus(String dockerStatus)  { this.dockerStatus = dockerStatus; }
 
    public int    getContainerPort()                      { return containerPort; }
    public void   setContainerPort(int containerPort)     { this.containerPort = containerPort; }
 
    public String getContainerId()                    { return containerId; }
    public void   setContainerId(String containerId)  { this.containerId = containerId; }
 
    public String getBuildLog()                 { return buildLog; }
    public void   setBuildLog(String buildLog)  { this.buildLog = buildLog; }
 
    public String getErrorMessage()                     { return errorMessage; }
    public void   setErrorMessage(String errorMessage)  { this.errorMessage = errorMessage; }
 
    public String getSemester()                   { return semester; }
    public void   setSemester(String semester)    { this.semester = semester; }
 
    public Status getStatus()                 { return status; }
    public void   setStatus(Status status)    { this.status = status; }
 
    public int    getCurrentMilestoneNo()                         { return currentMilestoneNo; }
    public void   setCurrentMilestoneNo(int currentMilestoneNo)   { this.currentMilestoneNo = currentMilestoneNo; }
 
    public Double getOverallGrade()                   { return overallGrade; }
    public void   setOverallGrade(Double overallGrade){ this.overallGrade = overallGrade; }
 
    public Double getObservationMark() { return observationMark; }
    public void setObservationMark(Double observationMark) { this.observationMark = observationMark; }

    public Double getContinuousMark() { return continuousMark; }
    public void setContinuousMark(Double continuousMark) { this.continuousMark = continuousMark; }

    public LocalDateTime getSubmittedAt()                         { return submittedAt; }
    public void          setSubmittedAt(LocalDateTime submittedAt){ this.submittedAt = submittedAt; }
 
    public LocalDateTime getUpdatedAt()                         { return updatedAt; }
    public void          setUpdatedAt(LocalDateTime updatedAt)  { this.updatedAt = updatedAt; }
 
    public int    getRunningLimitSeconds()                               { return runningLimitSeconds; }
    public void   setRunningLimitSeconds(int runningLimitSeconds)       { this.runningLimitSeconds = runningLimitSeconds; }

    public String getChapterProgress() { return chapterProgress; }
    public void setChapterProgress(String chapterProgress) { this.chapterProgress = chapterProgress; }

    public int[] getChapterProgressArray() {
        int[] arr = new int[]{0,0,0,0,0,0,0,0};
        if (this.chapterProgress != null && !this.chapterProgress.isEmpty()) {
            String[] parts = this.chapterProgress.split(",");
            for (int i = 0; i < Math.min(parts.length, 8); i++) {
                try {
                    arr[i] = Integer.parseInt(parts[i].trim());
                } catch (NumberFormatException e) {
                    arr[i] = 0;
                }
            }
        }
        return arr;
    }

    @Override
    public String toString() {
        return "Project{id=" + id + ", title='" + title + "', status=" + status + "}";
    }
}
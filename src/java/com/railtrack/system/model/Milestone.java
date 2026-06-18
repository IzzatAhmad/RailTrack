/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 *
 * @author izzat
 */
public class Milestone {
 
    public enum MilestoneStatus {
        NOT_STARTED,    // not yet worked on
        IN_PROGRESS,    // student is working on it
        SUBMITTED,      // student submitted, awaiting supervisor review
        APPROVED,       // supervisor approved, grade recorded
        REJECTED        // supervisor rejected, student must resubmit
    }
 
    // ── Identity ──────────────────────────────────────────────────────────────
    private int             id;
    private int             projectId;
    private String          projectTitle;   // denormalised for display
    private int             milestoneNo;    // ordering: 1, 2, 3 …
    private String          title;
    private String          description;
 
    // ── Scheduling ────────────────────────────────────────────────────────────
    private LocalDate       dueDate;
    private MilestoneStatus status;
 
    // ── Grading ───────────────────────────────────────────────────────────────
    private double          weight;         // % contribution to overall grade (0–100)
    private Double          grade;          // 0–100, null until graded
    private String          supervisorNote; // grading feedback
 
    // ── Submission ────────────────────────────────────────────────────────────
    private String          submissionNote; // student's submission comment
    private LocalDateTime   submittedAt;
    private LocalDateTime   reviewedAt;
    private LocalDateTime   createdAt;
    private String          pitaStage;      // PITA1, PITA2, or null
 
    public Milestone() {
        this.status = MilestoneStatus.NOT_STARTED;
    }

    public String getPitaStage() {
        return pitaStage;
    }

    public void setPitaStage(String pitaStage) {
        this.pitaStage = pitaStage;
    }
 
    public Milestone(int projectId, int milestoneNo, String title, LocalDate dueDate, double weight) {
        this.projectId    = projectId;
        this.milestoneNo  = milestoneNo;
        this.title        = title;
        this.dueDate      = dueDate;
        this.weight       = weight;
        this.status       = MilestoneStatus.NOT_STARTED;
    }
 
    // ── Business helpers ──────────────────────────────────────────────────────
 
    /** True if due date has passed and milestone is not yet approved. */
    public boolean isOverdue() {
        if (dueDate == null) return false;
        if (status == MilestoneStatus.APPROVED) return false;
        return LocalDate.now().isAfter(dueDate);
    }
 
    /** Returns the weighted score contribution, or 0 if not yet graded. */
    public double getWeightedScore() {
        if (grade == null) return 0.0;
        return (grade / 100.0) * weight;
    }
 
    public boolean isPendingReview() {
        return status == MilestoneStatus.SUBMITTED;
    }
 
    public boolean isGraded() {
        return status == MilestoneStatus.APPROVED && grade != null;
    }
 
    // ── Getters & Setters ─────────────────────────────────────────────────────
 
    public int    getId()          { return id; }
    public void   setId(int id)    { this.id = id; }
 
    public int    getProjectId()              { return projectId; }
    public void   setProjectId(int projectId) { this.projectId = projectId; }
 
    public String getProjectTitle()                   { return projectTitle; }
    public void   setProjectTitle(String projectTitle){ this.projectTitle = projectTitle; }
 
    public int    getMilestoneNo()                    { return milestoneNo; }
    public void   setMilestoneNo(int milestoneNo)     { this.milestoneNo = milestoneNo; }
 
    public String getTitle()                { return title; }
    public void   setTitle(String title)    { this.title = title; }
 
    public String getDescription()                    { return description; }
    public void   setDescription(String description)  { this.description = description; }
 
    public LocalDate getDueDate()                 { return dueDate; }
    public void      setDueDate(LocalDate dueDate){ this.dueDate = dueDate; }
 
    public MilestoneStatus getStatus()                       { return status; }
    public void            setStatus(MilestoneStatus status) { this.status = status; }
 
    public double getWeight()                { return weight; }
    public void   setWeight(double weight)   { this.weight = weight; }
 
    public Double getGrade()               { return grade; }
    public void   setGrade(Double grade)   { this.grade = grade; }
 
    public String getSupervisorNote()                       { return supervisorNote; }
    public void   setSupervisorNote(String supervisorNote)  { this.supervisorNote = supervisorNote; }
 
    public String getSubmissionNote()                       { return submissionNote; }
    public void   setSubmissionNote(String submissionNote)  { this.submissionNote = submissionNote; }
 
    public LocalDateTime getSubmittedAt()                         { return submittedAt; }
    public void          setSubmittedAt(LocalDateTime submittedAt){ this.submittedAt = submittedAt; }
 
    public LocalDateTime getReviewedAt()                          { return reviewedAt; }
    public void          setReviewedAt(LocalDateTime reviewedAt)  { this.reviewedAt = reviewedAt; }
 
    public LocalDateTime getCreatedAt()                         { return createdAt; }
    public void          setCreatedAt(LocalDateTime createdAt)  { this.createdAt = createdAt; }
 
    @Override
    public String toString() {
        return "Milestone{id=" + id + ", projectId=" + projectId
                + ", no=" + milestoneNo + ", title='" + title + "', status=" + status + "}";
    }
}
 

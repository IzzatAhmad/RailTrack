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
public class Feedback {
 
    public enum FeedbackType {
        GENERAL,        // general project feedback
        MILESTONE,      // tied to a specific milestone
        CODE_REVIEW,    // code/repo quality
        FINAL_EVAL      // end-of-project evaluation
    }
 
    // ── Identity ──────────────────────────────────────────────────────────────
    private int          id;
    private int          projectId;
    private String       projectTitle;   // denormalised
    private Integer      milestoneId;    // nullable — only set for MILESTONE type
    private int          authorId;       // supervisor or coordinator user id
    private String       authorName;     // denormalised
 
    // ── Content ───────────────────────────────────────────────────────────────
    private FeedbackType type;
    private String       content;
 
    // ── Read tracking ─────────────────────────────────────────────────────────
    private boolean      readByStudent;
    private LocalDateTime createdAt;
    private LocalDateTime readAt;
 
    public Feedback() {
        this.type           = FeedbackType.GENERAL;
        this.readByStudent  = false;
    }
 
    public Feedback(int projectId, int authorId, FeedbackType type, String content) {
        this.projectId     = projectId;
        this.authorId      = authorId;
        this.type          = type;
        this.content       = content;
        this.readByStudent = false;
    }
 
    // ── Helpers ───────────────────────────────────────────────────────────────
 
    public boolean isMilestoneFeedback() {
        return type == FeedbackType.MILESTONE && milestoneId != null;
    }
 
    public boolean isUnread() {
        return !readByStudent;
    }
 
    // ── Getters & Setters ─────────────────────────────────────────────────────
 
    public int     getId()          { return id; }
    public void    setId(int id)    { this.id = id; }
 
    public int     getProjectId()               { return projectId; }
    public void    setProjectId(int projectId)  { this.projectId = projectId; }
 
    public String  getProjectTitle()                    { return projectTitle; }
    public void    setProjectTitle(String projectTitle) { this.projectTitle = projectTitle; }
 
    public Integer getMilestoneId()                   { return milestoneId; }
    public void    setMilestoneId(Integer milestoneId){ this.milestoneId = milestoneId; }
 
    public int     getAuthorId()              { return authorId; }
    public void    setAuthorId(int authorId)  { this.authorId = authorId; }
 
    public String  getAuthorName()                    { return authorName; }
    public void    setAuthorName(String authorName)   { this.authorName = authorName; }
 
    public FeedbackType getType()                    { return type; }
    public void         setType(FeedbackType type)   { this.type = type; }
 
    public String  getContent()                 { return content; }
    public void    setContent(String content)   { this.content = content; }
 
    public boolean isReadByStudent()                        { return readByStudent; }
    public void    setReadByStudent(boolean readByStudent)  { this.readByStudent = readByStudent; }
 
    public LocalDateTime getCreatedAt()                         { return createdAt; }
    public void          setCreatedAt(LocalDateTime createdAt)  { this.createdAt = createdAt; }
 
    public LocalDateTime getReadAt()                      { return readAt; }
    public void          setReadAt(LocalDateTime readAt)  { this.readAt = readAt; }
 
    @Override
    public String toString() {
        return "Feedback{id=" + id + ", projectId=" + projectId
                + ", type=" + type + ", author=" + authorName + "}";
    }
}

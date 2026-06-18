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
public class DeploymentLog {
 
    public enum Action {
        BUILD, START, STOP, REBUILD, REMOVE
    }
 
    private int           id;
    private int           projectId;
    private int           performedById;      // user who triggered the action
    private String        performedByName;    // denormalised
    private Action        action;
    private String        outcome;            // "success" | "failed"
    private String        detail;             // optional extra info / error snippet
    private LocalDateTime performedAt;
    private String        projectTitle;
 
    public DeploymentLog() {}
 
    public DeploymentLog(int projectId, int performedById, Action action, String outcome) {
        this.projectId      = projectId;
        this.performedById  = performedById;
        this.action         = action;
        this.outcome        = outcome;
        this.performedAt    = LocalDateTime.now();
    }
 
    // ── Helpers ───────────────────────────────────────────────────────────────
 
    public boolean isSuccess() { return "success".equalsIgnoreCase(outcome); }
 
    // ── Getters & Setters ─────────────────────────────────────────────────────
 
    public int    getId()          { return id; }
    public void   setId(int id)    { this.id = id; }
 
    public int    getProjectId()              { return projectId; }
    public void   setProjectId(int projectId) { this.projectId = projectId; }
 
    public int    getPerformedById()                    { return performedById; }
    public void   setPerformedById(int performedById)   { this.performedById = performedById; }
 
    public String getPerformedByName()                          { return performedByName; }
    public void   setPerformedByName(String performedByName)    { this.performedByName = performedByName; }
 
    public String getProjectTitle()                      { return projectTitle; }
    public void   setProjectTitle(String projectTitle)   { this.projectTitle = projectTitle; }
 
    public Action getAction()                { return action; }
    public void   setAction(Action action)   { this.action = action; }
 
    public String getOutcome()                  { return outcome; }
    public void   setOutcome(String outcome)    { this.outcome = outcome; }
 
    public String getDetail()                { return detail; }
    public void   setDetail(String detail)   { this.detail = detail; }
 
    public LocalDateTime getPerformedAt()                         { return performedAt; }
    public void          setPerformedAt(LocalDateTime performedAt){ this.performedAt = performedAt; }
 
    @Override
    public String toString() {
        return "DeploymentLog{projectId=" + projectId + ", action=" + action
                + ", outcome=" + outcome + ", at=" + performedAt + "}";
    }
}

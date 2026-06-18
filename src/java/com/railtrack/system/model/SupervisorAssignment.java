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
public class SupervisorAssignment {
 
    private int           id;
    private int           projectId;
    private String        projectTitle;       // denormalised
    private int           supervisorId;
    private String        supervisorName;     // denormalised
    private int           assignedById;       // coordinator who made the assignment
    private String        assignedByName;     // denormalised
    private String        note;               // optional coordinator note
    private LocalDateTime assignedAt;
 
    public SupervisorAssignment() {}
 
    public SupervisorAssignment(int projectId, int supervisorId, int assignedById) {
        this.projectId    = projectId;
        this.supervisorId = supervisorId;
        this.assignedById = assignedById;
        this.assignedAt   = LocalDateTime.now();
    }
 
    // ── Getters & Setters ─────────────────────────────────────────────────────
 
    public int    getId()          { return id; }
    public void   setId(int id)    { this.id = id; }
 
    public int    getProjectId()              { return projectId; }
    public void   setProjectId(int projectId) { this.projectId = projectId; }
 
    public String getProjectTitle()                   { return projectTitle; }
    public void   setProjectTitle(String projectTitle){ this.projectTitle = projectTitle; }
 
    public int    getSupervisorId()                   { return supervisorId; }
    public void   setSupervisorId(int supervisorId)   { this.supervisorId = supervisorId; }
 
    public String getSupervisorName()                       { return supervisorName; }
    public void   setSupervisorName(String supervisorName)  { this.supervisorName = supervisorName; }
 
    public int    getAssignedById()                   { return assignedById; }
    public void   setAssignedById(int assignedById)   { this.assignedById = assignedById; }
 
    public String getAssignedByName()                       { return assignedByName; }
    public void   setAssignedByName(String assignedByName)  { this.assignedByName = assignedByName; }
 
    public String getNote()               { return note; }
    public void   setNote(String note)    { this.note = note; }
 
    public LocalDateTime getAssignedAt()                        { return assignedAt; }
    public void          setAssignedAt(LocalDateTime assignedAt){ this.assignedAt = assignedAt; }
 
    @Override
    public String toString() {
        return "SupervisorAssignment{id=" + id + ", projectId=" + projectId
                + ", supervisorId=" + supervisorId + ", assignedAt=" + assignedAt + "}";
    }
}
 

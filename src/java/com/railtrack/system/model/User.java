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
public class User {

    public enum Role {
        STUDENT, SUPERVISOR, COORDINATOR
    }

    private int id;
    private String username;
    private String passwordHash;
    private String fullName;
    private String email;
    private String phone;
    private String department;
    private Double cgpa;
    private Integer supervisorId;
    private String supervisorName;
    private Role role;
    private boolean active;
    private LocalDateTime createdAt;
    private LocalDateTime lastLogin;
    private boolean emailNotifEnabled = true;

    public User() {
    }

    public User(int id, String username, String fullName, String email, Role role) {
        this.id = id;
        this.username = username;
        this.fullName = fullName;
        this.email = email;
        this.role = role;
        this.active = true;
    }

    // ── Role helpers ──────────────────────────────────────────────────────────
    public boolean isStudent() {
        return role == Role.STUDENT;
    }

    public boolean isSupervisor() {
        return role == Role.SUPERVISOR;
    }

    public boolean isCoordinator() {
        return role == Role.COORDINATOR;
    }

    public String getRoleLabel() {
        if (role == null) {
            return "Unknown";
        }
        switch (role) {
            case STUDENT:
                return "Student";
            case SUPERVISOR:
                return "Supervisor";
            case COORDINATOR:
                return "Coordinator";
            default:
                return role.name();
        }
    }

    /**
     * Display-safe name: fullName if set, otherwise username.
     */
    public String getDisplayName() {
        return (fullName != null && !fullName.trim().isEmpty())
                ? fullName.trim()
                : (username != null ? username.trim() : "");
    }
    // ── Getters & Setters ─────────────────────────────────────────────────────

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public Double getCgpa() {
        return cgpa;
    }

    public void setCgpa(Double cgpa) {
        this.cgpa = cgpa;
    }

    public Integer getSupervisorId() {
        return supervisorId;
    }

    public void setSupervisorId(Integer supervisorId) {
        this.supervisorId = supervisorId;
    }

    public String getSupervisorName() {
        return supervisorName;
    }

    public void setSupervisorName(String supervisorName) {
        this.supervisorName = supervisorName;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getLastLogin() {
        return lastLogin;
    }

    public void setLastLogin(LocalDateTime lastLogin) {
        this.lastLogin = lastLogin;
    }

    public boolean isEmailNotifEnabled() {
        return emailNotifEnabled;
    }

    public void setEmailNotifEnabled(boolean emailNotifEnabled) {
        this.emailNotifEnabled = emailNotifEnabled;
    }

    @Override
    public String toString() {
        return "User{id=" + id + ", username='" + username + "', role=" + role + "}";
    }
}

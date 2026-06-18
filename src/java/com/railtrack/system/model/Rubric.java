package com.railtrack.system.model;

import java.sql.Timestamp;

public class Rubric {
    private int id;
    private String section;
    private String title;
    private String content;
    private int sortOrder;
    private boolean enabled;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Rubric() {}

    public Rubric(int id, String section, String title, String content, int sortOrder, boolean enabled) {
        this.id = id;
        this.section = section;
        this.title = title;
        this.content = content;
        this.sortOrder = sortOrder;
        this.enabled = enabled;
    }

    public Rubric(int id, String section, String title, String content, int sortOrder, boolean enabled, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.section = section;
        this.title = title;
        this.content = content;
        this.sortOrder = sortOrder;
        this.enabled = enabled;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getSection() { return section; }
    public void setSection(String section) { this.section = section; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }
    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}

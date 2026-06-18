package com.railtrack.system.model;

public class MaterialLink {
    private int id;
    private String section;
    private String title;
    private String url;
    private int sortOrder;
    private boolean enabled;

    public MaterialLink() {}

    public MaterialLink(int id, String section, String title, String url, int sortOrder, boolean enabled) {
        this.id = id;
        this.section = section;
        this.title = title;
        this.url = url;
        this.sortOrder = sortOrder;
        this.enabled = enabled;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getSection() { return section; }
    public void setSection(String section) { this.section = section; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }
    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
}

package com.railtrack.system.model;

import java.time.LocalDateTime;

/**
 * Represents a single image attached to a logbook entry.
 * The actual binary data (file_data) is NOT held in this model —
 * it is fetched on demand by LogbookDAO.getImageData() to avoid
 * loading large BLOBs when listing logbook entries.
 */
public class LogbookImage {

    private int id;
    private int logbookId;
    private String fileName;
    private String contentType;
    private int fileSize;
    private LocalDateTime createdAt;

    public LogbookImage() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getLogbookId() { return logbookId; }
    public void setLogbookId(int logbookId) { this.logbookId = logbookId; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }

    public int getFileSize() { return fileSize; }
    public void setFileSize(int fileSize) { this.fileSize = fileSize; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}

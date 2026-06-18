package com.railtrack.system.model;

import java.time.LocalDateTime;

public class StudentDocument {
    private int id;
    private int studentId;
    private int documentTypeId;
    private String fileName;
    private String contentType;
    private int fileSize;
    private LocalDateTime uploadedAt;

    // Join fields for display convenience
    private String studentName;
    private String projectTitle;
    private String documentTypeName;

    public StudentDocument() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getDocumentTypeId() { return documentTypeId; }
    public void setDocumentTypeId(int documentTypeId) { this.documentTypeId = documentTypeId; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }

    public int getFileSize() { return fileSize; }
    public void setFileSize(int fileSize) { this.fileSize = fileSize; }

    public LocalDateTime getUploadedAt() { return uploadedAt; }
    public void setUploadedAt(LocalDateTime uploadedAt) { this.uploadedAt = uploadedAt; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getProjectTitle() { return projectTitle; }
    public void setProjectTitle(String projectTitle) { this.projectTitle = projectTitle; }

    public String getDocumentTypeName() { return documentTypeName; }
    public void setDocumentTypeName(String documentTypeName) { this.documentTypeName = documentTypeName; }
}

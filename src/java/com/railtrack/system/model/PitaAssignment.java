package com.railtrack.system.model;

import java.time.LocalDateTime;

public class PitaAssignment {
    private int id;
    private int projectId;
    private String projectTitle;
    private String studentName;
    private int evaluatorId;
    private String evaluatorName;
    private String stage;
    private Double grade;
    private String feedback;
    private LocalDateTime evaluatedAt;

    public PitaAssignment() {}

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getProjectId() {
        return projectId;
    }

    public void setProjectId(int projectId) {
        this.projectId = projectId;
    }

    public String getProjectTitle() {
        return projectTitle;
    }

    public void setProjectTitle(String projectTitle) {
        this.projectTitle = projectTitle;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public int getEvaluatorId() {
        return evaluatorId;
    }

    public void setEvaluatorId(int evaluatorId) {
        this.evaluatorId = evaluatorId;
    }

    public String getStage() {
        return stage;
    }

    public void setStage(String stage) {
        this.stage = stage;
    }

    public Double getGrade() {
        return grade;
    }

    public void setGrade(Double grade) {
        this.grade = grade;
    }

    public String getFeedback() {
        return feedback;
    }

    public void setFeedback(String feedback) {
        this.feedback = feedback;
    }

    public LocalDateTime getEvaluatedAt() {
        return evaluatedAt;
    }

    public void setEvaluatedAt(LocalDateTime evaluatedAt) {
        this.evaluatedAt = evaluatedAt;
    }

    public String getEvaluatorName() {
        return evaluatorName;
    }

    public void setEvaluatorName(String evaluatorName) {
        this.evaluatorName = evaluatorName;
    }

    @Override
    public String toString() {
        return "PitaAssignment{" +
                "id=" + id +
                ", projectId=" + projectId +
                ", projectTitle='" + projectTitle + '\'' +
                ", studentName='" + studentName + '\'' +
                ", evaluatorId=" + evaluatorId +
                ", stage='" + stage + '\'' +
                ", grade=" + grade +
                ", evaluatedAt=" + evaluatedAt +
                '}';
    }
}

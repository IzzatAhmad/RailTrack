/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.service;

import com.railtrack.system.dao.FeedbackDAO;
import com.railtrack.system.dao.MilestoneDAO;
import com.railtrack.system.dao.ProjectDAO;
import com.railtrack.system.model.Feedback;
import com.railtrack.system.model.Milestone;
import com.railtrack.system.model.Project;
 
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
 

/**
 *
 * @author izzat
 */
public class NotificationService {
 
    private final FeedbackDAO  feedbackDAO  = new FeedbackDAO();
    private final MilestoneDAO milestoneDAO = new MilestoneDAO();
    private final ProjectDAO   projectDAO   = new ProjectDAO();
 
    // ── Student notifications ─────────────────────────────────────────────────
 
    /**
     * Returns badge counts for a student's dashboard.
     *
     * Keys:
     *  unreadFeedback   - feedback items not yet read
     *  overdueCount     - milestones past their due date
     *  rejectedCount    - milestones rejected by supervisor
     */
    public Map<String, Long> getStudentCounts(int studentId) throws SQLException {
    Map<String, Long> map = new HashMap<>();

    // Unread feedback count
    long unread = feedbackDAO.findUnreadByStudent(studentId).size();
    map.put("unreadFeedback", unread);

    // Count overdue and rejected milestones
    long overdue  = 0;
    long rejected = 0;

    for (Project p : projectDAO.findByStudent(studentId)) {
        for (Milestone m : milestoneDAO.findByProject(p.getId())) {
            if (m.isOverdue()) overdue++;
            if (m.getStatus() == com.railtrack.system.model.Milestone.MilestoneStatus.REJECTED) rejected++;
        }
    }

    map.put("overdueCount",  overdue);
    map.put("rejectedCount", rejected);
    map.put("total", unread + overdue + rejected);

    return map;
}
 
    // ── Supervisor notifications ──────────────────────────────────────────────
 
    /**
     * Returns badge counts for a supervisor's dashboard.
     *
     * Keys:
     *  pendingReviews  - milestones awaiting supervisor review
     *  totalProjects   - number of assigned projects
     *  runningCount    - containers currently running
     */
    public Map<String, Long> getSupervisorCounts(int supervisorId) throws SQLException {
        Map<String, Long> map = new HashMap<>();
 
        long pending  = milestoneDAO.countPendingBySupervisor(supervisorId);
        long total    = projectDAO.countBySupervisor(supervisorId);
        long running  = projectDAO.findBySupervisor(supervisorId)
                .stream().filter(Project::isRunning).count();
 
        map.put("pendingReviews", pending);
        map.put("totalProjects",  total);
        map.put("runningCount",   running);
        map.put("total", pending);
 
        return map;
    }
 
    // ── Coordinator notifications ─────────────────────────────────────────────
 
    /**
     * Returns badge counts for the coordinator dashboard.
     *
     * Keys:
     *  pendingProjects   - projects awaiting supervisor assignment
     *  underReviewCount  - projects in UNDER_REVIEW state
     *  totalProjects     - all projects in system
     */
    public Map<String, Long> getCoordinatorCounts() throws SQLException {
        Map<String, Long> map = new HashMap<>();
 
        long pending     = projectDAO.countByStatus(Project.Status.PENDING);
        long underReview = projectDAO.countByStatus(Project.Status.UNDER_REVIEW);
        long total       = projectDAO.findAll().size();
 
        map.put("pendingProjects",  pending);
        map.put("underReviewCount", underReview);
        map.put("totalProjects",    total);
        map.put("total", pending + underReview);
 
        return map;
    }
 
    // ── Helpers ───────────────────────────────────────────────────────────────
 
    /**
     * Marks all feedback on a project as read when the student opens the project page.
     */
    public void markProjectFeedbackRead(int projectId) throws SQLException {
        feedbackDAO.markAllReadForProject(projectId);
    }
}
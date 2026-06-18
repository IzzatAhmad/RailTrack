/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.service;
 
import com.railtrack.system.dao.*;
import com.railtrack.system.model.*;
import com.railtrack.system.util.ValidationUtil;
 
import java.sql.SQLException;
import java.util.List;

/**
 *
 * @author izzat
 */
public class ProjectService {
 
    private final ProjectDAO              projectDAO              = new ProjectDAO();
    private final MilestoneDAO            milestoneDAO            = new MilestoneDAO();
    private final SupervisorAssignmentDAO supervisorAssignmentDAO = new SupervisorAssignmentDAO();
    private final FeedbackDAO             feedbackDAO             = new FeedbackDAO();
 
    // ── Student: submit project ───────────────────────────────────────────────
 
    /**
     * Validates and inserts a new project submitted by a student.
     * Creates 3 default milestones with equal weight (33/33/34).
     *
     * @throws IllegalArgumentException on validation failure
     */
    public Project submitProject(int studentId, String title, String description,
                                 String repoUrl, String branch, String semester)
            throws SQLException, IllegalArgumentException {
 
        // Validate
        if (ValidationUtil.isBlank(title))
            throw new IllegalArgumentException("Project title is required.");
        if (!ValidationUtil.isValidRepoUrl(repoUrl))
            throw new IllegalArgumentException("Invalid repository URL.");
        if (ValidationUtil.notBlank(semester) && !ValidationUtil.isValidSemester(semester))
            throw new IllegalArgumentException("Semester must be in format YYYY/YYYY-1 or YYYY/YYYY-2.");

        // Limit to 1 non-rejected project per student
        List<Project> existing = projectDAO.findByStudent(studentId);
        for (Project proj : existing) {
            if (proj.getStatus() != Project.Status.REJECTED) {
                throw new IllegalArgumentException("You have already submitted a project. Only one active/pending project is allowed per student.");
            }
        }
 
        Project p = new Project();
        p.setStudentId(studentId);
        p.setTitle(ValidationUtil.sanitise(title));
        p.setDescription(ValidationUtil.sanitise(description));
        p.setRepoUrl(repoUrl.trim());
        p.setBranch(ValidationUtil.defaultIfBlank(branch, "main"));
        p.setSemester(ValidationUtil.sanitise(semester));

        // Auto-assign supervisor if student is bound to one overall
        UserDAO uDAO = new UserDAO();
        User student = uDAO.findById(studentId);
        if (student != null && student.getSupervisorId() != null && student.getSupervisorId() > 0) {
            p.setSupervisorId(student.getSupervisorId());
            p.setStatus(Project.Status.ACTIVE);
        }
 
        projectDAO.insert(p);
 
        // Auto-assign PITA 1 & 2 evaluators if supervisor was assigned
        if (p.getSupervisorId() > 0) {
            assignPitaEvaluatorIfAbsent(p.getId(), p.getSupervisorId(), "PITA1", uDAO);
            assignPitaEvaluatorIfAbsent(p.getId(), p.getSupervisorId(), "PITA2", uDAO);
        }

        // Create 3 default milestones
        createDefaultMilestones(p.getId());
 
        return p;
    }
 
    /** Creates the standard 3 milestones for a new project. */
    private void createDefaultMilestones(int projectId) throws SQLException {
        java.time.LocalDate today = java.time.LocalDate.now();
 
        Milestone m1 = new Milestone(projectId, 1,
                "Proposal & Literature Review",
                today.plusDays(30), 20.0);
        m1.setDescription("Submit project proposal and literature review document.");
 
        Milestone m2 = new Milestone(projectId, 2,
                "System Design & Prototype",
                today.plusDays(90), 35.0);
        m2.setDescription("Submit system architecture diagram and working prototype.");
 
        Milestone m3 = new Milestone(projectId, 3,
                "Final Submission & Presentation",
                today.plusDays(150), 45.0);
        m3.setDescription("Complete system, documentation, and final demonstration.");
 
        milestoneDAO.insert(m1);
        milestoneDAO.insert(m2);
        milestoneDAO.insert(m3);
    }
 
    // ── Coordinator: assign supervisor ────────────────────────────────────────
 
    /**
     * Assigns a supervisor to a project and records the audit event.
     * If the project was PENDING it is promoted to ACTIVE automatically.
     */
    public void assignSupervisor(int projectId, int supervisorId,
                                 int coordinatorId, String note)
            throws SQLException, IllegalArgumentException {
 
        Project p = projectDAO.findById(projectId);
        if (p == null)
            throw new IllegalArgumentException("Project not found: " + projectId);
 
        UserDAO uDAO = new UserDAO();
        User supervisor = uDAO.findById(supervisorId);
        if (supervisor != null && supervisor.getRole() == User.Role.COORDINATOR) {
            throw new IllegalArgumentException("A coordinator cannot be assigned as a supervisor.");
        }

        projectDAO.assignSupervisor(projectId, supervisorId);

        // Bind student account to the supervisor overall
        uDAO.updateSupervisor(p.getStudentId(), supervisorId);

        // Auto-assign PITA 1 & 2 evaluators
        assignPitaEvaluatorIfAbsent(projectId, supervisorId, "PITA1", uDAO);
        assignPitaEvaluatorIfAbsent(projectId, supervisorId, "PITA2", uDAO);
 
        SupervisorAssignment sa = new SupervisorAssignment(projectId, supervisorId, coordinatorId);
        sa.setNote(ValidationUtil.sanitise(note));
        supervisorAssignmentDAO.insert(sa);
    }
 
    // ── Supervisor: review milestone ──────────────────────────────────────────
 
    /**
     * Supervisor approves a milestone.
     * Recalculates and persists the project's overall grade.
     * If all milestones are approved the project status → COMPLETED.
     */
    public void approveMilestone(int milestoneId, double grade,
                                 String supervisorNote, int supervisorId)
            throws SQLException, IllegalArgumentException {
 
        if (!ValidationUtil.isValidGrade(grade))
            throw new IllegalArgumentException("Grade must be between 0 and 100.");
 
        Milestone m = milestoneDAO.findById(milestoneId);
        if (m == null)
            throw new IllegalArgumentException("Milestone not found.");
        if (m.getStatus() != Milestone.MilestoneStatus.SUBMITTED)
            throw new IllegalArgumentException("Milestone is not in SUBMITTED state.");
 
        milestoneDAO.approve(milestoneId, grade, ValidationUtil.sanitise(supervisorNote));
 
        // Recalculate overall grade
        double overall = milestoneDAO.calculateOverallGrade(m.getProjectId());
        projectDAO.updateGrade(m.getProjectId(), overall);
 
        // Check if all milestones are now approved → complete the project
        List<Milestone> all = milestoneDAO.findByProject(m.getProjectId());
        boolean allApproved = all.stream()
                .allMatch(ms -> ms.getStatus() == Milestone.MilestoneStatus.APPROVED);
        if (allApproved) {
            projectDAO.updateStatus(m.getProjectId(), Project.Status.COMPLETED);
        } else {
            // Restore ACTIVE status in case it was UNDER_REVIEW
            projectDAO.updateStatus(m.getProjectId(), Project.Status.ACTIVE);
        }
    }
 
    /**
     * Supervisor rejects a milestone — student must resubmit.
     */
    public void rejectMilestone(int milestoneId, String supervisorNote)
            throws SQLException, IllegalArgumentException {
 
        Milestone m = milestoneDAO.findById(milestoneId);
        if (m == null)
            throw new IllegalArgumentException("Milestone not found.");
        if (m.getStatus() != Milestone.MilestoneStatus.SUBMITTED)
            throw new IllegalArgumentException("Milestone is not in SUBMITTED state.");
 
        milestoneDAO.reject(milestoneId, ValidationUtil.sanitise(supervisorNote));
        projectDAO.updateStatus(m.getProjectId(), Project.Status.ACTIVE);
    }
 
    // ── Student: submit milestone ─────────────────────────────────────────────
 
    /**
     * Student submits a milestone for review.
     * Puts the project into UNDER_REVIEW status.
     */
    public void submitMilestone(int milestoneId, String submissionNote, int studentId)
            throws SQLException, IllegalArgumentException {
 
        Milestone m = milestoneDAO.findById(milestoneId);
        if (m == null)
            throw new IllegalArgumentException("Milestone not found.");
 
        Project p = projectDAO.findById(m.getProjectId());
        if (p == null || p.getStudentId() != studentId)
            throw new IllegalArgumentException("Not authorised to submit this milestone.");
 
        milestoneDAO.submit(milestoneId, ValidationUtil.sanitise(submissionNote));
        projectDAO.updateStatus(m.getProjectId(), Project.Status.UNDER_REVIEW);
    }
 
    // ── Supervisor: post feedback ─────────────────────────────────────────────
 
    public void postFeedback(int projectId, Integer milestoneId, int authorId,
                             Feedback.FeedbackType type, String content)
            throws SQLException, IllegalArgumentException {
 
        if (ValidationUtil.isBlank(content))
            throw new IllegalArgumentException("Feedback content cannot be empty.");
 
        Feedback f = new Feedback(projectId, authorId, type, ValidationUtil.sanitise(content));
        f.setMilestoneId(milestoneId);
        feedbackDAO.insert(f);

        // Dispatch Gmail notifications asynchronously
        sendFeedbackNotifications(projectId, f);
    }

    private void sendFeedbackNotifications(int projectId, Feedback f) {
        try {
            Project p = projectDAO.findById(projectId);
            if (p != null) {
                UserDAO uDAO = new UserDAO();
                User student = uDAO.findById(p.getStudentId());
                if (student != null) {
                    User author = uDAO.findById(f.getAuthorId());
                    String authorName = author != null ? author.getFullName() : "Advisor";
                    
                    String message = String.format(
                        "New comment on your project '%s' from %s (%s):\n\n%s",
                        p.getTitle(), authorName, f.getType().name(), f.getContent()
                    );
                    
                    if (student.isEmailNotifEnabled() && student.getEmail() != null && !student.getEmail().trim().isEmpty()) {
                        EmailService.sendEmailAsync(student.getEmail(), "New Project Feedback: " + p.getTitle(), message);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error dispatching feedback notifications: " + e.getMessage());
            e.printStackTrace();
        }
    }
 
    // ── Coordinator: reject project ───────────────────────────────────────────
 
    public void rejectProject(int projectId, int coordinatorId, String reason)
            throws SQLException {
        projectDAO.updateStatus(projectId, Project.Status.REJECTED);
        if (ValidationUtil.notBlank(reason)) {
            postFeedback(projectId, null, coordinatorId,
                    Feedback.FeedbackType.GENERAL,
                    "Project rejected: " + reason);
        }
    }

    /**
     * Automatically assigns unassigned projects to supervisors based on student CGPA load balancing.
     * Evaluates active supervisors, current assignments, and prioritizes assigning high CGPA students first.
     */
    public int autoAssignSupervisors(int coordinatorId) throws SQLException {
        UserDAO userDAO = new UserDAO();
        List<User> supervisors = userDAO.findAllSupervisors();
        if (supervisors.isEmpty()) {
            throw new IllegalArgumentException("No supervisors found in the system.");
        }

        List<Project> unassigned = projectDAO.findUnassigned();
        if (unassigned.isEmpty()) {
            return 0;
        }

        // Helper class to track supervisor load
        class SupLoad {
            final User supervisor;
            int count = 0;
            double cgpaSum = 0.0;

            SupLoad(User s) {
                this.supervisor = s;
            }

            double getAverageCgpa() {
                return count == 0 ? 0.0 : cgpaSum / count;
            }
        }

        List<SupLoad> loads = new java.util.ArrayList<>();
        for (User s : supervisors) {
            SupLoad load = new SupLoad(s);
            List<Project> supervisorProjects = projectDAO.findBySupervisor(s.getId());
            load.count = supervisorProjects.size();
            for (Project p : supervisorProjects) {
                load.cgpaSum += (p.getStudentCgpa() != null ? p.getStudentCgpa() : 0.0);
            }
            loads.add(load);
        }

        // Sort unassigned projects by student CGPA in descending order (null/unprovided CGPAs are treated as 0.0)
        unassigned.sort((p1, p2) -> {
            double c1 = p1.getStudentCgpa() != null ? p1.getStudentCgpa() : 0.0;
            double c2 = p2.getStudentCgpa() != null ? p2.getStudentCgpa() : 0.0;
            return Double.compare(c2, c1);
        });

        // Sequence assignment: assign to supervisor with lowest count, tie-break by lowest average CGPA
        for (Project p : unassigned) {
            SupLoad best = null;
            for (SupLoad candidate : loads) {
                if (best == null) {
                    best = candidate;
                    continue;
                }

                if (candidate.count < best.count) {
                    best = candidate;
                } else if (candidate.count == best.count) {
                    if (candidate.getAverageCgpa() < best.getAverageCgpa()) {
                        best = candidate;
                    }
                }
            }

            assignSupervisor(p.getId(), best.supervisor.getId(), coordinatorId,
                    "Automatically assigned based on CGPA load balancing.");

            best.count++;
            best.cgpaSum += (p.getStudentCgpa() != null ? p.getStudentCgpa() : 0.0);
        }

        return unassigned.size();
    }

    /**
     * Automatically assigns unassigned student accounts to supervisors based on CGPA load balancing.
     * Synchronizes student-supervisor assignments to their active projects as well.
     */
    public int autoAssignStudentSupervisors() throws SQLException {
        UserDAO userDAO = new UserDAO();
        List<User> supervisors = userDAO.findAllSupervisors();
        if (supervisors.isEmpty()) {
            throw new IllegalArgumentException("No supervisors found in the system.");
        }

        List<User> students = userDAO.findAllStudents();
        List<User> unassignedStudents = new java.util.ArrayList<>();
        for (User u : students) {
            if (u.getSupervisorId() == null || u.getSupervisorId() <= 0) {
                unassignedStudents.add(u);
            }
        }

        if (unassignedStudents.isEmpty()) {
            return 0;
        }

        // Helper class to track supervisor load (student count and CGPA sum)
        class SupLoad {
            final User supervisor;
            int count = 0;
            double cgpaSum = 0.0;

            SupLoad(User s) {
                this.supervisor = s;
            }

            double getAverageCgpa() {
                return count == 0 ? 0.0 : cgpaSum / count;
            }
        }

        List<SupLoad> loads = new java.util.ArrayList<>();
        for (User s : supervisors) {
            SupLoad load = new SupLoad(s);
            for (User std : students) {
                if (std.getSupervisorId() != null && std.getSupervisorId().equals(s.getId())) {
                    load.count++;
                    load.cgpaSum += (std.getCgpa() != null ? std.getCgpa() : 0.0);
                }
            }
            loads.add(load);
        }

        // Sort unassigned students by CGPA in descending order
        unassignedStudents.sort((s1, s2) -> {
            double c1 = s1.getCgpa() != null ? s1.getCgpa() : 0.0;
            double c2 = s2.getCgpa() != null ? s2.getCgpa() : 0.0;
            return Double.compare(c2, c1);
        });

        // Assign each student to the supervisor with lowest count, tie-break by lowest average CGPA
        for (User u : unassignedStudents) {
            SupLoad best = null;
            for (SupLoad candidate : loads) {
                if (best == null) {
                    best = candidate;
                    continue;
                }

                if (candidate.count < best.count) {
                    best = candidate;
                } else if (candidate.count == best.count) {
                    if (candidate.getAverageCgpa() < best.getAverageCgpa()) {
                        best = candidate;
                    }
                }
            }

            // Update student's supervisor in DB
            userDAO.updateSupervisor(u.getId(), best.supervisor.getId());

            // Synchronize supervisor to any projects owned by this student
            projectDAO.updateSupervisorForStudent(u.getId(), best.supervisor.getId());

            // Synchronize PITA 1 & 2 evaluators for all projects owned by this student
            List<Project> studentProjects = projectDAO.findByStudent(u.getId());
            for (Project p : studentProjects) {
                assignPitaEvaluatorIfAbsent(p.getId(), best.supervisor.getId(), "PITA1", userDAO);
                assignPitaEvaluatorIfAbsent(p.getId(), best.supervisor.getId(), "PITA2", userDAO);
            }

            best.count++;
            best.cgpaSum += (u.getCgpa() != null ? u.getCgpa() : 0.0);
        }

        return unassignedStudents.size();
    }
 
    // ── Read helpers ──────────────────────────────────────────────────────────
 
    public Project getProjectOrThrow(int projectId) throws SQLException {
        Project p = projectDAO.findById(projectId);
        if (p == null)
            throw new IllegalArgumentException("Project not found: " + projectId);
        return p;
    }

    public void reassignStudentSupervisor(int studentId, Integer supervisorId) throws SQLException {
        UserDAO userDAO = new UserDAO();
        userDAO.updateSupervisor(studentId, supervisorId);
        projectDAO.updateSupervisorForStudent(studentId, supervisorId);

        if (supervisorId != null && supervisorId > 0) {
            List<Project> studentProjects = projectDAO.findByStudent(studentId);
            for (Project p : studentProjects) {
                assignPitaEvaluatorIfAbsent(p.getId(), supervisorId, "PITA1", userDAO);
                assignPitaEvaluatorIfAbsent(p.getId(), supervisorId, "PITA2", userDAO);
            }
        }
    }

    private void assignPitaEvaluatorIfAbsent(int projectId, int evaluatorId, String stage, UserDAO uDAO) {
        try {
            List<User> currentEvaluators = uDAO.findEvaluatorsByProjectAndStage(projectId, stage);
            boolean alreadyAssigned = false;
            for (User u : currentEvaluators) {
                if (u.getId() == evaluatorId) {
                    alreadyAssigned = true;
                    break;
                }
            }
            if (!alreadyAssigned) {
                uDAO.addEvaluator(projectId, evaluatorId, stage);
            }
        } catch (Exception e) {
            System.err.println("Error assigning PITA evaluator automatically: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
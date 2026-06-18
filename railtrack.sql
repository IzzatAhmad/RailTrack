-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 28, 2026 at 04:30 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `railtrack`
--

-- --------------------------------------------------------

--
-- Table structure for table `deployment_logs`
--

CREATE TABLE `deployment_logs` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `performed_by_id` int(11) NOT NULL,
  `action` enum('BUILD','START','STOP','REBUILD','REMOVE') NOT NULL,
  `outcome` enum('success','failed') NOT NULL DEFAULT 'success',
  `detail` text DEFAULT NULL,
  `performed_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `feedback`
--

CREATE TABLE `feedback` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `milestone_id` int(11) DEFAULT NULL,
  `author_id` int(11) NOT NULL,
  `type` enum('GENERAL','MILESTONE','CODE_REVIEW','FINAL_EVAL') NOT NULL DEFAULT 'GENERAL',
  `content` text NOT NULL,
  `read_by_student` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `read_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `milestones`
--

CREATE TABLE `milestones` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `milestone_no` tinyint(3) UNSIGNED NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `status` enum('NOT_STARTED','IN_PROGRESS','SUBMITTED','APPROVED','REJECTED') NOT NULL DEFAULT 'NOT_STARTED',
  `weight` decimal(5,2) NOT NULL DEFAULT 0.00,
  `grade` decimal(5,2) DEFAULT NULL,
  `pita_stage` varchar(10) DEFAULT NULL,
  `supervisor_note` text DEFAULT NULL,
  `submission_note` text DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `milestones`
--

INSERT INTO `milestones` (`id`, `project_id`, `milestone_no`, `title`, `description`, `due_date`, `status`, `weight`, `grade`, `supervisor_note`, `submission_note`, `submitted_at`, `reviewed_at`, `created_at`) VALUES
(1, 1, 1, 'Proposal & Literature Review', 'Submit project proposal and literature review document.', '2026-06-27', 'NOT_STARTED', 20.00, NULL, NULL, NULL, NULL, NULL, '2026-05-28 22:09:24'),
(2, 1, 2, 'System Design & Prototype', 'Submit system architecture and working prototype.', '2026-08-26', 'NOT_STARTED', 35.00, NULL, NULL, NULL, NULL, NULL, '2026-05-28 22:09:24'),
(3, 1, 3, 'Final Submission & Presentation', 'Complete system, documentation, and final demo.', '2026-10-25', 'NOT_STARTED', 45.00, NULL, NULL, NULL, NULL, NULL, '2026-05-28 22:09:24');

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

CREATE TABLE `projects` (
  `id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `student_id` int(11) NOT NULL,
  `supervisor_id` int(11) DEFAULT NULL,
  `repo_url` varchar(500) NOT NULL,
  `branch` varchar(100) NOT NULL DEFAULT 'main',
  `image_tag` varchar(200) DEFAULT NULL,
  `docker_status` varchar(30) NOT NULL DEFAULT 'none',
  `container_port` smallint(5) UNSIGNED DEFAULT NULL,
  `container_id` varchar(64) DEFAULT NULL,
  `build_log` mediumtext DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `semester` varchar(20) DEFAULT NULL,
  `status` enum('PENDING','ACTIVE','UNDER_REVIEW','COMPLETED','REJECTED') NOT NULL DEFAULT 'PENDING',
  `current_milestone_no` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `overall_grade` decimal(5,2) DEFAULT NULL,
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `running_limit_seconds` int(11) NOT NULL DEFAULT 14400
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `projects`
--

INSERT INTO `projects` (`id`, `title`, `description`, `student_id`, `supervisor_id`, `repo_url`, `branch`, `image_tag`, `docker_status`, `container_port`, `container_id`, `build_log`, `error_message`, `semester`, `status`, `current_milestone_no`, `overall_grade`, `submitted_at`, `updated_at`, `running_limit_seconds`) VALUES
(1, 'pokri', 'Final Year Project by Charlie', 4, 3, 'https://github.com/aezmine/classroom-project', 'main', NULL, 'none', NULL, NULL, NULL, NULL, '2024/2025-1', 'ACTIVE', 1, NULL, '2026-05-28 22:09:24', '2026-05-28 22:09:24', 14400);

-- --------------------------------------------------------

--
-- Table structure for table `student_menu_items`
--

CREATE TABLE `student_menu_items` (
  `id` int(11) NOT NULL,
  `item_key` varchar(60) NOT NULL COMMENT 'Stable identifier, e.g. matra, project_register',
  `label` varchar(80) NOT NULL COMMENT 'Display label shown to student',
  `icon` varchar(80) NOT NULL COMMENT 'Bootstrap-Icons class, e.g. bi-grid',
  `icon_color` varchar(30) DEFAULT '#2563eb' COMMENT 'CSS colour for the icon',
  `url` varchar(255) NOT NULL COMMENT 'Relative URL the tile links to',
  `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT 'Lower = appears first',
  `is_enabled` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 = visible to students, 0 = hidden',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_menu_items`
--

INSERT INTO `student_menu_items` (`id`, `item_key`, `label`, `icon`, `icon_color`, `url`, `sort_order`, `is_enabled`, `created_at`, `updated_at`) VALUES
(1, 'matra', 'matra', 'bi-grid-fill', '#2563eb', '/matra', 1, 1, '2026-05-28 14:09:40', '2026-05-28 14:09:40'),
(2, 'project_register', 'Project Register', 'bi-person-plus-fill', '#2563eb', '/project/register', 2, 1, '2026-05-28 14:09:40', '2026-05-28 14:09:40'),
(3, 'registered_list', 'Registered Project List', 'bi-list-check', '#1e2740', '/project/list', 3, 1, '2026-05-28 14:09:40', '2026-05-28 14:09:40'),
(4, 'student_list', 'List', 'bi-people-fill', '#16a34a', '/students/list', 4, 1, '2026-05-28 14:09:40', '2026-05-28 14:09:40'),
(5, 'planning', 'Planning', 'bi-calendar-week-fill', '#d97706', '/planning', 5, 1, '2026-05-28 14:09:40', '2026-05-28 14:09:40'),
(6, 'pita_01', 'PITA-01', 'bi-file-earmark-pdf-fill', '#dc2626', '/forms/pita01', 6, 1, '2026-05-28 14:09:40', '2026-05-28 14:09:40'),
(7, 'materials', 'Materials', 'bi-journal-text', '#2563eb', '/materials', 7, 1, '2026-05-28 14:09:40', '2026-05-28 14:09:40'),
(8, 'rubrics', 'Rubrics', 'bi-check2-square', '#1e2740', '/rubrics', 8, 1, '2026-05-28 14:09:40', '2026-05-28 14:09:40'),
(9, 'presentation', 'Presentation', 'bi-people-fill', '#2563eb', '/presentation', 9, 1, '2026-05-28 14:09:40', '2026-05-28 14:09:40'),
(10, 'thesis_upload', 'Thesis Upload', 'bi-upload', '#1e2740', '/thesis/upload', 10, 1, '2026-05-28 14:09:40', '2026-05-28 14:09:40'),
(11, 'thesis_status', 'Thesis Status', 'bi-list-check', '#1e2740', '/thesis/status', 11, 1, '2026-05-28 14:09:40', '2026-05-28 14:09:40');

-- --------------------------------------------------------

--
-- Table structure for table `supervisor_assignments`
--

CREATE TABLE `supervisor_assignments` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `supervisor_id` int(11) NOT NULL,
  `assigned_by_id` int(11) NOT NULL,
  `note` text DEFAULT NULL,
  `assigned_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(120) NOT NULL,
  `email` varchar(120) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `department` varchar(100) DEFAULT NULL,
  `cgpa` decimal(3,2) DEFAULT NULL,
  `role` enum('STUDENT','SUPERVISOR','COORDINATOR') NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `last_login` datetime DEFAULT NULL,
  `supervisor_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password_hash`, `full_name`, `email`, `phone`, `department`, `role`, `active`, `created_at`, `last_login`) VALUES
(1, 'admin', '$2a$10$42Ea2IL5YHdx5eN5b5QuveZZ8gH84eoXRg99oeFjebEeFzYQbN7oO', 'Admin Coordinator', 'admin@railtrack.local', NULL, NULL, 'COORDINATOR', 1, '2026-05-28 22:09:24', NULL),
(2, 'sup_ali', '$2a$10$42Ea2IL5YHdx5eN5b5QuveZZ8gH84eoXRg99oeFjebEeFzYQbN7oO', 'Ali Supervisor', 'ali@railtrack.local', NULL, NULL, 'SUPERVISOR', 1, '2026-05-28 22:09:24', NULL),
(3, 'sup_bob', '$2a$10$42Ea2IL5YHdx5eN5b5QuveZZ8gH84eoXRg99oeFjebEeFzYQbN7oO', 'Bob Supervisor', 'bob@railtrack.local', NULL, NULL, 'SUPERVISOR', 1, '2026-05-28 22:09:24', NULL),
(4, 'stu_charlie', '$2a$10$42Ea2IL5YHdx5eN5b5QuveZZ8gH84eoXRg99oeFjebEeFzYQbN7oO', 'Charlie Student', 'charlie@railtrack.local', NULL, NULL, 'STUDENT', 1, '2026-05-28 22:09:24', NULL),
(5, 'stu_dana', '$2a$10$42Ea2IL5YHdx5eN5b5QuveZZ8gH84eoXRg99oeFjebEeFzYQbN7oO', 'Dana Student', 'dana@railtrack.local', NULL, NULL, 'STUDENT', 1, '2026-05-28 22:09:24', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `deployment_logs`
--
ALTER TABLE `deployment_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_log_performer` (`performed_by_id`),
  ADD KEY `idx_log_project` (`project_id`),
  ADD KEY `idx_log_action` (`action`);

--
-- Indexes for table `feedback`
--
ALTER TABLE `feedback`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_feedback_milestone` (`milestone_id`),
  ADD KEY `idx_feedback_project` (`project_id`),
  ADD KEY `idx_feedback_author` (`author_id`),
  ADD KEY `idx_feedback_unread` (`project_id`,`read_by_student`);

--
-- Indexes for table `milestones`
--
ALTER TABLE `milestones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_milestone` (`project_id`,`milestone_no`),
  ADD KEY `idx_milestone_project` (`project_id`),
  ADD KEY `idx_milestone_status` (`status`);

--
-- Indexes for table `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_project_student` (`student_id`),
  ADD KEY `idx_project_supervisor` (`supervisor_id`),
  ADD KEY `idx_project_status` (`status`),
  ADD KEY `idx_project_semester` (`semester`);

--
-- Indexes for table `student_menu_items`
--
ALTER TABLE `student_menu_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `item_key` (`item_key`);

--
-- Indexes for table `supervisor_assignments`
--
ALTER TABLE `supervisor_assignments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_sa_assigned_by` (`assigned_by_id`),
  ADD KEY `idx_sa_project` (`project_id`),
  ADD KEY `idx_sa_supervisor` (`supervisor_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_users_role` (`role`),
  ADD KEY `idx_users_active` (`active`),
  ADD KEY `idx_users_supervisor` (`supervisor_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `deployment_logs`
--
ALTER TABLE `deployment_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `feedback`
--
ALTER TABLE `feedback`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `milestones`
--
ALTER TABLE `milestones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `projects`
--
ALTER TABLE `projects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `student_menu_items`
--
ALTER TABLE `student_menu_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `supervisor_assignments`
--
ALTER TABLE `supervisor_assignments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `deployment_logs`
--
ALTER TABLE `deployment_logs`
  ADD CONSTRAINT `fk_log_performer` FOREIGN KEY (`performed_by_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_log_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `feedback`
--
ALTER TABLE `feedback`
  ADD CONSTRAINT `fk_feedback_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_feedback_milestone` FOREIGN KEY (`milestone_id`) REFERENCES `milestones` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_feedback_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `milestones`
--
ALTER TABLE `milestones`
  ADD CONSTRAINT `fk_milestone_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `fk_project_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_project_supervisor` FOREIGN KEY (`supervisor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `supervisor_assignments`
--
ALTER TABLE `supervisor_assignments`
  ADD CONSTRAINT `fk_sa_assigned_by` FOREIGN KEY (`assigned_by_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_sa_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_sa_supervisor` FOREIGN KEY (`supervisor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_user_supervisor` FOREIGN KEY (`supervisor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

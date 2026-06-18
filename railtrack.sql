-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 18, 2026 at 03:02 AM
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
  `supervisor_id` int(11) DEFAULT NULL,
  `telegram_chat_id` varchar(100) DEFAULT NULL,
  `email_notif_enabled` tinyint(1) DEFAULT 1,
  `telegram_notif_enabled` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password_hash`, `full_name`, `email`, `phone`, `department`, `cgpa`, `role`, `active`, `created_at`, `last_login`, `supervisor_id`, `telegram_chat_id`, `email_notif_enabled`, `telegram_notif_enabled`) VALUES
(1, 'admin', '$2a$10$42Ea2IL5YHdx5eN5b5QuveZZ8gH84eoXRg99oeFjebEeFzYQbN7oO', 'Admin Coordinator', 'admin@railtrack.local', NULL, NULL, NULL, 'COORDINATOR', 0, '2026-05-28 22:09:24', '2026-06-18 07:24:47', NULL, NULL, 1, 0),
(5, 'stu_dana', '$2a$10$42Ea2IL5YHdx5eN5b5QuveZZ8gH84eoXRg99oeFjebEeFzYQbN7oO', 'Dana Student', 'timekeeper.semicolon@gmail.com', '01128483302', '', 2.55, 'STUDENT', 0, '2026-05-28 22:09:24', '2026-06-18 07:50:01', 280, '', 1, 1),
(207, 'testsupervisor', '120000:cXZuBwxKHBeu8sZ8T/8BbQ==:Yg5/Pd15YYEUK5RjyAWk/OpL2cWNjBhFzKncOtkERHI=', 'Test Supervisor', 'testsupervisor@railtrack.com', '', 'SMSK(KP)', NULL, 'SUPERVISOR', 0, '2026-06-03 18:04:25', '2026-06-03 18:17:17', NULL, NULL, 1, 0),
(208, 'testcoordinator', '120000:Vba964iDOSwbZ/znm/OeEg==:rDKJXgrFrntVQdmYYsk8mgfluB2+mZXlcR/9/XSaDrU=', 'Admin Coordinator', 'testcoordinator@railtrack.com', NULL, 'SMSK(KP)', 2.57, 'STUDENT', 0, '2026-06-03 18:06:25', '2026-06-03 18:06:43', 290, NULL, 1, 0),
(211, 'student112', '120000:QFlZxAY01/NQZ5A1bMeB3w==:osMXqxeXkZU7XqbO6svr/fVOkXS4Mda0YuaeKCf0uJA=', 'Student 112', 'student112@railtrack.local', '', 'Computer Science', 3.17, 'STUDENT', 0, '2026-06-04 16:30:14', '2026-06-07 16:17:21', 293, NULL, 1, 0),
(212, 'student113', '120000:cc8QNIG+8aR/mtE5+GKTew==:EFBM0TtQX1+OrefVEmm76G2h3a6J136SVok0R73dxxs=', 'Student 113', 'student113@railtrack.local', '', 'Information Technology', 2.16, 'STUDENT', 0, '2026-06-04 16:30:14', '2026-06-07 16:18:59', 293, NULL, 1, 0),
(213, 'student114', '120000:s26jcv2R+wMDoyes0AAlrw==:qGT59HUl1qeU+lf/k82T+amHeZf5r6+dj0oMbd9o2t4=', 'Student 114', 'student114@railtrack.local', '', 'Information Systems', 3.29, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 296, NULL, 1, 0),
(214, 'student115', '120000:2j+4O/7fV7QwbBFeUDFe8A==:3fjdEISy1yhhUetuK47sKrGswvUd3k4LLkTEy07M7Lg=', 'Student 115', 'student115@railtrack.local', '', 'Cyber Security', 3.97, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 284, NULL, 1, 0),
(215, 'student116', '120000:gwWvWMl3mbuR38eBM+Bt5w==:iORTJtnqJ6Rea/FMwBIHVMhKjcjm4TCLxbtJIxkegG0=', 'Student 116', 'student116@railtrack.local', '', 'Software Engineering', 3.97, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 285, NULL, 1, 0),
(216, 'student117', '120000:aMxAIfJnJEDSYvAJK3FQ/w==:7oA4fdpEoLtt2QugubshpxF/Vj16OD7kV6rSlA5Xyt8=', 'Student 117', 'student117@railtrack.local', '', 'Computer Science', 3.95, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 286, NULL, 1, 0),
(217, 'student118', '120000:ZOhbZMXafBuvxs8CzmTH6A==:Saig6fbFZxXKcnxwg4UqMm1GGBNHHyod7LZWZb8dKPo=', 'Student 118', 'student118@railtrack.local', '', 'Information Technology', 3.82, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 293, NULL, 1, 0),
(218, 'student119', '120000:0y2HfiV5KmW2zWBcZ4IYqw==:ke37Z/6B1hk1MeeU2bxzf93JkkkYYeEDYEbHiXuqIsM=', 'Student 119', 'student119@railtrack.local', '', 'Information Systems', 3.27, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 295, NULL, 1, 0),
(219, 'student120', '120000:8VkVK31g9Vgtd0RtP1euqQ==:TlnUsrSQfG4lph2NlynITIwzprgkD/PuNH65Z6qHLA0=', 'Student 120', 'student120@railtrack.local', '', 'Cyber Security', 2.87, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 284, NULL, 1, 0),
(220, 'student121', '120000:bzKjBj83TQC1wx12bZ3NPg==:mqjbB+YGvfnaoFmyHqN44DiB74k7izY4RclSyv/JcZY=', 'Student 121', 'student121@railtrack.local', '', 'Software Engineering', 2.56, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 295, NULL, 1, 0),
(221, 'student122', '120000:H8rcv5ayrv1+1suYDPsrcg==:GMcFnJv3JIyM2YATMCP2oXC9wtoccy7V0/gXQoXsszs=', 'Student 122', 'student122@railtrack.local', '', 'Computer Science', 2.18, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 301, NULL, 1, 0),
(222, 'student123', '120000:ZMTHLd9Xjj1O+3/DXAO3WA==:FP15GME/BKnR4JiRa6JCQJD1mtwLNUn2ADaxs5dhnWA=', 'Student 123', 'student123@railtrack.local', '', 'Information Technology', 3.21, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 281, NULL, 1, 0),
(223, 'student124', '120000:9o50aeoUExxFWcIiFm1/Uw==:XbN9DoXqzZ3xm8WwK7zxlkL1cVtuZiX7fPs66o/CzEo=', 'Student 124', 'student124@railtrack.local', '', 'Information Systems', 3.50, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 301, NULL, 1, 0),
(224, 'student125', '120000:J/PNkaTvJfdRqeHTbiVk8A==:LCmxIf4k9GnyvNLFsGFZF3ZCn0Jumusjv2Mli+0U+Uw=', 'Student 125', 'student125@railtrack.local', '', 'Cyber Security', 3.87, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 289, NULL, 1, 0),
(225, 'student126', '120000:QJH+g5W8feLQwwC18GGeJQ==:ajjjz+Vj0EJ7WpJDFb7ouZ47dvHUYZaulQkxnddDq3Q=', 'Student 126', 'student126@railtrack.local', '', 'Software Engineering', 2.88, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 286, NULL, 1, 0),
(226, 'student127', '120000:g3veKtkby+UsLWTkn4fkIA==:e57gTn9I3VYgiyqKHNnJBj/aBs1a8kVd5tO/aLXVBnA=', 'Student 127', 'student127@railtrack.local', '', 'Computer Science', 2.77, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 284, NULL, 1, 0),
(227, 'student128', '120000:a9sY0FIRTMO6USePwfoPjQ==:1A9dSTsEROY1xt5cjpBdVhGf5MiQjGbWXDMJ1423Kj0=', 'Student 128', 'student128@railtrack.local', '', 'Information Technology', 3.23, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 294, NULL, 1, 0),
(228, 'student129', '120000:TlRdW59nP+OtqB/I06+p1w==:JxK8o5XRTmB1ulKlC4lVqlaVlWZl8tv409nKv+Zuo0k=', 'Student 129', 'student129@railtrack.local', '', 'Information Systems', 3.85, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 290, NULL, 1, 0),
(229, 'student130', '120000:uHMxOyBOYMgxKOj95fw/FQ==:0JYT3yq/wx6BrUPlh/vjAhIP7fgLBe2d1momzNw7VnM=', 'Student 130', 'student130@railtrack.local', '', 'Cyber Security', 3.53, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 298, NULL, 1, 0),
(230, 'student131', '120000:MkSb8XceKaVlzf4kD7mHSQ==:QyozFslFi77Gs7/ZxFO0kLoFs88zC/2n5CK6x5jx0Js=', 'Student 131', 'student131@railtrack.local', '', 'Software Engineering', 2.10, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 294, NULL, 1, 0),
(231, 'student132', '120000:GS01GQMosliKL5N/7jbwlA==:4R1ogY5HTgBfP9A6zzEyvjSXquUU4RqZljRxQxlOrCg=', 'Student 132', 'student132@railtrack.local', '', 'Computer Science', 3.93, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 287, NULL, 1, 0),
(232, 'student133', '120000:9m0BtPdv3vB86ZXASi92lA==:p0ZvPDa06kJqY3MA5JeFlpwebk2ZK+opBIaYkD0gi/o=', 'Student 133', 'student133@railtrack.local', '', 'Information Technology', 3.36, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 299, NULL, 1, 0),
(233, 'student134', '120000:D9ZeWKUeOSbMDT2MyE1NYQ==:TS8wYBxsYwgt1QA/SSH81vxQsRa4V/vJlW3KFo92Z3M=', 'Student 134', 'student134@railtrack.local', '', 'Information Systems', 2.99, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 291, NULL, 1, 0),
(234, 'student135', '120000:CVO6xocjlQysZ6W5yK5aHQ==:10r+1DuY4gn40dqn4kJ8hC0GiBGERdwanupk5FJa72E=', 'Student 135', 'student135@railtrack.local', '', 'Cyber Security', 2.87, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 285, NULL, 1, 0),
(235, 'student136', '120000:VOEHITqJQNgK2hs7scmPDQ==:WTiqF+ypc5Ci3CdhvdBVtmKH20BBRrPLNxWv1IbPmXc=', 'Student 136', 'student136@railtrack.local', '', 'Software Engineering', 3.39, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 298, NULL, 1, 0),
(236, 'student137', '120000:cLvFNrWCpOvs6cGqisvqIA==:58dWk6moVVdzyQaPRFHywk8XdGIIRPRxWam9HHDMq3M=', 'Student 137', 'student137@railtrack.local', '', 'Computer Science', 2.34, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 301, NULL, 1, 0),
(237, 'student138', '120000:Z25f6sCRwj264Uk4S/0LYw==:nRi2iKBFSb8sUy3OJX6nxKvCpJ5nooLXkHddHtM+b2Y=', 'Student 138', 'student138@railtrack.local', '', 'Information Technology', 3.53, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 299, NULL, 1, 0),
(238, 'student139', '120000:kSC7ZBaqRBaU4uMRCFsNbw==:0aZ5ObSZ6dOjz+IQu5Od5gzYR2VeIMVC/V0V+NCFqYU=', 'Student 139', 'student139@railtrack.local', '', 'Information Systems', 2.62, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 289, NULL, 1, 0),
(239, 'student140', '120000:ferwc+mdLUpBvNHMJfYDPQ==:Vwe2rs+evcKvMY3WZ2ecgEdAz4AQj+gq5GHaVutz7gk=', 'Student 140', 'student140@railtrack.local', '', 'Cyber Security', 2.52, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 298, NULL, 1, 0),
(240, 'student141', '120000:Z/r1WreyOePuUb8cwxym9g==:qeQkraXsHKQxJClCjAhbS/ncNwTWfMZOUp0yNQUwZsQ=', 'Student 141', 'student141@railtrack.local', '', 'Software Engineering', 2.76, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 287, NULL, 1, 0),
(241, 'student142', '120000:1s4s8pbWH6vb/ENUa/KDKQ==:NiTjx51GK1ZOsutgRat91qQak+JEg3finNW+V8zVZcE=', 'Student 142', 'student142@railtrack.local', '', 'Computer Science', 2.21, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 280, NULL, 1, 0),
(242, 'student143', '120000:AJs3OjoO+GzacpxOLyqSxg==:xFzIXjbKIyiAsQ5QM/GZKpZJwqAcgXB+XP3TBA9DQIc=', 'Student 143', 'student143@railtrack.local', '', 'Information Technology', 2.80, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 282, NULL, 1, 0),
(243, 'student144', '120000:QO2u5GoDbj2XVMRHP+l5gA==:xtyvhQnqCGmG19yoWdIHECcK1sn2wdbXgdkP1LIPYlo=', 'Student 144', 'student144@railtrack.local', '', 'Information Systems', 3.36, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 297, NULL, 1, 0),
(244, 'student145', '120000:knImZM8sSCJohpYVVxMH/g==:URiPV+JpYCKtl0jLJopMNm0CDu9+LUVy/02cDYSbWug=', 'Student 145', 'student145@railtrack.local', '', 'Cyber Security', 2.38, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 281, NULL, 1, 0),
(245, 'student146', '120000:A8jYInvv2BW2Xsap3eCiXA==:Q4SMRmv5HruuomKJ8Z3ttf83+oijLodYODGZjMofL1g=', 'Student 146', 'student146@railtrack.local', '', 'Software Engineering', 3.85, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 291, NULL, 1, 0),
(246, 'student147', '120000:++F6qTImXhjbFJsqvYmO+g==:rJCtvicGcIOCn8/QwWRUsph8pqNBQIJcylIN8GYkDCg=', 'Student 147', 'student147@railtrack.local', '', 'Computer Science', 2.08, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 298, NULL, 1, 0),
(247, 'student148', '120000:ZKQhKtqioa+3d320bWtECg==:YN2igGrOz6Jo6O1QGK8umihi68+Cb7C4G9agsSf/Jxk=', 'Student 148', 'student148@railtrack.local', '', 'Information Technology', 2.85, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 283, NULL, 1, 0),
(248, 'student149', '120000:D4JpVCzdRIlu61/3lDhS/g==:kXFuUkttNXZCzSpgFKZYn3ALFL3fLBYsoaimg05bit0=', 'Student 149', 'student149@railtrack.local', '', 'Information Systems', 2.01, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 290, NULL, 1, 0),
(249, 'student150', '120000:6a6Q8oRD+JPJhazzA0mprw==:lyH63OmRR1XhBgLu9He2RstA0himLjPv8rNbKQaPHH4=', 'Student 150', 'student150@railtrack.local', '', 'Cyber Security', 3.50, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 207, NULL, 1, 0),
(250, 'student151', '120000:otyYGwWBl5j7KKRQBaWuLg==:vVVTcxfH8d05UMd8nJg8k84EDL3TMY6XEBhv1aj/Tpw=', 'Student 151', 'student151@railtrack.local', '', 'Software Engineering', 3.46, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 282, NULL, 1, 0),
(251, 'student152', '120000:nc+q81STG+ch9xjFuoy7Gw==:9cCXmT6NR6iR9q+550euldlhExFe6vNBxGo3+t82Opo=', 'Student 152', 'student152@railtrack.local', '', 'Computer Science', 2.80, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 280, NULL, 1, 0),
(252, 'student153', '120000:0e9TwkufaJSFmcupq43Y5g==:hJaTGyzsSKWeeeIWWYaQhcuUYt5z8+CNibLvn2Y3lTo=', 'Student 153', 'student153@railtrack.local', '', 'Information Technology', 3.61, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 296, NULL, 1, 0),
(253, 'student154', '120000:IKh91Ys+w33cGYYqJKDyZg==:AV6pk1KHvxi97PXlFX5eILbHqqrLnzt3JL3zBUeS/So=', 'Student 154', 'student154@railtrack.local', '', 'Information Systems', 3.65, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 295, NULL, 1, 0),
(254, 'student155', '120000:iqcUJEvdIfaNF4nSmFC/qA==:i/yRoW9oa5yMObZOSAaSH120PvPslTWGswe5mJawmnY=', 'Student 155', 'student155@railtrack.local', '', 'Cyber Security', 3.44, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 207, NULL, 1, 0),
(255, 'student156', '120000:SgbS3w77GzZypuAFG4lBNw==:/qrldIjh9InUNXPr2dVYON9MUO0jw3RT4S2uNSO9F6U=', 'Student 156', 'student156@railtrack.local', '', 'Software Engineering', 2.25, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 292, NULL, 1, 0),
(256, 'student157', '120000:YEU9IJc+bpDX1WuVolYMSA==:XrorKB7Yz8AKeCA8vI2rZReJcSKbonUanACyYboLV80=', 'Student 157', 'student157@railtrack.local', '', 'Computer Science', 2.93, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 288, NULL, 1, 0),
(257, 'student158', '120000:JLBsJMha5LintINhRTjAEQ==:JvF4s7Lv1Awn/nsgeElPCCS3CWqTwqZdaRHmTe55SPQ=', 'Student 158', 'student158@railtrack.local', '', 'Information Technology', 3.91, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 288, NULL, 1, 0),
(258, 'student159', '120000:GiyOCQVy9LFUC0cVJLLTRg==:pE5jgnXXLhZKvsx5qifzbutzsF1EteWPU/NU1yCMgAc=', 'Student 159', 'student159@railtrack.local', '', 'Information Systems', 2.77, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 285, NULL, 1, 0),
(259, 'student160', '120000:l1et7ZXxKPK0K7eNYt/LRA==:6cifhh8tjy4TDChBMJO5Uvl5KeoiMvExxQEfPos6+MQ=', 'Student 160', 'student160@railtrack.local', '', 'Cyber Security', 2.10, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 297, NULL, 1, 0),
(260, 'student161', '120000:+/jFp01h2m9rpvLdV4qNbA==:VFfL4M15wkTLr5NQzrk4v5Uh7durUHepGip9AIep4i8=', 'Student 161', 'student161@railtrack.local', '', 'Software Engineering', 2.21, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 292, NULL, 1, 0),
(261, 'student162', '120000:yVjS/4e7YG2CDcLC+7VX6Q==:IA+rCfcZgJ+e124zpalVZoLK1wHTkcG9kpcDwZe84rs=', 'Student 162', 'student162@railtrack.local', '', 'Computer Science', 2.72, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 291, NULL, 1, 0),
(262, 'student163', '120000:nSzVfTIdACNMEltnqGSHqg==:S56iU4dpaKuDuxYWXeENcBGnJ9ILGjMJgx8Ulm5x+T0=', 'Student 163', 'student163@railtrack.local', '', 'Information Technology', 2.99, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 289, NULL, 1, 0),
(263, 'student164', '120000:I9SZ/gEfX3ly/wfWfpQYtw==://YVnMkge+g0wKCbHLO34IhqEWr5YlgBOuPqLs5JS6M=', 'Student 164', 'student164@railtrack.local', '', 'Information Systems', 2.78, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 286, NULL, 1, 0),
(264, 'student165', '120000:pVBcX/JmI3RUom4ub+II9g==:PybM2e+4i+iQUDYM2UDs0413rTuYAAbr30tx1Dt3gYU=', 'Student 165', 'student165@railtrack.local', '', 'Cyber Security', 2.91, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 287, NULL, 1, 0),
(265, 'student166', '120000:Xmb0d7q8yu8L9oBA7ZrRdw==:RudBofd39G9M7MB8Mdky0x2tDSO8jOH2eFrtb3x2oSM=', 'Student 166', 'student166@railtrack.local', '', 'Software Engineering', 2.25, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 282, NULL, 1, 0),
(266, 'student167', '120000:YK/cqUv7sVIMZveJla1lHQ==:REa/qF5UK/Zz5HTu7tyel3LIvkA11QhcObgvyI0saMk=', 'Student 167', 'student167@railtrack.local', '', 'Computer Science', 2.49, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 294, NULL, 1, 0),
(267, 'student168', '120000:v7i9kwPJvegjk9q2HPIm6g==:7wFt9ODetEB8cEPthGWDCxySMk9dluWbDEKFjIVG/dY=', 'Student 168', 'student168@railtrack.local', '', 'Information Technology', 3.70, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 294, NULL, 1, 0),
(268, 'student169', '120000:Mai6HlT8BOJKfbgv5iBOJw==:io+15LCEKFrOQnLPwlBnT1K7c2XgKkwIe0N5egf0GLY=', 'Student 169', 'student169@railtrack.local', '', 'Information Systems', 3.05, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 290, NULL, 1, 0),
(269, 'student170', '120000:KfHLp7NXwkqQvCc6bUPL1w==:9zq8YYGIqQDM1sKkzrY5NOkqsqQCgFghQR6WD4TIogg=', 'Student 170', 'student170@railtrack.local', '', 'Cyber Security', 2.15, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 281, NULL, 1, 0),
(270, 'student171', '120000:v48L5qZxKXbyd6INsK6v2Q==:6bHFDPD7djQ07XlWhrPxd9qpCn283JDg1HxZ6rQcAes=', 'Student 171', 'student171@railtrack.local', '', 'Software Engineering', 3.58, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 297, NULL, 1, 0),
(271, 'student172', '120000:EJoYhJIsJLwUwN0WoTIPQQ==:2gtnUio6omTBqO7Jr4rSf+2zrKgIa+8sBT2AJrrfSjY=', 'Student 172', 'student172@railtrack.local', '', 'Computer Science', 3.46, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 301, NULL, 1, 0),
(272, 'student173', '120000:0ywSUNq6l0UU2Sknax3XRQ==:AHzZ6FwPa9Ip54Q7tvmAHicc5xbprhUxic02fKI/d2Y=', 'Student 173', 'student173@railtrack.local', '', 'Information Technology', 2.58, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 299, NULL, 1, 0),
(273, 'student174', '120000:EHHjj2qTgkdD3Ccps2REAA==:HWQHTm6REx8tCSNlZ3SkBpYmjQr0pJUcb8SYhllrZu4=', 'Student 174', 'student174@railtrack.local', '', 'Information Systems', 2.49, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 297, NULL, 1, 0),
(274, 'student175', '120000:Xhu5k82dDhKLVheEmAWqqg==:RrTgBjnF+ngZqAilxEDPC8p+MhRifkMFr9s7RCKetP0=', 'Student 175', 'student175@railtrack.local', '', 'Cyber Security', 2.70, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 283, NULL, 1, 0),
(275, 'student176', '120000:9CgrgUNH/Q5XQ2CfOsvNHg==:QljPeC8Wh7KAaXDJlmEAOlEHGbkwM051LtQfvF6GxGQ=', 'Student 176', 'student176@railtrack.local', '', 'Software Engineering', 2.05, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 299, NULL, 1, 0),
(276, 'student177', '120000:7ti5IEUyraRG7egIxMriXw==:/2oi0t4/MyPX+U/wy+1kHycpi+/3CxYiYVeKQuy4xTQ=', 'Student 177', 'student177@railtrack.local', '', 'Computer Science', 2.14, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 207, NULL, 1, 0),
(277, 'student178', '120000:Pz+uHgFAp22KJmmyfjOSmw==:WcATbcgs4TwfAA4gWd4nCbeGLfkA6w/lCxajwEwMBfI=', 'Student 178', 'student178@railtrack.local', '', 'Information Technology', 2.57, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 296, NULL, 1, 0),
(278, 'student179', '120000:FKDNmoapX8bJxffB/kZauQ==:zJTxGc/9CPoVVFqPCjn8IdvbWMLDdFGoOGN93rz3lW8=', 'Student 179', 'student179@railtrack.local', '', 'Information Systems', 2.41, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 207, NULL, 1, 0),
(279, 'student180', '120000:BXPZ3bnz8g/f53MnoAjygg==:KyhBh35V//JfSsNdPIfPgDjykaIhq29u/ixCBYhpi4Q=', 'Student 180', 'student180@railtrack.local', '', 'Cyber Security', 2.33, 'STUDENT', 0, '2026-06-04 16:30:14', NULL, 293, NULL, 1, 0),
(280, 'supervisor001', '$2a$10$42Ea2IL5YHdx5eN5b5QuveZZ8gH84eoXRg99oeFjebEeFzYQbN7oO', 'Supervisor 001', 'supervisor001@railtrack.local', '', 'Software Engineering', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', '2026-06-18 06:02:27', NULL, NULL, 1, 0),
(281, 'supervisor002', '120000:fUlmpFn4FianzJ3v4mAJUQ==:iDbhBf7309CyiINUyxIbWZEwujpCHimVNG9lH4pEObg=', 'Supervisor 002', 'supervisor002@railtrack.local', '', 'Computer Science', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(282, 'supervisor003', '$2a$10$42Ea2IL5YHdx5eN5b5QuveZZ8gH84eoXRg99oeFjebEeFzYQbN7oO', 'Supervisor 003', 'supervisor003@railtrack.local', '', 'Information Technology', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', '2026-06-15 23:41:24', NULL, NULL, 1, 0),
(283, 'supervisor004', '120000:9I5sYFHCoIpmeH0FgjxGWQ==:F1tFxzQ0o7wBMu9JuVBscoPzXi4IX8nSHu2IS5pOOHE=', 'Supervisor 004', 'supervisor004@railtrack.local', '', 'Information Systems', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(284, 'supervisor005', '120000:IBKh41rtAt9PPtL7ZnySoQ==:X7BmfgNPOg6J11J706PD+mApzY8/hs+tOOFySJ+L+/o=', 'Supervisor 005', 'supervisor005@railtrack.local', '', 'Cyber Security', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(285, 'supervisor006', '120000:AU+n5Rovc1/X+CC1V8bEcQ==:z86TmORxY0sUIv25SACYHo5ULvlHEl6Rd1QUS1rA2uw=', 'Supervisor 006', 'supervisor006@railtrack.local', '', 'Software Engineering', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(286, 'supervisor007', '120000:4OvV/O8W5M2v7YVCfmvrfQ==:6MYSgRfZesQJoBL8gbOaVPDZUkZQ1mRB3mrgzM8nWOE=', 'Supervisor 007', 'supervisor007@railtrack.local', '', 'Computer Science', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(287, 'supervisor008', '120000:DIO69l/bfhjMTjEPCD2Gaw==:53RFrfPYdzL1emVKNnGyMH5kvK8twwtTUh10rOSC9x4=', 'Supervisor 008', 'supervisor008@railtrack.local', '', 'Information Technology', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(288, 'supervisor009', '120000:JpPSWwA0pL5qaJjDb+GeqQ==:DV9OxXxPqEQ8JH7Uz5gzZse02Lz4qKCcd3tduaj68m4=', 'Supervisor 009', 'supervisor009@railtrack.local', '', 'Information Systems', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(289, 'supervisor010', '120000:rKtDLlNlVh4WFYUmv6mQmg==:0JtqWpySe/RaHd+SHqSDn0ItMMsWc0IRrbHPrrPTCAQ=', 'Supervisor 010', 'supervisor010@railtrack.local', '', 'Cyber Security', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(290, 'supervisor011', '120000:aPTRsdZXoP6zfP4E5SM/iA==:h3qVEugKYT/DIsz7Q/hQGlDfZHn69lpqr7RMxAKJeaQ=', 'Supervisor 011', 'supervisor011@railtrack.local', '', 'Software Engineering', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(291, 'supervisor012', '120000:qW4z01gD+deEBFO4jIH4+g==:9WNFszpSNSTPAmU5Ap0q0Y1E0okXqqNLMLM4eK/ZsD4=', 'Supervisor 012', 'supervisor012@railtrack.local', '', 'Computer Science', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(292, 'supervisor013', '120000:MmlpVRTjUByeXFzs/D6TvA==:WqtB7Rl4UnxDtXtvNvAalArpYVfvL0Shi1dwCb9KnxA=', 'Supervisor 013', 'supervisor013@railtrack.local', '', 'Information Technology', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(293, 'supervisor014', '120000:PqlYP03md8rUL3kWD/NEJA==:i2Q+oB/nTQVfNZkMVTLYEK4h6nulaRXJS7xEXRje7mQ=', 'Supervisor 014', 'supervisor014@railtrack.local', '', 'Information Systems', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(294, 'supervisor015', '120000:vWkSx3ZUhhifNahIGitm2w==:Oc8xLOcH7n6G+PPo9N14Gpe5hYOCJy/4XuFkRiykHkE=', 'Supervisor 015', 'supervisor015@railtrack.local', '', 'Cyber Security', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(295, 'supervisor016', '120000:6WEkJhxFyjuo4Q1etjj4zg==:XrBUD4HJZqVIuuTTBHrWG8rmrjwdYfx19oIEoMYCGM8=', 'Supervisor 016', 'supervisor016@railtrack.local', '', 'Software Engineering', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(296, 'supervisor017', '120000:ZWCB7ao0v0fM+qvRvaawPA==:UgPFi4T1H6MqVrozKFt6wEn0i1ov2DySlLGezTB6fvY=', 'Supervisor 017', 'supervisor017@railtrack.local', '', 'Computer Science', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(297, 'supervisor018', '120000:qzEiVmJHNijhA3SVIaE1eg==:mtbGcZ4gGoMpRwxgLc8KEkxBag1UeJgz29yxwS5n4ns=', 'Supervisor 018', 'supervisor018@railtrack.local', '', 'Information Technology', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(298, 'supervisor019', '120000:8rOjOTY5edfd+HvnaCrp0g==:00Gfeuu9CsBrRUa2lDJTQ5aR6s5VO4QIA71I+qQYV7o=', 'Supervisor 019', 'supervisor019@railtrack.local', '', 'Information Systems', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(299, 'supervisor020', '120000:uzDXZPovTk1420mpgzSJ+A==:e13oZ7AT0mxJ5kjuikXw9xJoolIh8VQfPR31rKYdgNw=', 'Supervisor 020', 'supervisor020@railtrack.local', '', 'Cyber Security', NULL, 'SUPERVISOR', 0, '2026-06-04 16:30:14', NULL, NULL, NULL, 1, 0),
(301, 'sup_test1', '120000:HdeRNrL67iOUSc69cj9QJg==:bcX/g0Bi5UwhtuJDgDMLypDidyy7JkbgU2Yhwgzq47g=', 'Test Supervisor', 'sup_test1@railtrack.local', NULL, 'SMSK(KP)', NULL, 'SUPERVISOR', 0, '2026-06-07 16:20:49', '2026-06-07 16:21:01', NULL, NULL, 1, 0),
(302, 'coord_test1', '120000:YWrUPUjzPWpPsveeoulwng==:pKbFSwyYoHIE3FhcNZIkreUrNQRwh+JqHTnIAPM2qs0=', 'Test Coordinator', 'coord_test1@railtrack.local', NULL, 'SMSK(KP)', 3.21, 'STUDENT', 0, '2026-06-07 16:21:53', '2026-06-07 16:22:04', 292, NULL, 1, 0),
(303, 'adm_test1', '120000:hVR8Xgoex0Wc1csRZ7jy7A==:G+NG6RYu7+DNM2ACivsbpK0C3+dOvamIax63d23X2S0=', 'Test Admin', 'adm_test1@railtrack.local', NULL, 'SMSK(KP)', 2.73, 'STUDENT', 0, '2026-06-07 16:23:42', '2026-06-07 16:23:49', 288, NULL, 1, 0),
(304, 'sqli_test1', '120000:4IwVsE+uu7OalUdUJPDiPw==:B7pz8MpBSTOMiAUeat8Ayz2gMWykJ+Tidu0ttzWpVaw=', 'SQLi Test', 'sqli_test1@railtrack.local', NULL, 'SMSK(KP)\'; UPDATE users SET status = \'Active\' WHERE role = \'COORDINATOR\'; --', 4.00, 'STUDENT', 0, '2026-06-07 16:24:38', NULL, 283, NULL, 1, 0),
(305, 'sqli_test2', '120000:QTQ8K7/aomjCieBiq+hp8Q==:Jt4w8JJu1QQDtO5PKkEOT01FC3xWyusLvPhhpWjYRcg=', 'SQLi Test 2', 'sqli_test2@railtrack.local', NULL, 'SMSK(KP)\'; UPDATE users SET status = \'Active\' WHERE username = \'admin\'; --', 3.82, 'STUDENT', 0, '2026-06-07 16:25:20', NULL, 292, NULL, 1, 0),
(306, 'charlie_import_test', '120000:oYlMxa7zg3KqtflNXlrfbg==:KdsJBAecJoVrI4ll7Q7sAYVqBgtykL2Xsyv3fD6B2wU=', 'Charlie Import Test', 'charlie_import_test@railtrack.local', '', 'Computer Science', 3.75, 'STUDENT', 0, '2026-06-08 04:32:37', '2026-06-08 04:44:37', 281, NULL, 1, 0),
(308, 'muhdizzatamriahmad17', '120000:kkJCD9FUFdiD+O0W0Qg5Uw==:AmEnN9vAp6OkzyG9ECoXzPxXKhglHkLNRmJv2bxx9ss=', 'IzzatAhmad', 'muhdizzatamriahmad17@gmail.com', NULL, 'SMSK(KP)', NULL, 'STUDENT', 0, '2026-06-11 04:43:17', '2026-06-18 06:00:04', 280, NULL, 1, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_users_role` (`role`),
  ADD KEY `idx_users_active` (`active`),
  ADD KEY `fk_user_supervisor` (`supervisor_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=309;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_user_supervisor` FOREIGN KEY (`supervisor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

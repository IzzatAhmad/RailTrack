// Global mock database for the RailTrack prototype
const RT_MOCK_DATA = {
    users: [
        { id: 1, role: 'STUDENT', username: 'student1', fullName: 'Alice Johnson', email: 'alice.j@university.edu', avatar: 'A', studentId: '2022-8374' },
        { id: 2, role: 'STUDENT', username: 'student2', fullName: 'Bob Carter', email: 'bob.c@university.edu', avatar: 'B', studentId: '2022-9211' },
        { id: 3, role: 'SUPERVISOR', username: 'supervisor1', fullName: 'Dr. Sarah Smith', email: 'sarah.smith@university.edu', avatar: 'SS' },
        { id: 4, role: 'SUPERVISOR', username: 'supervisor2', fullName: 'Dr. James Anderson', email: 'j.anderson@university.edu', avatar: 'JA' },
        { id: 5, role: 'COORDINATOR', username: 'coordinator1', fullName: 'Prof. Helen Clark', email: 'helen.clark@university.edu', avatar: 'HC' }
    ],
    projects: [
        {
            id: 1,
            title: 'Smart Attendance System using Facial Recognition',
            description: 'A contactless attendance tracking system designed for university lecture rooms using mobile face scans and computer vision models.',
            repoUrl: 'https://github.com/alicej/smart-attendance',
            branch: 'main',
            status: 'ACTIVE', // PENDING, ACTIVE, UNDER_REVIEW, COMPLETED, REJECTED
            dockerStatus: 'running', // running, stopped, error, built, none
            runningLimitSeconds: 14400, // 4 hours
            overallGrade: 88.5,
            semester: '2024/2025-1',
            studentId: '2022-8374',
            studentName: 'Alice Johnson',
            supervisorId: 3,
            supervisorName: 'Dr. Sarah Smith',
            pita1Evaluators: [3, 4],
            pita2Evaluators: [4]
        },
        {
            id: 2,
            title: 'E-Commerce Analytics Engine',
            description: 'Real-time dashboard visualizer for sales metrics, user sessions, and inventory flow, leveraging BigQuery pipelines.',
            repoUrl: 'https://github.com/bobcarter/eco-analytics',
            branch: 'develop',
            status: 'PENDING',
            dockerStatus: 'none',
            runningLimitSeconds: 7200, // 2 hours
            overallGrade: null,
            semester: '2024/2025-1',
            studentId: '2022-9211',
            studentName: 'Bob Carter',
            supervisorId: null,
            supervisorName: null,
            pita1Evaluators: [],
            pita2Evaluators: []
        }
    ],
    milestones: [
        {
            projectId: 1,
            milestoneNo: 1,
            title: 'Project Proposal Submission',
            dueDate: '2026-04-15',
            status: 'APPROVED', // PENDING, SUBMITTED, APPROVED, REJECTED, OVERDUE
            grade: 90.0,
            weight: 15,
            description: 'Define the scope, hardware components, face detection libraries, and backend architecture.',
            studentComment: 'Submitted proposal document with system flowchart.',
            supervisorComment: 'Solid architectural proposal. Good detail on performance parameters.'
        },
        {
            projectId: 1,
            milestoneNo: 2,
            title: 'Mid-Term Progress Report & Dockerfile Setup',
            dueDate: '2026-05-20',
            status: 'APPROVED',
            grade: 87.0,
            weight: 35,
            description: 'Implement face extraction models, connect to PostgreSQL DB, containerize app, and run it locally.',
            studentComment: 'Dockerfile works, models loaded on CPU. Connected logbook tracker.',
            supervisorComment: 'Excellent progress. Make sure the container limits memory usage.'
        },
        {
            projectId: 1,
            milestoneNo: 3,
            title: 'PITA-01 Technical Demonstration',
            dueDate: '2026-06-12',
            status: 'SUBMITTED',
            grade: null,
            weight: 25,
            description: 'Deploy on RailTrack environment, demo live container logs, and test model accuracy.',
            studentComment: 'Container is deployed and running at port 8080. Evaluators can view live.',
            supervisorComment: ''
        },
        {
            projectId: 1,
            milestoneNo: 4,
            title: 'Final Dissertation & Code Delivery',
            dueDate: '2026-07-05',
            status: 'PENDING',
            grade: null,
            weight: 25,
            description: 'Submit the final academic report, testing methodologies, and final code repository.',
            studentComment: '',
            supervisorComment: ''
        }
    ],
    feedbacks: [
        {
            projectId: 1,
            authorName: 'Dr. Sarah Smith',
            type: 'GENERAL', // GENERAL, FINAL_EVAL
            content: 'Please look into OpenCV Cascade classifier limitations. Deep neural networks (like MTCNN) are more robust.',
            createdAt: '2026-05-18'
        },
        {
            projectId: 1,
            authorName: 'Dr. Sarah Smith',
            type: 'GENERAL',
            content: 'Great implementation on Docker setup. Container responds within 120ms.',
            createdAt: '2026-05-22'
        }
    ],
    logbooks: [
        { projectId: 1, week: 1, hours: 8, description: 'Researched face-recognition algorithms (LBPH vs Deep Learning). Chosen FaceNet.', status: 'APPROVED', feedback: 'Good choice.' },
        { projectId: 1, week: 2, hours: 10, description: 'Created SQLite data models and wrote scripts for batch image uploads.', status: 'APPROVED', feedback: 'Ensure schema constraints are set.' },
        { projectId: 1, week: 3, hours: 12, description: 'Coded face alignment module using MTCNN. Encountered high processing delays.', status: 'APPROVED', feedback: 'Optimize image resizing.' },
        { projectId: 1, week: 4, hours: 6, description: 'Added logs stream via Server-Sent Events (SSE) and tested on local Docker.', status: 'SUBMITTED', feedback: '' }
    ],
    documents: [
        { projectId: 1, docType: 'Proposal', fileName: 'Proposal_Alice_Johnson_v2.pdf', uploadedAt: '2026-04-12', status: 'APPROVED', grade: 90 },
        { projectId: 1, docType: 'Midterm', fileName: 'Midterm_Alice_Johnson_Final.pdf', uploadedAt: '2026-05-18', status: 'APPROVED', grade: 87 },
        { projectId: 1, docType: 'PITA-01', fileName: 'PITA_Evaluation_v1.pdf', uploadedAt: '2026-06-09', status: 'SUBMITTED', grade: null }
    ],
    materials: [
        { id: 1, title: 'Final Year Project Handbook (2025/2026)', type: 'PDF', size: '1.2 MB', uploadedBy: 'Helen Clark', date: '2026-03-01' },
        { id: 2, title: 'RailTrack Docker Deployment Guide', type: 'PDF', size: '840 KB', uploadedBy: 'Helen Clark', date: '2026-03-15' },
        { id: 3, title: 'PITA Evaluation Form Rubric Template', type: 'DOCX', size: '145 KB', uploadedBy: 'Sarah Smith', date: '2026-04-02' }
    ],
    menuItems: [
        { id: 1, label: 'My Project', url: '#/student/project/1', icon: 'bi bi-kanban', iconColor: '#2563eb' },
        { id: 2, label: 'Logbook Journal', url: '#/student/logbook', icon: 'bi bi-book', iconColor: '#16a34a' },
        { id: 3, label: 'Submissions', url: '#/student/documents', icon: 'bi bi-cloud-arrow-up', iconColor: '#eab308' },
        { id: 4, label: 'Rubrics Guide', url: '#/student/rubrics', icon: 'bi bi-journal-bookmark', iconColor: '#8b5cf6' }
    ],
    deployLogs: [
        { projectId: 1, action: 'BUILD', outcome: 'success', performedByName: 'Alice Johnson', performedAt: '2026-06-08T10:14:00' },
        { projectId: 1, action: 'START', outcome: 'success', performedByName: 'Alice Johnson', performedAt: '2026-06-08T10:15:00' },
        { projectId: 1, action: 'STOP', outcome: 'success', performedByName: 'Dr. Sarah Smith', performedAt: '2026-06-09T18:30:00' },
        { projectId: 1, action: 'START', outcome: 'success', performedByName: 'Alice Johnson', performedAt: '2026-06-10T09:00:00' }
    ],
    globalRequirements: [
        { id: 1, title: 'Project Proposal', weight: 15, dueDate: '2026-04-20', description: 'Initial scope assessment and requirements validation.' },
        { id: 2, title: 'Mid-term Assessment Report', weight: 35, dueDate: '2026-05-25', description: 'Comprehensive design review and dockerization check.' },
        { id: 3, title: 'PITA-01 Evaluation (Draft & Demo)', weight: 25, dueDate: '2026-06-15', description: 'Functional deployment testing, test logs, code standard check.' },
        { id: 4, title: 'Final Thesis & Oral Presentation', weight: 25, dueDate: '2026-07-10', description: 'Written dissertation submission and panel review.' }
    ]
};

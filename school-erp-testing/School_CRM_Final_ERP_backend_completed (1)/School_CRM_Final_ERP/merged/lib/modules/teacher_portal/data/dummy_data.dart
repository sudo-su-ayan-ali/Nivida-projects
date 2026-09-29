import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../theme/app_colors.dart';

/// Seed / dummy data. AppState clones these lists into mutable state on
/// startup — swap this file for a real API layer when wiring a backend.
class DummyData {
  DummyData._();

  static const List<String> weekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<double> attendanceWeek = [92, 88, 78, 85, 84, 96, 96];

  static const List<ClassSlice> classSlices = [
    ClassSlice(name: 'Class 10-A', students: 32, color: AppColors.primary),
    ClassSlice(name: 'Class 9-B', students: 28, color: AppColors.blue),
    ClassSlice(name: 'Class 8-A', students: 34, color: AppColors.green),
    ClassSlice(name: 'Class 7-C', students: 34, color: AppColors.orange),
  ];

  /// Full week timetable — Today's Schedule + the Timetable page both read
  /// from this so there's a single source of truth.
  static final Map<String, List<ScheduleItem>> weekTimetable = {
    'Mon': const [
      ScheduleItem(time: '08:00 AM', className: 'Class 10-A', subject: 'Mathematics', room: 'Room 301', status: ScheduleStatus.completed),
      ScheduleItem(time: '09:00 AM', className: 'Class 9-B', subject: 'Mathematics', room: 'Room 302', status: ScheduleStatus.completed),
      ScheduleItem(time: '10:00 AM', className: 'Class 8-A', subject: 'Mathematics', room: 'Room 303', status: ScheduleStatus.ongoing),
      ScheduleItem(time: '11:00 AM', className: 'Class 7-C', subject: 'Mathematics', room: 'Room 304', status: ScheduleStatus.upcoming),
      ScheduleItem(time: '01:00 PM', className: 'Class 10-A', subject: 'Doubt Clearing', room: 'Room 301', status: ScheduleStatus.upcoming),
    ],
    'Tue': const [
      ScheduleItem(time: '08:00 AM', className: 'Class 9-B', subject: 'Mathematics', room: 'Room 302', status: ScheduleStatus.upcoming),
      ScheduleItem(time: '09:30 AM', className: 'Class 10-A', subject: 'Mathematics', room: 'Room 301', status: ScheduleStatus.upcoming),
      ScheduleItem(time: '11:00 AM', className: 'Class 8-A', subject: 'Mathematics', room: 'Room 303', status: ScheduleStatus.upcoming),
    ],
    'Wed': const [
      ScheduleItem(time: '08:00 AM', className: 'Class 7-C', subject: 'Mathematics', room: 'Room 304', status: ScheduleStatus.upcoming),
      ScheduleItem(time: '09:00 AM', className: 'Class 10-A', subject: 'Mathematics', room: 'Room 301', status: ScheduleStatus.upcoming),
      ScheduleItem(time: '10:00 AM', className: 'Class 9-B', subject: 'Mathematics', room: 'Room 302', status: ScheduleStatus.upcoming),
      ScheduleItem(time: '12:00 PM', className: 'Class 8-A', subject: 'Mathematics', room: 'Room 303', status: ScheduleStatus.upcoming),
    ],
    'Thu': const [
      ScheduleItem(time: '08:00 AM', className: 'Class 10-A', subject: 'Mathematics', room: 'Room 301', status: ScheduleStatus.upcoming),
      ScheduleItem(time: '09:00 AM', className: 'Class 8-A', subject: 'Mathematics', room: 'Room 303', status: ScheduleStatus.upcoming),
      ScheduleItem(time: '10:30 AM', className: 'Class 7-C', subject: 'Mathematics', room: 'Room 304', status: ScheduleStatus.upcoming),
    ],
    'Fri': const [
      ScheduleItem(time: '08:00 AM', className: 'Class 9-B', subject: 'Mathematics', room: 'Room 302', status: ScheduleStatus.upcoming),
      ScheduleItem(time: '09:00 AM', className: 'Class 10-A', subject: 'Unit Test', room: 'Room 301', status: ScheduleStatus.upcoming),
      ScheduleItem(time: '11:00 AM', className: 'Class 8-A', subject: 'Mathematics', room: 'Room 303', status: ScheduleStatus.upcoming),
      ScheduleItem(time: '12:30 PM', className: 'Class 7-C', subject: 'Mathematics', room: 'Room 304', status: ScheduleStatus.upcoming),
    ],
    'Sat': const [
      ScheduleItem(time: '09:00 AM', className: 'Class 10-A', subject: 'Remedial Class', room: 'Room 301', status: ScheduleStatus.upcoming),
    ],
    'Sun': const [],
  };

  static List<StudentItem> seedStudents() => [
        StudentItem(id: 's1', name: 'Rahul Verma', className: 'Class 10-A', score: 85, avatarSeed: 'Rahul', email: 'rahul.verma@stu.edusmart.school', phone: '+91 90000 00001'),
        StudentItem(id: 's2', name: 'Ananya Singh', className: 'Class 10-A', score: 78, avatarSeed: 'Ananya', email: 'ananya.singh@stu.edusmart.school', phone: '+91 90000 00002'),
        StudentItem(id: 's3', name: 'Vikram Mehta', className: 'Class 9-B', score: 65, avatarSeed: 'Vikram', email: 'vikram.mehta@stu.edusmart.school', phone: '+91 90000 00003'),
        StudentItem(id: 's4', name: 'Kavya Joshi', className: 'Class 8-A', score: 60, avatarSeed: 'Kavya', email: 'kavya.joshi@stu.edusmart.school', phone: '+91 90000 00004'),
        StudentItem(id: 's5', name: 'Arjun Patel', className: 'Class 7-C', score: 55, avatarSeed: 'Arjun', email: 'arjun.patel@stu.edusmart.school', phone: '+91 90000 00005'),
        StudentItem(id: 's6', name: 'Rohan Das', className: 'Class 10-A', score: 42, avatarSeed: 'Rohan', email: 'rohan.das@stu.edusmart.school', phone: '+91 90000 00006'),
        StudentItem(id: 's7', name: 'Meera Nair', className: 'Class 9-B', score: 45, avatarSeed: 'Meera', email: 'meera.nair@stu.edusmart.school', phone: '+91 90000 00007'),
        StudentItem(id: 's8', name: 'Karan Shah', className: 'Class 8-A', score: 48, avatarSeed: 'Karan', email: 'karan.shah@stu.edusmart.school', phone: '+91 90000 00008'),
        StudentItem(id: 's9', name: 'Priya Roy', className: 'Class 7-C', score: 40, avatarSeed: 'Priya2', email: 'priya.roy@stu.edusmart.school', phone: '+91 90000 00009'),
        StudentItem(id: 's10', name: 'Aditya Kumar', className: 'Class 10-A', score: 44, avatarSeed: 'Aditya', email: 'aditya.kumar@stu.edusmart.school', phone: '+91 90000 00010'),
        StudentItem(id: 's11', name: 'Ishaan Gupta', className: 'Class 9-B', score: 91, avatarSeed: 'Ishaan', email: 'ishaan.gupta@stu.edusmart.school', phone: '+91 90000 00011'),
        StudentItem(id: 's12', name: 'Sneha Reddy', className: 'Class 8-A', score: 88, avatarSeed: 'Sneha', email: 'sneha.reddy@stu.edusmart.school', phone: '+91 90000 00012'),
      ];

  static List<AssignmentItem> seedAssignments() => [
        AssignmentItem(id: 'a1', icon: Icons.description_outlined, color: AppColors.purple, bgColor: AppColors.purpleBg, title: 'Algebra Basics Worksheet', className: 'Class 10-A', dueDate: '15 May 2026', pendingCount: 28, totalCount: 32),
        AssignmentItem(id: 'a2', icon: Icons.functions_outlined, color: AppColors.blue, bgColor: AppColors.blueBg, title: 'Linear Equations Quiz', className: 'Class 9-B', dueDate: '14 May 2026', pendingCount: 18, totalCount: 28),
        AssignmentItem(id: 'a3', icon: Icons.calculate_outlined, color: AppColors.pink, bgColor: AppColors.pinkBg, title: 'Math Problem Set', className: 'Class 8-A', dueDate: '16 May 2026', pendingCount: 32, totalCount: 34),
        AssignmentItem(id: 'a4', icon: Icons.menu_book_outlined, color: AppColors.green, bgColor: AppColors.greenBg, title: 'Chapter 5 Exercise', className: 'Class 7-C', dueDate: '17 May 2026', pendingCount: 24, totalCount: 34),
      ];

  static List<ExamItem> seedExams() => [
        ExamItem(id: 'e1', icon: Icons.assignment_turned_in_outlined, color: AppColors.purple, bgColor: AppColors.purpleBg, title: 'Mid Term Exam', className: 'Class 10-A', subject: 'Mathematics', date: '20 May 2026'),
        ExamItem(id: 'e2', icon: Icons.edit_note_outlined, color: AppColors.blue, bgColor: AppColors.blueBg, title: 'Unit Test - 2', className: 'Class 9-B', subject: 'Mathematics', date: '22 May 2026'),
        ExamItem(id: 'e3', icon: Icons.fact_check_outlined, color: AppColors.green, bgColor: AppColors.greenBg, title: 'Monthly Test', className: 'Class 8-A', subject: 'Mathematics', date: '25 May 2026'),
        ExamItem(id: 'e4', icon: Icons.quiz_outlined, color: AppColors.pink, bgColor: AppColors.pinkBg, title: 'Surprise Test', className: 'Class 7-C', subject: 'Mathematics', date: '28 May 2026'),
      ];

  static List<MessageItem> seedMessages() => [
        MessageItem(id: 'm1', icon: Icons.send_outlined, color: AppColors.blue, bgColor: AppColors.blueBg, title: 'Message to Class 10-A', meta: 'Homework reminder for tomorrow', time: '10:15 AM'),
        MessageItem(id: 'm2', icon: Icons.send_outlined, color: AppColors.purple, bgColor: AppColors.purpleBg, title: 'Message to Class 9-B', meta: 'Quiz schedule for this week', time: 'Yesterday'),
        MessageItem(id: 'm3', icon: Icons.family_restroom_outlined, color: AppColors.orange, bgColor: AppColors.orangeBg, title: 'Message to Parents', meta: 'PTM on 18th May', time: '2 Days Ago', unread: true),
        MessageItem(id: 'm4', icon: Icons.campaign_outlined, color: AppColors.teal, bgColor: AppColors.tealBg, title: 'Announcement', meta: 'School will remain closed on 15th May', time: '3 Days Ago', unread: true),
        MessageItem(id: 'm5', icon: Icons.forum_outlined, color: AppColors.pink, bgColor: AppColors.pinkBg, title: 'Principal Office', meta: 'Submit monthly report by Friday', time: '4 Days Ago', unread: true),
      ];

  static List<NotificationItem> seedNotifications() => [
        NotificationItem(id: 'n1', icon: Icons.assignment_turned_in_outlined, color: AppColors.green, bgColor: AppColors.greenBg, title: '28 submissions received', subtitle: 'Algebra Basics Worksheet • Class 10-A', time: '10 min ago'),
        NotificationItem(id: 'n2', icon: Icons.event_note_outlined, color: AppColors.pink, bgColor: AppColors.pinkBg, title: 'Mid Term Exam scheduled', subtitle: 'Class 10-A • 20 May 2026', time: '1 hr ago'),
        NotificationItem(id: 'n3', icon: Icons.family_restroom_outlined, color: AppColors.orange, bgColor: AppColors.orangeBg, title: 'New message from parent', subtitle: "Rohan Das's guardian replied", time: '3 hr ago'),
        NotificationItem(id: 'n4', icon: Icons.how_to_reg_outlined, color: AppColors.blue, bgColor: AppColors.blueBg, title: 'Attendance reminder', subtitle: 'Class 8-A attendance not marked yet', time: 'Yesterday'),
        NotificationItem(id: 'n5', icon: Icons.campaign_outlined, color: AppColors.teal, bgColor: AppColors.tealBg, title: 'School holiday notice', subtitle: 'School closed on 15th May', time: '2 days ago', read: true),
        NotificationItem(id: 'n6', icon: Icons.workspace_premium_rounded, color: const Color(0xFFC98A0A), bgColor: AppColors.yellowBg, title: 'New feature unlocked', subtitle: 'Analytics dashboard is now live', time: '3 days ago', read: true),
        NotificationItem(id: 'n7', icon: Icons.grading_outlined, color: AppColors.purple, bgColor: AppColors.purpleBg, title: 'Grading pending', subtitle: 'Linear Equations Quiz • Class 9-B', time: '4 days ago', read: true),
      ];

  static List<ResourceItem> seedStudyMaterials() => [
        ResourceItem(id: 'sm1', icon: Icons.picture_as_pdf_outlined, color: AppColors.red, bgColor: AppColors.redBg, title: 'Algebra Fundamentals.pdf', subtitle: 'Class 10-A • 2.4 MB'),
        ResourceItem(id: 'sm2', icon: Icons.slideshow_outlined, color: AppColors.orange, bgColor: AppColors.orangeBg, title: 'Trigonometry Slides.pptx', subtitle: 'Class 9-B • 5.1 MB'),
        ResourceItem(id: 'sm3', icon: Icons.movie_outlined, color: AppColors.purple, bgColor: AppColors.purpleBg, title: 'Geometry Explained.mp4', subtitle: 'Class 8-A • 48 MB'),
      ];

  static List<ResourceItem> seedQuestionBank() => [
        ResourceItem(id: 'qb1', icon: Icons.quiz_outlined, color: AppColors.blue, bgColor: AppColors.blueBg, title: 'Algebra — 25 MCQs', subtitle: 'Difficulty: Medium'),
        ResourceItem(id: 'qb2', icon: Icons.functions_outlined, color: AppColors.green, bgColor: AppColors.greenBg, title: 'Trigonometry — 18 Questions', subtitle: 'Difficulty: Hard'),
      ];

  static List<ResourceItem> seedLibrary() => [
        ResourceItem(id: 'lib1', icon: Icons.menu_book_outlined, color: AppColors.teal, bgColor: AppColors.tealBg, title: 'NCERT Class 10 Maths', subtitle: 'Reference textbook'),
        ResourceItem(id: 'lib2', icon: Icons.auto_stories_outlined, color: AppColors.pink, bgColor: AppColors.pinkBg, title: 'RD Sharma — Class 9', subtitle: 'Reference textbook'),
        ResourceItem(id: 'lib3', icon: Icons.local_library_outlined, color: AppColors.purple, bgColor: AppColors.purpleBg, title: 'Previous Year Papers', subtitle: '2019 – 2025'),
      ];

  static List<LessonPlanItem> seedLessonPlans() => [
        LessonPlanItem(id: 'lp1', title: 'Introduction to Quadratic Equations', className: 'Class 10-A', date: '15 May 2026'),
        LessonPlanItem(id: 'lp2', title: 'Basics of Trigonometric Ratios', className: 'Class 9-B', date: '16 May 2026'),
      ];

  static const List<ActionTile> teachingResources = [
    ActionTile(id: 'study_materials', icon: Icons.file_download_outlined, label: 'Study Materials', sub: 'Upload & Manage'),
    ActionTile(id: 'question_bank', icon: Icons.quiz_outlined, label: 'Question Bank', sub: 'Create & Share'),
    ActionTile(id: 'library', icon: Icons.local_library_outlined, label: 'Library', sub: 'Access Resources'),
  ];

  static const List<ActionTile> quickActions = [
    ActionTile(id: 'take_attendance', icon: Icons.how_to_reg_outlined, label: 'Take Attendance'),
    ActionTile(id: 'create_assignment', icon: Icons.edit_document, label: 'Create Assignment'),
    ActionTile(id: 'upload_material', icon: Icons.drive_folder_upload_outlined, label: 'Upload Material'),
    ActionTile(id: 'schedule_test', icon: Icons.event_available_outlined, label: 'Schedule Test'),
    ActionTile(id: 'record_marks', icon: Icons.grading_outlined, label: 'Record Marks'),
    ActionTile(id: 'send_message', icon: Icons.mail_outline, label: 'Send Message'),
    ActionTile(id: 'leave_request', icon: Icons.notifications_active_outlined, label: 'Leave Request'),
  ];

  static const List<ActionTile> otherTools = [
    ActionTile(id: 'grade_book', icon: Icons.book_outlined, label: 'Grade Book', sub: 'Manage Grades'),
    ActionTile(id: 'lesson_plan', icon: Icons.auto_stories_outlined, label: 'Lesson Plan', sub: 'Create Plan'),
    ActionTile(id: 'syllabus', icon: Icons.checklist_rtl_outlined, label: 'Syllabus Tracker', sub: 'Track Progress'),
    ActionTile(id: 'seating', icon: Icons.grid_view_outlined, label: 'Seating Chart', sub: 'Arrange Classroom'),
    ActionTile(id: 'substitute', icon: Icons.assignment_ind_outlined, label: 'Substitute Note', sub: 'Handoff Summary'),
    ActionTile(id: 'ptm', icon: Icons.groups_2_outlined, label: 'PTM Scheduler', sub: 'Book Meetings'),
    ActionTile(id: 'calendar', icon: Icons.calendar_month_outlined, label: 'Calendar', sub: 'Weekly Timetable'),
    ActionTile(id: 'homework', icon: Icons.assignment_turned_in_outlined, label: 'Homework Tracker', sub: 'Submission Status'),
    ActionTile(id: 'online_class', icon: Icons.video_call_outlined, label: 'Online Classes', sub: 'Zoom / Meet Links'),
    ActionTile(id: 'fees', icon: Icons.receipt_long_outlined, label: 'Fee Status', sub: 'Dues & Reminders'),
    ActionTile(id: 'notice_board', icon: Icons.campaign_outlined, label: 'Notice Board', sub: 'Broadcast Notices'),
    ActionTile(id: 'academic_calendar', icon: Icons.calendar_today_outlined, label: 'Academic Calendar', sub: 'Holidays & Events'),
    ActionTile(id: 'settings', icon: Icons.settings_outlined, label: 'Settings', sub: 'Manage Profile'),
  ];

  static Map<String, List<AssessmentRecord>> seedGradebook(List<StudentItem> students) {
    final map = <String, List<AssessmentRecord>>{};
    const categories = ['Unit Test', 'Assignment', 'Quiz'];
    for (final s in students) {
      map[s.id] = [
        AssessmentRecord(id: '${s.id}-gr1', title: 'Unit Test 1', category: categories[0], maxMarks: 50, obtained: (s.score * 0.5).clamp(0, 50).toDouble(), date: '10 Apr 2026'),
        AssessmentRecord(id: '${s.id}-gr2', title: 'Homework Set 1', category: categories[1], maxMarks: 20, obtained: (s.score * 0.2).clamp(0, 20).toDouble(), date: '18 Apr 2026'),
        AssessmentRecord(id: '${s.id}-gr3', title: 'Pop Quiz', category: categories[2], maxMarks: 10, obtained: (s.score * 0.1).clamp(0, 10).toDouble(), date: '25 Apr 2026'),
      ];
    }
    return map;
  }

  static List<SyllabusChapter> seedSyllabus() => [
        SyllabusChapter(id: 'syl1', className: 'Class 10-A', subject: 'Mathematics', title: 'Real Numbers', totalTopics: 5, completedTopics: 5),
        SyllabusChapter(id: 'syl2', className: 'Class 10-A', subject: 'Mathematics', title: 'Polynomials', totalTopics: 4, completedTopics: 3),
        SyllabusChapter(id: 'syl3', className: 'Class 10-A', subject: 'Mathematics', title: 'Quadratic Equations', totalTopics: 6, completedTopics: 1),
        SyllabusChapter(id: 'syl4', className: 'Class 9-B', subject: 'Mathematics', title: 'Number Systems', totalTopics: 4, completedTopics: 4),
        SyllabusChapter(id: 'syl5', className: 'Class 9-B', subject: 'Mathematics', title: 'Coordinate Geometry', totalTopics: 3, completedTopics: 1),
        SyllabusChapter(id: 'syl6', className: 'Class 8-A', subject: 'Mathematics', title: 'Rational Numbers', totalTopics: 4, completedTopics: 2),
        SyllabusChapter(id: 'syl7', className: 'Class 7-C', subject: 'Mathematics', title: 'Integers', totalTopics: 3, completedTopics: 3),
      ];

  static List<PTMSlot> seedPtmSlots() => [
        PTMSlot(id: 'ptm1', date: '18 May 2026', time: '10:00 AM'),
        PTMSlot(id: 'ptm2', date: '18 May 2026', time: '10:30 AM', parentName: "Rohan Das's Guardian", studentName: 'Rohan Das'),
        PTMSlot(id: 'ptm3', date: '18 May 2026', time: '11:00 AM'),
        PTMSlot(id: 'ptm4', date: '18 May 2026', time: '11:30 AM'),
      ];

  static List<TodoItem> seedTodos() => [
        TodoItem(id: 'td1', title: 'Grade pending Unit 2 quizzes'),
        TodoItem(id: 'td2', title: 'Prepare PTM notes for Class 10-A'),
        TodoItem(id: 'td3', title: 'Submit monthly attendance report', done: true),
      ];
}

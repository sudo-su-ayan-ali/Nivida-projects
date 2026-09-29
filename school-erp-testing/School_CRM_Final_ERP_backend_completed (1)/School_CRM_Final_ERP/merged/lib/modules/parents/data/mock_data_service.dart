import 'package:flutter/material.dart';
import '../models/models.dart';
import '../core/theme/app_colors.dart';

/// Single source of truth for demo data. In a real app this would be
/// replaced by repository classes calling a REST/GraphQL API.
class MockDataService {
  MockDataService._();
  static final MockDataService instance = MockDataService._();

  final String schoolName = 'Greenfield Public School';
  final String academicSession = '2024-25';

  List<ChildRecord> children() {
    final now = DateTime.now();
    return [
      ChildRecord(
        student: const Student(
          id: 'stu_rahul',
          name: 'Rahul Sharma',
          className: '10-A',
          rollNo: '12',
          avatarInitials: 'RS',
          avatarColor: AppColors.primary,
        ),
        attendance: AttendanceSummary(
          presentDays: 23,
          lateDays: 1,
          absentDays: 1,
          history: List.generate(25, (i) {
            final day = now.subtract(Duration(days: 25 - i));
            final status = i == 5
                ? AttendanceStatus.absent
                : i == 12
                    ? AttendanceStatus.late
                    : AttendanceStatus.present;
            return AttendanceDay(date: day, status: status);
          }),
        ),
        academics: const AcademicSummary(
          term: 'Term 2, 2024-25',
          overallGrade: 'A',
          subjects: [
            SubjectGrade(subject: 'Maths', grade: 'A+', score: 94),
            SubjectGrade(subject: 'Science', grade: 'A', score: 88),
            SubjectGrade(subject: 'English', grade: 'A', score: 86),
            SubjectGrade(subject: 'Social Studies', grade: 'A-', score: 82),
          ],
        ),
        fees: FeeSummary(
          totalFees: 45000,
          paidAmount: 39800,
          installments: [
            FeeInstallment(
                label: 'Term 1 Installment',
                amount: 22500,
                paid: true,
                dueDate: DateTime(now.year, 7, 10)),
            FeeInstallment(
                label: 'Term 2 Installment',
                amount: 17300,
                paid: true,
                dueDate: DateTime(now.year, 11, 10)),
            FeeInstallment(
                label: 'Term 3 Installment',
                amount: 5200,
                paid: false,
                dueDate: DateTime(now.year, now.month, now.day + 6)),
          ],
        ),
        homework: [
          HomeworkItem(
              id: 'hw1',
              subject: 'Maths',
              title: 'Quadratic Equations Worksheet',
              dueDate: now.add(const Duration(days: 2)),
              submitted: false),
          HomeworkItem(
              id: 'hw2',
              subject: 'English',
              title: 'Essay: My Favourite Season',
              dueDate: now.add(const Duration(days: 4)),
              submitted: false),
          HomeworkItem(
              id: 'hw3',
              subject: 'Science',
              title: 'Lab Report - Photosynthesis',
              dueDate: now.subtract(const Duration(days: 1)),
              submitted: true),
        ],
        exams: [
          ExamItem(
              id: 'ex1',
              subject: 'Mathematics',
              date: now.add(const Duration(days: 10)),
              time: '09:00 AM - 11:00 AM',
              room: 'Room 204'),
          ExamItem(
              id: 'ex2',
              subject: 'Science',
              date: now.add(const Duration(days: 12)),
              time: '09:00 AM - 11:00 AM',
              room: 'Room 204'),
          ExamItem(
              id: 'ex3',
              subject: 'English',
              date: now.add(const Duration(days: 14)),
              time: '09:00 AM - 11:00 AM',
              room: 'Room 204'),
        ],
        timetable: const [
          TimetableSlot(day: 'Mon', time: '09:00 - 09:45', subject: 'Maths', teacher: 'Ms. Priya Verma'),
          TimetableSlot(day: 'Mon', time: '09:45 - 10:30', subject: 'Science', teacher: 'Mr. Amit Kumar'),
          TimetableSlot(day: 'Tue', time: '09:00 - 09:45', subject: 'English', teacher: 'Ms. Neha Singh'),
          TimetableSlot(day: 'Tue', time: '09:45 - 10:30', subject: 'Social Studies', teacher: 'Mr. Rakesh Jain'),
          TimetableSlot(day: 'Wed', time: '09:00 - 09:45', subject: 'Maths', teacher: 'Ms. Priya Verma'),
        ],
        transport: const TransportInfo(
          routeName: 'Route 4 - North Zone',
          busNumber: 'RJ-19-BS-4521',
          driverName: 'Mr. Suresh Yadav',
          driverPhone: '+91 98290 11234',
          pickupPoint: 'Shastri Nagar Circle',
          pickupTime: '07:15 AM',
          dropTime: '02:40 PM',
        ),
        library: [
          LibraryBook(
              title: 'A Brief History of Time',
              author: 'Stephen Hawking',
              issuedOn: now.subtract(const Duration(days: 10)),
              dueOn: now.add(const Duration(days: 4)),
              returned: false),
          LibraryBook(
              title: 'Panchatantra Tales',
              author: 'Vishnu Sharma',
              issuedOn: now.subtract(const Duration(days: 30)),
              dueOn: now.subtract(const Duration(days: 16)),
              returned: true),
        ],
      ),
      ChildRecord(
        student: const Student(
          id: 'stu_ananya',
          name: 'Ananya Sharma',
          className: '7-B',
          rollNo: '28',
          avatarInitials: 'AS',
          avatarColor: AppColors.secondary,
        ),
        attendance: AttendanceSummary(
          presentDays: 21,
          lateDays: 2,
          absentDays: 2,
          history: List.generate(25, (i) {
            final day = now.subtract(Duration(days: 25 - i));
            final status = i == 3 || i == 18
                ? AttendanceStatus.absent
                : i == 7 || i == 20
                    ? AttendanceStatus.late
                    : AttendanceStatus.present;
            return AttendanceDay(date: day, status: status);
          }),
        ),
        academics: const AcademicSummary(
          term: 'Term 2, 2024-25',
          overallGrade: 'B+',
          subjects: [
            SubjectGrade(subject: 'Maths', grade: 'B+', score: 79),
            SubjectGrade(subject: 'Science', grade: 'A-', score: 84),
            SubjectGrade(subject: 'English', grade: 'B+', score: 78),
            SubjectGrade(subject: 'Social Studies', grade: 'B', score: 75),
          ],
        ),
        fees: FeeSummary(
          totalFees: 38000,
          paidAmount: 38000,
          installments: [
            FeeInstallment(
                label: 'Term 1 Installment',
                amount: 19000,
                paid: true,
                dueDate: DateTime(now.year, 7, 10)),
            FeeInstallment(
                label: 'Term 2 Installment',
                amount: 19000,
                paid: true,
                dueDate: DateTime(now.year, 11, 10)),
          ],
        ),
        homework: [
          HomeworkItem(
              id: 'hw4',
              subject: 'Science',
              title: 'Project: Solar System Model',
              dueDate: now.add(const Duration(days: 6)),
              submitted: false),
          HomeworkItem(
              id: 'hw5',
              subject: 'Maths',
              title: 'Fractions Practice Sheet',
              dueDate: now.add(const Duration(days: 1)),
              submitted: false),
        ],
        exams: [
          ExamItem(
              id: 'ex4',
              subject: 'Mathematics',
              date: now.add(const Duration(days: 11)),
              time: '10:00 AM - 12:00 PM',
              room: 'Room 108'),
          ExamItem(
              id: 'ex5',
              subject: 'Science',
              date: now.add(const Duration(days: 13)),
              time: '10:00 AM - 12:00 PM',
              room: 'Room 108'),
        ],
        timetable: const [
          TimetableSlot(day: 'Mon', time: '09:00 - 09:45', subject: 'Science', teacher: 'Mr. Amit Kumar'),
          TimetableSlot(day: 'Mon', time: '09:45 - 10:30', subject: 'Maths', teacher: 'Ms. Kavita Rao'),
          TimetableSlot(day: 'Tue', time: '09:00 - 09:45', subject: 'English', teacher: 'Ms. Neha Singh'),
        ],
        transport: const TransportInfo(
          routeName: 'Route 2 - East Zone',
          busNumber: 'RJ-19-BS-3310',
          driverName: 'Mr. Manoj Chauhan',
          driverPhone: '+91 98290 55678',
          pickupPoint: 'Ratanada Chowk',
          pickupTime: '07:05 AM',
          dropTime: '02:25 PM',
        ),
        library: [
          LibraryBook(
              title: 'Malgudi Days',
              author: 'R. K. Narayan',
              issuedOn: now.subtract(const Duration(days: 5)),
              dueOn: now.add(const Duration(days: 9)),
              returned: false),
        ],
      ),
    ];
  }

  List<Notice> notices() {
    final now = DateTime.now();
    return [
      Notice(
        id: 'n1',
        title: 'Annual Sports Day',
        description: 'Sports day will be held on 25th May 2026.',
        postedAt: now.subtract(const Duration(hours: 2)),
        icon: Icons.emoji_events_outlined,
        color: AppColors.info,
      ),
      Notice(
        id: 'n2',
        title: 'Fee Reminder',
        description: '2nd installment payment is due by 10th May 2026.',
        postedAt: now.subtract(const Duration(days: 1)),
        icon: Icons.payments_outlined,
        color: AppColors.danger,
      ),
      Notice(
        id: 'n3',
        title: 'Summer Camp',
        description: 'Registration open for Summer Camp 2026.',
        postedAt: now.subtract(const Duration(days: 3)),
        icon: Icons.wb_sunny_outlined,
        color: AppColors.success,
      ),
      Notice(
        id: 'n4',
        title: 'Parent-Teacher Meeting',
        description: 'PTM scheduled for all classes on 10th May.',
        postedAt: now.subtract(const Duration(days: 5)),
        icon: Icons.groups_outlined,
        color: AppColors.primary,
        read: true,
      ),
    ];
  }

  List<SchoolEvent> events() {
    final now = DateTime.now();
    return [
      SchoolEvent(
        id: 'e1',
        title: 'PTM (Parents-Teacher Meeting)',
        description: '10 May 2026 · 10:00 AM - 01:00 PM',
        date: DateTime(now.year, now.month, now.day + 3),
        timeLabel: '10:00 AM',
      ),
      SchoolEvent(
        id: 'e2',
        title: 'Annual Sports Day',
        description: '25 May 2026 · 08:00 AM onwards',
        date: DateTime(now.year, now.month, now.day + 18),
        timeLabel: '08:00 AM',
      ),
      SchoolEvent(
        id: 'e3',
        title: 'World Environment Day',
        description: '05 June 2026 · All Day',
        date: DateTime(now.year, now.month, now.day + 29),
        timeLabel: 'All Day',
      ),
    ];
  }

  List<TeacherThread> teacherThreads() {
    final now = DateTime.now();
    return [
      TeacherThread(
        id: 't1',
        teacherName: 'Ms. Priya Verma',
        subject: 'Class Teacher (Rahul)',
        avatarInitials: 'PV',
        avatarColor: AppColors.primary,
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        unread: true,
        messages: [
          ChatMessage(
              text: 'Regarding: Progress in Mathematics',
              sender: MessageSender.teacher,
              time: now.subtract(const Duration(hours: 2, minutes: 5))),
          ChatMessage(
              text: 'Rahul has shown improvement in his recent test. Keep encouraging him to practice daily.',
              sender: MessageSender.teacher,
              time: now.subtract(const Duration(hours: 2))),
        ],
      ),
      TeacherThread(
        id: 't2',
        teacherName: 'Mr. Amit Kumar',
        subject: 'Science Teacher (Ananya)',
        avatarInitials: 'AK',
        avatarColor: AppColors.secondary,
        lastMessageTime: now.subtract(const Duration(days: 1)),
        unread: true,
        messages: [
          ChatMessage(
              text: 'Regarding: Project Submission',
              sender: MessageSender.teacher,
              time: now.subtract(const Duration(days: 1, hours: 1))),
          ChatMessage(
              text: "Ananya's science project is well done. Great creativity!",
              sender: MessageSender.teacher,
              time: now.subtract(const Duration(days: 1))),
        ],
      ),
      TeacherThread(
        id: 't3',
        teacherName: 'Ms. Neha Singh',
        subject: 'English Teacher (Rahul)',
        avatarInitials: 'NS',
        avatarColor: AppColors.success,
        lastMessageTime: now.subtract(const Duration(days: 2)),
        unread: false,
        messages: [
          ChatMessage(
              text: 'Regarding: Reading Habits',
              sender: MessageSender.teacher,
              time: now.subtract(const Duration(days: 2, hours: 1))),
          ChatMessage(
              text: 'Please encourage Rahul to read more books for better vocabulary.',
              sender: MessageSender.teacher,
              time: now.subtract(const Duration(days: 2))),
        ],
      ),
    ];
  }

  List<QuickLink> quickLinks() => const [
        QuickLink(label: 'View Timetable', icon: Icons.calendar_view_week_outlined, color: AppColors.primary),
        QuickLink(label: 'Homework', icon: Icons.menu_book_outlined, color: AppColors.info),
        QuickLink(label: 'Exam Schedule', icon: Icons.fact_check_outlined, color: AppColors.warning),
        QuickLink(label: 'Download Reports', icon: Icons.file_download_outlined, color: AppColors.success),
        QuickLink(label: 'Leave Application', icon: Icons.event_note_outlined, color: AppColors.secondary),
        QuickLink(label: 'Transport Info', icon: Icons.directions_bus_outlined, color: AppColors.danger),
      ];
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edusmart_school_erp_flutter/modules/teacher_portal/models/dashboard_models.dart';
import 'package:edusmart_school_erp_flutter/modules/teacher_portal/state/app_state.dart';
import 'package:edusmart_school_erp_flutter/modules/teacher_portal/screens/attendance_screen.dart';
import 'package:edusmart_school_erp_flutter/modules/teacher_portal/screens/homework_screen.dart';
import 'package:edusmart_school_erp_flutter/modules/teacher_portal/screens/syllabus_screen.dart';
import 'package:edusmart_school_erp_flutter/modules/teacher_portal/screens/leave_payroll_screen.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Section 4: Standalone Teacher Portal (Mini-App) Functional Tests', () {
    test('1. Class Attendance: mark individual and batch attendance (Present / Absent)', () {
      final app = AppState(autoLoad: false);
      app.students = [
        StudentItem(id: 's1', name: 'Aarav Sharma', className: 'Class 10-A', score: 85, avatarSeed: 'Aarav'),
        StudentItem(id: 's2', name: 'Diya Patel', className: 'Class 10-A', score: 92, avatarSeed: 'Diya'),
        StudentItem(id: 's3', name: 'Ishaan Verma', className: 'Class 10-A', score: 78, avatarSeed: 'Ishaan'),
        StudentItem(id: 's4', name: 'Ananya Roy', className: 'Class 9-B', score: 88, avatarSeed: 'Ananya'),
      ];

      // Initially all defaulted to present
      expect(app.presentCount, equals(4));
      expect(app.absentCount, equals(0));

      // Mark single student absent in memory
      final studentS2 = app.students.firstWhere((s) => s.id == 's2');
      studentS2.attendanceToday = AttendanceStatus.absent;

      expect(app.presentCount, equals(3));
      expect(app.absentCount, equals(1));

      // Batch mark all in Class 10-A to Present
      for (final s in app.students.where((s) => s.className == 'Class 10-A')) {
        s.attendanceToday = AttendanceStatus.present;
      }
      expect(app.presentCount, equals(4));
      expect(app.absentCount, equals(0));

      // Filter verification
      final class10Students = app.studentsFiltered(className: 'Class 10-A');
      expect(class10Students.length, equals(3));
      final class9Students = app.studentsFiltered(className: 'Class 9-B');
      expect(class9Students.length, equals(1));
    });

    test('2. Homework Pipeline: create homework, assign to class roster, track submissions & progress', () {
      final app = AppState(autoLoad: false);
      app.students = [
        StudentItem(id: 'stu-1', name: 'Kavita Das', className: 'Class 10-A', score: 80, avatarSeed: 'Kavita'),
        StudentItem(id: 'stu-2', name: 'Rahul Joshi', className: 'Class 10-A', score: 75, avatarSeed: 'Rahul'),
        StudentItem(id: 'stu-3', name: 'Sanya Mirza', className: 'Class 10-A', score: 90, avatarSeed: 'Sanya'),
      ];

      final studentIds = app.studentsFiltered(className: 'Class 10-A').map((s) => s.id).toList();
      final initialSubmissions = {for (final id in studentIds) id: 'Pending'};

      final homeworkItem = HomeworkItem(
        id: 'hw-101',
        title: 'Trigonometry Problem Set 4',
        className: 'Class 10-A',
        subject: 'Mathematics',
        dueDate: '2026-10-05',
        submissions: initialSubmissions,
      );

      app.homework = [homeworkItem];

      // Initial stats
      expect(homeworkItem.totalCount, equals(3));
      expect(homeworkItem.pendingCount, equals(3));
      expect(homeworkItem.submittedCount, equals(0));
      expect(homeworkItem.progress, equals(0.0));

      // Update submission status for stu-1 to Submitted
      homeworkItem.submissions['stu-1'] = 'Submitted';
      expect(homeworkItem.submittedCount, equals(1));
      expect(homeworkItem.pendingCount, equals(2));
      expect(homeworkItem.progress, closeTo(0.333, 0.01));

      // Cycle status logic: Pending -> Submitted -> Reviewed -> Late
      const order = ['Pending', 'Submitted', 'Reviewed', 'Late'];
      final currStatus = homeworkItem.submissions['stu-2'] ?? 'Pending';
      final nextStatus = order[(order.indexOf(currStatus) + 1) % order.length];
      homeworkItem.submissions['stu-2'] = nextStatus;

      expect(homeworkItem.submissions['stu-2'], equals('Submitted'));
      expect(homeworkItem.submittedCount, equals(2));
      expect(homeworkItem.pendingCount, equals(1));
    });

    test('3. Syllabus Progress Tracker: topics completion and percentage recalculation', () {
      final app = AppState(autoLoad: false);
      final chapter1 = SyllabusChapter(
        id: 'syl-1',
        className: 'Class 10-A',
        subject: 'Science',
        title: 'Chemical Reactions and Equations',
        totalTopics: 5,
        completedTopics: 3, // 3/5 = 60%
      );
      final chapter2 = SyllabusChapter(
        id: 'syl-2',
        className: 'Class 10-A',
        subject: 'Science',
        title: 'Acids, Bases and Salts',
        totalTopics: 5,
        completedTopics: 1, // 1/5 = 20%
      );
      app.syllabus = [chapter1, chapter2];

      expect(chapter1.progress, equals(0.60));
      expect(chapter2.progress, equals(0.20));

      // Combined class progress: (0.60 + 0.20) / 2 = 0.40 (40%)
      final classProgress = app.syllabusProgressFor('Class 10-A');
      expect(classProgress, closeTo(0.40, 0.001));

      // Teacher marks 1 more topic completed in chapter 1 (4/5 = 80%)
      chapter1.completedTopics = (chapter1.completedTopics + 1).clamp(0, chapter1.totalTopics);
      expect(chapter1.progress, equals(0.80));

      // Recalculated class progress: (0.80 + 0.20) / 2 = 0.50 (50%)
      expect(app.syllabusProgressFor('Class 10-A'), closeTo(0.50, 0.001));

      // Complete all topics in chapter 1 (5/5 = 100%)
      chapter1.completedTopics = 5;
      expect(chapter1.progress, equals(1.0));
    });

    test('4. Staff Leave Workflow: Apply leave -> Pending -> Principal approval / rejection', () {
      final app = AppState(autoLoad: false);
      app.teacherName = 'Priya Sharma';

      final leave1 = LeaveRequest(
        id: 'lv-001',
        staffName: 'Priya Sharma',
        leaveType: 'Casual',
        reason: 'Family wedding',
        date: '2026-10-10',
        toDate: '2026-10-11',
        days: 2,
        appliedOn: '2026-09-29',
        status: 'Pending',
      );

      app.leaveRequests = [leave1];

      // Verify pending approvals list
      expect(app.pendingApprovals.length, equals(1));
      expect(app.pendingApprovals.first.id, equals('lv-001'));
      expect(app.pendingApprovals.first.status, equals('Pending'));

      // Principal approves leave request
      final target = app.leaveRequests.firstWhere((l) => l.id == 'lv-001');
      target.status = 'Approved';
      target.approverNote = 'Approved by Principal';

      expect(app.pendingApprovals.isEmpty, isTrue);
      expect(app.myLeaveRequests.first.status, equals('Approved'));
      expect(app.casualLeaveUsed, equals(2));
      expect(app.sickLeaveUsed, equals(0));

      // Add sick leave and reject
      final leave2 = LeaveRequest(
        id: 'lv-002',
        staffName: 'Priya Sharma',
        leaveType: 'Sick',
        reason: 'Medical checkup',
        date: '2026-10-15',
        toDate: '2026-10-15',
        days: 1,
        appliedOn: '2026-09-29',
        status: 'Pending',
      );
      app.leaveRequests.add(leave2);
      expect(app.pendingApprovals.length, equals(1));

      leave2.status = 'Rejected';
      leave2.approverNote = 'Staff shortage on specified date';
      expect(app.pendingApprovals.isEmpty, isTrue);
      expect(app.sickLeaveUsed, equals(0)); // Rejected leave does not count against balance
    });

    testWidgets('5. AttendanceScreen renders attendance KPIs and student rows', (tester) async {
      final app = AppState(autoLoad: false);
      app.students = [
        StudentItem(id: 's1', name: 'Rohan Sharma', className: 'Class 10-A', score: 85, avatarSeed: 'Rohan'),
        StudentItem(id: 's2', name: 'Simran Kaur', className: 'Class 10-A', score: 90, avatarSeed: 'Simran'),
      ];

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: app,
          child: const MaterialApp(
            home: Scaffold(
              body: AttendanceScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('Mark All Present'), findsOneWidget);
      expect(find.text('Rohan Sharma'), findsOneWidget);
      expect(find.text('Simran Kaur'), findsOneWidget);
      expect(find.text('Present'), findsWidgets);
    });

    testWidgets('6. HomeworkScreen displays assigned homework and submission pills', (tester) async {
      final app = AppState(autoLoad: false);
      app.students = [
        StudentItem(id: 's1', name: 'Rohan Sharma', className: 'Class 10-A', score: 85, avatarSeed: 'Rohan'),
      ];
      app.homework = [
        HomeworkItem(
          id: 'hw-1',
          title: 'Physics Wave Optics Assignment',
          className: 'Class 10-A',
          subject: 'Physics',
          dueDate: '2026-10-12',
          submissions: {'s1': 'Submitted'},
        ),
      ];

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: app,
          child: const MaterialApp(
            home: Scaffold(
              body: HomeworkScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Homework Submission Tracking'), findsOneWidget);
      expect(find.text('Physics Wave Optics Assignment'), findsOneWidget);
      expect(find.text('1 Submitted'), findsOneWidget);
    });

    testWidgets('7. SyllabusScreen renders chapter progress and topic step buttons', (tester) async {
      final app = AppState(autoLoad: false);
      app.students = [
        StudentItem(id: 's1', name: 'Rohan Sharma', className: 'Class 10-A', score: 85, avatarSeed: 'Rohan'),
      ];
      app.syllabus = [
        SyllabusChapter(
          id: 'c1',
          className: 'Class 10-A',
          subject: 'Mathematics',
          title: 'Quadratic Equations',
          totalTopics: 10,
          completedTopics: 6,
        ),
      ];

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: app,
          child: const MaterialApp(
            home: Scaffold(
              body: SyllabusScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Syllabus Tracker'), findsOneWidget);
      expect(find.text('Quadratic Equations'), findsOneWidget);
      expect(find.text('6/10 Topics'), findsOneWidget);
      expect(find.text('6 / 10 topics done'), findsOneWidget);
    });

    testWidgets('8. LeavePayrollScreen renders leave balances and Approvals tab for Principal role', (tester) async {
      final app = AppState(autoLoad: false);
      app.currentRole = UserRole.principal;
      app.teacherName = 'Dr. Principal';
      app.leaveRequests = [
        LeaveRequest(
          id: 'lv-99',
          staffName: 'Anita Desai',
          leaveType: 'Casual',
          reason: 'Personal engagement',
          date: '2026-10-14',
          status: 'Pending',
        ),
      ];

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: app,
          child: const MaterialApp(
            home: Scaffold(
              body: LeavePayrollScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Leave & Payroll'), findsOneWidget);
      expect(find.text('My Leave'), findsOneWidget);
      expect(find.text('Approvals'), findsOneWidget);

      // Switch to Approvals tab
      await tester.tap(find.text('Approvals'));
      await tester.pumpAndSettle();

      expect(find.text('Pending Approvals (1)'), findsOneWidget);
      expect(find.text('Anita Desai'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });
  });
}

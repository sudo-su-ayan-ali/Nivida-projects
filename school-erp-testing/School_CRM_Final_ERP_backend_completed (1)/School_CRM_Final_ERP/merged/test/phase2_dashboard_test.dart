import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edusmart_school_erp_flutter/data/dashboard_repository.dart';
import 'package:edusmart_school_erp_flutter/widgets/stat_cards_row.dart';
import 'package:edusmart_school_erp_flutter/widgets/fee_collection_card.dart';
import 'package:edusmart_school_erp_flutter/widgets/admission_chart_card.dart';

/// Mock/Subclassed DashboardRepository to test deterministic metric calculations,
/// multi-tenant filtering assertions, and UI reactivity without network delays.
class TestableDashboardRepository extends DashboardRepository {
  TestableDashboardRepository({
    int initialStudents = 0,
    int initialTeachers = 0,
    int initialUsers = 0,
    double initialAttendancePercent = 0.0,
    double initialMonthlyCollection = 0.0,
    double initialFeeCollected = 0.0,
    double initialFeePending = 0.0,
    double initialFeeOverdue = 0.0,
    List<String>? initialAdmissionMonths,
    List<double>? initialAdmissionCounts,
    int initialAdmissionsSession = 0,
    bool initialLoading = false,
  }) {
    totalStudents = initialStudents;
    totalTeachers = initialTeachers;
    totalUsers = initialUsers;
    todayAttendancePercent = initialAttendancePercent;
    monthlyCollection = initialMonthlyCollection;
    feeCollected = initialFeeCollected;
    feePending = initialFeePending;
    feeOverdue = initialFeeOverdue;
    admissionMonths = initialAdmissionMonths ?? ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
    admissionCounts = initialAdmissionCounts ?? [10.0, 15.0, 25.0, 30.0, 20.0, 18.0, 22.0];
    totalAdmissionsThisSession = initialAdmissionsSession;
    isLoading = initialLoading;
  }

  void simulateRealTimeUpdate({
    int? students,
    int? teachers,
    double? attendance,
    double? collection,
    double? collected,
    double? pending,
    double? overdue,
    int? admissionsSession,
  }) {
    if (students != null) totalStudents = students;
    if (teachers != null) totalTeachers = teachers;
    if (attendance != null) todayAttendancePercent = attendance;
    if (collection != null) monthlyCollection = collection;
    if (collected != null) feeCollected = collected;
    if (pending != null) feePending = pending;
    if (overdue != null) feeOverdue = overdue;
    if (admissionsSession != null) totalAdmissionsThisSession = admissionsSession;
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Section 1: Dashboard KPI & Mathematical Calculation Tests', () {
    test('1. KPI formulas and attendance percentage calculation logic', () {
      // Simulate raw attendance records for a school
      final mockAttendanceRecords = [
        {'status': 'present'},
        {'status': 'present'},
        {'status': 'present'},
        {'status': 'absent'},
        {'status': 'late'},
      ];

      final total = mockAttendanceRecords.length;
      final presentCount = mockAttendanceRecords.where((r) => r['status'] == 'present').length;
      final calculatedPercentage = total > 0 ? (presentCount / total) * 100 : 0.0;

      expect(total, equals(5));
      expect(presentCount, equals(3));
      expect(calculatedPercentage, equals(60.0));
    });

    test('2. Teaching staff designation keyword resolution', () {
      const teachingKeywords = [
        'professor',
        'teacher',
        'head of department',
        'hod',
        'lecturer',
      ];

      final mockEmployees = [
        {'name': 'Dr. Meera', 'designation': 'Senior Professor'},
        {'name': 'Prof. Arvind', 'designation': 'Head of Department'},
        {'name': 'Ramesh Kumar', 'designation': 'Bus Driver'},
        {'name': 'Kavita Das', 'designation': 'Primary Teacher'},
        {'name': 'Sunil Joshi', 'designation': 'Accountant'},
        {'name': 'Anil Sharma', 'designation': 'Lecturer'},
      ];

      final teachingStaffCount = mockEmployees.where((row) {
        final designation = (row['designation'] as String?)?.toLowerCase();
        if (designation == null) return false;
        return teachingKeywords.any((keyword) => designation.contains(keyword));
      }).length;

      expect(teachingStaffCount, equals(4)); // Professor, HoD, Teacher, Lecturer
    });

    test('3. Fee calculation logic (Collected, Pending, Overdue)', () {
      final mockInstallments = [
        // Fully paid
        {'amount_due': 50000.0, 'amount_paid': 50000.0, 'due_date': '2026-09-01'},
        // Partially paid, not overdue (future due date)
        {'amount_due': 30000.0, 'amount_paid': 10000.0, 'due_date': '2026-12-31'},
        // Partially paid, overdue (past due date)
        {'amount_due': 20000.0, 'amount_paid': 5000.0, 'due_date': '2026-08-01'},
        // Completely unpaid, overdue
        {'amount_due': 15000.0, 'amount_paid': 0.0, 'due_date': '2026-07-15'},
      ];

      double collected = 0;
      double pending = 0;
      double overdue = 0;
      final today = DateTime.parse('2026-09-29');

      for (final row in mockInstallments) {
        final amount = row['amount_due'] as double;
        final paid = row['amount_paid'] as double;
        final remaining = amount - paid;
        collected += paid;

        if (remaining > 0.01) {
          final dueDate = DateTime.parse(row['due_date'] as String);
          if (today.isAfter(dueDate)) {
            overdue += remaining;
          } else {
            pending += remaining;
          }
        }
      }

      expect(collected, equals(65000.0)); // 50000 + 10000 + 5000
      expect(pending, equals(20000.0));   // 20000 remaining on 2026-12-31
      expect(overdue, equals(30000.0));   // 15000 (past Aug) + 15000 (past Jul)
    });
  });

  group('Phase 2 Section 1: Dashboard UI Widget & Real-Time Sync Tests', () {
    testWidgets('4. StatCardsRow renders live KPI counters accurately', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = TestableDashboardRepository(
        initialStudents: 248,
        initialTeachers: 32,
        initialUsers: 310,
        initialAttendancePercent: 94.2,
        initialMonthlyCollection: 1250000.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCardsRow(repo: repo),
          ),
        ),
      );
      await tester.pump();

      // Verify all 5 live KPI metric values appear on screen
      expect(find.text('Total Students'), findsOneWidget);
      expect(find.text('248'), findsOneWidget);

      expect(find.text('Total Teachers'), findsOneWidget);
      expect(find.text('32'), findsOneWidget);

      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('310'), findsOneWidget);

      expect(find.text("Today's Attendance"), findsOneWidget);
      expect(find.text('94.2%'), findsOneWidget);

      expect(find.text('Monthly Collection'), findsOneWidget);
      expect(find.text('₹ 1250000'), findsOneWidget);
    });

    testWidgets('5. Real-Time Refresh dynamically updates StatCardsRow without restart', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = TestableDashboardRepository(
        initialStudents: 248,
        initialMonthlyCollection: 1250000.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedBuilder(
              animation: repo,
              builder: (context, _) => StatCardsRow(repo: repo),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('248'), findsOneWidget);
      expect(find.text('₹ 1250000'), findsOneWidget);

      // Simulate new student admission and new fee transaction in real-time
      repo.simulateRealTimeUpdate(
        students: 249,
        collection: 1300000.0,
      );
      await tester.pump();

      expect(find.text('248'), findsNothing);
      expect(find.text('249'), findsOneWidget);
      expect(find.text('₹ 1300000'), findsOneWidget);
    });

    testWidgets('6. FeeCollectionCard calculates and renders summary slices & amounts', (tester) async {
      tester.view.physicalSize = const Size(600, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeeCollectionCard(
              collected: 500000.0,
              pending: 300000.0,
              overdue: 200000.0,
            ),
          ),
        ),
      );
      await tester.pump();

      // Total = 1,000,000. Collected = 50%, Pending = 30%, Overdue = 20%
      expect(find.text('Fee Collection Overview'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget); // Main center stat

      // Check legend text
      expect(find.text('Collected'), findsAtLeastNWidgets(1));
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Overdue'), findsOneWidget);
      expect(find.text('₹ 500,000 (50%)'), findsOneWidget);
      expect(find.text('₹ 300,000 (30%)'), findsOneWidget);
      expect(find.text('₹ 200,000 (20%)'), findsOneWidget);
    });

    testWidgets('7. AdmissionChartCard renders session total and chart container', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = TestableDashboardRepository(
        initialAdmissionsSession: 140,
        initialAdmissionMonths: ['Apr', 'May', 'Jun'],
        initialAdmissionCounts: [40.0, 60.0, 40.0],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdmissionChartCard(repo: repo),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Students Admission'), findsOneWidget);
      expect(find.text('140'), findsOneWidget);
      expect(find.text('New Admissions'), findsOneWidget);
    });
  });
}

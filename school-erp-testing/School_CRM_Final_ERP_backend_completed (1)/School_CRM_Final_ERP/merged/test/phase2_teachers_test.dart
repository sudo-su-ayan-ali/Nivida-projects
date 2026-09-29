import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edusmart_school_erp_flutter/modules/teachers/models/teacher.dart';
import 'package:edusmart_school_erp_flutter/modules/teachers/widgets/department_chart_card.dart';
import 'package:edusmart_school_erp_flutter/modules/teachers/widgets/birthday_card.dart';
import 'package:edusmart_school_erp_flutter/modules/teachers/widgets/teacher_list_panel.dart';

Teacher _createDummyTeacher({
  required int id,
  required String empId,
  required String name,
  String department = 'Science',
  String subject = 'Physics',
  String status = 'Active',
  String email = 'teacher@school.test',
  String phone = '9845012345',
  int birthDay = 15,
  String birthMonth = 'AUG',
}) {
  return Teacher(
    id: id,
    empId: empId,
    name: name,
    email: email,
    phone: phone,
    department: department,
    subject: subject,
    status: status,
    avatarSeed: name,
    birthDay: birthDay,
    birthMonth: birthMonth,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Section 3: Teachers Module CRUD & Rollback Tests', () {
    test('1. CRUD Operations: Add, Update, and Delete Teacher in-memory state', () {
      final roster = <Teacher>[
        _createDummyTeacher(id: 1, empId: 'EMP-001', name: 'Dr. Meera Nambiar'),
      ];

      expect(roster.length, equals(1));

      // Add
      final newTeacher = _createDummyTeacher(
        id: 2,
        empId: 'EMP-002',
        name: 'Prof. Arvind Menon',
        department: 'Mathematics',
        subject: 'Calculus',
      );
      roster.insert(0, newTeacher);
      expect(roster.length, equals(2));
      expect(roster.first.name, equals('Prof. Arvind Menon'));

      // Update
      final updated = roster.first.copyWith(phone: '9999999999', status: 'On Leave');
      final idx = roster.indexWhere((t) => t.id == updated.id);
      roster[idx] = updated;
      expect(roster.first.phone, equals('9999999999'));
      expect(roster.first.status, equals('On Leave'));

      // Delete
      roster.removeWhere((t) => t.id == 2);
      expect(roster.length, equals(1));
      expect(roster.first.name, equals('Dr. Meera Nambiar'));
    });

    test('2. Optimistic UI & Rollback Logic Simulation on Network Error', () async {
      // Setup initial roster
      final initialRoster = [
        _createDummyTeacher(id: 1, empId: 'EMP-001', name: 'Dr. Meera Nambiar'),
        _createDummyTeacher(id: 2, empId: 'EMP-002', name: 'Prof. Arvind Menon'),
      ];
      var currentRoster = List<Teacher>.of(initialRoster);

      // Function simulating optimistic delete with error rollback
      Future<void> simulateOptimisticDelete(int id, {required bool shouldFail}) async {
        final backup = List<Teacher>.of(currentRoster);
        // Optimistic UI removal
        currentRoster.removeWhere((t) => t.id == id);

        try {
          if (shouldFail) {
            throw Exception('Network 500: Database connection timed out');
          }
          // Server success
        } catch (_) {
          // Rollback on failure!
          currentRoster = backup;
        }
      }

      // Step A: Successful delete
      await simulateOptimisticDelete(2, shouldFail: false);
      expect(currentRoster.length, equals(1));
      expect(currentRoster.first.id, equals(1));

      // Step B: Failed delete -> Rollback triggered
      await simulateOptimisticDelete(1, shouldFail: true);
      expect(currentRoster.length, equals(1));
      expect(currentRoster.first.id, equals(1)); // Restored!
    });

    test('3. Department Distribution Counts and Birthday Sorting', () {
      final teachers = [
        _createDummyTeacher(id: 1, empId: 'EMP-001', name: 'Dr. Meera', department: 'Science', birthDay: 15, birthMonth: 'AUG'),
        _createDummyTeacher(id: 2, empId: 'EMP-002', name: 'Prof. Arvind', department: 'Mathematics', birthDay: 5, birthMonth: 'MAY'),
        _createDummyTeacher(id: 3, empId: 'EMP-003', name: 'Kavita Das', department: 'Science', birthDay: 22, birthMonth: 'NOV'),
        _createDummyTeacher(id: 4, empId: 'EMP-004', name: 'Sunil Joshi', department: 'Arts', birthDay: 1, birthMonth: 'JAN'),
      ];

      // Department aggregation
      final deptCounts = <String, int>{};
      for (final t in teachers) {
        deptCounts[t.department] = (deptCounts[t.department] ?? 0) + 1;
      }

      expect(deptCounts['Science'], equals(2));
      expect(deptCounts['Mathematics'], equals(1));
      expect(deptCounts['Arts'], equals(1));

      // Birthday ordering
      final sortedByBirthday = [...teachers]..sort((a, b) => a.birthDay.compareTo(b.birthDay));
      expect(sortedByBirthday.first.name, equals('Sunil Joshi')); // Day 1
      expect(sortedByBirthday[1].name, equals('Prof. Arvind'));   // Day 5
      expect(sortedByBirthday.last.name, equals('Kavita Das'));    // Day 22
    });
  });

  group('Phase 2 Section 3: Teachers Module UI Component Tests', () {
    testWidgets('4. DepartmentChartCard calculates and renders total and breakdown', (tester) async {
      tester.view.physicalSize = const Size(600, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final teachers = [
        _createDummyTeacher(id: 1, empId: 'EMP-001', name: 'Dr. Meera', department: 'Science'),
        _createDummyTeacher(id: 2, empId: 'EMP-002', name: 'Prof. Arvind', department: 'Mathematics'),
        _createDummyTeacher(id: 3, empId: 'EMP-003', name: 'Kavita Das', department: 'Science'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DepartmentChartCard(teachers: teachers),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Department Wise Teachers'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // Total in center
      expect(find.text('Science'), findsOneWidget);
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // 2 in Science
      expect(find.text('1'), findsOneWidget); // 1 in Math
    });

    testWidgets('5. BirthdayCard renders upcoming birthdays with badges', (tester) async {
      tester.view.physicalSize = const Size(500, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final teachers = [
        _createDummyTeacher(id: 1, empId: 'EMP-001', name: 'Dr. Meera', birthDay: 15, birthMonth: 'AUG', subject: 'Physics'),
        _createDummyTeacher(id: 2, empId: 'EMP-002', name: 'Prof. Arvind', birthDay: 22, birthMonth: 'NOV', subject: 'Mathematics'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BirthdayCard(teachers: teachers),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Upcoming Birthdays'), findsOneWidget);
      expect(find.text('Dr. Meera'), findsOneWidget);
      expect(find.text('Physics Teacher'), findsOneWidget);
      expect(find.text('AUG'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);

      expect(find.text('Prof. Arvind'), findsOneWidget);
      expect(find.text('Mathematics Teacher'), findsOneWidget);
      expect(find.text('NOV'), findsOneWidget);
      expect(find.text('22'), findsOneWidget);
    });

    testWidgets('6. TeacherListPanel displays roster and handles search text', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final teachers = [
        _createDummyTeacher(id: 1, empId: 'EMP-001', name: 'Dr. Meera Nambiar'),
        _createDummyTeacher(id: 2, empId: 'EMP-002', name: 'Prof. Arvind Menon'),
      ];

      String capturedSearch = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeacherListPanel(
              filtered: teachers,
              query: '',
              deptFilter: null,
              statusFilter: null,
              sortKey: TeacherSortKey.none,
              sortAsc: true,
              page: 1,
              pageSize: 5,
              onQueryChanged: (q) => capturedSearch = q,
              onDeptFilterChanged: (_) {},
              onStatusFilterChanged: (_) {},
              onSortToggle: (_) {},
              onPageChanged: (_) {},
              onClearFilters: () {},
              onUpdate: (_) {},
              onDelete: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Check header and row presence
      expect(find.text('Teacher List'), findsOneWidget);
      expect(find.text('Dr. Meera Nambiar'), findsOneWidget);
      expect(find.text('Prof. Arvind Menon'), findsOneWidget);

      // Enter search query
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Meera');
      await tester.pump();

      expect(capturedSearch, equals('Meera'));
    });
  });
}

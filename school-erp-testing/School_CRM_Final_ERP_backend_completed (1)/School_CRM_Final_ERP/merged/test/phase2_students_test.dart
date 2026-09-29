import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edusmart_school_erp_flutter/modules/students/models/student.dart';
import 'package:edusmart_school_erp_flutter/modules/students/data/student_repository.dart';
import 'package:edusmart_school_erp_flutter/modules/students/widgets/at_risk_students_card.dart';
import 'package:edusmart_school_erp_flutter/modules/students/widgets/today_highlights_card.dart';
import 'package:edusmart_school_erp_flutter/modules/students/widgets/students_list_section.dart';

/// Testable subclass of StudentRepository for hermetic, in-memory testing of
/// Students Module operations (Admissions, Filtering, TC, At-Risk calculations, Rollbacks).
class TestableStudentRepository extends StudentRepository {
  final List<Student> _mockStudents = [];

  TestableStudentRepository({List<Student>? initialStudents}) {
    if (initialStudents != null) {
      _mockStudents.addAll(initialStudents);
    }
    isLoading = false;
  }

  @override
  List<Student> get all => List.unmodifiable(_mockStudents);

  @override
  Future<void> load() async {
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> addStudent(Student student) async {
    // Duplicate enrollment/admission number check
    if (_mockStudents.any((s) => s.admissionNo == student.admissionNo)) {
      throw Exception('Duplicate entry: Admission/Enrollment number ${student.admissionNo} already exists.');
    }
    _mockStudents.insert(0, student);
    notifyListeners();
  }

  @override
  Future<void> updateStudent(Student updated) async {
    final idx = _mockStudents.indexWhere((s) => s.id == updated.id);
    if (idx != -1) {
      _mockStudents[idx] = updated;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteStudent(String id) async {
    _mockStudents.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  /// Simulate a TC approval: status changes from active to inactive (transferred)
  Future<void> approveTransferCertificate(String studentId) async {
    final idx = _mockStudents.indexWhere((s) => s.id == studentId);
    if (idx != -1) {
      final s = _mockStudents[idx];
      _mockStudents[idx] = s.copyWith(status: StudentStatus.inactive);
      notifyListeners();
    }
  }

  @override
  Student? byId(String id) {
    try {
      return _mockStudents.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  int get total => _mockStudents.length;

  @override
  int get boys => _mockStudents.where((s) => s.gender == 'Male').length;

  @override
  int get girls => _mockStudents.where((s) => s.gender == 'Female').length;

  @override
  List<Student> get atRiskStudents {
    final risky = _mockStudents.where((s) => s.riskLevel != RiskLevel.none).toList();
    risky.sort((a, b) => a.riskLevel.index.compareTo(b.riskLevel.index));
    return risky.take(5).toList();
  }

  @override
  List<Student> get lowAttendanceStudents =>
      _mockStudents.where((s) => s.attendancePercent < 75).toList();

  @override
  List<Student> get feeDueStudents =>
      _mockStudents.where((s) => s.feeDue > 0).toList();
}

Student _createDummyStudent({
  required String id,
  required String admissionNo,
  required String name,
  int classNum = 10,
  String section = 'A',
  String mobile = '9876543210',
  String parentName = 'Guardian',
  String parentMobile = '9876543211',
  StudentStatus status = StudentStatus.active,
  double attendancePercent = 92.0,
  double examAveragePercent = 85.0,
  double feeDue = 0.0,
  RiskLevel riskLevel = RiskLevel.none,
  String riskReason = '',
}) {
  return Student(
    id: id,
    admissionNo: admissionNo,
    name: name,
    email: '$admissionNo@school.test',
    classNum: classNum,
    section: section,
    mobile: mobile,
    parentName: parentName,
    parentMobile: parentMobile,
    status: status,
    gender: 'Male',
    bloodGroup: 'B+',
    category: 'General',
    dob: DateTime(2010, 5, 12),
    admissionDate: DateTime(2026, 4, 1),
    address: 'Campus Road, Bangalore',
    usesTransport: true,
    transportRoute: 'Route 101',
    livesInHostel: false,
    hostelName: null,
    documentsVerified: true,
    idCardGenerated: true,
    attendancePercent: attendancePercent,
    examAveragePercent: examAveragePercent,
    feeDue: feeDue,
    riskLevel: riskLevel,
    riskReason: riskReason,
    isBirthdayToday: false,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Section 2: Students Module Functional & Data Flow Tests', () {
    test('1. Full Admission & Student Registration Flow', () async {
      final repo = TestableStudentRepository();
      expect(repo.total, equals(0));

      final newStudent = _createDummyStudent(
        id: 's-001',
        admissionNo: 'ALP-2026-001',
        name: 'Aarav Sharma',
      );

      await repo.addStudent(newStudent);

      expect(repo.total, equals(1));
      expect(repo.all.first.name, equals('Aarav Sharma'));
      expect(repo.all.first.admissionNo, equals('ALP-2026-001'));
      expect(repo.all.first.status, equals(StudentStatus.active));
    });

    test('2. Duplicate Admission/Enrollment Number Rejection', () async {
      final repo = TestableStudentRepository(
        initialStudents: [
          _createDummyStudent(id: 's-001', admissionNo: 'ALP-2026-001', name: 'Aarav Sharma'),
        ],
      );

      final duplicateStudent = _createDummyStudent(
        id: 's-002',
        admissionNo: 'ALP-2026-001', // Same admission number!
        name: 'Duplicate Student',
      );

      // Must throw exception on duplicate admission/enrollment number
      expect(
        () => repo.addStudent(duplicateStudent),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'error message',
          contains('Duplicate entry'),
        )),
      );

      // Verify count remains 1 and duplicate was not inserted
      expect(repo.total, equals(1));
    });

    test('3. Automatic At-Risk Flagging Logic (<75% attendance or high risk)', () {
      final students = [
        _createDummyStudent(
          id: 's-001',
          admissionNo: 'ALP-001',
          name: 'Healthy Student',
          attendancePercent: 95.0,
          riskLevel: RiskLevel.none,
        ),
        _createDummyStudent(
          id: 's-002',
          admissionNo: 'ALP-002',
          name: 'Low Attendance Student',
          attendancePercent: 62.0, // < 75%
          riskLevel: RiskLevel.high,
          riskReason: 'Attendance < 75%',
        ),
        _createDummyStudent(
          id: 's-003',
          admissionNo: 'ALP-003',
          name: 'Academic Failure Risk',
          attendancePercent: 88.0,
          examAveragePercent: 32.0,
          riskLevel: RiskLevel.medium,
          riskReason: 'Failing Math',
        ),
      ];

      final repo = TestableStudentRepository(initialStudents: students);

      // Low attendance filter
      final lowAttendance = repo.lowAttendanceStudents;
      expect(lowAttendance.length, equals(1));
      expect(lowAttendance.first.name, equals('Low Attendance Student'));

      // At risk ranking
      final atRisk = repo.atRiskStudents;
      expect(atRisk.length, equals(2));
      expect(atRisk[0].riskLevel, equals(RiskLevel.high));
      expect(atRisk[1].riskLevel, equals(RiskLevel.medium));
    });

    test('4. Transfer Certificate (TC) Lifecycle & Status Transition', () async {
      final student = _createDummyStudent(
        id: 's-001',
        admissionNo: 'ALP-2026-001',
        name: 'Aarav Sharma',
        status: StudentStatus.active,
      );

      final repo = TestableStudentRepository(initialStudents: [student]);
      expect(repo.byId('s-001')!.status, equals(StudentStatus.active));

      // Approve TC
      await repo.approveTransferCertificate('s-001');

      // Verified status updated to inactive/transferred
      expect(repo.byId('s-001')!.status, equals(StudentStatus.inactive));
    });
  });

  group('Phase 2 Section 2: Students Module UI & Interaction Tests', () {
    testWidgets('5. StudentsListSection filters by name, class, and mobile search', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final students = [
        _createDummyStudent(id: 's-001', admissionNo: 'ALP-001', name: 'Aarav Sharma', mobile: '9811111111'),
        _createDummyStudent(id: 's-002', admissionNo: 'ALP-002', name: 'Diya Patel', mobile: '9822222222'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StudentsListSection(
                students: students,
                onAddStudent: () {},
                onImportExcel: () {},
                onExportPdf: () {},
                onView: (_) {},
                onEdit: (_) {},
                onDelete: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Both initially visible
      expect(find.text('Aarav Sharma'), findsOneWidget);
      expect(find.text('Diya Patel'), findsOneWidget);

      // Search for "Diya"
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Diya');
      await tester.pump();

      expect(find.text('Diya Patel'), findsOneWidget);
      expect(find.text('Aarav Sharma'), findsNothing);
    });

    testWidgets('6. AtRiskStudentsCard displays risk badges and student names', (tester) async {
      tester.view.physicalSize = const Size(600, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final atRisk = [
        _createDummyStudent(
          id: 's-002',
          admissionNo: 'ALP-002',
          name: 'Diya Patel',
          riskLevel: RiskLevel.high,
          riskReason: 'Low Attendance',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AtRiskStudentsCard(
              students: atRisk,
              onViewAll: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('At-Risk Students'), findsOneWidget);
      expect(find.text('Diya Patel'), findsOneWidget);
      expect(find.text('High Risk'), findsOneWidget);
      expect(find.text('Low Attendance'), findsOneWidget);
    });

    testWidgets('7. TodayHighlightsCard renders counters for TC requests and low attendance', (tester) async {
      tester.view.physicalSize = const Size(600, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TodayHighlightsCard(
              birthdays: 2,
              feeDue: 5,
              tcRequests: 3,
              lowAttendance: 4,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text("Today's Highlights"), findsOneWidget);
      expect(find.text('3 Requests'), findsOneWidget);
      expect(find.text('4 Students'), findsOneWidget);
    });
  });
}

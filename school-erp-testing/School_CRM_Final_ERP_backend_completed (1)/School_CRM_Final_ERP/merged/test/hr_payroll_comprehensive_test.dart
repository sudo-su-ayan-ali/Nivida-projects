import 'package:flutter_test/flutter_test.dart';
import 'package:edusmart_school_erp_flutter/modules/hr_payroll/data/hr_export_service.dart';
import 'package:edusmart_school_erp_flutter/modules/hr_payroll/models/models.dart';
import 'package:edusmart_school_erp_flutter/modules/hr_payroll/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HR & Payroll Comprehensive Unit and Integration Tests', () {
    late AppState state;

    setUp(() {
      state = AppState();
    });

    test('HR State initial fallbacks populate non-empty data without crashing', () {
      expect(state.employees.isNotEmpty, isTrue);
      expect(state.departments.isNotEmpty, isTrue);
      expect(state.designations.isNotEmpty, isTrue);
      expect(state.attendance.isNotEmpty, isTrue);
      expect(state.leaves.isNotEmpty, isTrue);
      expect(state.salaryStructures.isNotEmpty, isTrue);
      expect(state.payrollRecords.isNotEmpty, isTrue);
      expect(state.shifts.isNotEmpty, isTrue);
      expect(state.loans.isNotEmpty, isTrue);
      expect(state.allowanceDeductions.isNotEmpty, isTrue);
    });

    test('Department and Designation employee headcount counters work correctly', () {
      final deptName = state.departments.first.name;
      final countDept = state.employeeCountForDepartment(deptName);
      expect(countDept, isNonNegative);

      final desigName = state.designations.first.name;
      final countDesig = state.employeeCountForDesignation(desigName);
      expect(countDesig, isNonNegative);

      expect(state.topDepartmentsByHeadcount, isA<Map<String, int>>());
      expect(state.totalEmployees, equals(state.employees.length));
      expect(state.totalDepartments, equals(state.departments.length));
    });

    test('Optimistic mutation: Department CRUD updates state immediately', () async {
      final initialCount = state.departments.length;
      final newDept = Department(id: 'dept-test-1', name: 'Robotics', head: 'Dr. Test');
      await state.addDepartment(newDept);
      expect(state.departments.any((d) => d.id == 'dept-test-1'), isTrue);

      final updatedDept = Department(id: 'dept-test-1', name: 'Advanced Robotics', head: 'Dr. Test');
      await state.updateDepartment(updatedDept);
      expect(state.departments.firstWhere((d) => d.id == 'dept-test-1').name, equals('Advanced Robotics'));

      await state.deleteDepartment('dept-test-1');
      expect(state.departments.any((d) => d.id == 'dept-test-1'), isFalse);
    });

    test('Optimistic mutation: Designation CRUD updates state immediately', () async {
      final newDesig = Designation(
        id: 'desig-test-1',
        name: 'AI Instructor',
        department: 'IT',
        description: 'Instructs AI courses',
      );
      await state.addDesignation(newDesig);
      expect(state.designations.any((d) => d.id == 'desig-test-1'), isTrue);

      final updatedDesig = Designation(
        id: 'desig-test-1',
        name: 'Senior AI Instructor',
        department: 'IT',
        description: 'Senior lead',
      );
      await state.updateDesignation(updatedDesig);
      expect(state.designations.firstWhere((d) => d.id == 'desig-test-1').name, equals('Senior AI Instructor'));

      await state.deleteDesignation('desig-test-1');
      expect(state.designations.any((d) => d.id == 'desig-test-1'), isFalse);
    });

    test('Optimistic mutation: Attendance marking and status update', () async {
      final emp = state.employees.first;
      final rec = AttendanceRecord(
        id: 'att-test-1',
        employeeId: emp.id,
        employeeName: emp.name,
        department: emp.department,
        date: DateTime.now(),
        checkIn: '08:55',
        checkOut: '17:05',
        status: AttendanceStatus.present,
      );
      await state.markAttendance(rec);
      expect(state.attendance.any((a) => a.id == 'att-test-1'), isTrue);

      await state.updateAttendanceStatus('att-test-1', AttendanceStatus.halfDay);
      expect(state.attendance.firstWhere((a) => a.id == 'att-test-1').status, equals(AttendanceStatus.halfDay));
    });

    test('Optimistic mutation: Leave request application and approval', () async {
      final emp = state.employees.first;
      final req = LeaveRequest(
        id: 'leave-test-1',
        employeeId: emp.id,
        employeeName: emp.name,
        leaveType: 'Casual Leave',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 2)),
        days: 3,
        reason: 'Family Event',
        status: LeaveStatus.pending,
      );
      await state.applyLeave(req);
      expect(state.leaves.any((l) => l.id == 'leave-test-1'), isTrue);
      expect(state.notifications.any((n) => n.title == 'New leave request'), isTrue);

      await state.setLeaveStatus('leave-test-1', LeaveStatus.approved);
      expect(state.leaves.firstWhere((l) => l.id == 'leave-test-1').status, equals(LeaveStatus.approved));
    });

    test('Optimistic mutation: Allowance Deduction toggle and add', () async {
      final newAll = AllowanceDeduction(
        id: 'ad-test-1',
        name: 'Internet Allowance',
        type: 'Allowance',
        calcType: 'Fixed',
        value: 1500,
        enabled: true,
      );
      await state.addAllowanceDeduction(newAll);
      expect(state.allowanceDeductions.any((a) => a.id == 'ad-test-1'), isTrue);

      await state.toggleAllowanceDeduction('ad-test-1');
      expect(state.allowanceDeductions.firstWhere((a) => a.id == 'ad-test-1').enabled, isFalse);

      await state.deleteAllowanceDeduction('ad-test-1');
      expect(state.allowanceDeductions.any((a) => a.id == 'ad-test-1'), isFalse);
    });

    test('HR Export Service: Employee CSV builder outputs correct headers and data rows', () {
      final csv = HrExportService.buildCsv(
        ['Emp Code', 'Name', 'Department', 'Designation', 'Salary'],
        [
          ['EMP001', 'Test Name', 'Teaching', 'Teacher', 50000],
        ],
      );
      expect(csv, contains('Emp Code'));
      expect(csv, contains('EMP001'));
      expect(csv, contains('Test Name'));
    });

    test('HR Export Service: Payslip PDF generation succeeds with byte output', () async {
      final emp = state.employees.first;
      final struct = state.structureFor(emp.id);
      final pdfBytes = await HrExportService.generatePayslipPdf(
        employee: emp,
        month: 'May 2024',
        structure: struct,
      );
      expect(pdfBytes.isNotEmpty, isTrue);
      // Valid PDF files start with '%PDF'
      final header = String.fromCharCodes(pdfBytes.sublist(0, 4));
      expect(header, equals('%PDF'));
    });
  });
}

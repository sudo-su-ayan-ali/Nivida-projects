import 'package:flutter_test/flutter_test.dart';

import 'package:edusmart_school_erp_flutter/modules/hr_payroll/models/models.dart';
import 'package:edusmart_school_erp_flutter/modules/hr_payroll/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 3 Section 4.11: HR & Monthly Payroll Module Tests', () {
    late AppState state;

    setUp(() {
      state = AppState();
    });

    test('1. Employee Onboarding & Directory: Model creation, field binding, and status assignment', () {
      final emp = Employee(
        id: 'emp-qa-101',
        empCode: 'EMP101',
        name: 'Dr. Jane Smith',
        gender: 'Female',
        dob: DateTime(1985, 5, 20),
        email: 'jane.smith@edusmart.local',
        phone: '+91 98765 43210',
        address: '123 Academic Enclave',
        department: 'Science',
        designation: 'Senior Physics Lecturer',
        joiningDate: DateTime(2021, 6, 1),
        employmentType: EmploymentType.fullTime,
        salary: 80000,
        bankAccount: 'HDFC000123456789',
        pan: 'ABCDE1234F',
        aadhaar: '1234 5678 9012',
        emergencyContact: '+91 98765 00000',
        status: EmployeeStatus.active,
      );

      state.employees.add(emp);
      expect(state.employees.any((e) => e.id == 'emp-qa-101'), isTrue);
      final retrieved = state.employees.firstWhere((e) => e.id == 'emp-qa-101');
      expect(retrieved.name, equals('Dr. Jane Smith'));
      expect(retrieved.department, equals('Science'));
      expect(retrieved.employmentType, equals(EmploymentType.fullTime));
      expect(retrieved.status, equals(EmployeeStatus.active));
      expect(retrieved.salary, equals(80000));
    });

    test('2. Salary Structure Formula: Gross, Allowances, PF, TDS, and Net Pay verification', () {
      // Basic = 50,000; HRA = 40% (20,000); Special Allowance = 10,000; Conveyance = 0; Medical = 0
      // PF = 12% of Basic (6,000); Other deductions (TDS) = 5,000; Professional tax = 0
      // Expected Gross = 80,000; Deductions = 11,000; Net = 69,000
      final structure = SalaryStructure(
        employeeId: 'emp-qa-101',
        basic: 50000,
        hra: 20000,
        conveyance: 0,
        medical: 0,
        specialAllowance: 10000,
        pf: 6000,
        esi: 0,
        professionalTax: 0,
        otherDeductions: 5000,
      );

      expect(structure.gross, equals(80000));
      expect(structure.totalDeductions, equals(11000));
      expect(structure.net, equals(69000));
      expect(structure.gross - structure.totalDeductions, equals(structure.net));
    });

    test('3. Monthly Payroll Run Execution: Batch processing and net pay generation for active employees', () async {
      final emp1 = Employee(
        id: 'emp-01',
        empCode: 'EMP01',
        name: 'Teacher One',
        gender: 'Male',
        dob: DateTime(1990, 1, 1),
        email: 't1@edusmart.local',
        phone: '111',
        address: 'School',
        department: 'Mathematics',
        designation: 'Lecturer',
        joiningDate: DateTime(2020, 1, 1),
        employmentType: EmploymentType.fullTime,
        salary: 60000,
        bankAccount: '111',
        pan: 'AAA',
        aadhaar: '111',
        emergencyContact: '000',
      );
      final emp2 = Employee(
        id: 'emp-02',
        empCode: 'EMP02',
        name: 'Teacher Two',
        gender: 'Female',
        dob: DateTime(1992, 2, 2),
        email: 't2@edusmart.local',
        phone: '222',
        address: 'School',
        department: 'Mathematics',
        designation: 'Lecturer',
        joiningDate: DateTime(2020, 2, 2),
        employmentType: EmploymentType.fullTime,
        salary: 70000,
        bankAccount: '222',
        pan: 'BBB',
        aadhaar: '222',
        emergencyContact: '000',
      );

      state.employees = [emp1, emp2];
      state.salaryStructures = [
        SalaryStructure(
          employeeId: 'emp-01',
          basic: 30000,
          hra: 15000,
          conveyance: 2000,
          medical: 1000,
          specialAllowance: 12000,
          pf: 3600,
          esi: 0,
          professionalTax: 200,
          otherDeductions: 1000,
        ),
        SalaryStructure(
          employeeId: 'emp-02',
          basic: 35000,
          hra: 17500,
          conveyance: 2000,
          medical: 1000,
          specialAllowance: 14500,
          pf: 4200,
          esi: 0,
          professionalTax: 200,
          otherDeductions: 1500,
        ),
      ];

      await state.processPayrollForMonth('August 2026', department: 'Mathematics');

      final augustPayroll = state.payrollRecords.where((p) => p.month == 'August 2026').toList();
      expect(augustPayroll.length, equals(2));

      final rec1 = augustPayroll.firstWhere((p) => p.employeeId == 'emp-01');
      expect(rec1.gross, equals(60000));
      expect(rec1.deductions, equals(4800)); // 3600 + 200 + 1000
      expect(rec1.net, equals(55200));
      expect(rec1.status, equals(PayrollStatus.processed));

      final rec2 = augustPayroll.firstWhere((p) => p.employeeId == 'emp-02');
      expect(rec2.gross, equals(70000));
      expect(rec2.deductions, equals(5900)); // 4200 + 200 + 1500
      expect(rec2.net, equals(64100));
      expect(rec2.status, equals(PayrollStatus.processed));
    });

    test('4. Loan Advance & EMI Calculation: Principal, interest rate, and tenure amortization', () {
      // Amount = 60,000, Interest = 10%, Tenure = 12 months
      // Principal with interest = 60000 + 6000 = 66000
      // EMI = 66000 / 12 = 5500
      final loan = LoanAdvance(
        id: 'loan-1',
        employeeId: 'emp-01',
        employeeName: 'Teacher One',
        loanType: 'Personal Loan',
        amount: 60000,
        interestPercent: 10,
        tenureMonths: 12,
        startDate: DateTime(2026, 1, 1),
        remaining: 66000,
      );

      expect(loan.emi, equals(5500));

      // Test zero tenure guard
      final zeroTenure = LoanAdvance(
        id: 'loan-2',
        employeeId: 'emp-02',
        employeeName: 'Teacher Two',
        loanType: 'Emergency',
        amount: 10000,
        interestPercent: 0,
        tenureMonths: 0,
        startDate: DateTime(2026, 1, 1),
        remaining: 10000,
      );
      expect(zeroTenure.emi, equals(0));
    });

    test('5. Leave Request & Attendance Status Synchronization', () {
      final leave = LeaveRequest(
        id: 'leave-1',
        employeeId: 'emp-01',
        employeeName: 'Teacher One',
        leaveType: 'Medical Leave',
        startDate: DateTime(2026, 8, 10),
        endDate: DateTime(2026, 8, 12),
        days: 3,
        reason: 'Viral fever',
        status: LeaveStatus.approved,
      );

      state.leaves.add(leave);
      expect(state.leaves.any((l) => l.id == 'leave-1'), isTrue);
      expect(state.leaves.firstWhere((l) => l.id == 'leave-1').status, equals(LeaveStatus.approved));

      // Attendance record marking
      final att = AttendanceRecord(
        id: 'att-1',
        employeeId: 'emp-01',
        employeeName: 'Teacher One',
        department: 'Mathematics',
        date: DateTime(2026, 8, 10),
        checkIn: '--',
        checkOut: '--',
        status: AttendanceStatus.onLeave,
      );
      state.attendance.add(att);
      expect(state.attendance.firstWhere((a) => a.id == 'att-1').status, equals(AttendanceStatus.onLeave));
    });

    test('6. Recruitment Pipeline: Candidate progression from Applied to Offered', () {
      final candidate = Candidate(
        id: 'cand-01',
        name: 'Alex Johnson',
        position: 'Computer Science Faculty',
        experience: '5 Years',
        skills: ['Python', 'Dart', 'Flutter', 'Data Structures'],
        interviewStatus: 'Pending',
        applicationStatus: 'Applied',
      );

      state.candidates.add(candidate);
      expect(state.candidates.first.applicationStatus, equals('Applied'));

      // Progress to Shortlisted / Interview
      candidate.applicationStatus = 'Interview Scheduled';
      candidate.interviewStatus = 'Round 1 Cleared';
      expect(candidate.applicationStatus, equals('Interview Scheduled'));

      // Offer roll-out
      final offer = JobOffer(
        id: 'offer-01',
        candidateName: candidate.name,
        position: candidate.position,
        salary: 75000,
        joiningDate: DateTime(2026, 11, 1),
        status: 'Sent',
      );
      state.offers.add(offer);

      expect(state.offers.first.salary, equals(75000));
      expect(state.offers.first.status, equals('Sent'));
    });
  });
}

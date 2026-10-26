import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../data/mock_data.dart' as seed;
import '../data/hr_service.dart';

const _uuid = Uuid();

class AppState extends ChangeNotifier {
    AppState() {
    employees = seed.buildEmployeeSeed();
    departments = List.from(seed.departmentsSeed);
    designations = List.from(seed.designationsSeed);
    _seedAttendance();
    _seedLeaves();
    _seedSalaryStructures();
    _seedPayroll();
    _seedLoans();
    _seedAllowances();
    shifts = [
      Shift(id: _uuid.v4(), name: 'Morning Shift', startTime: '08:00 AM', endTime: '02:00 PM', graceMinutes: 15, assignedEmployees: 24),
      Shift(id: _uuid.v4(), name: 'Regular Shift', startTime: '09:00 AM', endTime: '05:00 PM', graceMinutes: 15, assignedEmployees: 32),
      Shift(id: _uuid.v4(), name: 'Evening Shift', startTime: '01:00 PM', endTime: '07:00 PM', graceMinutes: 10, assignedEmployees: 8),
    ];
    jobs = [];
    candidates = [];
    interviews = [];
    offers = [];
    appraisals = [];
    taxRecords = [];
    notifications = [];
    _init();
  }

  Future<void> _init() async {
    await _loadDepartments();
    await _loadDesignations();
    await _loadEmployees();
    await _loadAttendance();
    await _loadLeaves();
    await _loadSalaryStructures();
    await _loadPayrollRecords();
    _seedNotifications();
    await _loadShifts();
    await _loadAppraisals();
    await _loadJobs();
    await _loadCandidates();
    await _loadInterviews();
    await _loadOffers();
    await _loadLoans();
    await _loadAllowanceDeductions();
    await _loadTaxRecords();
    notifyListeners();
  }

  // ---------- Core collections ----------
  late List<Employee> employees;
  late List<Department> departments;
  late List<Designation> designations;
  late List<AttendanceRecord> attendance;
  late List<LeaveRequest> leaves;
  late List<Shift> shifts;
  late List<Appraisal> appraisals;
  late List<SalaryStructure> salaryStructures;
  late List<PayrollRecord> payrollRecords;
  late List<LoanAdvance> loans;
  late List<AllowanceDeduction> allowanceDeductions;
  late List<TaxRecord> taxRecords;
  late List<JobOpening> jobs;
  late List<Candidate> candidates;
  late List<InterviewSchedule> interviews;
  late List<JobOffer> offers;
  late List<AppNotification> notifications;

  bool sidebarCollapsed = false;
  void toggleSidebar() {
    sidebarCollapsed = !sidebarCollapsed;
    notifyListeners();
  }

  Future<void> _loadDepartments() async {
    try {
      final rows = await HrService().fetchDepartments();
      if (rows.isNotEmpty) {
        departments = rows.map((r) => Department(
          id: r['id'],
          name: r['name'] ?? '',
          head: r['head'] ?? '',
          status: r['status'] ?? 'Active',
        )).toList();
      } else if (departments.isEmpty) {
        departments = List.from(seed.departmentsSeed);
      }
    } catch (e) {
      debugPrint('HrState _loadDepartments fallback: $e');
      if (departments.isEmpty) {
        departments = List.from(seed.departmentsSeed);
      }
    }
    notifyListeners();
  }
  
 
  // ---------- Seeding helpers ----------
  void _seedAttendance() {
    attendance = [];
    final today = DateTime.now();
    for (final e in employees) {
      final rnd = e.empCode.hashCode % 10;
      AttendanceStatus status;
      if (e.status == EmployeeStatus.onLeave) {
        status = AttendanceStatus.onLeave;
      } else if (rnd < 7) {
        status = AttendanceStatus.present;
      } else if (rnd < 8) {
        status = AttendanceStatus.late;
      } else if (rnd < 9) {
        status = AttendanceStatus.halfDay;
      } else {
        status = AttendanceStatus.absent;
      }
      attendance.add(AttendanceRecord(
        id: _uuid.v4(),
        employeeId: e.id,
        employeeName: e.name,
        department: e.department,
        date: DateTime(today.year, today.month, today.day),
        checkIn: status == AttendanceStatus.absent ? '--' : '09:0${rnd % 5}',
        checkOut: status == AttendanceStatus.absent ? '--' : '05:1${rnd % 5}',
        status: status,
      ));
    }
  }

  void _seedLeaves() {
    final types = [
      'Casual Leave',
      'Medical Leave',
      'Earned Leave',
      'Sick Leave'
    ];
    final statuses = [
      LeaveStatus.pending,
      LeaveStatus.pending,
      LeaveStatus.approved,
      LeaveStatus.rejected,
      LeaveStatus.pending
    ];
    leaves = [];
    for (var i = 0; i < 5 && i < employees.length; i++) {
      final e = employees[i];
      final start = DateTime.now().add(Duration(days: i * 3));
      leaves.add(LeaveRequest(
        id: _uuid.v4(),
        employeeId: e.id,
        employeeName: e.name,
        leaveType: types[i % types.length],
        startDate: start,
        endDate: start.add(const Duration(days: 2)),
        days: 3,
        reason: 'Personal work',
        status: statuses[i % statuses.length],
      ));
    }
  }

  void _seedSalaryStructures() {
    salaryStructures = employees.map((e) {
      final basic = e.salary * 0.5;
      final hra = e.salary * 0.2;
      final conveyance = 1600.0;
      final medical = 1250.0;
      final special = e.salary - (basic + hra + conveyance + medical);
      return SalaryStructure(
        employeeId: e.id,
        basic: basic,
        hra: hra,
        conveyance: conveyance,
        medical: medical,
        specialAllowance: special < 0 ? 0 : special,
        pf: basic * 0.12,
        esi: e.salary <= 21000 ? e.salary * 0.0075 : 0,
        professionalTax: 200,
        otherDeductions: 0,
      );
    }).toList();
  }

  void _seedPayroll() {
    payrollRecords = [];
    for (final e in employees) {
      final s = salaryStructures.firstWhere((s) => s.employeeId == e.id);
      payrollRecords.add(PayrollRecord(
        id: _uuid.v4(),
        employeeId: e.id,
        employeeName: e.name,
        department: e.department,
        month: 'May 2024',
        gross: s.gross,
        allowances: s.hra + s.conveyance + s.medical + s.specialAllowance,
        deductions: s.totalDeductions,
        net: s.net,
        status: PayrollStatus.processed,
      ));
    }
  }

   void _seedLoans() {
    loans = [];
    if (employees.length > 3) {
      loans.add(LoanAdvance(
        id: _uuid.v4(),
        employeeId: employees[3].id,
        employeeName: employees[3].name,
        loanType: 'Salary Advance',
        amount: 20000,
        interestPercent: 0,
        tenureMonths: 4,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        remaining: 15000,
      ));
    }
    if (employees.length > 7) {
      loans.add(LoanAdvance(
        id: _uuid.v4(),
        employeeId: employees[7].id,
        employeeName: employees[7].name,
        loanType: 'Personal Loan',
        amount: 50000,
        interestPercent: 6,
        tenureMonths: 12,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        remaining: 42000,
      ));
    }
  }

  void _seedAllowances() {
    allowanceDeductions = [
      AllowanceDeduction(
          id: _uuid.v4(),
          name: 'House Rent Allowance',
          type: 'Allowance',
          calcType: 'Percentage',
          value: 20),
      AllowanceDeduction(
          id: _uuid.v4(),
          name: 'Conveyance Allowance',
          type: 'Allowance',
          calcType: 'Fixed',
          value: 1600),
      AllowanceDeduction(
          id: _uuid.v4(),
          name: 'Provident Fund',
          type: 'Deduction',
          calcType: 'Percentage',
          value: 12),
      AllowanceDeduction(
          id: _uuid.v4(),
          name: 'Professional Tax',
          type: 'Deduction',
          calcType: 'Fixed',
          value: 200),
    ];
  }

  Future<void> _loadTaxRecords() async {
    try {
      var rows = await HrService().fetchTaxRecords();
      if (rows.isEmpty && employees.isNotEmpty) {
        for (final e in employees.take(6)) {
          final annual = e.salary * 12;
          final taxable = annual - 50000;
          final tax = taxable > 700000 ? taxable * 0.1 : taxable * 0.05;
          try {
            await HrService().addTaxRecord({
              'employee_id': e.id,
              'financial_year': '2024-25',
              'annual_income': annual,
              'taxable_income': taxable,
              'tax': tax,
              'tds': tax / 12,
              'status': 'Filed',
            });
          } catch (_) {}
        }
        try {
          rows = await HrService().fetchTaxRecords();
        } catch (_) {}
      }
      if (rows.isNotEmpty) {
        taxRecords = rows.map((r) => TaxRecord(
          id: r['id'],
          employeeId: r['employee_id'] ?? '',
          employeeName: r['hr_employees']?['name'] ?? '',
          financialYear: r['financial_year'] ?? '',
          annualIncome: (r['annual_income'] as num?)?.toDouble() ?? 0,
          taxableIncome: (r['taxable_income'] as num?)?.toDouble() ?? 0,
          tax: (r['tax'] as num?)?.toDouble() ?? 0,
          tds: (r['tds'] as num?)?.toDouble() ?? 0,
          status: r['status'] ?? 'Filed',
        )).toList();
      } else if (taxRecords.isEmpty) {
        taxRecords = employees.take(6).map((e) {
          final annual = e.salary * 12;
          final taxable = annual - 50000;
          final tax = taxable > 700000 ? taxable * 0.1 : taxable * 0.05;
          return TaxRecord(
            id: _uuid.v4(),
            employeeId: e.id,
            employeeName: e.name,
            financialYear: '2024-25',
            annualIncome: annual,
            taxableIncome: taxable,
            tax: tax,
            tds: tax / 12,
            status: 'Filed',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('HrState _loadTaxRecords fallback: $e');
      if (taxRecords.isEmpty) {
        taxRecords = employees.take(6).map((e) {
          final annual = e.salary * 12;
          final taxable = annual - 50000;
          final tax = taxable > 700000 ? taxable * 0.1 : taxable * 0.05;
          return TaxRecord(
            id: _uuid.v4(),
            employeeId: e.id,
            employeeName: e.name,
            financialYear: '2024-25',
            annualIncome: annual,
            taxableIncome: taxable,
            tax: tax,
            tds: tax / 12,
            status: 'Filed',
          );
        }).toList();
      }
    }
    notifyListeners();
  }

   void _seedNotifications() {
    notifications = [];
    if (employees.length > 3) {
      notifications.add(AppNotification(
          id: _uuid.v4(),
          title: 'New leave request',
          message: '${employees[3].name} applied for Medical Leave',
          time: DateTime.now().subtract(const Duration(minutes: 20))));
    }
    notifications.add(AppNotification(
        id: _uuid.v4(),
        title: 'Payroll processing completed',
        message: 'May 2024 payroll processed for all departments',
        time: DateTime.now().subtract(const Duration(hours: 2))));
    if (employees.isNotEmpty) {
      notifications.add(AppNotification(
          id: _uuid.v4(),
          title: 'New employee added',
          message: '${employees[0].name} joined as ${employees[0].designation}',
          time: DateTime.now().subtract(const Duration(hours: 5))));
    }
    notifications.add(AppNotification(
        id: _uuid.v4(),
        title: 'Interview scheduled',
        message: 'Interview scheduled with Nikhil Bansal',
        time: DateTime.now().subtract(const Duration(days: 1))));
    notifications.add(AppNotification(
        id: _uuid.v4(),
        title: 'Payslip generated',
        message: 'Payslips generated for May 2024',
        time: DateTime.now().subtract(const Duration(days: 1, hours: 3))));
  }

  int get unreadNotifications => notifications.where((n) => !n.read).length;

  void markNotificationRead(String id) {
    final n = notifications.firstWhere((n) => n.id == id);
    n.read = true;
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (final n in notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  // ---------- Employee CRUD ----------
  Future<void> addEmployee(Employee e) async {
    final existingIdx = employees.indexWhere((x) => x.id == e.id);
    if (existingIdx != -1) {
      employees[existingIdx] = e;
    } else {
      employees.add(e);
    }
    structureFor(e.id);
    notifyListeners();
    try {
      await HrService().addEmployee({
        'emp_code': e.empCode,
        'name': e.name,
        'gender': e.gender,
        'dob': e.dob.toIso8601String().split('T').first,
        'email': e.email,
        'phone': e.phone,
        'address': e.address,
        'department': e.department,
        'designation': e.designation,
        'joining_date': e.joiningDate.toIso8601String().split('T').first,
        'employment_type': e.employmentType.name,
        'salary': e.salary,
        'bank_account': e.bankAccount,
        'pan': e.pan,
        'aadhaar': e.aadhaar,
        'emergency_contact': e.emergencyContact,
        'status': e.status.name,
        'avatar_color': e.avatarColor,
      });
      await _loadEmployees();
    } catch (err) {
      debugPrint('Error syncing addEmployee: $err');
    }
    notifyListeners();
  }

  Future<void> updateEmployee(Employee e) async {
    final idx = employees.indexWhere((x) => x.id == e.id);
    if (idx != -1) {
      employees[idx] = e;
      notifyListeners();
    }
    try {
      await HrService().updateEmployee(e.id, {
        'emp_code': e.empCode,
        'name': e.name,
        'gender': e.gender,
        'dob': e.dob.toIso8601String().split('T').first,
        'email': e.email,
        'phone': e.phone,
        'address': e.address,
        'department': e.department,
        'designation': e.designation,
        'joining_date': e.joiningDate.toIso8601String().split('T').first,
        'employment_type': e.employmentType.name,
        'salary': e.salary,
        'bank_account': e.bankAccount,
        'pan': e.pan,
        'aadhaar': e.aadhaar,
        'emergency_contact': e.emergencyContact,
        'status': e.status.name,
        'avatar_color': e.avatarColor,
      });
      await _loadEmployees();
    } catch (err) {
      debugPrint('Error syncing updateEmployee: $err');
    }
    notifyListeners();
  }

  Future<void> deleteEmployee(String id) async {
    employees.removeWhere((e) => e.id == id);
    notifyListeners();
    try {
      await HrService().deleteEmployee(id);
      await _loadEmployees();
    } catch (err) {
      debugPrint('Error syncing deleteEmployee: $err');
    }
    notifyListeners();
  }

  // ---------- Department CRUD ----------
  Future<void> addDepartment(Department d) async {
    final existingIdx = departments.indexWhere((x) => x.id == d.id);
    if (existingIdx != -1) {
      departments[existingIdx] = d;
    } else {
      departments.add(d);
    }
    notifyListeners();
    try {
      await HrService().addDepartment(d.name, d.head);
      await _loadDepartments();
    } catch (e) {
      debugPrint('Error syncing addDepartment: $e');
    }
    notifyListeners();
  }

  Future<void> updateDepartment(Department d) async {
    final idx = departments.indexWhere((x) => x.id == d.id);
    if (idx != -1) {
      departments[idx] = d;
      notifyListeners();
    }
    try {
      await HrService().updateDepartment(d.id, d.name, d.head);
      await _loadDepartments();
    } catch (e) {
      debugPrint('Error syncing updateDepartment: $e');
    }
    notifyListeners();
  }

  Future<void> deleteDepartment(String id) async {
    departments.removeWhere((d) => d.id == id);
    notifyListeners();
    try {
      await HrService().deleteDepartment(id);
      await _loadDepartments();
    } catch (e) {
      debugPrint('Error syncing deleteDepartment: $e');
    }
    notifyListeners();
  }

  Future<void> _loadDesignations() async {
    try {
      final rows = await HrService().fetchDesignations();
      if (rows.isNotEmpty) {
        designations = rows.map((r) => Designation(
          id: r['id'],
          name: r['name'] ?? '',
          department: r['department'] ?? '',
          description: r['description'] ?? '',
          status: r['status'] ?? 'Active',
        )).toList();
      } else if (designations.isEmpty) {
        designations = List.from(seed.designationsSeed);
      }
    } catch (e) {
      debugPrint('HrState _loadDesignations fallback: $e');
      if (designations.isEmpty) {
        designations = List.from(seed.designationsSeed);
      }
    }
    notifyListeners();
  }

  Future<void> _loadEmployees() async {
    try {
      final rows = await HrService().fetchEmployees();
      if (rows.isNotEmpty) {
        employees = rows.map((r) => Employee(
          id: r['id'],
          empCode: r['emp_code'] ?? '',
          name: r['name'] ?? '',
          gender: r['gender'] ?? '',
          dob: r['dob'] != null ? DateTime.parse(r['dob']) : DateTime(2000, 1, 1),
          email: r['email'] ?? '',
          phone: r['phone'] ?? '',
          address: r['address'] ?? '',
          department: r['department'] ?? '',
          designation: r['designation'] ?? '',
          joiningDate: r['joining_date'] != null ? DateTime.parse(r['joining_date']) : DateTime.now(),
          employmentType: EmploymentType.values.firstWhere(
            (e) => e.name == r['employment_type'], orElse: () => EmploymentType.fullTime),
          salary: (r['salary'] as num?)?.toDouble() ?? 0,
          bankAccount: r['bank_account'] ?? '',
          pan: r['pan'] ?? '',
          aadhaar: r['aadhaar'] ?? '',
          emergencyContact: r['emergency_contact'] ?? '',
          status: EmployeeStatus.values.firstWhere(
            (e) => e.name == r['status'], orElse: () => EmployeeStatus.active),
          avatarColor: r['avatar_color'] ?? 'blue',
        )).toList();
      } else if (employees.isEmpty) {
        employees = seed.buildEmployeeSeed();
      }
    } catch (e) {
      debugPrint('HrState _loadEmployees fallback: $e');
      if (employees.isEmpty) {
        employees = seed.buildEmployeeSeed();
      }
    }
    notifyListeners();
  } 

  int employeeCountForDepartment(String name) =>
      employees.where((e) => e.department == name).length;

  int employeeCountForDesignation(String name) =>
      employees.where((e) => e.designation == name).length;

  Future<void> addDesignation(Designation d) async {
    final existingIdx = designations.indexWhere((x) => x.id == d.id);
    if (existingIdx != -1) {
      designations[existingIdx] = d;
    } else {
      designations.add(d);
    }
    notifyListeners();
    try {
      await HrService().addDesignation(d.name, d.department, d.description);
      await _loadDesignations();
    } catch (e) {
      debugPrint('Error syncing addDesignation: $e');
    }
    notifyListeners();
  }

  Future<void> updateDesignation(Designation d) async {
    final idx = designations.indexWhere((x) => x.id == d.id);
    if (idx != -1) {
      designations[idx] = d;
      notifyListeners();
    }
    try {
      await HrService().updateDesignation(d.id, d.name, d.department, d.description);
      await _loadDesignations();
    } catch (e) {
      debugPrint('Error syncing updateDesignation: $e');
    }
    notifyListeners();
  }

  Future<void> deleteDesignation(String id) async {
    designations.removeWhere((d) => d.id == id);
    notifyListeners();
    try {
      await HrService().deleteDesignation(id);
      await _loadDesignations();
    } catch (e) {
      debugPrint('Error syncing deleteDesignation: $e');
    }
    notifyListeners();
  }
  Future<void> _loadAttendance() async {
    try {
      final rows = await HrService().fetchAttendance();
      if (rows.isNotEmpty) {
        attendance = rows.map((r) => AttendanceRecord(
          id: r['id'],
          employeeId: r['employee_id'] ?? '',
          employeeName: r['hr_employees']?['name'] ?? '',
          department: r['hr_employees']?['department'] ?? '',
          date: r['attendance_date'] != null ? DateTime.parse(r['attendance_date']) : DateTime.now(),
          checkIn: r['check_in'] ?? '--',
          checkOut: r['check_out'] ?? '--',
          status: AttendanceStatus.values.firstWhere(
            (s) => s.name == r['status'], orElse: () => AttendanceStatus.present),
        )).toList();
      } else if (attendance.isEmpty) {
        _seedAttendance();
      }
    } catch (e) {
      debugPrint('HrState _loadAttendance fallback: $e');
      if (attendance.isEmpty) _seedAttendance();
    }
    notifyListeners();
  }

  Future<void> _loadLeaves() async {
    try {
      final rows = await HrService().fetchLeaves();
      if (rows.isNotEmpty) {
        leaves = rows.map((r) => LeaveRequest(
          id: r['id'],
          employeeId: r['employee_id'] ?? '',
          employeeName: r['hr_employees']?['name'] ?? '',
          leaveType: r['leave_type'] ?? '',
          startDate: r['start_date'] != null ? DateTime.parse(r['start_date']) : DateTime.now(),
          endDate: r['end_date'] != null ? DateTime.parse(r['end_date']) : DateTime.now(),
          days: r['days'] ?? 1,
          reason: r['reason'] ?? '',
          status: LeaveStatus.values.firstWhere(
            (s) => s.name == r['status'], orElse: () => LeaveStatus.pending),
        )).toList();
      } else if (leaves.isEmpty) {
        _seedLeaves();
      }
    } catch (e) {
      debugPrint('HrState _loadLeaves fallback: $e');
      if (leaves.isEmpty) _seedLeaves();
    }
    notifyListeners();
  }

  Future<void> _loadSalaryStructures() async {
    try {
      final rows = await HrService().fetchSalaryStructures();
      if (rows.isNotEmpty) {
        salaryStructures = rows.map((r) => SalaryStructure(
          employeeId: r['employee_id'] ?? '',
          basic: (r['basic'] as num?)?.toDouble() ?? 0,
          hra: (r['hra'] as num?)?.toDouble() ?? 0,
          conveyance: (r['conveyance'] as num?)?.toDouble() ?? 0,
          medical: (r['medical'] as num?)?.toDouble() ?? 0,
          specialAllowance: (r['special_allowance'] as num?)?.toDouble() ?? 0,
          pf: (r['pf'] as num?)?.toDouble() ?? 0,
          esi: (r['esi'] as num?)?.toDouble() ?? 0,
          professionalTax: (r['professional_tax'] as num?)?.toDouble() ?? 0,
          otherDeductions: (r['other_deductions'] as num?)?.toDouble() ?? 0,
        )).toList();
      } else if (salaryStructures.isEmpty) {
        _seedSalaryStructures();
      }
    } catch (e) {
      debugPrint('HrState _loadSalaryStructures fallback: $e');
      if (salaryStructures.isEmpty) _seedSalaryStructures();
    }
    notifyListeners();
  }

  Future<void> _loadPayrollRecords() async {
    try {
      final rows = await HrService().fetchPayrollRecords();
      if (rows.isNotEmpty) {
        payrollRecords = rows.map((r) => PayrollRecord(
          id: r['id'],
          employeeId: r['employee_id'] ?? '',
          employeeName: r['hr_employees']?['name'] ?? '',
          department: r['hr_employees']?['department'] ?? '',
          month: r['month'] ?? '',
          gross: (r['gross'] as num?)?.toDouble() ?? 0,
          allowances: (r['allowances'] as num?)?.toDouble() ?? 0,
          deductions: (r['deductions'] as num?)?.toDouble() ?? 0,
          net: (r['net'] as num?)?.toDouble() ?? 0,
          status: PayrollStatus.values.firstWhere(
            (s) => s.name == r['status'], orElse: () => PayrollStatus.processed),
        )).toList();
      } else if (payrollRecords.isEmpty) {
        _seedPayroll();
      }
    } catch (e) {
      debugPrint('HrState _loadPayrollRecords fallback: $e');
      if (payrollRecords.isEmpty) _seedPayroll();
    }
    notifyListeners();
  }

  Future<void> _loadLoans() async {
    try {
      final rows = await HrService().fetchLoans();
      if (rows.isNotEmpty) {
        loans = rows.map((r) => LoanAdvance(
          id: r['id'],
          employeeId: r['employee_id'] ?? '',
          employeeName: r['hr_employees']?['name'] ?? '',
          loanType: r['loan_type'] ?? '',
          amount: (r['amount'] as num?)?.toDouble() ?? 0,
          interestPercent: (r['interest_percent'] as num?)?.toDouble() ?? 0,
          tenureMonths: r['tenure_months'] ?? 1,
          startDate: r['start_date'] != null ? DateTime.parse(r['start_date']) : DateTime.now(),
          remaining: (r['remaining'] as num?)?.toDouble() ?? 0,
        )).toList();
      } else if (loans.isEmpty) {
        _seedLoans();
      }
    } catch (e) {
      debugPrint('HrState _loadLoans fallback: $e');
      if (loans.isEmpty) _seedLoans();
    }
    notifyListeners();
  }

  Future<void> _loadAllowanceDeductions() async {
    try {
      final rows = await HrService().fetchAllowanceDeductions();
      if (rows.isNotEmpty) {
        allowanceDeductions = rows.map((r) => AllowanceDeduction(
          id: r['id'],
          name: r['name'] ?? '',
          type: r['type'] ?? '',
          calcType: r['calc_type'] ?? '',
          value: (r['value'] as num?)?.toDouble() ?? 0,
          enabled: r['enabled'] ?? true,
        )).toList();
      } else if (allowanceDeductions.isEmpty) {
        _seedAllowances();
      }
    } catch (e) {
      debugPrint('HrState _loadAllowanceDeductions fallback: $e');
      if (allowanceDeductions.isEmpty) _seedAllowances();
    }
    notifyListeners();
  }

  Future<void> _loadShifts() async {
    try {
      final rows = await HrService().fetchShifts();
      if (rows.isNotEmpty) {
        shifts = rows.map((r) => Shift(
          id: r['id'],
          name: r['name'] ?? '',
          startTime: r['start_time'] ?? '',
          endTime: r['end_time'] ?? '',
          graceMinutes: r['grace_minutes'] ?? 10,
          assignedEmployees: r['assigned_employees'] ?? 0,
        )).toList();
      } else if (shifts.isEmpty) {
        shifts = [
          Shift(id: _uuid.v4(), name: 'Morning Shift', startTime: '08:00 AM', endTime: '02:00 PM', graceMinutes: 15, assignedEmployees: 24),
          Shift(id: _uuid.v4(), name: 'Regular Shift', startTime: '09:00 AM', endTime: '05:00 PM', graceMinutes: 15, assignedEmployees: 32),
          Shift(id: _uuid.v4(), name: 'Evening Shift', startTime: '01:00 PM', endTime: '07:00 PM', graceMinutes: 10, assignedEmployees: 8),
        ];
      }
    } catch (e) {
      debugPrint('HrState _loadShifts fallback: $e');
      if (shifts.isEmpty) {
        shifts = [
          Shift(id: _uuid.v4(), name: 'Morning Shift', startTime: '08:00 AM', endTime: '02:00 PM', graceMinutes: 15, assignedEmployees: 24),
          Shift(id: _uuid.v4(), name: 'Regular Shift', startTime: '09:00 AM', endTime: '05:00 PM', graceMinutes: 15, assignedEmployees: 32),
          Shift(id: _uuid.v4(), name: 'Evening Shift', startTime: '01:00 PM', endTime: '07:00 PM', graceMinutes: 10, assignedEmployees: 8),
        ];
      }
    }
    notifyListeners();
  }

  Future<void> _loadAppraisals() async {
    try {
      final rows = await HrService().fetchAppraisals();
      appraisals = rows.map((r) => Appraisal(
        id: r['id'],
        employeeId: r['employee_id'] ?? '',
        employeeName: r['hr_employees']?['name'] ?? '',
        reviewPeriod: r['review_period'] ?? '',
        score: (r['score'] as num?)?.toDouble() ?? 0,
        goals: r['goals'] ?? '',
        managerFeedback: r['manager_feedback'] ?? '',
        employeeFeedback: r['employee_feedback'] ?? '',
        status: r['status'] ?? 'Pending',
      )).toList();
    } catch (e) {
      debugPrint('HrState _loadAppraisals fallback: $e');
    }
    notifyListeners();
  }

  Future<void> _loadJobs() async {
    try {
      final rows = await HrService().fetchJobs();
      jobs = rows.map((r) => JobOpening(
        id: r['id'],
        title: r['title'] ?? '',
        department: r['department'] ?? '',
        location: r['location'] ?? '',
        employmentType: r['employment_type'] ?? '',
        vacancies: r['vacancies'] ?? 1,
        applications: r['applications'] ?? 0,
        status: r['status'] ?? 'Open',
      )).toList();
    } catch (e) {
      debugPrint('HrState _loadJobs fallback: $e');
    }
    notifyListeners();
  }

  Future<void> _loadCandidates() async {
    try {
      final rows = await HrService().fetchCandidates();
      candidates = rows.map((r) {
        final raw = r['skills'];
        List<String> skillsList;
        if (raw is List) {
          skillsList = raw.map((s) => s.toString()).toList();
        } else if (raw is String) {
          skillsList = raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        } else {
          skillsList = [];
        }
        return Candidate(
          id: r['id'],
          name: r['name'] ?? '',
          position: r['position'] ?? '',
          experience: r['experience'] ?? '',
          skills: skillsList,
          interviewStatus: r['interview_status'] ?? 'Pending',
          applicationStatus: r['application_status'] ?? 'Applied',
        );
      }).toList();
    } catch (e) {
      debugPrint('HrState _loadCandidates fallback: $e');
    }
    notifyListeners();
  }

  Future<void> _loadInterviews() async {
    try {
      final rows = await HrService().fetchInterviews();
      interviews = rows.map((r) => InterviewSchedule(
        id: r['id'],
        candidateName: r['candidate_name'] ?? '',
        position: r['position'] ?? '',
        interviewer: r['interviewer'] ?? '',
        date: DateTime.parse(r['interview_date']),
        time: r['interview_time'] ?? '',
        mode: r['mode'] ?? '',
        status: r['status'] ?? 'Scheduled',
      )).toList();
    } catch (e) {
      debugPrint('HrState _loadInterviews fallback: $e');
    }
    notifyListeners();
  }

  Future<void> _loadOffers() async {
    try {
      final rows = await HrService().fetchOffers();
      offers = rows.map((r) => JobOffer(
        id: r['id'],
        candidateName: r['candidate_name'] ?? '',
        position: r['position'] ?? '',
        salary: (r['salary'] as num?)?.toDouble() ?? 0,
        joiningDate: DateTime.parse(r['joining_date']),
        status: r['status'] ?? 'Pending',
      )).toList();
    } catch (e) {
      debugPrint('HrState _loadOffers fallback: $e');
    }
    notifyListeners();
  }

  // ---------- Attendance Mutations ----------
  Future<void> markAttendance(AttendanceRecord record) async {
    final idx = attendance.indexWhere((a) => a.id == record.id || (a.employeeId == record.employeeId && a.date.year == record.date.year && a.date.month == record.date.month && a.date.day == record.date.day));
    if (idx != -1) {
      attendance[idx] = record;
    } else {
      attendance.insert(0, record);
    }
    notifyListeners();
    try {
      await HrService().markAttendance(record.employeeId, record.status.name, record.checkIn, record.checkOut);
      await _loadAttendance();
    } catch (e) {
      debugPrint('Error syncing markAttendance: $e');
    }
    notifyListeners();
  }

  Future<void> updateAttendanceStatus(String id, AttendanceStatus status) async {
    final idx = attendance.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final old = attendance[idx];
      attendance[idx] = AttendanceRecord(
        id: old.id,
        employeeId: old.employeeId,
        employeeName: old.employeeName,
        department: old.department,
        date: old.date,
        checkIn: status == AttendanceStatus.absent ? '--' : old.checkIn,
        checkOut: status == AttendanceStatus.absent ? '--' : old.checkOut,
        status: status,
      );
      notifyListeners();
    }
    try {
      await HrService().updateAttendanceStatus(id, status.name);
      await _loadAttendance();
    } catch (e) {
      debugPrint('Error syncing updateAttendanceStatus: $e');
    }
    notifyListeners();
  }

  // ---------- Leave Mutations ----------
  Future<void> applyLeave(LeaveRequest req) async {
    leaves.insert(0, req);
    notifications.insert(
      0,
      AppNotification(
        id: _uuid.v4(),
        title: 'New leave request',
        message: '${req.employeeName} applied for ${req.leaveType}',
        time: DateTime.now(),
      ),
    );
    notifyListeners();
    try {
      await HrService().applyLeave({
        'employee_id': req.employeeId,
        'leave_type': req.leaveType,
        'start_date': req.startDate.toIso8601String().split('T').first,
        'end_date': req.endDate.toIso8601String().split('T').first,
        'days': req.days,
        'reason': req.reason,
        'status': req.status.name,
      });
      await _loadLeaves();
    } catch (e) {
      debugPrint('Error syncing applyLeave: $e');
    }
    notifyListeners();
  }

  Future<void> setLeaveStatus(String id, LeaveStatus status) async {
    final idx = leaves.indexWhere((l) => l.id == id);
    if (idx != -1) {
      final old = leaves[idx];
      leaves[idx] = LeaveRequest(
        id: old.id,
        employeeId: old.employeeId,
        employeeName: old.employeeName,
        leaveType: old.leaveType,
        startDate: old.startDate,
        endDate: old.endDate,
        days: old.days,
        reason: old.reason,
        status: status,
      );
      notifyListeners();
    }
    try {
      await HrService().setLeaveStatus(id, status.name);
      await _loadLeaves();
    } catch (e) {
      debugPrint('Error syncing setLeaveStatus: $e');
    }
    notifyListeners();
  }

  // ---------- Shift Mutations ----------
  Future<void> addShift(Shift s) async {
    shifts.add(s);
    notifyListeners();
    try {
      await HrService().addShift({
        'name': s.name,
        'start_time': s.startTime,
        'end_time': s.endTime,
        'grace_minutes': s.graceMinutes,
        'assigned_employees': s.assignedEmployees,
      });
      await _loadShifts();
    } catch (e) {
      debugPrint('Error syncing addShift: $e');
    }
    notifyListeners();
  }

  Future<void> updateShift(Shift s) async {
    final idx = shifts.indexWhere((x) => x.id == s.id);
    if (idx != -1) {
      shifts[idx] = s;
      notifyListeners();
    }
    try {
      await HrService().updateShift(s.id, {
        'name': s.name,
        'start_time': s.startTime,
        'end_time': s.endTime,
        'grace_minutes': s.graceMinutes,
      });
      await _loadShifts();
    } catch (e) {
      debugPrint('Error syncing updateShift: $e');
    }
    notifyListeners();
  }

  Future<void> deleteShift(String id) async {
    shifts.removeWhere((s) => s.id == id);
    notifyListeners();
    try {
      await HrService().deleteShift(id);
      await _loadShifts();
    } catch (e) {
      debugPrint('Error syncing deleteShift: $e');
    }
    notifyListeners();
  }

  // ---------- Appraisal Mutations ----------
  Future<void> addAppraisal(Appraisal a) async {
    appraisals.insert(0, a);
    notifyListeners();
    try {
      await HrService().addAppraisal({
        'employee_id': a.employeeId,
        'review_period': a.reviewPeriod,
        'score': a.score,
        'goals': a.goals,
        'manager_feedback': a.managerFeedback,
        'employee_feedback': a.employeeFeedback,
        'status': a.status,
      });
      await _loadAppraisals();
    } catch (e) {
      debugPrint('Error syncing addAppraisal: $e');
    }
    notifyListeners();
  }

  Future<void> updateAppraisal(Appraisal a) async {
    final idx = appraisals.indexWhere((x) => x.id == a.id);
    if (idx != -1) {
      appraisals[idx] = a;
      notifyListeners();
    }
    try {
      await HrService().updateAppraisal(a.id, {
        'review_period': a.reviewPeriod,
        'score': a.score,
        'goals': a.goals,
        'manager_feedback': a.managerFeedback,
        'employee_feedback': a.employeeFeedback,
        'status': a.status,
      });
      await _loadAppraisals();
    } catch (e) {
      debugPrint('Error syncing updateAppraisal: $e');
    }
    notifyListeners();
  }

  // ---------- Salary structure ----------
  SalaryStructure structureFor(String employeeId) => salaryStructures
      .firstWhere((s) => s.employeeId == employeeId, orElse: () {
    final s = SalaryStructure(
      employeeId: employeeId,
      basic: 0,
      hra: 0,
      conveyance: 0,
      medical: 0,
      specialAllowance: 0,
      pf: 0,
      esi: 0,
      professionalTax: 0,
      otherDeductions: 0,
    );
    salaryStructures.add(s);
    return s;
  });

  Future<void> updateSalaryStructure(SalaryStructure s) async {
    final idx = salaryStructures.indexWhere((x) => x.employeeId == s.employeeId);
    if (idx != -1) {
      salaryStructures[idx] = s;
    } else {
      salaryStructures.add(s);
    }
    notifyListeners();
    try {
      await HrService().upsertSalaryStructure({
        'employee_id': s.employeeId,
        'basic': s.basic,
        'hra': s.hra,
        'conveyance': s.conveyance,
        'medical': s.medical,
        'special_allowance': s.specialAllowance,
        'pf': s.pf,
        'esi': s.esi,
        'professional_tax': s.professionalTax,
        'other_deductions': s.otherDeductions,
      });
      await _loadSalaryStructures();
    } catch (e) {
      debugPrint('Error syncing updateSalaryStructure: $e');
    }
    notifyListeners();
  }

  Future<void> processPayrollForMonth(String month, {String? department}) async {
    final targets = department == null || department == 'All Departments'
        ? employees
        : employees.where((e) => e.department == department).toList();
    for (final e in targets) {
      final s = structureFor(e.id);
      try {
        await HrService().upsertPayrollRecord({
          'employee_id': e.id,
          'month': month,
          'gross': s.gross,
          'allowances': s.hra + s.conveyance + s.medical + s.specialAllowance,
          'deductions': s.totalDeductions,
          'net': s.net,
          'status': 'processed',
        });
      } catch (err) {
        debugPrint('Supabase upsertPayrollRecord error: $err');
      }

      // Keep local state updated
      final existingIdx = payrollRecords.indexWhere(
          (p) => p.employeeId == e.id && p.month == month);
      final rec = PayrollRecord(
        id: existingIdx != -1 ? payrollRecords[existingIdx].id : _uuid.v4(),
        employeeId: e.id,
        employeeName: e.name,
        department: e.department,
        month: month,
        gross: s.gross,
        allowances: s.hra + s.conveyance + s.medical + s.specialAllowance,
        deductions: s.totalDeductions,
        net: s.net,
        status: PayrollStatus.processed,
      );
      if (existingIdx != -1) {
        payrollRecords[existingIdx] = rec;
      } else {
        payrollRecords.add(rec);
      }
    }
    notifications.insert(
      0,
      AppNotification(
        id: _uuid.v4(),
        title: 'Payroll processing completed',
        message: '$month payroll processed'
            '${department != null && department != 'All Departments' ? ' for $department' : ' for all departments'}',
        time: DateTime.now(),
      ),
    );
    try {
      await _loadPayrollRecords();
    } catch (_) {}
    notifyListeners();
  }

  // ---------- Loans ----------
  Future<void> addLoan(LoanAdvance l) async {
    loans.insert(0, l);
    notifyListeners();
    try {
      await HrService().addLoan({
        'employee_id': l.employeeId,
        'loan_type': l.loanType,
        'amount': l.amount,
        'interest_percent': l.interestPercent,
        'tenure_months': l.tenureMonths,
        'start_date': l.startDate.toIso8601String().split('T').first,
        'remaining': l.remaining,
      });
      await _loadLoans();
    } catch (e) {
      debugPrint('Error syncing addLoan: $e');
    }
    notifyListeners();
  }

  Future<void> updateLoan(LoanAdvance l) async {
    final idx = loans.indexWhere((x) => x.id == l.id);
    if (idx != -1) {
      loans[idx] = l;
      notifyListeners();
    }
    try {
      await HrService().updateLoan(l.id, {
        'loan_type': l.loanType,
        'amount': l.amount,
        'interest_percent': l.interestPercent,
        'tenure_months': l.tenureMonths,
        'remaining': l.remaining,
      });
      await _loadLoans();
    } catch (e) {
      debugPrint('Error syncing updateLoan: $e');
    }
    notifyListeners();
  }

  // ---------- Allowances / Deductions ----------
  Future<void> addAllowanceDeduction(AllowanceDeduction a) async {
    allowanceDeductions.add(a);
    notifyListeners();
    try {
      await HrService().addAllowanceDeduction({
        'name': a.name,
        'type': a.type,
        'calc_type': a.calcType,
        'value': a.value,
        'enabled': a.enabled,
      });
      await _loadAllowanceDeductions();
    } catch (e) {
      debugPrint('Error syncing addAllowanceDeduction: $e');
    }
    notifyListeners();
  }

  Future<void> toggleAllowanceDeduction(String id) async {
    final idx = allowanceDeductions.indexWhere((x) => x.id == id);
    if (idx != -1) {
      final a = allowanceDeductions[idx];
      final updated = AllowanceDeduction(
        id: a.id,
        name: a.name,
        type: a.type,
        calcType: a.calcType,
        value: a.value,
        enabled: !a.enabled,
      );
      allowanceDeductions[idx] = updated;
      notifyListeners();
      try {
        await HrService().toggleAllowanceDeduction(id, updated.enabled);
        await _loadAllowanceDeductions();
      } catch (e) {
        debugPrint('Error syncing toggleAllowanceDeduction: $e');
      }
      notifyListeners();
    }
  }

  Future<void> deleteAllowanceDeduction(String id) async {
    allowanceDeductions.removeWhere((x) => x.id == id);
    notifyListeners();
    try {
      await HrService().deleteAllowanceDeduction(id);
      await _loadAllowanceDeductions();
    } catch (e) {
      debugPrint('Error syncing deleteAllowanceDeduction: $e');
    }
    notifyListeners();
  }

  // ---------- Recruitment ----------
  Future<void> addJob(JobOpening j) async {
    jobs.insert(0, j);
    notifyListeners();
    try {
      await HrService().addJob({
        'title': j.title,
        'department': j.department,
        'location': j.location,
        'employment_type': j.employmentType,
        'vacancies': j.vacancies,
        'applications': j.applications,
        'status': j.status,
      });
      await _loadJobs();
    } catch (e) {
      debugPrint('Error syncing addJob: $e');
    }
    notifyListeners();
  }

  Future<void> updateJob(JobOpening j) async {
    final idx = jobs.indexWhere((x) => x.id == j.id);
    if (idx != -1) {
      jobs[idx] = j;
      notifyListeners();
    }
    try {
      await HrService().updateJob(j.id, {
        'title': j.title,
        'department': j.department,
        'location': j.location,
        'employment_type': j.employmentType,
        'vacancies': j.vacancies,
        'status': j.status,
      });
      await _loadJobs();
    } catch (e) {
      debugPrint('Error syncing updateJob: $e');
    }
    notifyListeners();
  }

  Future<void> deleteJob(String id) async {
    jobs.removeWhere((x) => x.id == id);
    notifyListeners();
    try {
      await HrService().deleteJob(id);
      await _loadJobs();
    } catch (e) {
      debugPrint('Error syncing deleteJob: $e');
    }
    notifyListeners();
  }

  Future<void> addCandidate(Candidate c) async {
    candidates.insert(0, c);
    notifyListeners();
    try {
      await HrService().addCandidate({
        'name': c.name,
        'position': c.position,
        'experience': c.experience,
        'skills': c.skills.join(', '),
        'interview_status': c.interviewStatus,
        'application_status': c.applicationStatus,
      });
      await _loadCandidates();
    } catch (e) {
      debugPrint('Error syncing addCandidate: $e');
    }
    notifyListeners();
  }

  Future<void> updateCandidateStatus(String id, {String? interview, String? application}) async {
    final idx = candidates.indexWhere((x) => x.id == id);
    if (idx != -1) {
      final old = candidates[idx];
      candidates[idx] = Candidate(
        id: old.id,
        name: old.name,
        position: old.position,
        experience: old.experience,
        skills: old.skills,
        interviewStatus: interview ?? old.interviewStatus,
        applicationStatus: application ?? old.applicationStatus,
      );
      notifyListeners();
    }
    try {
      await HrService().updateCandidateStatus(id, interview: interview, application: application);
      await _loadCandidates();
    } catch (e) {
      debugPrint('Error syncing updateCandidateStatus: $e');
    }
    notifyListeners();
  }

  Future<void> addInterview(InterviewSchedule i) async {
    interviews.insert(0, i);
    notifications.insert(
      0,
      AppNotification(
        id: _uuid.v4(),
        title: 'Interview scheduled',
        message: 'Interview scheduled with ${i.candidateName}',
        time: DateTime.now(),
      ),
    );
    notifyListeners();
    try {
      await HrService().addInterview({
        'candidate_name': i.candidateName,
        'position': i.position,
        'interviewer': i.interviewer,
        'interview_date': i.date.toIso8601String().split('T').first,
        'interview_time': i.time,
        'mode': i.mode,
        'status': i.status,
      });
      await _loadInterviews();
    } catch (e) {
      debugPrint('Error syncing addInterview: $e');
    }
    notifyListeners();
  }

  Future<void> addOffer(JobOffer o) async {
    offers.insert(0, o);
    notifyListeners();
    try {
      await HrService().addOffer({
        'candidate_name': o.candidateName,
        'position': o.position,
        'salary': o.salary,
        'joining_date': o.joiningDate.toIso8601String().split('T').first,
        'status': o.status,
      });
      await _loadOffers();
    } catch (e) {
      debugPrint('Error syncing addOffer: $e');
    }
    notifyListeners();
  }

  Future<void> updateOfferStatus(String id, String status) async {
    final idx = offers.indexWhere((x) => x.id == id);
    if (idx != -1) {
      final old = offers[idx];
      offers[idx] = JobOffer(
        id: old.id,
        candidateName: old.candidateName,
        position: old.position,
        salary: old.salary,
        joiningDate: old.joiningDate,
        status: status,
      );
      notifyListeners();
    }
    try {
      await HrService().updateOfferStatus(id, status);
      await _loadOffers();
    } catch (e) {
      debugPrint('Error syncing updateOfferStatus: $e');
    }
    notifyListeners();
  }

  // ---------- Dashboard derived data ----------
  int get totalEmployees => employees.length;
  int get totalDepartments => departments.length;

  double get attendanceTodayPercent {
    if (attendance.isEmpty) return 0;
    final present = attendance
        .where((a) =>
            a.status == AttendanceStatus.present ||
            a.status == AttendanceStatus.late ||
            a.status == AttendanceStatus.halfDay)
        .length;
    return (present / attendance.length) * 100;
  }

  int get onLeaveToday =>
      attendance.where((a) => a.status == AttendanceStatus.onLeave).length;

  int get absentToday =>
      attendance.where((a) => a.status == AttendanceStatus.absent).length;

  double get totalPayrollThisMonth => payrollRecords
      .where((p) => p.month == 'May 2024')
      .fold(0.0, (sum, p) => sum + p.net);

  double get pendingPayments => payrollRecords
      .where((p) => p.status != PayrollStatus.paid)
      .fold(0.0, (sum, p) => sum + p.net) *
      0.13; // mock pending fraction

  Map<String, int> get staffBreakdown {
    final teaching =
        employees.where((e) => e.department == 'Teaching').length;
    final nonTeaching = employees
        .where((e) =>
            e.department == 'Library' || e.department == 'Transport')
        .length;
    final admin = employees
        .where((e) =>
            e.department == 'Administration' ||
            e.department == 'HR' ||
            e.department == 'Accounts' ||
            e.department == 'IT')
        .length;
    final support =
        employees.where((e) => e.department == 'Support Staff').length;
    return {
      'Teaching Staff': teaching,
      'Non-Teaching Staff': nonTeaching,
      'Administrative Staff': admin,
      'Support Staff': support,
    };
  }

  List<Employee> get recentJoinings {
    final list = List<Employee>.from(employees);
    list.sort((a, b) => b.joiningDate.compareTo(a.joiningDate));
    return list.take(5).toList();
  }

  List<Employee> get upcomingBirthdays {
    final now = DateTime.now();
    final list = List<Employee>.from(employees);
    list.sort((a, b) {
      final aNext = DateTime(now.year, a.dob.month, a.dob.day);
      final bNext = DateTime(now.year, b.dob.month, b.dob.day);
      return aNext.difference(now).compareTo(bNext.difference(now));
    });
    return list.take(5).toList();
  }

  Map<String, int> get topDepartmentsByHeadcount {
    final map = <String, int>{};
    for (final d in departments) {
      map[d.name] = employeeCountForDepartment(d.name);
    }
    final sorted = Map.fromEntries(
        map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
    return sorted;
  }

  List<double> get payrollTrends6Months =>
      [1420000, 1510000, 1560000, 1620000, 1700000, totalPayrollThisMonth];

  List<String> get payrollTrendLabels =>
      ['Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May'];
}
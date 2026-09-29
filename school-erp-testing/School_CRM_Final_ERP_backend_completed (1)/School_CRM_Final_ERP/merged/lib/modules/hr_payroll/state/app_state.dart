import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../data/mock_data.dart' as seed;
import '../data/hr_service.dart';

const _uuid = Uuid();

class AppState extends ChangeNotifier {
    AppState() {
    employees = [];
    departments = [];
    designations = [];
    shifts = [];
    jobs = [];
    candidates = [];
    interviews = [];
    offers = [];
    attendance = [];
    leaves = [];
    salaryStructures = [];
    payrollRecords = [];
    appraisals = [];
    loans = [];
    allowanceDeductions = [];
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
    final rows = await HrService().fetchDepartments();
    departments = rows.map((r) => Department(
      id: r['id'],
      name: r['name'] ?? '',
      head: r['head'] ?? '',
      status: r['status'] ?? 'Active',
    )).toList();
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
    var rows = await HrService().fetchTaxRecords();
    if (rows.isEmpty && employees.isNotEmpty) {
      // First run for this institution: seed real tax records in Supabase
      // (computed once from current employees) instead of using in-memory mock data.
      for (final e in employees.take(6)) {
        final annual = e.salary * 12;
        final taxable = annual - 50000;
        final tax = taxable > 700000 ? taxable * 0.1 : taxable * 0.05;
        await HrService().addTaxRecord({
          'employee_id': e.id,
          'financial_year': '2024-25',
          'annual_income': annual,
          'taxable_income': taxable,
          'tax': tax,
          'tds': tax / 12,
          'status': 'Filed',
        });
      }
      rows = await HrService().fetchTaxRecords();
    }
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
  }
  Future<void> _loadAttendance() async {
    final rows = await HrService().fetchAttendance();
    attendance = rows.map((r) => AttendanceRecord(
      id: r['id'],
      employeeId: r['employee_id'],
      employeeName: r['hr_employees']?['name'] ?? '',
      department: r['hr_employees']?['department'] ?? '',
      date: DateTime.parse(r['attendance_date']),
      checkIn: r['check_in'] ?? '--',
      checkOut: r['check_out'] ?? '--',
      status: AttendanceStatus.values.firstWhere(
        (s) => s.name == r['status'], orElse: () => AttendanceStatus.present),
    )).toList();
    notifyListeners();
  }
    Future<void> _loadLeaves() async {
    final rows = await HrService().fetchLeaves();
    leaves = rows.map((r) => LeaveRequest(
      id: r['id'],
      employeeId: r['employee_id'],
      employeeName: r['hr_employees']?['name'] ?? '',
      leaveType: r['leave_type'] ?? '',
      startDate: DateTime.parse(r['start_date']),
      endDate: DateTime.parse(r['end_date']),
      days: r['days'] ?? 1,
      reason: r['reason'] ?? '',
      status: LeaveStatus.values.firstWhere(
        (s) => s.name == r['status'], orElse: () => LeaveStatus.pending),
    )).toList();
    notifyListeners();
  }
    Future<void> _loadSalaryStructures() async {
    final rows = await HrService().fetchSalaryStructures();
    salaryStructures = rows.map((r) => SalaryStructure(
      employeeId: r['employee_id'],
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
    notifyListeners();
  }
    Future<void> _loadPayrollRecords() async {
    final rows = await HrService().fetchPayrollRecords();
    payrollRecords = rows.map((r) => PayrollRecord(
      id: r['id'],
      employeeId: r['employee_id'],
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
    notifyListeners();
  }
    Future<void> _loadLoans() async {
    final rows = await HrService().fetchLoans();
    loans = rows.map((r) => LoanAdvance(
      id: r['id'],
      employeeId: r['employee_id'],
      employeeName: r['hr_employees']?['name'] ?? '',
      loanType: r['loan_type'] ?? '',
      amount: (r['amount'] as num?)?.toDouble() ?? 0,
      interestPercent: (r['interest_percent'] as num?)?.toDouble() ?? 0,
      tenureMonths: r['tenure_months'] ?? 1,
      startDate: DateTime.parse(r['start_date']),
      remaining: (r['remaining'] as num?)?.toDouble() ?? 0,
    )).toList();
    notifyListeners();
  }
    Future<void> _loadAllowanceDeductions() async {
    final rows = await HrService().fetchAllowanceDeductions();
    allowanceDeductions = rows.map((r) => AllowanceDeduction(
      id: r['id'],
      name: r['name'] ?? '',
      type: r['type'] ?? '',
      calcType: r['calc_type'] ?? '',
      value: (r['value'] as num?)?.toDouble() ?? 0,
      enabled: r['enabled'] ?? true,
    )).toList();
    notifyListeners();
  }

  Future<void> _loadShifts() async {
    final rows = await HrService().fetchShifts();
    shifts = rows.map((r) => Shift(
      id: r['id'],
      name: r['name'] ?? '',
      startTime: r['start_time'] ?? '',
      endTime: r['end_time'] ?? '',
      graceMinutes: r['grace_minutes'] ?? 10,
      assignedEmployees: r['assigned_employees'] ?? 0,
    )).toList();
    notifyListeners();
  }

  Future<void> _loadAppraisals() async {
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
    notifyListeners();
  }

  Future<void> _loadJobs() async {
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
    notifyListeners();
  }

  Future<void> _loadCandidates() async {
    final rows = await HrService().fetchCandidates();
    candidates = rows.map((r) => Candidate(
      id: r['id'],
      name: r['name'] ?? '',
      position: r['position'] ?? '',
      experience: r['experience'] ?? '',
      skills: (r['skills'] as List?)?.map((s) => s.toString()).toList() ?? [],
      interviewStatus: r['interview_status'] ?? 'Pending',
      applicationStatus: r['application_status'] ?? 'Applied',
    )).toList();
    notifyListeners();
  }

  Future<void> _loadInterviews() async {
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
    notifyListeners();
  }

  Future<void> _loadOffers() async {
    final rows = await HrService().fetchOffers();
    offers = rows.map((r) => JobOffer(
      id: r['id'],
      candidateName: r['candidate_name'] ?? '',
      position: r['position'] ?? '',
      salary: (r['salary'] as num?)?.toDouble() ?? 0,
      joiningDate: DateTime.parse(r['joining_date']),
      status: r['status'] ?? 'Pending',
    )).toList();
    notifyListeners();
  }

  Future<void> updateEmployee(Employee e) async {
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
  }

  Future<void> deleteEmployee(String id) async {
    await HrService().deleteEmployee(id);
    await _loadEmployees();
  }

  // ---------- Department CRUD ----------
  Future<void> addDepartment(Department d) async {
    await HrService().addDepartment(d.name, d.head);
    await _loadDepartments();
  }

  Future<void> updateDepartment(Department d) async {
    await HrService().updateDepartment(d.id, d.name, d.head);
    await _loadDepartments();
  }

  Future<void> deleteDepartment(String id) async {
    await HrService().deleteDepartment(id);
    await _loadDepartments();
  }
  Future<void> _loadDesignations() async {
    final rows = await HrService().fetchDesignations();
    designations = rows.map((r) => Designation(
      id: r['id'],
      name: r['name'] ?? '',
      department: r['department'] ?? '',
      description: r['description'] ?? '',
      status: r['status'] ?? 'Active',
    )).toList();
    notifyListeners();
  }
   Future<void> _loadEmployees() async {
    final rows = await HrService().fetchEmployees();
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
    notifyListeners();
  } 
  int employeeCountForDepartment(String name) =>
      employees.where((e) => e.department == name).length;
   Future<void> addDesignation(Designation d) async {
    await HrService().addDesignation(d.name, d.department, d.description);
    await _loadDesignations();
  }

  Future<void> updateDesignation(Designation d) async {
    await HrService().updateDesignation(d.id, d.name, d.department, d.description);
    await _loadDesignations();
  }

  Future<void> deleteDesignation(String id) async {
    await HrService().deleteDesignation(id);
    await _loadDesignations();
  }

  int employeeCountForDesignation(String name) =>
      employees.where((e) => e.designation == name).length;

  // ---------- Attendance ----------
    Future<void> markAttendance(AttendanceRecord record) async {
    await HrService().markAttendance(record.employeeId, record.status.name, record.checkIn, record.checkOut);
    await _loadAttendance();
  }

  Future<void> updateAttendanceStatus(String id, AttendanceStatus status) async {
    await HrService().updateAttendanceStatus(id, status.name);
    await _loadAttendance();
  }
  // ---------- Leave ----------
    Future<void> applyLeave(LeaveRequest req) async {
    await HrService().applyLeave({
      'employee_id': req.employeeId,
      'leave_type': req.leaveType,
      'start_date': req.startDate.toIso8601String().split('T').first,
      'end_date': req.endDate.toIso8601String().split('T').first,
      'days': req.days,
      'reason': req.reason,
      'status': req.status.name,
    });
    notifications.insert(
      0,
      AppNotification(
        id: _uuid.v4(),
        title: 'New leave request',
        message: '${req.employeeName} applied for ${req.leaveType}',
        time: DateTime.now(),
      ),
    );
    await _loadLeaves();
  }

  Future<void> setLeaveStatus(String id, LeaveStatus status) async {
    await HrService().setLeaveStatus(id, status.name);
    await _loadLeaves();
  }
  // ---------- Shifts ----------
  Future<void> addShift(Shift s) async {
    await HrService().addShift({
      'name': s.name,
      'start_time': s.startTime,
      'end_time': s.endTime,
      'grace_minutes': s.graceMinutes,
      'assigned_employees': s.assignedEmployees,
    });
    await _loadShifts();
  }

  Future<void> updateShift(Shift s) async {
    await HrService().updateShift(s.id, {
      'name': s.name,
      'start_time': s.startTime,
      'end_time': s.endTime,
      'grace_minutes': s.graceMinutes,
    });
    await _loadShifts();
  }

  Future<void> deleteShift(String id) async {
    await HrService().deleteShift(id);
    await _loadShifts();
  }

  // ---------- Appraisals ----------
  Future<void> addAppraisal(Appraisal a) async {
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
  }

  Future<void> updateAppraisal(Appraisal a) async {
    await HrService().updateAppraisal(a.id, {
      'review_period': a.reviewPeriod,
      'score': a.score,
      'goals': a.goals,
      'manager_feedback': a.managerFeedback,
      'employee_feedback': a.employeeFeedback,
      'status': a.status,
    });
    await _loadAppraisals();
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
  }

   Future<void> processPayrollForMonth(String month, {String? department}) async {
    final targets = department == null || department == 'All Departments'
        ? employees
        : employees.where((e) => e.department == department).toList();
    for (final e in targets) {
      final s = structureFor(e.id);
      await HrService().upsertPayrollRecord({
        'employee_id': e.id,
        'month': month,
        'gross': s.gross,
        'allowances': s.hra + s.conveyance + s.medical + s.specialAllowance,
        'deductions': s.totalDeductions,
        'net': s.net,
        'status': 'processed',
      });
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
    await _loadPayrollRecords();
  }

  // ---------- Loans ----------
   Future<void> addLoan(LoanAdvance l) async {
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
  }

  Future<void> updateLoan(LoanAdvance l) async {
    await HrService().updateLoan(l.id, {
      'loan_type': l.loanType,
      'amount': l.amount,
      'interest_percent': l.interestPercent,
      'tenure_months': l.tenureMonths,
      'remaining': l.remaining,
    });
    await _loadLoans();
  }

  // ---------- Allowances / Deductions ----------
    Future<void> addAllowanceDeduction(AllowanceDeduction a) async {
    await HrService().addAllowanceDeduction({
      'name': a.name,
      'type': a.type,
      'calc_type': a.calcType,
      'value': a.value,
      'enabled': a.enabled,
    });
    await _loadAllowanceDeductions();
  }

  Future<void> toggleAllowanceDeduction(String id) async {
    final a = allowanceDeductions.firstWhere((x) => x.id == id);
    await HrService().toggleAllowanceDeduction(id, !a.enabled);
    await _loadAllowanceDeductions();
  }

  Future<void> deleteAllowanceDeduction(String id) async {
    await HrService().deleteAllowanceDeduction(id);
    await _loadAllowanceDeductions();
  }

  // ---------- Recruitment ----------
  Future<void> addJob(JobOpening j) async {
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
  }

  Future<void> updateJob(JobOpening j) async {
    await HrService().updateJob(j.id, {
      'title': j.title,
      'department': j.department,
      'location': j.location,
      'employment_type': j.employmentType,
      'vacancies': j.vacancies,
      'status': j.status,
    });
    await _loadJobs();
  }

  Future<void> deleteJob(String id) async {
    await HrService().deleteJob(id);
    await _loadJobs();
  }

  Future<void> addCandidate(Candidate c) async {
    await HrService().addCandidate({
      'name': c.name,
      'position': c.position,
      'experience': c.experience,
      'skills': c.skills,
      'interview_status': c.interviewStatus,
      'application_status': c.applicationStatus,
    });
    await _loadCandidates();
  }

  Future<void> updateCandidateStatus(String id, {String? interview, String? application}) async {
    await HrService().updateCandidateStatus(id, interview: interview, application: application);
    await _loadCandidates();
  }

  Future<void> addInterview(InterviewSchedule i) async {
    await HrService().addInterview({
      'candidate_name': i.candidateName,
      'position': i.position,
      'interviewer': i.interviewer,
      'interview_date': i.date.toIso8601String().split('T').first,
      'interview_time': i.time,
      'mode': i.mode,
      'status': i.status,
    });
    notifications.insert(
      0,
      AppNotification(
        id: _uuid.v4(),
        title: 'Interview scheduled',
        message: 'Interview scheduled with ${i.candidateName}',
        time: DateTime.now(),
      ),
    );
    await _loadInterviews();
  }

  Future<void> addOffer(JobOffer o) async {
    await HrService().addOffer({
      'candidate_name': o.candidateName,
      'position': o.position,
      'salary': o.salary,
      'joining_date': o.joiningDate.toIso8601String().split('T').first,
      'status': o.status,
    });
    await _loadOffers();
  }

  Future<void> updateOfferStatus(String id, String status) async {
    await HrService().updateOfferStatus(id, status);
    await _loadOffers();
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
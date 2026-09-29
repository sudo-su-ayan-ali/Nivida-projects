enum EmployeeStatus { active, inactive, onLeave }

enum EmploymentType { fullTime, partTime, contract, intern }

class Employee {
  String id;
  String empCode;
  String name;
  String gender;
  DateTime dob;
  String email;
  String phone;
  String address;
  String department;
  String designation;
  DateTime joiningDate;
  EmploymentType employmentType;
  double salary;
  String bankAccount;
  String pan;
  String aadhaar;
  String emergencyContact;
  EmployeeStatus status;
  String avatarColor;

  Employee({
    required this.id,
    required this.empCode,
    required this.name,
    required this.gender,
    required this.dob,
    required this.email,
    required this.phone,
    required this.address,
    required this.department,
    required this.designation,
    required this.joiningDate,
    required this.employmentType,
    required this.salary,
    required this.bankAccount,
    required this.pan,
    required this.aadhaar,
    required this.emergencyContact,
    this.status = EmployeeStatus.active,
    this.avatarColor = 'blue',
  });
}

class Department {
  String id;
  String name;
  String head;
  String status;
  Department(
      {required this.id,
      required this.name,
      required this.head,
      this.status = 'Active'});
}

class Designation {
  String id;
  String name;
  String department;
  String description;
  String status;
  Designation({
    required this.id,
    required this.name,
    required this.department,
    required this.description,
    this.status = 'Active',
  });
}

enum AttendanceStatus { present, absent, late, halfDay, onLeave }

class AttendanceRecord {
  String id;
  String employeeId;
  String employeeName;
  String department;
  DateTime date;
  String checkIn;
  String checkOut;
  AttendanceStatus status;
  AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });
}

enum LeaveStatus { pending, approved, rejected, cancelled }

class LeaveRequest {
  String id;
  String employeeId;
  String employeeName;
  String leaveType;
  DateTime startDate;
  DateTime endDate;
  int days;
  String reason;
  LeaveStatus status;
  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    this.status = LeaveStatus.pending,
  });
}

class Shift {
  String id;
  String name;
  String startTime;
  String endTime;
  int graceMinutes;
  int assignedEmployees;
  Shift({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.graceMinutes,
    this.assignedEmployees = 0,
  });
}

class Appraisal {
  String id;
  String employeeId;
  String employeeName;
  String reviewPeriod;
  double score; // out of 5
  String goals;
  String managerFeedback;
  String employeeFeedback;
  String status;
  Appraisal({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.reviewPeriod,
    required this.score,
    required this.goals,
    required this.managerFeedback,
    required this.employeeFeedback,
    this.status = 'Pending',
  });
}

class SalaryStructure {
  String employeeId;
  double basic;
  double hra;
  double conveyance;
  double medical;
  double specialAllowance;
  double pf;
  double esi;
  double professionalTax;
  double otherDeductions;

  SalaryStructure({
    required this.employeeId,
    required this.basic,
    required this.hra,
    required this.conveyance,
    required this.medical,
    required this.specialAllowance,
    required this.pf,
    required this.esi,
    required this.professionalTax,
    required this.otherDeductions,
  });

  double get gross => basic + hra + conveyance + medical + specialAllowance;
  double get totalDeductions => pf + esi + professionalTax + otherDeductions;
  double get net => gross - totalDeductions;
}

enum PayrollStatus { draft, processed, paid }

class PayrollRecord {
  String id;
  String employeeId;
  String employeeName;
  String department;
  String month; // e.g. "May 2024"
  double gross;
  double allowances;
  double deductions;
  double net;
  PayrollStatus status;
  PayrollRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.month,
    required this.gross,
    required this.allowances,
    required this.deductions,
    required this.net,
    this.status = PayrollStatus.draft,
  });
}

class LoanAdvance {
  String id;
  String employeeId;
  String employeeName;
  String loanType;
  double amount;
  double interestPercent;
  int tenureMonths;
  DateTime startDate;
  double remaining;
  String status;
  LoanAdvance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.loanType,
    required this.amount,
    required this.interestPercent,
    required this.tenureMonths,
    required this.startDate,
    required this.remaining,
    this.status = 'Active',
  });

  double get emi {
    final principalWithInterest = amount + (amount * interestPercent / 100);
    return tenureMonths == 0 ? 0 : principalWithInterest / tenureMonths;
  }
}

class AllowanceDeduction {
  String id;
  String name;
  String type; // Allowance / Deduction
  String calcType; // Fixed / Percentage
  double value;
  bool enabled;
  String appliesTo;
  AllowanceDeduction({
    required this.id,
    required this.name,
    required this.type,
    required this.calcType,
    required this.value,
    this.enabled = true,
    this.appliesTo = 'All Employees',
  });
}

class TaxRecord {
  String id;
  String employeeId;
  String employeeName;
  String financialYear;
  double annualIncome;
  double taxableIncome;
  double tax;
  double tds;
  String status;
  TaxRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.financialYear,
    required this.annualIncome,
    required this.taxableIncome,
    required this.tax,
    required this.tds,
    this.status = 'Filed',
  });
}

class JobOpening {
  String id;
  String title;
  String department;
  String location;
  String employmentType;
  int vacancies;
  int applications;
  String status;
  JobOpening({
    required this.id,
    required this.title,
    required this.department,
    required this.location,
    required this.employmentType,
    required this.vacancies,
    required this.applications,
    this.status = 'Open',
  });
}

class Candidate {
  String id;
  String name;
  String position;
  String experience;
  List<String> skills;
  String interviewStatus;
  String applicationStatus;
  Candidate({
    required this.id,
    required this.name,
    required this.position,
    required this.experience,
    required this.skills,
    required this.interviewStatus,
    required this.applicationStatus,
  });
}

class InterviewSchedule {
  String id;
  String candidateName;
  String position;
  String interviewer;
  DateTime date;
  String time;
  String mode;
  String status;
  InterviewSchedule({
    required this.id,
    required this.candidateName,
    required this.position,
    required this.interviewer,
    required this.date,
    required this.time,
    required this.mode,
    this.status = 'Scheduled',
  });
}

class JobOffer {
  String id;
  String candidateName;
  String position;
  double salary;
  DateTime joiningDate;
  String status;
  JobOffer({
    required this.id,
    required this.candidateName,
    required this.position,
    required this.salary,
    required this.joiningDate,
    this.status = 'Pending',
  });
}

class AppNotification {
  String id;
  String title;
  String message;
  DateTime time;
  bool read;
  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.read = false,
  });
}

import 'package:uuid/uuid.dart';
import '../models/models.dart';

const _uuid = Uuid();

final departmentsSeed = <Department>[
  Department(id: _uuid.v4(), name: 'Teaching', head: 'Dr. Anjali Mehta'),
  Department(id: _uuid.v4(), name: 'Administration', head: 'Rakesh Kapoor'),
  Department(id: _uuid.v4(), name: 'Accounts', head: 'Sunita Verma'),
  Department(id: _uuid.v4(), name: 'IT', head: 'Vikram Joshi'),
  Department(id: _uuid.v4(), name: 'HR', head: 'Priya Singh'),
  Department(id: _uuid.v4(), name: 'Library', head: 'Kavita Shah'),
  Department(id: _uuid.v4(), name: 'Support Staff', head: 'Manoj Kumar'),
  Department(id: _uuid.v4(), name: 'Transport', head: 'Suresh Yadav'),
];

final designationsSeed = <Designation>[
  Designation(
      id: _uuid.v4(),
      name: 'Mathematics Teacher',
      department: 'Teaching',
      description: 'Teaches mathematics to senior classes'),
  Designation(
      id: _uuid.v4(),
      name: 'Science Teacher',
      department: 'Teaching',
      description: 'Teaches physics, chemistry & biology'),
  Designation(
      id: _uuid.v4(),
      name: 'English Teacher',
      department: 'Teaching',
      description: 'Teaches English language & literature'),
  Designation(
      id: _uuid.v4(),
      name: 'Admission Officer',
      department: 'Administration',
      description: 'Handles admissions & enquiries'),
  Designation(
      id: _uuid.v4(),
      name: 'Accountant',
      department: 'Accounts',
      description: 'Manages accounts & payroll'),
  Designation(
      id: _uuid.v4(),
      name: 'System Administrator',
      department: 'IT',
      description: 'Maintains IT infrastructure'),
  Designation(
      id: _uuid.v4(),
      name: 'HR Executive',
      department: 'HR',
      description: 'Manages HR operations'),
  Designation(
      id: _uuid.v4(),
      name: 'Librarian',
      department: 'Library',
      description: 'Manages library resources'),
  Designation(
      id: _uuid.v4(),
      name: 'Lab Assistant',
      department: 'Teaching',
      description: 'Assists in science labs'),
];

final _empNames = <List<String>>[
  ['Rohit Sharma', 'Male', 'Mathematics Teacher', 'Teaching'],
  ['Priya Singh', 'Female', 'Science Teacher', 'Teaching'],
  ['Ankit Verma', 'Male', 'Lab Assistant', 'Teaching'],
  ['Neha Patel', 'Female', 'Accountant', 'Accounts'],
  ['Vikram Joshi', 'Male', 'Admission Officer', 'Administration'],
  ['Sunita Reddy', 'Female', 'English Teacher', 'Teaching'],
  ['Rajesh Kumar', 'Male', 'Physics Teacher', 'Teaching'],
  ['Meena Iyer', 'Female', 'HR Executive', 'HR'],
  ['Arjun Patel', 'Male', 'System Administrator', 'IT'],
  ['Kavita Shah', 'Female', 'Librarian', 'Library'],
  ['Deepak Nair', 'Male', 'Mathematics Teacher', 'Teaching'],
  ['Anjali Mehta', 'Female', 'Science Teacher', 'Teaching'],
  ['Suresh Yadav', 'Male', 'Transport Coordinator', 'Transport'],
  ['Pooja Sharma', 'Female', 'English Teacher', 'Teaching'],
  ['Manoj Kumar', 'Male', 'Support Staff', 'Support Staff'],
  ['Kiran Rao', 'Female', 'Accountant', 'Accounts'],
  ['Amit Kumar', 'Male', 'Science Teacher', 'Teaching'],
  ['Sneha Iyer', 'Female', 'HR Executive', 'HR'],
  ['Rahul Verma', 'Male', 'System Administrator', 'IT'],
  ['Vivek Singh', 'Male', 'Mathematics Teacher', 'Teaching'],
];

List<Employee> buildEmployeeSeed() {
  final list = <Employee>[];
  for (var i = 0; i < _empNames.length; i++) {
    final n = _empNames[i];
    list.add(Employee(
      id: _uuid.v4(),
      empCode: 'EMP${(1001 + i)}',
      name: n[0],
      gender: n[1],
      dob: DateTime(1985 + (i % 15), (i % 12) + 1, (i % 27) + 1),
      email:
          '${n[0].toLowerCase().replaceAll(' ', '.')}@brightfuture.edu.in',
      phone: '98${(10000000 + i * 137).toString().substring(0, 8)}',
      address: 'Jodhpur, Rajasthan',
      department: n[3],
      designation: n[2],
      joiningDate: DateTime(2024, 5, (i % 27) + 1),
      employmentType: EmploymentType.fullTime,
      salary: 28000 + (i * 1350).toDouble(),
      bankAccount: 'XXXX-XXXX-${(1000 + i * 7)}',
      pan: 'ABCDE${1000 + i}F',
      aadhaar: 'XXXX-XXXX-${1000 + i}',
      emergencyContact: '99${(10000000 + i * 91).toString().substring(0, 8)}',
      status: i == 4 ? EmployeeStatus.onLeave : EmployeeStatus.active,
      avatarColor: ['blue', 'purple', 'teal', 'orange'][i % 4],
    ));
  }
  return list;
}

final shiftsSeed = <Shift>[
  Shift(
      id: _uuid.v4(),
      name: 'Morning Shift',
      startTime: '09:00 AM',
      endTime: '05:00 PM',
      graceMinutes: 10,
      assignedEmployees: 12),
  Shift(
      id: _uuid.v4(),
      name: 'General Shift',
      startTime: '10:00 AM',
      endTime: '06:00 PM',
      graceMinutes: 15,
      assignedEmployees: 6),
  Shift(
      id: _uuid.v4(),
      name: 'Night Shift',
      startTime: '10:00 PM',
      endTime: '06:00 AM',
      graceMinutes: 10,
      assignedEmployees: 2),
];

final jobsSeed = <JobOpening>[
  JobOpening(
      id: _uuid.v4(),
      title: 'Senior Mathematics Teacher',
      department: 'Teaching',
      location: 'Jodhpur',
      employmentType: 'Full Time',
      vacancies: 2,
      applications: 14),
  JobOpening(
      id: _uuid.v4(),
      title: 'IT Support Executive',
      department: 'IT',
      location: 'Jodhpur',
      employmentType: 'Full Time',
      vacancies: 1,
      applications: 9),
  JobOpening(
      id: _uuid.v4(),
      title: 'Front Office Executive',
      department: 'Administration',
      location: 'Jodhpur',
      employmentType: 'Full Time',
      vacancies: 1,
      applications: 6),
];

final candidatesSeed = <Candidate>[
  Candidate(
      id: _uuid.v4(),
      name: 'Nikhil Bansal',
      position: 'Senior Mathematics Teacher',
      experience: '6 years',
      skills: ['Mathematics', 'CBSE Curriculum'],
      interviewStatus: 'Scheduled',
      applicationStatus: 'In Review'),
  Candidate(
      id: _uuid.v4(),
      name: 'Ritu Chawla',
      position: 'IT Support Executive',
      experience: '3 years',
      skills: ['Networking', 'Hardware', 'Windows Admin'],
      interviewStatus: 'Pending',
      applicationStatus: 'Applied'),
  Candidate(
      id: _uuid.v4(),
      name: 'Sameer Khan',
      position: 'Front Office Executive',
      experience: '2 years',
      skills: ['Communication', 'MS Office'],
      interviewStatus: 'Completed',
      applicationStatus: 'Shortlisted'),
];

final interviewsSeed = <InterviewSchedule>[
  InterviewSchedule(
      id: _uuid.v4(),
      candidateName: 'Nikhil Bansal',
      position: 'Senior Mathematics Teacher',
      interviewer: 'Dr. Anjali Mehta',
      date: DateTime.now().add(const Duration(days: 2)),
      time: '11:00 AM',
      mode: 'In-person'),
  InterviewSchedule(
      id: _uuid.v4(),
      candidateName: 'Ritu Chawla',
      position: 'IT Support Executive',
      interviewer: 'Arjun Patel',
      date: DateTime.now().add(const Duration(days: 4)),
      time: '3:00 PM',
      mode: 'Online'),
];

final offersSeed = <JobOffer>[
  JobOffer(
      id: _uuid.v4(),
      candidateName: 'Sameer Khan',
      position: 'Front Office Executive',
      salary: 24000,
      joiningDate: DateTime.now().add(const Duration(days: 14)),
      status: 'Sent'),
];

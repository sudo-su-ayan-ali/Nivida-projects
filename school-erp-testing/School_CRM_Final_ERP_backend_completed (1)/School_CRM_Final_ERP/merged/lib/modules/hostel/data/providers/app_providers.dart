import '../../models/notice.dart';
import '../../models/staff.dart';
import '../hostel_service.dart';
import '../../models/block.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/student.dart';
import '../../models/room.dart';
import '../../models/payment.dart';
import '../../models/leave_request.dart';
import '../../models/complaint.dart';
import '../../models/maintenance_request.dart';
import '../../models/visitor.dart';
import '../../models/attendance_record.dart';
// mock_data.dart import hata diya — ab kahin use nahi ho raha (Step 4 dekho)

/// ---------- Simple app-wide UI state ----------
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);
final selectedHostelProvider = StateProvider<String>((ref) => 'Greenfield International Hostel');
final selectedAcademicYearProvider = StateProvider<String>((ref) => '2024-25');
final globalSearchProvider = StateProvider<String>((ref) => '');

/// ---------- Auth (disabled — module is always treated as logged in) ----------
class AuthState {
  final bool isLoggedIn;
  final bool loading;
  final String? error;
  final String name;
  final String role;
  const AuthState({
    this.isLoggedIn = true, // <-- hamesha true, login page kabhi nahi dikhega
    this.loading = false,
    this.error,
    this.name = 'Super Admin',
    this.role = 'Administrator',
  });

  AuthState copyWith({bool? isLoggedIn, bool? loading, String? error, String? name}) =>
      AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        loading: loading ?? false,
        error: error,
        name: name ?? this.name,
        role: role,
      );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());
  final _client = Supabase.instance.client;

  Future<void> logout() async {
    await _client.auth.signOut();
    state = const AuthState(); // isLoggedIn: true rehta hai — login page dobara nahi khulega
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) => AuthController());

/// ---------- Students ----------
final studentsProvider = FutureProvider<List<Student>>((ref) async {
  return HostelService().fetchHostelStudentsList();
});

/// ---------- Rooms ----------
final roomsProvider = FutureProvider<List<Room>>((ref) async {
  return HostelService().fetchRoomsWithModel();
});
final blocksProvider = FutureProvider<List<HostelBlock>>((ref) async {
  return HostelService().fetchBlocksWithOccupancy();
});

/// ---------- Payments ----------
final paymentsProvider = FutureProvider<List<Payment>>((ref) async {
  return HostelService().fetchHostelFeesList();
});

/// ---------- Leaves ----------
class LeavesController extends StateNotifier<List<LeaveRequest>> {
  LeavesController() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await HostelService().fetchLeaveRequests();
    state = rows.map((r) => LeaveRequest(
      id: r['id'],
      studentName: r['students']?['full_name'] ?? '',
      room: '',
      leaveType: r['leave_type'] ?? '',
      reason: r['reason'] ?? '',
      from: DateTime.parse(r['from_date']),
      to: DateTime.parse(r['to_date']),
      emergencyContact: r['emergency_contact'] ?? '',
      destination: r['destination'] ?? '',
      status: r['status'] ?? 'Pending',
    )).toList();
  }

  Future<void> updateStatus(String id, String status) async {
    await HostelService().updateLeaveStatus(id, status);
    state = [for (final l in state) if (l.id == id) (l..status = status) else l];
  }
}

final leavesProvider = StateNotifierProvider<LeavesController, List<LeaveRequest>>((ref) => LeavesController());

/// ---------- Complaints ----------
class ComplaintsController extends StateNotifier<List<Complaint>> {
  ComplaintsController() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await HostelService().fetchComplaints();
    state = rows.map((r) => Complaint(
      id: r['id'],
      studentName: r['students']?['full_name'] ?? '',
      room: '',
      category: r['category'] ?? '',
      description: r['description'] ?? '',
      priority: r['priority'] ?? 'Medium',
      date: r['created_at'] != null ? DateTime.parse(r['created_at']) : DateTime.now(),
      assignedTo: r['assigned_to'] ?? '',
      status: r['status'] ?? 'Open',
    )).toList();
  }

  Future<void> updateStatus(String id, String status) async {
    await HostelService().updateComplaintStatus(id, status);
    state = [for (final c in state) if (c.id == id) (c..status = status) else c];
  }
}

final complaintsProvider =
    StateNotifierProvider<ComplaintsController, List<Complaint>>((ref) => ComplaintsController());

/// ---------- Maintenance ----------
class MaintenanceController extends StateNotifier<List<MaintenanceRequest>> {
  MaintenanceController() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await HostelService().fetchMaintenanceRequests();
    state = rows.map((r) => MaintenanceRequest(
      id: r['id'],
      room: r['rooms']?['room_number'] ?? '',
      block: '',
      category: r['category'] ?? '',
      issue: r['issue'] ?? '',
      priority: r['priority'] ?? 'Medium',
      assignedStaff: r['assigned_staff'] ?? '',
      createdDate: r['created_at'] != null ? DateTime.parse(r['created_at']) : DateTime.now(),
      expectedDate: r['expected_date'] != null ? DateTime.parse(r['expected_date']) : DateTime.now(),
      status: r['status'] ?? 'Pending',
    )).toList();
  }

  Future<void> updateStatus(String id, String status) async {
    await HostelService().updateMaintenanceStatus(id, status);
    state = [for (final m in state) if (m.id == id) (m..status = status) else m];
  }
}

final maintenanceProvider =
    StateNotifierProvider<MaintenanceController, List<MaintenanceRequest>>((ref) => MaintenanceController());

/// ---------- Visitors ----------
class VisitorsController extends StateNotifier<List<Visitor>> {
  VisitorsController() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await HostelService().fetchVisitors();
    state = rows.map((r) => Visitor(
      id: r['id'],
      visitorName: r['visitor_name'] ?? '',
      studentName: r['students']?['full_name'] ?? '',
      relation: r['relation'] ?? '',
      phone: r['phone'] ?? '',
      idType: r['id_type'] ?? '',
      idNumber: r['id_number'] ?? '',
      purpose: r['purpose'] ?? '',
      checkIn: r['check_in'] != null ? DateTime.parse(r['check_in']) : DateTime.now(),
      checkOut: r['check_out'] != null ? DateTime.parse(r['check_out']) : null,
      status: r['status'] ?? 'Checked In',
    )).toList();
  }

  Future<void> checkOut(String id) async {
    await HostelService().checkOutVisitor(id);
    state = [for (final v in state) if (v.id == id) (v..status = 'Checked Out'..checkOut = DateTime.now()) else v];
  }
}

final visitorsProvider = StateNotifierProvider<VisitorsController, List<Visitor>>((ref) => VisitorsController());

/// ---------- Notices ----------
final noticesProvider = FutureProvider<List<Notice>>((ref) async {
  final rows = await HostelService().fetchNotices();
  return rows.map((r) => Notice(
    id: r['id'],
    title: r['title'] ?? '',
    description: r['description'] ?? '',
    category: r['category'] ?? '',
    audience: r['audience'] ?? '',
    publishDate: r['publish_date'] != null ? DateTime.parse(r['publish_date']) : DateTime.now(),
    expiryDate: r['expiry_date'] != null ? DateTime.parse(r['expiry_date']) : DateTime.now(),
    priority: r['priority'] ?? 'Normal',
    status: r['status'] ?? 'Active',
  )).toList();
});

/// ---------- Staff ----------
final staffProvider = FutureProvider<List<StaffMember>>((ref) async {
  final rows = await HostelService().fetchStaff();
  return rows.map((r) => StaffMember(
    id: r['id'],
    name: r['name'] ?? '',
    employeeId: r['employee_id'] ?? '',
    role: r['role'] ?? '',
    phone: r['phone'] ?? '',
    email: r['email'] ?? '',
    joiningDate: r['joining_date'] != null ? DateTime.parse(r['joining_date']) : DateTime.now(),
    status: r['status'] ?? 'Active',
  )).toList();
});

/// ---------- Attendance ----------
class AttendanceController extends StateNotifier<List<AttendanceRecord>> {
  AttendanceController() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final rows = await HostelService().fetchAttendanceToday();
    state = rows.map((r) => AttendanceRecord(
      id: r['id'],
      studentName: r['students']?['full_name'] ?? '',
      room: r['rooms']?['room_number'] ?? '',
      block: '',
      status: r['status'] ?? 'Not Marked',
      checkInTime: r['check_in_time'] ?? '',
      markedBy: r['marked_by'] ?? '',
    )).toList();
  }

  Future<void> mark(String id, String status) async {
    await HostelService().markAttendance(id, status);
    state = [for (final a in state) if (a.id == id) (a..status = status) else a];
  }
}

final attendanceProvider =
    StateNotifierProvider<AttendanceController, List<AttendanceRecord>>((ref) => AttendanceController());

/// ---------- Notifications (unread count demo) ----------
final unreadNotificationsProvider = StateProvider<int>((ref) => 7);
final unreadMessagesProvider = StateProvider<int>((ref) => 3);
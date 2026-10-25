import 'package:flutter/foundation.dart';
import '../../models/notice.dart';
import '../../models/staff.dart';
import '../hostel_service.dart';
import '../hostel_settings_service.dart';
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

DateTime _parseDate(dynamic val, [DateTime? fallback]) {
  if (val == null) return fallback ?? DateTime.now();
  if (val is DateTime) return val;
  final s = val.toString().trim();
  if (s.isEmpty) return fallback ?? DateTime.now();
  return DateTime.tryParse(s) ?? fallback ?? DateTime.now();
}

DateTime? _parseNullableDate(dynamic val) {
  if (val == null) return null;
  if (val is DateTime) return val;
  final s = val.toString().trim();
  if (s.isEmpty) return null;
  return DateTime.tryParse(s);
}

/// ---------- Leaves ----------
class LeavesController extends StateNotifier<List<LeaveRequest>> {
  LeavesController() : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await HostelService().fetchLeaveRequests();
      state = rows.map((r) => LeaveRequest(
        id: r['id'],
        studentName: r['students']?['full_name'] ?? '',
        room: '',
        leaveType: r['leave_type'] ?? '',
        reason: r['reason'] ?? '',
        from: _parseDate(r['from_date']),
        to: _parseDate(r['to_date']),
        emergencyContact: r['emergency_contact'] ?? '',
        destination: r['destination'] ?? '',
        status: r['status'] ?? 'Pending',
      )).toList();
    } catch (_) {}
  }

  Future<void> reload() async => _load();

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

  Future<void> reload() async => _load();

  Future<void> _load() async {
    try {
      final rows = await HostelService().fetchComplaints();
      state = rows.map((r) => Complaint(
        id: r['id'],
        studentName: r['students']?['full_name'] ?? '',
        room: '',
        category: r['category'] ?? '',
        description: r['description'] ?? '',
        priority: r['priority'] ?? 'Medium',
        date: _parseDate(r['created_at']),
        assignedTo: r['assigned_to'] ?? '',
        status: r['status'] ?? 'Open',
      )).toList();
    } catch (_) {}
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

  Future<void> reload() async => _load();

  Future<void> _load() async {
    try {
      final rows = await HostelService().fetchMaintenanceRequests();
      state = rows.map((r) => MaintenanceRequest(
        id: r['id'],
        room: r['rooms']?['room_number'] ?? '',
        block: '',
        category: r['category'] ?? '',
        issue: r['issue'] ?? '',
        priority: r['priority'] ?? 'Medium',
        assignedStaff: r['assigned_staff'] ?? '',
        createdDate: _parseDate(r['created_at']),
        expectedDate: _parseDate(r['expected_date']),
        status: r['status'] ?? 'Pending',
      )).toList();
    } catch (_) {}
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

  Future<void> reload() async => _load();

  Future<void> _load() async {
    try {
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
        checkIn: _parseDate(r['check_in']),
        checkOut: _parseNullableDate(r['check_out']),
        status: r['status'] ?? 'Checked In',
      )).toList();
    } catch (_) {}
  }

  Future<void> checkOut(String id) async {
    await HostelService().checkOutVisitor(id);
    state = [for (final v in state) if (v.id == id) (v..status = 'Checked Out'..checkOut = DateTime.now()) else v];
  }
}

final visitorsProvider = StateNotifierProvider<VisitorsController, List<Visitor>>((ref) => VisitorsController());

/// ---------- Notices ----------
class NoticesController extends StateNotifier<List<Notice>> {
  NoticesController() : super([]) {
    _load();
  }

  Future<void> reload() async => _load();

  Future<void> _load() async {
    try {
      final rows = await HostelService().fetchNotices();
      state = rows.map((r) => Notice(
        id: r['id'],
        title: r['title'] ?? '',
        description: r['description'] ?? '',
        category: r['category'] ?? 'General',
        audience: r['audience'] ?? 'All Students',
        publishDate: _parseDate(r['publish_date'] ?? r['created_at']),
        expiryDate: _parseDate(r['expiry_date']),
        priority: r['priority'] ?? 'Normal',
        status: r['status'] ?? 'Active',
      )).toList();
    } catch (e) {
      debugPrint('NoticesController._load error: $e');
    }
  }

  Future<void> updateStatus(String id, String status) async {
    await HostelService().updateNoticeStatus(id, status);
    state = [for (final n in state) if (n.id == id) (n..status = status) else n];
  }

  Future<void> removeNotice(String id) async {
    await HostelService().deleteNotice(id);
    state = [for (final n in state) if (n.id != id) n];
  }
}

final noticesProvider =
    StateNotifierProvider<NoticesController, List<Notice>>((ref) => NoticesController());

/// ---------- Staff ----------
class StaffController extends StateNotifier<List<StaffMember>> {
  StaffController({bool autoLoad = true}) : super([]) {
    if (autoLoad) reload();
  }

  bool _loading = false;
  bool get isLoading => _loading;

  Future<void> reload() async {
    _loading = true;
    try {
      final rows = await HostelService().fetchStaff();
      state = rows.map((r) {
        String rawStatus = (r['status']?.toString() ?? 'Active').trim();
        String normalizedStatus = rawStatus.toLowerCase() == 'active'
            ? 'Active'
            : (rawStatus.isEmpty
                ? 'Active'
                : '${rawStatus[0].toUpperCase()}${rawStatus.substring(1).toLowerCase()}');
        return StaffMember(
          id: r['id']?.toString() ?? '',
          name: r['name']?.toString() ?? '',
          employeeId: r['employee_id']?.toString() ?? '',
          role: r['role']?.toString() ?? 'Staff',
          phone: r['phone']?.toString() ?? '',
          email: r['email']?.toString() ?? '',
          joiningDate: _parseDate(r['joining_date']),
          status: normalizedStatus,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading staff: $e');
    } finally {
      _loading = false;
    }
  }

  Future<void> updateStatus(String id, String newStatus) async {
    await HostelService().updateStaffStatus(id, newStatus);
    state = [
      for (final s in state)
        if (s.id == id) s.copyWith(status: newStatus) else s
    ];
  }

  Future<void> removeStaff(String id) async {
    await HostelService().deleteStaffMember(id);
    state = state.where((s) => s.id != id).toList();
  }
}

final staffProvider =
    StateNotifierProvider<StaffController, List<StaffMember>>((ref) => StaffController());

/// ---------- Attendance ----------
class AttendanceController extends StateNotifier<List<AttendanceRecord>> {
  String _selectedDate = DateTime.now().toIso8601String().split('T').first;
  bool _isLoading = false;

  AttendanceController() : super([]) {
    _load();
  }

  String get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  String _normalizeStatus(dynamic val) {
    if (val == null) return 'Not Marked';
    final s = val.toString().trim();
    if (s.isEmpty) return 'Not Marked';
    final lower = s.toLowerCase();
    if (lower == 'present') return 'Present';
    if (lower == 'absent') return 'Absent';
    if (lower == 'late') return 'Late';
    if (lower == 'leave') return 'Leave';
    if (lower == 'not marked' || lower == 'not_marked') return 'Not Marked';
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }

  Future<void> setDate(String dateStr) async {
    _selectedDate = dateStr;
    await _load();
  }

  Future<void> reload() async {
    await _load();
  }

  Future<void> _load() async {
    _isLoading = true;
    try {
      final rows = await HostelService().fetchAttendanceForDate(_selectedDate);
      if (rows.isEmpty && _selectedDate == DateTime.now().toIso8601String().split('T').first) {
        await HostelService().initializeAttendanceForDate(_selectedDate);
        final freshRows = await HostelService().fetchAttendanceForDate(_selectedDate);
        state = freshRows.map(_mapRecord).toList();
      } else {
        state = rows.map(_mapRecord).toList();
      }
    } catch (e) {
      debugPrint('Error loading attendance for $_selectedDate: $e');
    } finally {
      _isLoading = false;
    }
  }

  AttendanceRecord _mapRecord(Map<String, dynamic> r) {
    return AttendanceRecord(
      id: r['id']?.toString() ?? '',
      studentName: r['students']?['full_name'] ?? 'Student',
      room: r['rooms']?['room_number'] ?? 'N/A',
      block: r['block_name'] ?? '',
      status: _normalizeStatus(r['status']),
      checkInTime: r['check_in_time'] ?? '--',
      markedBy: r['marked_by'] ?? '--',
    );
  }

  Future<void> mark(String id, String status, {String? checkInTime, String? markedBy}) async {
    final normStatus = _normalizeStatus(status);
    final now = DateTime.now();
    final defaultTime =
        "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
    final timeToSave = checkInTime ?? (normStatus == 'Present' || normStatus == 'Late' ? defaultTime : '--');
    final byToSave = markedBy ?? 'Principal / Warden';

    // Optimistic state update
    state = [
      for (final a in state)
        if (a.id == id)
          AttendanceRecord(
            id: a.id,
            studentName: a.studentName,
            room: a.room,
            block: a.block,
            status: normStatus,
            checkInTime: timeToSave,
            markedBy: byToSave,
          )
        else
          a
    ];

    try {
      await HostelService().markAttendance(
        id,
        normStatus,
        checkInTime: timeToSave == '--' ? null : timeToSave,
        markedBy: byToSave,
      );
    } catch (e) {
      debugPrint('Error marking attendance: $e');
    }
  }

  Future<void> markAll(String status, {String? markedBy}) async {
    final normStatus = _normalizeStatus(status);
    final now = DateTime.now();
    final defaultTime =
        "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
    final timeToSave = normStatus == 'Present' || normStatus == 'Late' ? defaultTime : '--';
    final byToSave = markedBy ?? 'Principal / Warden';

    final ids = state.map((a) => a.id).toList();

    state = [
      for (final a in state)
        AttendanceRecord(
          id: a.id,
          studentName: a.studentName,
          room: a.room,
          block: a.block,
          status: normStatus,
          checkInTime: timeToSave,
          markedBy: byToSave,
        )
    ];

    try {
      await HostelService().markAllAttendance(
        attendanceIds: ids,
        status: normStatus,
        markedBy: byToSave,
      );
    } catch (e) {
      debugPrint('Error batch marking attendance: $e');
    }
  }
}

final attendanceProvider =
    StateNotifierProvider<AttendanceController, List<AttendanceRecord>>((ref) => AttendanceController());

final attendanceDatesProvider = FutureProvider<List<String>>((ref) async {
  return await HostelService().fetchAttendanceDates();
});

/// ---------- Notifications (unread count demo) ----------
final unreadNotificationsProvider = StateProvider<int>((ref) => 7);
final unreadMessagesProvider = StateProvider<int>((ref) => 3);

/// ---------- Hostel Settings ----------
class HostelSettingsController extends StateNotifier<HostelSettings> {
  final HostelSettingsService _service;
  HostelSettingsController({HostelSettingsService? service, bool autoLoad = true})
      : _service = service ?? HostelSettingsService(),
        super(const HostelSettings()) {
    if (autoLoad) {
      loadSettings();
    }
  }

  Future<void> loadSettings() async {
    try {
      final s = await _service.loadSettings();
      state = s;
    } catch (e) {
      debugPrint('Failed to load hostel settings: $e');
    }
  }

  Future<void> updateSettings(HostelSettings updated) async {
    state = updated;
    await _service.saveSettings(updated);
  }

  Future<void> resetToDefaults() async {
    final def = await _service.resetDefaults();
    state = def;
  }
}

final hostelSettingsProvider =
    StateNotifierProvider<HostelSettingsController, HostelSettings>((ref) => HostelSettingsController());

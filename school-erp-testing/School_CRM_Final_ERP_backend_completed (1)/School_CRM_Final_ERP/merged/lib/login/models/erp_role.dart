import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Every distinct login persona supported by the common ERP login screen.
///
/// Section visibility for each role is enforced centrally in
/// [ErpRoleData.allowedSections] (see below) and applied in
/// `screens/dashboard_screen.dart` — nothing inside `modules/` had to be
/// touched to make this work.
enum ErpRole {
  principal,
  vicePrincipal,
  studentsAdmin,
  teachersAdmin,
  attendanceAdmin,
  feesAdmin,
  examAdmin,
  transportAdmin,
  hrAdmin,
  hostelAdmin,
  pti,
  studentParent,
  settingsAdmin,

  /// A teacher's own personal portal login — deliberately *not* one of the
  /// admin personas above. It carries no `allowedSections` into the shared
  /// sidebar/dashboard shell at all: `main.dart` checks for this role
  /// before `DashboardScreen` is ever built and, when matched, renders the
  /// standalone Teacher Portal app (`modules/teacher_portal`) full-screen
  /// instead. That keeps the isolation absolute — no other role's sidebar
  /// links to it, and this role never sees the admin shell.
  teacher,
}

/// Static presentation + access-control data for each [ErpRole]. Keeping
/// this in one place means the whole login screen (chips, header avatar,
/// button gradient) *and* the post-login sidebar react automatically
/// whenever a role's permissions change — there is only one source of
/// truth.
class ErpRoleData {
  final String label;
  final String idLabel;
  final String idHint;
  final IconData icon;
  final Color color;
  final String tagline;

  /// Short access code shown on the login chip.
  final String code;

  /// The fixed sign-in ID for this role (see [kErpCredentials] below).
  final String loginId;

  /// The fixed password for this role (see [kErpCredentials] below).
  final String password;

  /// Indices into `kSidebarItems` (widgets/sidebar.dart) that this role is
  /// allowed to see. Dashboard = 0, Students = 1, Teachers = 2,
  /// Parent&Student = 3, Attendance = 4, Fees = 5, Examinations = 6,
  /// Transport = 7, Hostel = 8, HR & Payroll = 9, Inventory = 10,
  /// Settings = 11.
  final List<int> allowedSections;

  /// Principal can approve; Vice Principal sees every section the
  /// Principal does but the Approvals action stays locked.
  final bool canApprove;

  const ErpRoleData({
    required this.label,
    required this.idLabel,
    required this.idHint,
    required this.icon,
    required this.color,
    required this.tagline,
    required this.code,
    required this.loginId,
    required this.password,
    required this.allowedSections,
    this.canApprove = false,
  });
}

/// All twelve sidebar sections, for readability below.
const int _dashboard = 0;
const int _students = 1;
const int _teachers = 2;
const int _parentStudent = 3;
const int _attendance = 4;
const int _fees = 5;
const int _examinations = 6;
const int _transport = 7;
const int _hostel = 8;
const int _hrPayroll = 9;
const int _inventory = 10;
const int _settings = 11;

const List<int> _allSections = [
  _dashboard,
  _students,
  _teachers,
  _parentStudent,
  _attendance,
  _fees,
  _examinations,
  _transport,
  _hostel,
  _hrPayroll,
  _inventory,
  _settings,
];

const Map<ErpRole, ErpRoleData> kErpRoles = {
  ErpRole.principal: ErpRoleData(
    label: 'Principal',
    idLabel: 'Principal ID',
    idHint: 'Enter your Principal ID',
    icon: Icons.workspace_premium_rounded,
    color: AppColors.primaryPurple,
    tagline: 'Full control of your institution',
    code: 'PRC',
    loginId: 'PRC001',
    password: 'Principal@123',
    allowedSections: _allSections,
    canApprove: true,
  ),
  ErpRole.vicePrincipal: ErpRoleData(
    label: 'Vice Principal',
    idLabel: 'Vice Principal ID',
    idHint: 'Enter your Vice Principal ID',
    icon: Icons.admin_panel_settings_rounded,
    color: AppColors.accentBlue,
    tagline: 'Institution oversight — approvals require Principal',
    code: 'VPR',
    loginId: 'VPR001',
    password: 'VicePrincipal@123',
    allowedSections: _allSections,
    canApprove: false,
  ),
  ErpRole.studentsAdmin: ErpRoleData(
    label: 'Students Admin',
    idLabel: 'Students Admin ID',
    idHint: 'Enter your Students Admin ID',
    icon: Icons.groups_2_rounded,
    color: AppColors.primaryPurple,
    tagline: 'Student records & admissions',
    code: 'STA',
    loginId: 'STA001',
    password: 'StudentsAdmin@123',
    allowedSections: [_students],
  ),
  ErpRole.teachersAdmin: ErpRoleData(
    label: 'Teachers Admin',
    idLabel: 'Teachers Admin ID',
    idHint: 'Enter your Teachers Admin ID',
    icon: Icons.co_present_rounded,
    color: AppColors.accentBlue,
    tagline: 'Teacher records & staff management',
    code: 'TEA',
    loginId: 'TEA001',
    password: 'TeachersAdmin@123',
    allowedSections: [_teachers],
  ),
  ErpRole.attendanceAdmin: ErpRoleData(
    label: 'Attendance Admin',
    idLabel: 'Attendance Admin ID',
    idHint: 'Enter your Attendance Admin ID',
    icon: Icons.event_available_rounded,
    color: AppColors.info,
    tagline: 'Daily attendance & records',
    code: 'ATD',
    loginId: 'ATD001',
    password: 'Attendance@123',
    allowedSections: [_attendance],
  ),
  ErpRole.feesAdmin: ErpRoleData(
    label: 'Fees Admin',
    idLabel: 'Fees Admin ID',
    idHint: 'Enter your Fees Admin ID',
    icon: Icons.currency_rupee_rounded,
    color: AppColors.success,
    tagline: 'Fee collection & finance',
    code: 'FEE',
    loginId: 'FEE001',
    password: 'FeesAdmin@123',
    allowedSections: [_fees],
  ),
  ErpRole.examAdmin: ErpRoleData(
    label: 'Exam Admin',
    idLabel: 'Exam Admin ID',
    idHint: 'Enter your Exam Admin ID',
    icon: Icons.article_rounded,
    color: Color(0xFFFB923C),
    tagline: 'Examinations & results',
    code: 'EXM',
    loginId: 'EXM001',
    password: 'ExamAdmin@123',
    allowedSections: [_examinations],
  ),
  ErpRole.transportAdmin: ErpRoleData(
    label: 'Transport Admin',
    idLabel: 'Transport Admin ID',
    idHint: 'Enter your Transport Admin ID',
    icon: Icons.directions_bus_filled_rounded,
    color: Color(0xFF06B6D4),
    tagline: 'Routes, drivers & vehicle tracking',
    code: 'TRP',
    loginId: 'TRP001',
    password: 'Transport@123',
    allowedSections: [_transport],
  ),
  ErpRole.hrAdmin: ErpRoleData(
    label: 'HR Admin',
    idLabel: 'HR Admin ID',
    idHint: 'Enter your HR Admin ID',
    icon: Icons.badge_rounded,
    color: AppColors.warning,
    tagline: 'HR, staff & payroll',
    code: 'HRA',
    loginId: 'HRA001',
    password: 'HRAdmin@123',
    allowedSections: [_hrPayroll],
  ),
  ErpRole.hostelAdmin: ErpRoleData(
    label: 'Hostel Admin',
    idLabel: 'Hostel Admin ID',
    idHint: 'Enter your Hostel Admin ID',
    icon: Icons.holiday_village_rounded,
    color: Color(0xFF06B6D4),
    tagline: 'Rooms, mess & hostel discipline',
    code: 'HST',
    loginId: 'HST001',
    password: 'HostelAdmin@123',
    allowedSections: [_hostel],
  ),
  ErpRole.pti: ErpRoleData(
    label: 'PTI',
    idLabel: 'PTI ID',
    idHint: 'Enter your PTI ID',
    icon: Icons.inventory_2_rounded,
    color: Color(0xFF8B5CF6),
    tagline: 'Sports & inventory stock',
    code: 'PTI',
    loginId: 'PTI001',
    password: 'Pti@123',
    allowedSections: [_inventory],
  ),
  ErpRole.studentParent: ErpRoleData(
    label: 'Student / Parent',
    idLabel: 'Student / Parent ID',
    idHint: "Enter your ID or ward's Roll No.",
    icon: Icons.family_restroom_rounded,
    color: Color(0xFFEF4476),
    tagline: "Track academics, fees & attendance",
    code: 'STU',
    loginId: 'STU001',
    password: 'Student@123',
    allowedSections: [_parentStudent],
  ),
  ErpRole.settingsAdmin: ErpRoleData(
    label: 'Settings Admin',
    idLabel: 'Settings Admin ID',
    idHint: 'Enter your Settings Admin ID',
    icon: Icons.settings_rounded,
    color: Color(0xFF64748B),
    tagline: 'School configuration & system settings',
    code: 'SET',
    loginId: 'SET001',
    password: 'SettingsAdmin@123',
    allowedSections: [_settings],
  ),
  ErpRole.teacher: ErpRoleData(
    label: 'Teacher',
    idLabel: 'Teacher ID',
    idHint: 'Enter your Teacher ID',
    icon: Icons.school_rounded,
    color: Color(0xFF16A34A),
    tagline: 'Your classes, students & daily teaching tools',
    code: 'TCH',
    loginId: 'TCH001',
    password: 'Teacher@123',
    // Empty on purpose — this role never reaches the admin sidebar, so no
    // `kSidebarItems` index needs to be granted to it. See the `teacher`
    // enum value's doc comment above.
    allowedSections: [],
  ),
};

/// Kept only as a reference sheet of login-id/password/role triples for
/// provisioning demo Supabase Auth accounts (`auth.users` + a matching
/// `profiles.role` row) — the login screen itself no longer checks
/// against this map. Real sign-in now goes through Supabase Auth via
/// `_resolveRole` in `main.dart`.
final Map<String, MapEntry<String, ErpRole>> kErpCredentials = {
  for (final entry in kErpRoles.entries)
    entry.value.loginId: MapEntry(entry.value.password, entry.key),
};
/// Converts a role string stored in Supabase (`profiles.role`) back into
/// the matching [ErpRole] enum value. Used by the real login flow.
ErpRole? erpRoleFromString(String value) {
  switch (value) {
    case 'principal':
      return ErpRole.principal;
    case 'vice_principal':
      return ErpRole.vicePrincipal;
    case 'students_admin':
      return ErpRole.studentsAdmin;
    case 'teachers_admin':
      return ErpRole.teachersAdmin;
    case 'attendance_admin':
      return ErpRole.attendanceAdmin;
    case 'fees_admin':
      return ErpRole.feesAdmin;
    case 'exam_admin':
      return ErpRole.examAdmin;
    case 'transport_admin':
      return ErpRole.transportAdmin;
    case 'hr_admin':
      return ErpRole.hrAdmin;
    case 'hostel_admin':
      return ErpRole.hostelAdmin;
    case 'inventory_admin':
      return ErpRole.pti;
    case 'parent_student':
      return ErpRole.studentParent;
    case 'settings_admin':
      return ErpRole.settingsAdmin;
    case 'teacher':
      return ErpRole.teacher;
    default:
      return null;
  }
}
import '../models/dashboard_models.dart' show UserRole;

/// Central place for page index constants so screens/widgets can navigate
/// to a specific page (`context.read<AppState>().setNavIndex(...)`) without
/// importing shell_screen.dart directly (avoids circular imports, since
/// shell_screen.dart imports every page).
///
/// Keep this in sync with `kNavItems` / `kPages` in shell_screen.dart.
const int kDashboardNavIndex = 0;
const int kAttendanceNavIndex = 1;
const int kStudentsNavIndex = 2;
const int kAssignmentsNavIndex = 3;
const int kExamsNavIndex = 4;
const int kMessagesNavIndex = 5;
const int kTimetableNavIndex = 6;
const int kProfileNavIndex = 7;
const int kGradebookNavIndex = 8;
const int kSyllabusNavIndex = 9;
const int kSeatingNavIndex = 10;
const int kSubstituteNavIndex = 11;
const int kPtmNavIndex = 12;
const int kHomeworkNavIndex = 13;
const int kOnlineClassNavIndex = 14;
const int kFeesNavIndex = 15;
const int kNoticeNavIndex = 16;
const int kAcademicCalendarNavIndex = 17;
const int kLeavePayrollNavIndex = 18;
const int kDocumentVaultNavIndex = 19;
const int kReportsNavIndex = 20;
const int kAccessControlNavIndex = 21;

/// Which nav indices a given role is allowed to see in the sidebar/drawer.
/// Teacher = original 18 teacher-facing pages + their own Leave & Payroll
/// + the Document Vault. HOD additionally gets the Class-Wide Analytics &
/// Report Builder (department decision-making). Principal/Admin see
/// everything, since a whole-school overview is the whole point of those
/// roles — and only Principal/Admin get Role-Based Access Control, since
/// raising/reviewing an access-change request is a leadership-only action.
List<int> navIndicesForRole(UserRole role) {
  const teacherPages = [
  kDashboardNavIndex, kAttendanceNavIndex, kStudentsNavIndex, kAssignmentsNavIndex,
  kExamsNavIndex, kMessagesNavIndex, kTimetableNavIndex, kProfileNavIndex,
  kGradebookNavIndex, kSyllabusNavIndex, kSeatingNavIndex, kSubstituteNavIndex,
  kPtmNavIndex, kHomeworkNavIndex, kOnlineClassNavIndex, kFeesNavIndex,
  kNoticeNavIndex, kAcademicCalendarNavIndex, kLeavePayrollNavIndex, kDocumentVaultNavIndex,
  kReportsNavIndex,kAccessControlNavIndex,
];
  return teacherPages;
}

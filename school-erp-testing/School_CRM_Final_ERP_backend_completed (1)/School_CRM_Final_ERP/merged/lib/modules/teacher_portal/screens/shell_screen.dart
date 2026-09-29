import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/top_header.dart';
import 'role_aware_dashboard_screen.dart';
import 'attendance_screen.dart';
import 'students_screen.dart';
import 'assignments_screen.dart';
import 'exams_screen.dart';
import 'messages_screen.dart';
import 'timetable_screen.dart';
import 'profile_screen.dart';
import 'gradebook_screen.dart';
import 'syllabus_screen.dart';
import 'seating_screen.dart';
import 'substitute_screen.dart';
import 'ptm_screen.dart';
import 'homework_screen.dart';
import 'online_class_screen.dart';
import 'fees_screen.dart';
import 'notice_board_screen.dart';
import 'academic_calendar_screen.dart';
import 'leave_payroll_screen.dart';
import 'document_vault_screen.dart';
import 'reports_screen.dart';
import 'access_control_screen.dart';
import 'nav_indices.dart';

// NavItem + kNavItems now live in nav_items.dart so pages/widgets other than
// this shell (e.g. the dashboard's bottom "All Modules" nav widget) can use
// them without importing this whole file.
export 'nav_items.dart';

const List<Widget> kPages = [
  RoleAwareDashboardScreen(),
  AttendanceScreen(),
  StudentsScreen(),
  AssignmentsScreen(),
  ExamsScreen(),
  MessagesScreen(),
  TimetableScreen(),
  ProfileScreen(),
  GradebookScreen(),
  SyllabusScreen(),
  SeatingScreen(),
  SubstituteScreen(),
  PtmScreen(),
  HomeworkScreen(),
  OnlineClassScreen(),
  FeesScreen(),
  NoticeBoardScreen(),
  AcademicCalendarScreen(),
  LeavePayrollScreen(),
  DocumentVaultScreen(),
  ReportsScreen(),
  AccessControlScreen(),
];

// Named indices for the new pages live in nav_indices.dart (imported
// above) so other files can use them without importing this whole file.

/// App shell: top header + the currently selected page. There is no
/// sidebar/drawer any more — every page that used to live in the sidebar
/// is now reachable from the "All Modules" widget at the bottom of the
/// dashboard (see lib/widgets/nav_menu_card.dart), so nothing was dropped,
/// it just moved into a widget on the dashboard itself.
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isMobile = width < 900;

            return Scaffold(
              backgroundColor: AppColors.scaffoldBg,
              body: SafeArea(
                child: Column(
                  children: [
                    TopHeader(
                      isMobile: isMobile,
                      onSearch: app.setSearchQuery,
                    ),
                    Expanded(child: kPages[app.navIndex]),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

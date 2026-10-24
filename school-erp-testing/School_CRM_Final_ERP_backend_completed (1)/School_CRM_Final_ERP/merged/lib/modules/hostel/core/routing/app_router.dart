import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/layouts/main_shell.dart';

import '../../features/dashboard/dashboard_screen.dart';
import '../../features/students/students_list_screen.dart';
import '../../features/students/add_student_screen.dart';
import '../../features/students/student_profile_screen.dart';
import '../../features/hostel/blocks_screen.dart';
import '../../features/hostel/rooms_screen.dart';
import '../../features/hostel/room_detail_screen.dart';
import '../../features/attendance/attendance_screen.dart';
import '../../features/leaves/leaves_screen.dart';
import '../../features/fees/fees_screen.dart';
import '../../features/mess/mess_screen.dart';
import '../../features/complaints/complaints_screen.dart';
import '../../features/maintenance/maintenance_screen.dart';
import '../../features/visitors/visitors_screen.dart';
import '../../features/notices/notices_screen.dart';
import '../../features/staff/staff_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (c, s) => const DashboardScreen(),
          ),

          GoRoute(
            path: '/students',
            builder: (c, s) => const StudentsListScreen(),
          ),
          GoRoute(
            path: '/students/add',
            builder: (c, s) => AddStudentScreen(
              studentId: s.uri.queryParameters['id'],
            ),
          ),
          GoRoute(
            path: '/students/edit/:id',
            builder: (c, s) => AddStudentScreen(
              studentId: s.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/students/:id',
            builder: (c, s) =>
                StudentProfileScreen(studentId: s.pathParameters['id']!),
          ),

          GoRoute(
            path: '/hostel/blocks',
            builder: (c, s) => const BlocksScreen(),
          ),
          GoRoute(
            path: '/hostel/rooms',
            builder: (c, s) => const RoomsScreen(),
          ),
          GoRoute(
            path: '/hostel/rooms/:id',
            builder: (c, s) =>
                RoomDetailScreen(roomId: s.pathParameters['id']!),
          ),

          GoRoute(
            path: '/attendance',
            builder: (c, s) => const AttendanceScreen(),
          ),
          GoRoute(path: '/leaves', builder: (c, s) => const LeavesScreen()),
          GoRoute(path: '/fees', builder: (c, s) => const FeesScreen()),
          GoRoute(path: '/mess', builder: (c, s) => const MessScreen()),
          GoRoute(
            path: '/complaints',
            builder: (c, s) => const ComplaintsScreen(),
          ),
          GoRoute(
            path: '/maintenance',
            builder: (c, s) => const MaintenanceScreen(),
          ),
          GoRoute(path: '/visitors', builder: (c, s) => const VisitorsScreen()),
          GoRoute(path: '/notices', builder: (c, s) => const NoticesScreen()),
          GoRoute(path: '/staff', builder: (c, s) => const StaffScreen()),
          GoRoute(path: '/reports', builder: (c, s) => const ReportsScreen()),
          GoRoute(
            path: '/settings',
            builder: (c, s) => SettingsScreen(
              initialSection:
                  s.uri.queryParameters['section'] ?? s.uri.queryParameters['tab'],
            ),
          ),
        ],
      ),
    ],
  );
});
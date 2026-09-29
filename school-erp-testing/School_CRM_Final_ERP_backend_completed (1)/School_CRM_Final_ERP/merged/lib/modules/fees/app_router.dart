import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/widgets/app_shell.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/students/students_list_screen.dart';
import 'features/students/student_profile_screen.dart';
import 'features/fee_collection/fee_collection_screen.dart';
import 'features/receipt/receipt_screen.dart';
import 'features/defaulters/defaulters_screen.dart';
import 'features/reports/reports_screen.dart';
import 'features/day_closing/day_closing_screen.dart';
import 'features/audit/audit_log_screen.dart';
import 'features/finance/finance_section.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const AppShell(route: '/dashboard', title: 'Dashboard', child: DashboardScreen()),
    ),
    GoRoute(
      path: '/students',
      builder: (context, state) => const AppShell(route: '/students', title: 'Students & Fees', child: StudentsListScreen()),
    ),
    GoRoute(
      path: '/students/:id',
      builder: (context, state) => AppShell(
        route: '/students',
        title: 'Student Profile',
        child: StudentProfileScreen(studentId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/collect',
      builder: (context, state) => AppShell(
        route: '/collect',
        title: 'Fee Collection',
        child: FeeCollectionScreen(initialStudentId: state.uri.queryParameters['student']),
      ),
    ),
    GoRoute(
      path: '/receipt/:receiptNo',
      builder: (context, state) => AppShell(
        route: '/collect',
        title: 'Receipt',
        child: ReceiptScreen(receiptNo: state.pathParameters['receiptNo']!),
      ),
    ),
    GoRoute(
      path: '/defaulters',
      builder: (context, state) => const AppShell(route: '/defaulters', title: 'Defaulter Management', child: DefaultersScreen()),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const AppShell(route: '/reports', title: 'Reports', child: ReportsScreen()),
    ),
    GoRoute(
      path: '/finance',
      builder: (context, state) => const AppShell(route: '/finance', title: 'Finance Management', child: FinanceSection()),
    ),
    GoRoute(
      path: '/day-closing',
      builder: (context, state) => const AppShell(route: '/day-closing', title: 'Day Closing', child: DayClosingScreen()),
    ),
    GoRoute(
      path: '/audit',
      builder: (context, state) => const AppShell(route: '/audit', title: 'Audit Log', child: AuditLogScreen()),
    ),
  ],
);

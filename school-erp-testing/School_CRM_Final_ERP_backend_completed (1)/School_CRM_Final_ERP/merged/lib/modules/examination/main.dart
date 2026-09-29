import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'state/app_store.dart';
import 'theme/app_theme.dart';
import 'routing/app_routes.dart';
import 'widgets/app_shell.dart';

import 'screens/dashboard_screen.dart';
import 'screens/exam_management_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/eligibility_screen.dart';

import 'screens/paper_screens.dart';
import 'screens/seating_hall_screens.dart';
import 'screens/barcode_center_screen.dart';
import 'screens/answer_books_screen.dart';
import 'screens/evaluation_screen.dart';
import 'screens/moderation_screen.dart';
import 'screens/results_screens.dart';
import 'screens/revaluation_screen.dart';
import 'screens/malpractice_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/remaining_module_screens.dart';
import 'screens/added_modules_screens.dart';

void main() {
  runApp(const ExamErpApp());
}

class ExamErpApp extends StatelessWidget {
  const ExamErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppStore(),
      child: Builder(builder: (context) {
        final router = _buildRouter();
        return MaterialApp.router(
          title: 'School Examination ERP',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: router,
        );
      }),
    );
  }

  GoRouter _buildRouter() {
    Widget shell(BuildContext context, GoRouterState state, Widget child) => AppShell(currentPath: state.uri.path, child: child);

    return GoRouter(
      initialLocation: AppRoutes.dashboard,
      routes: [
        ShellRoute(
          builder: (context, state, child) => shell(context, state, child),
          routes: [
            GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardScreen()),
            GoRoute(path: AppRoutes.examManagement, builder: (_, __) => const ExamManagementScreen()),
            GoRoute(path: AppRoutes.calendar, builder: (_, __) => const CalendarScreen()),
            GoRoute(path: AppRoutes.eligibility, builder: (_, __) => const EligibilityScreen()),
          
            GoRoute(path: AppRoutes.paperSecurity, builder: (_, __) => const PaperSecurityScreen()),
            GoRoute(path: AppRoutes.seating, builder: (_, __) => const SeatingScreen()),
            GoRoute(path: AppRoutes.examHall, builder: (_, __) => const ExamHallScreen()),
            GoRoute(path: AppRoutes.barcodeCenter, builder: (_, __) => const BarcodeCenterScreen()),
            GoRoute(path: AppRoutes.answerBooks, builder: (_, __) => const AnswerBooksScreen()),
            GoRoute(path: AppRoutes.evaluation, builder: (_, __) => const EvaluationScreen()),
            GoRoute(path: AppRoutes.moderation, builder: (_, __) => const ModerationScreen()),
            GoRoute(path: AppRoutes.results, builder: (_, __) => const ResultsScreen()),
            GoRoute(path: AppRoutes.gradingEngine, builder: (_, __) => const GradingEngineScreen()),
            GoRoute(path: AppRoutes.revaluation, builder: (_, __) => const RevaluationScreen()),
            GoRoute(path: AppRoutes.admitCards, builder: (_, __) => const AdmitCardsScreen()),
            GoRoute(path: AppRoutes.certificates, builder: (_, __) => const CertificatesScreen()),
            GoRoute(path: AppRoutes.malpractice, builder: (_, __) => const MalpracticeScreen()),
            GoRoute(path: AppRoutes.accommodation, builder: (_, __) => const AccommodationScreen()),
            GoRoute(path: AppRoutes.analytics, builder: (_, __) => const AnalyticsScreen()),
            GoRoute(path: AppRoutes.notifications, builder: (_, __) => const NotificationsScreen()),
            GoRoute(path: AppRoutes.portal, builder: (_, __) => const PortalScreen()),
            GoRoute(path: AppRoutes.archive, builder: (_, __) => const ArchiveScreen()),
            GoRoute(path: AppRoutes.backup, builder: (_, __) => const BackupScreen()),
            GoRoute(path: AppRoutes.roles, builder: (_, __) => const RolesScreen()),
            GoRoute(path: AppRoutes.auditLogs, builder: (_, __) => const AuditLogsScreen()),
            GoRoute(path: AppRoutes.reportCardDesigner, builder: (_, __) => const ReportCardDesignerScreen()),
            GoRoute(path: AppRoutes.reschedule, builder: (_, __) => const RescheduleScreen()),
            GoRoute(path: AppRoutes.substituteInvigilator, builder: (_, __) => const SubstituteInvigilatorScreen()),
            GoRoute(path: AppRoutes.digitalInstructions, builder: (_, __) => const DigitalInstructionsScreen()),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../routes.dart';
import 'dashboard_screen.dart';
import 'employees_screen.dart';
import 'departments_screen.dart';
import 'designations_screen.dart';
import 'attendance_screen.dart';
import 'leave_screen.dart';
import 'shifts_screen.dart';
import 'appraisals_screen.dart';
import 'salary_structure_screen.dart';
import 'payroll_processing_screen.dart';
import 'allowances_screen.dart';
import 'loans_screen.dart';
import 'payslips_screen.dart';
import 'tax_screen.dart';
import 'recruitment_screens.dart';
import 'reports_screens.dart';
import 'ai_analytics_screen.dart';
import 'system_screens.dart';

typedef Navigate = void Function(String route, [Map<String, dynamic> args]);

/// Builds the widget for the given route. Central place mapping
/// [Routes] constants -> screen widgets, keeping main.dart / app_shell clean.
Widget buildScreen(String route, Map<String, dynamic> args, Navigate onNavigate) {
  switch (route) {
    case Routes.dashboard:
      return DashboardScreen(onNavigate: onNavigate);
    case Routes.employees:
      return EmployeesScreen(args: args, onNavigate: onNavigate);
    case Routes.employeeDetail:
      return EmployeeDetailScreen(args: args, onNavigate: onNavigate);
    case Routes.departments:
      return const DepartmentsScreen();
    case Routes.designations:
      return const DesignationsScreen();
    case Routes.attendance:
      return AttendanceScreen(args: args);
    case Routes.leave:
      return LeaveScreen(args: args);
    case Routes.shifts:
      return const ShiftsScreen();
    case Routes.appraisals:
      return const AppraisalsScreen();
    case Routes.salaryStructure:
      return const SalaryStructureScreen();
    case Routes.payroll:
      return PayrollProcessingScreen(args: args);
    case Routes.allowances:
      return const AllowancesScreen();
    case Routes.loans:
      return LoansScreen(args: args);
    case Routes.payslips:
      return PayslipsScreen(args: args);
    case Routes.tax:
      return const TaxScreen();
    case Routes.jobs:
      return const JobsScreen();
    case Routes.candidates:
      return const CandidatesScreen();
    case Routes.interviews:
      return const InterviewsScreen();
    case Routes.offers:
      return const OffersScreen();
    case Routes.hrReports:
      return HrReportsScreen(args: args);
    case Routes.payrollReports:
      return PayrollReportsScreen(args: args);
    case Routes.aiAnalytics:
      return const AiAnalyticsScreen();
    case Routes.notifications:
      return const NotificationsScreen();
    case Routes.settings:
      return const SettingsScreen();
    case Routes.profile:
      return const ProfileScreen();
    default:
      return DashboardScreen(onNavigate: onNavigate);
  }
}

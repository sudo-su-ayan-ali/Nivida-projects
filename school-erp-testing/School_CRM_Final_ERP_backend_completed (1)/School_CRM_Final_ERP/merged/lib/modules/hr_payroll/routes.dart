import 'package:flutter/material.dart';

class Routes {
  static const dashboard = '/dashboard';
  static const employees = '/employees';
  static const employeeDetail = '/employees/detail';
  static const departments = '/departments';
  static const designations = '/designations';
  static const attendance = '/attendance';
  static const leave = '/leave';
  static const shifts = '/shifts';
  static const appraisals = '/appraisals';
  static const salaryStructure = '/salary-structure';
  static const payroll = '/payroll';
  static const allowances = '/allowances';
  static const loans = '/loans';
  static const payslips = '/payslips';
  static const tax = '/tax';
  static const jobs = '/jobs';
  static const candidates = '/candidates';
  static const interviews = '/interviews';
  static const offers = '/offers';
  static const hrReports = '/hr-reports';
  static const payrollReports = '/payroll-reports';
  static const aiAnalytics = '/ai-analytics';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const profile = '/profile';
}

class NavItem {
  final String label;
  final IconData icon;
  final String route;
  const NavItem(this.label, this.icon, this.route);
}

class NavGroup {
  final String? title;
  final List<NavItem> items;
  const NavGroup(this.title, this.items);
}

const sidebarGroups = <NavGroup>[
  NavGroup(null, [
    NavItem('Dashboard', Icons.dashboard_outlined, Routes.dashboard),
  ]),
  NavGroup('EMPLOYEE MANAGEMENT', [
    NavItem('Employees', Icons.people_outline, Routes.employees),
    NavItem('Departments', Icons.apartment_outlined, Routes.departments),
    NavItem('Designations', Icons.badge_outlined, Routes.designations),
    NavItem('Attendance', Icons.event_available_outlined, Routes.attendance),
    NavItem('Leave Management', Icons.beach_access_outlined, Routes.leave),
    NavItem('Shift Management', Icons.schedule_outlined, Routes.shifts),
    NavItem('Appraisals', Icons.star_border, Routes.appraisals),
  ]),
  NavGroup('PAYROLL MANAGEMENT', [
    NavItem('Salary Structure', Icons.account_balance_wallet_outlined, Routes.salaryStructure),
    NavItem('Payroll Processing', Icons.calculate_outlined, Routes.payroll),
    NavItem('Allowances & Deductions', Icons.swap_vert, Routes.allowances),
    NavItem('Loans & Advances', Icons.handshake_outlined, Routes.loans),
    NavItem('Payslips', Icons.receipt_long_outlined, Routes.payslips),
    NavItem('Tax Management', Icons.percent, Routes.tax),
  ]),
  NavGroup('RECRUITMENT', [
    NavItem('Jobs', Icons.work_outline, Routes.jobs),
    NavItem('Candidates', Icons.person_search_outlined, Routes.candidates),
    NavItem('Interviews', Icons.event_note_outlined, Routes.interviews),
    NavItem('Offers', Icons.handshake, Routes.offers),
  ]),
  NavGroup('REPORTS & ANALYTICS', [
    NavItem('HR Reports', Icons.bar_chart_outlined, Routes.hrReports),
    NavItem('Payroll Reports', Icons.insert_chart_outlined, Routes.payrollReports),
    NavItem('AI Analytics', Icons.psychology_outlined, Routes.aiAnalytics),
  ]),
  NavGroup('SYSTEM', [
    NavItem('Notifications', Icons.notifications_outlined, Routes.notifications),
    NavItem('Settings', Icons.settings_outlined, Routes.settings),
    NavItem('User Profile', Icons.account_circle_outlined, Routes.profile),
  ]),
];

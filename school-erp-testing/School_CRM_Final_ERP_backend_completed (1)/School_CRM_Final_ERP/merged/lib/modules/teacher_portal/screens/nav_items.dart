import 'package:flutter/material.dart';

/// Single entry describing one navigable page of the app (icon, active
/// icon, label). Kept in its own file (rather than inside shell_screen.dart)
/// so screens/widgets — e.g. the dashboard's bottom navigation-menu widget —
/// can read `kNavItems` without importing shell_screen.dart, which would
/// create a circular import (shell_screen.dart imports every page).
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavItem({required this.icon, required this.activeIcon, required this.label});
}

/// Master list of every page in the app, in the same order as `kPages` in
/// shell_screen.dart and the index constants in nav_indices.dart. Do not
/// reorder — indices here must line up exactly with those two.
const List<NavItem> kNavItems = [
  NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard'),
  NavItem(icon: Icons.how_to_reg_outlined, activeIcon: Icons.how_to_reg_rounded, label: 'Attendance'),
  NavItem(icon: Icons.groups_outlined, activeIcon: Icons.groups_rounded, label: 'Students'),
  NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'Assignments'),
  NavItem(icon: Icons.event_note_outlined, activeIcon: Icons.event_note_rounded, label: 'Exams'),
  NavItem(icon: Icons.forum_outlined, activeIcon: Icons.forum_rounded, label: 'Messages'),
  NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, label: 'Timetable'),
  NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
  // Appended after the original 8 so every existing setNavIndex(n) call
  // elsewhere in the app keeps pointing at the same page.
  NavItem(icon: Icons.grade_outlined, activeIcon: Icons.grade_rounded, label: 'Gradebook'),
  NavItem(icon: Icons.checklist_rtl_outlined, activeIcon: Icons.checklist_rounded, label: 'Syllabus'),
  NavItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded, label: 'Seating Chart'),
  NavItem(icon: Icons.assignment_ind_outlined, activeIcon: Icons.assignment_ind_rounded, label: 'Substitute Note'),
  NavItem(icon: Icons.groups_2_outlined, activeIcon: Icons.groups_2_rounded, label: 'PTM Scheduler'),
  // Appended after the original 13 for the same reason as above.
  NavItem(icon: Icons.assignment_turned_in_outlined, activeIcon: Icons.assignment_turned_in_rounded, label: 'Homework'),
  NavItem(icon: Icons.video_call_outlined, activeIcon: Icons.video_call_rounded, label: 'Online Classes'),
  NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Fee Status'),
  NavItem(icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded, label: 'Notice Board'),
  NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: 'Academic Calendar'),
  // Appended after the original 18 for the same reason as above.
  NavItem(icon: Icons.beach_access_outlined, activeIcon: Icons.beach_access_rounded, label: 'Leave & Payroll'),
  NavItem(icon: Icons.folder_shared_outlined, activeIcon: Icons.folder_shared_rounded, label: 'Document Vault'),
  NavItem(icon: Icons.insert_chart_outlined_rounded, activeIcon: Icons.insert_chart_rounded, label: 'Reports'),
  // Appended after the original 20 for the same reason as above.
  NavItem(icon: Icons.admin_panel_settings_outlined, activeIcon: Icons.admin_panel_settings_rounded, label: 'Access Control'),
];

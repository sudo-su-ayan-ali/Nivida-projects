import 'package:flutter/material.dart';
import '../models/teacher.dart';
import '../theme/app_colors.dart';

/// Fixed headcount per department, used for the "Add/Edit Teacher"
/// department dropdown and the department filter chips.
const Map<String, int> kDeptHeadcount = {
  'Mathematics': 8,
  'Science': 7,
  'English': 6,
  'Computer Science': 6,
  'Social Studies': 5,
  'Physical Education': 4,
  'Arts': 3,
  'Music': 3,
};

/// "Teaching Tools & Important Links" quick-access cards.
final List<QuickAction> kQuickActions = [
  QuickAction(icon: Icons.calendar_month_rounded, title: 'My Timetable', subtitle: 'View Schedule', accent: AppColors.primary, bg: const Color(0xFFEEF0FF)),
  QuickAction(icon: Icons.assignment_outlined, title: 'Leave Management', subtitle: 'Apply / Approve', accent: AppColors.warning, bg: const Color(0xFFFFF1DE)),
  QuickAction(icon: Icons.groups_2_outlined, title: 'Class Allocation', subtitle: 'View Classes', accent: AppColors.blue, bg: const Color(0xFFE4EEFF)),
  QuickAction(icon: Icons.bar_chart_rounded, title: 'Performance Report', subtitle: 'View Reports', accent: AppColors.danger, bg: const Color(0xFFFFE7E7)),
  QuickAction(icon: Icons.menu_book_outlined, title: 'Subject Allocation', subtitle: 'View Subjects', accent: AppColors.blue, bg: const Color(0xFFE4EEFF)),
  QuickAction(icon: Icons.fact_check_outlined, title: 'Attendance Report', subtitle: 'View Reports', accent: AppColors.success, bg: const Color(0xFFDFF7EC)),
  QuickAction(icon: Icons.event_note_outlined, title: 'Exam Schedule', subtitle: 'View Schedule', accent: Color(0xFFEC4899), bg: const Color(0xFFFFE3F0)),
  QuickAction(icon: Icons.auto_stories_outlined, title: 'Syllabus Coverage', subtitle: 'Track Progress', accent: AppColors.secondary, bg: const Color(0xFFF1E8FF)),
];

/// "Additional Important Information" bottom stat cards.
final List<StatTile> kBottomStats = [
  StatTile(icon: Icons.groups_rounded, value: '48', label: 'Total Classes Assigned', accent: AppColors.primary, bg: const Color(0xFFEEF0FF)),
  StatTile(icon: Icons.trending_up_rounded, value: '1,256', label: 'Total Students Taught', accent: AppColors.blue, bg: const Color(0xFFE4EEFF)),
  StatTile(icon: Icons.person_off_outlined, value: '3', label: 'Pending Leave Requests', accent: AppColors.warning, bg: const Color(0xFFFFF1DE)),
  StatTile(icon: Icons.rule_folder_outlined, value: '5', label: 'Pending Approvals', accent: AppColors.blue, bg: const Color(0xFFE4EEFF)),
  StatTile(icon: Icons.task_alt_rounded, value: '24', label: 'Completed Tasks', accent: AppColors.success, bg: const Color(0xFFDFF7EC)),
  StatTile(icon: Icons.event_available_outlined, value: '4', label: 'Upcoming Exams', accent: AppColors.danger, bg: const Color(0xFFFFE7E7)),
];
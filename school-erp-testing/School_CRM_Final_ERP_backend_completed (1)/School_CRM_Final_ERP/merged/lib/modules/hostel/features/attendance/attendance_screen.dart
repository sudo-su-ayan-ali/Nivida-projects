import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_data_table.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/filter_dropdown.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/app_breadcrumb.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});
  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String query = '';
  String statusFilter = 'All Status';

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(attendanceProvider);
    final present = records.where((a) => a.status == 'Present').length;
    final absent = records.where((a) => a.status == 'Absent').length;
    final late = records.where((a) => a.status == 'Late').length;
    final notMarked = records.where((a) => a.status == 'Not Marked').length;

    final filtered = records.where((a) {
      final matchesQuery = query.isEmpty || a.studentName.toLowerCase().contains(query.toLowerCase());
      final matchesStatus = statusFilter == 'All Status' || a.status == statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();

    return SingleChildScrollView(
      child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppBreadcrumb(items: const ['Attendance Management']),
          const SizedBox(height: 10),
          const Text('Attendance Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Daily hostel attendance is controlled by Admin, Warden, and authorized staff only.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: Responsive.statColumns(context).clamp(1, 4),
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
            childAspectRatio: 1.5,
            children: [
              StatCard(icon: Icons.check_circle_rounded, color: AppColors.success, value: '$present', label: 'Present'),
              StatCard(icon: Icons.cancel_rounded, color: AppColors.danger, value: '$absent', label: 'Absent'),
              StatCard(icon: Icons.schedule_rounded, color: AppColors.warning, value: '$late', label: 'Late'),
              StatCard(icon: Icons.help_outline_rounded, color: AppColors.textMuted, value: '$notMarked', label: 'Not Marked'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(width: 240, child: AppSearchField(hint: 'Search student...', onChanged: (v) => setState(() => query = v))),
                    FilterDropdown(
                      label: 'Status',
                      value: statusFilter,
                      options: const ['All Status', 'Present', 'Absent', 'Late', 'Not Marked'],
                      onChanged: (v) => setState(() => statusFilter = v!),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppDataTable(
                  minWidth: 900,
                  columns: const [
                    AppTableColumn('Student', width: 160),
                    AppTableColumn('Room', width: 90),
                    AppTableColumn('Block', width: 130),
                    AppTableColumn('Status', width: 100),
                    AppTableColumn('Check-in Time', width: 120),
                    AppTableColumn('Marked By', width: 140),
                    AppTableColumn('Actions', width: 140),
                  ],
                  rowCount: filtered.length,
                  rowBuilder: (i) {
                    final a = filtered[i];
                    return [
                      CellText(a.studentName, strong: true),
                      CellText(a.room),
                      CellText(a.block.split(' ').take(2).join(' ')),
                      StatusBadge(status: a.status),
                      CellText(a.checkInTime),
                      CellText(a.markedBy),
                      Wrap(spacing: 4, children: [
                        _quickMark(context, a, 'Present'),
                        _quickMark(context, a, 'Absent'),
                        _quickMark(context, a, 'Late'),
                      ]),
                    ];
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _quickMark(BuildContext context, a, String status) {
    final color = AppColors.statusColor(status);
    final active = a.status == status;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () async {
        final ok = await showConfirmDialog(context, title: 'Mark $status', message: 'Mark ${a.studentName} as $status?');
        if (ok) ref.read(attendanceProvider.notifier).mark(a.id, status);
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(
          status == 'Present' ? Icons.check_rounded : status == 'Absent' ? Icons.close_rounded : Icons.schedule_rounded,
          size: 14,
          color: color,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_data_table.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/filter_dropdown.dart';
import '../../shared/widgets/pagination.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/app_breadcrumb.dart';

class LeavesScreen extends ConsumerStatefulWidget {
  const LeavesScreen({super.key});
  @override
  ConsumerState<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends ConsumerState<LeavesScreen> {
  String query = '';
  String statusFilter = 'All Status';
  int page = 1;
  final pageSize = 8;

  @override
  Widget build(BuildContext context) {
    final leaves = ref.watch(leavesProvider);
    final df = DateFormat('d MMM yyyy');

    final filtered = leaves.where((l) {
      final matchesQuery = query.isEmpty || l.studentName.toLowerCase().contains(query.toLowerCase());
      final matchesStatus = statusFilter == 'All Status' || l.status == statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();

    final totalPages = (filtered.length / pageSize).ceil().clamp(1, 999999);
    if (page > totalPages) page = 1;
    final pageItems = filtered.skip((page - 1) * pageSize).take(pageSize).toList();

    return SingleChildScrollView(
      child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppBreadcrumb(items: const ['Leave Management']),
          const SizedBox(height: 10),
          const Text('Leave Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Review, approve, or reject student leave requests.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
                    SizedBox(width: 240, child: AppSearchField(hint: 'Search student...', onChanged: (v) => setState(() { query = v; page = 1; }))),
                    FilterDropdown(
                      label: 'Status',
                      value: statusFilter,
                      options: const ['All Status', 'Pending', 'Approved', 'Rejected', 'Completed'],
                      onChanged: (v) => setState(() { statusFilter = v!; page = 1; }),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppDataTable(
                  minWidth: 1000,
                  columns: const [
                    AppTableColumn('Student Name', width: 150),
                    AppTableColumn('Room No.', width: 90),
                    AppTableColumn('Leave Type', width: 110),
                    AppTableColumn('From', width: 100),
                    AppTableColumn('To', width: 100),
                    AppTableColumn('Status', width: 100),
                    AppTableColumn('Actions', width: 170),
                  ],
                  rowCount: pageItems.length,
                  rowBuilder: (i) {
                    final l = pageItems[i];
                    return [
                      CellText(l.studentName, strong: true),
                      CellText(l.room),
                      CellText(l.leaveType),
                      CellText(df.format(l.from)),
                      CellText(df.format(l.to)),
                      StatusBadge(status: l.status),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          tooltip: 'View',
                          icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.textSecondary),
                          onPressed: () => showAppDialog(context, title: 'Leave Request Details', content: _leaveDetails(l)),
                        ),
                        if (l.status == 'Pending') ...[
                          IconButton(
                            tooltip: 'Approve',
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.success),
                            onPressed: () async {
                              final ok = await showConfirmDialog(context, title: 'Approve Leave', message: 'Approve leave request for ${l.studentName}?');
                              if (ok) {
                                ref.read(leavesProvider.notifier).updateStatus(l.id, 'Approved');
                                if (context.mounted) showAppSnackBar(context, 'Leave approved for ${l.studentName}.');
                              }
                            },
                          ),
                          IconButton(
                            tooltip: 'Reject',
                            icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.danger),
                            onPressed: () async {
                              final ok = await showConfirmDialog(context, title: 'Reject Leave', message: 'Reject leave request for ${l.studentName}?', danger: true, confirmLabel: 'Reject');
                              if (ok) {
                                ref.read(leavesProvider.notifier).updateStatus(l.id, 'Rejected');
                                if (context.mounted) showAppSnackBar(context, 'Leave rejected for ${l.studentName}.', isError: true);
                              }
                            },
                          ),
                        ],
                      ]),
                    ];
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPagination(currentPage: page, totalPages: totalPages, totalItems: filtered.length, pageSize: pageSize, onPageChanged: (p) => setState(() => page = p)),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _leaveDetails(l) {
    final df = DateFormat('d MMMM yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _row('Student', l.studentName),
        _row('Room', l.room),
        _row('Leave Type', l.leaveType),
        _row('Reason', l.reason),
        _row('From', df.format(l.from)),
        _row('To', df.format(l.to)),
        _row('Destination', l.destination),
        _row('Emergency Contact', l.emergencyContact),
        _row('Status', l.status),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          ],
        ),
      );
}

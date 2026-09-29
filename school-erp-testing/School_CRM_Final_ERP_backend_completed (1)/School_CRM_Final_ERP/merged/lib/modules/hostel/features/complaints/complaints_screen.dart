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
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/app_breadcrumb.dart';

class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key});
  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  String query = '';
  String statusFilter = 'All Status';
  String categoryFilter = 'All Categories';
  int page = 1;
  final pageSize = 8;

  @override
  Widget build(BuildContext context) {
    final complaints = ref.watch(complaintsProvider);
    final df = DateFormat('d MMM yyyy');
    final categories = ['All Categories', ...{for (final c in complaints) c.category}];

    final filtered = complaints.where((c) {
      final matchesQuery = query.isEmpty || c.studentName.toLowerCase().contains(query.toLowerCase());
      final matchesStatus = statusFilter == 'All Status' || c.status == statusFilter;
      final matchesCategory = categoryFilter == 'All Categories' || c.category == categoryFilter;
      return matchesQuery && matchesStatus && matchesCategory;
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBreadcrumb(items: const ['Complaint Management']),
                  const SizedBox(height: 10),
                  Text('Complaint Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  SizedBox(height: 4),
                  Text('Track and resolve student complaints across categories.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
              PrimaryButton(label: 'New Complaint', icon: Icons.add_rounded, onPressed: () {}),
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
                    SizedBox(width: 220, child: AppSearchField(hint: 'Search student...', onChanged: (v) => setState(() { query = v; page = 1; }))),
                    FilterDropdown(label: 'Category', value: categoryFilter, options: categories, onChanged: (v) => setState(() { categoryFilter = v!; page = 1; })),
                    FilterDropdown(
                      label: 'Status',
                      value: statusFilter,
                      options: const ['All Status', 'Open', 'In Progress', 'Resolved', 'Closed'],
                      onChanged: (v) => setState(() { statusFilter = v!; page = 1; }),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppDataTable(
                  minWidth: 1050,
                  columns: const [
                    AppTableColumn('ID', width: 80),
                    AppTableColumn('Student', width: 130),
                    AppTableColumn('Category', width: 100),
                    AppTableColumn('Priority', width: 90),
                    AppTableColumn('Date', width: 100),
                    AppTableColumn('Assigned To', width: 140),
                    AppTableColumn('Status', width: 100),
                    AppTableColumn('Actions', width: 120),
                  ],
                  rowCount: pageItems.length,
                  rowBuilder: (i) {
                    final c = pageItems[i];
                    return [
                      CellText(c.id),
                      CellText(c.studentName, strong: true),
                      CellText(c.category),
                      StatusBadge(status: c.priority == 'Urgent' || c.priority == 'High' ? 'Rejected' : c.priority == 'Medium' ? 'Pending' : 'Approved'),
                      CellText(df.format(c.date)),
                      CellText(c.assignedTo),
                      StatusBadge(status: c.status),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
                        onSelected: (v) async {
                          final ok = await showConfirmDialog(context, title: 'Update Status', message: 'Mark complaint ${c.id} as $v?');
                          if (ok) {
                            ref.read(complaintsProvider.notifier).updateStatus(c.id, v);
                            if (context.mounted) showAppSnackBar(context, 'Complaint updated to $v.');
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'In Progress', child: Text('Mark In Progress')),
                          PopupMenuItem(value: 'Resolved', child: Text('Mark Resolved')),
                          PopupMenuItem(value: 'Closed', child: Text('Close Complaint')),
                        ],
                      ),
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
}

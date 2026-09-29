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
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_breadcrumb.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});
  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  String query = '';
  String roleFilter = 'All Roles';

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(staffProvider).value ?? [];
    final df = DateFormat('d MMM yyyy');
    final roles = ['All Roles', ...{for (final s in staff) s.role}];

    final filtered = staff.where((s) {
      final matchesQuery = query.isEmpty || s.name.toLowerCase().contains(query.toLowerCase());
      final matchesRole = roleFilter == 'All Roles' || s.role == roleFilter;
      return matchesQuery && matchesRole;
    }).toList();

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
                  AppBreadcrumb(items: const ['Staff Management']),
                  const SizedBox(height: 10),
                  Text('Staff Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  SizedBox(height: 4),
                  Text('Manage wardens, accountants, and support staff.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
              PrimaryButton(label: 'Add Staff', icon: Icons.person_add_alt_1_rounded, onPressed: () {}),
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
                    SizedBox(width: 240, child: AppSearchField(hint: 'Search staff...', onChanged: (v) => setState(() => query = v))),
                    FilterDropdown(label: 'Role', value: roleFilter, options: roles, onChanged: (v) => setState(() => roleFilter = v!)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppDataTable(
                  minWidth: 950,
                  columns: const [
                    AppTableColumn('Staff', width: 190),
                    AppTableColumn('Employee ID', width: 120),
                    AppTableColumn('Role', width: 150),
                    AppTableColumn('Phone', width: 120),
                    AppTableColumn('Joining Date', width: 120),
                    AppTableColumn('Status', width: 100),
                    AppTableColumn('Actions', width: 90),
                  ],
                  rowCount: filtered.length,
                  rowBuilder: (i) {
                    final s = filtered[i];
                    return [
                      Row(children: [
                        AppAvatar(initials: s.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase(), size: 32),
                        const SizedBox(width: 10),
                        Expanded(child: CellText(s.name, strong: true)),
                      ]),
                      CellText(s.employeeId),
                      CellText(s.role),
                      CellText(s.phone),
                      CellText(df.format(s.joiningDate)),
                      StatusBadge(status: s.status),
                      RowActions(onView: () {}, onEdit: () {}),
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
}

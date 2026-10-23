import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/providers/app_providers.dart';
import '../../data/hostel_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_data_table.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/filter_dropdown.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_breadcrumb.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/confirm_dialog.dart';

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
              PrimaryButton(
                label: 'Add Staff',
                icon: Icons.person_add_alt_1_rounded,
                onPressed: () => _showAddStaffDialog(context),
              ),
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

  void _showAddStaffDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String role = 'Warden';
    bool saving = false;

    showAppDialog(
      context,
      title: 'Add Hostel Staff',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
              items: const ['Chief Hostel Warden', 'Warden', 'Assistant Warden', 'Accountant', 'Hostel Supervisor', 'Security Guard']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => role = v!),
            ),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
                const SizedBox(width: 10),
                PrimaryButton(
                  label: saving ? 'Saving...' : 'Add Staff',
                  icon: Icons.check_rounded,
                  onPressed: saving ? null : () async {
                    if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                      showAppSnackBar(context, 'Please enter name and phone.', isError: true);
                      return;
                    }
                    setState(() => saving = true);
                    try {
                      await HostelService().createStaffMember(
                        name: nameCtrl.text.trim(),
                        role: role,
                        phone: phoneCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                      );
                      ref.invalidate(staffProvider);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        showAppSnackBar(context, 'Staff "${nameCtrl.text.trim()}" added successfully.');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showAppSnackBar(context, 'Failed to add staff: $e', isError: true);
                      }
                    } finally {
                      setState(() => saving = false);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

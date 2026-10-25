import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../models/staff.dart';
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
import '../../shared/widgets/stat_card.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});
  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  String query = '';
  String roleFilter = 'All Roles';
  String statusFilter = 'All Statuses';

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(staffProvider);
    final df = DateFormat('d MMM yyyy');
    final roles = ['All Roles', ...{for (final s in staff) s.role}];

    final filtered = staff.where((s) {
      final q = query.toLowerCase().trim();
      final matchesQuery = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.employeeId.toLowerCase().contains(q) ||
          s.role.toLowerCase().contains(q) ||
          s.phone.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q);

      final matchesRole = roleFilter == 'All Roles' || s.role == roleFilter;
      final matchesStatus = statusFilter == 'All Statuses' ||
          s.status.toLowerCase() == statusFilter.toLowerCase();

      return matchesQuery && matchesRole && matchesStatus;
    }).toList();

    final totalCount = staff.length;
    final activeCount = staff.where((s) => s.status.toLowerCase() == 'active').length;
    final inactiveCount = staff.where((s) => s.status.toLowerCase() != 'active').length;
    final wardenCount = staff.where((s) => s.role.toLowerCase().contains('warden')).length;

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
                    AppBreadcrumb(items: ['Hostel Management', 'Staff Management']),
                    SizedBox(height: 10),
                    Text(
                      'Staff Management',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage wardens, supervisors, caretakers, and support staff.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 10,
                  children: [
                    SecondaryButton(
                      label: 'Refresh',
                      icon: Icons.refresh_rounded,
                      onPressed: () => ref.read(staffProvider.notifier).reload(),
                    ),
                    PrimaryButton(
                      label: 'Add Staff',
                      icon: Icons.person_add_alt_1_rounded,
                      onPressed: () => _showAddStaffDialog(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Stat Cards Row
            GridView.count(
              crossAxisCount: Responsive.statColumns(context).clamp(1, 4),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.8,
              children: [
                StatCard(
                  icon: Icons.badge_outlined,
                  color: AppColors.primary,
                  value: '$totalCount',
                  label: 'Total Staff',
                ),
                StatCard(
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  value: '$activeCount',
                  label: 'Active Staff',
                ),
                StatCard(
                  icon: Icons.shield_outlined,
                  color: AppColors.purple,
                  value: '$wardenCount',
                  label: 'Wardens',
                ),
                StatCard(
                  icon: Icons.pause_circle_outline_rounded,
                  color: AppColors.warning,
                  value: '$inactiveCount',
                  label: 'Inactive Staff',
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
                      SizedBox(
                        width: 260,
                        child: AppSearchField(
                          hint: 'Search name, ID, role...',
                          onChanged: (v) => setState(() => query = v),
                        ),
                      ),
                      FilterDropdown(
                        label: 'Role',
                        value: roleFilter,
                        options: roles,
                        onChanged: (v) => setState(() => roleFilter = v!),
                      ),
                      FilterDropdown(
                        label: 'Status',
                        value: statusFilter,
                        options: const ['All Statuses', 'Active', 'Inactive'],
                        onChanged: (v) => setState(() => statusFilter = v!),
                      ),
                      if (query.isNotEmpty || roleFilter != 'All Roles' || statusFilter != 'All Statuses')
                        TextButton.icon(
                          onPressed: () => setState(() {
                            query = '';
                            roleFilter = 'All Roles';
                            statusFilter = 'All Statuses';
                          }),
                          icon: const Icon(Icons.clear_all_rounded, size: 18),
                          label: const Text('Reset'),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_search_rounded, size: 54, color: AppColors.textMuted),
                          const SizedBox(height: 14),
                          const Text(
                            'No staff members found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            query.isNotEmpty || roleFilter != 'All Roles' || statusFilter != 'All Statuses'
                                ? 'Try adjusting your search query or filter options.'
                                : 'Get started by adding your first hostel staff member.',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 18),
                          PrimaryButton(
                            label: 'Add Staff',
                            icon: Icons.person_add_alt_1_rounded,
                            onPressed: () => _showAddStaffDialog(context),
                          ),
                        ],
                      ),
                    )
                  else
                    AppDataTable(
                      minWidth: 1050,
                      columns: const [
                        AppTableColumn('Staff', width: 220),
                        AppTableColumn('Employee ID', width: 130),
                        AppTableColumn('Role', width: 160),
                        AppTableColumn('Phone', width: 130),
                        AppTableColumn('Joining Date', width: 120),
                        AppTableColumn('Status', width: 100),
                        AppTableColumn('Actions', width: 160),
                      ],
                      rowCount: filtered.length,
                      rowBuilder: (i) {
                        final s = filtered[i];
                        return [
                          Row(
                            children: [
                              AppAvatar(initials: _getInitials(s.name), size: 34),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CellText(s.name, strong: true),
                                    if (s.email.isNotEmpty)
                                      Text(
                                        s.email,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          CellText(s.employeeId.isEmpty ? 'N/A' : s.employeeId),
                          CellText(s.role),
                          CellText(s.phone.isEmpty ? 'N/A' : s.phone),
                          CellText(df.format(s.joiningDate)),
                          StatusBadge(status: s.status),
                          RowActions(
                            onView: () => _showViewStaffDialog(context, s),
                            onEdit: () => _showEditStaffDialog(context, s),
                            onDelete: () => _confirmDeleteStaff(context, s),
                            moreItems: [
                              if (s.status.toLowerCase() == 'active')
                                PopupMenuItem(
                                  onTap: () => _toggleStaffStatus(context, s, 'Inactive'),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.block_rounded, size: 16, color: AppColors.warning),
                                      SizedBox(width: 8),
                                      Text('Mark Inactive'),
                                    ],
                                  ),
                                )
                              else
                                PopupMenuItem(
                                  onTap: () => _toggleStaffStatus(context, s, 'Active'),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.success),
                                      SizedBox(width: 8),
                                      Text('Mark Active'),
                                    ],
                                  ),
                                ),
                            ],
                          ),
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

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showViewStaffDialog(BuildContext context, StaffMember s) async {
    final df = DateFormat('d MMM yyyy');
    final shouldEdit = await showAppDialog<bool>(
      context,
      title: 'Staff Profile',
      content: Builder(
        builder: (dialogCtx) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  AppAvatar(initials: _getInitials(s.name), size: 60),
                  const SizedBox(height: 12),
                  Text(
                    s.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          s.role,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: s.status),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _detailRow(Icons.badge_outlined, 'Employee ID', s.employeeId.isEmpty ? 'N/A' : s.employeeId),
            const SizedBox(height: 12),
            _detailRow(Icons.phone_outlined, 'Phone', s.phone.isEmpty ? 'N/A' : s.phone),
            const SizedBox(height: 12),
            _detailRow(Icons.email_outlined, 'Email', s.email.isEmpty ? 'N/A' : s.email),
            const SizedBox(height: 12),
            _detailRow(Icons.calendar_today_outlined, 'Joining Date', df.format(s.joiningDate)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(
                  label: 'Close',
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                ),
                const SizedBox(width: 10),
                PrimaryButton(
                  label: 'Edit Staff',
                  icon: Icons.edit_rounded,
                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (shouldEdit == true && context.mounted) {
      _showEditStaffDialog(context, s);
    }
  }

  void _showEditStaffDialog(BuildContext context, StaffMember s) {
    final nameCtrl = TextEditingController(text: s.name);
    final phoneCtrl = TextEditingController(text: s.phone);
    final emailCtrl = TextEditingController(text: s.email);
    final empIdCtrl = TextEditingController(text: s.employeeId);
    bool saving = false;

    final availableRoles = [
      'Chief Hostel Warden',
      'Warden',
      'Assistant Warden',
      'Hostel Supervisor',
      'Caretaker',
      'Accountant',
      'Security Guard',
      'Other',
    ];

    String role = s.role.trim();
    if (role.isEmpty) {
      role = 'Warden';
    } else {
      final match = availableRoles.firstWhere(
        (r) => r.toLowerCase() == role.toLowerCase(),
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        role = match;
      } else {
        availableRoles.add(role);
      }
    }

    String status = s.status.trim().toLowerCase() == 'inactive' ? 'Inactive' : 'Active';

    showAppDialog(
      context,
      title: 'Edit Staff Member',
      content: StatefulBuilder(
        builder: (ctx, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: role,
              decoration: const InputDecoration(labelText: 'Role *', border: OutlineInputBorder()),
              items: availableRoles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setDialogState(() => role = v ?? 'Warden'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: empIdCtrl,
              decoration: const InputDecoration(labelText: 'Employee ID', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: status,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: const ['Active', 'Inactive'].map((st) => DropdownMenuItem(value: st, child: Text(st))).toList(),
              onChanged: (v) => setDialogState(() => status = v ?? 'Active'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
                const SizedBox(width: 10),
                PrimaryButton(
                  label: saving ? 'Saving...' : 'Save Changes',
                  icon: Icons.check_rounded,
                  onPressed: saving
                      ? null
                      : () async {
                          if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                            showAppSnackBar(context, 'Please enter name and phone number.', isError: true);
                            return;
                          }
                          setDialogState(() => saving = true);
                          try {
                            await HostelService().updateStaffMember(
                              id: s.id,
                              name: nameCtrl.text.trim(),
                              role: role,
                              phone: phoneCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              employeeId: empIdCtrl.text.trim(),
                              status: status,
                            );
                            await ref.read(staffProvider.notifier).reload();
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              showAppSnackBar(context, 'Staff "${nameCtrl.text.trim()}" updated successfully.');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showAppSnackBar(context, 'Failed to update staff: $e', isError: true);
                            }
                          } finally {
                            if (ctx.mounted) setDialogState(() => saving = false);
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

  Future<void> _confirmDeleteStaff(BuildContext context, StaffMember s) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Staff Member',
      message: 'Are you sure you want to delete "${s.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      danger: true,
    );
    if (confirmed && context.mounted) {
      try {
        await ref.read(staffProvider.notifier).removeStaff(s.id);
        if (context.mounted) {
          showAppSnackBar(context, 'Staff "${s.name}" deleted successfully.');
        }
      } catch (e) {
        if (context.mounted) {
          showAppSnackBar(context, 'Failed to delete staff: $e', isError: true);
        }
      }
    }
  }

  Future<void> _toggleStaffStatus(BuildContext context, StaffMember s, String newStatus) async {
    try {
      await ref.read(staffProvider.notifier).updateStatus(s.id, newStatus);
      if (context.mounted) {
        showAppSnackBar(context, 'Staff "${s.name}" status updated to $newStatus.');
      }
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(context, 'Failed to update status: $e', isError: true);
      }
    }
  }

  void _showAddStaffDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final empIdCtrl = TextEditingController();
    String role = 'Warden';
    String status = 'Active';
    bool saving = false;

    final availableRoles = const [
      'Chief Hostel Warden',
      'Warden',
      'Assistant Warden',
      'Hostel Supervisor',
      'Caretaker',
      'Accountant',
      'Security Guard',
      'Other',
    ];

    showAppDialog(
      context,
      title: 'Add Hostel Staff',
      content: StatefulBuilder(
        builder: (ctx, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: role,
              decoration: const InputDecoration(labelText: 'Role *', border: OutlineInputBorder()),
              items: availableRoles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setDialogState(() => role = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: empIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Employee ID (Optional)',
                hintText: 'e.g. HST-101 (auto-generated if empty)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: status,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: const ['Active', 'Inactive'].map((st) => DropdownMenuItem(value: st, child: Text(st))).toList(),
              onChanged: (v) => setDialogState(() => status = v!),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
                const SizedBox(width: 10),
                PrimaryButton(
                  label: saving ? 'Saving...' : 'Add Staff',
                  icon: Icons.check_rounded,
                  onPressed: saving
                      ? null
                      : () async {
                          if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                            showAppSnackBar(context, 'Please enter name and phone number.', isError: true);
                            return;
                          }
                          setDialogState(() => saving = true);
                          try {
                            await HostelService().createStaffMember(
                              name: nameCtrl.text.trim(),
                              role: role,
                              phone: phoneCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              employeeId: empIdCtrl.text.trim(),
                              status: status,
                              joiningDate: DateTime.now(),
                            );
                            await ref.read(staffProvider.notifier).reload();
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              showAppSnackBar(context, 'Staff "${nameCtrl.text.trim()}" added successfully.');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showAppSnackBar(context, 'Failed to add staff: $e', isError: true);
                            }
                          } finally {
                            if (ctx.mounted) setDialogState(() => saving = false);
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

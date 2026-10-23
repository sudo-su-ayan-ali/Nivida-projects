import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import '../../data/hostel_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_data_table.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/filter_dropdown.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/app_breadcrumb.dart';
import '../../shared/widgets/app_dialog.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});
  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  String query = '';
  String statusFilter = 'All Status';

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(maintenanceProvider);
    final df = DateFormat('d MMM yyyy');
    final pending = requests.where((r) => r.status == 'Pending').length;
    final inProgress = requests.where((r) => r.status == 'In Progress').length;
    final completed = requests.where((r) => r.status == 'Completed').length;

    final filtered = requests.where((r) {
      final matchesQuery = query.isEmpty || r.room.toLowerCase().contains(query.toLowerCase()) || r.issue.toLowerCase().contains(query.toLowerCase());
      final matchesStatus = statusFilter == 'All Status' || r.status == statusFilter;
      return matchesQuery && matchesStatus;
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
                  AppBreadcrumb(items: const ['Maintenance Management']),
                  const SizedBox(height: 10),
                  Text('Maintenance Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  SizedBox(height: 4),
                  Text('Track and assign maintenance requests across the hostel.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
              PrimaryButton(
                label: 'New Request',
                icon: Icons.add_rounded,
                onPressed: () => _showNewRequestDialog(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: Responsive.statColumns(context).clamp(1, 3),
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
            childAspectRatio: 1.7,
            children: [
              StatCard(icon: Icons.pending_actions_rounded, color: AppColors.warning, value: '$pending', label: 'Pending'),
              StatCard(icon: Icons.autorenew_rounded, color: AppColors.info, value: '$inProgress', label: 'In Progress'),
              StatCard(icon: Icons.check_circle_rounded, color: AppColors.success, value: '$completed', label: 'Completed'),
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
                    SizedBox(width: 240, child: AppSearchField(hint: 'Search room or issue...', onChanged: (v) => setState(() => query = v))),
                    FilterDropdown(
                      label: 'Status',
                      value: statusFilter,
                      options: const ['All Status', 'Pending', 'In Progress', 'Completed'],
                      onChanged: (v) => setState(() => statusFilter = v!),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppDataTable(
                  minWidth: 1050,
                  columns: const [
                    AppTableColumn('Request ID', width: 90),
                    AppTableColumn('Room / Block', width: 140),
                    AppTableColumn('Category', width: 100),
                    AppTableColumn('Issue', width: 200),
                    AppTableColumn('Assigned Staff', width: 130),
                    AppTableColumn('Expected', width: 100),
                    AppTableColumn('Status', width: 110),
                    AppTableColumn('Actions', width: 90),
                  ],
                  rowCount: filtered.length,
                  rowBuilder: (i) {
                    final m = filtered[i];
                    return [
                      CellText(m.id),
                      CellText('${m.room} · ${m.block.split(' ').take(2).join(' ')}'),
                      CellText(m.category),
                      CellText(m.issue),
                      CellText(m.assignedStaff),
                      CellText(df.format(m.expectedDate)),
                      StatusBadge(status: m.status),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
                        onSelected: (v) async {
                          final ok = await showConfirmDialog(context, title: 'Update Status', message: 'Mark ${m.id} as $v?');
                          if (ok) {
                            ref.read(maintenanceProvider.notifier).updateStatus(m.id, v);
                            if (context.mounted) showAppSnackBar(context, 'Maintenance request updated to $v.');
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'In Progress', child: Text('Mark In Progress')),
                          PopupMenuItem(value: 'Completed', child: Text('Mark Completed')),
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

  void _showNewRequestDialog(BuildContext context) async {
    final rooms = await HostelService().fetchRoomsWithModel();
    if (rooms.isEmpty) {
      if (context.mounted) showAppSnackBar(context, 'No rooms available for maintenance request.', isError: true);
      return;
    }

    String selectedRoomId = rooms.first.id;
    String category = 'Plumbing';
    final descCtrl = TextEditingController();
    bool saving = false;

    if (!context.mounted) return;

    showAppDialog(
      context,
      title: 'New Maintenance Request',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: selectedRoomId,
              decoration: const InputDecoration(labelText: 'Room', border: OutlineInputBorder()),
              items: rooms.map((r) => DropdownMenuItem<String>(value: r.id, child: Text('Room ${r.number} (${r.block})'))).toList(),
              onChanged: (v) => setState(() => selectedRoomId = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: const ['Plumbing', 'Electrical', 'Carpentry', 'AC / Heating', 'Civil / Painting', 'Pest Control', 'Other']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
            ),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Issue Description', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
                const SizedBox(width: 10),
                PrimaryButton(
                  label: saving ? 'Submitting...' : 'Submit Request',
                  icon: Icons.check_rounded,
                  onPressed: saving ? null : () async {
                    if (descCtrl.text.trim().isEmpty) {
                      showAppSnackBar(context, 'Please enter an issue description.', isError: true);
                      return;
                    }
                    setState(() => saving = true);
                    try {
                      await HostelService().createMaintenanceRequest(
                        roomId: selectedRoomId,
                        category: category,
                        description: descCtrl.text.trim(),
                      );
                      ref.invalidate(maintenanceProvider);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        showAppSnackBar(context, 'Maintenance request submitted.');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showAppSnackBar(context, 'Failed to submit maintenance request: $e', isError: true);
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

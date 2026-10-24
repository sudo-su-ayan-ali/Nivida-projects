import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import '../../data/hostel_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/filter_dropdown.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/app_breadcrumb.dart';

class NoticesScreen extends ConsumerStatefulWidget {
  const NoticesScreen({super.key});

  @override
  ConsumerState<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends ConsumerState<NoticesScreen> {
  String query = '';
  String categoryFilter = 'All Categories';
  String statusFilter = 'All Status';

  @override
  Widget build(BuildContext context) {
    final notices = ref.watch(noticesProvider);
    final df = DateFormat('d MMM yyyy');
    final columns = Responsive.gridColumns(context, max: 3);

    final categories = [
      'All Categories',
      ...{for (final n in notices) n.category.trim()}.where((c) => c.isNotEmpty),
    ];

    final filtered = notices.where((n) {
      final matchesQuery = query.isEmpty ||
          n.title.toLowerCase().contains(query.toLowerCase()) ||
          n.description.toLowerCase().contains(query.toLowerCase()) ||
          n.audience.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = categoryFilter == 'All Categories' || n.category == categoryFilter;
      final matchesStatus = statusFilter == 'All Status' || n.status == statusFilter;
      return matchesQuery && matchesCategory && matchesStatus;
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
                    AppBreadcrumb(items: ['Notice Management']),
                    SizedBox(height: 10),
                    Text(
                      'Notice Management',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Publish and manage hostel-wide announcements for students and staff.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                PrimaryButton(
                  label: 'Create Notice',
                  icon: Icons.add_rounded,
                  onPressed: () => _showCreateNoticeDialog(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    child: AppSearchField(
                      hint: 'Search notices...',
                      onChanged: (v) => setState(() => query = v),
                    ),
                  ),
                  FilterDropdown(
                    label: 'Category',
                    value: categoryFilter,
                    options: categories,
                    onChanged: (v) => setState(() => categoryFilter = v!),
                  ),
                  FilterDropdown(
                    label: 'Status',
                    value: statusFilter,
                    options: const ['All Status', 'Active', 'Archived'],
                    onChanged: (v) => setState(() => statusFilter = v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (filtered.isEmpty)
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.campaign_outlined, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text(
                        'No Notices Found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        query.isNotEmpty || categoryFilter != 'All Categories' || statusFilter != 'All Status'
                            ? 'No announcements match the selected search or filter criteria.'
                            : 'No announcements have been published for this hostel yet.',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Publish First Notice',
                        icon: Icons.add_rounded,
                        onPressed: () => _showCreateNoticeDialog(context),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 1.35,
                ),
                itemBuilder: (context, i) {
                  final n = filtered[i];
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                n.category,
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                            ),
                            if (n.priority == 'High' || n.priority == 'Urgent') ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.dangerSoft,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  n.priority.toUpperCase(),
                                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.danger),
                                ),
                              ),
                            ],
                            const Spacer(),
                            StatusBadge(status: n.status),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
                              onSelected: (v) async {
                                if (v == 'toggle_status') {
                                  final newStatus = n.status == 'Active' ? 'Archived' : 'Active';
                                  final ok = await showConfirmDialog(
                                    context,
                                    title: 'Change Notice Status',
                                    message: 'Mark notice "${n.title}" as $newStatus?',
                                  );
                                  if (ok) {
                                    ref.read(noticesProvider.notifier).updateStatus(n.id, newStatus);
                                    if (context.mounted) {
                                      showAppSnackBar(context, 'Notice marked as $newStatus.');
                                    }
                                  }
                                } else if (v == 'delete') {
                                  final ok = await showConfirmDialog(
                                    context,
                                    title: 'Delete Notice',
                                    message: 'Are you sure you want to delete notice "${n.title}"? This cannot be undone.',
                                    confirmLabel: 'Delete',
                                    danger: true,
                                  );
                                  if (ok) {
                                    ref.read(noticesProvider.notifier).removeNotice(n.id);
                                    if (context.mounted) {
                                      showAppSnackBar(context, 'Notice deleted.');
                                    }
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'toggle_status',
                                  child: Text(n.status == 'Active' ? 'Archive Notice' : 'Activate Notice'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete Notice', style: TextStyle(color: AppColors.danger)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          n.title,
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            n.description,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Divider(color: AppColors.divider),
                        Row(
                          children: [
                            const Icon(Icons.groups_rounded, size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                n.audience,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              df.format(n.publishDate),
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showCreateNoticeDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'General';
    String audience = 'All Students';
    String priority = 'Normal';
    bool saving = false;

    showAppDialog(
      context,
      title: 'Publish New Notice',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                hintText: 'Enter notice title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: const ['General', 'Holiday', 'Mess', 'Maintenance', 'Discipline', 'Urgent']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => category = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Priority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: priority,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: const ['Normal', 'High', 'Urgent']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (v) => setState(() => priority = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Audience', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: audience,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const ['All Students', 'Block A', 'Block B', 'Staff', 'Hostel Residents']
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) => setState(() => audience = v!),
            ),
            const SizedBox(height: 14),
            const Text('Notice Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter notice announcements and guidelines...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(ctx),
                ),
                const SizedBox(width: 10),
                PrimaryButton(
                  label: saving ? 'Publishing...' : 'Publish Notice',
                  icon: Icons.campaign_rounded,
                  onPressed: saving
                      ? null
                      : () async {
                          if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) {
                            showAppSnackBar(context, 'Please enter both title and details.', isError: true);
                            return;
                          }
                          setState(() => saving = true);
                          try {
                            await HostelService().createNotice(
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              category: category,
                              audience: audience,
                              priority: priority,
                            );
                            await ref.read(noticesProvider.notifier).reload();
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              showAppSnackBar(context, 'Notice "${titleCtrl.text.trim()}" published successfully.');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showAppSnackBar(context, 'Failed to publish notice: $e', isError: true);
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

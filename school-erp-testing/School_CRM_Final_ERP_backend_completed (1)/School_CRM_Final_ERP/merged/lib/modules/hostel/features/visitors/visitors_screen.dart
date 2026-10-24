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
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/app_breadcrumb.dart';
import '../../shared/widgets/app_dialog.dart';

class VisitorsScreen extends ConsumerStatefulWidget {
  const VisitorsScreen({super.key});
  @override
  ConsumerState<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends ConsumerState<VisitorsScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final visitors = ref.watch(visitorsProvider);
    final df = DateFormat('d MMM, h:mm a');
    final insideNow = visitors.where((v) => v.status == 'Checked In').length;
    final todayCount = visitors.length;

    final filtered = visitors.where((v) =>
        query.isEmpty || v.visitorName.toLowerCase().contains(query.toLowerCase()) || v.studentName.toLowerCase().contains(query.toLowerCase())).toList();

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
                  AppBreadcrumb(items: const ['Visitor Management']),
                  const SizedBox(height: 10),
                  Text('Visitor Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  SizedBox(height: 4),
                  Text('Log and track visitor check-ins across the hostel.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
              PrimaryButton(
                label: 'Check-In Visitor',
                icon: Icons.person_add_alt_1_rounded,
                onPressed: () => _showCheckInDialog(context),
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
              StatCard(icon: Icons.today_rounded, color: AppColors.primary, value: '$todayCount', label: "Today's Visitors"),
              StatCard(icon: Icons.person_pin_circle_rounded, color: AppColors.success, value: '$insideNow', label: 'Currently Inside'),
              StatCard(icon: Icons.history_rounded, color: AppColors.info, value: '${visitors.length}', label: 'Total Records'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 260, child: AppSearchField(hint: 'Search visitor or student...', onChanged: (v) => setState(() => query = v))),
                const SizedBox(height: AppSpacing.lg),
                AppDataTable(
                  minWidth: 1100,
                  columns: const [
                    AppTableColumn('Visitor', width: 140),
                    AppTableColumn('Student', width: 130),
                    AppTableColumn('Relation', width: 90),
                    AppTableColumn('Phone', width: 120),
                    AppTableColumn('Purpose', width: 120),
                    AppTableColumn('Check-in', width: 130),
                    AppTableColumn('Check-out', width: 130),
                    AppTableColumn('Status', width: 100),
                    AppTableColumn('Actions', width: 90),
                  ],
                  rowCount: filtered.length,
                  rowBuilder: (i) {
                    final v = filtered[i];
                    return [
                      CellText(v.visitorName, strong: true),
                      CellText(v.studentName),
                      CellText(v.relation),
                      CellText(v.phone),
                      CellText(v.purpose),
                      CellText(df.format(v.checkIn)),
                      CellText(v.checkOut != null ? df.format(v.checkOut!) : '-'),
                      StatusBadge(status: v.status),
                      v.status == 'Checked In'
                          ? IconButton(
                              tooltip: 'Check Out',
                              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
                              onPressed: () async {
                                final ok = await showConfirmDialog(context, title: 'Check Out Visitor', message: 'Check out ${v.visitorName}?');
                                if (ok) {
                                  ref.read(visitorsProvider.notifier).checkOut(v.id);
                                  if (context.mounted) showAppSnackBar(context, '${v.visitorName} checked out.');
                                }
                              },
                            )
                          : const SizedBox.shrink(),
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

  void _showCheckInDialog(BuildContext context) async {
    final students = ref.read(studentsProvider).value ?? [];
    if (students.isEmpty) {
      if (context.mounted) showAppSnackBar(context, 'No students available to assign a visitor to.', isError: true);
      return;
    }

    String selectedStudentId = students.first.coreStudentId ?? students.first.id;
    final visitorCtrl = TextEditingController();
    final relationCtrl = TextEditingController(text: 'Father');
    final phoneCtrl = TextEditingController();
    bool saving = false;

    showAppDialog(
      context,
      title: 'Check-In Visitor',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: selectedStudentId,
              decoration: const InputDecoration(labelText: 'Visiting Student', border: OutlineInputBorder()),
              items: students.map((s) => DropdownMenuItem<String>(
                value: s.coreStudentId ?? s.id,
                child: Text('${s.name} (${s.room})'),
              )).toList(),
              onChanged: (v) => setState(() => selectedStudentId = v!),
            ),
            const SizedBox(height: 12),
            TextField(controller: visitorCtrl, decoration: const InputDecoration(labelText: 'Visitor Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: relationCtrl, decoration: const InputDecoration(labelText: 'Relationship (e.g. Father, Mother, Brother)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Contact Phone', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
                const SizedBox(width: 10),
                PrimaryButton(
                  label: saving ? 'Checking in...' : 'Check In',
                  icon: Icons.check_rounded,
                  onPressed: saving ? null : () async {
                    if (visitorCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                      showAppSnackBar(context, 'Please enter visitor name and phone.', isError: true);
                      return;
                    }
                    setState(() => saving = true);
                    try {
                      await HostelService().createVisitor(
                        studentId: selectedStudentId,
                        visitorName: visitorCtrl.text.trim(),
                        relation: relationCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                      );
                      await ref.read(visitorsProvider.notifier).reload();
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        showAppSnackBar(context, 'Visitor "${visitorCtrl.text.trim()}" checked in successfully.');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showAppSnackBar(context, 'Failed to check in visitor: $e', isError: true);
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

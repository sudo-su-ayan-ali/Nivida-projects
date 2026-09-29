import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';
import '../widgets/common/responsive_grid.dart';
import '../widgets/dialogs/action_dialogs.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final assignments = app.assignments;

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 720;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Assignments', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('${app.pendingAssignmentsCount} of ${assignments.length} need grading', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                AppPrimaryButton(
                  label: 'Create Assignment',
                  icon: Icons.add_task_rounded,
                  onPressed: () => showAddAssignmentDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (assignments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No assignments yet — create one to get started.', style: AppTextStyles.itemSub)),
              )
            else
              ResponsiveGrid(
                minItemWidth: 320,
                maxColumns: 3,
                children: [for (final a in assignments) _AssignmentCard(item: a)],
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

class _AssignmentCard extends StatelessWidget {
  final AssignmentItem item;
  const _AssignmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final submitted = item.totalCount - item.pendingCount;
    final progress = item.totalCount == 0 ? 0.0 : submitted / item.totalCount;
    return AppCard(
      onTap: () => _openGradeDialog(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: item.icon, color: item.color, bgColor: item.bgColor, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: AppTextStyles.itemTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(item.meta, style: AppTextStyles.itemSub),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.scaffoldBg,
              valueColor: AlwaysStoppedAnimation(item.graded ? AppColors.green : AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$submitted / ${item.totalCount} submitted', style: AppTextStyles.itemSub),
              item.graded
                  ? const StatusPill(label: 'Graded', color: AppColors.green, bgColor: AppColors.greenBg)
                  : StatusPill(label: 'Pending (${item.pendingCount})', color: AppColors.orange, bgColor: AppColors.orangeBg),
            ],
          ),
        ],
      ),
    );
  }

  void _openGradeDialog(BuildContext context) {
    showAppFormDialog(
      context: context,
      title: item.title,
      child: _GradeBody(item: item),
    );
  }
}

class _GradeBody extends StatefulWidget {
  final AssignmentItem item;
  const _GradeBody({required this.item});

  @override
  State<_GradeBody> createState() => _GradeBodyState();
}

class _GradeBodyState extends State<_GradeBody> {
  late double _pending;

  @override
  void initState() {
    super.initState();
    _pending = widget.item.pendingCount.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.meta, style: AppTextStyles.itemSub),
        const SizedBox(height: 14),
        Text('Ungraded submissions: ${_pending.round()} / ${item.totalCount}', style: AppTextStyles.itemTitle),
        Slider(
          value: _pending,
          min: 0,
          max: item.totalCount.toDouble(),
          divisions: item.totalCount == 0 ? 1 : item.totalCount,
          activeColor: AppColors.primary,
          label: '${_pending.round()}',
          onChanged: (v) => setState(() => _pending = v),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                                onPressed: () async {
                  await context.read<AppState>().deleteAssignment(item.id);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  showAppSnack(context, 'Assignment deleted', icon: Icons.delete_outline);
                },
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.red),
                label: const Text('Delete', style: TextStyle(color: AppColors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppPrimaryButton(
                label: 'Save',
                icon: Icons.check_rounded,
                              onPressed: () async {
                  await context.read<AppState>().setAssignmentPending(item.id, _pending.round());
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  showAppSnack(context, 'Grading progress updated');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

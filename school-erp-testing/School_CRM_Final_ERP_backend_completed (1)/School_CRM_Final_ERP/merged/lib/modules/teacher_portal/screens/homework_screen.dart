import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';
import '../widgets/dialogs/action_dialogs.dart';

class HomeworkScreen extends StatelessWidget {
  const HomeworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.homework;

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
                    Text('Homework Submission Tracking', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('${app.totalSubmissionsReceived} / ${app.totalSubmissionsExpected} submitted • ${app.pendingSubmissionsCount} pending', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                AppPrimaryButton(
                  label: 'Assign Homework',
                  icon: Icons.add_task_rounded,
                  onPressed: () => showAddHomeworkDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No homework assigned yet — tap "Assign Homework" to get started.', style: AppTextStyles.itemSub)),
              )
            else
              for (final hw in list) _HomeworkCard(item: hw),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

class _HomeworkCard extends StatelessWidget {
  final HomeworkItem item;
  const _HomeworkCard({required this.item});

  Color get _progressColor {
    if (item.progress >= 1) return AppColors.green;
    if (item.progress >= 0.5) return AppColors.blue;
    return AppColors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final studentIds = item.submissions.keys.toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconBadge(icon: Icons.assignment_turned_in_outlined, color: AppColors.purple, bgColor: AppColors.purpleBg),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTextStyles.itemTitle),
                      Text('${item.className} • ${item.subject} • Due: ${item.dueDate}', style: AppTextStyles.itemSub),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => app.deleteHomework(item.id),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.delete_outline, size: 18, color: AppColors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: item.progress.clamp(0, 1).toDouble(),
                minHeight: 9,
                backgroundColor: AppColors.scaffoldBg,
                valueColor: AlwaysStoppedAnimation(_progressColor),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusPill(label: '${item.submittedCount} Submitted', color: AppColors.green, bgColor: AppColors.greenBg),
                StatusPill(label: '${item.pendingCount} Pending', color: AppColors.orange, bgColor: AppColors.orangeBg),
                StatusPill(label: '${item.lateCount} Late', color: AppColors.red, bgColor: AppColors.redBg),
              ],
            ),
            if (studentIds.isNotEmpty) ...[
              const Divider(color: AppColors.border, height: 26),
              Text('Tap a student\'s status to update it', style: AppTextStyles.caption),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final sid in studentIds)
                    _StudentStatusChip(
                      name: app.studentById(sid)?.name ?? 'Student',
                      status: item.submissions[sid] ?? 'Pending',
                      onTap: () => app.cycleSubmissionStatus(item.id, sid),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StudentStatusChip extends StatelessWidget {
  final String name;
  final String status;
  final VoidCallback onTap;
  const _StudentStatusChip({required this.name, required this.status, required this.onTap});

  Color get _color {
    switch (status) {
      case 'Submitted':
        return AppColors.blue;
      case 'Reviewed':
        return AppColors.green;
      case 'Late':
        return AppColors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  Color get _bg {
    switch (status) {
      case 'Submitted':
        return AppColors.blueBg;
      case 'Reviewed':
        return AppColors.greenBg;
      case 'Late':
        return AppColors.redBg;
      default:
        return AppColors.scaffoldBg;
    }
  }

  IconData get _icon {
    switch (status) {
      case 'Submitted':
        return Icons.upload_file_rounded;
      case 'Reviewed':
        return Icons.verified_rounded;
      case 'Late':
        return Icons.timer_off_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: _color.withOpacity(0.3))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 14, color: _color),
            const SizedBox(width: 6),
            Text(name, style: AppTextStyles.itemSub.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(width: 6),
            Text(status, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: _color)),
          ],
        ),
      ),
    );
  }
}

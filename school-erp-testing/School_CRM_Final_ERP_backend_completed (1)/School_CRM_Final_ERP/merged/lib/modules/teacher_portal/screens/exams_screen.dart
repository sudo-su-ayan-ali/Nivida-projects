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
import 'nav_indices.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final exams = app.exams;

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
                    Text('Exams & Marks', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('${exams.length} exams scheduled', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                AppPrimaryButton(
                  label: 'Schedule Exam',
                  icon: Icons.event_available_rounded,
                  onPressed: () => showAddExamDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (exams.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No exams scheduled — schedule one to get started.', style: AppTextStyles.itemSub)),
              )
            else
              ResponsiveGrid(
                minItemWidth: 300,
                maxColumns: 3,
                children: [for (final e in exams) _ExamCard(item: e)],
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

class _ExamCard extends StatelessWidget {
  final ExamItem item;
  const _ExamCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(item.date, style: AppTextStyles.itemSub.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<AppState>().deleteExam(item.id);
                    showAppSnack(context, 'Exam removed', icon: Icons.delete_outline);
                  },
                  icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.red),
                  label: const Text('Remove', style: TextStyle(color: AppColors.red, fontSize: 12.5)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<AppState>().setNavIndex(kGradebookNavIndex);
                    showAppSnack(context, 'Opened Gradebook — record marks for "${item.title}"', icon: Icons.grading_outlined);
                  },
                  icon: const Icon(Icons.grading_outlined, size: 16, color: AppColors.primary),
                  label: const Text('Record Marks', style: TextStyle(color: AppColors.primary, fontSize: 12.5)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../screens/nav_indices.dart';
import 'common/app_card.dart';

class HomeworkSubmissionCard extends StatelessWidget {
  const HomeworkSubmissionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.homework.take(3).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Homework Submissions',
            onAction: () => app.setNavIndex(kHomeworkNavIndex),
          ),
          const SizedBox(height: 4),
          Text('${app.totalSubmissionsReceived} / ${app.totalSubmissionsExpected} submitted', style: AppTextStyles.itemSub),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('No homework assigned yet.', style: AppTextStyles.itemSub))
          else
            for (final hw in list) _HomeworkRow(item: hw),
        ],
      ),
    );
  }
}

class _HomeworkRow extends StatelessWidget {
  final HomeworkItem item;
  const _HomeworkRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.read<AppState>().setNavIndex(kHomeworkNavIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            const IconBadge(icon: Icons.assignment_turned_in_outlined, color: AppColors.purple, bgColor: AppColors.purpleBg, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTextStyles.itemTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${item.className} • Due: ${item.dueDate}', style: AppTextStyles.itemSub),
                ],
              ),
            ),
            StatusPill(
              label: '${item.submittedCount}/${item.totalCount}',
              color: item.progress >= 1 ? AppColors.green : AppColors.orange,
              bgColor: item.progress >= 1 ? AppColors.greenBg : AppColors.orangeBg,
            ),
          ],
        ),
      ),
    );
  }
}

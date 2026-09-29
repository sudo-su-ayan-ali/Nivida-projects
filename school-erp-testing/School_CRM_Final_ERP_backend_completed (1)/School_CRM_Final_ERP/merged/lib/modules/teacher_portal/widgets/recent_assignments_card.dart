import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';

class RecentAssignmentsCard extends StatelessWidget {
  const RecentAssignmentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.assignments.take(4).toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recent Assignments',
            onAction: () => app.setNavIndex(3),
          ),
          const SizedBox(height: 14),
          if (list.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('No assignments yet.', style: AppTextStyles.itemSub))
          else
            for (final a in list) _AssignmentRow(item: a),
        ],
      ),
    );
  }
}

class _AssignmentRow extends StatelessWidget {
  final AssignmentItem item;
  const _AssignmentRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.read<AppState>().setNavIndex(3),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            IconBadge(icon: item.icon, color: item.color, bgColor: item.bgColor, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTextStyles.itemTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(item.meta, style: AppTextStyles.itemSub),
                ],
              ),
            ),
            item.graded
                ? const StatusPill(label: 'Graded', color: AppColors.green, bgColor: AppColors.greenBg)
                : StatusPill(label: 'Pending (${item.pendingCount})', color: AppColors.orange, bgColor: AppColors.orangeBg),
          ],
        ),
      ),
    );
  }
}

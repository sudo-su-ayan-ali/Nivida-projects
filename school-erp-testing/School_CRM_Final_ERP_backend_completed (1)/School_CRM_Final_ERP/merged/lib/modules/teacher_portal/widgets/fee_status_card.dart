import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../screens/nav_indices.dart';
import 'common/app_card.dart';

class FeeStatusCard extends StatelessWidget {
  const FeeStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.pendingFeeRecords.take(3).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Fee Status',
            onAction: () => app.setNavIndex(kFeesNavIndex),
          ),
          const SizedBox(height: 4),
          Text('${app.pendingFeesCount} students with dues • ₹${app.totalPendingFeeAmount.toStringAsFixed(0)} pending', style: AppTextStyles.itemSub),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('All fees are cleared 🎉', style: AppTextStyles.itemSub))
          else
            for (final f in list) _FeeRow(record: f),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final FeeRecord record;
  const _FeeRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final student = app.studentById(record.studentId);
    final overdue = record.status == 'Overdue';
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => app.setNavIndex(kFeesNavIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            InitialsAvatar(seed: student?.name ?? '?', size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student?.name ?? 'Student', style: AppTextStyles.itemTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('₹${record.amount.toStringAsFixed(0)} due ${record.dueDate}', style: AppTextStyles.itemSub),
                ],
              ),
            ),
            StatusPill(label: record.status, color: overdue ? AppColors.red : AppColors.orange, bgColor: overdue ? AppColors.redBg : AppColors.orangeBg),
          ],
        ),
      ),
    );
  }
}

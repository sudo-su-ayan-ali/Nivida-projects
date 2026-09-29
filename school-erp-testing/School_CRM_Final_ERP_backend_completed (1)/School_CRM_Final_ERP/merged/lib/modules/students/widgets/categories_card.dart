import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_card.dart';

/// "Student Categories" horizontal progress bars (General/OBC/SC/ST).
class CategoriesCard extends StatelessWidget {
  final Map<String, int> counts;
  final VoidCallback? onViewAll;
  const CategoriesCard({super.key, required this.counts, this.onViewAll});

  static const _colors = {
    'General': AppColors.success,
    'OBC': AppColors.success,
    'SC': AppColors.info,
    'ST': AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final maxVal = counts.values.isEmpty ? 1 : counts.values.reduce((a, b) => a > b ? a : b);
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                   const Text('Student Categories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 18),
          for (final entry in counts.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                      Text(entry.value.toString(),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: entry.value / maxVal,
                      minHeight: 7,
                      backgroundColor: AppColors.border,
                      color: _colors[entry.key] ?? AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

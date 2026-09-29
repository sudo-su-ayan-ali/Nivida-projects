import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';

class MyStudentsCard extends StatelessWidget {
  const MyStudentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final query = app.searchQuery;
    final list = app.studentsFiltered(query: query).take(6).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'My Students',
            actionLabel: 'View All Students',
            onAction: () => app.setNavIndex(2),
          ),
          const SizedBox(height: 14),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No students match "$query"', style: AppTextStyles.itemSub)),
            )
          else
            for (final s in list) _StudentRow(student: s),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final StudentItem student;
  const _StudentRow({required this.student});

  Color get _scoreColor {
    if (student.score >= 75) return AppColors.green;
    if (student.score >= 60) return AppColors.orange;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.read<AppState>().setNavIndex(2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            InitialsAvatar(seed: student.avatarSeed, size: 36),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: AppTextStyles.itemTitle),
                  Text(student.className, style: AppTextStyles.itemSub),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: student.score / 100),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 7,
                    backgroundColor: AppColors.scaffoldBg,
                    valueColor: AlwaysStoppedAnimation(_scoreColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 38,
              child: Text('${student.score}%', textAlign: TextAlign.right, style: AppTextStyles.itemTitle.copyWith(color: _scoreColor)),
            ),
          ],
        ),
      ),
    );
  }
}

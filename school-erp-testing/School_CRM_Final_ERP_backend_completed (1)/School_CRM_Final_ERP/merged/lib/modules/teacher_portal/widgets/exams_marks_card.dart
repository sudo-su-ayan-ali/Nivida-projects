import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';

class ExamsMarksCard extends StatelessWidget {
  const ExamsMarksCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.exams.take(4).toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Exams & Marks', onAction: () => app.setNavIndex(4)),
          const SizedBox(height: 14),
          if (list.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('No exams scheduled.', style: AppTextStyles.itemSub))
          else
            for (final e in list)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => app.setNavIndex(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      IconBadge(icon: e.icon, color: e.color, bgColor: e.bgColor, size: 38),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title, style: AppTextStyles.itemTitle),
                            const SizedBox(height: 2),
                            Text(e.meta, style: AppTextStyles.itemSub),
                          ],
                        ),
                      ),
                      Text(e.date, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

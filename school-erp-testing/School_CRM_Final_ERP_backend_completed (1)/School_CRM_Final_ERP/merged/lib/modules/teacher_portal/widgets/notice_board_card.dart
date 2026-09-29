import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../screens/nav_indices.dart';
import 'common/app_card.dart';

class NoticeBoardCard extends StatelessWidget {
  const NoticeBoardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.sortedNotices.take(3).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Notice Board',
            onAction: () => app.setNavIndex(kNoticeNavIndex),
          ),
          const SizedBox(height: 14),
          if (list.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('No notices posted yet.', style: AppTextStyles.itemSub))
          else
            for (final n in list) _NoticeRow(item: n),
        ],
      ),
    );
  }
}

class _NoticeRow extends StatelessWidget {
  final NoticeItem item;
  const _NoticeRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.read<AppState>().setNavIndex(kNoticeNavIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            IconBadge(
              icon: item.pinned ? Icons.push_pin_rounded : Icons.campaign_outlined,
              color: item.pinned ? AppColors.orange : AppColors.blue,
              bgColor: item.pinned ? AppColors.orangeBg : AppColors.blueBg,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTextStyles.itemTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('To: ${item.audience}', style: AppTextStyles.itemSub, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Text(item.date, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

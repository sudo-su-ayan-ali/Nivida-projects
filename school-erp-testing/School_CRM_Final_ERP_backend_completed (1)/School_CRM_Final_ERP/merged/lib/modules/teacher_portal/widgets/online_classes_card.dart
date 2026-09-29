import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../screens/nav_indices.dart';
import 'common/app_card.dart';

class OnlineClassesCard extends StatelessWidget {
  const OnlineClassesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.onlineClasses.take(3).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Online Classes',
            onAction: () => app.setNavIndex(kOnlineClassNavIndex),
          ),
          const SizedBox(height: 14),
          if (list.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('No online classes scheduled.', style: AppTextStyles.itemSub))
          else
            for (final oc in list) _OnlineClassRow(item: oc),
        ],
      ),
    );
  }
}

class _OnlineClassRow extends StatelessWidget {
  final OnlineClassItem item;
  const _OnlineClassRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.read<AppState>().setNavIndex(kOnlineClassNavIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            const IconBadge(icon: Icons.videocam_outlined, color: AppColors.blue, bgColor: AppColors.blueBg, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTextStyles.itemTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${item.className} • ${item.platform}', style: AppTextStyles.itemSub),
                ],
              ),
            ),
            StatusPill(label: item.time, color: AppColors.purple, bgColor: AppColors.purpleBg),
          ],
        ),
      ),
    );
  }
}

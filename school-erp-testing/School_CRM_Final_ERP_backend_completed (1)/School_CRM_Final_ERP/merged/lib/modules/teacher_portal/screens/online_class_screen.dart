import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';
import '../widgets/common/responsive_grid.dart';
import '../widgets/dialogs/action_dialogs.dart';

class OnlineClassScreen extends StatelessWidget {
  const OnlineClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.onlineClasses;

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
                    Text('Online Classes', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('${list.length} sessions scheduled', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                AppPrimaryButton(
                  label: 'Schedule Online Class',
                  icon: Icons.video_call_rounded,
                  onPressed: () => showAddOnlineClassDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No online classes scheduled yet.', style: AppTextStyles.itemSub)),
              )
            else
              ResponsiveGrid(
                minItemWidth: 320,
                maxColumns: 3,
                children: [for (final oc in list) _OnlineClassCard(item: oc)],
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

class _OnlineClassCard extends StatelessWidget {
  final OnlineClassItem item;
  const _OnlineClassCard({required this.item});

  IconData get _platformIcon {
    if (item.platform.toLowerCase().contains('meet')) return Icons.videocam_rounded;
    if (item.platform.toLowerCase().contains('teams')) return Icons.groups_rounded;
    return Icons.duo_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: _platformIcon, color: AppColors.blue, bgColor: AppColors.blueBg),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: AppTextStyles.itemTitle),
                    Text('${item.className} • ${item.subject}', style: AppTextStyles.itemSub),
                  ],
                ),
              ),
              InkWell(
                onTap: () => app.deleteOnlineClass(item.id),
                child: const Icon(Icons.delete_outline, size: 18, color: AppColors.red),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              StatusPill(label: item.platform, color: AppColors.blue, bgColor: AppColors.blueBg),
              const SizedBox(width: 8),
              StatusPill(label: '${item.date} • ${item.time}', color: AppColors.purple, bgColor: AppColors.purpleBg),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: AppColors.scaffoldBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item.link, style: AppTextStyles.itemSub, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: item.link));
                    showAppSnack(context, 'Meeting link copied to clipboard', icon: Icons.copy_all_rounded);
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy Link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppPrimaryButton(
                  label: 'Start / Join',
                  icon: Icons.video_camera_front_rounded,
                  onPressed: () => showAppSnack(context, 'Joining ${item.title}… (demo — frontend only)', icon: Icons.videocam_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

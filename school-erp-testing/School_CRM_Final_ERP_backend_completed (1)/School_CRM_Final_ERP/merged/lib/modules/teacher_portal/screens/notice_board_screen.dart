import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';
import '../widgets/dialogs/action_dialogs.dart';

class NoticeBoardScreen extends StatelessWidget {
  const NoticeBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final notices = app.sortedNotices;

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
                    Text('Notice Board', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('Broadcast announcements to a whole class or all parents at once', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                AppPrimaryButton(
                  label: 'Post Notice',
                  icon: Icons.campaign_rounded,
                  onPressed: () => showPostNoticeDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (notices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No notices posted yet.', style: AppTextStyles.itemSub)),
              )
            else
              for (final n in notices) _NoticeCard(item: n),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

class _NoticeCard extends StatelessWidget {
  final NoticeItem item;
  const _NoticeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBadge(
                  icon: item.pinned ? Icons.push_pin_rounded : Icons.campaign_outlined,
                  color: item.pinned ? AppColors.orange : AppColors.blue,
                  bgColor: item.pinned ? AppColors.orangeBg : AppColors.blueBg,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTextStyles.itemTitle),
                      Text('To: ${item.audience} • ${item.date}', style: AppTextStyles.itemSub),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => app.togglePinNotice(item.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      item.pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                      size: 18,
                      color: item.pinned ? AppColors.orange : AppColors.textMuted,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => app.deleteNotice(item.id),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.delete_outline, size: 18, color: AppColors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.body, style: AppTextStyles.itemSub.copyWith(color: AppColors.textPrimary, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

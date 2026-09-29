import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';
import '../widgets/dialogs/action_dialogs.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final messages = app.messages;

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
                    Text('Communication', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('${app.unreadMessagesCount} unread of ${messages.length} messages', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                AppPrimaryButton(
                  label: 'Compose',
                  icon: Icons.edit_outlined,
                  onPressed: () => showComposeMessageDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: messages.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: Text('No messages yet.', style: AppTextStyles.itemSub)),
                    )
                  : Column(
                      children: [
                        for (int i = 0; i < messages.length; i++) ...[
                          _MessageRow(item: messages[i]),
                          if (i != messages.length - 1) const Divider(height: 1, color: AppColors.border),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

class _MessageRow extends StatelessWidget {
  final MessageItem item;
  const _MessageRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<AppState>().markMessageRead(item.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBadge(icon: item.icon, color: item.color, bgColor: item.bgColor, size: 42),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTextStyles.itemTitle.copyWith(fontWeight: item.unread ? FontWeight.w800 : FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(item.meta, style: AppTextStyles.itemSub),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item.time, style: AppTextStyles.caption),
                if (item.unread) ...[
                  const SizedBox(height: 6),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

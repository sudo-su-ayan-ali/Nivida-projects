import "package:flutter/material.dart";
import "../../core/theme/app_colors.dart";
import "../../core/constants/app_spacing.dart";

class NotificationItemData {
  final IconData icon;
  final Color color;
  final String title;
  final String time;
  final bool read;
  const NotificationItemData({required this.icon, required this.color, required this.title, required this.time, this.read = false});
}

class NotificationPanel extends StatelessWidget {
  final List<NotificationItemData> items;
  final VoidCallback? onMarkAllRead;

  const NotificationPanel({super.key, required this.items, this.onMarkAllRead});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      constraints: const BoxConstraints(maxHeight: 420),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.raised,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Expanded(child: Text("Notifications", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                TextButton(onPressed: onMarkAllRead, child: const Text("Mark all read", style: TextStyle(fontSize: 12))),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (_, i) {
                final n = items[i];
                return ListTile(
                  leading: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: n.color.withOpacity(0.12), shape: BoxShape.circle),
                    child: Icon(n.icon, color: n.color, size: 18),
                  ),
                  title: Text(n.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(n.time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  trailing: n.read ? null : Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

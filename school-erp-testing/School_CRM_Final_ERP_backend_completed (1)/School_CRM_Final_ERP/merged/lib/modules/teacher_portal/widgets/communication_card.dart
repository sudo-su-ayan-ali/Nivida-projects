import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';

class CommunicationCard extends StatelessWidget {
  const CommunicationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.messages.take(4).toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Communication', onAction: () => app.setNavIndex(5)),
          const SizedBox(height: 14),
          if (list.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('No messages yet.', style: AppTextStyles.itemSub))
          else
            for (final m in list)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  app.markMessageRead(m.id);
                  app.setNavIndex(5);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconBadge(icon: m.icon, color: m.color, bgColor: m.bgColor, size: 38),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.title, style: AppTextStyles.itemTitle),
                            const SizedBox(height: 2),
                            Text(m.meta, style: AppTextStyles.itemSub),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(m.time, style: AppTextStyles.caption),
                          if (m.unread) ...[
                            const SizedBox(height: 5),
                            Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

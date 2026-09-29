import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';

class BottomAnalyticsBar extends StatelessWidget {
  final bool isMobile;
  const BottomAnalyticsBar({super.key, this.isMobile = false});

  @override
Widget build(BuildContext context) {
  final analytics = context.watch<AppState>().analytics;
  return AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    child: Wrap(
      spacing: 18,
      runSpacing: 16,
      children: analytics.map((a) => SizedBox(width: 150, child: _tile(a))).toList(),
    ),
  );
}

  Widget _tile(AnalyticsItem a) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconBadge(icon: a.icon, color: a.color, bgColor: a.bgColor, size: 38),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(a.value,
                  style: AppTextStyles.statValue.copyWith(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(a.label,
                  style: AppTextStyles.itemSub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

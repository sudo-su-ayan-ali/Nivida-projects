import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import 'section_card.dart';

class AlertsSection extends StatelessWidget {
  const AlertsSection({super.key});

  static const _statusLabels = ['Low Stock', 'Out of Stock', 'Expired', 'Reserved'];

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final alerts = appState.liveAlerts;

   return SectionCard(
  title: 'Inventory Alerts',
  child: Column(
        children: [
          for (var i = 0; i < alerts.length; i++) ...[
            _AlertTile(
              data: alerts[i],
              onView: () {
                appState.setStatusFilter(_statusLabels[i]);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Table filtered by "${_statusLabels[i]}" — scroll down')),
                );
              },
            ),
            if (i != alerts.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final AlertData data;
  final VoidCallback onView;
  const _AlertTile({required this.data, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(color: data.bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(data.icon, color: data.color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                Text(
                  data.subtitle,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onView,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text('View', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

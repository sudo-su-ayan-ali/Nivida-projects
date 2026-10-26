import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../theme/app_theme.dart';
import 'section_card.dart';

/// Displays either "Recent Stock In" or "Recent Stock Out" list depending
/// on [items] passed in, driven by the same reusable card layout. [items]
/// is a live reference into AppState's log, so it updates automatically
/// whenever a Stock In / Stock Out action happens elsewhere in the app.
class StockActivitySection extends StatelessWidget {
  final String title;
  final List<StockActivity> items;
  const StockActivitySection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final recent = items.take(4).toList();

    return SectionCard(
      title: title,
      actionLabel: items.length > 4 ? 'View All' : null,
      onAction: items.length > 4 ? () => _showFullLog(context) : null,
      child: recent.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No activity yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            )
          : Column(
              children: [
                for (var i = 0; i < recent.length; i++) ...[
                  _ActivityTile(activity: recent[i]),
                  if (i != recent.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }

  void _showFullLog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 400,
          height: 420,
          child: items.isEmpty
              ? const Center(child: Text('No activity yet', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 20),
                  itemBuilder: (_, i) => _ActivityTile(activity: items[i]),
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final StockActivity activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final isIn = activity.direction == StockDirection.stockIn;
    final color = isIn ? AppColors.green : AppColors.red;
    final bg = isIn ? AppColors.greenLight : AppColors.redLight;
    final sign = isIn ? '+' : '-';
    final label = isIn ? 'Items Added' : 'Items Issued';

    return Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(activity.icon, size: 17, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.itemName,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$sign${activity.quantity} $label',
                style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Text(activity.date, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
      ],
    );
  }
}

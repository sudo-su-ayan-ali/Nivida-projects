import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import 'section_card.dart';

class LowStockSection extends StatelessWidget {
  const LowStockSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final lowStock = appState.liveLowStock;

    return SectionCard(
  title: 'Low Stock Items',
  child: lowStock.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No low stock items right now 🎉',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            )
          : Column(
              children: [
                for (var i = 0; i < lowStock.length; i++) ...[
                  _LowStockTile(item: lowStock[i]),
                  if (i != lowStock.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

class _LowStockTile extends StatelessWidget {
  final LowStockItem item;
  const _LowStockTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(color: item.iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(item.icon, size: 18, color: item.iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.orangeLight, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Low Stock',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.orange)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: item.ratio.clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                ),
              ),
              const SizedBox(height: 4),
              Text('${item.current} / ${item.max}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

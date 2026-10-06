import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/responsive.dart';

class KpiSection extends StatelessWidget {
  const KpiSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final columns = Responsive.gridColumns(context, mobile: 1, tablet: 2, desktop: 5);

    final kpis = <KpiData>[
      KpiData(
        title: 'Total Items',
        value: '${appState.totalSkuCount}',
        subtitle: 'All Items',
        icon: Icons.layers_rounded,
        iconColor: AppColors.blue,
        iconBg: AppColors.blueLight,
      ),
      KpiData(
        title: 'Total Categories',
        value: '${appState.activeCategoryCount}',
        subtitle: 'Active Categories',
        icon: Icons.grid_view_rounded,
        iconColor: AppColors.purple,
        iconBg: AppColors.purpleLight,
      ),
      KpiData(
        title: 'Total Value',
        value: '₹${formatIndianNumber(appState.totalValue)}',
        subtitle: 'Inventory Value',
        icon: Icons.currency_rupee_rounded,
        iconColor: AppColors.green,
        iconBg: AppColors.greenLight,
      ),
      KpiData(
        title: 'Low Stock Items',
        value: '${appState.lowStockCount}',
        subtitle: 'Reorder Soon',
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.orange,
        iconBg: AppColors.orangeLight,
      ),
      KpiData(
        title: 'Out of Stock',
        value: '${appState.outOfStockCount}',
        subtitle: 'Not Available',
        icon: Icons.cancel_outlined,
        iconColor: AppColors.red,
        iconBg: AppColors.redLight,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: kpis
              .map((k) => SizedBox(
                    width: columns == 1 ? constraints.maxWidth : width,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          if (k.title == 'Low Stock Items') {
                            appState.setStatusFilter('Low Stock');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Filtered table by Low Stock items')),
                            );
                          } else if (k.title == 'Out of Stock') {
                            appState.setStatusFilter('Out of Stock');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Filtered table by Out of Stock items')),
                            );
                          } else if (k.title == 'Total Items') {
                            appState.clearFilters();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reset all filters — showing all items')),
                            );
                          }
                        },
                        child: KpiCard(data: k),
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

class KpiCard extends StatelessWidget {
  final KpiData data;
  const KpiCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, (1 - value) * 12), child: child),
        );
      },
      child: Container(
        decoration: cardDecoration(),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.value,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(color: data.iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(data.icon, color: data.iconColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

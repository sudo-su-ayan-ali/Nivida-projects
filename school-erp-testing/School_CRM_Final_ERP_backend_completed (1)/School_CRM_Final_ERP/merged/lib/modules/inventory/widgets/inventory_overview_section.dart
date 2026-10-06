import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'section_card.dart';

class InventoryOverviewSection extends StatelessWidget {
  const InventoryOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final columns = Responsive.gridColumns(context, mobile: 2, tablet: 3, desktop: 2);

    final stats = <OverviewStat>[
      OverviewStat(
        title: 'Available Items',
        value: '${appState.inStockCount}',
        icon: Icons.fact_check_rounded,
        iconColor: AppColors.green,
        iconBg: AppColors.greenLight,
      ),
      OverviewStat(
        title: 'Issued Items',
        value: '${appState.issuedCount}',
        icon: Icons.output_rounded,
        iconColor: AppColors.blue,
        iconBg: AppColors.blueLight,
      ),
      OverviewStat(
        title: 'Reserved Items',
        value: '${appState.reservedCount}',
        icon: Icons.bookmark_rounded,
        iconColor: AppColors.purple,
        iconBg: AppColors.purpleLight,
      ),
      OverviewStat(
        title: 'Damaged Items',
        value: '${appState.damagedCount}',
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.orange,
        iconBg: AppColors.orangeLight,
      ),
      OverviewStat(
        title: 'Expired Items',
        value: '${appState.expiredCount}',
        icon: Icons.event_busy_rounded,
        iconColor: AppColors.red,
        iconBg: AppColors.redLight,
      ),
      OverviewStat(
        title: 'Suppliers',
        value: '${appState.supplierCount}',
        icon: Icons.groups_rounded,
        iconColor: AppColors.teal,
        iconBg: AppColors.tealLight,
      ),
    ];

    return SectionCard(
      title: 'Inventory Overview',
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 12.0;
          final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: stats
                .map((s) => SizedBox(
                      width: width,
                      child: _OverviewTile(
                        stat: s,
                        onTap: () {
                          if (s.title == 'Available Items') {
                            appState.setStatusFilter('In Stock');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Filtered table by In Stock items')),
                            );
                          } else if (s.title == 'Reserved Items') {
                            appState.setStatusFilter('Reserved');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Filtered table by Reserved items')),
                            );
                          } else if (s.title == 'Expired Items') {
                            appState.setStatusFilter('Expired');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Filtered table by Expired items')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${s.title}: ${s.value}')),
                            );
                          }
                        },
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

class _OverviewTile extends StatelessWidget {
  final OverviewStat stat;
  final VoidCallback onTap;
  const _OverviewTile({required this.stat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(color: stat.iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(stat.icon, color: stat.iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.value,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      stat.title,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
